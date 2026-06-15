import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../models/novel.dart';
import 'chapter_editor_screen.dart';
import 'character_list_screen.dart';
import 'world_setting_screen.dart';

/// 小说编辑器页面
class NovelEditorScreen extends StatefulWidget {
  final String novelId;

  const NovelEditorScreen({super.key, required this.novelId});

  @override
  State<NovelEditorScreen> createState() => _NovelEditorScreenState();
}

class _NovelEditorScreenState extends State<NovelEditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NovelProvider>().loadNovel(widget.novelId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();
    final novel = novelProvider.currentNovel;
    final colorScheme = Theme.of(context).colorScheme;

    if (novel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('小说')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showNovelInfo(context, novel),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '章节'),
            Tab(text: '人物'),
            Tab(text: '设定'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChaptersTab(novel: novel),
          _CharactersTab(novel: novel),
          _WorldSettingTab(novel: novel),
        ],
      ),
      floatingActionButton: _buildFAB(context, novel),
    );
  }

  Widget _buildFAB(BuildContext context, Novel novel) {
    return FloatingActionButton.extended(
      onPressed: () {
        if (_tabController.index == 0) {
          _addChapter(context, novel);
        } else if (_tabController.index == 1) {
          _addCharacter(context, novel);
        }
      },
      icon: const Icon(Icons.add_rounded),
      label: Text(_tabController.index == 0 ? '添加章节' : '添加角色'),
    );
  }

  void _addChapter(BuildContext context, Novel novel) async {
    final titleController = TextEditingController(text: '第${novel.chapters.length + 1}章');
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加章节'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: '章节标题'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(context, titleController.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      final chapter = await context.read<NovelProvider>().createChapter(
        novelId: novel.id,
        title: result,
      );
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChapterEditorScreen(
              novelId: novel.id,
              chapterId: chapter.id,
              chapterTitle: chapter.title,
            ),
          ),
        );
      }
    }
  }

  void _addCharacter(BuildContext context, Novel novel) async {
    final nameController = TextEditingController();
    String selectedRole = 'supporting';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加角色'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '角色名称'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: '角色定位'),
                items: CharacterRole.names.entries.map((e) {
                  return DropdownMenuItem(value: e.key, child: Text(e.value));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedRole = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await context.read<NovelProvider>().addCharacter(
                  novelId: novel.id,
                  name: nameController.text.trim(),
                  role: selectedRole,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNovelInfo(BuildContext context, Novel novel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _NovelInfoSheet(
          novel: novel,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _ChaptersTab extends StatelessWidget {
  final Novel novel;

  const _ChaptersTab({required this.novel});

  @override
  Widget build(BuildContext context) {
    if (novel.chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('暂无章节', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('点击下方按钮添加第一章'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: novel.chapters.length,
      itemBuilder: (context, index) {
        final chapter = novel.chapters[index];
        return _ChapterCard(novel: novel, chapter: chapter, index: index);
      },
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Novel novel;
  final Chapter chapter;
  final int index;

  const _ChapterCard({required this.novel, required this.chapter, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text('${index + 1}', style: TextStyle(color: colorScheme.onPrimaryContainer)),
        ),
        title: Text(chapter.title),
        subtitle: Text('${chapter.wordCount} 字'),
        trailing: chapter.isPublished
            ? Icon(Icons.check_circle, color: Colors.green, size: 20)
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChapterEditorScreen(
                novelId: novel.id,
                chapterId: chapter.id,
                chapterTitle: chapter.title,
              ),
            ),
          );
        },
        onLongPress: () => _showChapterOptions(context),
      ),
    );
  }

  void _showChapterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('编辑章节'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChapterEditorScreen(
                    novelId: novel.id,
                    chapterId: chapter.id,
                    chapterTitle: chapter.title,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(chapter.isPublished ? Icons.visibility_off : Icons.visibility, color: Colors.blue),
            title: Text(chapter.isPublished ? '取消发布' : '发布章节'),
            onTap: () async {
              Navigator.pop(context);
              final updated = chapter.copyWith(isPublished: !chapter.isPublished);
              await context.read<NovelProvider>().updateChapter(updated);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('删除章节', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认删除'),
                  content: Text('确定要删除"${chapter.title}"吗？'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<NovelProvider>().deleteChapter(chapter.id, novel.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CharactersTab extends StatelessWidget {
  final Novel novel;

  const _CharactersTab({required this.novel});

  @override
  Widget build(BuildContext context) {
    if (novel.characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('暂无角色', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('点击下方按钮添加角色'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: novel.characters.length,
      itemBuilder: (context, index) {
        final character = novel.characters[index];
        return _CharacterCard(novel: novel, character: character);
      },
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Novel novel;
  final Character character;

  const _CharacterCard({required this.novel, required this.character});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(character.role).withOpacity(0.2),
          child: Text(character.name[0], style: TextStyle(color: _getRoleColor(character.role))),
        ),
        title: Text(character.name),
        subtitle: Text(CharacterRole.getName(character.role)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CharacterDetailScreen(novelId: novel.id, character: character),
            ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'protagonist':
        return Colors.purple;
      case 'antagonist':
        return Colors.red;
      case 'supporting':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _WorldSettingTab extends StatelessWidget {
  final Novel novel;

  const _WorldSettingTab({required this.novel});

  @override
  Widget build(BuildContext context) {
    final worldSetting = novel.worldSetting;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingCard(
          icon: Icons.access_time,
          title: '时代背景',
          content: worldSetting.timePeriod.isEmpty ? '未设置' : worldSetting.timePeriod,
          onTap: () => _editSetting(context, 'timePeriod', '时代背景', worldSetting.timePeriod),
        ),
        _SettingCard(
          icon: Icons.location_on_outlined,
          title: '地理位置',
          content: worldSetting.location.isEmpty ? '未设置' : worldSetting.location,
          onTap: () => _editSetting(context, 'location', '地理位置', worldSetting.location),
        ),
        _SettingCard(
          icon: Icons.auto_awesome,
          title: '修炼体系',
          content: worldSetting.magicSystem.isEmpty ? '未设置' : worldSetting.magicSystem,
          onTap: () => _editSetting(context, 'magicSystem', '修炼体系', worldSetting.magicSystem),
        ),
        _SettingCard(
          icon: Icons.account_balance_outlined,
          title: '政治格局',
          content: worldSetting.politics.isEmpty ? '未设置' : worldSetting.politics,
          onTap: () => _editSetting(context, 'politics', '政治格局', worldSetting.politics),
        ),
        _SettingCard(
          icon: Icons.monetization_on_outlined,
          title: '经济体系',
          content: worldSetting.economy.isEmpty ? '未设置' : worldSetting.economy,
          onTap: () => _editSetting(context, 'economy', '经济体系', worldSetting.economy),
        ),
        _SettingCard(
          icon: Icons.menu_book_outlined,
          title: '文化习俗',
          content: worldSetting.culture.isEmpty ? '未设置' : worldSetting.culture,
          onTap: () => _editSetting(context, 'culture', '文化习俗', worldSetting.culture),
        ),
      ],
    );
  }

  void _editSetting(BuildContext context, String field, String title, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(hintText: '输入$title...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final newWorldSetting = WorldSetting(
                name: novel.worldSetting.name,
                description: novel.worldSetting.description,
                timePeriod: field == 'timePeriod' ? controller.text : novel.worldSetting.timePeriod,
                location: field == 'location' ? controller.text : novel.worldSetting.location,
                culture: field == 'culture' ? controller.text : novel.worldSetting.culture,
                magicSystem: field == 'magicSystem' ? controller.text : novel.worldSetting.magicSystem,
                politics: field == 'politics' ? controller.text : novel.worldSetting.politics,
                economy: field == 'economy' ? controller.text : novel.worldSetting.economy,
                technology: novel.worldSetting.technology,
              );
              await context.read<NovelProvider>().updateWorldSetting(novel.id, newWorldSetting);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final VoidCallback onTap;

  const _SettingCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title),
        subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.edit_outlined, size: 20),
        onTap: onTap,
      ),
    );
  }
}

class _NovelInfoSheet extends StatelessWidget {
  final Novel novel;
  final ScrollController scrollController;

  const _NovelInfoSheet({required this.novel, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text(novel.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              label: Text(NovelGenre.getName(novel.genre)),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: '字数', value: '${novel.totalWordCount}'),
              _StatItem(label: '章节', value: '${novel.chapterCount}'),
              _StatItem(label: '角色', value: '${novel.characters.length}'),
            ],
          ),
          if (novel.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('简介', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(novel.description),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../models/novel.dart';
import '../widgets/page_decoration.dart';
import 'novel_editor_screen.dart';
import 'novel_tools_screen.dart';

/// 小说列表页面
class NovelListScreen extends StatefulWidget {
  const NovelListScreen({super.key});

  @override
  State<NovelListScreen> createState() => _NovelListScreenState();
}

class _NovelListScreenState extends State<NovelListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NovelProvider>().loadNovels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final novelProvider = context.watch<NovelProvider>();

    return PageDecoration.standardScaffold(
      context: context,
      title: '我的小说',
      showBackButton: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.build_outlined),
          tooltip: '小说工具箱',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NovelToolsScreen()),
            );
          },
        ),
      ],
      body: novelProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : novelProvider.novels.isEmpty
              ? _buildEmptyState(context)
              : _buildNovelList(context, novelProvider.novels),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('新建小说'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return PageDecoration.emptyState(
      icon: Icons.auto_stories_outlined,
      message: '暂无小说\n点击下方按钮创建你的第一部小说',
      actionLabel: '创建小说',
      onAction: () => _showCreateDialog(context),
    );
  }

  Widget _buildNovelList(BuildContext context, List<Novel> novels) {
    return PageDecoration.scrollContent(
      child: Column(
        children: novels.map((novel) {
          return PageDecoration.card(
            child: _NovelCard(novel: novel),
          );
        }).toList(),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedGenre = 'other';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('创建小说'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PageDecoration.inputField(
                controller: titleController,
                label: '书名',
                hint: '输入小说名称',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGenre,
                decoration: const InputDecoration(labelText: '类型'),
                items: NovelGenre.names.entries.map((e) {
                  return DropdownMenuItem(value: e.key, child: Text(e.value));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedGenre = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final novel = await context.read<NovelProvider>().createNovel(
                  title: titleController.text.trim(),
                  genre: selectedGenre,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NovelEditorScreen(novelId: novel.id),
                    ),
                  );
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NovelCard extends StatelessWidget {
  final Novel novel;

  const _NovelCard({required this.novel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NovelEditorScreen(novelId: novel.id),
          ),
        );
      },
      onLongPress: () => _showOptionsMenu(context),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Expanded(
                child: Text(
                  novel.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusChip(context),
            ],
          ),
          PageDecoration.divider(height: 12),
          
          // 信息标签行
          Row(
            children: [
              _buildInfoChip(Icons.category_outlined, NovelGenre.getName(novel.genre)),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.text_fields_rounded, '${novel.totalWordCount} 字'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.library_books_outlined, '${novel.chapterCount} 章'),
            ],
          ),
          
          // 描述
          if (novel.description.isNotEmpty) ...[
            PageDecoration.divider(height: 12),
            Text(
              novel.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // 更新时间
          PageDecoration.divider(height: 12),
          Row(
            children: [
              Icon(Icons.update_outlined, size: 14, color: colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                '更新于 ${_formatDate(novel.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color bgColor;
    String label;
    
    switch (novel.status) {
      case 'completed':
        bgColor = Colors.green;
        label = '已完成';
        break;
      case 'paused':
        bgColor = Colors.orange;
        label = '暂停';
        break;
      default:
        bgColor = Theme.of(context).colorScheme.primary;
        label = '创作中';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: bgColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}-${date.day}';
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text('《${novel.title}》', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('编辑小说'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NovelEditorScreen(novelId: novel.id),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('删除小说', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认删除'),
                  content: Text('确定要删除《${novel.title}》吗？此操作不可恢复。'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<NovelProvider>().deleteNovel(novel.id);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

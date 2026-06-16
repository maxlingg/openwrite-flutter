import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/novel_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../services/webdav_service.dart';
import '../services/import_export_service.dart';
import '../services/recycle_bin_service.dart';
import '../services/bookmark_service.dart';
import '../models/note.dart';
import '../widgets/page_decoration.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final novelProvider = context.watch<NovelProvider>();

    return PageDecoration.standardScaffold(
      context: context,
      title: '设置',
      showBackButton: true,
      body: PageDecoration.scrollContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统计卡片
            PageDecoration.statsRow(
              context,
              items: [
                StatItem(
                  icon: Icons.article_outlined,
                  value: '${notesProvider.notesCount}',
                  label: '笔记',
                ),
                StatItem(
                  icon: Icons.text_fields_rounded,
                  value: _formatWordCount(notesProvider.totalWordCount),
                  label: '字数',
                ),
                StatItem(
                  icon: Icons.book_outlined,
                  value: '${novelProvider.novels.length}',
                  label: '小说',
                ),
              ],
            ),
            
            PageDecoration.divider(height: 32),
            
            // 外观设置
            PageDecoration.sectionTitle(context, '外观'),
            _buildThemeTile(context),
            
            PageDecoration.divider(height: 32),
            
            // 数据管理
            PageDecoration.sectionTitle(context, '数据管理'),
            PageDecoration.card(
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.cloud_upload_outlined,
                    title: '导出数据',
                    subtitle: '导出笔记为 JSON 或 ZIP',
                    onTap: () => _showExportDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.cloud_download_outlined,
                    title: '导入数据',
                    subtitle: '从 JSON 或 ZIP 恢复笔记',
                    onTap: () => _showImportDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.sync_outlined,
                    title: 'WebDav 同步',
                    subtitle: '配置云端同步',
                    onTap: () => _showWebDavDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.backup_outlined,
                    title: '自动备份',
                    subtitle: '定期备份到本地',
                    onTap: () => _showBackupDialog(context),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            
            PageDecoration.divider(height: 32),
            
            // 书签收藏
            PageDecoration.sectionTitle(context, '书签收藏'),
            PageDecoration.card(
              child: _buildListTile(
                context,
                icon: Icons.bookmark_outline,
                title: '我的书签',
                subtitle: '查看收藏的笔记和章节',
                onTap: () => _showBookmarksDialog(context),
                showDivider: false,
              ),
            ),
            
            PageDecoration.divider(height: 32),
            
            // 回收站
            PageDecoration.sectionTitle(context, '回收站'),
            PageDecoration.card(
              child: _buildListTile(
                context,
                icon: Icons.delete_outline_rounded,
                title: '回收站',
                subtitle: '查看已删除的笔记',
                onTap: () => _showRecycleBinDialog(context),
                showDivider: false,
              ),
            ),
            
            PageDecoration.divider(height: 32),
            
            // 关于
            PageDecoration.sectionTitle(context, '关于'),
            PageDecoration.card(
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: '关于墨韵笔记',
                    subtitle: '版本 1.2.2',
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    context,
                    icon: Icons.code,
                    title: '开源项目',
                    subtitle: 'GitHub: openwrite-flutter',
                    onTap: () => _showSourceDialog(context),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            
            PageDecoration.divider(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return PageDecoration.card(
      child: PageDecoration.listTile(
        icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        title: '深色模式',
        subtitle: themeProvider.isDarkMode ? '已开启' : '已关闭',
        trailing: Switch(
          value: themeProvider.isDarkMode,
          onChanged: (value) => themeProvider.toggleTheme(),
        ),
        onTap: () => themeProvider.toggleTheme(),
        iconColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        PageDecoration.listTile(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  String _formatWordCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 10000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 10000).toStringAsFixed(1)}W';
  }

  // 导出对话框
  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text('导出笔记', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.file_present_outlined),
            title: const Text('导出为 JSON'),
            subtitle: const Text('可用于备份和恢复'),
            onTap: () async {
              Navigator.pop(context);
              final service = ImportExportService(StorageService());
              try {
                final path = await service.exportToJson();
                if (path != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已导出到: $path')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('导出失败: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_zip_outlined),
            title: const Text('导出为 ZIP'),
            subtitle: const Text('包含所有笔记的压缩包'),
            onTap: () async {
              Navigator.pop(context);
              final service = ImportExportService(StorageService());
              try {
                final path = await service.exportToZip();
                if (path != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已导出到: $path')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('导出失败: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 导入对话框
  void _showImportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text('导入笔记', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.file_present_outlined),
            title: const Text('从 JSON 导入'),
            onTap: () async {
              Navigator.pop(context);
              final service = ImportExportService(StorageService());
              try {
                final count = await service.importFromJson();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('成功导入 $count 篇笔记')),
                  );
                  context.read<NotesProvider>().loadNotes();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('导入失败: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_zip_outlined),
            title: const Text('从 ZIP 导入'),
            onTap: () async {
              Navigator.pop(context);
              final service = ImportExportService(StorageService());
              try {
                final count = await service.importFromZip();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('成功导入 $count 篇笔记')),
                  );
                  context.read<NotesProvider>().loadNotes();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('导入失败: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // WebDav 配置对话框
  void _showWebDavDialog(BuildContext context) {
    final urlController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final basePathController = TextEditingController(text: '/OpenWrite');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WebDav 同步配置'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PageDecoration.inputField(
                controller: urlController,
                label: '服务器地址',
                hint: 'https://dav.example.com',
              ),
              const SizedBox(height: 16),
              PageDecoration.inputField(
                controller: usernameController,
                label: '用户名',
              ),
              const SizedBox(height: 16),
              PageDecoration.inputField(
                controller: passwordController,
                label: '密码',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              PageDecoration.inputField(
                controller: basePathController,
                label: '同步目录',
                hint: '/OpenWrite',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final config = WebDavConfig(
                serverUrl: urlController.text.trim(),
                username: usernameController.text.trim(),
                password: passwordController.text,
                basePath: basePathController.text.trim(),
              );
              final service = WebDavService();
              final success = await service.testConnection(config);
              if (success) {
                await service.saveConfig(config);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('配置已保存')),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('连接失败，请检查配置')),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 自动备份对话框
  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自动备份'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('设置自动备份频率：'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('每日自动备份'),
              leading: const Icon(Icons.today),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已设置每日自动备份')),
                );
              },
            ),
            ListTile(
              title: const Text('每周自动备份'),
              leading: const Icon(Icons.date_range),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已设置每周自动备份')),
                );
              },
            ),
            ListTile(
              title: const Text('关闭自动备份'),
              leading: const Icon(Icons.block),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已关闭自动备份')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 书签对话框
  void _showBookmarksDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _BookmarksContent(
          scrollController: scrollController,
        ),
      ),
    );
  }

  // 回收站对话框
  void _showRecycleBinDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _RecycleBinContent(
          scrollController: scrollController,
        ),
      ),
    );
  }

  // 关于对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '墨韵笔记',
      applicationVersion: '1.2.2',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('📝', style: TextStyle(fontSize: 32))),
      ),
      children: const [
        Text('一个现代美观的笔记应用，支持 Markdown 编辑、云端同步、数据导入导出等功能。'),
        SizedBox(height: 16),
        Text('主要功能：'),
        Text('• AI 写作助手'),
        Text('• 小说创作管理'),
        Text('• WebDav 云端同步'),
        Text('• 数据导入导出'),
      ],
    );
  }

  // 源代码对话框
  void _showSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开源项目'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('墨韵笔记 (OpenWrite)'),
            const SizedBox(height: 8),
            const Text('基于 Flutter 开发的现代化笔记应用'),
            const SizedBox(height: 16),
            const Text('GitHub: openwrite-flutter'),
            const SizedBox(height: 8),
            const Text('欢迎 Star 和 Fork！'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 书签内容组件
class _BookmarksContent extends StatefulWidget {
  final ScrollController scrollController;
  
  const _BookmarksContent({required this.scrollController});

  @override
  State<_BookmarksContent> createState() => _BookmarksContentState();
}

class _BookmarksContentState extends State<_BookmarksContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookmarkService _bookmarkService = BookmarkService(StorageService());
  List<Bookmark> _noteBookmarks = [];
  List<Bookmark> _chapterBookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final noteBookmarks = await _bookmarkService.getNoteBookmarks();
    final chapterBookmarks = await _bookmarkService.getChapterBookmarks();
    setState(() {
      _noteBookmarks = noteBookmarks;
      _chapterBookmarks = chapterBookmarks;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '我的书签',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '笔记书签 (${_noteBookmarks.length})'),
              Tab(text: '章节书签 (${_chapterBookmarks.length})'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookmarkList(_noteBookmarks, BookmarkType.note),
                      _buildBookmarkList(_chapterBookmarks, BookmarkType.chapter),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList(List<Bookmark> bookmarks, BookmarkType type) {
    if (bookmarks.isEmpty) {
      return PageDecoration.emptyState(
        icon: Icons.bookmark_border,
        message: '暂无书签\n收藏笔记或章节后会在此显示',
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              type == BookmarkType.note ? Icons.article : Icons.book,
            ),
            title: Text(bookmark.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: bookmark.description != null
                ? Text(bookmark.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_remove),
              onPressed: () async {
                await _bookmarkService.removeBookmark(bookmark.itemId, type);
                _loadBookmarks();
              },
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}

/// 回收站内容组件
class _RecycleBinContent extends StatefulWidget {
  final ScrollController scrollController;
  
  const _RecycleBinContent({required this.scrollController});

  @override
  State<_RecycleBinContent> createState() => _RecycleBinContentState();
}

class _RecycleBinContentState extends State<_RecycleBinContent> {
  List<RecycleBinItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = RecycleBinService(StorageService());
    final items = await service.getDeletedNotes();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('回收站', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (_items.isNotEmpty)
                  TextButton(
                    onPressed: _emptyRecycleBin,
                    child: const Text('清空'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? PageDecoration.emptyState(
                        icon: Icons.delete_outline,
                        message: '回收站为空',
                      )
                    : ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                item.note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '删除于 ${_formatDate(item.deletedAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.restore_rounded),
                                    onPressed: () => _restore(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever_rounded),
                                    onPressed: () => _permanentDelete(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}-${date.month}-${date.day}';

  Future<void> _restore(RecycleBinItem item) async {
    final service = RecycleBinService(StorageService());
    await service.restoreNote(item.note.id);
    await _loadData();
    if (mounted) context.read<NotesProvider>().loadNotes();
  }

  Future<void> _permanentDelete(RecycleBinItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('永久删除'),
        content: const Text('确定要永久删除这条笔记吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final service = RecycleBinService(StorageService());
      await service.permanentlyDelete(item.note.id);
      await _loadData();
    }
  }

  Future<void> _emptyRecycleBin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空回收站'),
        content: const Text('确定要清空回收站吗？所有已删除的笔记将被永久删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final service = RecycleBinService(StorageService());
      await service.emptyRecycleBin();
      await _loadData();
    }
  }
}

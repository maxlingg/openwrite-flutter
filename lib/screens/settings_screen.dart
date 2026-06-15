import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../services/storage_service.dart';
import '../services/webdav_service.dart';
import '../services/import_export_service.dart';
import '../services/recycle_bin_service.dart';
import '../models/note.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notesProvider = context.watch<NotesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primaryContainer, colorScheme.primaryContainer.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, icon: Icons.article_outlined, value: '${notesProvider.notesCount}', label: '笔记'),
                _buildStatItem(context, icon: Icons.text_fields_rounded, value: _formatWordCount(notesProvider.totalWordCount), label: '字数'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildSectionTitle(context, '数据管理'),
          _buildListTile(context, icon: Icons.cloud_upload_outlined, title: '导出数据', subtitle: '导出笔记为 JSON 或 ZIP', onTap: () => _showExportDialog(context)),
          _buildListTile(context, icon: Icons.cloud_download_outlined, title: '导入数据', subtitle: '从 JSON 或 ZIP 恢复笔记', onTap: () => _showImportDialog(context)),
          _buildListTile(context, icon: Icons.sync_outlined, title: 'WebDav 同步', subtitle: '配置云端同步', onTap: () => _showWebDavDialog(context)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildSectionTitle(context, '回收站'),
          _buildListTile(context, icon: Icons.delete_outline_rounded, title: '回收站', subtitle: '查看已删除的笔记', onTap: () => _showRecycleBinDialog(context)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildSectionTitle(context, '关于'),
          _buildListTile(context, icon: Icons.info_outline_rounded, title: '关于墨韵笔记', subtitle: '版本 1.2.2', onTap: () => _showAboutDialog(context)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required IconData icon, required String value, required String label}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, size: 32, color: colorScheme.onPrimaryContainer),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 22),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }

  String _formatWordCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 10000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 10000).toStringAsFixed(1)}W';
  }

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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导出到: $path')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败: $e')));
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已导出到: $path')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败: $e')));
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('成功导入 $count 篇笔记')));
                  context.read<NotesProvider>().loadNotes();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导入失败: $e')));
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('成功导入 $count 篇笔记')));
                  context.read<NotesProvider>().loadNotes();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导入失败: $e')));
                }
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

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
              TextField(controller: urlController, decoration: const InputDecoration(labelText: '服务器地址', hintText: 'https://dav.example.com')),
              const SizedBox(height: 16),
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: '用户名')),
              const SizedBox(height: 16),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: '密码')),
              const SizedBox(height: 16),
              TextField(controller: basePathController, decoration: const InputDecoration(labelText: '同步目录', hintText: '/OpenWrite')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              final config = WebDavConfig(serverUrl: urlController.text.trim(), username: usernameController.text.trim(), password: passwordController.text, basePath: basePathController.text.trim());
              final service = WebDavService();
              final success = await service.testConnection(config);
              if (success) {
                await service.saveConfig(config);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('配置已保存')));
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('连接失败，请检查配置')));
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showRecycleBinDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.95, expand: false, builder: (context, scrollController) => _RecycleBinContent(scrollController: scrollController)),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '墨韵笔记',
      applicationVersion: '1.2.2',
      applicationIcon: Container(width: 64, height: 64, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('📝', style: TextStyle(fontSize: 32)))),
      children: const [Text('一个现代美观的笔记应用，支持 Markdown 编辑、云端同步、数据导入导出等功能。')],
    );
  }
}

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
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('回收站', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (_items.isNotEmpty) TextButton(onPressed: _emptyRecycleBin, child: const Text('清空')),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete_outline, size: 64, color: colorScheme.outline), const SizedBox(height: 16), Text('回收站为空', style: Theme.of(context).textTheme.bodyLarge)]))
                    : ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(item.note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('删除于 ${_formatDate(item.deletedAt)}', style: const TextStyle(fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.restore_rounded), onPressed: () => _restore(item)),
                                  IconButton(icon: const Icon(Icons.delete_forever_rounded), onPressed: () => _permanentDelete(item)),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('清空')),
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

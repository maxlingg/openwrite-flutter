import 'package:flutter/material.dart';
import '../services/recycle_bin_service.dart';

/// 回收站对话框
class RecycleBinDialog extends StatefulWidget {
  final RecycleBinService service;
  final Function(String id, String type)? onRestore;
  final Function(String id)? onDelete;

  const RecycleBinDialog({
    super.key,
    required this.service,
    this.onRestore,
    this.onDelete,
  });

  @override
  State<RecycleBinDialog> createState() => _RecycleBinDialogState();
}

class _RecycleBinDialogState extends State<RecycleBinDialog> {
  List<RecycleBinItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    _items = await widget.service.loadItems();
    setState(() => _isLoading = false);
  }

  void _restore(RecycleBinItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复'),
        content: Text('确定要恢复"${item.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.service.restoreItem(item.id);
              widget.onRestore?.call(item.id, item.type);
              await _loadItems();
            },
            child: const Text('恢复'),
          ),
        ],
      ),
    );
  }

  void _delete(RecycleBinItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('永久删除'),
        content: Text('确定要永久删除"${item.title}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.service.permanentlyDelete(item.id);
              widget.onDelete?.call(item.id);
              await _loadItems();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空回收站'),
        content: const Text('确定要清空所有回收站内容吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.service.clearAll();
              await _loadItems();
            },
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Text(
                    '回收站',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  const Spacer(),
                  if (_items.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('清空'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 内容区
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
            ),

            // 提示
            Container(
              padding: const EdgeInsets.all(12),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    '回收站内容将在30天后自动清理',
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '回收站为空',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          leading: Icon(
            item.type == 'note' ? Icons.note : Icons.auto_stories,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '剩余 ${item.remainingDays} 天',
            style: TextStyle(
              fontSize: 12,
              color: item.remainingDays <= 7 ? Colors.red : null,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: '恢复',
                onPressed: () => _restore(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: '永久删除',
                onPressed: () => _delete(item),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 显示回收站对话框的便捷函数
Future<void> showRecycleBinDialog(
  BuildContext context, {
  required RecycleBinService service,
  Function(String id, String type)? onRestore,
  Function(String id)? onDelete,
}) async {
  await showDialog(
    context: context,
    builder: (context) => RecycleBinDialog(
      service: service,
      onRestore: onRestore,
      onDelete: onDelete,
    ),
  );
}

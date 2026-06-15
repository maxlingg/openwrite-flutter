import 'package:flutter/material.dart';
import '../services/memo_service.dart';

/// 便签对话框
class MemoDialog extends StatefulWidget {
  final Memo? memo;
  final Function(Memo)? onSave;
  final Function(String)? onDelete;

  const MemoDialog({
    super.key,
    this.memo,
    this.onSave,
    this.onDelete,
  });

  @override
  State<MemoDialog> createState() => _MemoDialogState();
}

class _MemoDialogState extends State<MemoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo?.title ?? '');
    _contentController = TextEditingController(text: widget.memo?.content ?? '');
    _isEditing = widget.memo == null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    final memo = Memo(
      id: widget.memo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.memo?.createdAt,
      isPinned: widget.memo?.isPinned ?? false,
    );
    
    widget.onSave?.call(memo);
    Navigator.pop(context);
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除便签'),
        content: const Text('确定要删除这条便签吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call(widget.memo!.id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
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
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.note_alt_outlined, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    widget.memo == null ? '新建便签' : '编辑便签',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  if (widget.memo != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _delete,
                      color: Colors.red,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 内容区
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '标题',
                        hintText: '便签标题...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() => _isEditing = true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: '内容',
                        hintText: '便签内容...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      minLines: 5,
                      onChanged: (_) => setState(() => _isEditing = true),
                    ),
                  ],
                ),
              ),
            ),

            // 按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('保存'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示便签对话框的便捷函数
Future<void> showMemoDialog(
  BuildContext context, {
  Memo? memo,
  Function(Memo)? onSave,
  Function(String)? onDelete,
}) async {
  await showDialog(
    context: context,
    builder: (context) => MemoDialog(
      memo: memo,
      onSave: onSave,
      onDelete: onDelete,
    ),
  );
}

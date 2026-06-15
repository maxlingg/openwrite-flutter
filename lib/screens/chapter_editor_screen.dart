import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../services/novel_service.dart';

/// 章节编辑器页面
class ChapterEditorScreen extends StatefulWidget {
  final String novelId;
  final String chapterId;
  final String chapterTitle;

  const ChapterEditorScreen({
    super.key,
    required this.novelId,
    required this.chapterId,
    required this.chapterTitle,
  });

  @override
  State<ChapterEditorScreen> createState() => _ChapterEditorScreenState();
}

class _ChapterEditorScreenState extends State<ChapterEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contentFocusNode = FocusNode();
  int _wordCount = 0;
  bool _hasChanges = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.chapterTitle;
    _loadChapter();
    
    _contentController.addListener(_updateWordCount);
    _contentController.addListener(() {
      if (!_hasChanges) setState(() => _hasChanges = true);
    });
  }

  Future<void> _loadChapter() async {
    final service = NovelService();
    final chapter = await service.getChapterById(widget.chapterId);
    if (chapter != null && mounted) {
      setState(() {
        _contentController.text = chapter.content;
        _wordCount = chapter.content.length;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    setState(() => _wordCount = _contentController.text.length);
  }

  Future<void> _saveChapter() async {
    final service = NovelService();
    final chapter = await service.getChapterById(widget.chapterId);
    if (chapter == null) return;

    final updated = chapter.copyWith(
      title: _titleController.text.trim().isEmpty ? '无标题' : _titleController.text.trim(),
      content: _contentController.text,
      wordCount: _contentController.text.length,
      updatedAt: DateTime.now(),
    );

    await service.updateChapter(updated);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存'), duration: Duration(seconds: 1)),
      );
      setState(() => _hasChanges = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapterTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        await _saveChapter();
        if (mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('章节编辑'),
          actions: [
            if (_hasChanges)
              TextButton.icon(
                onPressed: _saveChapter,
                icon: const Icon(Icons.save_outlined),
                label: const Text('保存'),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '章节标题',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: colorScheme.outline),
                      ),
                    ),
                    const Divider(),
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      maxLines: null,
                      minLines: 20,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                      ),
                      decoration: InputDecoration(
                        hintText: '开始写作...\n\n提示：\n• 每段开头空两格\n• 使用「」作为对话标记\n• 章节结尾可添加本章总结',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: colorScheme.outline.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_wordCount 字',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildQuickFormat(Icons.format_bold, '**', '**'),
                  _buildQuickFormat(Icons.format_italic, '「', '」'),
                  _buildQuickFormat(Icons.format_quote, '——', ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFormat(IconData icon, String prefix, String suffix) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: () => _insertFormat(prefix, suffix),
      tooltip: '快速格式',
    );
  }

  void _insertFormat(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    
    if (selection.isValid && selection.start != selection.end) {
      final selected = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$selected$suffix');
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: selection.end + prefix.length + suffix.length,
      );
    } else {
      final cursorPos = selection.baseOffset;
      final newText = text.substring(0, cursorPos) + prefix + suffix + text.substring(cursorPos);
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: cursorPos + prefix.length,
      );
    }
  }
}

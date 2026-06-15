import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';
import '../widgets/category_picker.dart';

class EditorScreen extends StatefulWidget {
  final Note? note;
  const EditorScreen({super.key, this.note});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  
  String _category = 'writing';
  String _categoryName = '写作';
  int _wordCount = 0;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    if (widget.note != null) {
      _category = widget.note!.category;
      _categoryName = widget.note!.categoryName;
      _wordCount = widget.note!.wordCount;
    }

    _contentController.addListener(_updateWordCount);
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    setState(() => _wordCount = _contentController.text.length);
  }

  void _onTextChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text;

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? '无标题' : title,
      content: content,
      excerpt: _generateExcerpt(content),
      category: _category,
      categoryName: _categoryName,
      tags: widget.note?.tags ?? [],
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      wordCount: content.length,
    );

    await context.read<NotesProvider>().updateNote(note);
    if (mounted) Navigator.pop(context, note);
  }

  String _generateExcerpt(String content) {
    if (content.isEmpty) return '';
    final clean = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.length > 100 ? '${clean.substring(0, 100)}...' : clean;
  }

  Future<void> _selectCategory() async {
    final selected = await CategoryPicker.show(context, _category);
    if (selected != null) {
      setState(() {
        _category = selected;
        _categoryName = Category.getById(selected).name;
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(_category);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('未保存的更改'),
            content: const Text('确定要离开吗？未保存的更改将丢失。'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('离开')),
            ],
          ),
        );
        if (shouldPop == true && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (_hasChanges) _saveNote();
              else Navigator.pop(context);
            },
          ),
          title: const Text('编辑'),
          actions: [
            TextButton.icon(
              onPressed: _selectCategory,
              icon: Text(categoryColor['emoji']!, style: const TextStyle(fontSize: 16)),
              label: Text(_categoryName, style: const TextStyle(fontSize: 14)),
            ),
            IconButton(
              onPressed: _saveNote,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '标题',
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _contentFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      maxLines: null,
                      minLines: 15,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: '开始写作...',
                        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: colorScheme.outlineVariant))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                    child: Text('$_wordCount 字', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getCategoryColor(String category) {
    const colors = {
      'writing': {'emoji': '✍️', 'bg': '0xFFE8DEF8', 'text': '0xFF6750A4'},
      'work': {'emoji': '💼', 'bg': '0xFFE3F2FD', 'text': '0xFF1976D2'},
      'life': {'emoji': '🌿', 'bg': '0xFFE8F5E9', 'text': '0xFF388E3C'},
      'study': {'emoji': '📚', 'bg': '0xFFFFF3E0', 'text': '0xFFF57C00'},
      'idea': {'emoji': '💡', 'bg': '0xFFFFFDE7', 'text': '0xFFFBC02D'},
      'diary': {'emoji': '📔', 'bg': '0xFFFCE4EC', 'text': '0xFFE91E63'},
    };
    return colors[category] ?? colors['writing']!;
  }
}

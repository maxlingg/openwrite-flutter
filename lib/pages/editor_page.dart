import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../theme/app_theme.dart';
import '../widgets/format_toolbar.dart';
import '../widgets/category_picker.dart';

/// 编辑器页面
class EditorPage extends StatefulWidget {
  final Note? note;

  const EditorPage({super.key, this.note});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final NoteService _noteService = NoteService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  
  String _category = 'writing';
  String _categoryName = '写作';
  int _wordCount = 0;
  bool _isEditing = false;
  Set<FormatAction> _activeFormats = {};

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note != null;
    
    if (_isEditing) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _category = widget.note!.category;
      _categoryName = widget.note!.categoryName;
      _wordCount = widget.note!.wordCount;
    }
    
    _contentController.addListener(_updateWordCount);
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
    final count = _contentController.text.length;
    if (count != _wordCount) {
      setState(() => _wordCount = count);
    }
  }

  Future<void> _onSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }
    
    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: title.isEmpty ? '无标题笔记' : title,
      content: content,
      excerpt: content.isEmpty ? '' : content.substring(0, content.length.clamp(0, 100)),
      category: _category,
      categoryName: _categoryName,
      tags: [],
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      wordCount: _wordCount,
    );
    
    if (_isEditing) {
      await _noteService.updateNote(note);
    } else {
      await _noteService.createNote(note);
    }
    
    if (mounted) {
      Navigator.pop(context, note);
    }
  }

  void _onFormat(FormatAction action) {
    setState(() {
      if (_activeFormats.contains(action)) {
        _activeFormats.remove(action);
      } else {
        _activeFormats.add(action);
      }
    });
  }

  Future<void> _onSelectCategory() async {
    final selected = await CategoryPicker.show(context, _category);
    if (selected != null) {
      final category = Category.getById(selected);
      setState(() {
        _category = selected;
        _categoryName = category.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final categoryColor = AppTheme.categoryColors[_category]!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 头部
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppTheme.darkOutlineVariant : AppTheme.lightOutlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 返回按钮
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // 标题输入
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      style: Theme.of(context).textTheme.titleLarge,
                      decoration: InputDecoration(
                        hintText: '无标题笔记',
                        hintStyle: TextStyle(
                          color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) {
                        _contentFocusNode.requestFocus();
                      },
                    ),
                  ),
                  
                  // 分类按钮
                  GestureDetector(
                    onTap: _onSelectCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.background,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(categoryColor.emoji, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            _categoryName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: categoryColor.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // 保存按钮
                  IconButton(
                    onPressed: _onSave,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 内容区
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: null,
                  minLines: 15,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: '开始写作...',
                    hintStyle: TextStyle(
                      color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            
            // 字数显示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: _wordCount > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        '$_wordCount 字',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 格式工具栏
            FormatToolbar(
              onFormat: _onFormat,
              activeFormats: _activeFormats,
            ),
          ],
        ),
      ),
    );
  }
}

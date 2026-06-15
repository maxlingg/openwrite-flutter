import 'package:uuid/uuid.dart';

/// 笔记数据模型
class Note {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String category;
  final String categoryName;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int wordCount;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.category,
    required this.categoryName,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.wordCount,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? excerpt,
    String? category,
    String? categoryName,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? wordCount,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wordCount: wordCount ?? this.wordCount,
    );
  }
}

/// 笔记服务 - 简化版本
class NoteService {
  final _uuid = const Uuid();
  final List<Note> _notes = [];

  String generateId() => _uuid.v4();

  Future<List<Note>> getAllNotes() async {
    return List.from(_notes);
  }

  Future<void> createNote(Note note) async {
    _notes.add(note);
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  Future<Note?> getNoteById(String id) async {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}

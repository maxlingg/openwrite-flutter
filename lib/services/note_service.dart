import 'package:uuid/uuid.dart';
import '../models/note.dart';

/// 分类数据模型
class Category {
  final String id;
  final String name;
  final String emoji;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
  });

  static const List<Category> all = [
    Category(id: 'writing', name: '写作', emoji: '✍️'),
    Category(id: 'work', name: '工作', emoji: '💼'),
    Category(id: 'life', name: '生活', emoji: '🌿'),
    Category(id: 'study', name: '学习', emoji: '📚'),
    Category(id: 'idea', name: '灵感', emoji: '💡'),
    Category(id: 'diary', name: '日记', emoji: '📔'),
  ];

  static Category getById(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.first,
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

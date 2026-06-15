import 'package:uuid/uuid.dart';
import '../models/note.dart';

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

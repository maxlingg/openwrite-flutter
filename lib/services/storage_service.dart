import 'dart:convert';
import '../models/note.dart';

/// 本地存储服务
class StorageService {
  final List<Note> _notes = [];

  /// 获取所有笔记
  Future<List<Note>> getAllNotes() async {
    return List.from(_notes);
  }

  /// 插入笔记
  Future<void> insertNote(Note note) async {
    _notes.add(note);
  }

  /// 更新笔记
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
  }

  /// 删除笔记
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  /// 获取笔记数量
  Future<int> getNotesCount() async {
    return _notes.length;
  }

  /// 获取总字数
  Future<int> getTotalWordCount() async {
    return _notes.fold(0, (sum, note) => sum + note.wordCount);
  }

  /// 导出为 JSON
  Future<String> exportToJson() async {
    final data = _notes.map((n) => n.toJson()).toList();
    return jsonEncode(data);
  }

  /// 从 JSON 导入
  Future<int> importFromJson(String json) async {
    try {
      final list = jsonDecode(json) as List;
      int count = 0;
      for (final item in list) {
        final note = Note.fromJson(item as Map<String, dynamic>);
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[index] = note;
        } else {
          _notes.add(note);
        }
        count++;
      }
      return count;
    } catch (_) {
      return 0;
    }
  }
}

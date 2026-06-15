import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/note.dart';

/// 回收站项目
class RecycleBinItem {
  final String id;
  final String type;
  final String title;
  final String content;
  final DateTime deletedAt;
  final Map<String, dynamic> metadata;
  final Note? note;

  RecycleBinItem({
    required this.id,
    required this.type,
    required this.title,
    this.content = '',
    DateTime? deletedAt,
    this.metadata = const {},
    this.note,
  }) : deletedAt = deletedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'content': content,
    'deletedAt': deletedAt.toIso8601String(),
    'metadata': metadata,
  };

  factory RecycleBinItem.fromJson(Map<String, dynamic> json) => RecycleBinItem(
    id: json['id'] as String,
    type: json['type'] as String,
    title: json['title'] as String,
    content: json['content'] as String? ?? '',
    deletedAt: DateTime.parse(json['deletedAt'] as String),
    metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
  );

  bool get isExpired {
    final daysSinceDeleted = DateTime.now().difference(deletedAt).inDays;
    return daysSinceDeleted > 30;
  }

  int get remainingDays => 30 - DateTime.now().difference(deletedAt).inDays;
}

/// 回收站服务
class RecycleBinService {
  static const _fileName = 'recycle_bin.json';
  
  final dynamic _dataPath;
  List<RecycleBinItem> _items = [];

  RecycleBinService(this._dataPath);

  /// 获取已删除的笔记
  Future<List<RecycleBinItem>> getDeletedNotes() async {
    return _items.where((i) => i.type == 'note').toList();
  }

  /// 恢复笔记
  Future<void> restoreNote(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _saveItems();
  }

  /// 永久删除
  Future<void> permanentlyDelete(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _saveItems();
  }

  /// 清空回收站
  Future<void> emptyRecycleBin() async {
    _items.clear();
    await _saveItems();
  }

  Future<void> _saveItems() async {
    // 简化版本，不做实际文件操作
  }
}

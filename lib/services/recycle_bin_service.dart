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

  /// 加载回收站项目
  Future<List<RecycleBinItem>> loadItems() async {
    try {
      final file = File(path.join(_dataPath.toString(), _fileName));
      if (await file.exists()) {
        final content = await file.readAsString();
        final list = jsonDecode(content) as List;
        _items = list.map((e) => RecycleBinItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      _items = [];
    }
    return _items;
  }

  /// 获取已删除的笔记
  Future<List<RecycleBinItem>> getDeletedNotes() async {
    return _items.where((i) => i.type == 'note').toList();
  }

  /// 添加到回收站
  Future<void> addItem({
    required String id,
    required String type,
    required String title,
    String content = '',
    Map<String, dynamic> metadata = const {},
  }) async {
    final item = RecycleBinItem(
      id: id,
      type: type,
      title: title,
      content: content,
      metadata: metadata,
    );
    _items.insert(0, item);
  }

  /// 恢复项目
  Future<void> restoreItem(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  /// 恢复笔记（兼容方法）
  Future<void> restoreNote(String id) async {
    await restoreItem(id);
  }

  /// 永久删除
  Future<void> permanentlyDelete(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  /// 清空回收站
  Future<void> clearAll() async {
    _items.clear();
  }

  /// 清空回收站（兼容方法）
  Future<void> emptyRecycleBin() async {
    await clearAll();
  }

  /// 清理过期项目
  Future<void> cleanExpired() async {
    _items.removeWhere((i) => i.isExpired);
  }

  /// 获取所有项目
  List<RecycleBinItem> getItems() => List.unmodifiable(_items);

  /// 获取统计
  Map<String, int> getStats() {
    return {
      'total': _items.length,
      'notes': _items.where((i) => i.type == 'note').length,
      'novels': _items.where((i) => i.type == 'novel').length,
    };
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// 回收站项目
class RecycleBinItem {
  final String id;
  final String type; // 'note' or 'novel'
  final String title;
  final String content;
  final DateTime deletedAt;
  final Map<String, dynamic> metadata;

  RecycleBinItem({
    required this.id,
    required this.type,
    required this.title,
    this.content = '',
    DateTime? deletedAt,
    this.metadata = const {},
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

  /// 是否已过期（30天）
  bool get isExpired {
    final daysSinceDeleted = DateTime.now().difference(deletedAt).inDays;
    return daysSinceDeleted > 30;
  }

  /// 剩余天数
  int get remainingDays => 30 - DateTime.now().difference(deletedAt).inDays;
}

/// 回收站服务
class RecycleBinService {
  static const _fileName = 'recycle_bin.json';
  static const _retentionDays = 30;
  
  final String _dataPath;
  List<RecycleBinItem> _items = [];

  RecycleBinService(this._dataPath);

  /// 加载回收站
  Future<List<RecycleBinItem>> loadItems() async {
    try {
      final file = File(path.join(_dataPath, _fileName));
      if (await file.exists()) {
        final content = await file.readAsString();
        final list = jsonDecode(content) as List;
        _items = list.map((e) => RecycleBinItem.fromJson(e as Map<String, dynamic>)).toList();
        
        // 自动清理过期项
        await _cleanExpired();
      }
    } catch (_) {
      _items = [];
    }
    return _items;
  }

  /// 保存回收站
  Future<void> saveItems() async {
    final file = File(path.join(_dataPath, _fileName));
    await file.writeAsString(jsonEncode(_items.map((i) => i.toJson()).toList()));
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
    await saveItems();
  }

  /// 恢复项目
  Future<Map<String, dynamic>?> restoreItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = _items.removeAt(index);
      await saveItems();
      return {
        'type': item.type,
        'metadata': item.metadata,
      };
    }
    return null;
  }

  /// 永久删除
  Future<void> permanentlyDelete(String id) async {
    _items.removeWhere((i) => i.id == id);
    await saveItems();
  }

  /// 清空回收站
  Future<void> clearAll() async {
    _items.clear();
    await saveItems();
  }

  /// 清理过期项
  Future<void> _cleanExpired() async {
    final expired = _items.where((i) => i.isExpired).toList();
    for (final item in expired) {
      _items.removeWhere((i) => i.id == item.id);
    }
    if (expired.isNotEmpty) {
      await saveItems();
    }
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

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// 便签数据
class Memo {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  Memo({
    required this.id,
    required this.title,
    this.content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isPinned': isPinned,
  };

  factory Memo.fromJson(Map<String, dynamic> json) => Memo(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    isPinned: json['isPinned'] as bool? ?? false,
  );

  Memo copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
  }) => Memo(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isPinned: isPinned ?? this.isPinned,
  );
}

/// 便签服务
class MemoService {
  static const _fileName = 'memos.json';
  final String _dataPath;
  List<Memo> _memos = [];

  MemoService(this._dataPath);

  /// 加载便签
  Future<List<Memo>> loadMemos() async {
    try {
      final file = File(path.join(_dataPath, _fileName));
      if (await file.exists()) {
        final content = await file.readAsString();
        final list = jsonDecode(content) as List;
        _memos = list.map((e) => Memo.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      _memos = [];
    }
    return _memos;
  }

  /// 保存便签
  Future<void> saveMemos() async {
    final file = File(path.join(_dataPath, _fileName));
    await file.writeAsString(jsonEncode(_memos.map((m) => m.toJson()).toList()));
  }

  /// 添加便签
  Future<Memo> addMemo({required String title, String content = ''}) async {
    final memo = Memo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
    );
    _memos.insert(0, memo);
    await saveMemos();
    return memo;
  }

  /// 更新便签
  Future<void> updateMemo(Memo memo) async {
    final index = _memos.indexWhere((m) => m.id == memo.id);
    if (index != -1) {
      _memos[index] = memo.copyWith(updatedAt: DateTime.now());
      await saveMemos();
    }
  }

  /// 删除便签
  Future<void> deleteMemo(String id) async {
    _memos.removeWhere((m) => m.id == id);
    await saveMemos();
  }

  /// 置顶/取消置顶
  Future<void> togglePin(String id) async {
    final index = _memos.indexWhere((m) => m.id == id);
    if (index != -1) {
      _memos[index] = _memos[index].copyWith(isPinned: !_memos[index].isPinned);
      await saveMemos();
    }
  }

  /// 获取所有便签
  List<Memo> getMemos() => List.unmodifiable(_memos);

  /// 搜索便签
  List<Memo> searchMemos(String query) {
    if (query.isEmpty) return _memos;
    final lower = query.toLowerCase();
    return _memos.where((m) =>
      m.title.toLowerCase().contains(lower) ||
      m.content.toLowerCase().contains(lower)
    ).toList();
  }
}

import 'dart:convert';
import '../models/note.dart';

/// 书签类型
enum BookmarkType { note, chapter }

/// 书签项
class Bookmark {
  final String id;
  final String itemId;      // 笔记或章节 ID
  final BookmarkType type;
  final String title;
  final String? description;
  final String? noteId;     // 所属笔记本 ID（用于章节）
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.itemId,
    required this.type,
    required this.title,
    this.description,
    this.noteId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'type': type.name,
    'title': title,
    'description': description,
    'noteId': noteId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'] as String,
    itemId: json['itemId'] as String,
    type: BookmarkType.values.firstWhere((e) => e.name == json['type']),
    title: json['title'] as String,
    description: json['description'] as String?,
    noteId: json['noteId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// 收藏/书签服务
class BookmarkService {
  static const String _bookmarksFile = 'bookmarks.json';
  final StorageService _storage;

  BookmarkService(this._storage);

  /// 获取所有书签
  Future<List<Bookmark>> getBookmarks() async {
    try {
      final content = await _storage.readString(_bookmarksFile);
      if (content == null || content.isEmpty) return [];
      
      final List<dynamic> jsonList = json.decode(content);
      return jsonList.map((e) => Bookmark.fromJson(e)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  /// 获取笔记类型书签
  Future<List<Bookmark>> getNoteBookmarks() async {
    final bookmarks = await getBookmarks();
    return bookmarks.where((b) => b.type == BookmarkType.note).toList();
  }

  /// 获取章节类型书签
  Future<List<Bookmark>> getChapterBookmarks() async {
    final bookmarks = await getBookmarks();
    return bookmarks.where((b) => b.type == BookmarkType.chapter).toList();
  }

  /// 添加书签
  Future<void> addBookmark(Bookmark bookmark) async {
    final bookmarks = await getBookmarks();
    
    // 检查是否已存在
    final exists = bookmarks.any((b) => b.itemId == bookmark.itemId && b.type == bookmark.type);
    if (exists) return;
    
    bookmarks.add(bookmark);
    await _saveBookmarks(bookmarks);
  }

  /// 添加笔记书签
  Future<void> addNoteBookmark(Note note) async {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: note.id,
      type: BookmarkType.note,
      title: note.title,
      description: note.content.length > 100 
          ? '${note.content.substring(0, 100)}...' 
          : note.content,
      createdAt: DateTime.now(),
    );
    await addBookmark(bookmark);
  }

  /// 添加章节书签
  Future<void> addChapterBookmark({
    required String chapterId,
    required String chapterTitle,
    required String novelId,
    String? description,
  }) async {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: chapterId,
      type: BookmarkType.chapter,
      title: chapterTitle,
      description: description,
      noteId: novelId,
      createdAt: DateTime.now(),
    );
    await addBookmark(bookmark);
  }

  /// 删除书签
  Future<void> removeBookmark(String itemId, BookmarkType type) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.itemId == itemId && b.type == type);
    await _saveBookmarks(bookmarks);
  }

  /// 检查是否已书签
  Future<bool> isBookmarked(String itemId, BookmarkType type) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b.itemId == itemId && b.type == type);
  }

  /// 清除所有书签
  Future<void> clearAll() async {
    await _saveBookmarks([]);
  }

  Future<void> _saveBookmarks(List<Bookmark> bookmarks) async {
    final jsonList = bookmarks.map((b) => b.toJson()).toList();
    await _storage.writeString(_bookmarksFile, json.encode(jsonList));
  }
}

// 简化的存储服务接口
class StorageService {
  Future<String?> readString(String path) async {
    try {
      final file = await _getFile(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> writeString(String path, String content) async {
    final file = await _getFile(path);
    await file.writeAsString(content);
  }

  Future<dynamic> _getFile(String path) async {
    // 实际项目中应该使用 path_provider
    return _FileWrapper(path);
  }
}

class _FileWrapper {
  final String path;
  _FileWrapper(this.path);
  
  Future<bool> exists() async => false;
  Future<String> readAsString() async => '';
  Future<void> writeAsString(String content) async {}
}

import 'package:flutter/material.dart';
import '../models/novel.dart';
import '../services/novel_service.dart';

/// 小说状态管理
class NovelProvider extends ChangeNotifier {
  final NovelService _novelService = NovelService();
  
  List<Novel> _novels = [];
  Novel? _currentNovel;
  bool _isLoading = false;
  String? _error;

  List<Novel> get novels => _novels;
  Novel? get currentNovel => _currentNovel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载所有小说
  Future<void> loadNovels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _novels = await _novelService.getAllNovels();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载小说详情
  Future<void> loadNovel(String id) async {
    try {
      _currentNovel = await _novelService.getNovelById(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 创建小说
  Future<Novel> createNovel({
    required String title,
    String description = '',
    String genre = 'other',
  }) async {
    final novel = Novel.create(
      title: title,
      description: description,
      genre: genre,
    );
    await _novelService.insertNovel(novel);
    _novels.insert(0, novel);
    notifyListeners();
    return novel;
  }

  /// 更新小说
  Future<void> updateNovel(Novel novel) async {
    final updated = novel.copyWith(updatedAt: DateTime.now());
    await _novelService.updateNovel(updated);
    
    final index = _novels.indexWhere((n) => n.id == novel.id);
    if (index != -1) {
      _novels[index] = updated;
    }
    if (_currentNovel?.id == novel.id) {
      _currentNovel = updated;
    }
    notifyListeners();
  }

  /// 删除小说
  Future<void> deleteNovel(String id) async {
    await _novelService.deleteNovel(id);
    _novels.removeWhere((n) => n.id == id);
    if (_currentNovel?.id == id) {
      _currentNovel = null;
    }
    notifyListeners();
  }

  /// 创建章节
  Future<Chapter> createChapter({
    required String novelId,
    required String title,
  }) async {
    final chapters = await _novelService.getChapters(novelId);
    final chapter = Chapter.create(
      novelId: novelId,
      title: title,
      order: chapters.length,
    );
    await _novelService.insertChapter(chapter);
    await loadNovel(novelId);
    return chapter;
  }

  /// 更新章节
  Future<void> updateChapter(Chapter chapter) async {
    final updated = chapter.copyWith(
      wordCount: chapter.content.length,
      updatedAt: DateTime.now(),
    );
    await _novelService.updateChapter(updated);
    if (_currentNovel?.id == chapter.novelId) {
      await loadNovel(chapter.novelId);
    }
  }

  /// 删除章节
  Future<void> deleteChapter(String id, String novelId) async {
    await _novelService.deleteChapter(id, novelId);
    await loadNovel(novelId);
  }

  /// 添加角色
  Future<Character> addCharacter({
    required String novelId,
    required String name,
    String role = 'supporting',
  }) async {
    final character = Character.create(
      novelId: novelId,
      name: name,
      role: role,
    );
    await _novelService.insertCharacter(character);
    await loadNovel(novelId);
    return character;
  }

  /// 更新角色
  Future<void> updateCharacter(Character character) async {
    await _novelService.updateCharacter(character);
    await loadNovel(character.novelId);
  }

  /// 删除角色
  Future<void> deleteCharacter(String id, String novelId) async {
    await _novelService.deleteCharacter(id);
    await loadNovel(novelId);
  }

  /// 更新世界观设定
  Future<void> updateWorldSetting(String novelId, WorldSetting worldSetting) async {
    if (_currentNovel == null) return;
    final updated = _currentNovel!.copyWith(worldSetting: worldSetting);
    await updateNovel(updated);
  }

  /// 获取统计信息
  Map<String, int> getStatistics() {
    final totalNovels = _novels.length;
    final totalWords = _novels.fold(0, (sum, n) => sum + n.totalWordCount);
    final totalChapters = _novels.fold(0, (sum, n) => sum + n.chapterCount);
    return {
      'novels': totalNovels,
      'words': totalWords,
      'chapters': totalChapters,
    };
  }
}

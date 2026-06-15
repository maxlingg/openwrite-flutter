import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/novel.dart';

/// 小说存储服务
class NovelService {
  static Database? _database;
  static const String _novelsTable = 'novels';
  static const String _chaptersTable = 'chapters';
  static const String _charactersTable = 'characters';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'novels.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_novelsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        genre TEXT,
        coverImage TEXT,
        worldSetting TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        wordCount INTEGER DEFAULT 0,
        isPublished INTEGER DEFAULT 0,
        status TEXT DEFAULT 'writing'
      )
    ''');

    await db.execute('''
      CREATE TABLE $_chaptersTable (
        id TEXT PRIMARY KEY,
        novelId TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        chapterOrder INTEGER NOT NULL,
        wordCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        summary TEXT,
        isPublished INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $_charactersTable (
        id TEXT PRIMARY KEY,
        novelId TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT,
        description TEXT,
        appearance TEXT,
        personality TEXT,
        backstory TEXT,
        motivation TEXT,
        avatar TEXT,
        customFields TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_novelId ON $_chaptersTable(novelId)');
    await db.execute('CREATE INDEX idx_chapterOrder ON $_chaptersTable(chapterOrder)');
    await db.execute('CREATE INDEX idx_charNovelId ON $_charactersTable(novelId)');
  }

  // 小说操作
  Future<List<Novel>> getAllNovels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _novelsTable,
      orderBy: 'updatedAt DESC',
    );
    
    List<Novel> novels = [];
    for (final map in maps) {
      final novel = await _novelFromMap(map);
      novels.add(novel);
    }
    return novels;
  }

  Future<Novel?> getNovelById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _novelsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return await _novelFromMap(maps.first);
  }

  Future<void> insertNovel(Novel novel) async {
    final db = await database;
    await db.insert(
      _novelsTable,
      _novelToMap(novel),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNovel(Novel novel) async {
    final db = await database;
    await db.update(
      _novelsTable,
      _novelToMap(novel),
      where: 'id = ?',
      whereArgs: [novel.id],
    );
  }

  Future<void> deleteNovel(String id) async {
    final db = await database;
    // 删除关联的章节和角色
    await db.delete(_chaptersTable, where: 'novelId = ?', whereArgs: [id]);
    await db.delete(_charactersTable, where: 'novelId = ?', whereArgs: [id]);
    await db.delete(_novelsTable, where: 'id = ?', whereArgs: [id]);
  }

  // 章节操作
  Future<List<Chapter>> getChapters(String novelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _chaptersTable,
      where: 'novelId = ?',
      whereArgs: [novelId],
      orderBy: 'chapterOrder ASC',
    );
    return maps.map((map) => _chapterFromMap(map)).toList();
  }

  Future<Chapter?> getChapterById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _chaptersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _chapterFromMap(maps.first);
  }

  Future<void> insertChapter(Chapter chapter) async {
    final db = await database;
    await db.insert(
      _chaptersTable,
      _chapterToMap(chapter),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _updateNovelWordCount(chapter.novelId);
  }

  Future<void> updateChapter(Chapter chapter) async {
    final db = await database;
    await db.update(
      _chaptersTable,
      _chapterToMap(chapter),
      where: 'id = ?',
      whereArgs: [chapter.id],
    );
    await _updateNovelWordCount(chapter.novelId);
  }

  Future<void> deleteChapter(String id, String novelId) async {
    final db = await database;
    await db.delete(_chaptersTable, where: 'id = ?', whereArgs: [id]);
    await _updateNovelWordCount(novelId);
  }

  Future<void> reorderChapters(String novelId, List<String> chapterIds) async {
    final db = await database;
    for (int i = 0; i < chapterIds.length; i++) {
      await db.update(
        _chaptersTable,
        {'chapterOrder': i},
        where: 'id = ?',
        whereArgs: [chapterIds[i]],
      );
    }
  }

  // 角色操作
  Future<List<Character>> getCharacters(String novelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _charactersTable,
      where: 'novelId = ?',
      whereArgs: [novelId],
    );
    return maps.map((map) => _characterFromMap(map)).toList();
  }

  Future<void> insertCharacter(Character character) async {
    final db = await database;
    await db.insert(
      _charactersTable,
      _characterToMap(character),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCharacter(Character character) async {
    final db = await database;
    await db.update(
      _charactersTable,
      _characterToMap(character),
      where: 'id = ?',
      whereArgs: [character.id],
    );
  }

  Future<void> deleteCharacter(String id) async {
    final db = await database;
    await db.delete(_charactersTable, where: 'id = ?', whereArgs: [id]);
  }

  // 统计更新
  Future<void> _updateNovelWordCount(String novelId) async {
    final chapters = await getChapters(novelId);
    final totalWordCount = chapters.fold(0, (sum, ch) => sum + ch.wordCount);
    
    final db = await database;
    await db.update(
      _novelsTable,
      {
        'wordCount': totalWordCount,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [novelId],
    );
  }

  // 导出为 JSON
  Future<String> exportNovelToJson(String novelId) async {
    final novel = await getNovelById(novelId);
    if (novel == null) throw Exception('小说不存在');
    
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'novel': novel.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // 辅助方法
  Future<Novel> _novelFromMap(Map<String, dynamic> map) async {
    final chapters = await getChapters(map['id'] as String);
    final characters = await getCharacters(map['id'] as String);
    
    return Novel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      genre: map['genre'] as String? ?? 'other',
      coverImage: map['coverImage'] as String? ?? '',
      chapters: chapters,
      characters: characters,
      worldSetting: map['worldSetting'] != null 
          ? WorldSetting.fromJson(json.decode(map['worldSetting'] as String))
          : WorldSetting(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      wordCount: map['wordCount'] as int? ?? 0,
      isPublished: (map['isPublished'] as int? ?? 0) == 1,
      status: map['status'] as String? ?? 'writing',
    );
  }

  Map<String, dynamic> _novelToMap(Novel novel) {
    return {
      'id': novel.id,
      'title': novel.title,
      'description': novel.description,
      'genre': novel.genre,
      'coverImage': novel.coverImage,
      'worldSetting': json.encode(novel.worldSetting.toJson()),
      'createdAt': novel.createdAt.toIso8601String(),
      'updatedAt': novel.updatedAt.toIso8601String(),
      'wordCount': novel.wordCount,
      'isPublished': novel.isPublished ? 1 : 0,
      'status': novel.status,
    };
  }

  Chapter _chapterFromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as String,
      novelId: map['novelId'] as String,
      title: map['title'] as String,
      content: map['content'] as String? ?? '',
      order: map['chapterOrder'] as int,
      wordCount: map['wordCount'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      summary: map['summary'] as String? ?? '',
      isPublished: (map['isPublished'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> _chapterToMap(Chapter chapter) {
    return {
      'id': chapter.id,
      'novelId': chapter.novelId,
      'title': chapter.title,
      'content': chapter.content,
      'chapterOrder': chapter.order,
      'wordCount': chapter.wordCount,
      'createdAt': chapter.createdAt.toIso8601String(),
      'updatedAt': chapter.updatedAt.toIso8601String(),
      'summary': chapter.summary,
      'isPublished': chapter.isPublished ? 1 : 0,
    };
  }

  Character _characterFromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] as String,
      novelId: map['novelId'] as String,
      name: map['name'] as String,
      role: map['role'] as String? ?? 'supporting',
      description: map['description'] as String? ?? '',
      appearance: map['appearance'] as String? ?? '',
      personality: map['personality'] as String? ?? '',
      backstory: map['backstory'] as String? ?? '',
      motivation: map['motivation'] as String? ?? '',
      avatar: map['avatar'] as String? ?? '',
      customFields: map['customFields'] != null 
          ? Map<String, String>.from(json.decode(map['customFields'] as String))
          : {},
    );
  }

  Map<String, dynamic> _characterToMap(Character character) {
    return {
      'id': character.id,
      'novelId': character.novelId,
      'name': character.name,
      'role': character.role,
      'description': character.description,
      'appearance': character.appearance,
      'personality': character.personality,
      'backstory': character.backstory,
      'motivation': character.motivation,
      'avatar': character.avatar,
      'customFields': json.encode(character.customFields),
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

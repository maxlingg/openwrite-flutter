import 'package:uuid/uuid.dart';

/// 小说数据模型
class Novel {
  final String id;
  final String title;
  final String description;
  final String genre;
  final String coverImage;
  final List<Chapter> chapters;
  final List<Character> characters;
  final WorldSetting worldSetting;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int wordCount;
  final bool isPublished;
  final String status; // writing, completed, paused

  Novel({
    required this.id,
    required this.title,
    this.description = '',
    this.genre = 'other',
    this.coverImage = '',
    this.chapters = const [],
    this.characters = const [],
    WorldSetting? worldSetting,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.wordCount = 0,
    this.isPublished = false,
    this.status = 'writing',
  }) : worldSetting = worldSetting ?? WorldSetting(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Novel.create({required String title, String description = '', String genre = 'other'}) {
    final now = DateTime.now();
    return Novel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      genre: genre,
      createdAt: now,
      updatedAt: now,
    );
  }

  Novel copyWith({
    String? id,
    String? title,
    String? description,
    String? genre,
    String? coverImage,
    List<Chapter>? chapters,
    List<Character>? characters,
    WorldSetting? worldSetting,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? wordCount,
    bool? isPublished,
    String? status,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      coverImage: coverImage ?? this.coverImage,
      chapters: chapters ?? this.chapters,
      characters: characters ?? this.characters,
      worldSetting: worldSetting ?? this.worldSetting,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wordCount: wordCount ?? this.wordCount,
      isPublished: isPublished ?? this.isPublished,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'genre': genre,
      'coverImage': coverImage,
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'characters': characters.map((c) => c.toJson()).toList(),
      'worldSetting': worldSetting.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'wordCount': wordCount,
      'isPublished': isPublished,
      'status': status,
    };
  }

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      genre: json['genre'] as String? ?? 'other',
      coverImage: json['coverImage'] as String? ?? '',
      chapters: (json['chapters'] as List<dynamic>?)?.map((c) => Chapter.fromJson(c as Map<String, dynamic>)).toList() ?? [],
      characters: (json['characters'] as List<dynamic>?)?.map((c) => Character.fromJson(c as Map<String, dynamic>)).toList() ?? [],
      worldSetting: json['worldSetting'] != null ? WorldSetting.fromJson(json['worldSetting'] as Map<String, dynamic>) : WorldSetting(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      wordCount: json['wordCount'] as int? ?? 0,
      isPublished: json['isPublished'] as bool? ?? false,
      status: json['status'] as String? ?? 'writing',
    );
  }

  int get totalWordCount => chapters.fold(0, (sum, ch) => sum + ch.wordCount);
  int get chapterCount => chapters.length;
}

/// 章节数据模型
class Chapter {
  final String id;
  final String novelId;
  final String title;
  final String content;
  final int order;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String summary;
  final bool isPublished;

  Chapter({
    required this.id,
    required this.novelId,
    required this.title,
    this.content = '',
    required this.order,
    this.wordCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.summary = '',
    this.isPublished = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Chapter.create({
    required String novelId,
    required String title,
    required int order,
  }) {
    final now = DateTime.now();
    return Chapter(
      id: const Uuid().v4(),
      novelId: novelId,
      title: title,
      order: order,
      createdAt: now,
      updatedAt: now,
    );
  }

  Chapter copyWith({
    String? id,
    String? novelId,
    String? title,
    String? content,
    int? order,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? summary,
    bool? isPublished,
  }) {
    return Chapter(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      title: title ?? this.title,
      content: content ?? this.content,
      order: order ?? this.order,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summary: summary ?? this.summary,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'title': title,
      'content': content,
      'order': order,
      'wordCount': wordCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'summary': summary,
      'isPublished': isPublished,
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      novelId: json['novelId'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      order: json['order'] as int,
      wordCount: json['wordCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      summary: json['summary'] as String? ?? '',
      isPublished: json['isPublished'] as bool? ?? false,
    );
  }
}

/// 人物角色数据模型
class Character {
  final String id;
  final String novelId;
  final String name;
  final String role; // protagonist, antagonist, supporting, minor
  final String description;
  final String appearance;
  final String personality;
  final String backstory;
  final String motivation;
  final String avatar;
  final Map<String, String> customFields;

  Character({
    required this.id,
    required this.novelId,
    required this.name,
    this.role = 'supporting',
    this.description = '',
    this.appearance = '',
    this.personality = '',
    this.backstory = '',
    this.motivation = '',
    this.avatar = '',
    Map<String, String>? customFields,
  }) : customFields = customFields ?? {};

  factory Character.create({
    required String novelId,
    required String name,
    String role = 'supporting',
  }) {
    return Character(
      id: const Uuid().v4(),
      novelId: novelId,
      name: name,
      role: role,
    );
  }

  Character copyWith({
    String? id,
    String? novelId,
    String? name,
    String? role,
    String? description,
    String? appearance,
    String? personality,
    String? backstory,
    String? motivation,
    String? avatar,
    Map<String, String>? customFields,
  }) {
    return Character(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      name: name ?? this.name,
      role: role ?? this.role,
      description: description ?? this.description,
      appearance: appearance ?? this.appearance,
      personality: personality ?? this.personality,
      backstory: backstory ?? this.backstory,
      motivation: motivation ?? this.motivation,
      avatar: avatar ?? this.avatar,
      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'name': name,
      'role': role,
      'description': description,
      'appearance': appearance,
      'personality': personality,
      'backstory': backstory,
      'motivation': motivation,
      'avatar': avatar,
      'customFields': customFields,
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      novelId: json['novelId'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'supporting',
      description: json['description'] as String? ?? '',
      appearance: json['appearance'] as String? ?? '',
      personality: json['personality'] as String? ?? '',
      backstory: json['backstory'] as String? ?? '',
      motivation: json['motivation'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      customFields: Map<String, String>.from(json['customFields'] as Map? ?? {}),
    );
  }
}

/// 世界观设定
class WorldSetting {
  final String name;
  final String description;
  final String timePeriod;
  final String location;
  final String culture;
  final String magicSystem;
  final String politics;
  final String economy;
  final String technology;
  final Map<String, String> customSettings;

  WorldSetting({
    this.name = '',
    this.description = '',
    this.timePeriod = '',
    this.location = '',
    this.culture = '',
    this.magicSystem = '',
    this.politics = '',
    this.economy = '',
    this.technology = '',
    Map<String, String>? customSettings,
  }) : customSettings = customSettings ?? {};

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'timePeriod': timePeriod,
      'location': location,
      'culture': culture,
      'magicSystem': magicSystem,
      'politics': politics,
      'economy': economy,
      'technology': technology,
      'customSettings': customSettings,
    };
  }

  factory WorldSetting.fromJson(Map<String, dynamic> json) {
    return WorldSetting(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timePeriod: json['timePeriod'] as String? ?? '',
      location: json['location'] as String? ?? '',
      culture: json['culture'] as String? ?? '',
      magicSystem: json['magicSystem'] as String? ?? '',
      politics: json['politics'] as String? ?? '',
      economy: json['economy'] as String? ?? '',
      technology: json['technology'] as String? ?? '',
      customSettings: Map<String, String>.from(json['customSettings'] as Map? ?? {}),
    );
  }
}

/// 小说类型枚举
class NovelGenre {
  static const String xianxia = 'xianxia';       // 仙侠
  static const String fantasy = 'fantasy';       // 奇幻
  static const String urban = 'urban';           // 都市
  static const String romance = 'romance';       // 言情
  static const String sciFi = 'sciFi';          // 科幻
  static const String horror = 'horror';         // 悬疑
  static const String history = 'history';       // 历史
  static const String game = 'game';             // 游戏
  static const String other = 'other';           // 其他

  static const Map<String, String> names = {
    xianxia: '仙侠',
    fantasy: '奇幻',
    urban: '都市',
    romance: '言情',
    sciFi: '科幻',
    horror: '悬疑',
    history: '历史',
    game: '游戏',
    other: '其他',
  };

  static String getName(String genre) => names[genre] ?? '其他';
}

/// 角色类型
class CharacterRole {
  static const String protagonist = 'protagonist';   // 主角
  static const String antagonist = 'antagonist';     // 反派
  static const String supporting = 'supporting';     // 配角
  static const String minor = 'minor';               // 龙套

  static const Map<String, String> names = {
    protagonist: '主角',
    antagonist: '反派',
    supporting: '配角',
    minor: '龙套',
  };

  static String getName(String role) => names[role] ?? '配角';
}

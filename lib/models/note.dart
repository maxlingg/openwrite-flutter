import 'package:uuid/uuid.dart';

/// 笔记数据模型
class Note {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String category;
  final String categoryName;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int wordCount;
  final bool isDeleted;
  final DateTime? deletedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.category,
    required this.categoryName,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.wordCount,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory Note.create({
    required String title,
    required String content,
    String category = 'writing',
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      excerpt: _generateExcerpt(content),
      category: category,
      categoryName: Category.getById(category).name,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      wordCount: content.length,
    );
  }

  static String _generateExcerpt(String content) {
    if (content.isEmpty) return '';
    final clean = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.length > 100 ? '${clean.substring(0, 100)}...' : clean;
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? excerpt,
    String? category,
    String? categoryName,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? wordCount,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      wordCount: wordCount ?? this.wordCount,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'category': category,
      'categoryName': categoryName,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'wordCount': wordCount,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String,
      category: json['category'] as String,
      categoryName: json['categoryName'] as String,
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      wordCount: json['wordCount'] as int,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
    );
  }
}

/// 分类数据模型
class Category {
  final String id;
  final String name;
  final String emoji;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
  });

  static const List<Category> all = [
    Category(id: 'writing', name: '写作', emoji: '✍️'),
    Category(id: 'work', name: '工作', emoji: '💼'),
    Category(id: 'life', name: '生活', emoji: '🌿'),
    Category(id: 'study', name: '学习', emoji: '📚'),
    Category(id: 'idea', name: '灵感', emoji: '💡'),
    Category(id: 'diary', name: '日记', emoji: '📔'),
  ];

  static Category getById(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.first,
    );
  }
}

/// 回收站项目
class RecycleBinItem {
  final Note note;
  final DateTime deletedAt;
  final int daysUntilPermanentDeletion;

  RecycleBinItem({
    required this.note,
    required this.deletedAt,
    this.daysUntilPermanentDeletion = 30,
  });

  bool get isExpiringSoon => DateTime.now().difference(deletedAt).inDays > (daysUntilPermanentDeletion - 7);
}

/// 技能模型
class Skill {
  final String id;
  final String name;
  final String description;
  final String version;
  final String author;
  final String icon;
  final bool isBuiltIn;
  final Map<String, dynamic> config;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    this.version = '1.0.0',
    this.author = 'Unknown',
    this.icon = '🔧',
    this.isBuiltIn = false,
    this.config = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'author': author,
      'icon': icon,
      'isBuiltIn': isBuiltIn,
      'config': config,
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String? ?? '1.0.0',
      author: json['author'] as String? ?? 'Unknown',
      icon: json['icon'] as String? ?? '🔧',
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      config: json['config'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// WebDav 配置
class WebDavConfig {
  final String serverUrl;
  final String username;
  final String password;
  final String basePath;

  WebDavConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.basePath = '/OpenWrite',
  });

  Map<String, dynamic> toJson() {
    return {
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'basePath': basePath,
    };
  }

  factory WebDavConfig.fromJson(Map<String, dynamic> json) {
    return WebDavConfig(
      serverUrl: json['serverUrl'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      basePath: json['basePath'] as String? ?? '/OpenWrite',
    );
  }

  bool get isValid => serverUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
}

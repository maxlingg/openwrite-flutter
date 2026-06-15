import 'package:flutter/material.dart';

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
  });

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

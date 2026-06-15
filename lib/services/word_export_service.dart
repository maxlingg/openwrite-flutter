import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/novel.dart';

/// Word 导出服务
class WordExportService {
  /// 导出小说为 Word 文档
  Future<List<int>> exportNovelToDocx(Novel novel) async {
    final content = StringBuffer();
    
    // 文档头
    content.writeln(_docxHeader());
    
    // 标题
    content.writeln(_createHeading(novel.title, 1));
    
    // 基本信息
    content.writeln(_createParagraph('作者：${novel.description}'));
    content.writeln(_createParagraph('类型：${NovelGenre.getName(novel.genre)}'));
    content.writeln(_createParagraph('字数：${novel.totalWordCount}'));
    content.writeln(_createParagraph('章节：${novel.chapterCount}'));
    content.writeln(_createParagraph(''));
    
    // 简介
    if (novel.description.isNotEmpty) {
      content.writeln(_createHeading('简介', 2));
      content.writeln(_createParagraph(novel.description));
      content.writeln(_createParagraph(''));
    }
    
    // 人物
    if (novel.characters.isNotEmpty) {
      content.writeln(_createHeading('人物设定', 2));
      for (final character in novel.characters) {
        content.writeln(_createHeading(character.name, 3));
        content.writeln(_createParagraph('角色：${CharacterRole.getName(character.role)}'));
        if (character.description.isNotEmpty) {
          content.writeln(_createParagraph(character.description));
        }
        if (character.personality.isNotEmpty) {
          content.writeln(_createParagraph('性格：${character.personality}'));
        }
        if (character.backstory.isNotEmpty) {
          content.writeln(_createParagraph('背景：${character.backstory}'));
        }
        content.writeln(_createParagraph(''));
      }
    }
    
    // 世界观
    if (novel.worldSetting.description.isNotEmpty || 
        novel.worldSetting.magicSystem.isNotEmpty) {
      content.writeln(_createHeading('世界观设定', 2));
      if (novel.worldSetting.description.isNotEmpty) {
        content.writeln(_createParagraph(novel.worldSetting.description));
      }
      if (novel.worldSetting.magicSystem.isNotEmpty) {
        content.writeln(_createParagraph('力量体系：${novel.worldSetting.magicSystem}'));
      }
      if (novel.worldSetting.culture.isNotEmpty) {
        content.writeln(_createParagraph('文化：${novel.worldSetting.culture}'));
      }
      content.writeln(_createParagraph(''));
    }
    
    // 章节内容
    content.writeln(_createHeading('正文', 2));
    for (final chapter in novel.chapters) {
      content.writeln(_createHeading(chapter.title, 3));
      content.writeln(_createParagraph(chapter.content));
      content.writeln(_createParagraph(''));
    }
    
    // 文档尾
    content.writeln(_docxFooter());
    
    return utf8.encode(content.toString());
  }

  /// 导出章节为纯文本
  Future<List<int>> exportChapterToText(Chapter chapter) async {
    return utf8.encode('${chapter.title}\n\n${chapter.content}');
  }

  /// 导出为 Markdown
  Future<List<int>> exportNovelToMarkdown(Novel novel) async {
    final content = StringBuffer();
    
    // 标题
    content.writeln('# ${novel.title}');
    content.writeln('');
    
    // 基本信息
    content.writeln('> 类型：${NovelGenre.getName(novel.genre)}  |  字数：${novel.totalWordCount}  |  章节：${novel.chapterCount}');
    content.writeln('');
    
    // 简介
    if (novel.description.isNotEmpty) {
      content.writeln('## 简介');
      content.writeln(novel.description);
      content.writeln('');
    }
    
    // 人物
    if (novel.characters.isNotEmpty) {
      content.writeln('## 人物设定');
      for (final character in novel.characters) {
        content.writeln('### ${character.name}');
        content.writeln('- 角色：${CharacterRole.getName(character.role)}');
        if (character.description.isNotEmpty) {
          content.writeln('- 描述：${character.description}');
        }
        if (character.personality.isNotEmpty) {
          content.writeln('- 性格：${character.personality}');
        }
        if (character.backstory.isNotEmpty) {
          content.writeln('- 背景：${character.backstory}');
        }
        content.writeln('');
      }
    }
    
    // 章节内容
    content.writeln('## 正文');
    for (final chapter in novel.chapters) {
      content.writeln('### ${chapter.title}');
      content.writeln(chapter.content);
      content.writeln('');
    }
    
    return utf8.encode(content.toString());
  }

  String _docxHeader() {
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:body>''';
  }

  String _docxFooter() {
    return '''</w:body>
</w:document>''';
  }

  String _createHeading(String text, int level) {
    final styleId = 'Heading$level';
    return '<w:p><w:pStyle w:val="$styleId"/><w:r><w:t>$text</w:t></w:r></w:p>';
  }

  String _createParagraph(String text) {
    final escaped = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
    return '<w:p><w:r><w:t>$escaped</w:t></w:r></w:p>';
  }
}

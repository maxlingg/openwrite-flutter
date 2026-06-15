import 'dart:convert';
import 'package:http/http.dart' as http;

/// 网络小说章节信息
class NovelChapter {
  final String title;
  final String url;
  final String content;

  NovelChapter({
    required this.title,
    required this.url,
    this.content = '',
  });
}

/// 网络小说信息
class NovelInfo {
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String sourceUrl;
  final List<NovelChapter> chapters;

  NovelInfo({
    required this.title,
    required this.author,
    this.description = '',
    this.coverUrl = '',
    required this.sourceUrl,
    this.chapters = const [],
  });
}

/// 网络小说爬虫服务
class NovelCrawlerService {
  static const _defaultHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
  };

  /// 从 URL 获取小说信息
  Future<NovelInfo> fetchNovel(String url) async {
    try {
      // 根据 URL 识别网站类型
      if (url.contains('qidian.com')) {
        return await _fetchQidian(url);
      } else if (url.contains('xxbiquge') || url.contains('biquge')) {
        return await _fetchBiquge(url);
      } else if (url.contains('jjwxc')) {
        return await _fetchjjwxc(url);
      } else {
        // 通用抓取
        return await _fetchGeneric(url);
      }
    } catch (e) {
      throw NovelCrawlerException('获取小说失败: $e');
    }
  }

  /// 获取章节内容
  Future<String> fetchChapterContent(String url) async {
    try {
      if (url.contains('qidian.com')) {
        return await _fetchQidianContent(url);
      } else if (url.contains('xxbiquge') || url.contains('biquge')) {
        return await _fetchBiqugeContent(url);
      } else if (url.contains('jjwxc')) {
        return await _fetchjjwxcContent(url);
      } else {
        return await _fetchGenericContent(url);
      }
    } catch (e) {
      throw NovelCrawlerException('获取章节内容失败: $e');
    }
  }

  /// 起点中文网
  Future<NovelInfo> _fetchQidian(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw NovelCrawlerException('网站请求失败: ${response.statusCode}');
    }

    final html = utf8.decode(response.bodyBytes);

    // 解析标题
    final titleMatch = RegExp(r'<h1[^>]*class="book-title"[^>]*>([^<]+)</h1>').firstMatch(html);
    final title = titleMatch?.group(1)?.trim() ?? '未知标题';

    // 解析作者
    final authorMatch = RegExp(r'<a[^>]*class="author"[^>]*>([^<]+)</a>').firstMatch(html);
    final author = authorMatch?.group(1)?.trim() ?? '未知作者';

    // 解析简介
    final descMatch = RegExp(r'<p[^>]*class="desc"[^>]*>([^<]+)</p>').firstMatch(html);
    final description = descMatch?.group(1)?.trim() ?? '';

    // 解析章节列表
    final chapters = <NovelChapter>[];
    final chapterPattern = RegExp(r'<a[^>]*href="(/[^"]+)"[^>]*>([^<]+)</a>', caseSensitive: false);
    for (final match in chapterPattern.allMatches(html)) {
      final href = match.group(1) ?? '';
      final chapterTitle = match.group(2)?.trim() ?? '';
      if (href.isNotEmpty && chapterTitle.isNotEmpty && !href.contains('/book/')) {
        chapters.add(NovelChapter(
          title: chapterTitle,
          url: href.startsWith('http') ? href : 'https://vip.qidian.com$href',
        ));
      }
    }

    return NovelInfo(
      title: title,
      author: author,
      description: description,
      sourceUrl: url,
      chapters: chapters,
    );
  }

  Future<String> _fetchQidianContent(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw NovelCrawlerException('网站请求失败');
    }

    final html = utf8.decode(response.bodyBytes);
    // 提取正文内容（简化版）
    final contentMatch = RegExp(
      r'<div[^>]*class="read-content[^"]*"[^>]*>([\s\S]*?)</div>',
      caseSensitive: false,
    ).firstMatch(html);

    return _cleanHtml(contentMatch?.group(1) ?? '无法解析内容');
  }

  /// 笔趣阁/新笔趣阁
  Future<NovelInfo> _fetchBiquge(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw NovelCrawlerException('网站请求失败');
    }

    final html = utf8.decode(response.bodyBytes, allowMalformed: true);

    // 解析标题
    final titleMatch = RegExp(r'<h1[^>]*>([^<]+)</h1>').firstMatch(html);
    final title = titleMatch?.group(1)?.trim() ?? '未知标题';

    // 解析作者
    final authorMatch = RegExp(r'作者：([^<]+)').firstMatch(html);
    final author = authorMatch?.group(1)?.trim() ?? '未知作者';

    // 解析简介
    final descMatch = RegExp(r'<div[^>]*id="intro"[^>]*>([\s\S]*?)</div>').firstMatch(html);
    final description = _cleanHtml(descMatch?.group(1) ?? '');

    // 解析章节列表
    final chapters = <NovelChapter>[];
    final listUrl = url.replaceAll(RegExp(r'/[^/]+$'), '/');
    
    final chapterPattern = RegExp(r'<a[^>]*href="([^"]+)"[^>]*>([^<]+)</a>', caseSensitive: false);
    for (final match in chapterPattern.allMatches(html)) {
      final href = match.group(1) ?? '';
      final chapterTitle = match.group(2)?.trim() ?? '';
      
      if (href.isNotEmpty && chapterTitle.isNotEmpty && 
          href.contains('.html') && !href.startsWith('http')) {
        chapters.add(NovelChapter(
          title: chapterTitle,
          url: listUrl + href,
        ));
      }
    }

    return NovelInfo(
      title: title,
      author: author,
      description: description,
      sourceUrl: url,
      chapters: chapters,
    );
  }

  Future<String> _fetchBiqugeContent(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw NovelCrawlerException('网站请求失败');
    }

    final html = utf8.decode(response.bodyBytes, allowMalformed: true);
    final contentMatch = RegExp(
      r'<div[^>]*id="content"[^>]*>([\s\S]*?)</div>',
      caseSensitive: false,
    ).firstMatch(html);

    return _cleanHtml(contentMatch?.group(1) ?? '无法解析内容');
  }

  /// 晋江文学城
  Future<NovelInfo> _fetchjjwxc(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw NovelCrawlerException('网站请求失败');
    }

    final html = utf8.decode(response.bodyBytes);

    final titleMatch = RegExp(r'<h1[^>]*itemprop="name"[^>]*>([^<]+)</h1>').firstMatch(html);
    final title = titleMatch?.group(1)?.trim() ?? '未知标题';

    final authorMatch = RegExp(r'<a[^>]*itemprop="author"[^>]*>([^<]+)</a>').firstMatch(html);
    final author = authorMatch?.group(1)?.trim() ?? '未知作者';

    final descMatch = RegExp(r'<span[^>]*itemprop="description"[^>]*>([\s\S]*?)</span>').firstMatch(html);
    final description = _cleanHtml(descMatch?.group(1) ?? '');

    return NovelInfo(
      title: title,
      author: author,
      description: description,
      sourceUrl: url,
      chapters: [],
    );
  }

  Future<String> _fetchjjwxcContent(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw NovelCrawlerException('网站请求失败');
    }

    final html = utf8.decode(response.bodyBytes);
    final contentMatch = RegExp(
      r'<div[^>]*class="readcontent[^"]*"[^>]*>([\s\S]*?)</div>',
      caseSensitive: false,
    ).firstMatch(html);

    return _cleanHtml(contentMatch?.group(1) ?? '无法解析内容');
  }

  /// 通用抓取（简化版）
  Future<NovelInfo> _fetchGeneric(String url) async {
    return NovelInfo(
      title: '小说',
      author: '未知',
      sourceUrl: url,
      chapters: [],
    );
  }

  Future<String> _fetchGenericContent(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw NovelCrawlerException('网站请求失败');
    }

    final html = utf8.decode(response.bodyBytes);
    // 尝试提取正文
    final contentMatch = RegExp(
      r'<article[^>]*>([\s\S]*?)</article>',
      caseSensitive: false,
    ).firstMatch(html);

    return _cleanHtml(contentMatch?.group(1) ?? '无法解析内容');
  }

  /// 清理 HTML 标签
  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

/// 小说爬虫异常
class NovelCrawlerException implements Exception {
  final String message;
  NovelCrawlerException(this.message);
  
  @override
  String toString() => message;
}

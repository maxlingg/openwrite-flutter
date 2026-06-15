import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Map<String, dynamic> toJson() => {
    'serverUrl': serverUrl,
    'username': username,
    'password': password,
    'basePath': basePath,
  };

  factory WebDavConfig.fromJson(Map<String, dynamic> json) {
    return WebDavConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      basePath: json['basePath'] as String? ?? '/OpenWrite',
    );
  }
}

/// WebDav 服务
class WebDavService {
  WebDavConfig? _config;

  void setConfig(WebDavConfig config) {
    _config = config;
  }

  void clearConfig() {
    _config = null;
  }

  bool get hasConfig => _config != null;

  /// 测试连接
  Future<bool> testConnection() async {
    if (_config == null) return false;
    
    try {
      final response = await _propfind(
        _getUrl(''),
        _authHeaders,
        '<?xml version="1.0"?><d:propfind xmlns:d="DAV:"><d:prop><d:resourcetype/></d:prop></d:propfind>',
        0,
      );
      return response.statusCode == 207;
    } catch (_) {
      return false;
    }
  }

  /// 上传文件
  Future<bool> uploadFile(String path, List<int> data) async {
    if (_config == null) throw Exception('未配置 WebDav');

    try {
      final response = await http.put(
        _getUrl(path),
        headers: _authHeaders,
        body: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('上传失败: $e');
    }
  }

  /// 下载文件
  Future<List<int>?> downloadFile(String path) async {
    if (_config == null) throw Exception('未配置 WebDav');

    try {
      final response = await http.get(
        _getUrl(path),
        headers: _authHeaders,
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      throw Exception('下载失败: $e');
    }
  }

  /// 删除文件
  Future<bool> deleteFile(String path) async {
    if (_config == null) throw Exception('未配置 WebDav');

    try {
      final response = await http.delete(
        _getUrl(path),
        headers: _authHeaders,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('删除失败: $e');
    }
  }

  /// 列出目录
  Future<List<WebDavItem>> listDirectory(String path) async {
    if (_config == null) throw Exception('未配置 WebDav');

    try {
      final response = await _propfind(
        _getUrl(path),
        _authHeaders,
        '<?xml version="1.0"?><d:propfind xmlns:d="DAV:"><d:prop><d:displayname/><d:getcontentlength/><d:getlastmodified/></d:prop></d:propfind>',
        1,
      );

      if (response.statusCode != 207) return [];

      return _parseDirectoryList(response.body);
    } catch (e) {
      throw Exception('列出目录失败: $e');
    }
  }

  /// 创建目录
  Future<bool> createDirectory(String path) async {
    if (_config == null) throw Exception('未配置 WebDav');

    try {
      final response = await _mkcol(_getUrl(path), _authHeaders);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('创建目录失败: $e');
    }
  }

  /// 同步上传
  Future<void> syncUpload(Map<String, dynamic> data) async {
    if (_config == null) throw Exception('未配置 WebDav');

    final jsonData = jsonEncode(data);
    await uploadFile('openwrite_backup.json', utf8.encode(jsonData));
  }

  /// 同步下载
  Future<Map<String, dynamic>?> syncDownload() async {
    if (_config == null) throw Exception('未配置 WebDav');

    final data = await downloadFile('openwrite_backup.json');
    if (data == null) return null;

    try {
      return jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Uri _getUrl(String path) {
    final base = _config!.serverUrl.endsWith('/') 
        ? _config!.serverUrl.substring(0, _config!.serverUrl.length - 1)
        : _config!.serverUrl;
    final basePath = _config!.basePath.startsWith('/')
        ? _config!.basePath
        : '/${_config!.basePath}';
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$basePath$cleanPath');
  }

  Map<String, String> get _authHeaders => {
    'Authorization': 'Basic ${base64Encode(utf8.encode('${_config!.username}:${_config!.password}'))}',
    'Content-Type': 'application/xml',
  };

  List<WebDavItem> _parseDirectoryList(String xml) {
    final items = <WebDavItem>[];
    final hrefPattern = RegExp(r'<d:href>([^<]+)</d:href>');
    final namePattern = RegExp(r'<d:displayname>([^<]+)</d:displayname>');
    final sizePattern = RegExp(r'<d:getcontentlength>([^<]+)</d:getcontentlength>');
    final isDirPattern = RegExp(r'<d:collection/>');

    final hrefs = hrefPattern.allMatches(xml).toList();
    final names = namePattern.allMatches(xml).toList();
    final sizes = sizePattern.allMatches(xml).toList();
    final isDirs = isDirPattern.allMatches(xml).toList();

    for (var i = 0; i < hrefs.length; i++) {
      items.add(WebDavItem(
        path: hrefs[i].group(1) ?? '',
        name: i < names.length ? names[i].group(1) ?? '' : '',
        size: i < sizes.length ? int.tryParse(sizes[i].group(1) ?? '') ?? 0 : 0,
        isDirectory: i < isDirs.length,
      ));
    }

    return items;
  }
}

/// WebDav 条目
class WebDavItem {
  final String path;
  final String name;
  final int size;
  final bool isDirectory;

  WebDavItem({
    required this.path,
    required this.name,
    required this.size,
    required this.isDirectory,
  });
}

/// PROPFIND 请求
Future<http.Response> _propfind(
  Uri url,
  Map<String, String> headers,
  String body,
  int maxDepth,
) async {
  final request = http.Request('PROPFIND', url);
  request.headers.addAll(headers);
  request.headers['Depth'] = maxDepth.toString();
  request.body = body;
  
  final streamed = await request.send();
  return await http.Response.fromStream(streamed);
}

/// MKCOL 请求
Future<http.Response> _mkcol(
  Uri url,
  Map<String, String> headers,
) async {
  final request = http.Request('MKCOL', url);
  request.headers.addAll(headers);
  
  final streamed = await request.send();
  return await http.Response.fromStream(streamed);
}

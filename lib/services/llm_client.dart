import 'dart:convert';
import 'package:http/http.dart' as http;

/// LLM 客户端 - 支持 OpenAI GPT、Claude 等
class LlmClient {
  final String baseUrl;
  final String apiKey;
  final String model;
  
  // 静态配置存储
  static String? _globalBaseUrl;
  static String? _globalApiKey;
  static String? _globalModel;

  LlmClient({
    required this.baseUrl,
    required this.apiKey,
    this.model = 'gpt-4o',
  });

  /// 设置全局配置
  static void setGlobalConfig({
    required String baseUrl,
    required String apiKey,
    required String model,
  }) {
    _globalBaseUrl = baseUrl;
    _globalApiKey = apiKey;
    _globalModel = model;
  }

  /// 检查全局配置是否可用
  static bool get globalConfigured =>
      _globalApiKey != null && _globalApiKey!.isNotEmpty;

  /// 获取全局配置的客户端
  static LlmClient? getGlobalClient() {
    if (!globalConfigured) return null;
    return LlmClient(
      baseUrl: _globalBaseUrl!,
      apiKey: _globalApiKey!,
      model: _globalModel ?? 'gpt-4o',
    );
  }

  /// 发送聊天请求
  Future<LlmResponse> chat({
    required List<LlmMessage> messages,
    double temperature = 0.7,
    int maxTokens = 4000,
    bool stream = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages.map((m) => m.toJson()).toList(),
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': stream,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return LlmResponse.fromJson(data);
      } else {
        throw LlmException('请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is LlmException) rethrow;
      throw LlmException('网络错误: $e');
    }
  }

  /// 流式聊天请求
  Stream<String> chatStream({
    required List<LlmMessage> messages,
    double temperature = 0.7,
    int maxTokens = 4000,
  }) async* {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages.map((m) => m.toJson()).toList(),
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': true,
        }),
      );

      if (response.statusCode == 200) {
        final lines = utf8.decode(response.bodyBytes).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null && content is String) {
                yield content;
              }
            } catch (_) {}
          }
        }
      } else {
        throw LlmException('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      if (e is LlmException) yield* Stream.error(e);
      yield* Stream.error(LlmException('网络错误: $e'));
    }
  }

  /// 测试连接
  Future<TestConnectionResult> testConnection() async {
    try {
      // 先测试 chat 接口
      final chatResponse = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': 'Say "OK"'}
          ],
          'max_tokens': 10,
        }),
      );

      if (chatResponse.statusCode == 200) {
        return TestConnectionResult(success: true, message: '连接成功');
      }

      // 解析错误信息
      String errorMsg = 'HTTP ${chatResponse.statusCode}';
      try {
        final errorBody = jsonDecode(utf8.decode(chatResponse.bodyBytes));
        errorMsg = errorBody['error']?['message'] ?? errorBody['error']?['type'] ?? errorMsg;
      } catch (_) {}

      // 根据状态码提供具体错误
      switch (chatResponse.statusCode) {
        case 401:
          return TestConnectionResult(success: false, message: 'API 密钥无效或已过期');
        case 403:
          return TestConnectionResult(success: false, message: 'API 密钥权限不足');
        case 404:
          return TestConnectionResult(success: false, message: 'API 地址不正确，接口不存在');
        case 429:
          return TestConnectionResult(success: false, message: '请求过于频繁，请稍后重试');
        default:
          return TestConnectionResult(success: false, message: errorMsg);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('HandshakeException')) {
        return TestConnectionResult(success: false, message: '无法连接到服务器，请检查 API 地址');
      }
      if (e.toString().contains('TimeoutException')) {
        return TestConnectionResult(success: false, message: '连接超时，请检查网络或 API 地址');
      }
      return TestConnectionResult(success: false, message: '连接失败: $e');
    }
  }

  /// 兼容旧方法的简化版本
  Future<bool> testConnectionLegacy() async {
    final result = await testConnection();
    return result.success;
  }

  /// 获取可用模型列表
  Future<List<String>> fetchModels() async {
    try {
      // 尝试 OpenAI 格式的 models API
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // OpenAI 格式
        if (data['data'] != null) {
          final models = data['data'] as List;
          return models
              .map((m) => m['id'] as String?)
              .where((id) => id != null && !id.contains('embeddings'))
              .cast<String>()
              .toList();
        }
        
        // OpenRouter 格式
        if (data['models'] != null) {
          final models = data['models'] as List;
          return models
              .map((m) => m['id'] as String?)
              .where((id) => id != null)
              .cast<String>()
              .toList();
        }
      }
      
      // 如果请求失败但没有抛异常，返回默认模型
      return _getDefaultModels();
    } catch (e) {
      // 出错时返回基于URL检测的默认模型
      return _getDefaultModels();
    }
  }

  List<String> _getDefaultModels() {
    if (baseUrl.contains('openai.com')) {
      return ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-4', 'gpt-3.5-turbo', 'gpt-3.5-turbo-16k'];
    } else if (baseUrl.contains('anthropic')) {
      return ['claude-3-5-sonnet-20241022', 'claude-3-5-sonnet-20240620', 'claude-3-opus-20240229', 'claude-3-sonnet-20240229', 'claude-3-haiku-20240307'];
    } else if (baseUrl.contains('openrouter')) {
      return ['anthropic/claude-3.5-sonnet', 'google/gemini-pro', 'google/gemini-flash-1.5', 'openai/gpt-4o', 'meta-llama/Llama-3-70b-chat-hf', 'meta-llama/Llama-3-8b-chat-hf'];
    } else if (baseUrl.contains('kilo')) {
      return ['meta-llama/Llama-3-70b-chat-hf', 'meta-llama/Llama-3-8b-chat-hf', 'Qwen/Qwen2-72B-Instruct'];
    } else if (baseUrl.contains('zhipu')) {
      return ['glm-4', 'glm-4-flash', 'glm-4-plus', 'glm-3-turbo'];
    } else if (baseUrl.contains('moonshot')) {
      return ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'];
    } else if (baseUrl.contains('deepseek')) {
      return ['deepseek-chat', 'deepseek-coder'];
    }
    // 通用默认模型列表
    return [
      'gpt-4o',
      'gpt-4o-mini', 
      'gpt-4-turbo',
      'claude-3-5-sonnet-20240620',
      'meta-llama/Llama-3-70b-chat-hf',
    ];
  }
}

/// LLM 消息
class LlmMessage {
  final String role; // system, user, assistant
  final String content;
  final String? name;

  LlmMessage({
    required this.role,
    required this.content,
    this.name,
  });

  /// 创建系统消息
  factory LlmMessage.system(String content) {
    return LlmMessage(role: 'system', content: content);
  }

  /// 创建用户消息
  factory LlmMessage.user(String content) {
    return LlmMessage(role: 'user', content: content);
  }

  /// 创建助手消息
  factory LlmMessage.assistant(String content) {
    return LlmMessage(role: 'assistant', content: content);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'role': role,
      'content': content,
    };
    if (name != null) json['name'] = name!;
    return json;
  }

  factory LlmMessage.fromJson(Map<String, dynamic> json) {
    return LlmMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      name: json['name'] as String?,
    );
  }
}

/// LLM 响应
class LlmResponse {
  final String content;
  final String model;
  final int tokensUsed;
  final String? reasoning;

  LlmResponse({
    required this.content,
    required this.model,
    required this.tokensUsed,
    this.reasoning,
  });

  factory LlmResponse.fromJson(Map<String, dynamic> json) {
    final choices = json['choices'] as List?;
    final firstChoice = choices?.isNotEmpty == true ? choices![0] : null;
    final message = firstChoice?['message'];
    
    return LlmResponse(
      content: message?['content'] as String? ?? '',
      model: json['model'] as String? ?? '',
      tokensUsed: json['usage']?['total_tokens'] as int? ?? 0,
      reasoning: firstChoice?['reasoning'] as String?,
    );
  }
}

/// LLM 异常
class LlmException implements Exception {
  final String message;
  LlmException(this.message);

  @override
  String toString() => message;
}

/// 连接测试结果
class TestConnectionResult {
  final bool success;
  final String message;

  TestConnectionResult({required this.success, required this.message});
}

/// LLM 配置预设
class LlmPreset {
  static const openai = {
    'name': 'OpenAI',
    'baseUrl': 'https://api.openai.com/v1',
    'model': 'gpt-4o',
  };
  
  static const anthropic = {
    'name': 'Claude',
    'baseUrl': 'https://api.anthropic.com/v1',
    'model': 'claude-3-5-sonnet-20241022',
  };
  
  static const kilo = {
    'name': 'Kilo AI',
    'baseUrl': 'https://api.kilo.ai/api',
    'model': 'meta-llama/Llama-3-70b-chat-hf',
  };
  
  static const openrouter = {
    'name': 'OpenRouter',
    'baseUrl': 'https://openrouter.ai/api/v1',
    'model': 'anthropic/claude-3.5-sonnet',
  };
}

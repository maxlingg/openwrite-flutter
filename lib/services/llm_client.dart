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
  Future<bool> testConnection() async {
    try {
      final response = await chat(
        messages: [LlmMessage.system('You are a helpful assistant.'), LlmMessage.user('Say "OK" if you can hear me.')],
        maxTokens: 10,
      );
      return response.content.isNotEmpty;
    } catch (_) {
      return false;
    }
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
        final models = data['data'] as List?;
        if (models != null) {
          return models
              .map((m) => m['id'] as String?)
              .where((id) => id != null && !id.contains('embeddings'))
              .cast<String>()
              .toList();
        }
      }
      
      // 如果上述失败，返回预设模型列表
      return _getDefaultModels();
    } catch (_) {
      return _getDefaultModels();
    }
  }

  List<String> _getDefaultModels() {
    if (baseUrl.contains('openai.com')) {
      return ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-4', 'gpt-3.5-turbo'];
    } else if (baseUrl.contains('anthropic')) {
      return ['claude-3-5-sonnet-20240620', 'claude-3-opus-20240229', 'claude-3-sonnet-20240229'];
    } else if (baseUrl.contains('openrouter')) {
      return ['anthropic/claude-3.5-sonnet', 'google/gemini-pro', 'openai/gpt-4o', 'meta-llama/Llama-3-70b-chat-hf'];
    } else if (baseUrl.contains('kilo')) {
      return ['meta-llama/Llama-3-70b-chat-hf', 'meta-llama/Llama-3-8b-chat-hf'];
    }
    return [];
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

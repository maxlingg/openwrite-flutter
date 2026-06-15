import 'dart:async';
import 'llm_client.dart';

/// 聊天引擎事件
enum ChatEngineEvent {
  messageAdded,
  textDelta,
  thinkingDelta,
  toolCallStart,
  toolCallResult,
  toolRoundComplete,
  complete,
  usage,
  error,
}

/// 聊天消息
class ChatMessage {
  final String id;
  final String role; // system, user, assistant
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
  final Map<String, dynamic>? toolCall;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isStreaming = false,
    this.toolCall,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
    Map<String, dynamic>? toolCall,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      toolCall: toolCall ?? this.toolCall,
    );
  }
}

/// 聊天引擎
class ChatEngine {
  LlmClient? _client;
  final List<ChatMessage> _messages = [];
  final _messageController = StreamController<ChatEngineState>.broadcast();
  
  // 系统提示词
  String _systemPrompt = '''你是一个专业的小说写作助手，擅长：
- 扩写：将简短的段落扩展为详细的场景描写
- 缩写：将冗长的内容精简为核心要点
- 润色：改善文字表达，使其更流畅优美
- 改写：用不同方式表达相同意思
- 续写：延续现有情节继续创作
- 创作建议：提供情节发展、人物塑造等建议

请用简洁专业的语言回复。''';

  Stream<ChatEngineState> get stream => _messageController.stream;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _client != null;

  /// 设置 LLM 客户端
  void setClient(LlmClient client) {
    _client = client;
  }

  /// 设置系统提示词
  void setSystemPrompt(String prompt) {
    _systemPrompt = prompt;
    _addSystemMessage();
  }

  /// 添加用户消息
  Future<void> addUserMessage(String content) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
    );
    _messages.add(message);
    _emit(ChatEngineState.event(ChatEngineEvent.messageAdded, message));
  }

  /// 发送消息并获取回复
  Future<String> send() async {
    if (_client == null) {
      throw Exception('请先配置 AI 连接');
    }

    // 添加助手占位消息
    final assistantMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: '',
      isStreaming: true,
    );
    _messages.add(assistantMessage);
    _emit(ChatEngineState.event(ChatEngineEvent.messageAdded, assistantMessage));

    try {
      // 构建消息列表
      final llmMessages = <LlmMessage>[
        LlmMessage(role: 'system', content: _systemPrompt),
        ..._messages.where((m) => !m.isStreaming).map((m) => LlmMessage(
          role: m.role,
          content: m.content,
        )),
      ];

      // 发送请求
      final response = await _client!.chat(
        messages: llmMessages,
        temperature: 0.7,
        maxTokens: 4000,
      );

      // 更新消息
      final index = _messages.indexWhere((m) => m.id == assistantMessage.id);
      if (index != -1) {
        _messages[index] = assistantMessage.copyWith(
          content: response.content,
          isStreaming: false,
        );
        _emit(ChatEngineState.event(ChatEngineEvent.messageAdded, _messages[index]));
      }

      _emit(ChatEngineState.event(ChatEngineEvent.complete, null));
      _emit(ChatEngineState.usage(response.tokensUsed));

      return response.content;
    } catch (e) {
      // 移除占位消息
      _messages.removeWhere((m) => m.id == assistantMessage.id);
      _emit(ChatEngineState.error(e.toString()));
      rethrow;
    }
  }

  /// 清空对话历史
  void clearHistory() {
    _messages.clear();
    _addSystemMessage();
    _emit(ChatEngineState.event(ChatEngineEvent.complete, null));
  }

  /// 添加系统消息
  void _addSystemMessage() {
    // 保留最新的系统消息之前的对话
    final userMessages = _messages.where((m) => m.role == 'user').toList();
    _messages.clear();
    
    // 如果已有系统消息，替换它
    final hasSystem = _messages.any((m) => m.role == 'system');
    if (!hasSystem) {
      _messages.add(ChatMessage(
        id: 'system_${DateTime.now().millisecondsSinceEpoch}',
        role: 'system',
        content: _systemPrompt,
      ));
    }
    
    // 重新添加用户消息
    _messages.addAll(userMessages);
  }

  void _emit(ChatEngineState state) {
    _messageController.add(state);
  }

  void dispose() {
    _messageController.close();
  }
}

/// 聊天引擎状态
class ChatEngineState {
  final ChatEngineEvent? event;
  final ChatMessage? message;
  final String? error;
  final int? tokensUsed;

  ChatEngineState({
    this.event,
    this.message,
    this.error,
    this.tokensUsed,
  });

  factory ChatEngineState.event(ChatEngineEvent event, ChatMessage? message) {
    return ChatEngineState(event: event, message: message);
  }

  factory ChatEngineState.error(String error) {
    return ChatEngineState(error: error);
  }

  factory ChatEngineState.usage(int tokens) {
    return ChatEngineState(tokensUsed: tokens);
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// 聊天消息
class ChatMessage {
  final String id;
  final String role; // system, user, assistant
  final String content;
  final DateTime timestamp;
  final String? skillId; // 关联的技能 ID

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.skillId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'skillId': skillId,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    role: json['role'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    skillId: json['skillId'] as String?,
  );
}

/// 聊天会话
class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final String? skillId; // 使用的技能
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    this.messages = const [],
    this.skillId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'skillId': skillId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] as String,
    title: json['title'] as String,
    messages: (json['messages'] as List?)
        ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList() ?? [],
    skillId: json['skillId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    String? skillId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      skillId: skillId ?? this.skillId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// 聊天历史服务
class ChatHistoryService {
  static const _sessionsFile = 'chat_sessions.json';
  final String _dataPath;
  List<ChatSession> _sessions = [];

  ChatHistoryService(this._dataPath);

  /// 加载所有会话
  Future<List<ChatSession>> loadSessions() async {
    try {
      final file = File(path.join(_dataPath, _sessionsFile));
      if (await file.exists()) {
        final content = await file.readAsString();
        final list = jsonDecode(content) as List;
        _sessions = list.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
        // 按更新时间倒序
        _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } catch (_) {
      _sessions = [];
    }
    return _sessions;
  }

  /// 保存所有会话
  Future<void> _saveSessions() async {
    try {
      final file = File(path.join(_dataPath, _sessionsFile));
      await file.writeAsString(jsonEncode(_sessions.map((s) => s.toJson()).toList()));
    } catch (_) {
      // 忽略保存错误
    }
  }

  /// 创建新会话
  Future<ChatSession> createSession({
    String? skillId,
    String title = '新对话',
  }) async {
    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      skillId: skillId,
    );
    _sessions.insert(0, session);
    await _saveSessions();
    return session;
  }

  /// 更新会话
  Future<void> updateSession(ChatSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session.copyWith(updatedAt: DateTime.now());
      await _saveSessions();
    }
  }

  /// 删除会话
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await _saveSessions();
  }

  /// 添加消息到会话
  Future<void> addMessage(String sessionId, ChatMessage message) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = _sessions[index];
      final updatedMessages = [...session.messages, message];
      _sessions[index] = session.copyWith(
        messages: updatedMessages,
        title: session.title == '新对话' && message.role == 'user'
            ? message.content.length > 20
                ? '${message.content.substring(0, 20)}...'
                : message.content
            : session.title,
      );
      await _saveSessions();
    }
  }

  /// 获取会话
  ChatSession? getSession(String id) {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 获取所有会话
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  /// 搜索会话
  List<ChatSession> searchSessions(String query) {
    if (query.isEmpty) return sessions;
    final lower = query.toLowerCase();
    return _sessions.where((s) {
      return s.title.toLowerCase().contains(lower) ||
          s.messages.any((m) => m.content.toLowerCase().contains(lower));
    }).toList();
  }
}

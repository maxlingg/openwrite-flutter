import 'package:flutter/material.dart';
import '../services/chat_engine.dart';
import '../services/llm_client.dart';

/// AI 助手对话页面
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatEngine _chatEngine = ChatEngine();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;
  bool _showSettings = false;
  
  // LLM 配置
  String _baseUrl = 'https://api.openai.com/v1';
  String _apiKey = '';
  String _selectedPreset = 'OpenAI';

  @override
  void initState() {
    super.initState();
    _setupEngine();
  }

  void _setupEngine() {
    _chatEngine.stream.listen((state) {
      if (state.error != null) {
        setState(() {
          _error = state.error;
          _isLoading = false;
        });
      } else if (state.event == ChatEngineEvent.complete) {
        setState(() => _isLoading = false);
      } else if (state.event == ChatEngineEvent.usage) {
        // 记录使用量
      }
    });
  }

  void _connect() {
    if (_apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入 API Key')),
      );
      return;
    }

    final client = LlmClient(
      baseUrl: _baseUrl,
      apiKey: _apiKey,
    );
    
    _chatEngine.setClient(client);
    setState(() {
      _isConnected = true;
      _showSettings = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已连接到 AI')),
    );
  }

  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() => _isLoading = true);

    try {
      await _chatEngine.addUserMessage(content);
      await _chatEngine.send();
      _scrollToBottom();
    } catch (e) {
      // 错误已在 stream 中处理
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空所有对话历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _chatEngine.clearHistory();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _insertTemplate(String template) {
    _inputController.text = template;
    _inputFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _chatEngine.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 写作助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空对话',
            onPressed: _clearHistory,
          ),
          IconButton(
            icon: Icon(_showSettings ? Icons.close : Icons.settings),
            tooltip: '设置',
            onPressed: () => setState(() => _showSettings = !_showSettings),
          ),
        ],
      ),
      body: Column(
        children: [
          // 设置面板
          if (_showSettings) _buildSettingsPanel(),
          
          // 连接提示
          if (!_isConnected) _buildConnectBanner(),
          
          // 消息列表
          Expanded(
            child: _chatEngine.messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(),
          ),
          
          // 错误提示
          if (_error != null) _buildErrorBanner(),
          
          // 快捷模板
          _buildTemplateBar(),
          
          // 输入框
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    final presets = [
      ('OpenAI', 'https://api.openai.com/v1', 'gpt-4o'),
      ('Kilo AI', 'https://api.kilo.ai/api', 'meta-llama/Llama-3-70b-chat-hf'),
      ('OpenRouter', 'https://openrouter.ai/api/v1', 'anthropic/claude-3.5-sonnet'),
      ('自定义', '', ''),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI 配置', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedPreset,
            decoration: const InputDecoration(
              labelText: '服务商',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: presets.map((p) => DropdownMenuItem(
              value: p.$1,
              child: Text(p.$1),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPreset = value;
                  final preset = presets.firstWhere((p) => p.$1 == value);
                  if (preset.$2.isNotEmpty) {
                    _baseUrl = preset.$2;
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
              hintText: '输入你的 API Key',
            ),
            obscureText: true,
            onChanged: (value) => _apiKey = value,
          ),
          const SizedBox(height: 12),
          if (_selectedPreset == '自定义')
            TextField(
              decoration: const InputDecoration(
                labelText: 'Base URL',
                border: OutlineInputBorder(),
                hintText: 'https://api.example.com/v1',
              ),
              onChanged: (value) => _baseUrl = value,
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _connect,
              icon: const Icon(Icons.link),
              label: const Text('连接'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('点击右上角设置配置 AI 连接'),
          ),
          TextButton(
            onPressed: () => setState(() => _showSettings = true),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'AI 写作助手',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '我可以帮你：扩写、缩写、润色、改写、续写',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _chatEngine.messages.length,
      itemBuilder: (context, index) {
        final message = _chatEngine.messages[index];
        if (message.role == 'system') return const SizedBox.shrink();
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser 
              ? colorScheme.primaryContainer 
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? '你' : 'AI 助手',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUser 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              message.content.isEmpty && message.isStreaming 
                  ? '思考中...' 
                  : message.content,
              style: TextStyle(
                color: isUser 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 20, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _error = null),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateBar() {
    final templates = [
      '帮我扩写这段...',
      '帮我缩写这段...',
      '润色这段文字...',
      '续写这个情节...',
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: templates.map((t) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ActionChip(
              label: Text(t, style: const TextStyle(fontSize: 12)),
              onPressed: () => _insertTemplate(t),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocusNode,
                decoration: InputDecoration(
                  hintText: '输入你的问题或创作需求...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isLoading || !_isConnected ? null : _sendMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/chat_engine.dart';
import '../services/llm_client.dart';
import '../services/skill_service.dart';
import '../services/app_settings_service.dart';
import '../services/chat_history_service.dart';
import 'skill_marketplace_screen.dart';

/// AI 助手对话页面
class ChatScreen extends StatefulWidget {
  final String? initialSkillId;
  
  const ChatScreen({super.key, this.initialSkillId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatEngine _chatEngine = ChatEngine();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  final SkillService _skillService = SkillService('');
  
  AppSettingsService? _settingsService;
  ChatHistoryService? _historyService;
  
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;
  bool _showSettings = false;
  bool _showHistory = false;
  
  // LLM 配置
  LlmConfig _llmConfig = LlmConfig();
  
  // 当前技能
  Skill? _currentSkill;
  String _currentSkillId = '';
  
  // 聊天历史
  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _setupEngine();
    _initServices();
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
        // 保存消息到历史
        if (_currentSession != null && _chatEngine.messages.isNotEmpty) {
          final lastMessage = _chatEngine.messages.last;
          _historyService?.addMessage(
            _currentSession!.id,
            HistoryMessage(
              id: lastMessage.id,
              role: lastMessage.role,
              content: lastMessage.content,
            ),
          );
        }
      }
    });
  }

  Future<void> _initServices() async {
    _settingsService = await AppSettingsService.create();
    _historyService = await ChatHistoryService.create();
    
    await _loadSettings();
    await _loadHistory();
  }

  Future<void> _loadSettings() async {
    if (_settingsService == null) return;
    
    final settings = await _settingsService!.loadSettings();
    setState(() {
      _llmConfig = settings.llmConfig;
    });
    
    if (_llmConfig.isConfigured) {
      _connect();
    }
    
    await _skillService.loadInstalledSkills();
    
    if (widget.initialSkillId != null) {
      _currentSkillId = widget.initialSkillId!;
      _currentSkill = _skillService.getSkillById(_currentSkillId);
      if (_currentSkill != null && _isConnected) {
        _chatEngine.setSystemPrompt(_currentSkill!.systemPrompt);
      }
    } else if (settings.currentSkillId != null && settings.currentSkillId!.isNotEmpty) {
      _currentSkillId = settings.currentSkillId!;
      _currentSkill = _skillService.getSkillById(_currentSkillId);
      if (_currentSkill != null && _isConnected) {
        _chatEngine.setSystemPrompt(_currentSkill!.systemPrompt);
      }
    }
    
    setState(() {});
  }

  Future<void> _loadHistory() async {
    if (_historyService == null) return;
    _sessions = await _historyService.loadSessions();
    setState(() {});
  }

  void _connect() {
    if (_llmConfig.apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置 API Key')),
      );
      setState(() => _showSettings = true);
      return;
    }

    final client = LlmClient(
      baseUrl: _llmConfig.baseUrl,
      apiKey: _llmConfig.apiKey,
      model: _llmConfig.model,
    );
    
    _chatEngine.setClient(client);
    
    if (_currentSkill != null) {
      _chatEngine.setSystemPrompt(_currentSkill!.systemPrompt);
    }
    
    setState(() {
      _isConnected = true;
      _showSettings = false;
    });
    
    _saveSettings();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已连接到 AI')),
    );
  }

  Future<void> _saveSettings() async {
    if (_settingsService == null) return;
    final settings = await _settingsService!.loadSettings();
    await _settingsService!.saveSettings(settings.copyWith(
      llmConfig: _llmConfig,
      currentSkillId: _currentSkillId.isNotEmpty ? _currentSkillId : null,
    ));
  }

  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() => _isLoading = true);

    try {
      if (_currentSession == null && _historyService != null) {
        _currentSession = await _historyService!.createSession(
          skillId: _currentSkillId.isNotEmpty ? _currentSkillId : null,
          title: content.length > 20 ? '${content.substring(0, 20)}...' : content,
        );
        _sessions.insert(0, _currentSession!);
        setState(() {});
      }
      
      await _chatEngine.addUserMessage(content);
      
      if (_currentSession != null && _historyService != null) {
        await _historyService!.addMessage(
          _currentSession!.id,
          HistoryMessage(role: 'user', content: content),
        );
      }
      
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
        title: const Text('清空当前对话'),
        content: const Text('确定要清空当前对话历史吗？'),
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

  void _startNewSession() {
    _currentSession = null;
    _chatEngine.clearHistory();
    setState(() {});
  }

  Future<void> _loadSession(ChatSession session) async {
    _currentSession = session;
    _chatEngine.clearHistory();
    
    for (final msg in session.messages) {
      await _chatEngine.addUserMessage(msg.content);
    }
    
    if (session.skillId != null && session.skillId!.isNotEmpty) {
      final skill = _skillService.getSkillById(session.skillId!);
      if (skill != null) {
        _currentSkill = skill;
        _currentSkillId = skill.id;
        if (_isConnected) {
          _chatEngine.setSystemPrompt(skill.systemPrompt);
        }
      }
    }
    
    setState(() {
      _showHistory = false;
    });
  }

  Future<void> _switchSkill(Skill skill) async {
    setState(() {
      _currentSkill = skill;
      _currentSkillId = skill.id;
    });
    
    if (_isConnected) {
      _chatEngine.setSystemPrompt(skill.systemPrompt);
    }
    
    await _saveSettings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已切换到「${skill.name}」')),
      );
    }
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI 写作助手'),
            if (_currentSkill != null)
              Text(
                _currentSkill!.name,
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _currentSkill != null,
              child: const Icon(Icons.auto_awesome),
            ),
            tooltip: '选择技能',
            onPressed: () => _showSkillSelector(),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _sessions.isNotEmpty,
              child: const Icon(Icons.history),
            ),
            tooltip: '对话历史',
            onPressed: () => setState(() => _showHistory = !_showHistory),
          ),
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
          if (_showSettings) _buildSettingsPanel(),
          if (_showHistory) _buildHistoryPanel(),
          if (!_isConnected) _buildConnectBanner(),
          Expanded(
            child: _chatEngine.messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(),
          ),
          if (_error != null) _buildErrorBanner(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('AI 配置', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              TextButton.icon(
                onPressed: _connect,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('保存'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _getPresetName(_llmConfig.baseUrl),
            decoration: const InputDecoration(
              labelText: '服务商',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'OpenAI', child: Text('OpenAI')),
              DropdownMenuItem(value: 'Kilo AI', child: Text('Kilo AI')),
              DropdownMenuItem(value: 'OpenRouter', child: Text('OpenRouter')),
              DropdownMenuItem(value: 'Claude', child: Text('Claude (Anthropic)')),
              DropdownMenuItem(value: '自定义', child: Text('自定义')),
            ],
            onChanged: (value) {
              setState(() {
                switch (value) {
                  case 'OpenAI':
                    _llmConfig = _llmConfig.copyWith(baseUrl: 'https://api.openai.com/v1', model: 'gpt-4o');
                    break;
                  case 'Kilo AI':
                    _llmConfig = _llmConfig.copyWith(baseUrl: 'https://api.kilo.ai/api', model: 'meta-llama/Llama-3-70b-chat-hf');
                    break;
                  case 'OpenRouter':
                    _llmConfig = _llmConfig.copyWith(baseUrl: 'https://openrouter.ai/api/v1', model: 'anthropic/claude-3.5-sonnet');
                    break;
                  case 'Claude':
                    _llmConfig = _llmConfig.copyWith(baseUrl: 'https://api.anthropic.com', model: 'claude-3-5-sonnet-20240620');
                    break;
                }
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
              hintText: '输入你的 API Key',
              prefixIcon: Icon(Icons.key),
            ),
            obscureText: true,
            controller: TextEditingController(text: _llmConfig.apiKey),
            onChanged: (value) {
              _llmConfig = _llmConfig.copyWith(apiKey: value);
              _saveSettings();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: '模型',
              border: OutlineInputBorder(),
              hintText: '如：gpt-4o, claude-3.5-sonnet',
            ),
            controller: TextEditingController(text: _llmConfig.model),
            onChanged: (value) {
              _llmConfig = _llmConfig.copyWith(model: value);
              _saveSettings();
            },
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('高级设置'),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Temperature', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: _llmConfig.temperature.toString()),
                      onChanged: (value) {
                        final temp = double.tryParse(value);
                        if (temp != null) _llmConfig = _llmConfig.copyWith(temperature: temp);
                        _saveSettings();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: '最大 Token', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: _llmConfig.maxTokens.toString()),
                      onChanged: (value) {
                        final tokens = int.tryParse(value);
                        if (tokens != null) _llmConfig = _llmConfig.copyWith(maxTokens: tokens);
                        _saveSettings();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _connect,
              icon: Icon(_isConnected ? Icons.refresh : Icons.link),
              label: Text(_isConnected ? '重新连接' : '连接'),
            ),
          ),
        ],
      ),
    );
  }

  String _getPresetName(String baseUrl) {
    if (baseUrl.contains('openai.com')) return 'OpenAI';
    if (baseUrl.contains('kilo.ai')) return 'Kilo AI';
    if (baseUrl.contains('openrouter')) return 'OpenRouter';
    if (baseUrl.contains('anthropic')) return 'Claude';
    return '自定义';
  }

  Widget _buildHistoryPanel() {
    return Container(
      height: 200,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text('对话历史', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _startNewSession,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新建'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _sessions.isEmpty
                ? const Center(child: Text('暂无历史记录'))
                : ListView.builder(
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.chat),
                        title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(_formatDate(session.updatedAt), style: const TextStyle(fontSize: 12)),
                        selected: _currentSession?.id == session.id,
                        onTap: () => _loadSession(session),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () async {
                            await _historyService?.deleteSession(session.id);
                            _sessions = _historyService?.sessions ?? [];
                            if (_currentSession?.id == session.id) _startNewSession();
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${date.month}/${date.day}';
  }

  Widget _buildConnectBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('点击右上角设置配置 AI 连接')),
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
          Icon(Icons.auto_awesome, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('AI 写作助手', style: Theme.of(context).textTheme.titleLarge),
          if (_currentSkill != null) ...[
            const SizedBox(height: 8),
            Text('当前技能：${_currentSkill!.name}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickButton('帮我扩写这段...', '扩写'),
              _buildQuickButton('帮我缩写这段...', '缩写'),
              _buildQuickButton('润色这段文字...', '润色'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String text, String type) {
    return ActionChip(label: Text(type), onPressed: () {
      _inputController.text = text;
      _inputFocusNode.requestFocus();
    });
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser) ...[
                  Text(_currentSkill?.name ?? 'AI 助手', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => _copyMessage(message.content),
                    tooltip: '复制',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: SelectableText(
                message.content.isEmpty && message.isStreaming ? '思考中...' : message.content,
                style: TextStyle(color: isUser ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
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
          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => setState(() => _error = null)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))],
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isLoading || !_isConnected ? null : _sendMessage,
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkillSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('选择技能', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showSkillMarketplace(context);
                  },
                  child: const Text('管理技能'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentSkill != null)
              ListTile(
                leading: Text(_currentSkill!.icon, style: const TextStyle(fontSize: 24)),
                title: Text(_currentSkill!.name),
                subtitle: const Text('当前使用'),
                trailing: const Icon(Icons.check, color: Colors.green),
              ),
            const Divider(),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _skillService.allAvailableSkills.length,
                itemBuilder: (context, index) {
                  final skill = _skillService.allAvailableSkills[index];
                  return ListTile(
                    leading: Text(skill.icon, style: const TextStyle(fontSize: 24)),
                    title: Text(skill.name),
                    subtitle: Text(skill.category, style: const TextStyle(fontSize: 12)),
                    selected: _currentSkillId == skill.id,
                    trailing: _currentSkillId == skill.id ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (skill.isInstalled || skill.isBuiltIn) {
                        _switchSkill(skill);
                      } else {
                        _skillService.installSkill(skill);
                        setState(() {});
                        _switchSkill(skill);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

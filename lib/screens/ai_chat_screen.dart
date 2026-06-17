import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/llm_client.dart';
import '../services/app_settings_service.dart';
import '../models/ai_message.dart';

/// AI 写作助手主页面 - 复刻原版墨问AI界面
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AppSettingsService _settingsService = AppSettingsService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isConfigured = false;
  bool _webSearchEnabled = false;
  String _currentModel = 'gpt-4o-mini';
  
  // 选中的工具
  String? _selectedTool;
  
  // 书名推荐相关
  String? _pendingContext;
  List<String> _titleOptions = [];
  final TextEditingController _customAnswerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsService.loadSettings();
    final config = _settingsService.llmConfig;
    setState(() {
      _isConfigured = config.isConfigured;
      _currentModel = config.model;
    });
    if (_isConfigured) {
      LlmClient.setGlobalConfig(
        baseUrl: config.baseUrl,
        apiKey: config.apiKey,
        model: config.model,
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _customAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 快捷工具栏
          _buildToolBar(context),
          
          // 聊天内容区
          Expanded(
            child: _messages.isEmpty 
                ? _buildWelcomeView(context)
                : _buildChatList(context),
          ),
          
          // 书名推荐卡片（当有推荐时显示）
          if (_titleOptions.isNotEmpty) _buildTitleRecommendationCard(context),
          
          // 输入区域
          _buildInputArea(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '新对话',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () => _showModelSelector(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentModel,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _clearChat,
          tooltip: '新建对话',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showSettings(context),
        ),
      ],
    );
  }

  /// 快捷工具栏 - 复刻原版
  Widget _buildToolBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.2),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _buildToolChip(
              icon: Icons.note_alt_outlined,
              label: '备忘录',
              color: Colors.blue,
              isSelected: _selectedTool == 'memo',
              onTap: () => _selectTool('memo'),
            ),
            const SizedBox(width: 8),
            _buildToolChip(
              icon: Icons.badge_outlined,
              label: '起名',
              color: Colors.purple,
              isSelected: _selectedTool == 'name',
              onTap: () => _selectTool('name'),
            ),
            const SizedBox(width: 8),
            _buildToolChip(
              icon: Icons.auto_fix_high,
              label: '蒸馏',
              color: Colors.orange,
              isSelected: _selectedTool == 'distill',
              onTap: () => _selectTool('distill'),
            ),
            const SizedBox(width: 8),
            _buildToolChip(
              icon: Icons.architecture,
              label: '拆解',
              color: Colors.teal,
              isSelected: _selectedTool == 'deconstruct',
              onTap: () => _selectTool('deconstruct'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 欢迎页面
  Widget _buildWelcomeView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI 写作助手',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '你的专属创作伙伴',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            if (!_isConfigured)
              FilledButton.icon(
                onPressed: () => _showSettings(context),
                icon: const Icon(Icons.settings),
                label: const Text('配置 AI 设置'),
              )
            else
              Text(
                '已连接 $_currentModel',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  /// 聊天列表
  Widget _buildChatList(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(context, message, index);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser 
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 检查是否是书名推荐消息
            if (!isUser && message.type == 'title_recommendation')
              _buildTitleRecommendationContent(context, message.content)
            else
              SelectableText(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isUser 
                    ? colorScheme.onPrimary.withOpacity(0.6)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 书名推荐内容 - 复刻原版卡片样式
  Widget _buildTitleRecommendationContent(BuildContext context, String content) {
    final colorScheme = Theme.of(context).colorScheme;
    final titles = _extractTitles(content);
    final description = content.split('***')[0].trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(Icons.help_outline, size: 18, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              '书名推荐',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 描述
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        // 书名选项
        ...titles.map((title) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _selectTitle(title),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                '《$title》',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  List<String> _extractTitles(String content) {
    final regex = RegExp(r'《([^》]+)》');
    return regex.allMatches(content).map((m) => m.group(1) ?? '').toList();
  }

  /// 书名推荐卡片 - 固定在输入框上方
  Widget _buildTitleRecommendationCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                '选择或自定义书名',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customAnswerController,
            decoration: InputDecoration(
              hintText: '输入自定义答案...',
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitCustomTitle,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('提交'),
            ),
          ),
        ],
      ),
    );
  }

  /// 输入区域 - 复刻原版
  Widget _buildInputArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 联网搜索开关
          Row(
            children: [
              Icon(Icons.bolt, size: 16, color: colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                '联网搜索',
                style: TextStyle(fontSize: 12, color: colorScheme.primary),
              ),
              const Spacer(),
              Switch(
                value: _webSearchEnabled,
                onChanged: (v) => setState(() => _webSearchEnabled = v),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // 主输入框
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _inputController,
                          maxLines: null,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: _isConfigured 
                                ? '写下你的故事...' 
                                : '请先配置 AI 设置',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          enabled: _isConfigured,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      // 底部工具栏
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: colorScheme.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildBottomToolButton(
                              icon: Icons.auto_awesome,
                              label: '@技能',
                              color: colorScheme.primary,
                              onTap: () => _showSkillsPanel(context),
                            ),
                            _buildBottomToolButton(
                              icon: Icons.folder_outlined,
                              label: '#文件',
                              color: Colors.green,
                              onTap: () {},
                            ),
                            _buildBottomToolButton(
                              icon: Icons.lightbulb_outline,
                              label: '灵感',
                              color: Colors.amber,
                              onTap: () {},
                            ),
                            _buildBottomToolButton(
                              icon: Icons.grid_view,
                              label: '模板',
                              color: Colors.grey,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 发送按钮
              IconButton.filled(
                onPressed: (_isLoading || !_isConfigured || _inputController.text.trim().isEmpty) 
                    ? null 
                    : _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                ),
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _inputController.text.trim().isEmpty || !_isConfigured
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onPrimary,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // === 事件处理 ===

  void _selectTool(String tool) {
    setState(() {
      if (_selectedTool == tool) {
        _selectedTool = null;
      } else {
        _selectedTool = tool;
      }
    });

    // 根据工具设置提示词
    switch (tool) {
      case 'memo':
        _inputController.text = '请帮我整理以下写作灵感笔记，提取核心要点：\n\n';
        break;
      case 'name':
        _inputController.text = '请帮我起一个小说人物/地点/功法名称，要求：';
        break;
      case 'distill':
        _inputController.text = '请帮我蒸馏以下内容，提炼核心观点：\n\n';
        break;
      case 'deconstruct':
        _inputController.text = '请帮我拆解分析这个成功小说的结构：\n\n书名：';
        break;
    }
  }

  void _showModelSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ModelSelectorSheet(
        currentModel: _currentModel,
        onSelect: (model) {
          setState(() => _currentModel = model);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AISettingsSheetFull(
        settingsService: _settingsService,
        onSaved: () {
          _loadSettings();
        },
      ),
    );
  }

  void _showSkillsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SkillsPanelSheet(
        onSelect: (skill) {
          Navigator.pop(context);
          _inputController.text = '使用技能：$skill\n\n';
        },
      ),
    );
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _titleOptions.clear();
      _customAnswerController.clear();
      _selectedTool = null;
    });
  }

  void _selectTitle(String title) {
    _inputController.text = '我选择《$title》，请继续帮我创建小说项目并生成大纲';
    _sendMessage();
  }

  void _submitCustomTitle() {
    final customTitle = _customAnswerController.text.trim();
    if (customTitle.isEmpty) return;
    
    _inputController.text = '我选择自定义书名：$customTitle，请继续帮我创建小说项目';
    _titleOptions.clear();
    _customAnswerController.clear();
    _sendMessage();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading || !_isConfigured) return;

    setState(() {
      _messages.add(ChatMessage(
        isUser: true,
        content: text,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _titleOptions.clear();
    });
    _inputController.clear();

    try {
      final client = LlmClient.getGlobalClient();
      if (client == null) {
        throw Exception('请先配置 AI 设置');
      }

      final messages = _messages.map((m) {
        return m.isUser 
            ? LlmMessage.user(m.content)
            : LlmMessage.assistant(m.content);
      }).toList();

      final response = await client.chat(
        messages: messages,
        temperature: _settingsService.llmConfig.temperature,
      );

      setState(() {
        _messages.add(ChatMessage(
          isUser: false,
          content: response.content,
          timestamp: DateTime.now(),
          type: _detectMessageType(response.content),
        ));

        // 如果是书名推荐，保存选项
        if (_detectMessageType(response.content) == 'title_recommendation') {
          _titleOptions = _extractTitles(response.content);
        }
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          isUser: false,
          content: '抱歉，发生了错误：$e',
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _detectMessageType(String content) {
    if (content.contains('书名推荐') && RegExp(r'《[^》]+》').hasMatch(content)) {
      return 'title_recommendation';
    }
    return 'text';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// 聊天消息模型
class ChatMessage {
  final bool isUser;
  final String content;
  final DateTime timestamp;
  final String type;

  ChatMessage({
    required this.isUser,
    required this.content,
    required this.timestamp,
    this.type = 'text',
  });
}

/// 模型选择器
class _ModelSelectorSheet extends StatefulWidget {
  final String currentModel;
  final Function(String) onSelect;

  const _ModelSelectorSheet({
    required this.currentModel,
    required this.onSelect,
  });

  @override
  State<_ModelSelectorSheet> createState() => _ModelSelectorSheetState();
}

class _ModelSelectorSheetState extends State<_ModelSelectorSheet> {
  List<String> _models = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchModels();
  }

  Future<void> _fetchModels() async {
    setState(() => _isLoading = true);
    try {
      final client = LlmClient.getGlobalClient();
      if (client != null) {
        final models = await client.fetchModels();
        setState(() => _models = models);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('选择模型', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchModels,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_models.isEmpty)
            const Center(child: Text('暂无可用模型'))
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _models.length,
                itemBuilder: (context, index) {
                  final model = _models[index];
                  final isSelected = model == widget.currentModel;
                  return ListTile(
                    title: Text(model),
                    trailing: isSelected 
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    selected: isSelected,
                    onTap: () => widget.onSelect(model),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 技能面板
class _SkillsPanelSheet extends StatelessWidget {
  final Function(String) onSelect;

  const _SkillsPanelSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final skills = [
      ('📖', '小说创作', '专业的网文写作助手'),
      ('🎭', '角色设定', '创建丰满的人物形象'),
      ('🏰', '世界观构建', '设计独特的世界体系'),
      ('📋', '大纲生成', '快速生成故事大纲'),
      ('✨', '文风优化', '提升文章质量'),
      ('🔍', '查重检测', '检测内容重复率'),
    ];

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('选择技能', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: skills.map((s) {
              return InkWell(
                onTap: () => onSelect(s.$2),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 52) / 2,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(s.$1, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Text(
                        s.$2,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        s.$3,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 完整的 AI 设置面板
class _AISettingsSheetFull extends StatefulWidget {
  final AppSettingsService settingsService;
  final VoidCallback? onSaved;

  const _AISettingsSheetFull({
    required this.settingsService,
    this.onSaved,
  });

  @override
  State<_AISettingsSheetFull> createState() => _AISettingsSheetFullState();
}

class _AISettingsSheetFullState extends State<_AISettingsSheetFull> {
  final _apiUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  String _selectedProvider = 'OpenAI';
  bool _isTesting = false;
  bool _isLoadingModels = false;
  List<String> _availableModels = [];
  String _model = 'gpt-4o-mini';
  double _temperature = 0.7;

  final _presets = {
    'OpenAI': {'url': 'https://api.openai.com/v1', 'model': 'gpt-4o-mini'},
    'Claude': {'url': 'https://api.anthropic.com', 'model': 'claude-3-5-sonnet-20240620'},
    'Kilo AI': {'url': 'https://api.kilig.ai/v1', 'model': 'meta-llama/Llama-3-70b-chat-hf'},
    '硅基流动': {'url': 'https://api.siliconflow.cn/v1', 'model': 'Qwen/Qwen2.5-72B-Instruct'},
    '自定义': {'url': '', 'model': ''},
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final config = widget.settingsService.llmConfig;
    setState(() {
      _apiUrlController.text = config.baseUrl;
      _apiKeyController.text = config.apiKey;
      _model = config.model;
      _temperature = config.temperature;
      
      if (config.baseUrl.contains('openai.com')) {
        _selectedProvider = 'OpenAI';
      } else if (config.baseUrl.contains('anthropic')) {
        _selectedProvider = 'Claude';
      } else if (config.baseUrl.contains('kilo')) {
        _selectedProvider = 'Kilo AI';
      } else if (config.baseUrl.contains('siliconflow')) {
        _selectedProvider = '硅基流动';
      } else if (config.baseUrl.isNotEmpty) {
        _selectedProvider = '自定义';
      }
    });
  }

  Future<void> _saveSettings() async {
    final config = LlmConfig(
      baseUrl: _apiUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      model: _model,
      temperature: _temperature,
    );
    
    await widget.settingsService.updateLlmConfig(config);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
      widget.onSaved?.call();
      Navigator.pop(context);
    }
  }

  Future<void> _testConnection() async {
    if (_apiUrlController.text.isEmpty || _apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整的 API 配置')),
      );
      return;
    }

    setState(() => _isTesting = true);
    try {
      final client = LlmClient(
        baseUrl: _apiUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        model: _model,
      );
      final result = await client.testConnection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success ? '✓ ${result.message}' : '✗ ${result.message}'),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('连接失败: $e')),
        );
      }
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _fetchModels() async {
    if (_apiUrlController.text.isEmpty || _apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写 API 配置')),
      );
      return;
    }

    setState(() => _isLoadingModels = true);
    try {
      final client = LlmClient(
        baseUrl: _apiUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        model: _model,
      );
      final models = await client.fetchModels();
      setState(() => _availableModels = models);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取到 ${models.length} 个模型')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取模型失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingModels = false);
    }
  }

  void _onPresetChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedProvider = value;
      if (value != '自定义') {
        _apiUrlController.text = _presets[value]!['url']!;
        _model = _presets[value]!['model']!;
        _availableModels = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⚙️ AI 设置', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 服务商预设
            const Text('服务商预设', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.keys.map((key) {
                final isSelected = _selectedProvider == key;
                return ChoiceChip(
                  label: Text(key),
                  selected: isSelected,
                  onSelected: (_) => _onPresetChanged(key),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // API 地址
            const Text('API 地址', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _apiUrlController,
              readOnly: _selectedProvider != '自定义',
              decoration: InputDecoration(
                hintText: 'https://api.openai.com/v1',
                suffixIcon: _selectedProvider != '自定义' 
                    ? const Icon(Icons.lock, size: 18) 
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // API 密钥
            const Text('API 密钥', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'sk-...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // 获取模型按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingModels ? null : _fetchModels,
                icon: _isLoadingModels 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: const Text('获取可用模型'),
              ),
            ),
            
            // 模型选择
            if (_availableModels.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('选择模型', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableModels.length,
                  itemBuilder: (context, i) {
                    return RadioListTile<String>(
                      title: Text(_availableModels[i], style: const TextStyle(fontSize: 13)),
                      value: _availableModels[i],
                      groupValue: _model,
                      onChanged: (v) => setState(() => _model = v!),
                      dense: true,
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Temperature
            Row(
              children: [
                const Text('Temperature', style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(_temperature.toStringAsFixed(1)),
              ],
            ),
            Slider(
              value: _temperature,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              onChanged: (v) => setState(() => _temperature = v),
            ),
            
            const SizedBox(height: 20),
            
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isTesting ? null : _testConnection,
                    child: _isTesting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('测试连接'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveSettings,
                    child: const Text('保存设置'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

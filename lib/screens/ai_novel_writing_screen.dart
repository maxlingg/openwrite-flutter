import 'package:flutter/material.dart';
import '../widgets/page_decoration.dart';
import '../services/llm_client.dart';
import '../services/app_settings_service.dart';

/// AI 小说写作助手主页 - 完整的 AI 小说创作流程
class AINovelWritingScreen extends StatefulWidget {
  const AINovelWritingScreen({super.key});

  @override
  State<AINovelWritingScreen> createState() => _AINovelWritingScreenState();
}

class _AINovelWritingScreenState extends State<AINovelWritingScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AppSettingsService _settingsService = AppSettingsService();
  final List<LlmMessage> _chatHistory = [];
  
  List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _webSearchEnabled = false;
  bool _isConfigured = false;
  
  // 存储当前对话上下文
  Map<String, dynamic>? _currentProject;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 小说助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'AI 设置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 快捷工具栏
          _buildToolBar(context),
          
          // 主要功能入口
          Expanded(
            child: _messages.isEmpty 
                ? _buildWelcomeScreen(context)
                : _buildChatList(context),
          ),
          
          // 输入区域
          _buildInputArea(context),
        ],
      ),
    );
  }

  /// 快捷工具栏
  Widget _buildToolBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _buildToolButton(context, Icons.note_alt_outlined, '备忘录', Colors.blue),
            const SizedBox(width: 8),
            _buildToolButton(context, Icons.badge_outlined, '起名', Colors.purple),
            const SizedBox(width: 8),
            _buildToolButton(context, Icons.auto_fix_high, '蒸馏', Colors.orange),
            const SizedBox(width: 8),
            _buildToolButton(context, Icons.architecture, '拆解', Colors.teal),
            const SizedBox(width: 8),
            _buildToolButton(context, Icons.auto_stories, '书名', Colors.pink),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(BuildContext context, IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => _handleToolTap(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  /// 欢迎页面
  Widget _buildWelcomeScreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PageDecoration.scrollContent(
      child: Column(
        children: [
          // Logo 区域
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI 小说写作助手',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '你的专属创作伙伴',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 三大功能入口
          _buildFeatureCard(
            context,
            icon: Icons.auto_stories,
            title: '新书启航',
            subtitle: '初始化小说项目，创建目录结构',
            color: colorScheme.primary,
            onTap: () => _showNewBookWizard(context),
          ),
          const SizedBox(height: 12),
          
          _buildFeatureCard(
            context,
            icon: Icons.play_arrow,
            title: '继续写作',
            subtitle: '从上次中断的地方继续创作',
            color: Colors.green,
            onTap: () => _showRecentProjects(context),
          ),
          const SizedBox(height: 12),
          
          _buildFeatureCard(
            context,
            icon: Icons.menu_book,
            title: '使用教程',
            subtitle: '查看完整功能使用指南',
            color: Colors.amber,
            onTap: () => _showTutorial(context),
          ),
          
          const SizedBox(height: 24),
          
          // 热门类型
          PageDecoration.sectionTitle(context, '🎯 热门类型推荐'),
          _buildGenreChips(context),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreChips(BuildContext context) {
    final genres = [
      ('都市异能', Colors.blue, 'urban_supernatural'),
      ('玄幻修真', Colors.purple, 'xianxia'),
      ('都市言情', Colors.pink, 'urban_romance'),
      ('科幻末世', Colors.teal, 'sci_fi'),
      ('悬疑惊悚', Colors.indigo, 'thriller'),
      ('历史穿越', Colors.brown, 'historical'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((g) {
        return ActionChip(
          avatar: Icon(Icons.bookmark, size: 16, color: g.$2),
          label: Text(g.$1),
          onPressed: () => _startWithGenre(g.$1, g.$3),
        );
      }).toList(),
    );
  }

  /// 聊天列表
  Widget _buildChatList(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, _ChatMessage message) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && message.type == 'title_recommendation')
              _buildTitleRecommendation(context, message.content)
            else if (!isUser && message.type == 'project_created')
              _buildProjectCreated(context, message.content)
            else
              Text(
                message.content,
                style: TextStyle(
                  color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 书名推荐卡片
  Widget _buildTitleRecommendation(BuildContext context, String content) {
    // 解析推荐的标题
    final titles = _parseTitles(content);
    final parts = content.split('***');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parts.isNotEmpty && parts[0].isNotEmpty)
          Text(
            parts[0].trim(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 12),
        ...titles.map((title) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _selectTitle(title),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '《$title》',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
        if (parts.length > 1 && parts[1].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              parts[1].trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  List<String> _parseTitles(String content) {
    // 简单的标题解析
    final regex = RegExp(r'《([^》]+)》');
    return regex.allMatches(content).map((m) => m.group(1) ?? '').toList();
  }

  /// 项目创建卡片
  Widget _buildProjectCreated(BuildContext context, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 32),
        const SizedBox(height: 8),
        Text(
          '小说项目已创建！',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('开始写作'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {},
              child: const Text('查看大纲'),
            ),
          ],
        ),
      ],
    );
  }

  /// 输入区域
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
          top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 联网搜索开关
          Row(
            children: [
              Icon(Icons.language, size: 16, color: colorScheme.primary),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: _isConfigured ? '写下你的故事...' : '请先在设置中配置 AI',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  enabled: _isConfigured,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isLoading || !_isConfigured ? null : _sendMessage,
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
        ],
      ),
    );
  }

  // === 事件处理 ===

  void _handleToolTap(String tool) {
    switch (tool) {
      case '备忘录':
        _showMemoTool();
        break;
      case '起名':
        _showNamingTool();
        break;
      case '蒸馏':
        _showDistillTool();
        break;
      case '拆解':
        _showDeconstructTool();
        break;
      case '书名':
        _showTitleRecommendation();
        break;
    }
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AISettingsSheet(
        settingsService: _settingsService,
        onSaved: () {
          _loadSettings();
        },
      ),
    );
  }

  void _showNewBookWizard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _NewBookWizard(
        onComplete: (title, genre) {
          Navigator.pop(context);
          _createNewBook(title, genre);
        },
      ),
    );
  }

  void _showRecentProjects(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('暂无最近的写作项目')),
    );
  }

  void _showTutorial(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _TutorialContent(
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _startWithGenre(String genreName, String genreKey) {
    _inputController.text = '我想写一部$genreName类型的小说，帮我推荐一些热门书名';
    _sendMessage();
  }

  void _showMemoTool() {
    _inputController.text = '帮我整理一下写作灵感笔记';
  }

  void _showNamingTool() {
    _inputController.text = '帮我起一个好听的小说人物名字，要求：姓李，男主角，年轻帅气';
  }

  void _showDistillTool() {
    _inputController.text = '帮我蒸馏以下内容，提取核心观点：\n\n';
  }

  void _showDeconstructTool() {
    _inputController.text = '帮我拆解一个成功小说的结构：\n\n';
  }

  void _showTitleRecommendation() {
    _inputController.text = '根据我的喜好（都市异能/玄幻修真），推荐几个热门书名';
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading || !_isConfigured) return;

    setState(() {
      _messages.add(_ChatMessage(isUser: true, content: text));
      _isLoading = true;
    });
    _inputController.clear();

    // 添加到聊天历史
    _chatHistory.add(LlmMessage.user(text));

    try {
      final client = LlmClient.getGlobalClient();
      if (client == null) {
        throw Exception('请先配置 AI 设置');
      }
      
      final response = await client.chat(
        messages: _chatHistory,
        temperature: _settingsService.llmConfig.temperature,
      );
      
      _chatHistory.add(LlmMessage.assistant(response.content));
      
      setState(() {
        _messages.add(_ChatMessage(isUser: false, content: response.content));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          isUser: false,
          content: '抱歉，发生了错误：$e',
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectTitle(String title) {
    _inputController.text = '好的，我选择《$title》，请帮我创建小说项目并生成大纲';
  }

  void _createNewBook(String title, String genre) {
    setState(() {
      _messages.add(_ChatMessage(
        isUser: false,
        type: 'project_created',
        content: '已创建小说《$title》，类型：$genre。\n\n现在你可以：\n• 开始创作第一章\n• 生成详细大纲\n• 设定世界观和角色',
      ));
    });
  }
}

/// 聊天消息模型
class _ChatMessage {
  final bool isUser;
  final String content;
  final String? type;

  _ChatMessage({
    required this.isUser,
    required this.content,
    this.type,
  });
}

/// 新书创建向导
class _NewBookWizard extends StatefulWidget {
  final Function(String title, String genre) onComplete;

  const _NewBookWizard({required this.onComplete});

  @override
  State<_NewBookWizard> createState() => _NewBookWizardState();
}

class _NewBookWizardState extends State<_NewBookWizard> {
  final _titleController = TextEditingController();
  String _selectedGenre = 'urban_supernatural';

  final _genres = [
    ('urban_supernatural', '都市异能', Colors.blue),
    ('xianxia', '玄幻修真', Colors.purple),
    ('urban_romance', '都市言情', Colors.pink),
    ('sci_fi', '科幻末世', Colors.teal),
    ('thriller', '悬疑惊悚', Colors.indigo),
    ('historical', '历史穿越', Colors.brown),
    ('fantasy', '奇幻魔法', Colors.amber),
    ('game', '游戏异界', Colors.green),
  ];

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
              const Icon(Icons.auto_stories, size: 28),
              const SizedBox(width: 8),
              Text(
                '新书启航',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 书名输入
          Text('📖 书名', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '输入小说名称',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 类型选择
          Text('🏷️ 类型', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _genres.map((g) {
              final isSelected = _selectedGenre == g.$1;
              return ChoiceChip(
                label: Text(g.$2),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedGenre = g.$1);
                },
                avatar: isSelected ? null : Icon(Icons.bookmark_border, size: 16, color: g.$3),
                selectedColor: g.$3.withOpacity(0.2),
                side: BorderSide(
                  color: isSelected ? g.$3 : colorScheme.outline,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (_titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入书名')),
                  );
                  return;
                }
                widget.onComplete(_titleController.text.trim(), _selectedGenre);
              },
              icon: const Icon(Icons.rocket_launch),
              label: const Text('开始创作'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 教程内容
class _TutorialContent extends StatelessWidget {
  final ScrollController scrollController;

  const _TutorialContent({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '📚 使用教程',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildTutorialSection(
                  context,
                  icon: Icons.auto_stories,
                  title: '新书启航',
                  content: '点击「新书启航」创建新小说项目。选择类型（都市异能、玄幻修真等），AI 将帮你生成书名、大纲和世界观设定。',
                ),
                _buildTutorialSection(
                  context,
                  icon: Icons.play_arrow,
                  title: '继续写作',
                  content: '从上次中断的地方继续创作。AI 会记住对话上下文，提供连贯的写作建议。',
                ),
                _buildTutorialSection(
                  context,
                  icon: Icons.badge,
                  title: '起名工具',
                  content: '为你的角色、地点、功法等起个好名字。告诉 AI 角色的性别、性格、时代背景等特征。',
                ),
                _buildTutorialSection(
                  context,
                  icon: Icons.auto_fix_high,
                  title: '蒸馏功能',
                  content: '将长段落提炼为核心内容，或将简略描述扩展为详细描写。',
                ),
                _buildTutorialSection(
                  context,
                  icon: Icons.architecture,
                  title: '拆解功能',
                  content: '分析优秀小说的结构、节奏、人物设定，学习成功作品的写作技巧。',
                ),
                _buildTutorialSection(
                  context,
                  icon: Icons.chat,
                  title: '对话创作',
                  content: '直接与 AI 对话，描述你的写作想法，获取灵感和建议。',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AI 设置面板
class _AISettingsSheet extends StatefulWidget {
  final AppSettingsService settingsService;
  final VoidCallback? onSaved;

  const _AISettingsSheet({
    required this.settingsService,
    this.onSaved,
  });

  @override
  State<_AISettingsSheet> createState() => _AISettingsSheetState();
}

class _AISettingsSheetState extends State<_AISettingsSheet> {
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
      
      // 根据 URL 识别预设
      if (config.baseUrl.contains('openai.com')) {
        _selectedProvider = 'OpenAI';
      } else if (config.baseUrl.contains('anthropic')) {
        _selectedProvider = 'Claude';
      } else if (config.baseUrl.contains('kilo')) {
        _selectedProvider = 'Kilo AI';
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
      
      if (models.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取到 ${models.length} 个模型')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('使用默认模型列表')),
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
            PageDecoration.sectionTitle(context, '服务商预设'),
            PageDecoration.choiceChipGrid(
              items: _presets.keys.toList(),
              selectedItem: _selectedProvider,
              onSelected: _onPresetChanged,
            ),
            const SizedBox(height: 16),
            
            // API 地址
            PageDecoration.sectionTitle(context, 'API 地址'),
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
            PageDecoration.sectionTitle(context, 'API 密钥'),
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
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('获取可用模型'),
              ),
            ),
            
            // 模型选择
            if (_availableModels.isNotEmpty) ...[
              const SizedBox(height: 16),
              PageDecoration.sectionTitle(context, '选择模型'),
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
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

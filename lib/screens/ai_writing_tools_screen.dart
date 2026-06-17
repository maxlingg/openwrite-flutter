import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/llm_client.dart';
import '../services/app_settings_service.dart';
import '../widgets/page_decoration.dart';

/// AI 写作助手工具箱 - 完整的 AI 写作功能
class AIWritingToolsScreen extends StatelessWidget {
  const AIWritingToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(
      context: context,
      title: 'AI 写作助手',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showAISettings(context),
          tooltip: 'AI 设置',
        ),
      ],
      body: const _AIWritingToolsBody(),
    );
  }

  void _showAISettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AISettingsSheet(),
    );
  }
}

class _AIWritingToolsBody extends StatelessWidget {
  const _AIWritingToolsBody();

  @override
  Widget build(BuildContext context) {
    return PageDecoration.scrollContent(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 状态卡片
          const _AIStatusCard(),
          PageDecoration.divider(height: 24),

          // 文段处理工具
          PageDecoration.sectionTitle(context, '✍️ 文段处理'),
          _buildToolsGrid(context, [
            _ToolItem(icon: Icons.text_fields, title: '扩写', description: '扩展简短内容', color: Colors.blue, onTap: () => _showTextTool(context, 'expand', '扩写')),
            _ToolItem(icon: Icons.compress, title: '缩写', description: '精简冗长内容', color: Colors.green, onTap: () => _showTextTool(context, 'condense', '缩写')),
            _ToolItem(icon: Icons.auto_fix_high, title: '润色', description: '优化语句质量', color: Colors.purple, onTap: () => _showTextTool(context, 'polish', '润色')),
            _ToolItem(icon: Icons.translate, title: '文风转换', description: '改变文章风格', color: Colors.orange, onTap: () => _showStyleTransfer(context)),
          ]),
          PageDecoration.divider(height: 24),

          // 创作辅助工具
          PageDecoration.sectionTitle(context, '🎨 创作辅助'),
          _buildToolsGrid(context, [
            _ToolItem(icon: Icons.lightbulb, title: '写作建议', description: '获取写作灵感', color: Colors.amber, onTap: () => _showWritingSuggestions(context)),
            _ToolItem(icon: Icons.analytics, title: '段落分析', description: '分析段落优缺点', color: Colors.teal, onTap: () => _showTextTool(context, 'analyze', '段落分析')),
            _ToolItem(icon: Icons.landscape, title: '场景描写', description: '生成场景描写', color: Colors.indigo, onTap: () => _showSceneGenerator(context)),
            _ToolItem(icon: Icons.record_voice_over, title: '人物对话', description: '生成人物对话', color: Colors.pink, onTap: () => _showDialogGenerator(context)),
          ]),
          PageDecoration.divider(height: 24),

          // 故事构思工具
          PageDecoration.sectionTitle(context, '📚 故事构思'),
          _buildToolsGrid(context, [
            _ToolItem(icon: Icons.account_tree, title: '大纲生成', description: '生成章节大纲', color: Colors.brown, onTap: () => _showOutlineGenerator(context)),
            _ToolItem(icon: Icons.public, title: '世界观设定', description: '创建世界观', color: Colors.cyan, onTap: () => _showWorldBuilding(context)),
            _ToolItem(icon: Icons.person, title: '角色设定', description: '生成角色', color: Colors.deepPurple, onTap: () => _showCharacterGenerator(context)),
            _ToolItem(icon: Icons.flash_on, title: '灵感火花', description: '随机创作灵感', color: Colors.red, onTap: () => _showInspiration(context)),
          ]),
          PageDecoration.divider(height: 24),

          // AI 对话入口
          PageDecoration.sectionTitle(context, '💬 AI 对话'),
          PageDecoration.card(
            onTap: () => _openAIChat(context),
            child: const Row(
              children: [
                Icon(Icons.chat, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI 写作助手', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('与 AI 进行创作对话', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          PageDecoration.divider(height: 40),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context, List<_ToolItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildToolCard(context, items[index]),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem item) {
    return PageDecoration.card(
      padding: const EdgeInsets.all(12),
      onTap: item.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Expanded(
            child: Text(item.description, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  void _showTextTool(BuildContext context, String type, String title) {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => AITextToolSheet(type: type, title: title));
  }

  void _showStyleTransfer(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => const AIStyleTransferSheet());
  }

  void _showWritingSuggestions(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AIWritingSuggestionsScreen()));
  }

  void _showSceneGenerator(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AISceneGeneratorScreen()));
  }

  void _showDialogGenerator(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AIDialogGeneratorScreen()));
  }

  void _showOutlineGenerator(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AIOutlineGeneratorScreen()));
  }

  void _showWorldBuilding(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AIWorldBuildingScreen()));
  }

  void _showCharacterGenerator(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AICharacterGeneratorScreen()));
  }

  void _showInspiration(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AIInspirationScreen()));
  }

  void _openAIChat(BuildContext context) {
    Navigator.pushNamed(context, '/chat');
  }
}

class _ToolItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  _ToolItem({required this.icon, required this.title, required this.description, required this.color, required this.onTap});
}

/// AI 状态卡片
class _AIStatusCard extends StatelessWidget {
  const _AIStatusCard();

  @override
  Widget build(BuildContext context) {
    final isConnected = LlmClient.globalConfigured;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? colorScheme.primaryContainer : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(isConnected ? Icons.cloud_done : Icons.cloud_off, size: 32, color: isConnected ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isConnected ? 'AI 服务已连接' : 'AI 服务未配置', style: TextStyle(fontWeight: FontWeight.bold, color: isConnected ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer)),
                Text(isConnected ? '可以开始使用 AI 写作功能' : '请先配置 AI 服务', style: TextStyle(fontSize: 12, color: isConnected ? colorScheme.onPrimaryContainer.withOpacity(0.8) : colorScheme.onErrorContainer.withOpacity(0.8))),
              ],
            ),
          ),
          if (!isConnected)
            TextButton(onPressed: () {}, child: Text('去设置', style: TextStyle(color: colorScheme.onErrorContainer))),
        ],
      ),
    );
  }
}

/// AI 设置面板
class _AISettingsSheet extends StatefulWidget {
  const _AISettingsSheet();

  @override
  State<_AISettingsSheet> createState() => _AISettingsSheetState();
}

class _AISettingsSheetState extends State<_AISettingsSheet> {
  final _apiUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  String _selectedProvider = 'OpenAI';
  String _model = 'gpt-4o';
  double _temperature = 0.7;
  bool _isLoadingModels = false;
  bool _isTesting = false;
  List<String> _availableModels = [];

  final Map<String, Map<String, String>> _presets = {
    'OpenAI': {'url': 'https://api.openai.com/v1', 'models': 'gpt-4o,gpt-4o-mini,gpt-4-turbo,gpt-3.5-turbo'},
    'Kilo AI': {'url': 'https://api.kilo.ai/api', 'models': 'meta-llama/Llama-3-70b-chat-hf,meta-llama/Llama-3-8b-chat-hf'},
    'OpenRouter': {'url': 'https://openrouter.ai/api/v1', 'models': 'anthropic/claude-3.5-sonnet,google/gemini-pro,openai/gpt-4o'},
    'Claude': {'url': 'https://api.anthropic.com', 'models': 'claude-3-5-sonnet-20240620,claude-3-opus-20240229,claude-3-sonnet-20240229'},
    '自定义': {'url': '', 'models': ''},
  };

  @override
  void initState() { super.initState(); _loadSettings(); }

  Future<void> _loadSettings() async {
    final settings = await AppSettingsService.create();
    final config = settings.llmConfig;
    _apiUrlController.text = config.baseUrl;
    _apiKeyController.text = config.apiKey;
    setState(() {
      _selectedProvider = _getProviderFromUrl(config.baseUrl);
      _model = config.model;
      _temperature = config.temperature;
      _updateModelsFromPreset();
    });
  }

  void _updateModelsFromPreset() {
    final preset = _presets[_selectedProvider];
    if (preset != null && preset['models']!.isNotEmpty) {
      _availableModels = preset['models']!.split(',');
      if (!_availableModels.contains(_model)) _model = _availableModels.isNotEmpty ? _availableModels[0] : '';
    } else {
      _availableModels = [];
    }
  }

  String _getProviderFromUrl(String url) {
    if (url.contains('openai.com')) return 'OpenAI';
    if (url.contains('kilo.ai')) return 'Kilo AI';
    if (url.contains('openrouter')) return 'OpenRouter';
    if (url.contains('anthropic')) return 'Claude';
    return 'OpenAI';
  }

  @override
  void dispose() { _apiUrlController.dispose(); _apiKeyController.dispose(); super.dispose(); }

  Future<void> _fetchModels() async {
    final apiUrl = _apiUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (apiUrl.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先输入 API 地址和密钥')));
      return;
    }
    setState(() => _isLoadingModels = true);
    try {
      final client = LlmClient(baseUrl: apiUrl, apiKey: apiKey, model: '');
      final models = await client.fetchModels();
      setState(() { _availableModels = models; _isLoadingModels = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('获取到 ${models.length} 个模型')));
    } catch (e) {
      setState(() => _isLoadingModels = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('获取模型失败: $e')));
    }
  }

  Future<void> _testConnection() async {
    final apiUrl = _apiUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (apiUrl.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先输入 API 地址和密钥')));
      return;
    }
    setState(() => _isTesting = true);
    try {
      final client = LlmClient(baseUrl: apiUrl, apiKey: apiKey, model: _model);
      final result = await client.testConnection();
      setState(() => _isTesting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success ? '✓ ${result.message}' : '✗ ${result.message}'),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isTesting = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('连接失败: $e')));
    }
  }

  Future<void> _saveSettings() async {
    final apiUrl = _apiUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (apiUrl.isEmpty || apiKey.isEmpty || _model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请填写完整信息')));
      return;
    }
    final settings = await AppSettingsService.create();
    await settings.updateLlmConfig(LlmConfig(baseUrl: apiUrl, apiKey: apiKey, model: _model, temperature: _temperature));
    if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI 设置已保存'))); }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Text('AI 设置', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Spacer(), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
            PageDecoration.divider(height: 20),
            PageDecoration.sectionTitle(context, '服务商预设'),
            PageDecoration.choiceChipGrid(items: _presets.keys.toList(), selectedItem: _selectedProvider, onSelected: (v) { setState(() { _selectedProvider = v; if (v != '自定义') _apiUrlController.text = _presets[v]!['url']!; _updateModelsFromPreset(); }); }),
            PageDecoration.divider(height: 16),
            PageDecoration.sectionTitle(context, 'API 地址'),
            PageDecoration.inputField(controller: _apiUrlController, label: '', hint: 'https://api.openai.com/v1', readOnly: _selectedProvider != '自定义', suffixIcon: _selectedProvider != '自定义' ? const Icon(Icons.lock, size: 18) : null),
            PageDecoration.divider(height: 16),
            PageDecoration.sectionTitle(context, 'API 密钥'),
            PageDecoration.inputField(controller: _apiKeyController, label: '', hint: 'sk-...', obscureText: true),
            PageDecoration.divider(height: 16),
            PageDecoration.button(label: '获取可用模型', onPressed: _fetchModels, isLoading: _isLoadingModels, isOutlined: true, isExpanded: true, icon: Icons.refresh),
            PageDecoration.divider(height: 16),
            PageDecoration.sectionTitle(context, '选择模型'),
            if (_availableModels.isEmpty)
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)), child: const Text('点击上方按钮获取可用模型'))
            else
              Container(constraints: const BoxConstraints(maxHeight: 150), decoration: BoxDecoration(border: Border.all(color: colorScheme.outline.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)), child: ListView.builder(shrinkWrap: true, itemCount: _availableModels.length, itemBuilder: (context, i) => RadioListTile<String>(title: Text(_availableModels[i], style: const TextStyle(fontSize: 13)), value: _availableModels[i], groupValue: _model, onChanged: (v) => setState(() => _model = v!), dense: true))),
            PageDecoration.divider(height: 16),
            Row(children: [const Text('Temperature', style: TextStyle(fontWeight: FontWeight.w500)), const Spacer(), Text(_temperature.toStringAsFixed(1))]),
            Slider(value: _temperature, min: 0.0, max: 2.0, divisions: 20, onChanged: (v) => setState(() => _temperature = v)),
            PageDecoration.divider(height: 20),
            PageDecoration.buttonRow(label1: '测试连接', onPressed1: _testConnection, label2: '保存设置', onPressed2: _saveSettings, isLoading: _isTesting),
          ],
        ),
      ),
    );
  }
}

/// AI 文段处理工具
class AITextToolSheet extends StatefulWidget {
  final String type;
  final String title;
  const AITextToolSheet({super.key, required this.type, required this.title});
  @override
  State<AITextToolSheet> createState() => _AITextToolSheetState();
}

class _AITextToolSheetState extends State<AITextToolSheet> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  bool _isLoading = false;

  String get _systemPrompt {
    switch (widget.type) {
      case 'expand': return '你是一个专业的小说写作助手。请将用户提供的简短内容扩展为详细、生动的描写，保持原文的核心思想和风格。';
      case 'condense': return '你是一个专业的小说写作助手。请将用户提供的冗长内容精简为核心要点，保持最重要的信息。';
      case 'polish': return '你是一个专业的小说写作助手。请优化用户提供的文字，提升语句流畅度和表达准确性。';
      case 'analyze': return '你是一个专业的小说写作助手。请分析用户提供的段落，指出优点和不足，给出改进建议。';
      default: return '你是一个专业的小说写作助手。';
    }
  }

  @override
  void dispose() { _inputController.dispose(); _outputController.dispose(); super.dispose(); }

  Future<void> _processText() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入内容'))); return; }
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      if (!config.isConfigured) throw Exception('请先配置 AI');
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final response = await client.chat(messages: [LlmMessage.system(_systemPrompt), LlmMessage.user(input)], temperature: config.temperature);
      setState(() { _outputController.text = response.content; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('处理失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Spacer(), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
          PageDecoration.divider(height: 16),
          PageDecoration.sectionTitle(context, '输入内容'),
          Expanded(child: PageDecoration.inputField(controller: _inputController, label: '', hint: '请输入要处理的内容...', maxLines: 0)),
          PageDecoration.divider(height: 12),
          PageDecoration.buttonRow(label1: '清空', onPressed1: () { _inputController.clear(); _outputController.clear(); }, label2: widget.title, onPressed2: _isLoading ? null : _processText, isLoading: _isLoading),
          PageDecoration.divider(height: 16),
          PageDecoration.sectionTitle(context, '处理结果'),
          Expanded(child: TextField(controller: _outputController, maxLines: 0, readOnly: true, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '处理结果...'))),
          if (_outputController.text.isNotEmpty) ...[
            PageDecoration.divider(height: 8),
            PageDecoration.button(label: '复制结果', onPressed: () { Clipboard.setData(ClipboardData(text: _outputController.text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制'))); }, isOutlined: true),
          ],
        ],
      ),
    );
  }
}

/// AI 文风转换
class AIStyleTransferSheet extends StatefulWidget {
  const AIStyleTransferSheet({super.key});
  @override
  State<AIStyleTransferSheet> createState() => _AIStyleTransferSheetState();
}

class _AIStyleTransferSheetState extends State<AIStyleTransferSheet> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  String _targetStyle = '古风';
  bool _isLoading = false;
  final List<String> _styles = ['古风', '现代', '简约', '华丽', '幽默', '严肃', '浪漫', '悬疑'];

  @override
  void dispose() { _inputController.dispose(); _outputController.dispose(); super.dispose(); }

  Future<void> _transfer() async {
    if (_inputController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final response = await client.chat(messages: [LlmMessage.system('你是一个专业的小说写作助手。请将文字转换为$_targetStyle风格。'), LlmMessage.user(_inputController.text)], temperature: config.temperature);
      setState(() { _outputController.text = response.content; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('转换失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Text('文风转换', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Spacer(), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
          PageDecoration.divider(height: 16),
          PageDecoration.sectionTitle(context, '目标风格'),
          PageDecoration.choiceChipGrid(items: _styles, selectedItem: _targetStyle, onSelected: (v) => setState(() => _targetStyle = v)),
          PageDecoration.divider(height: 16),
          Expanded(child: PageDecoration.inputField(controller: _inputController, label: '输入内容', hint: '请输入要转换的内容...', maxLines: 0)),
          PageDecoration.divider(height: 16),
          PageDecoration.button(label: '转换为$_targetStyle', onPressed: _isLoading ? null : _transfer, isLoading: _isLoading),
          if (_outputController.text.isNotEmpty) ...[
            PageDecoration.divider(height: 16),
            PageDecoration.sectionTitle(context, '转换结果'),
            Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)), child: SingleChildScrollView(child: SelectableText(_outputController.text)))),
          ],
        ],
      ),
    );
  }
}

/// AI 写作建议屏幕
class AIWritingSuggestionsScreen extends StatefulWidget {
  const AIWritingSuggestionsScreen({super.key});
  @override
  State<AIWritingSuggestionsScreen> createState() => _AIWritingSuggestionsScreenState();
}

class _AIWritingSuggestionsScreenState extends State<AIWritingSuggestionsScreen> {
  final _contextController = TextEditingController();
  String? _selectedType;
  List<String> _suggestions = [];
  bool _isLoading = false;

  final Map<String, String> _types = {'情节': '请根据以下背景提供情节发展建议', '人物': '请根据以下设定提供人物发展建议', '场景': '请根据以下场景提供描写建议', '对话': '请根据以下情境提供对话建议', '冲突': '请根据以下背景提供冲突设计建议', '高潮': '请根据以下情节提供高潮设计建议'};

  @override
  void dispose() { _contextController.dispose(); super.dispose(); }

  Future<void> _generateSuggestions() async {
    if (_selectedType == null || _contextController.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择类型并输入背景'))); return; }
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final response = await client.chat(messages: [LlmMessage.system('你是一个专业的小说写作助手。请提供具体、有创意的写作建议。'), LlmMessage.user('${_types[_selectedType]}：\n\n${_contextController.text}')], temperature: config.temperature);
      setState(() { _suggestions = response.content.split('\n').where((s) => s.trim().isNotEmpty).toList(); _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(context: context, title: '写作建议', showBackButton: true, body: PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '建议类型'),
          PageDecoration.choiceChipGrid(items: _types.keys.toList(), selectedItem: _selectedType ?? '', onSelected: (v) => setState(() => _selectedType = v)),
          PageDecoration.divider(height: 16),
          PageDecoration.inputField(controller: _contextController, label: '背景描述', hint: '请描述你的写作背景...', maxLines: 5),
          PageDecoration.divider(height: 16),
          PageDecoration.button(label: '生成建议', onPressed: _isLoading ? null : _generateSuggestions, isLoading: _isLoading),
          if (_suggestions.isNotEmpty) ...[
            PageDecoration.divider(height: 24),
            ...List.generate(_suggestions.length, (i) => PageDecoration.card(child: ListTile(leading: CircleAvatar(child: Text('${i + 1}')), title: Text(_suggestions[i])))),
            PageDecoration.divider(height: 8),
            PageDecoration.button(label: '复制全部', onPressed: () { Clipboard.setData(ClipboardData(text: _suggestions.join('\n\n'))); }, isOutlined: true),
          ],
        ],
      ),
    ));
  }
}

/// AI 场景生成器
class AISceneGeneratorScreen extends StatefulWidget {
  const AISceneGeneratorScreen({super.key});
  @override
  State<AISceneGeneratorScreen> createState() => _AISceneGeneratorScreenState();
}

class _AISceneGeneratorScreenState extends State<AISceneGeneratorScreen> {
  final _settingController = TextEditingController();
  String _sceneType = '室内';
  String _mood = '平静';
  String? _result;
  bool _isLoading = false;

  final List<String> _sceneTypes = ['室内', '室外', '自然', '城市', '历史', '幻想'];
  final List<String> _moods = ['平静', '紧张', '温馨', '悲伤', '神秘', '激烈', '浪漫', '恐怖'];

  @override
  void dispose() { _settingController.dispose(); super.dispose(); }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final prompt = '生成一个$_mood氛围的$_sceneType场景描写${_settingController.text.isNotEmpty ? '\n\n设定：${_settingController.text}' : ''}';
      final response = await client.chat(messages: [LlmMessage.system('你是一个专业的小说场景描写助手。请生成生动、细节丰富的场景描写。'), LlmMessage.user(prompt)], temperature: config.temperature);
      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(context: context, title: '场景描写生成', showBackButton: true, body: PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '场景类型'),
          PageDecoration.choiceChipGrid(items: _sceneTypes, selectedItem: _sceneType, onSelected: (v) => setState(() => _sceneType = v)),
          PageDecoration.divider(height: 16),
          PageDecoration.sectionTitle(context, '氛围'),
          PageDecoration.choiceChipGrid(items: _moods, selectedItem: _mood, onSelected: (v) => setState(() => _mood = v)),
          PageDecoration.divider(height: 16),
          PageDecoration.inputField(controller: _settingController, label: '场景设定（可选）', hint: '描述你想要的具体场景...', maxLines: 3),
          PageDecoration.divider(height: 16),
          PageDecoration.button(label: '生成场景', onPressed: _isLoading ? null : _generate, isLoading: _isLoading),
          if (_result != null) ...[
            PageDecoration.divider(height: 24),
            PageDecoration.sectionTitle(context, '生成结果'),
            PageDecoration.card(child: SelectableText(_result!)),
          ],
        ],
      ),
    ));
  }
}

/// AI 对话生成器
class AIDialogGeneratorScreen extends StatefulWidget {
  const AIDialogGeneratorScreen({super.key});
  @override
  State<AIDialogGeneratorScreen> createState() => _AIDialogGeneratorScreenState();
}

class _AIDialogGeneratorScreenState extends State<AIDialogGeneratorScreen> {
  final _contextController = TextEditingController();
  final _char1Controller = TextEditingController(text: '角色A');
  final _char2Controller = TextEditingController(text: '角色B');
  String? _result;
  bool _isLoading = false;

  @override
  void dispose() { _contextController.dispose(); _char1Controller.dispose(); _char2Controller.dispose(); super.dispose(); }

  Future<void> _generate() async {
    if (_contextController.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入对话情境'))); return; }
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final response = await client.chat(messages: [LlmMessage.system('你是一个专业的小说对话助手。请生成自然、生动的人物对话。'), LlmMessage.user('${_char1Controller.text}和${_char2Controller.text}的对话\n\n情境：${_contextController.text}')], temperature: config.temperature);
      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(context: context, title: '人物对话生成', showBackButton: true, body: PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: PageDecoration.inputField(controller: _char1Controller, label: '角色1')), const SizedBox(width: 12), Expanded(child: PageDecoration.inputField(controller: _char2Controller, label: '角色2'))]),
          PageDecoration.divider(height: 16),
          PageDecoration.inputField(controller: _contextController, label: '对话情境', hint: '描述对话的背景和情境...', maxLines: 4),
          PageDecoration.divider(height: 16),
          PageDecoration.button(label: '生成对话', onPressed: _isLoading ? null : _generate, isLoading: _isLoading),
          if (_result != null) ...[PageDecoration.divider(height: 24), PageDecoration.card(child: SelectableText(_result!))],
        ],
      ),
    ));
  }
}

/// AI 大纲生成器
class AIOutlineGeneratorScreen extends StatefulWidget {
  const AIOutlineGeneratorScreen({super.key});
  @override
  State<AIOutlineGeneratorScreen> createState() => _AIOutlineGeneratorScreenState();
}

class _AIOutlineGeneratorScreenState extends State<AIOutlineGeneratorScreen> {
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  int _chapterCount = 10;
  String? _result;
  bool _isLoading = false;

  @override
  void dispose() { _titleController.dispose(); _genreController.dispose(); super.dispose(); }

  Future<void> _generate() async {
    if (_titleController.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入小说标题'))); return; }
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final response = await client.chat(messages: [LlmMessage.system('你是一个专业的小说大纲策划助手。请生成结构清晰、节奏合理的大纲。'), LlmMessage.user('小说《${_titleController.text}》，题材：${_genreController.text}，共$_chapterCount章')], temperature: config.temperature);
      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(context: context, title: '章节大纲生成', showBackButton: true, body: PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.inputField(controller: _titleController, label: '小说标题', hint: '输入小说标题'),
          PageDecoration.divider(height: 16),
          PageDecoration.inputField(controller: _genreController, label: '题材类型', hint: '如：仙侠、都市、悬疑'),
          PageDecoration.divider(height: 16),
          Row(children: [Text('章节数量：$_chapterCount', style: const TextStyle(fontWeight: FontWeight.w500)), Expanded(child: Slider(value: _chapterCount.toDouble(), min: 5, max: 50, divisions: 45, onChanged: (v) => setState(() => _chapterCount = v.round())))]),
          PageDecoration.divider(height: 16),
          PageDecoration.button(label: '生成大纲', onPressed: _isLoading ? null : _generate, isLoading: _isLoading),
          if (_result != null) ...[PageDecoration.divider(height: 24), PageDecoration.card(child: SelectableText(_result!))],
        ],
      ),
    ));
  }
}

/// AI 世界观设定
class AIWorldBuildingScreen extends StatefulWidget {
  const AIWorldBuildingScreen({super.key});
  @override
  State<AIWorldBuildingScreen> createState() => _AIWorldBuildingScreenState();
}

class _AIWorldBuildingScreenState extends State<AIWorldBuildingScreen> {
  final _typeController = TextEditingController();
  String _worldType = '仙侠';
  String? _result;
  bool _isLoading = false;
  final List<String> _worldTypes = ['仙侠', '都市', '玄幻', '科幻', '历史', '西幻', '现代'];

  @override
  void dispose() { _typeController.dispose(); super.dispose(); }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final prompt = '生成一个完整的$_worldType世界观设定，包括：地理环境、社会结构、修炼体系、文化习俗、历史背景、主要势力等${_typeController.text.isNotEmpty ? '\n\n特殊设定：${_typeController.text}' : ''}';
      final response = await client.chat(messages: [LlmMessage.system('你是一个专业的世界观设定助手。请生成完整、合理、有深度的世界观设定。'), LlmMessage.user(prompt)], temperature: config.temperature);
      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(context: context, title: '世界观设定', showBackButton: true, body: PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '世界观类型'),
          PageDecoration.choiceChipGrid(items: _worldTypes, selectedItem: _worldType, onSelected: (v) => setState(() => _worldType = v)),
          PageDecoration.divider(height: 16),
          PageDecoration.inputField(controller: _typeController, label: '额外设定（可选）', hint: '描述你想要的特殊设定...'),
          PageDecoration.divider(height: 16),
          PageDecoration.button(label: '生成世界观', onPressed: _isLoading ? null : _generate, isLoading: _isLoading),
          if (_result != null) ...[PageDecoration.divider(height: 24), PageDecoration.card(child: SelectableText(_result!))],
        ],
      ),
    ));
  }
}

/// AI 角色生成器
class AICharacterGeneratorScreen extends StatefulWidget {
  const AICharacterGeneratorScreen({super.key});
  @override
  State<AICharacterGeneratorScreen> createState() => _AICharacterGeneratorScreenState();
}

class _AICharacterGeneratorScreenState extends State<AICharacterGeneratorScreen> {
  final _baseController = TextEditingController();
  String _role = '主角';
  String? _result;
  bool _isLoading = false;
  final List<String> _roles = ['主角', '配角', '反派', '导师', '情人', '友人'];

  @override
  void dispose() { _baseController.dispose(); super.dispose(); }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final prompt = '为一个$_role生成完整的角色设定，包括：姓名、年龄、外貌、性格、背景故事、能力、人物关系、成长弧线等${_baseController.text.isNotEmpty ? '\n\n基础设定：${_baseController.text}' : ''}';
      final response = await client.chat(messages: [LlmMessage.system('你是一个专业的角色设定助手。请生成有深度、有特色的角色设定。'), LlmMessage.user(prompt)], temperature: config.temperature);
      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(context: context, title: '角色设定生成', showBackButton: true, body: PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '角色定位'),
          PageDecoration.choiceChipGrid(items: _roles, selectedItem: _role, onSelected: (v) => setState(() => _role = v)),
          PageDecoration.divider(height: 16),
          PageDecoration.inputField(controller: _baseController, label: '角色基础设定（可选）', hint: '描述角色的基本信息或特点...'),
          PageDecoration.divider(height: 16),
          PageDecoration.button(label: '生成角色', onPressed: _isLoading ? null : _generate, isLoading: _isLoading),
          if (_result != null) ...[PageDecoration.divider(height: 24), PageDecoration.card(child: SelectableText(_result!))],
        ],
      ),
    ));
  }
}

/// AI 灵感火花
class AIInspirationScreen extends StatefulWidget {
  const AIInspirationScreen({super.key});
  @override
  State<AIInspirationScreen> createState() => _AIInspirationScreenState();
}

class _AIInspirationScreenState extends State<AIInspirationScreen> {
  String _genre = '仙侠';
  String? _result;
  bool _isLoading = false;
  final List<String> _genres = ['仙侠', '都市', '玄幻', '科幻', '言情', '悬疑', '历史', '游戏'];

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);
      final response = await client.chat(messages: [LlmMessage.system('你是一个富有创意的写作灵感提供者。请提供有趣、独特、有创意的写作灵感。'), LlmMessage.user('请为$_genre题材提供一个创作灵感火花。')], temperature: config.temperature);
      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) { setState(() => _isLoading = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('获取失败: $e'))); }
  }

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(context: context, title: '灵感火花', showBackButton: true, body: PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '选择题材'),
          PageDecoration.choiceChipGrid(items: _genres, selectedItem: _genre, onSelected: (v) => setState(() => _genre = v)),
          PageDecoration.divider(height: 32),
          Center(child: FilledButton.icon(onPressed: _isLoading ? null : _generate, icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome), label: const Text('获取灵感'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)))),
          if (_result != null) ...[PageDecoration.divider(height: 32), PageDecoration.sectionTitle(context, '灵感内容'), PageDecoration.card(padding: const EdgeInsets.all(20), child: SelectableText(_result!, style: const TextStyle(fontSize: 16, height: 1.6)))],
        ],
      ),
    ));
  }
}

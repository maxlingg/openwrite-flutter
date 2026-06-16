import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/llm_client.dart';
import '../services/app_settings_service.dart';
import '../services/skill_service.dart';

/// AI 写作助手工具箱 - 完整的 AI 写作功能
class AIWritingToolsScreen extends StatefulWidget {
  const AIWritingToolsScreen({super.key});

  @override
  State<AIWritingToolsScreen> createState() => _AIWritingToolsScreenState();
}

class _AIWritingToolsScreenState extends State<AIWritingToolsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 写作助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showAISettings(context),
            tooltip: 'AI 设置',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 状态卡片
            _buildAIStatusCard(context),
            const SizedBox(height: 24),

            // 文段处理工具
            _buildSectionTitle(context, '✍️ 文段处理'),
            const SizedBox(height: 12),
            _buildToolsGrid(context, [
              _ToolItem(
                icon: Icons.text_fields,
                title: '扩写',
                description: '将简短内容扩展为详细描述',
                color: Colors.blue,
                onTap: () => _showTextTool(context, 'expand', '扩写'),
              ),
              _ToolItem(
                icon: Icons.compress,
                title: '缩写',
                description: '将冗长内容精简为核心要点',
                color: Colors.green,
                onTap: () => _showTextTool(context, 'condense', '缩写'),
              ),
              _ToolItem(
                icon: Icons.auto_fix_high,
                title: '润色',
                description: '优化语句，提升文字质量',
                color: Colors.purple,
                onTap: () => _showTextTool(context, 'polish', '润色'),
              ),
              _ToolItem(
                icon: Icons.translate,
                title: '文风转换',
                description: '改变文章风格和语气',
                color: Colors.orange,
                onTap: () => _showStyleTransfer(context),
              ),
            ]),
            const SizedBox(height: 24),

            // 创作辅助工具
            _buildSectionTitle(context, '🎨 创作辅助'),
            const SizedBox(height: 12),
            _buildToolsGrid(context, [
              _ToolItem(
                icon: Icons.lightbulb,
                title: '写作建议',
                description: '获取写作灵感和建议',
                color: Colors.amber,
                onTap: () => _showWritingSuggestions(context),
              ),
              _ToolItem(
                icon: Icons.analytics,
                title: '段落分析',
                description: '分析段落的优点和不足',
                color: Colors.teal,
                onTap: () => _showTextTool(context, 'analyze', '段落分析'),
              ),
              _ToolItem(
                icon: Icons.landscape,
                title: '场景描写',
                description: '生成生动的场景描写',
                color: Colors.indigo,
                onTap: () => _showSceneGenerator(context),
              ),
              _ToolItem(
                icon: Icons.record_voice_over,
                title: '人物对话',
                description: '生成自然的人物对话',
                color: Colors.pink,
                onTap: () => _showDialogGenerator(context),
              ),
            ]),
            const SizedBox(height: 24),

            // 故事构思工具
            _buildSectionTitle(context, '📚 故事构思'),
            const SizedBox(height: 12),
            _buildToolsGrid(context, [
              _ToolItem(
                icon: Icons.account_tree,
                title: '大纲生成',
                description: '生成章节大纲和结构',
                color: Colors.brown,
                onTap: () => _showOutlineGenerator(context),
              ),
              _ToolItem(
                icon: Icons.public,
                title: '世界观设定',
                description: '创建完整的世界观',
                color: Colors.cyan,
                onTap: () => _showWorldBuilding(context),
              ),
              _ToolItem(
                icon: Icons.person,
                title: '角色设定',
                description: '生成角色背景和性格',
                color: Colors.deepPurple,
                onTap: () => _showCharacterGenerator(context),
              ),
              _ToolItem(
                icon: Icons.flash_on,
                title: '灵感火花',
                description: '随机获取创作灵感',
                color: Colors.red,
                onTap: () => _showInspiration(context),
              ),
            ]),
            const SizedBox(height: 24),

            // AI 对话入口
            _buildSectionTitle(context, '💬 AI 对话'),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.chat, color: colorScheme.onPrimaryContainer),
                ),
                title: const Text('AI 写作助手'),
                subtitle: const Text('与 AI 进行创作对话'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openAIChat(context),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAIStatusCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isConnected = LlmClient.globalConfigured;

    return Card(
      color: isConnected ? colorScheme.primaryContainer : colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isConnected ? Icons.cloud_done : Icons.cloud_off,
              size: 32,
              color: isConnected ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'AI 服务已连接' : 'AI 服务未配置',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isConnected ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                    ),
                  ),
                  Text(
                    isConnected ? '可以开始使用 AI 写作功能' : '请先配置 AI 服务',
                    style: TextStyle(
                      fontSize: 12,
                      color: isConnected ? colorScheme.onPrimaryContainer.withOpacity(0.8) : colorScheme.onErrorContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (!isConnected)
              TextButton(
                onPressed: () => _showAISettings(context),
                child: Text(
                  '去设置',
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
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
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  item.description,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAISettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AISettingsSheet(),
    );
  }

  void _showTextTool(BuildContext context, String type, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AITextToolSheet(type: type, title: title),
    );
  }

  void _showStyleTransfer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AIStyleTransferSheet(),
    );
  }

  void _showWritingSuggestions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIWritingSuggestionsScreen()),
    );
  }

  void _showSceneGenerator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AISceneGeneratorScreen()),
    );
  }

  void _showDialogGenerator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIDialogGeneratorScreen()),
    );
  }

  void _showOutlineGenerator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIOutlineGeneratorScreen()),
    );
  }

  void _showWorldBuilding(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIWorldBuildingScreen()),
    );
  }

  void _showCharacterGenerator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AICharacterGeneratorScreen()),
    );
  }

  void _showInspiration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIInspirationScreen()),
    );
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

  _ToolItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
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
    'OpenAI': {
      'url': 'https://api.openai.com/v1',
      'models': 'gpt-4o,gpt-4o-mini,gpt-4-turbo,gpt-3.5-turbo',
    },
    'Kilo AI': {
      'url': 'https://api.kilo.ai/api',
      'models': 'meta-llama/Llama-3-70b-chat-hf,meta-llama/Llama-3-8b-chat-hf',
    },
    'OpenRouter': {
      'url': 'https://openrouter.ai/api/v1',
      'models': 'anthropic/claude-3.5-sonnet,google/gemini-pro,openai/gpt-4o',
    },
    'Claude (Anthropic)': {
      'url': 'https://api.anthropic.com',
      'models': 'claude-3-5-sonnet-20240620,claude-3-opus-20240229,claude-3-sonnet-20240229',
    },
    '自定义': {
      'url': '',
      'models': '',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

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
      if (!_availableModels.contains(_model)) {
        _model = _availableModels.isNotEmpty ? _availableModels[0] : '';
      }
    } else {
      _availableModels = [];
    }
  }

  String _getProviderFromUrl(String url) {
    if (url.contains('openai.com')) return 'OpenAI';
    if (url.contains('kilo.ai')) return 'Kilo AI';
    if (url.contains('openrouter')) return 'OpenRouter';
    if (url.contains('anthropic')) return 'Claude (Anthropic)';
    return 'OpenAI';
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  /// 从 API 获取可用模型列表
  Future<void> _fetchModels() async {
    final apiUrl = _apiUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (apiUrl.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入 API 地址和密钥')),
      );
      return;
    }

    setState(() => _isLoadingModels = true);

    try {
      final client = LlmClient(baseUrl: apiUrl, apiKey: apiKey, model: '');
      final models = await client.fetchModels();
      
      setState(() {
        _availableModels = models;
        _isLoadingModels = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取到 ${models.length} 个模型')),
        );
      }
    } catch (e) {
      setState(() => _isLoadingModels = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取模型失败: $e')),
        );
      }
    }
  }

  /// 测试连接
  Future<void> _testConnection() async {
    final apiUrl = _apiUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (apiUrl.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入 API 地址和密钥')),
      );
      return;
    }

    setState(() => _isTesting = true);

    try {
      final client = LlmClient(baseUrl: apiUrl, apiKey: apiKey, model: _model);
      await client.testConnection();
      
      setState(() => _isTesting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('连接成功！')),
        );
      }
    } catch (e) {
      setState(() => _isTesting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('连接失败: $e')),
        );
      }
    }
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
            Row(
              children: [
                const Text('AI 设置', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),

            // 服务商预设
            const Text('服务商预设', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.keys.map((name) {
                final isSelected = _selectedProvider == name;
                return ChoiceChip(
                  label: Text(name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedProvider = name;
                        if (name != '自定义') {
                          _apiUrlController.text = _presets[name]!['url']!;
                        }
                        _updateModelsFromPreset();
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // API 地址
            Row(
              children: [
                const Text('API 地址', style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                if (_selectedProvider != '自定义')
                  Text(
                    _presets[_selectedProvider]!['url']!,
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiUrlController,
              enabled: _selectedProvider == '自定义',
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'https://api.openai.com/v1',
                suffixIcon: _selectedProvider == '自定义'
                    ? null
                    : Icon(Icons.lock, color: colorScheme.outline, size: 18),
              ),
              onChanged: (_) => setState(() => _selectedProvider = '自定义'),
            ),
            const SizedBox(height: 16),

            // API 密钥
            const Text('API 密钥', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'sk-...',
              ),
            ),
            const SizedBox(height: 16),

            // 获取模型按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingModels ? null : _fetchModels,
                icon: _isLoadingModels
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: Text(_isLoadingModels ? '获取中...' : '获取可用模型'),
              ),
            ),
            const SizedBox(height: 16),

            // 模型选择
            const Text('选择模型', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            if (_availableModels.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '点击上方按钮获取可用模型',
                  style: TextStyle(color: colorScheme.outline),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableModels.length,
                  itemBuilder: (context, index) {
                    final model = _availableModels[index];
                    return RadioListTile<String>(
                      title: Text(model, style: const TextStyle(fontSize: 13)),
                      value: model,
                      groupValue: _model,
                      onChanged: (v) => setState(() => _model = v!),
                      dense: true,
                    );
                  },
                ),
              ),
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
            const SizedBox(height: 8),
            Text(
              'Temperature 控制输出的随机性。较低值（如 0.2）产生更确定的回答，较高值（如 1.0）产生更有创意的回答。',
              style: TextStyle(fontSize: 11, color: colorScheme.outline),
            ),
            const SizedBox(height: 20),

            // 测试连接按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.wifi_tethering),
                label: Text(_isTesting ? '测试中...' : '测试连接'),
              ),
            ),
            const SizedBox(height: 12),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveSettings,
                child: const Text('保存设置'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final apiUrl = _apiUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (apiUrl.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入 API 地址和密钥')),
      );
      return;
    }

    if (_model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择或获取模型')),
      );
      return;
    }

    final settings = await AppSettingsService.create();
    final config = LlmConfig(
      baseUrl: apiUrl,
      apiKey: apiKey,
      model: _model,
      temperature: _temperature,
    );
    await settings.updateLlmConfig(config);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI 设置已保存')));
    }
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
      case 'expand':
        return '你是一个专业的小说写作助手。请将用户提供的简短内容扩展为详细、生动的描写，保持原文的核心思想和风格，增加更多细节、场景描写和情感表达。';
      case 'condense':
        return '你是一个专业的小说写作助手。请将用户提供的冗长内容精简为核心要点，保持最重要的信息，去除冗余表达，使内容更加简洁有力。';
      case 'polish':
        return '你是一个专业的小说写作助手。请优化用户提供的文字，提升语句流畅度、表达准确性和文字美感，同时保持原文的风格和意图。';
      case 'analyze':
        return '你是一个专业的小说写作助手。请分析用户提供的段落，指出其优点（如文笔、结构、情感表达等）和不足（如冗余、表达不清等），并给出具体的改进建议。';
      default:
        return '你是一个专业的小说写作助手。';
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),

          // 输入区域
          const Text('输入内容', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '请输入要处理的内容...',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _inputController.clear();
                    _outputController.clear();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('清空'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _processText,
                  icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_fix_high),
                  label: Text(widget.title),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 输出区域
          const Text('处理结果', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _outputController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '处理结果将显示在这里...',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 复制按钮
          if (_outputController.text.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _outputController.text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                },
                icon: const Icon(Icons.copy),
                label: const Text('复制结果'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _processText() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入内容')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      
      if (!config.isConfigured) {
        throw Exception('请先配置 AI');
      }

      final client = LlmClient(
        baseUrl: config.baseUrl,
        apiKey: config.apiKey,
        model: config.model,
      );

      final response = await client.chat(
        messages: [
          LlmMessage.system(_systemPrompt),
          LlmMessage.user(input),
        ],
        temperature: config.temperature,
      );

      setState(() {
        _outputController.text = response.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('处理失败: $e')));
      }
    }
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
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('文风转换', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),

          // 目标风格选择
          const Text('目标风格', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _styles.map((s) {
              final isSelected = _targetStyle == s;
              return ChoiceChip(
                label: Text(s),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _targetStyle = s);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 输入
          const Text('输入内容', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '请输入要转换的内容...'),
            ),
          ),
          const SizedBox(height: 16),

          // 按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _transfer,
              icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.translate),
              label: Text('转换为$_targetStyle'),
            ),
          ),
          const SizedBox(height: 16),

          // 输出
          if (_outputController.text.isNotEmpty) ...[
            const Text('转换结果', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(child: SelectableText(_outputController.text)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _transfer() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);

      final response = await client.chat(
        messages: [
          LlmMessage.system('你是一个专业的小说写作助手。请将用户提供的文字转换为$_targetStyle风格，保持原文的核心内容，但改变表达方式、词汇和语气，使其符合$_targetStyle的特点。'),
          LlmMessage.user(input),
        ],
        temperature: config.temperature,
      );

      setState(() {
        _outputController.text = response.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('转换失败: $e')));
    }
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

  final Map<String, String> _types = {
    '情节': '请根据以下背景提供3-5个情节发展建议：',
    '人物': '请根据以下设定提供3-5个人物发展建议：',
    '场景': '请根据以下场景提供3-5个场景描写建议：',
    '对话': '请根据以下情境提供3-5个对话建议：',
    '冲突': '请根据以下背景提供3-5个冲突设计建议：',
    '高潮': '请根据以下情节提供3-5个高潮设计建议：',
  };

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('写作建议')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 类型选择
            const Text('建议类型', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.keys.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedType = selected ? type : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 背景描述
            const Text('背景描述', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _contextController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '请描述你的写作背景、设定或当前遇到的问题...',
              ),
            ),
            const SizedBox(height: 20),

            // 生成按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _generateSuggestions,
                icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lightbulb),
                label: const Text('生成建议'),
              ),
            ),
            const SizedBox(height: 24),

            // 建议列表
            if (_suggestions.isNotEmpty) ...[
              const Text('建议列表', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...List.generate(_suggestions.length, (i) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(_suggestions[i]),
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _suggestions.join('\n\n')));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制')));
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('复制全部建议'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateSuggestions() async {
    if (_selectedType == null || _contextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择类型并输入背景')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);

      final prompt = _types[_selectedType]! + '\n\n' + _contextController.text;

      final response = await client.chat(
        messages: [
          LlmMessage.system('你是一个专业的小说写作助手。请提供具体、有创意的写作建议，每条建议用数字编号，简洁明了。'),
          LlmMessage.user(prompt),
        ],
        temperature: config.temperature,
      );

      setState(() {
        _suggestions = response.content.split('\n').where((s) => s.trim().isNotEmpty).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
    }
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
  void dispose() {
    _settingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('场景描写生成')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('场景类型', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _sceneTypes.map((s) => ChoiceChip(label: Text(s), selected: _sceneType == s, onSelected: (v) { if (v) setState(() => _sceneType = s); })).toList()),
            const SizedBox(height: 16),
            const Text('氛围', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _moods.map((m) => ChoiceChip(label: Text(m), selected: _mood == m, onSelected: (v) { if (v) setState(() => _mood = m); })).toList()),
            const SizedBox(height: 16),
            const Text('场景设定（可选）', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _settingController, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '描述你想要的具体场景设定...')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isLoading ? null : _generate, icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.landscape), label: const Text('生成场景'))),
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Text('生成结果', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: SelectableText(_result!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);

      final prompt = '生成一个$_mood氛围的$_sceneType场景描写${_settingController.text.isNotEmpty ? '\n\n设定：${_settingController.text}' : ''}';

      final response = await client.chat(
        messages: [
          LlmMessage.system('你是一个专业的小说场景描写助手。请生成生动、细节丰富的场景描写，包括环境、声音，光线，气味等感官细节。'),
          LlmMessage.user(prompt),
        ],
        temperature: config.temperature,
      );

      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
    }
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
  void dispose() {
    _contextController.dispose();
    _char1Controller.dispose();
    _char2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('人物对话生成')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: TextField(controller: _char1Controller, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '角色1'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _char2Controller, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '角色2'))),
            ]),
            const SizedBox(height: 16),
            const Text('对话情境', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _contextController, maxLines: 4, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '描述对话的背景、情境和目的...')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isLoading ? null : _generate, icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.record_voice_over), label: const Text('生成对话'))),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: SelectableText(_result!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    if (_contextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入对话情境')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);

      final response = await client.chat(
        messages: [
          LlmMessage.system('你是一个专业的小说对话助手。请生成自然、生动的人物对话，用「角色名：对话内容」的格式。'),
          LlmMessage.user('${_char1Controller.text}和${_char2Controller.text}的对话\n\n情境：${_contextController.text}'),
        ],
        temperature: config.temperature,
      );

      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
    }
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
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('章节大纲生成')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '小说标题', hintText: '输入小说标题')),
            const SizedBox(height: 16),
            TextField(controller: _genreController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '题材类型', hintText: '如：仙侠、都市、悬疑')),
            const SizedBox(height: 16),
            Row(children: [
              Text('章节数量：$_chapterCount', style: const TextStyle(fontWeight: FontWeight.w500)),
              Expanded(child: Slider(value: _chapterCount.toDouble(), min: 5, max: 50, divisions: 45, onChanged: (v) => setState(() => _chapterCount = v.round()))),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isLoading ? null : _generate, icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.account_tree), label: const Text('生成大纲'))),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: SelectableText(_result!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入小说标题')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);

      final response = await client.chat(
        messages: [
          LlmMessage.system('你是一个专业的小说大纲策划助手。请为小说生成结构清晰、节奏合理的大纲，包括章节标题和简要内容概述。'),
          LlmMessage.user('小说《${_titleController.text}》，题材：${_genreController.text}，共$_chapterCount章'),
        ],
        temperature: config.temperature,
      );

      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
    }
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
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('世界观设定')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('世界观类型', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _worldTypes.map((w) => ChoiceChip(label: Text(w), selected: _worldType == w, onSelected: (v) { if (v) setState(() => _worldType = w); })).toList()),
            const SizedBox(height: 16),
            TextField(controller: _typeController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '额外设定（可选）', hintText: '描述你想要的特殊设定...')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isLoading ? null : _generate, icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.public), label: const Text('生成世界观'))),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: SelectableText(_result!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);

      final prompt = '生成一个完整的$_worldType世界观设定，包括：地理环境、社会结构、修炼体系/科技水平、文化习俗、历史背景、主要势力等${_typeController.text.isNotEmpty ? '\n\n特殊设定：${_typeController.text}' : ''}';

      final response = await client.chat(
        messages: [
          LlmMessage.system('你是一个专业的世界观设定助手。请生成完整、合理、有深度的世界观设定。'),
          LlmMessage.user(prompt),
        ],
        temperature: config.temperature,
      );

      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
    }
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
  void dispose() {
    _baseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('角色设定生成')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('角色定位', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _roles.map((r) => ChoiceChip(label: Text(r), selected: _role == r, onSelected: (v) { if (v) setState(() => _role = r); })).toList()),
            const SizedBox(height: 16),
            TextField(controller: _baseController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: '角色基础设定', hintText: '描述角色的基本信息或你想要的特点...')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _isLoading ? null : _generate, icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.person), label: const Text('生成角色'))),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: SelectableText(_result!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);

      final prompt = '为一个$_role生成完整的角色设定，包括：姓名、年龄、外貌、性格背景故事、能力/特长、人物关系、成长弧线等${_baseController.text.isNotEmpty ? '\n\n基础设定：${_baseController.text}' : ''}';

      final response = await client.chat(
        messages: [
          LlmMessage.system('你是一个专业的角色设定助手。请生成有深度、有特色的角色设定。'),
          LlmMessage.user(prompt),
        ],
        temperature: config.temperature,
      );

      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('灵感火花')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择题材', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _genres.map((g) => ChoiceChip(label: Text(g), selected: _genre == g, onSelected: (v) { if (v) setState(() => _genre = g); })).toList()),
            const SizedBox(height: 32),
            Center(
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _generate,
                icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                label: const Text('获取灵感'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 32),
              const Text('灵感内容', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(_result!, style: const TextStyle(fontSize: 16, height: 1.6)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    try {
      final settings = await AppSettingsService.create();
      final config = settings.llmConfig;
      final client = LlmClient(baseUrl: config.baseUrl, apiKey: config.apiKey, model: config.model);

      final response = await client.chat(
        messages: [
          LlmMessage.system('你是一个富有创意的写作灵感提供者。请提供有趣、独特、有创意的写作灵感，可以是情节构思、人物设定、世界观碎片等。'),
          LlmMessage.user('请为$_genre题材提供一个创作灵感火花，可以是一个独特的情节、一个有趣的人物设定，或是一个吸引人的世界观碎片。'),
        ],
        temperature: config.temperature,
      );

      setState(() { _result = response.content; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('获取失败: $e')));
    }
  }
}

import 'package:flutter/material.dart';
import '../services/llm_client.dart';
import '../services/skill_service.dart';
import '../services/app_settings_service.dart';

/// AI 文段处理类型
enum DistillType {
  expand('扩写', '将简短的段落扩展为详细的场景描写，增加细节和氛围'),
  summarize('缩写', '将冗长的内容精简为核心要点'),
  polish('润色', '改善文字表达，使其更流畅优美'),
  rewrite('改写', '用不同方式表达相同意思'),
  continueWrite('续写', '延续现有情节继续创作'),
  translate('翻译', '将内容翻译为其他语言'),
  proofread('校对', '检查并修正语法、拼写错误');

  final String label;
  final String description;
  const DistillType(this.label, this.description);
}

/// AI 文段处理对话框
class DistillDialog extends StatefulWidget {
  final String initialText;
  final LlmClient? client;
  final LlmConfig? llmConfig;
  final Function(String result)? onComplete;

  const DistillDialog({
    super.key,
    this.initialText = '',
    this.client,
    this.llmConfig,
    this.onComplete,
  });

  @override
  State<DistillDialog> createState() => _DistillDialogState();
}

class _DistillDialogState extends State<DistillDialog> {
  late TextEditingController _inputController;
  late TextEditingController _outputController;
  DistillType _selectedType = DistillType.expand;
  bool _isProcessing = false;
  String? _error;
  
  // 技能选择
  Skill? _selectedSkill;
  final SkillService _skillService = SkillService('');

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.initialText);
    _outputController = TextEditingController();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    await _skillService.loadInstalledSkills();
    // 默认选择文笔提升技能（润色类）
    final polishSkill = _skillService.allAvailableSkills
        .where((s) => s.type == SkillType.polish && s.isInstalled)
        .firstOrNull;
    if (polishSkill != null) {
      setState(() => _selectedSkill = polishSkill);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    if (_inputController.text.trim().isEmpty) {
      setState(() => _error = '请输入要处理的内容');
      return;
    }

    final config = widget.llmConfig ?? LlmConfig();
    if (config.apiKey.isEmpty) {
      setState(() => _error = '请先在设置中配置 API Key');
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final client = widget.client ?? LlmClient(
        baseUrl: config.baseUrl,
        apiKey: config.apiKey,
        model: config.model,
      );

      final prompt = _buildPrompt(_inputController.text.trim());
      final messages = [
        LlmMessage(role: 'system', content: _buildSystemPrompt()),
        LlmMessage(role: 'user', content: prompt),
      ];

      final response = await client.chat(
        messages: messages,
        temperature: config.temperature,
        maxTokens: config.maxTokens,
      );

      setState(() {
        _outputController.text = response.content;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
    }
  }

  String _buildSystemPrompt() {
    // 如果选择了技能，使用技能的 distillPrompt
    if (_selectedSkill != null && _selectedSkill!.distillPrompt != null) {
      return _selectedSkill!.distillPrompt!;
    }
    
    // 默认提示词
    return '''你是一个专业的小说写作助手。请根据用户选择的操作类型，对提供的文本进行处理。

处理类型包括：
- 扩写：增加细节、场景描写、人物心理
- 缩写：提取核心要点，精简表达
- 润色：改善句式、用词、节奏
- 改写：保持原意，改变表达方式
- 续写：延续原文风格和情节
- 翻译：准确翻译，保持风格
- 校对：修正语法、拼写错误

请只输出处理后的文本，不要添加任何解释。''';
  }

  String _buildPrompt(String text) {
    return '【${_selectedType.label}】\n\n原文：\n$text';
  }

  void _copyResult() {
    if (_outputController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  void _applyResult() {
    if (_outputController.text.isNotEmpty && widget.onComplete != null) {
      widget.onComplete!(_outputController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_fix_high, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    'AI 文段处理',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 技能选择
                    Row(
                      children: [
                        const Text('使用技能：', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<Skill?>(
                            value: _selectedSkill,
                            isExpanded: true,
                            hint: const Text('选择技能'),
                            items: [
                              const DropdownMenuItem<Skill?>(
                                value: null,
                                child: Text('默认'),
                              ),
                              ..._skillService.allAvailableSkills
                                  .where((s) => s.isInstalled || s.isBuiltIn)
                                  .map((skill) {
                                return DropdownMenuItem(
                                  value: skill,
                                  child: Row(
                                    children: [
                                      Text(skill.icon),
                                      const SizedBox(width: 8),
                                      Text(skill.name),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (skill) => setState(() => _selectedSkill = skill),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 处理类型选择
                    const Text('处理类型', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DistillType.values.map((type) {
                        return ChoiceChip(
                          label: Text(type.label),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedType = type);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedType.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 输入框
                    const Text('原文', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: '输入要处理的内容...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),

                    const SizedBox(height: 16),

                    // 处理按钮
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isProcessing ? null : _process,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_fix_high),
                        label: Text(_isProcessing ? '处理中...' : '开始处理'),
                      ),
                    ),

                    // 错误提示
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 输出框
                    if (_outputController.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('处理结果', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _copyResult,
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('复制'),
                          ),
                          TextButton.icon(
                            onPressed: _applyResult,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('应用'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(minHeight: 100),
                        child: SelectableText(_outputController.text),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示文段处理对话框的便捷函数
Future<String?> showDistillDialog(
  BuildContext context, {
  String initialText = '',
  LlmClient? client,
  LlmConfig? llmConfig,
}) async {
  String? result;
  
  await showDialog(
    context: context,
    builder: (context) => DistillDialog(
      initialText: initialText,
      client: client,
      llmConfig: llmConfig,
      onComplete: (r) => result = r,
    ),
  );
  
  return result;
}

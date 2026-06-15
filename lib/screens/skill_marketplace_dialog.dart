import 'package:flutter/material.dart';

/// 技能/模板数据
class Skill {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isInstalled;
  final String? category;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isInstalled = false,
    this.category,
  });
}

/// 技能市场
class SkillMarketplaceDialog extends StatefulWidget {
  final Function(Skill)? onInstall;

  const SkillMarketplaceDialog({
    super.key,
    this.onInstall,
  });

  @override
  State<SkillMarketplaceDialog> createState() => _SkillMarketplaceDialogState();
}

class _SkillMarketplaceDialogState extends State<SkillMarketplaceDialog> {
  String _selectedCategory = '全部';
  bool _isLoading = false;

  final List<Skill> _skills = [
    const Skill(
      id: 'xianxia_writer',
      name: '仙侠小说助手',
      description: '专为仙侠小说创作设计的 AI 技能，包含修仙体系、功法境界等素材库',
      icon: '🌸',
      category: '小说',
    ),
    const Skill(
      id: 'modern_novel',
      name: '都市小说助手',
      description: '现代都市背景的小说创作技能，包含职场、商战、豪门等题材模板',
      icon: '🏙️',
      category: '小说',
    ),
    const Skill(
      id: 'plot_generator',
      name: '情节生成器',
      description: '自动生成小说情节大纲，支持多种叙事结构',
      icon: '📖',
      category: '工具',
    ),
    const Skill(
      id: 'character_builder',
      name: '人物设定助手',
      description: '快速创建立体的角色形象，包含性格、外貌、背景等',
      icon: '👤',
      category: '工具',
    ),
    const Skill(
      id: 'dialogue_writer',
      name: '对话润色',
      description: '优化角色对话，使对话更自然、符合人物性格',
      icon: '💬',
      category: '润色',
    ),
    const Skill(
      id: 'scene_describer',
      name: '场景描写',
      description: '增强场景描写的细节和氛围感',
      icon: '🎨',
      category: '润色',
    ),
  ];

  List<String> get _categories {
    final cats = _skills.map((s) => s.category ?? '').where((c) => c.isNotEmpty).toSet().toList();
    return ['全部', ...cats];
  }

  List<Skill> get _filteredSkills {
    if (_selectedCategory == '全部') return _skills;
    return _skills.where((s) => s.category == _selectedCategory).toList();
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
                  Icon(Icons.store, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    '技能市场',
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

            // 分类标签
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // 技能列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredSkills.length,
                      itemBuilder: (context, index) {
                        final skill = _filteredSkills[index];
                        return _buildSkillCard(skill);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard(Skill skill) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  skill.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (skill.category != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        skill.category!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 操作
            const SizedBox(width: 8),
            if (skill.isInstalled)
              OutlinedButton(
                onPressed: null,
                child: const Text('已安装'),
              )
            else
              FilledButton(
                onPressed: () {
                  widget.onInstall?.call(skill);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${skill.name} 安装成功')),
                  );
                },
                child: const Text('安装'),
              ),
          ],
        ),
      ),
    );
  }
}

/// 显示技能市场对话框的便捷函数
Future<void> showSkillMarketplaceDialog(
  BuildContext context, {
  Function(Skill)? onInstall,
}) async {
  await showDialog(
    context: context,
    builder: (context) => SkillMarketplaceDialog(
      onInstall: onInstall,
    ),
  );
}

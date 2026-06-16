import 'package:flutter/material.dart';
import '../services/skill_service.dart';

/// 技能市场页面
class SkillMarketplaceScreen extends StatefulWidget {
  final Function(Skill)? onSkillSelected;
  final Function(Skill)? onInstall;
  final Function(String)? onUninstall;

  const SkillMarketplaceScreen({
    super.key,
    this.onSkillSelected,
    this.onInstall,
    this.onUninstall,
  });

  @override
  State<SkillMarketplaceScreen> createState() => _SkillMarketplaceScreenState();
}

class _SkillMarketplaceScreenState extends State<SkillMarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final SkillService _skillService = SkillService('');
  
  String _selectedCategory = '全部';
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSkills();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);
    await _skillService.loadInstalledSkills();
    setState(() => _isLoading = false);
  }

  List<Skill> get _filteredSkills {
    var skills = _skillService.allAvailableSkills;
    
    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      skills = _skillService.searchSkills(_searchQuery);
    }
    
    // 分类过滤
    if (_selectedCategory != '全部') {
      skills = skills.where((s) => s.category == _selectedCategory).toList();
    }
    
    return skills;
  }

  List<Skill> get _installedSkills {
    return _skillService.allAvailableSkills
        .where((s) => s.isInstalled)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('技能市场'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '发现'),
            Tab(text: '我的技能'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSkills,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索技能...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // 分类选择
          if (_tabController.index == 0)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _skillService.categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 8),

          // 技能列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDiscoverTab(),
                      _buildMySkillsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    final skills = _filteredSkills;
    
    if (skills.isEmpty) {
      return _buildEmptyState('未找到相关技能');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        return _buildSkillCard(skills[index]);
      },
    );
  }

  Widget _buildMySkillsTab() {
    final skills = _installedSkills;
    
    if (skills.isEmpty) {
      return _buildEmptyState('暂无已安装的技能\n去发现页面安装更多技能吧');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        return _buildSkillCard(skills[index], showManage: true);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(Skill skill, {bool showManage = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSkillDetail(skill),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const SizedBox(width: 12),

                  // 信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                skill.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (skill.isBuiltIn)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '内置',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                skill.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.download,
                              size: 12,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${skill.downloads}',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              skill.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 描述
              Text(
                skill.description,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 标签
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: skill.tags.take(4).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showManage) ...[
                    TextButton(
                      onPressed: () => _uninstallSkill(skill),
                      child: const Text('卸载'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!showManage && !skill.isInstalled)
                    FilledButton(
                      onPressed: () => _installSkill(skill),
                      child: const Text('安装'),
                    ),
                  if (!showManage && skill.isInstalled)
                    OutlinedButton(
                      onPressed: null,
                      child: const Text('已安装'),
                    ),
                  if (showManage || skill.isInstalled)
                    FilledButton(
                      onPressed: () => _useSkill(skill),
                      child: const Text('使用'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSkillDetail(Skill skill) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖动条
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 内容
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // 头部
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              skill.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                skill.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '作者: ${skill.author}',
                                style: TextStyle(color: colorScheme.outline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 统计
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('下载', '${skill.downloads}'),
                        _buildStat('评分', skill.rating.toStringAsFixed(1)),
                        _buildStat('类型', skill.type.label),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 描述
                    Text(
                      '简介',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(skill.description),

                    const SizedBox(height: 20),

                    // 系统提示词
                    Text(
                      '系统提示词',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        skill.systemPrompt,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 标签
                    Text(
                      '标签',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skill.tags.map((tag) {
                        return Chip(label: Text(tag));
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // 操作按钮
                    Row(
                      children: [
                        if (!skill.isInstalled)
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                _installSkill(skill);
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('安装技能'),
                            ),
                          ),
                        if (skill.isInstalled)
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _useSkill(skill);
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('使用技能'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Future<void> _installSkill(Skill skill) async {
    await _skillService.installSkill(skill);
    setState(() {});
    widget.onInstall?.call(skill);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${skill.name} 安装成功')),
      );
    }
  }

  Future<void> _uninstallSkill(Skill skill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('卸载技能'),
        content: Text('确定要卸载「${skill.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('卸载'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _skillService.uninstallSkill(skill.id);
      setState(() {});
      widget.onUninstall?.call(skill.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${skill.name} 已卸载')),
        );
      }
    }
  }

  void _useSkill(Skill skill) {
    widget.onSkillSelected?.call(skill);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已切换到「${skill.name}」')),
      );
    }
  }
}

/// 显示技能市场的便捷函数
Future<void> showSkillMarketplace(
  BuildContext context, {
  Function(Skill)? onSkillSelected,
  Function(Skill)? onInstall,
  Function(String)? onUninstall,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SkillMarketplaceScreen(
        onSkillSelected: onSkillSelected,
        onInstall: onInstall,
        onUninstall: onUninstall,
      ),
    ),
  );
}

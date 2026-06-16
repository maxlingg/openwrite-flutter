import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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

  List<Skill> get _createdSkills {
    return _skillService.allAvailableSkills
        .where((s) => s.isCreated)
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
            Tab(text: '创建技能'),
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
                      _buildCreateSkillTab(),
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

  Widget _buildCreateSkillTab() {
    final createdSkills = _createdSkills;
    
    return Column(
      children: [
        // 创建新技能按钮
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showCreateSkillDialog,
              icon: const Icon(Icons.add),
              label: const Text('创建新技能'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ),

        // 技能导入/导出说明
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '技能导入/导出',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• 导出自定义技能后可分享给其他用户\n'
                    '• 导入技能文件 (.json) 即可使用\n'
                    '• 点击技能卡片上的按钮进行操作',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importSkill,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('导入技能'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showExportAllDialog,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('导出全部'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 已创建的技能列表
        if (createdSkills.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '已创建的技能 (${createdSkills.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: createdSkills.length,
              itemBuilder: (context, index) {
                return _buildCreatedSkillCard(createdSkills[index]);
              },
            ),
          ),
        ] else
          Expanded(
            child: _buildEmptyState('暂无创建的技能\n点击上方按钮创建你的第一个技能'),
          ),
      ],
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
                            if (skill.isCreated)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '自创',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onPrimaryContainer,
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
              const SizedBox(height: 12),

              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showManage && !skill.isBuiltIn) ...[
                    TextButton(
                      onPressed: () => _editSkill(skill),
                      child: const Text('编辑'),
                    ),
                    TextButton(
                      onPressed: () => _exportSkill(skill),
                      child: const Text('导出'),
                    ),
                    TextButton(
                      onPressed: () => _uninstallSkill(skill),
                      child: const Text('删除'),
                    ),
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

  Widget _buildCreatedSkillCard(Skill skill) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(skill.icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(skill.name),
        subtitle: Text(skill.category, style: const TextStyle(fontSize: 12)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editSkill(skill);
                break;
              case 'export':
                _exportSkill(skill);
                break;
              case 'use':
                _useSkill(skill);
                break;
              case 'delete':
                _deleteCreatedSkill(skill);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'use', child: Text('使用')),
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            const PopupMenuItem(value: 'export', child: Text('导出')),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
        onTap: () => _useSkill(skill),
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

  /// 显示创建技能对话框
  void _showCreateSkillDialog([Skill? existingSkill]) {
    showDialog(
      context: context,
      builder: (context) => _CreateSkillDialog(
        skillService: _skillService,
        existingSkill: existingSkill,
        onSaved: () {
          _loadSkills();
          _tabController.animateTo(2); // 切换到创建技能标签
        },
      ),
    );
  }

  /// 编辑技能
  void _editSkill(Skill skill) {
    _showCreateSkillDialog(skill);
  }

  /// 导出技能到文件
  Future<void> _exportSkill(Skill skill) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${skill.name.replaceAll(RegExp(r'[^\w\u4e00-\u9fff]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      final skillJson = {
        'id': skill.id,
        'name': skill.name,
        'icon': skill.icon,
        'description': skill.description,
        'category': skill.category,
        'type': skill.type.name,
        'author': skill.author,
        'systemPrompt': skill.systemPrompt,
        'distillPrompt': skill.distillPrompt,
        'analyzePrompt': skill.analyzePrompt,
        'tags': skill.tags,
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(skillJson));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已导出到: ${file.path}'),
            action: SnackBarAction(
              label: '复制路径',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: file.path));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  /// 导出所有自创技能
  void _showExportAllDialog() {
    final createdSkills = _createdSkills;
    
    if (createdSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无自创技能可导出')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出全部技能'),
        content: Text('将导出 ${createdSkills.length} 个自创技能为 JSON 文件'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportAllSkills(createdSkills);
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAllSkills(List<Skill> skills) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'openwrite_skills_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      final skillsJson = skills.map((s) => {
        'id': s.id,
        'name': s.name,
        'icon': s.icon,
        'description': s.description,
        'category': s.category,
        'type': s.type.name,
        'author': s.author,
        'systemPrompt': s.systemPrompt,
        'distillPrompt': s.distillPrompt,
        'analyzePrompt': s.analyzePrompt,
        'tags': s.tags,
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
      }).toList();
      
      await file.writeAsString(json.encode({
        'app': 'OpenWrite',
        'version': '1.0',
        'skills': skillsJson,
      }));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已导出 ${skills.length} 个技能到: ${file.path}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  /// 导入技能
  Future<void> _importSkill() async {
    // 显示导入对话框，让用户粘贴 JSON 内容
    final controller = TextEditingController();
    
    final confirmed = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入技能'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '请粘贴技能 JSON 内容或技能文件路径：',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: '{"name": "我的技能", ...}',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '提示：可以从其他用户分享的技能文件中复制内容',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('导入'),
          ),
        ],
      ),
    );

    if (confirmed == null || confirmed.isEmpty) return;

    try {
      String jsonContent = confirmed.trim();
      
      // 如果是文件路径，读取文件
      if (jsonContent.contains('/') || jsonContent.contains('\\')) {
        try {
          final file = File(jsonContent);
          if (await file.exists()) {
            jsonContent = await file.readAsString();
          }
        } catch (e) {
          // 不是文件路径，尝试作为 JSON 直接解析
        }
      }

      final Map<String, dynamic> data = json.decode(jsonContent);
      
      Skill? newSkill;
      
      // 处理单个技能或技能数组
      if (data.containsKey('skills')) {
        // 批量导入
        final skills = data['skills'] as List;
        int imported = 0;
        for (final skillData in skills) {
          try {
            final skill = _parseImportedSkill(skillData);
            await _skillService.createSkill(skill);
            imported++;
          } catch (e) {
            // 跳过无效技能
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成功导入 $imported 个技能')),
          );
        }
      } else {
        // 单个技能
        newSkill = _parseImportedSkill(data);
        await _skillService.createSkill(newSkill);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成功导入「${newSkill.name}」')),
          );
        }
      }
      
      _loadSkills();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: 无效的 JSON 格式')),
        );
      }
    }
  }

  Skill _parseImportedSkill(Map<String, dynamic> data) {
    return Skill(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['name'] ?? '未命名技能',
      icon: data['icon'] ?? '✨',
      description: data['description'] ?? '',
      category: data['category'] ?? '自定义',
      type: SkillType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => SkillType.custom,
      ),
      author: data['author'] ?? '用户',
      systemPrompt: data['systemPrompt'] ?? '',
      distillPrompt: data['distillPrompt'],
      analyzePrompt: data['analyzePrompt'],
      tags: List<String>.from(data['tags'] ?? []),
      isCreated: true,
    );
  }

  /// 删除自创技能
  Future<void> _deleteCreatedSkill(Skill skill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除技能'),
        content: Text('确定要删除「${skill.name}」吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _skillService.deleteCreatedSkill(skill.id);
      _loadSkills();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${skill.name} 已删除')),
        );
      }
    }
  }
}

/// 创建/编辑技能对话框
class _CreateSkillDialog extends StatefulWidget {
  final SkillService skillService;
  final Skill? existingSkill;
  final VoidCallback? onSaved;

  const _CreateSkillDialog({
    required this.skillService,
    this.existingSkill,
    this.onSaved,
  });

  @override
  State<_CreateSkillDialog> createState() => _CreateSkillDialogState();
}

class _CreateSkillDialogState extends State<_CreateSkillDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _descriptionController;
  late TextEditingController _systemPromptController;
  late TextEditingController _distillPromptController;
  late TextEditingController _analyzePromptController;
  late TextEditingController _tagsController;
  
  String _selectedCategory = '自定义';
  SkillType _selectedType = SkillType.custom;

  final List<String> _categories = [
    '自定义', '仙侠', '都市', '玄幻', '科幻', '言情', '悬疑', '历史', '游戏', '其他'
  ];

  final List<String> _availableIcons = [
    '✨', '🌟', '📝', '📖', '📚', '🎭', '👤', '🏰', '⚔️', '🔮',
    '🌸', '🔥', '💫', '🌙', '☀️', '🌈', '🎨', '🎯', '🎲', '🎪',
    '📱', '💻', '🔧', '🛠️', '📊', '📈', '💡', '🎓', '🏆', '⭐',
  ];

  @override
  void initState() {
    super.initState();
    final skill = widget.existingSkill;
    _nameController = TextEditingController(text: skill?.name ?? '');
    _iconController = TextEditingController(text: skill?.icon ?? '✨');
    _descriptionController = TextEditingController(text: skill?.description ?? '');
    _systemPromptController = TextEditingController(text: skill?.systemPrompt ?? '');
    _distillPromptController = TextEditingController(text: skill?.distillPrompt ?? '');
    _analyzePromptController = TextEditingController(text: skill?.analyzePrompt ?? '');
    _tagsController = TextEditingController(text: skill?.tags.join(', ') ?? '');
    _selectedCategory = skill?.category ?? '自定义';
    _selectedType = skill?.type ?? SkillType.custom;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _descriptionController.dispose();
    _systemPromptController.dispose();
    _distillPromptController.dispose();
    _analyzePromptController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.existingSkill != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                  Icon(Icons.auto_awesome, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? '编辑技能' : '创建新技能',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: colorScheme.onPrimaryContainer),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 表单
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  children: [
                    // 技能图标选择
                    const Text('图标', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableIcons.map((icon) {
                        final isSelected = _iconController.text == icon;
                        return InkWell(
                          onTap: () => setState(() => _iconController.text = icon),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? colorScheme.primaryContainer 
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected 
                                  ? Border.all(color: colorScheme.primary, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(icon, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // 技能名称
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '技能名称 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入技能名称';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // 分类
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: '分类',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),

                    const SizedBox(height: 12),

                    // 类型
                    DropdownButtonFormField<SkillType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: '类型',
                        border: OutlineInputBorder(),
                      ),
                      items: SkillType.values.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type.label));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                    ),

                    const SizedBox(height: 12),

                    // 描述
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '描述',
                        border: OutlineInputBorder(),
                        hintText: '简单描述这个技能的用途...',
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 12),

                    // 系统提示词
                    TextFormField(
                      controller: _systemPromptController,
                      decoration: const InputDecoration(
                        labelText: '系统提示词 *',
                        border: OutlineInputBorder(),
                        hintText: '定义 AI 的角色和行为...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入系统提示词';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // 蒸馏提示词
                    ExpansionTile(
                      title: const Text('高级设置'),
                      children: [
                        TextFormField(
                          controller: _distillPromptController,
                          decoration: const InputDecoration(
                            labelText: '文段蒸馏提示词',
                            border: OutlineInputBorder(),
                            hintText: '用于处理和提炼文本的提示词（可选）',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _analyzePromptController,
                          decoration: const InputDecoration(
                            labelText: '分析提示词',
                            border: OutlineInputBorder(),
                            hintText: '用于分析文本的提示词（可选）',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: '标签',
                            border: OutlineInputBorder(),
                            hintText: '用逗号分隔，如：写作, 润色, 仙侠',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveSkill,
                    child: Text(isEditing ? '保存' : '创建'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final skill = Skill(
      id: widget.existingSkill?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: _iconController.text,
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      type: _selectedType,
      author: '用户',
      systemPrompt: _systemPromptController.text.trim(),
      distillPrompt: _distillPromptController.text.trim().isEmpty 
          ? null 
          : _distillPromptController.text.trim(),
      analyzePrompt: _analyzePromptController.text.trim().isEmpty 
          ? null 
          : _analyzePromptController.text.trim(),
      tags: tags,
      isCreated: true,
    );

    await widget.skillService.createSkill(skill);
    
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingSkill != null 
              ? '技能已保存' 
              : '技能「${skill.name}」创建成功'),
        ),
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

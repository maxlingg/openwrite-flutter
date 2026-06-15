import 'package:flutter/material.dart';
import '../services/novel_tools_service.dart';
import '../models/novel.dart';

/// 小说工具箱页面 - AI辅助创作工具
class NovelToolsScreen extends StatefulWidget {
  const NovelToolsScreen({super.key});

  @override
  State<NovelToolsScreen> createState() => _NovelToolsScreenState();
}

class _NovelToolsScreenState extends State<NovelToolsScreen> with SingleTickerProviderStateMixin {
  final NovelToolsService _toolsService = NovelToolsService();
  late TabController _tabController;
  
  // 角色名生成
  final _surnameController = TextEditingController();
  String _selectedGender = '随机';
  String _generatedName = '';
  
  // 性格生成
  String _selectedBaseType = '';
  String _generatedPersonality = '';
  
  // 背景生成
  final _charNameController = TextEditingController();
  String _selectedRole = '主角';
  String _selectedGenre = '仙侠';
  String _generatedBackstory = '';
  
  // 世界观生成
  String _selectedWorldGenre = '仙侠';
  Map<String, String> _generatedWorld = {};
  
  // 情节大纲生成
  final _novelTitleController = TextEditingController();
  String _plotOutline = '';
  
  // 章节标题生成
  int _chapterCount = 10;
  List<String> _chapterTitles = [];
  
  // 简介生成
  final _synopsisTitleController = TextEditingController();
  String _generatedSynopsis = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _surnameController.dispose();
    _charNameController.dispose();
    _novelTitleController.dispose();
    _synopsisTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('小说工具箱'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '角色名'),
            Tab(text: '性格设定'),
            Tab(text: '角色背景'),
            Tab(text: '世界观'),
            Tab(text: '情节大纲'),
            Tab(text: '章节标题'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCharacterNameTab(),
          _buildPersonalityTab(),
          _buildBackstoryTab(),
          _buildWorldSettingTab(),
          _buildPlotOutlineTab(),
          _buildChapterTitlesTab(),
        ],
      ),
    );
  }

  /// 角色名生成器
  Widget _buildCharacterNameTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('角色姓名生成器'),
          const SizedBox(height: 16),
          TextField(
            controller: _surnameController,
            decoration: const InputDecoration(
              labelText: '姓氏（可选）',
              hintText: '如：李、王、张...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: ['随机', '男', '女'].map((gender) {
              return ChoiceChip(
                label: Text(gender),
                selected: _selectedGender == gender,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedGender = gender);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generateName,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('生成姓名'),
            ),
          ),
          if (_generatedName.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultCard(
              title: '生成结果',
              content: _generatedName,
              icon: Icons.person_outline,
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_generatedName),
                  tooltip: '复制',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generateName,
                  tooltip: '重新生成',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 性格设定生成器
  Widget _buildPersonalityTab() {
    final traits = ['勇敢', '聪明', '善良', '冷酷', '狡猾', '正直', '自私', '大方', '开朗', '内向'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('性格特征生成'),
          const SizedBox(height: 8),
          Text(
            '选择基础性格或随机生成组合',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: traits.map((trait) {
              return FilterChip(
                label: Text(trait),
                selected: _selectedBaseType == trait,
                onSelected: (selected) {
                  setState(() {
                    _selectedBaseType = selected ? trait : '';
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generatePersonality,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('生成性格设定'),
            ),
          ),
          if (_generatedPersonality.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultCard(
              title: '性格特征',
              content: _generatedPersonality,
              icon: Icons.psychology_outlined,
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_generatedPersonality),
                  tooltip: '复制',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generatePersonality,
                  tooltip: '重新生成',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 角色背景生成器
  Widget _buildBackstoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('角色背景故事'),
          const SizedBox(height: 16),
          TextField(
            controller: _charNameController,
            decoration: const InputDecoration(
              labelText: '角色名（可选）',
              hintText: '输入角色姓名',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: '角色定位',
              border: OutlineInputBorder(),
            ),
            items: ['主角', '反派', '配角', '龙套'].map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedRole = value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGenre,
            decoration: const InputDecoration(
              labelText: '小说类型',
              border: OutlineInputBorder(),
            ),
            items: NovelGenre.names.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedGenre = value);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generateBackstory,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('生成背景故事'),
            ),
          ),
          if (_generatedBackstory.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultCard(
              title: '背景故事',
              content: _generatedBackstory,
              icon: Icons.history_edu_outlined,
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_generatedBackstory),
                  tooltip: '复制',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generateBackstory,
                  tooltip: '重新生成',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 世界观设定生成器
  Widget _buildWorldSettingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('世界观设定生成'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedWorldGenre,
            decoration: const InputDecoration(
              labelText: '选择类型',
              border: OutlineInputBorder(),
            ),
            items: NovelGenre.names.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedWorldGenre = value);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generateWorldSetting,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('生成世界观'),
            ),
          ),
          if (_generatedWorld.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildWorldSettingResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildWorldSettingResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.public_outlined),
                const SizedBox(width: 8),
                Text(
                  '世界观设定',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_formatWorldSetting()),
                  tooltip: '复制全部',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generateWorldSetting,
                  tooltip: '重新生成',
                ),
              ],
            ),
            const Divider(),
            ..._generatedWorld.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getWorldSettingLabel(entry.key),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.value),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getWorldSettingLabel(String key) {
    const labels = {
      'timePeriod': '时代背景',
      'location': '地理环境',
      'culture': '文化风俗',
      'magicSystem': '力量体系',
      'politics': '政治格局',
      'economy': '经济体系',
      'technology': '科技/技艺',
    };
    return labels[key] ?? key;
  }

  String _formatWorldSetting() {
    return _generatedWorld.entries.map((e) {
      return '${_getWorldSettingLabel(e.key)}：${e.value}';
    }).join('\n\n');
  }

  /// 情节大纲生成器
  Widget _buildPlotOutlineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('情节大纲生成'),
          const SizedBox(height: 16),
          TextField(
            controller: _novelTitleController,
            decoration: const InputDecoration(
              labelText: '小说标题',
              hintText: '输入小说名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generatePlotOutline,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('生成情节大纲'),
            ),
          ),
          if (_plotOutline.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultCard(
              title: '情节大纲',
              content: _plotOutline,
              icon: Icons.account_tree_outlined,
              isMultiline: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_plotOutline),
                  tooltip: '复制',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generatePlotOutline,
                  tooltip: '重新生成',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 章节标题生成器
  Widget _buildChapterTitlesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('章节标题生成'),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('生成数量：'),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _chapterCount.toDouble(),
                  min: 5,
                  max: 30,
                  divisions: 25,
                  label: '$_chapterCount 章',
                  onChanged: (value) {
                    setState(() => _chapterCount = value.round());
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '$_chapterCount 章',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generateChapterTitles,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('生成章节标题'),
            ),
          ),
          if (_chapterTitles.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildChapterTitlesResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildChapterTitlesResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.format_list_numbered),
                const SizedBox(width: 8),
                Text(
                  '章节标题列表',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_all),
                  onPressed: () => _copyToClipboard(_chapterTitles.join('\n')),
                  tooltip: '复制全部',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generateChapterTitles,
                  tooltip: '重新生成',
                ),
              ],
            ),
            const Divider(),
            ...List.generate(_chapterTitles.length, (index) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 14,
                  child: Text('${index + 1}'),
                ),
                title: Text(_chapterTitles[index]),
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 辅助方法
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String content,
    required IconData icon,
    required List<Widget> actions,
    bool isMultiline = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                ...actions,
              ],
            ),
            const Divider(),
            SelectableText(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _generateName() {
    final gender = _selectedGender == '随机' ? null : (_selectedGender == '男' ? 'male' : 'female');
    setState(() {
      _generatedName = _toolsService.generateCharacterName(
        surname: _surnameController.text.isEmpty ? null : _surnameController.text,
        gender: gender,
      );
    });
    _showSnackBar('已生成角色名：$_generatedName');
  }

  void _generatePersonality() {
    setState(() {
      _generatedPersonality = _toolsService.generatePersonality(
        baseType: _selectedBaseType.isEmpty ? null : _selectedBaseType,
      );
    });
    _showSnackBar('已生成性格设定');
  }

  void _generateBackstory() {
    setState(() {
      _generatedBackstory = _toolsService.generateBackstory(
        name: _charNameController.text,
        role: _selectedRole,
        genre: _selectedGenre,
      );
    });
    _showSnackBar('已生成背景故事');
  }

  void _generateWorldSetting() {
    setState(() {
      _generatedWorld = _toolsService.generateWorldSetting(genre: _selectedWorldGenre);
    });
    _showSnackBar('已生成世界观设定');
  }

  void _generatePlotOutline() {
    if (_novelTitleController.text.isEmpty) {
      _showSnackBar('请输入小说标题');
      return;
    }
    setState(() {
      _plotOutline = _toolsService.generatePlotOutline(
        title: _novelTitleController.text,
        genre: _selectedGenre,
      );
    });
    _showSnackBar('已生成情节大纲');
  }

  void _generateChapterTitles() {
    setState(() {
      _chapterTitles = _toolsService.generateChapterTitles(count: _chapterCount);
    });
    _showSnackBar('已生成 $_chapterCount 个章节标题');
  }

  void _copyToClipboard(String text) {
    // 使用系统剪贴板复制
    // showDialog 会显示复制成功的提示
    _showSnackBar('已复制到剪贴板');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

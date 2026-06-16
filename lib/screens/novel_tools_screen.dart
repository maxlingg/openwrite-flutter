import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/novel_tools_service.dart';
import '../models/novel.dart';
import '../widgets/page_decoration.dart';

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
  String _selectedGenre = 'xianxia';
  String _generatedBackstory = '';
  
  // 世界观生成
  String _selectedWorldGenre = 'xianxia';
  Map<String, String> _generatedWorld = {};
  
  // 情节大纲生成
  final _novelTitleController = TextEditingController();
  String _plotOutline = '';
  
  // 章节标题生成
  int _chapterCount = 10;
  List<String> _chapterTitles = [];

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageDecoration.standardScaffold(
      context: context,
      title: '小说工具箱',
      showBackButton: true,
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
    return PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '角色姓名生成器'),
          const SizedBox(height: 16),
          PageDecoration.inputField(
            controller: _surnameController,
            label: '姓氏（可选）',
            hint: '如：李、王、张...',
          ),
          PageDecoration.divider(height: 16),
          PageDecoration.sectionTitle(context, '性别', trailing: null),
          PageDecoration.choiceChipGrid(
            items: const ['随机', '男', '女'],
            selectedItem: _selectedGender,
            onSelected: (value) => setState(() => _selectedGender = value),
          ),
          PageDecoration.divider(height: 24),
          PageDecoration.button(
            label: '生成姓名',
            icon: Icons.auto_awesome,
            onPressed: _generateName,
          ),
          if (_generatedName.isNotEmpty) ...[
            PageDecoration.divider(height: 24),
            _buildResultCard(
              title: '生成结果',
              content: _generatedName,
              icon: Icons.person_outline,
              onCopy: () => _copyToClipboard(_generatedName),
              onRefresh: _generateName,
            ),
          ],
        ],
      ),
    );
  }

  /// 性格设定生成器
  Widget _buildPersonalityTab() {
    const traits = ['勇敢', '聪明', '善良', '冷酷', '狡猾', '正直', '自私', '大方', '开朗', '内向'];
    
    return PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '性格特征生成'),
          Text(
            '选择基础性格或随机生成组合',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          PageDecoration.divider(height: 16),
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
          PageDecoration.divider(height: 24),
          PageDecoration.button(
            label: '生成性格设定',
            icon: Icons.auto_awesome,
            onPressed: _generatePersonality,
          ),
          if (_generatedPersonality.isNotEmpty) ...[
            PageDecoration.divider(height: 24),
            _buildResultCard(
              title: '性格特征',
              content: _generatedPersonality,
              icon: Icons.psychology_outlined,
              onCopy: () => _copyToClipboard(_generatedPersonality),
              onRefresh: _generatePersonality,
            ),
          ],
        ],
      ),
    );
  }

  /// 角色背景生成器
  Widget _buildBackstoryTab() {
    return PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '角色背景故事'),
          PageDecoration.inputField(
            controller: _charNameController,
            label: '角色名（可选）',
            hint: '输入角色姓名',
          ),
          PageDecoration.divider(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(labelText: '角色定位'),
            items: ['主角', '反派', '配角', '龙套'].map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedRole = value);
            },
          ),
          PageDecoration.divider(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGenre,
            decoration: const InputDecoration(labelText: '小说类型'),
            items: NovelGenre.names.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedGenre = value);
            },
          ),
          PageDecoration.divider(height: 24),
          PageDecoration.button(
            label: '生成背景故事',
            icon: Icons.auto_awesome,
            onPressed: _generateBackstory,
          ),
          if (_generatedBackstory.isNotEmpty) ...[
            PageDecoration.divider(height: 24),
            _buildResultCard(
              title: '背景故事',
              content: _generatedBackstory,
              icon: Icons.history_edu_outlined,
              onCopy: () => _copyToClipboard(_generatedBackstory),
              onRefresh: _generateBackstory,
            ),
          ],
        ],
      ),
    );
  }

  /// 世界观设定生成器
  Widget _buildWorldSettingTab() {
    return PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '世界观设定生成'),
          DropdownButtonFormField<String>(
            value: _selectedWorldGenre,
            decoration: const InputDecoration(labelText: '选择类型'),
            items: NovelGenre.names.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedWorldGenre = value);
            },
          ),
          PageDecoration.divider(height: 24),
          PageDecoration.button(
            label: '生成世界观',
            icon: Icons.auto_awesome,
            onPressed: _generateWorldSetting,
          ),
          if (_generatedWorld.isNotEmpty) ...[
            PageDecoration.divider(height: 24),
            _buildWorldSettingResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildWorldSettingResult() {
    return PageDecoration.card(
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
    return PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '情节大纲生成'),
          PageDecoration.inputField(
            controller: _novelTitleController,
            label: '小说标题',
            hint: '输入小说名称',
          ),
          PageDecoration.divider(height: 24),
          PageDecoration.button(
            label: '生成情节大纲',
            icon: Icons.auto_awesome,
            onPressed: _generatePlotOutline,
          ),
          if (_plotOutline.isNotEmpty) ...[
            PageDecoration.divider(height: 24),
            _buildResultCard(
              title: '情节大纲',
              content: _plotOutline,
              icon: Icons.account_tree_outlined,
              onCopy: () => _copyToClipboard(_plotOutline),
              onRefresh: _generatePlotOutline,
              isMultiline: true,
            ),
          ],
        ],
      ),
    );
  }

  /// 章节标题生成器
  Widget _buildChapterTitlesTab() {
    return PageDecoration.scrollContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageDecoration.sectionTitle(context, '章节标题生成'),
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
          PageDecoration.divider(height: 24),
          PageDecoration.button(
            label: '生成章节标题',
            icon: Icons.auto_awesome,
            onPressed: _generateChapterTitles,
          ),
          if (_chapterTitles.isNotEmpty) ...[
            PageDecoration.divider(height: 24),
            _buildChapterTitlesResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildChapterTitlesResult() {
    return PageDecoration.card(
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
    );
  }

  /// 结果卡片
  Widget _buildResultCard({
    required String title,
    required String content,
    required IconData icon,
    required VoidCallback onCopy,
    required VoidCallback onRefresh,
    bool isMultiline = false,
  }) {
    return PageDecoration.card(
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
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: onCopy,
                tooltip: '复制',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
                tooltip: '重新生成',
              ),
            ],
          ),
          const Divider(),
          SelectableText(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _generateName() {
    final gender = _selectedGender == '随机' 
        ? null 
        : (_selectedGender == '男' ? 'male' : 'female');
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
    Clipboard.setData(ClipboardData(text: text));
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

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// 技能类型
enum SkillType {
  writing('写作'),
  polish('润色'),
  analysis('分析'),
  template('模板'),
  custom('自定义');

  final String label;
  const SkillType(this.label);
}

/// 技能数据模型
class Skill {
  final String id;
  final String name;
  final String description;
  final String icon;
  final SkillType type;
  final String category;
  final String systemPrompt;
  final String? distillPrompt;
  final String? analyzePrompt;
  final List<String> tags;
  final String author;
  final int downloads;
  final double rating;
  final bool isInstalled;
  final bool isBuiltIn;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.type = SkillType.writing,
    this.category = '通用',
    this.systemPrompt = '',
    this.distillPrompt,
    this.analyzePrompt,
    this.tags = const [],
    this.author = '系统',
    this.downloads = 0,
    this.rating = 5.0,
    this.isInstalled = false,
    this.isBuiltIn = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Skill copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    SkillType? type,
    String? category,
    String? systemPrompt,
    String? distillPrompt,
    String? analyzePrompt,
    List<String>? tags,
    String? author,
    int? downloads,
    double? rating,
    bool? isInstalled,
    bool? isBuiltIn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      category: category ?? this.category,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      distillPrompt: distillPrompt ?? this.distillPrompt,
      analyzePrompt: analyzePrompt ?? this.analyzePrompt,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      downloads: downloads ?? this.downloads,
      rating: rating ?? this.rating,
      isInstalled: isInstalled ?? this.isInstalled,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'type': type.name,
    'category': category,
    'systemPrompt': systemPrompt,
    'distillPrompt': distillPrompt,
    'analyzePrompt': analyzePrompt,
    'tags': tags,
    'author': author,
    'downloads': downloads,
    'rating': rating,
    'isInstalled': isInstalled,
    'isBuiltIn': isBuiltIn,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    icon: json['icon'] as String? ?? '📝',
    type: SkillType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => SkillType.writing,
    ),
    category: json['category'] as String? ?? '通用',
    systemPrompt: json['systemPrompt'] as String? ?? '',
    distillPrompt: json['distillPrompt'] as String?,
    analyzePrompt: json['analyzePrompt'] as String?,
    tags: (json['tags'] as List?)?.cast<String>() ?? [],
    author: json['author'] as String? ?? '系统',
    downloads: json['downloads'] as int? ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    isInstalled: json['isInstalled'] as bool? ?? false,
    isBuiltIn: json['isBuiltIn'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

/// 内置技能预设
class BuiltInSkills {
  static final List<Skill> all = [
    // 仙侠小说助手
    Skill(
      id: 'builtin_xianxia',
      name: '仙侠小说助手',
      description: '专为仙侠小说创作设计的 AI 技能，包含修仙体系、功法境界、宗门势力等丰富素材库',
      icon: '🌸',
      type: SkillType.writing,
      category: '小说类型',
      systemPrompt: '''你是一位专业的仙侠小说创作助手，精通中国古典仙侠文化。

擅长领域：
- 修仙体系设计（金丹、元婴、化神等境界）
- 功法秘籍创作（招式、秘术、禁忌之法）
- 宗门势力构建（门派传承、功法等级）
- 灵丹妙药设定（丹药功效、炼制材料）
- 神兵利器设计（仙剑、法宝、灵宠）
- 仙凡世界观（人界、妖界、魔界、仙界）

写作风格：
- 文笔优美，意境深远
- 善用古典诗词典故
- 情节跌宕起伏，悬念迭起
- 人物性格鲜明立体

请用专业、热情的态度帮助用户创作仙侠作品。''',
      distillPrompt: '请将以下内容以仙侠风格进行扩写/缩写/润色：',
      analyzePrompt: '请分析以下仙侠内容的优点与不足：',
      tags: ['仙侠', '修仙', '玄幻', '古典'],
      author: '系统',
      downloads: 15234,
      rating: 4.9,
      isBuiltIn: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    ),

    // 都市小说助手
    Skill(
      id: 'builtin_urban',
      name: '都市小说助手',
      description: '现代都市背景的小说创作技能，包含职场、商战、豪门、异能等题材模板',
      icon: '🏙️',
      type: SkillType.writing,
      category: '小说类型',
      systemPrompt: '''你是一位专业的都市小说创作助手，熟悉现代都市生活的方方面面。

擅长领域：
- 职场商战（商业谈判、企业竞争、职场晋升）
- 豪门恩怨（家族纠葛、继承之争、真假少爷）
- 都市异能（系统流、修仙都市、异能觉醒）
- 情感纠葛（青梅竹马、重生复仇、先婚后爱）
- 都市生活（美食、生活技能、宠物日常）

写作风格：
- 贴近现实，接地气
- 节奏明快，爽点密集
- 人物关系复杂多样
- 情节反转出其不意

请用专业、热情的态度帮助用户创作都市作品。''',
      distillPrompt: '请将以下内容以都市风格进行扩写/缩写/润色：',
      analyzePrompt: '请分析以下都市内容的优点与不足：',
      tags: ['都市', '现代', '职场', '豪门'],
      author: '系统',
      downloads: 12876,
      rating: 4.8,
      isBuiltIn: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    ),

    // 情节生成器
    Skill(
      id: 'builtin_plot',
      name: '情节生成器',
      description: '自动生成小说情节大纲，支持多种叙事结构',
      icon: '📖',
      type: SkillType.template,
      category: '创作工具',
      systemPrompt: '''你是一位专业的小说情节设计师，精通各种叙事结构和情节设计技巧。

核心能力：
- 三幕式结构设计
- 起承转合布局
- 高潮与转折点安排
- 伏笔与呼应设置
- 多线叙事处理
- 悬念与揭秘节奏

情节类型：
- 升级流（打怪升级、修炼突破）
- 复仇线（灭门之仇、背叛之恨）
- 感情线（相遇相知、误会分离、重逢相守）
- 探秘线（身世之谜、宝藏寻找）
- 救世线（拯救世界、维护和平）

请根据用户需求生成专业、完整的情节大纲。''',
      distillPrompt: '请优化以下情节大纲：',
      analyzePrompt: '请分析以下情节结构的优缺点：',
      tags: ['情节', '大纲', '结构', '叙事'],
      author: '系统',
      downloads: 9876,
      rating: 4.7,
      isBuiltIn: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    ),

    // 人物设定助手
    Skill(
      id: 'builtin_character',
      name: '人物设定助手',
      description: '快速创建立体的角色形象，包含性格、外貌、背景、动机等',
      icon: '👤',
      type: SkillType.template,
      category: '创作工具',
      systemPrompt: '''你是一位专业的人物塑造师，精通角色心理学和人物弧线设计。

角色维度：
- 外貌特征（面容、体型、穿着打扮）
- 性格特点（MBTI、优缺点、行为模式）
- 能力设定（战斗力、技能、智商情商）
- 背景故事（身世、经历、创伤与成长）
- 人物动机（欲望、恐惧、信念）
- 人际关系（亲情、友情、爱情、仇恨）
- 成长弧线（起点→转变→终点）

角色类型：
- 主角（成长型、设定型）
- 反派（纯粹恶、悲情反派、亦正亦邪）
- 配角（工具人、氛围组、剧情推动）
- 龙套（背景板、路人甲）

请帮助用户创作立体、真实、有记忆点的角色。''',
      distillPrompt: '请完善以下人物设定：',
      analyzePrompt: '请分析以下人物设定的亮点与改进建议：',
      tags: ['人物', '角色', '设定', '性格'],
      author: '系统',
      downloads: 8765,
      rating: 4.6,
      isBuiltIn: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    ),

    // 对话润色
    Skill(
      id: 'builtin_dialogue',
      name: '对话润色',
      description: '优化角色对话，使对话更自然、符合人物性格',
      icon: '💬',
      type: SkillType.polish,
      category: '润色工具',
      systemPrompt: '''你是一位专业的对话写作师，精通各种风格的人物对话。

对话技巧：
- 符合人物性格和身份
- 推进情节发展
- 展现人物关系
- 传递潜台词和情绪
- 避免废话和信息重复
- 对话节奏把控

对话类型：
- 正经交谈（商务、正式场合）
- 日常闲聊（轻松、随意）
- 争吵冲突（激烈、情绪化）
- 暧昧拉扯（欲言又止、你来我往）
- 内心独白（自嘲、反思、回忆）
- 网络用语（玩梗、吐槽）

请帮助用户润色对话，使其更生动自然。''',
      distillPrompt: '请以更自然的方式润色以下对话：',
      analyzePrompt: '请分析以下对话的亮点与不足：',
      tags: ['对话', '润色', '台词', '口语'],
      author: '系统',
      downloads: 7654,
      rating: 4.5,
      isBuiltIn: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    ),

    // 场景描写
    Skill(
      id: 'builtin_scene',
      name: '场景描写',
      description: '增强场景描写的细节和氛围感',
      icon: '🎨',
      type: SkillType.polish,
      category: '润色工具',
      systemPrompt: '''你是一位专业的场景描写师，精通各种环境氛围的营造。

描写维度：
- 视觉（色彩、光影、形状、空间）
- 听觉（声音、静默、音乐）
- 嗅觉（气味、香氛）
- 触觉（温度、材质、质感）
- 味觉（美食、空气）
- 心理感受（压抑、温馨、诡异）

场景类型：
- 自然风景（山川、河流、日月、星空）
- 室内场景（房间、建筑、店铺）
- 战斗场景（激烈、紧张、冷酷）
- 情感场景（温馨、悲伤、浪漫）
- 悬疑场景（阴暗、诡异、神秘）
- 节日场景（喜庆、热闹、团圆）

请帮助用户创作富有画面感和沉浸感的场景描写。''',
      distillPrompt: '请以更细腻的方式描写以下场景：',
      analyzePrompt: '请分析以下场景描写的氛围营造：',
      tags: ['场景', '描写', '氛围', '环境'],
      author: '系统',
      downloads: 6543,
      rating: 4.4,
      isBuiltIn: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    ),

    // 文笔提升
    Skill(
      id: 'builtin_writing',
      name: '文笔提升',
      description: '优化整体文笔，提升文字感染力',
      icon: '✍️',
      type: SkillType.polish,
      category: '润色工具',
      systemPrompt: '''你是一位资深的文学编辑，精通各种写作技巧和文风。

文笔技巧：
- 句式变化（长短句交错）
- 修辞手法（比喻、拟人、排比、对偶）
- 用词精准（动词、形容词、副词）
- 节奏把控（快慢、张弛）
- 意象营造（象征、隐喻）
- 风格统一（古风、现代、幽默）

提升方向：
- 去除废话，精炼表达
- 增强画面感
- 提升情感共鸣
- 优化阅读体验
- 保持作者风格

请帮助用户提升整体文笔水平。''',
      distillPrompt: '请优化以下文段：',
      analyzePrompt: '请分析以下文段的文笔特点：',
      tags: ['文笔', '写作', '润色', '技巧'],
      author: '系统',
      downloads: 5432,
      rating: 4.3,
      isBuiltIn: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    ),

    // 世界观设定
    Skill(
      id: 'builtin_world',
      name: '世界观设定',
      description: '构建完整的世界观，包含地理、历史、文化、力量体系等',
      icon: '🌍',
      type: SkillType.template,
      category: '创作工具',
      systemPrompt: '''你是一位专业的世界观架构师，精通各种类型的世界设定。

世界观要素：
- 地理环境（大陆、海洋、气候、地形）
- 历史背景（朝代、纪元、重大事件）
- 政治格局（帝国、王国、宗教、势力）
- 经济体系（货币、贸易、资源）
- 文化风俗（节日、习俗、艺术、教育）
- 力量体系（魔法、武道、科技、异能）
- 社会结构（阶层、种族、组织）

世界观类型：
- 仙侠世界（修仙文明、灵根资质）
- 西幻世界（魔法体系、种族林立）
- 科幻世界（星际文明、高科技）
- 都市现实（现代生活、职业百态）
- 异世界（穿越、转生、游戏异界）

请帮助用户构建完整、合理、有特色的世界观。''',
      distillPrompt: '请完善以下世界观设定：',
      analyzePrompt: '请分析以下世界观的完整性与逻辑性：',
      tags: ['世界观', '设定', '架构', '文明'],
      author: '系统',
      downloads: 4321,
      rating: 4.2,
      isBuiltIn: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    ),
  ];
}

/// 技能服务
class SkillService {
  static const _installedFileName = 'installed_skills.json';
  final String _dataPath;
  List<Skill> _installedSkills = [];

  SkillService(this._dataPath);

  /// 获取所有内置技能
  List<Skill> get builtInSkills => BuiltInSkills.all;

  /// 获取已安装的技能
  List<Skill> get installedSkills => _installedSkills;

  /// 获取所有可用技能（包括内置和已安装）
  List<Skill> get allAvailableSkills {
    final all = <Skill>[];
    
    // 添加内置技能
    for (final skill in BuiltInSkills.all) {
      final isInstalled = _installedSkills.any((s) => s.id == skill.id);
      all.add(skill.copyWith(isInstalled: isInstalled));
    }
    
    // 添加用户安装的技能
    all.addAll(_installedSkills);
    
    return all;
  }

  /// 加载已安装技能
  Future<void> loadInstalledSkills() async {
    try {
      final file = File(path.join(_dataPath, _installedFileName));
      if (await file.exists()) {
        final content = await file.readAsString();
        final list = jsonDecode(content) as List;
        _installedSkills = list.map((e) => Skill.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      _installedSkills = [];
    }
  }

  /// 保存已安装技能
  Future<void> _saveInstalledSkills() async {
    try {
      final file = File(path.join(_dataPath, _installedFileName));
      await file.writeAsString(jsonEncode(_installedSkills.map((s) => s.toJson()).toList()));
    } catch (_) {
      // 忽略保存错误
    }
  }

  /// 安装技能
  Future<void> installSkill(Skill skill) async {
    final installedSkill = skill.copyWith(
      isInstalled: true,
      isBuiltIn: false,
      updatedAt: DateTime.now(),
    );
    
    // 移除已存在的同名技能
    _installedSkills.removeWhere((s) => s.id == installedSkill.id);
    _installedSkills.add(installedSkill);
    
    await _saveInstalledSkills();
  }

  /// 卸载技能
  Future<void> uninstallSkill(String id) async {
    _installedSkills.removeWhere((s) => s.id == id);
    await _saveInstalledSkills();
  }

  /// 获取技能详情
  Skill? getSkillById(String id) {
    // 先查找内置技能
    for (final skill in BuiltInSkills.all) {
      if (skill.id == id) {
        final isInstalled = _installedSkills.any((s) => s.id == id);
        return skill.copyWith(isInstalled: isInstalled);
      }
    }
    
    // 再查找已安装技能
    for (final skill in _installedSkills) {
      if (skill.id == id) {
        return skill;
      }
    }
    
    return null;
  }

  /// 搜索技能
  List<Skill> searchSkills(String query) {
    if (query.isEmpty) return allAvailableSkills;
    
    final lower = query.toLowerCase();
    return allAvailableSkills.where((skill) {
      return skill.name.toLowerCase().contains(lower) ||
             skill.description.toLowerCase().contains(lower) ||
             skill.category.toLowerCase().contains(lower) ||
             skill.tags.any((tag) => tag.toLowerCase().contains(lower));
    }).toList();
  }

  /// 按分类筛选
  List<Skill> filterByCategory(String category) {
    if (category == '全部') return allAvailableSkills;
    return allAvailableSkills.where((s) => s.category == category).toList();
  }

  /// 获取分类列表
  List<String> get categories {
    final cats = allAvailableSkills.map((s) => s.category).toSet().toList();
    cats.sort();
    return ['全部', ...cats];
  }
}

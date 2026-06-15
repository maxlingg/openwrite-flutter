import 'dart:math';

/// 小说工具服务 - 提供创作辅助功能
class NovelToolsService {
  final _random = Random();

  /// 生成随机角色名
  String generateCharacterName({String? surname, String? gender}) {
    final surnames = ['李', '王', '张', '刘', '陈', '杨', '赵', '黄', '周', '吴', '徐', '孙', '胡', '朱', '高', '林', '何', '郭', '马', '罗'];
    final maleNames = ['伟', '强', '磊', '洋', '勇', '艳', '军', '杰', '涛', '超', '明', '刚', '平', '辉', '鹏', '飞', '华', '波', '斌', '宇'];
    final femaleNames = ['芳', '娟', '敏', '静', '丽', '艳', '娜', '秀', '英', '华', '慧', '巧', '美', '婷', '玲', '桂', '燕', '霞', '云', '莲'];
    
    final usedSurname = surname ?? surnames[_random.nextInt(surnames.length)];
    final usedGender = gender ?? (_random.nextBool() ? 'male' : 'female');
    final names = usedGender == 'male' ? maleNames : femaleNames;
    final usedName = names[_random.nextInt(names.length)];
    final hasMiddleName = _random.nextBool();
    final middleName = hasMiddleName ? names[_random.nextInt(names.length)] : '';
    
    return '$usedSurname$middleName$usedName';
  }

  /// 生成角色性格
  String generatePersonality({String? baseType}) {
    final traits = [
      '勇敢', '聪明', '善良', '冷酷', '狡猾', '正直', '自私', '大方',
      '开朗', '内向', '乐观', '悲观', '稳重', '冲动', '冷静', '暴躁',
      '温柔', '粗暴', '细心', '粗心', '诚实', '虚伪', '坚韧', '懦弱',
    ];
    
    if (baseType != null) {
      return baseType;
    }
    
    // 随机选择2-4个性格特征
    final count = 2 + _random.nextInt(3);
    final selected = <String>[];
    final available = List<String>.from(traits);
    
    for (int i = 0; i < count && available.isNotEmpty; i++) {
      final index = _random.nextInt(available.length);
      selected.add(available.removeAt(index));
    }
    
    return selected.join('、');
  }

  /// 生成角色背景
  String generateBackstory({required String name, String? role, String? genre}) {
    final backstories = [
      '出身于没落的贵族家庭，祖上是名震一时的强者，但家道中落，如今只剩下残破的祖宅和一卷残缺的功法。',
      '自幼被仇家灭门，被路过的神秘人救走，在深山中跟随师父修行十年，如今艺成归来。',
      '出身贫寒，父母早亡，靠着自己的努力一步步爬上来，见惯了世间的冷暖。',
      '含着金汤匙出生的世家子弟，拥有最好的资源和教导，却渴望摆脱家族的束缚。',
      '原本是普通人，意外获得上古传承，从此踏入修行之路，开启了不一样的人生。',
      '是某个大势力的天才弟子，天赋异禀，却因为一场意外被宗门驱逐，从此流落江湖。',
    ];
    
    return backstories[_random.nextInt(backstories.length)];
  }

  /// 生成世界观设定
  Map<String, String> generateWorldSetting({String? genre}) {
    final genres = genre ?? ['xianxia', 'fantasy', 'urban'][_random.nextInt(3)];
    
    switch (genres) {
      case 'xianxia':
        return _generateXianxiaWorld();
      case 'fantasy':
        return _generateFantasyWorld();
      case 'urban':
        return _generateUrbanWorld();
      default:
        return _generateFantasyWorld();
    }
  }

  Map<String, String> _generateXianxiaWorld() {
    return {
      'timePeriod': '上古时代，万族争锋',
      'location': '九州大陆，宗门林立',
      'culture': '以武为尊，强者为王，修行者追求长生大道',
      'magicSystem': '修炼境界：炼气、筑基、金丹、元婴、化神、大乘、渡劫。每突破一个大境界，实力天翻地覆。',
      'politics': '各大宗门掌控资源，世俗王朝不过是宗门附庸',
      'economy': '灵石是通用货币，珍稀灵材可换天价',
      'technology': '炼丹、炼器、阵法是三大辅助之道',
    };
  }

  Map<String, String> _generateFantasyWorld() {
    return {
      'timePeriod': '中世纪风格，魔法国度林立',
      'location': '艾泽拉斯大陆，多种族共存',
      'culture': '骑士、法师、盗贼各司其职，公会制度盛行',
      'magicSystem': '元素魔法：火、水、风、土四系，还有稀有的暗系和光系',
      'politics': '人类帝国、精灵王国、矮人山城三分天下',
      'economy': '金币为主，魔法材料价值连城',
      'technology': '炼金术、附魔、铭文是核心技艺',
    };
  }

  Map<String, String> _generateUrbanWorld() {
    return {
      'timePeriod': '现代都市，繁华与暗涌并存',
      'location': '一线城市，商业中心',
      'culture': '上流社会讲究门当户对，底层人民为生活奔波',
      'magicSystem': '表面是普通都市，暗地里存在修士、古武世家、异能者',
      'politics': '世家大族掌控经济命脉，隐世势力不可小觑',
      'economy': '金钱至上，有钱能使鬼推磨',
      'technology': '科技发达，但高端资源被少数人垄断',
    };
  }

  /// 生成情节大纲
  String generatePlotOutline({required String title, String? genre, int chapterCount = 10}) {
    final plots = [
      '''【$title】情节大纲

第一章：意外觉醒
主角原本是普通人，意外获得金手指（传承/系统/异能），开始崭新人生。

第二章：初入修行
主角开始修炼，实力飞速提升，引起势力注意。

第三章：势力纷争
主角卷入势力纷争，遭遇危机但化险为夷。

第四章：结识伙伴
主角结识志同道合的伙伴，组建自己的班底。

第五章：秘境探险
进入秘境，获得机缘，实力再次飞跃。

第六章：势力崛起
主角势力初成，开始崭露头角。

第七章：生死危机
遭遇前所未有的危机，差点陨落。

第八章：绝地反击
在绝境中爆发，击败强敌。

第九章：登顶之路
成为一方强者，但发现还有更大的世界。

第十章：新的征程
站在巅峰，回望过去，展望未来。
''',
      '''【$title】情节大纲

第一章：落魄开局
主角开局不利，被人看不起，默默积蓄力量。

第二章：偶得机缘
意外获得逆天机缘，开始逆袭之路。

第三章：小有名气
展露锋芒，引起大势力关注。

第四章：拜入门下
被强者收为弟子，获得系统培养。

第五章：声名鹊起
在年轻一代中脱颖而出。

第六章：内部争斗
宗门内部派系争斗，主角被迫选边站。

第七章：外出历练
离开宗门，在外闯荡，见识更广阔的世界。

第八章：强敌环伺
树大招风，引来多方敌对势力。

第九章：生死决战
与最大反派决战，惊天动地。

第十章：功成名就
击败反派，成就不朽传奇。
''',
    ];
    
    return plots[_random.nextInt(plots.length)];
  }

  /// 生成章节标题
  List<String> generateChapterTitles({int count = 10}) {
    final titles = [
      '初入江湖', '崭露头角', '声名鹊起', '危机四伏', '绝处逢生',
      '风云际会', '龙争虎斗', '尘埃落定', '再起波澜', '登堂入室',
      '技惊四座', '锋芒毕露', '暗流涌动', '水落石出', '柳暗花明',
      '惊天逆转', '力挽狂澜', '名动天下', '问鼎巅峰', '超凡入圣',
    ];
    
    final result = <String>[];
    final used = <int>[];
    
    for (int i = 0; i < count && used.length < titles.length; i++) {
      int index;
      do {
        index = _random.nextInt(titles.length);
      } while (used.contains(index));
      used.add(index);
      result.add('第${_toChineseNumber(i + 1)}章 ${titles[index]}');
    }
    
    return result;
  }

  String _toChineseNumber(int number) {
    const units = ['', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (number < 10) return units[number];
    if (number < 20) return '十${units[number - 10]}';
    if (number < 100) {
      final tens = number ~/ 10;
      final ones = number % 10;
      return '${units[tens]}十${ones > 0 ? units[ones] : ''}';
    }
    return number.toString();
  }

  /// 生成小说简介
  String generateSynopsis({required String title, String? genre}) {
    return '''$title

一场意外，彻底改变了命运。

原本平凡的他，意外获得逆天机缘，从此踏入一条不归路。

在这个强者为尊的世界，他必须不断变强，才能守护自己想要守护的人。

且看他如何从微末崛起，一步一步登临绝顶！

【本文热血、爽文、不虐主】''';
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

/// 卡片数据
class CardItem {
  final String title;
  final String? description;
  final Color? color;

  const CardItem({
    required this.title,
    this.description,
    this.color,
  });
}

/// 预设卡片组
class CardDeck {
  static const plotTwists = [
    CardItem(title: '意外转折', description: '主角遭遇意想不到的事件', color: Colors.orange),
    CardItem(title: '身份揭露', description: '某人隐藏的身份被曝光', color: Colors.purple),
    CardItem(title: '背叛', description: '信任的人突然反目', color: Colors.red),
    CardItem(title: '重逢', description: '失散多年的人再次相遇', color: Colors.blue),
    CardItem(title: '觉醒', description: '角色发现自己的特殊能力', color: Colors.green),
    CardItem(title: '牺牲', description: '有人为了他人付出代价', color: Colors.redAccent),
    CardItem(title: '危机', description: '面临生死存亡的考验', color: Colors.deepOrange),
    CardItem(title: '机遇', description: '意外的机缘降临', color: Colors.amber),
  ];

  static const sceneSettings = [
    CardItem(title: '繁华都市', description: '现代都市的霓虹夜景', color: Colors.blueGrey),
    CardItem(title: '深山古刹', description: '云雾缭绕的隐世之地', color: Colors.brown),
    CardItem(title: '荒漠绿洲', description: '沙漠中的生命之源', color: Colors.teal),
    CardItem(title: '深海遗迹', description: '沉没的古老文明', color: Colors.indigo),
    CardItem(title: '星际飞船', description: '太空中的钢铁巨兽', color: Colors.blue),
    CardItem(title: '古风宫廷', description: '雕梁画栋的宫殿', color: Colors.deepPurple),
    CardItem(title: '幽暗森林', description: '危机四伏的密林', color: Colors.green),
    CardItem(title: '火山熔岩', description: '烈焰沸腾的禁地', color: Colors.red),
  ];

  static const characterTraits = [
    CardItem(title: '沉默寡言', description: '话少但每句都很有分量', color: Colors.grey),
    CardItem(title: '活泼开朗', description: '永远充满正能量', color: Colors.amber),
    CardItem(title: '腹黑深沉', description: '表面温和，内心算计', color: Colors.purple),
    CardItem(title: '正直勇敢', description: '面对不公会挺身而出', color: Colors.blue),
    CardItem(title: '优柔寡断', description: '总是难以做出决定', color: Colors.orange),
    CardItem(title: '冷血无情', description: '为了目标不择手段', color: Colors.red),
    CardItem(title: '天真烂漫', description: '对世界充满好奇', color: Colors.pink),
    CardItem(title: '老谋深算', description: '经验丰富的谋略家', color: Colors.brown),
  ];

  static const randomEvents = [
    CardItem(title: '获得宝物', description: '意外得到珍贵物品', color: Colors.amber),
    CardItem(title: '卷入阴谋', description: '被卷入未知的阴谋', color: Colors.grey),
    CardItem(title: '邂逅奇遇', description: '遇到改变命运的人', color: Colors.pink),
    CardItem(title: '突破瓶颈', description: '实力获得突破', color: Colors.green),
    CardItem(title: '遭遇追杀', description: '被强大敌人追杀', color: Colors.red),
    CardItem(title: '发现秘密', description: '揭开尘封的秘密', color: Colors.purple),
    CardItem(title: '陷入绝境', description: '四面楚歌的困境', color: Colors.deepOrange),
    CardItem(title: '贵人相助', description: '得到贵人的帮助', color: Colors.blue),
  ];
}

/// 卡片抽签对话框
class CardDrawDialog extends StatefulWidget {
  final List<CardItem> cards;
  final String title;

  const CardDrawDialog({
    super.key,
    required this.cards,
    this.title = '抽签',
  });

  @override
  State<CardDrawDialog> createState() => _CardDrawDialogState();
}

class _CardDrawDialogState extends State<CardDrawDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _random = Random();
  
  int? _selectedIndex;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _draw() {
    if (_isAnimating) return;
    
    setState(() {
      _selectedIndex = null;
      _isAnimating = true;
    });

    _controller.forward(from: 0).then((_) {
      setState(() {
        _selectedIndex = _random.nextInt(widget.cards.length);
        _isAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            
            // 卡片显示区
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                if (_selectedIndex == null || _isAnimating) {
                  return _buildAnimatingCard(colorScheme);
                }
                return _buildResultCard(widget.cards[_selectedIndex!]);
              },
            ),
            
            const SizedBox(height: 24),
            
            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
                FilledButton.icon(
                  onPressed: _isAnimating ? null : _draw,
                  icon: const Icon(Icons.casino),
                  label: const Text('抽签'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatingCard(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final index = (_animation.value * widget.cards.length).floor() % widget.cards.length;
        return Container(
          width: 200,
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  _isAnimating ? '抽取中...' : '点击抽签',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard(CardItem card) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 200,
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  card.color ?? Colors.blue,
                  (card.color ?? Colors.blue).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (card.color ?? Colors.blue).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (card.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      card.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 显示卡片抽签对话框的便捷函数
Future<void> showCardDrawDialog(
  BuildContext context, {
  List<CardItem>? cards,
  String title = '随机抽签',
}) async {
  final items = cards ?? CardDeck.plotTwists;
  
  await showDialog(
    context: context,
    builder: (context) => CardDrawDialog(
      cards: items,
      title: title,
    ),
  );
}

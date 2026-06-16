import 'package:flutter/material.dart';
import '../services/webdav_service.dart';
import '../services/recycle_bin_service.dart';
import '../services/memo_service.dart';
import '../screens/webdav_sync_dialog.dart';
import '../screens/recycle_bin_dialog.dart';
import '../screens/memo_dialog.dart';
import '../screens/skill_marketplace_screen.dart';
import '../screens/card_draw_dialog.dart';
import '../screens/novel_crawler_dialog.dart';
import '../screens/distill_dialog.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // AI 功能区
          _buildSectionHeader(context, 'AI 助手'),
          _buildListTile(
            context,
            icon: Icons.chat_outlined,
            title: 'AI 写作助手',
            subtitle: '对话式 AI 创作辅助',
            onTap: () {
              // TODO: 跳转到 AI 助手
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请在首页点击底部导航进入 AI 助手')),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.auto_fix_high,
            title: '文段处理',
            subtitle: '扩写、缩写、润色、改写',
            onTap: () => showDistillDialog(context),
          ),
          _buildListTile(
            context,
            icon: Icons.store_outlined,
            title: '技能市场',
            subtitle: 'AI 技能模板和插件',
            onTap: () => showSkillMarketplace(context),
          ),

          const Divider(),

          // 工具区
          _buildSectionHeader(context, '创作工具'),
          _buildListTile(
            context,
            icon: Icons.download_outlined,
            title: '导入网络小说',
            subtitle: '从笔趣阁、起点等网站导入',
            onTap: () => showNovelCrawlerDialog(context),
          ),
          _buildListTile(
            context,
            icon: Icons.save_alt_outlined,
            title: '导出文件',
            subtitle: '导出为 TXT、Markdown、Word',
            onTap: () {
              // TODO: 显示导出选项
            },
          ),
          _buildListTile(
            context,
            icon: Icons.casino_outlined,
            title: '创作灵感',
            subtitle: '随机抽签获取创作灵感',
            onTap: () => _showInspirationDialog(context),
          ),

          const Divider(),

          // 云同步区
          _buildSectionHeader(context, '云同步'),
          _buildListTile(
            context,
            icon: Icons.cloud_sync_outlined,
            title: 'WebDav 同步',
            subtitle: '同步到私有云盘',
            onTap: () => _showWebDavSync(context),
          ),

          const Divider(),

          // 便签区
          _buildSectionHeader(context, '便签'),
          _buildListTile(
            context,
            icon: Icons.note_alt_outlined,
            title: '便签管理',
            subtitle: '快捷便签和备忘录',
            onTap: () => _showMemoDialog(context),
          ),

          const Divider(),

          // 回收站区
          _buildSectionHeader(context, '数据管理'),
          _buildListTile(
            context,
            icon: Icons.delete_outline,
            title: '回收站',
            subtitle: '恢复误删的内容',
            onTap: () => _showRecycleBin(context),
          ),

          const Divider(),

          // 关于区
          _buildSectionHeader(context, '关于'),
          _buildListTile(
            context,
            icon: Icons.info_outline,
            title: '关于 OpenWrite',
            subtitle: '版本 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _buildListTile(
            context,
            icon: Icons.help_outline,
            title: '使用帮助',
            subtitle: '了解应用使用技巧',
            onTap: () => _showHelpDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showWebDavSync(BuildContext context) {
    final service = WebDavService();
    showWebDavSyncDialog(
      context,
      service: service,
      onSyncComplete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('同步完成')),
        );
      },
    );
  }

  void _showRecycleBin(BuildContext context) {
    final service = RecycleBinService('');
    showRecycleBinDialog(
      context,
      service: service,
      onRestore: (id, type) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已恢复')),
        );
      },
      onDelete: (id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已永久删除')),
        );
      },
    );
  }

  void _showMemoDialog(BuildContext context) {
    showMemoDialog(context);
  }

  void _showInspirationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择灵感类型'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              showCardDrawDialog(context, 
                cards: CardDeck.plotTwists,
                title: '情节灵感',
              );
            },
            child: const ListTile(
              leading: Icon(Icons.auto_stories),
              title: Text('情节灵感'),
              subtitle: Text('随机生成情节转折'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              showCardDrawDialog(context,
                cards: CardDeck.sceneSettings,
                title: '场景灵感',
              );
            },
            child: const ListTile(
              leading: Icon(Icons.location_on),
              title: Text('场景灵感'),
              subtitle: Text('随机生成场景设定'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              showCardDrawDialog(context,
                cards: CardDeck.characterTraits,
                title: '人物灵感',
              );
            },
            child: const ListTile(
              leading: Icon(Icons.person),
              title: Text('人物灵感'),
              subtitle: Text('随机生成角色特质'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              showCardDrawDialog(context,
                cards: CardDeck.randomEvents,
                title: '随机事件',
              );
            },
            child: const ListTile(
              leading: Icon(Icons.shuffle),
              title: Text('随机事件'),
              subtitle: Text('随机生成剧情事件'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'OpenWrite',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '墨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      children: [
        const Text('一款专注于小说创作的笔记应用'),
        const SizedBox(height: 8),
        const Text('支持 AI 辅助创作、云同步、多格式导出'),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📝 笔记功能',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('在笔记页面点击右下角按钮创建新笔记'),
              SizedBox(height: 12),
              Text('📚 小说功能',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('切换到小说页面，创建和管理你的小说项目'),
              SizedBox(height: 12),
              Text('🤖 AI 助手',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('配置 API Key 后可使用 AI 对话和文段处理功能'),
              SizedBox(height: 12),
              Text('☁️ 云同步',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('在设置中配置 WebDav 服务器实现云端备份'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

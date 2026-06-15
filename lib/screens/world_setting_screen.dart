import 'package:flutter/material.dart';
import '../models/novel.dart';

/// 世界观设定页面
class WorldSettingScreen extends StatefulWidget {
  final WorldSetting worldSetting;
  final Function(WorldSetting) onSave;

  const WorldSettingScreen({
    super.key,
    required this.worldSetting,
    required this.onSave,
  });

  @override
  State<WorldSettingScreen> createState() => _WorldSettingScreenState();
}

class _WorldSettingScreenState extends State<WorldSettingScreen> {
  late TextEditingController _timePeriodController;
  late TextEditingController _locationController;
  late TextEditingController _cultureController;
  late TextEditingController _magicSystemController;
  late TextEditingController _politicsController;
  late TextEditingController _economyController;
  late TextEditingController _technologyController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _timePeriodController = TextEditingController(text: widget.worldSetting.timePeriod);
    _locationController = TextEditingController(text: widget.worldSetting.location);
    _cultureController = TextEditingController(text: widget.worldSetting.culture);
    _magicSystemController = TextEditingController(text: widget.worldSetting.magicSystem);
    _politicsController = TextEditingController(text: widget.worldSetting.politics);
    _economyController = TextEditingController(text: widget.worldSetting.economy);
    _technologyController = TextEditingController(text: widget.worldSetting.technology);
    _descriptionController = TextEditingController(text: widget.worldSetting.description);
  }

  @override
  void dispose() {
    _timePeriodController.dispose();
    _locationController.dispose();
    _cultureController.dispose();
    _magicSystemController.dispose();
    _politicsController.dispose();
    _economyController.dispose();
    _technologyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final setting = WorldSetting(
      timePeriod: _timePeriodController.text,
      location: _locationController.text,
      culture: _cultureController.text,
      magicSystem: _magicSystemController.text,
      politics: _politicsController.text,
      economy: _economyController.text,
      technology: _technologyController.text,
      description: _descriptionController.text,
    );
    widget.onSave(setting);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('世界观设定'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField(
            controller: _timePeriodController,
            label: '时代背景',
            hint: '如：远古时代、现代社会、未来世界',
            icon: Icons.history,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _locationController,
            label: '地理环境',
            hint: '如：中原大陆、九州世界、星际帝国',
            icon: Icons.public,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cultureController,
            label: '文化风俗',
            hint: '宗教信仰、节日习俗、社会风貌',
            icon: Icons.temple_buddhist,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _magicSystemController,
            label: '力量体系',
            hint: '如：修仙境界、魔法等级、异能觉醒',
            icon: Icons.auto_awesome,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _politicsController,
            label: '政治格局',
            hint: '如：皇权专制、民主共和、宗门林立',
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _economyController,
            label: '经济体系',
            hint: '货币制度、贸易方式、资源分布',
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _technologyController,
            label: '科技/技艺',
            hint: '如：炼器炼丹、机关阵法、星际科技',
            icon: Icons.science,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: '世界简介',
            hint: '对这个世界的整体描述...',
            icon: Icons.description,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

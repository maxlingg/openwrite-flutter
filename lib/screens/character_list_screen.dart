import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../models/novel.dart';
import '../widgets/page_decoration.dart';

/// 角色详情页面
class CharacterDetailScreen extends StatefulWidget {
  final String novelId;
  final Character character;

  const CharacterDetailScreen({
    super.key,
    required this.novelId,
    required this.character,
  });

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _appearanceController;
  late TextEditingController _personalityController;
  late TextEditingController _backstoryController;
  late TextEditingController _motivationController;
  late String _role;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.character.name);
    _descriptionController = TextEditingController(text: widget.character.description);
    _appearanceController = TextEditingController(text: widget.character.appearance);
    _personalityController = TextEditingController(text: widget.character.personality);
    _backstoryController = TextEditingController(text: widget.character.backstory);
    _motivationController = TextEditingController(text: widget.character.motivation);
    _role = widget.character.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _backstoryController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  Future<void> _saveCharacter() async {
    final updated = widget.character.copyWith(
      name: _nameController.text.trim(),
      role: _role,
      description: _descriptionController.text,
      appearance: _appearanceController.text,
      personality: _personalityController.text,
      backstory: _backstoryController.text,
      motivation: _motivationController.text,
    );
    await context.read<NovelProvider>().updateCharacter(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存'), duration: Duration(seconds: 1)),
      );
      setState(() => _hasChanges = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      child: PageDecoration.standardScaffold(
        context: context,
        title: '角色设定',
        showBackButton: true,
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _saveCharacter,
              icon: const Icon(Icons.save_outlined),
              label: const Text('保存'),
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('删除角色', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认删除'),
                    content: Text('确定要删除角色"${widget.character.name}"吗？'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await context.read<NovelProvider>().deleteCharacter(widget.character.id, widget.novelId);
                  if (mounted) Navigator.pop(context);
                }
              }
            },
          ),
        ],
        body: PageDecoration.scrollContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像和名称
              _buildHeader(),
              
              PageDecoration.divider(height: 24),
              
              // 外貌特征
              _buildSection('外貌特征', _appearanceController, Icons.person_outline),
              PageDecoration.divider(height: 16),
              
              // 性格特点
              _buildSection('性格特点', _personalityController, Icons.psychology_outlined),
              PageDecoration.divider(height: 16),
              
              // 角色背景
              _buildSection('角色背景', _backstoryController, Icons.history_edu_outlined, maxLines: 6),
              PageDecoration.divider(height: 16),
              
              // 动机目标
              _buildSection('动机目标', _motivationController, Icons.flag_outlined, maxLines: 4),
              PageDecoration.divider(height: 16),
              
              // 备注
              _buildSection('备注', _descriptionController, Icons.note_outlined, maxLines: 4),
              
              PageDecoration.divider(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像
        CircleAvatar(
          radius: 40,
          backgroundColor: _getRoleColor(_role).withOpacity(0.2),
          child: Text(
            _nameController.text.isEmpty ? '?' : _nameController.text[0],
            style: TextStyle(fontSize: 32, color: _getRoleColor(_role)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              PageDecoration.inputField(
                controller: _nameController,
                label: '姓名',
                onChanged: (_) => setState(() => _hasChanges = true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: '角色定位'),
                items: CharacterRole.names.entries.map((e) {
                  return DropdownMenuItem(value: e.key, child: Text(e.value));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() {
                    _role = value;
                    _hasChanges = true;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, TextEditingController controller, IconData icon, {int maxLines = 3}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: '输入$title...',
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() => _hasChanges = true),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'protagonist':
        return Colors.purple;
      case 'antagonist':
        return Colors.red;
      case 'supporting':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

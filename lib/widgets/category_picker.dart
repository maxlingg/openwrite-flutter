import 'package:flutter/material.dart';

class CategoryPicker extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const CategoryPicker({super.key, required this.selectedCategory, required this.onSelect});

  static Future<String?> show(BuildContext context, String currentCategory) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CategoryPicker(
        selectedCategory: currentCategory,
        onSelect: (category) => Navigator.pop(context, category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      {'id': 'writing', 'name': '写作', 'emoji': '✍️'},
      {'id': 'work', 'name': '工作', 'emoji': '💼'},
      {'id': 'life', 'name': '生活', 'emoji': '🌿'},
      {'id': 'study', 'name': '学习', 'emoji': '📚'},
      {'id': 'idea', 'name': '灵感', 'emoji': '💡'},
      {'id': 'diary', 'name': '日记', 'emoji': '📔'},
    ];

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('选择分类', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat['id'] == selectedCategory;
                return GestureDetector(
                  onTap: () => onSelect(cat['id']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? colorScheme.primary : Colors.transparent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat['emoji']!, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(cat['name']!, style: TextStyle(fontWeight: FontWeight.w500, color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

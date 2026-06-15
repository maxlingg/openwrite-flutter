import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

/// 分类选择器底部弹窗
class CategoryPicker extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const CategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.onSelect,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动把手
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkOutline : AppTheme.lightOutline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  '选择分类',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 分类网格
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: Category.all.length,
              itemBuilder: (context, index) {
                final category = Category.all[index];
                final isSelected = category.id == selectedCategory;
                final categoryColor = AppTheme.categoryColors[category.id]!;

                return _CategoryItem(
                  category: category,
                  isSelected: isSelected,
                  categoryColor: categoryColor,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(category.id);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final CategoryColor categoryColor;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final surfaceColor = isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? categoryColor.background : surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标容器
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 名称
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? categoryColor.text : 
                       (isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

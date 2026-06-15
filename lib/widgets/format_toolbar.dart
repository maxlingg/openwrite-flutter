import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// 格式化操作类型
enum FormatAction {
  bold,
  italic,
  underline,
  alignLeft,
  alignCenter,
  alignRight,
  bulletList,
  numberedList,
  quote,
  heading,
}

/// 格式工具栏组件
class FormatToolbar extends StatelessWidget {
  final ValueChanged<FormatAction> onFormat;
  final Set<FormatAction> activeFormats;

  const FormatToolbar({
    super.key,
    required this.onFormat,
    this.activeFormats = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final surfaceColor = isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant;
    final textColor = isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant;
    final outlineColor = isDark ? AppTheme.darkOutline : AppTheme.lightOutline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        border: Border(
          top: BorderSide(color: outlineColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 文本样式组
            _buildFormatButton(
              context: context,
              icon: Icons.format_bold_rounded,
              action: FormatAction.bold,
              isActive: activeFormats.contains(FormatAction.bold),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            _buildFormatButton(
              context: context,
              icon: Icons.format_italic_rounded,
              action: FormatAction.italic,
              isActive: activeFormats.contains(FormatAction.italic),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            _buildFormatButton(
              context: context,
              icon: Icons.format_underline_rounded,
              action: FormatAction.underline,
              isActive: activeFormats.contains(FormatAction.underline),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            
            _buildDivider(outlineColor),
            
            // 对齐组
            _buildFormatButton(
              context: context,
              icon: Icons.format_align_left_rounded,
              action: FormatAction.alignLeft,
              isActive: activeFormats.contains(FormatAction.alignLeft),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            _buildFormatButton(
              context: context,
              icon: Icons.format_align_center_rounded,
              action: FormatAction.alignCenter,
              isActive: activeFormats.contains(FormatAction.alignCenter),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            _buildFormatButton(
              context: context,
              icon: Icons.format_align_right_rounded,
              action: FormatAction.alignRight,
              isActive: activeFormats.contains(FormatAction.alignRight),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            
            _buildDivider(outlineColor),
            
            // 列表组
            _buildFormatButton(
              context: context,
              icon: Icons.format_list_bulleted_rounded,
              action: FormatAction.bulletList,
              isActive: activeFormats.contains(FormatAction.bulletList),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            _buildFormatButton(
              context: context,
              icon: Icons.format_list_numbered_rounded,
              action: FormatAction.numberedList,
              isActive: activeFormats.contains(FormatAction.numberedList),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
            _buildFormatButton(
              context: context,
              icon: Icons.format_quote_rounded,
              action: FormatAction.quote,
              isActive: activeFormats.contains(FormatAction.quote),
              primaryColor: primaryColor,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatButton({
    required BuildContext context,
    required IconData icon,
    required FormatAction action,
    required bool isActive,
    required Color primaryColor,
    required Color surfaceColor,
    required Color textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onFormat(action);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? primaryColor.withOpacity(0.1) : surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? primaryColor : textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: color,
    );
  }
}

import 'package:flutter/material.dart';

/// 统一页面装饰组件 - 规范化所有页面的排版风格
class PageDecoration {
  /// 标准页面 Scaffold
  static Scaffold standardScaffold({
    required BuildContext context,
    required String title,
    Widget? body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    bool showBackButton = false,
    PreferredSizeWidget? bottom,
    Color? backgroundColor,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: bottom,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  /// 带滚动的内容区域
  static Widget scrollContent({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    ScrollController? controller,
  }) {
    return SingleChildScrollView(
      controller: controller,
      padding: padding,
      child: child,
    );
  }

  /// 区块标题
  static Widget sectionTitle(BuildContext context, String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  /// 标准卡片
  static Widget card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    EdgeInsets margin = const EdgeInsets.only(bottom: 12),
    VoidCallback? onTap,
    Color? color,
  }) {
    final cardWidget = Card(
      color: color,
      margin: margin,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: cardWidget,
      );
    }

    return cardWidget;
  }

  /// 标准列表项
  static Widget listTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: iconColor),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  /// 空状态
  static Widget emptyState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }

  /// 统计卡片行
  static Widget statsRow(BuildContext context, List<StatItem> items) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primaryContainer, colorScheme.primaryContainer.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          return Column(
            children: [
              Icon(item.icon, size: 28, color: colorScheme.onPrimaryContainer),
              const SizedBox(height: 8),
              Text(
                item.value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 标准输入框
  static Widget inputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// 标准按钮
  static Widget button({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isOutlined = false,
    IconData? icon,
    bool isExpanded = true,
  }) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final buttonWidget = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          )
        : FilledButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          );

    return isExpanded ? SizedBox(width: double.infinity, child: buttonWidget) : buttonWidget;
  }

  /// 双按钮行
  static Widget buttonRow({
    required String label1,
    required VoidCallback? onPressed1,
    String? label2,
    VoidCallback? onPressed2,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onPressed1,
            child: Text(label1),
          ),
        ),
        if (label2 != null && onPressed2 != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: isLoading ? null : onPressed2,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(label2),
            ),
          ),
        ],
      ],
    );
  }

  /// 分隔线
  static Widget divider({double height = 32}) {
    return SizedBox(height: height);
  }

  /// 选择器网格
  static Widget choiceChipGrid({
    required List<String> items,
    required String selectedItem,
    required void Function(String) onSelected,
    bool wrap = true,
  }) {
    final chips = items.map((item) {
      return ChoiceChip(
        label: Text(item),
        selected: selectedItem == item,
        onSelected: (selected) {
          if (selected) onSelected(item);
        },
      );
    }).toList();

    if (wrap) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: chip,
          );
        }).toList(),
      ),
    );
  }
}

/// 统计项
class StatItem {
  final IconData icon;
  final String value;
  final String label;

  const StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
}

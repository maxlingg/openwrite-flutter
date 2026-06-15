import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 现代化搜索栏组件
class SearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchBar({
    super.key,
    this.hintText = '搜索笔记、标签或内容...',
    required this.onChanged,
    this.onClear,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: _isFocused 
            ? primaryColor 
            : (isDark ? AppTheme.darkOutline : AppTheme.lightOutline),
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: _isFocused ? AppTheme.shadowMd : AppTheme.shadowSm,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused 
              ? primaryColor 
              : (isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant),
          ),
          suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                  widget.onClear?.call();
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

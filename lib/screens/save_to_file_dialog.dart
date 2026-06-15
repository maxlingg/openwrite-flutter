import 'package:flutter/material.dart';
import '../models/novel.dart';

/// 导出格式
enum ExportFormat {
  txt('纯文本 (.txt)', 'txt'),
  md('Markdown (.md)', 'md'),
  docx('Word 文档 (.docx)', 'docx'),
  json('JSON 数据 (.json)', 'json');

  final String label;
  final String extension;
  const ExportFormat(this.label, this.extension);
}

/// 保存到文件对话框
class SaveToFileDialog extends StatefulWidget {
  final Novel? novel;
  final String? chapterContent;
  final Function(ExportFormat format)? onExport;

  const SaveToFileDialog({
    super.key,
    this.novel,
    this.chapterContent,
    this.onExport,
  });

  @override
  State<SaveToFileDialog> createState() => _SaveToFileDialogState();
}

class _SaveToFileDialogState extends State<SaveToFileDialog> {
  ExportFormat _selectedFormat = ExportFormat.txt;
  bool _includeChapters = true;
  bool _includeCharacters = true;
  bool _includeWorldSetting = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.save_alt, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '导出文件',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 格式选择
            const Text('导出格式', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExportFormat.values.map((format) {
                return ChoiceChip(
                  label: Text(format.label),
                  selected: _selectedFormat == format,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFormat = format);
                  },
                );
              }).toList(),
            ),

            if (widget.novel != null) ...[
              const SizedBox(height: 16),

              // 导出选项
              const Text('导出内容', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('章节正文'),
                value: _includeChapters,
                onChanged: (v) => setState(() => _includeChapters = v ?? true),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('人物设定'),
                value: _includeCharacters,
                onChanged: (v) => setState(() => _includeCharacters = v ?? true),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('世界观设定'),
                value: _includeWorldSetting,
                onChanged: (v) => setState(() => _includeWorldSetting = v ?? true),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],

            const SizedBox(height: 24),

            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    widget.onExport?.call(_selectedFormat);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('导出'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示保存到文件对话框的便捷函数
Future<void> showSaveToFileDialog(
  BuildContext context, {
  Novel? novel,
  String? chapterContent,
  Function(ExportFormat format)? onExport,
}) async {
  await showDialog(
    context: context,
    builder: (context) => SaveToFileDialog(
      novel: novel,
      chapterContent: chapterContent,
      onExport: onExport,
    ),
  );
}

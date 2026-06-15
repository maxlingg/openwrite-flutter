import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteCardWidget extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NoteCardWidget({super.key, required this.note, required this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(note.category);

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: colorScheme.errorContainer, borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_rounded, color: colorScheme.onErrorContainer),
      ),
      confirmDismiss: (direction) async {
        onDelete?.call();
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(int.parse(categoryColor['text']!.replaceFirst('0x', '0xFF'))), Color(int.parse(categoryColor['text']!.replaceFirst('0x', '0xFF'))).withOpacity(0.6)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Color(int.parse(categoryColor['bg']!.replaceFirst('0x', '0xFF'))), borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(categoryColor['emoji']!, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(note.categoryName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(int.parse(categoryColor['text']!.replaceFirst('0x', '0xFF'))))),
                          ]),
                        ),
                        const Spacer(),
                        Text(_formatDate(note.updatedAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(note.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (note.excerpt.isNotEmpty) ...[const SizedBox(height: 8), Text(note.excerpt, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis)],
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(Icons.text_fields_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${note.wordCount} 字', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _getCategoryColor(String category) {
    const colors = {
      'writing': {'emoji': '✍️', 'bg': '0xFFE8DEF8', 'text': '0xFF6750A4'},
      'work': {'emoji': '💼', 'bg': '0xFFE3F2FD', 'text': '0xFF1976D2'},
      'life': {'emoji': '🌿', 'bg': '0xFFE8F5E9', 'text': '0xFF388E3C'},
      'study': {'emoji': '📚', 'bg': '0xFFFFF3E0', 'text': '0xFFF57C00'},
      'idea': {'emoji': '💡', 'bg': '0xFFFFFDE7', 'text': '0xFFFBC02D'},
      'diary': {'emoji': '📔', 'bg': '0xFFFCE4EC', 'text': '0xFFE91E63'},
    };
    return colors[category] ?? colors['writing']!;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return '今天';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${date.month}-${date.day}';
  }
}

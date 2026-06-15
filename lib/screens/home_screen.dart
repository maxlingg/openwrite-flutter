import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../models/note.dart';
import 'editor_screen.dart';
import 'settings_screen.dart';
import '../widgets/category_chip.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('📝', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('墨韵笔记', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('${notesProvider.notesCount} 篇笔记', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        themeProvider.toggleTheme();
                      },
                      icon: Icon(themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarWidget(
                  controller: _searchController,
                  onChanged: (query) => notesProvider.setSearchQuery(query),
                  hintText: '搜索笔记...',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    CategoryChip(label: '全部', isSelected: notesProvider.selectedCategory == null, onTap: () => notesProvider.setSelectedCategory(null)),
                    const SizedBox(width: 8),
                    ...Category.all.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(label: cat.name, emoji: cat.emoji, isSelected: notesProvider.selectedCategory == cat.id, onTap: () => notesProvider.setSelectedCategory(cat.id)),
                    )),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            if (notesProvider.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (notesProvider.notes.isEmpty)
              SliverFillRemaining(child: _buildEmptyState(context, notesProvider.searchQuery.isNotEmpty))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notesProvider.notes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NoteCardWidget(
                          note: note,
                          onTap: () => _openNote(note),
                          onDelete: () => _deleteNote(note),
                        ),
                      );
                    },
                    childCount: notesProvider.notes.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNote,
        icon: const Icon(Icons.add_rounded),
        label: const Text('新建笔记'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearchResult) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
            child: Icon(isSearchResult ? Icons.search_off_rounded : Icons.note_add_rounded, size: 40, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(isSearchResult ? '未找到笔记' : '暂无笔记', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(isSearchResult ? '尝试其他关键词' : '点击下方按钮创建第一篇笔记', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  void _openNote(Note note) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(note: note)));
  }

  Future<void> _createNote() async {
    final note = await context.read<NotesProvider>().createNote();
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(note: note)));
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除笔记'),
        content: Text('确定要删除 "${note.title}" 吗？\n删除后可从回收站恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<NotesProvider>().deleteNote(note.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('笔记已移入回收站'), behavior: SnackBarBehavior.floating));
    }
  }
}

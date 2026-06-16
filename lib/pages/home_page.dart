import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar.dart' as custom;
import '../widgets/modern_fab.dart';
import 'editor_page.dart';
import '../screens/novel_list_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/ai_writing_tools_screen.dart';
import '../screens/ai_novel_writing_screen.dart';
import '../screens/settings_screen_new.dart';
import '../providers/novel_provider.dart';

/// 首页 - 笔记列表
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final NoteService _noteService = NoteService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentIndex = 0;
  
  late AnimationController _listAnimationController;
  late Animation<double> _listAnimation;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutQuart,
    );
    _loadNotes();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _noteService.getAllNotes();
      setState(() {
        _notes = notes;
        _filteredNotes = notes;
        _isLoading = false;
      });
      _listAnimationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes.where((note) {
          return note.title.toLowerCase().contains(query.toLowerCase()) ||
                 note.excerpt.toLowerCase().contains(query.toLowerCase()) ||
                 note.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  Future<void> _onNoteTap(Note note) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(note: note),
      ),
    );
    
    if (result != null) {
      await _loadNotes();
    }
  }

  Future<void> _onCreateNote() async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => const EditorPage(),
      ),
    );
    
    if (result != null) {
      await _loadNotes();
    }
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      if (index == 1) {
        context.read<NovelProvider>().loadNovels();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildNotesPage(),
          const NovelListScreen(),
          const AINovelWritingScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: '笔记',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: '小说',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI写作',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? ModernFAB(
              onPressed: _onCreateNote,
              icon: Icons.add_rounded,
              tooltip: '新建笔记',
            )
          : null,
    );
  }

  Widget _buildNotesPage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 头部
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Center(
                      child: Text(
                        '墨',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Noto Serif SC',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 标题
                  Text(
                    '墨韵笔记',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  // AI 助手按钮
                  IconButton(
                    icon: const Icon(Icons.smart_toy_outlined),
                    tooltip: 'AI 助手',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                  ),
                  // 设置按钮
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: '设置',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  // 主题切换
                  _ThemeToggleButton(),
                ],
              ),
            ),
            
            // 搜索栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: custom.SearchBar(
                onChanged: _onSearch,
              ),
            ),
            
            // 笔记计数
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '最近笔记',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      '${_filteredNotes.length} 篇',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 笔记列表
            Expanded(
              child: _isLoading
                ? _buildLoading()
                : _filteredNotes.isEmpty
                  ? _buildEmpty()
                  : _buildNotesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmpty() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_note_rounded,
              size: 40,
              color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? '暂无笔记' : '未找到相关笔记',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? '点击下方按钮创建第一篇笔记' : '尝试其他关键词搜索',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: _listAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _listAnimationController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 0.6),
                (index * 0.1 + 0.4).clamp(0.4, 1.0),
                curve: Curves.easeOutQuart,
              ),
            )),
            child: NoteCardWidget(
              note: _filteredNotes[index],
              onTap: () => _onNoteTap(_filteredNotes[index]),
            ),
          ),
        );
      },
    );
  }
}

/// 主题切换按钮
class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Provider.of<ThemeNotifier>(context, listen: false).toggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              size: 20,
              color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// 主题状态管理
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setDark(bool value) {
    _isDark = value;
    notifyListeners();
  }
}

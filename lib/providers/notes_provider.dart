import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../services/recycle_bin_service.dart';

/// 笔记状态管理
class NotesProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final RecycleBinService _recycleBinService;
  
  List<Note> _notes = [];
  List<RecycleBinItem> _deletedNotes = [];
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  NotesProvider() : _recycleBinService = RecycleBinService(_storageService);

  List<Note> get notes => _searchQuery.isEmpty && _selectedCategory == null
      ? _notes
      : _filteredNotes;
  List<Note> get allNotes => _notes;
  List<RecycleBinItem> get deletedNotes => _deletedNotes;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get notesCount => _notes.length;
  int get totalWordCount => _notes.fold(0, (sum, note) => sum + note.wordCount);

  List<Note> get _filteredNotes {
    var filtered = _notes;
    if (_selectedCategory != null) {
      filtered = filtered.where((n) => n.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((n) =>
          n.title.toLowerCase().contains(query) ||
          n.content.toLowerCase().contains(query) ||
          n.tags.any((t) => t.toLowerCase().contains(query))
      ).toList();
    }
    return filtered;
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _storageService.getAllNotes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDeletedNotes() async {
    try {
      _deletedNotes = await _recycleBinService.getDeletedNotes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Note> createNote({
    String title = '',
    String content = '',
    String category = 'writing',
    List<String> tags = const [],
  }) async {
    final note = Note.create(
      title: title,
      content: content,
      category: category,
      tags: tags,
    );
    await _storageService.insertNote(note);
    _notes.insert(0, note);
    notifyListeners();
    return note;
  }

  Future<void> updateNote(Note note) async {
    final updatedNote = note.copyWith(
      excerpt: Note._generateExcerpt(note.content),
      wordCount: note.content.length,
      updatedAt: DateTime.now(),
    );
    await _storageService.updateNote(updatedNote);
    
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      _notes.removeAt(index);
      _notes.insert(0, updatedNote);
    }
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _storageService.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> permanentlyDeleteNote(String id) async {
    await _recycleBinService.permanentlyDelete(id);
    _deletedNotes.removeWhere((item) => item.note.id == id);
    notifyListeners();
  }

  Future<void> restoreNote(String id) async {
    await _recycleBinService.restoreNote(id);
    _deletedNotes.removeWhere((item) => item.note.id == id);
    await loadNotes();
    notifyListeners();
  }

  Future<void> emptyRecycleBin() async {
    await _recycleBinService.emptyRecycleBin();
    _deletedNotes.clear();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  Future<Map<String, int>> getStatistics() async {
    final count = await _storageService.getNotesCount();
    final wordCount = await _storageService.getTotalWordCount();
    return {'notes': count, 'words': wordCount};
  }

  Future<String?> exportToJson() async {
    return await _storageService.exportToJson();
  }

  Future<int> importFromJson(String json) async {
    final count = await _storageService.importFromJson(json);
    await loadNotes();
    return count;
  }
}

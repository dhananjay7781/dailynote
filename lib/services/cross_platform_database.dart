import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/note.dart';

class CrossPlatformDatabaseHelper {
  static final CrossPlatformDatabaseHelper instance = CrossPlatformDatabaseHelper._init();
  
  CrossPlatformDatabaseHelper._init();

  // In-memory storage for web
  List<Category> _categories = [];
  List<Note> _notes = [];
  int _categoryIdCounter = 1;
  int _noteIdCounter = 1;

  Future<void> initializeDatabase() async {
    if (kIsWeb) {
      await _loadFromWebStorage();
      if (_categories.isEmpty) {
        await _createDefaultCategory();
      }
    } else {
      // For native platforms, we'll still use the existing SQLite implementation
      // but this provides a fallback for web
      if (_categories.isEmpty) {
        await _createDefaultCategory();
      }
    }
  }

  Future<void> _createDefaultCategory() async {
    final defaultCategory = Category(
      id: _categoryIdCounter++,
      name: 'General',
      color: Colors.blue,
      createdAt: DateTime.now(),
    );
    _categories.add(defaultCategory);
    if (kIsWeb) {
      await _saveToWebStorage();
    }
  }

  Future<void> _loadFromWebStorage() async {
    if (!kIsWeb) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load categories
      final categoriesJson = prefs.getString('categories');
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = jsonDecode(categoriesJson);
        _categories = categoriesList.map((json) => Category.fromMap(json)).toList();
        _categoryIdCounter = _categories.isNotEmpty ? _categories.map((c) => c.id!).reduce((a, b) => a > b ? a : b) + 1 : 1;
      }
      
      // Load notes
      final notesJson = prefs.getString('notes');
      if (notesJson != null) {
        final List<dynamic> notesList = jsonDecode(notesJson);
        _notes = notesList.map((json) {
          final categoryId = json['category_id'];
          final category = _categories.firstWhere((c) => c.id == categoryId, 
              orElse: () => _categories.first);
          return Note.fromMap(json, category);
        }).toList();
        _noteIdCounter = _notes.isNotEmpty ? _notes.map((n) => n.id!).reduce((a, b) => a > b ? a : b) + 1 : 1;
      }
    } catch (e) {
      print('Error loading from web storage: $e');
    }
  }

  Future<void> _saveToWebStorage() async {
    if (!kIsWeb) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save categories
      final categoriesJson = jsonEncode(_categories.map((c) => c.toMap()).toList());
      await prefs.setString('categories', categoriesJson);
      
      // Save notes
      final notesJson = jsonEncode(_notes.map((n) => n.toMap()).toList());
      await prefs.setString('notes', notesJson);
    } catch (e) {
      print('Error saving to web storage: $e');
    }
  }

  // Category operations
  Future<int> createCategory(Category category) async {
    final newCategory = Category(
      id: _categoryIdCounter++,
      name: category.name,
      createdAt: category.createdAt,
    );
    _categories.add(newCategory);
    
    if (kIsWeb) {
      await _saveToWebStorage();
    }
    
    return newCategory.id!;
  }

  Future<List<Category>> getCategories() async {
    return List.from(_categories);
  }

  Future<void> updateCategory(Category category) async {
    final categoryIndex = _categories.indexWhere((cat) => cat.id == category.id);
    if (categoryIndex != -1) {
      _categories[categoryIndex] = category;
      if (kIsWeb) {
        await _saveToWebStorage();
      }
    }
  }

  Future<void> deleteCategory(int id) async {
    _categories.removeWhere((category) => category.id == id);
    if (kIsWeb) {
      await _saveToWebStorage();
    }
  }

  // Note operations
  Future<int> createNote(Note note) async {
    final newNote = Note(
      id: _noteIdCounter++,
      content: note.content,
      date: note.date,
      category: note.category,
      status: note.status,
      createdAt: note.createdAt,
    );
    _notes.add(newNote);
    
    if (kIsWeb) {
      await _saveToWebStorage();
    }
    
    return newNote.id!;
  }

  Future<List<Note>> getNotesByDate(DateTime date) async {
    return _notes.where((note) {
      return note.date.year == date.year &&
             note.date.month == date.month &&
             note.date.day == date.day;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Note>> getAllNotes() async {
    return List.from(_notes)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> updateNoteStatus(int id, NoteStatus newStatus) async {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    if (noteIndex != -1) {
      _notes[noteIndex].status = newStatus;
      if (kIsWeb) {
        await _saveToWebStorage();
      }
    }
  }

  Future<void> deleteNote(int id) async {
    _notes.removeWhere((note) => note.id == id);
    if (kIsWeb) {
      await _saveToWebStorage();
    }
  }

  Future<void> deleteAllData() async {
    _notes.clear();
    _categories.clear();
    _noteIdCounter = 1;
    _categoryIdCounter = 1;
    
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notes');
      await prefs.remove('categories');
    }
    
    await _createDefaultCategory();
  }

  Future<Map<NoteStatus, int>> getNoteStatusCounts() async {
    final counts = <NoteStatus, int>{
      NoteStatus.newNote: 0,
      NoteStatus.inProgress: 0,
      NoteStatus.completed: 0,
      NoteStatus.hold: 0,
    };

    for (final note in _notes) {
      counts[note.status] = (counts[note.status] ?? 0) + 1;
    }

    return counts;
  }

  Future<List<Note>> searchNotes(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.content.toLowerCase().contains(lowercaseQuery) ||
             note.category.name.toLowerCase().contains(lowercaseQuery);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

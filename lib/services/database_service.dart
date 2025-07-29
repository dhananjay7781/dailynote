import 'package:flutter/foundation.dart';

// Abstract base class for database operations
abstract class DatabaseService {
  Future<void> initializeDatabase();
  Future<int> createCategory(Map<String, dynamic> category);
  Future<List<Map<String, dynamic>>> getCategories();
  Future<int> createNote(Map<String, dynamic> note);
  Future<List<Map<String, dynamic>>> getNotesByDate(DateTime date);
  Future<List<Map<String, dynamic>>> getAllNotes();
  Future<void> updateNoteStatus(int id, int status);
  Future<void> deleteNote(int id);
  Future<void> deleteAllData();
  Future<Map<String, int>> getNoteStatusCounts();
  Future<List<Map<String, dynamic>>> searchNotes(String query);
}

// Factory to create the appropriate database service
class DatabaseServiceFactory {
  static DatabaseService create() {
    if (kIsWeb) {
      return WebDatabaseService();
    } else {
      return NativeDatabaseService();
    }
  }
}

// Stub implementations - will be replaced by platform-specific files
class WebDatabaseService extends DatabaseService {
  @override
  Future<void> initializeDatabase() async {}
  
  @override
  Future<int> createCategory(Map<String, dynamic> category) async => 0;
  
  @override
  Future<List<Map<String, dynamic>>> getCategories() async => [];
  
  @override
  Future<int> createNote(Map<String, dynamic> note) async => 0;
  
  @override
  Future<List<Map<String, dynamic>>> getNotesByDate(DateTime date) async => [];
  
  @override
  Future<List<Map<String, dynamic>>> getAllNotes() async => [];
  
  @override
  Future<void> updateNoteStatus(int id, int status) async {}
  
  @override
  Future<void> deleteNote(int id) async {}
  
  @override
  Future<void> deleteAllData() async {}
  
  @override
  Future<Map<String, int>> getNoteStatusCounts() async => {};
  
  @override
  Future<List<Map<String, dynamic>>> searchNotes(String query) async => [];
}

class NativeDatabaseService extends DatabaseService {
  @override
  Future<void> initializeDatabase() async {}
  
  @override
  Future<int> createCategory(Map<String, dynamic> category) async => 0;
  
  @override
  Future<List<Map<String, dynamic>>> getCategories() async => [];
  
  @override
  Future<int> createNote(Map<String, dynamic> note) async => 0;
  
  @override
  Future<List<Map<String, dynamic>>> getNotesByDate(DateTime date) async => [];
  
  @override
  Future<List<Map<String, dynamic>>> getAllNotes() async => [];
  
  @override
  Future<void> updateNoteStatus(int id, int status) async {}
  
  @override
  Future<void> deleteNote(int id) async {}
  
  @override
  Future<void> deleteAllData() async {}
  
  @override
  Future<Map<String, int>> getNoteStatusCounts() async => {};
  
  @override
  Future<List<Map<String, dynamic>>> searchNotes(String query) async => [];
}

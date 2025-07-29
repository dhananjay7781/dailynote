import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notebook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        status INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
  }

  // Category CRUD operations
  Future<int> createCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Note CRUD operations
  Future<int> createNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotesByDate(DateTime date) async {
    final db = await instance.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final notes = await db.query(
      'notes',
      where: 'date LIKE ? AND status != ?',
      whereArgs: ['$dateStr%', NoteStatus.deleted.index],
    );

    final categories = await getAllCategories();
    return notes.map((noteMap) {
      final category = categories.firstWhere(
          (cat) => cat.id == noteMap['category_id'],
          orElse: () => Category(
              name: 'Unknown', createdAt: DateTime.now())); // Fallback category
      return Note.fromMap(noteMap, category);
    }).toList();
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final notes = await db.query(
      'notes',
      where: 'status != ?',
      whereArgs: [NoteStatus.deleted.index],
    );

    final categories = await getAllCategories();
    return notes.map((noteMap) {
      final category = categories.firstWhere(
          (cat) => cat.id == noteMap['category_id'],
          orElse: () => Category(
              name: 'Unknown', createdAt: DateTime.now())); // Fallback category
      return Note.fromMap(noteMap, category);
    }).toList();
  }

  Future<int> updateNoteStatus(int id, NoteStatus status) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      {'status': status.index},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllData() async {
    final db = await instance.database;
    await db.delete('notes');
    return await db.delete('categories');
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final notes = await db.query(
      'notes',
      where: 'content LIKE ? AND status != ?',
      whereArgs: ['%$query%', NoteStatus.deleted.index],
    );

    final categories = await getAllCategories();
    return notes.map((noteMap) {
      final category = categories.firstWhere(
          (cat) => cat.id == noteMap['category_id'],
          orElse: () => Category(
              name: 'Unknown', createdAt: DateTime.now())); // Fallback category
      return Note.fromMap(noteMap, category);
    }).toList();
  }

  Future<Map<NoteStatus, int>> getNoteStatusCounts() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM notes 
      WHERE status != ? 
      GROUP BY status
    ''', [NoteStatus.deleted.index]);

    final counts = <NoteStatus, int>{
      NoteStatus.newNote: 0,
      NoteStatus.inProgress: 0,
      NoteStatus.completed: 0,
      NoteStatus.hold: 0,
    };

    for (final row in result) {
      final status = NoteStatus.values[row['status'] as int];
      counts[status] = row['count'] as int;
    }

    return counts;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
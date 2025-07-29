import 'package:dailynote/models/category.dart';

enum NoteStatus { newNote, inProgress, completed, hold, deleted }

class Note {
  int? id;
  final String content;
  final DateTime date;
  final Category category;
  NoteStatus status;
  final DateTime createdAt;

  Note({
    this.id,
    required this.content,
    required this.date,
    required this.category,
    this.status = NoteStatus.newNote,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(),
      'category_id': category.id,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, Category category) {
    return Note(
      id: map['id'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      category: category,
      status: NoteStatus.values[map['status']],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
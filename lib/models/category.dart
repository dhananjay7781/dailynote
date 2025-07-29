import 'package:flutter/material.dart';

class Category {
  int? id;
  final String name;
  final Color color;
  final DateTime createdAt;

  Category({
    this.id,
    required this.name,
    this.color = Colors.blue,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: Color(map['color'] ?? Colors.blue.value),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
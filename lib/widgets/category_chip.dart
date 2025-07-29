import 'package:flutter/material.dart';
import 'package:dailynote/models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;

  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        category.name,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.deepPurple,
    );
  }
}
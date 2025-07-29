import 'package:flutter/material.dart';
import 'package:dailynote/models/note.dart';
import 'package:dailynote/widgets/category_chip.dart';
import 'package:dailynote/widgets/status_chip.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Function(NoteStatus) onStatusChanged;
  final Function() onDeleted;

  const NoteCard({
    super.key,
    required this.note,
    required this.onStatusChanged,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryChip(category: note.category),
                StatusChip(
                  status: note.status,
                  count: null,
                  small: true,
                  onPressed: () {
                    _showStatusMenu(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDeleted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Change Status'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fiber_new, color: Colors.purple),
              title: const Text('New'),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged(NoteStatus.newNote);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.orange),
              title: const Text('In Progress'),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged(NoteStatus.inProgress);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Completed'),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged(NoteStatus.completed);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause_circle, color: Colors.blue),
              title: const Text('On Hold'),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged(NoteStatus.hold);
              },
            ),
          ],
        );
      },
    );
  }
}
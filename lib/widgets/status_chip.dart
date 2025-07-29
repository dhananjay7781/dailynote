import 'package:flutter/material.dart';
import 'package:dailynote/models/note.dart';

class StatusChip extends StatelessWidget {
  final NoteStatus status;
  final int? count;
  final bool small;
  final VoidCallback? onPressed;

  const StatusChip({
    super.key,
    required this.status,
    this.count,
    this.small = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);

    return ActionChip(
      label: count != null
          ? Text('$text ($count)')
          : Text(text, style: TextStyle(fontSize: small ? 12 : null)),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
      side: BorderSide(color: color),
      onPressed: onPressed,
    );
  }

  Color _getStatusColor(NoteStatus status) {
    switch (status) {
      case NoteStatus.newNote:
        return Colors.purple;
      case NoteStatus.inProgress:
        return Colors.orange;
      case NoteStatus.completed:
        return Colors.green;
      case NoteStatus.hold:
        return Colors.blue;
      case NoteStatus.deleted:
        return Colors.grey;
    }
  }

  String _getStatusText(NoteStatus status) {
    switch (status) {
      case NoteStatus.newNote:
        return 'New';
      case NoteStatus.inProgress:
        return 'In Progress';
      case NoteStatus.completed:
        return 'Completed';
      case NoteStatus.hold:
        return 'On Hold';
      case NoteStatus.deleted:
        return 'Deleted';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_paint/models/note.dart';
import 'package:my_paint/services/database_helper.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPublic = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final note = Note(
      title: _titleController.text,
      content: _contentController.text,
      privacyStatus: _isPublic ? 'public' : 'private',
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending_create',
    );

    await DatabaseHelper.instance.insert(note.toMap());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note saved offline!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Make Public:'),
                Switch(
                  value: _isPublic,
                  onChanged: (bool value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveNote,
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}

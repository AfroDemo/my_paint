import 'package:flutter/material.dart';
import 'package:my_paint/models/note.dart';
import 'package:my_paint/screens/add_note_screen.dart';
import 'package:my_paint/services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Note>> _getNotes() async {
    final notesFromDb = await DatabaseHelper.instance.queryAllRows();

    return notesFromDb.map((map) => Note.fromMap(map)).toList();
  }

  //we will call this to refresh the screen when we come back from AddNoteScreen
  void _refreshNotesList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Paint'),
        actions: [
          IconButton(
            onPressed: () => {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync button pressed')),
              ),
            },
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notes yet. Add one!'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final note = snapshot.data![index];

                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  trailing: Icon(
                    note.privacyStatus == 'public' ? Icons.public : Icons.lock,
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
          _refreshNotesList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

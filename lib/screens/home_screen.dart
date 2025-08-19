import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_paint/models/note.dart';
import 'package:my_paint/screens/add_note_screen.dart';
import 'package:my_paint/services/api_service.dart';
import 'package:my_paint/services/database_helper.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  Future<List<Note>> _getNotes() async {
    final notesFromDb = await DatabaseHelper.instance.queryAllRows();
    return notesFromDb.map((map) => Note.fromMap(map)).toList();
  }

  void _refreshNotesList() {
    setState(() {});
  }

  // New method to handle synchronization
  void _syncData() async {
    try {
      // 1. Check for pending users
      final pendingUsers = await DatabaseHelper.instance.queryPendingUsers();

      if (pendingUsers.isNotEmpty) {
        final userToSync = pendingUsers.first;
        final response = await _apiService.registerUser(
          userToSync.userName,
          userToSync.email,
          userToSync.password,
        );

        if (response.statusCode == 201) {
          // User registration successful, update local DB
          final remoteId = jsonDecode(
            response.body,
          )['id']; // Get the new ID from the backend
          userToSync.remoteId = remoteId;
          userToSync.syncStatus = 'synced';
          await DatabaseHelper.instance.updateUser(userToSync.toMap());
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User account synced!')));
        } else if (response.statusCode == 409) {
          // Conflict: username or email is taken
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration failed: Username or email is already taken. Please update your details and try again.',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sync failed: ${response.body}')),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nothing to sync!')));
      }

      final pendingNotes = await DatabaseHelper.instance.queryPendingNotes();

      if (pendingNotes.isNotEmpty) {
        final notesData = pendingNotes.map((e) => e.toMap()).toList();

        final response = await http.post(
          Uri.parse('http://192.168.1.150:8080/sync/notes'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(notesData),
        );

        if (response.statusCode == 200) {
          for (var note in pendingNotes) {
            note.syncStatus = 'synced';

            await DatabaseHelper.instance.updateNote(note.toMap());
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Notes synchronized!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notes sync failed: ${response.body}')),
          );
        }
      }

      if (pendingUsers.isEmpty && pendingNotes.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nothing to sync!')));
      }

      _refreshNotesList(); // Refresh the UI after sync
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sync error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Paint'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncData, // Call our new sync method
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

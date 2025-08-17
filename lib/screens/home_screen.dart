import 'package:flutter/material.dart';
import 'package:my_paint/screens/add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[const Text('No notes yet. Add one!')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          ),
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

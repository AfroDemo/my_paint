// lib/models/note.dart

import 'package:uuid/uuid.dart';

class Note {
  String? id; // Change to String
  int? userId; // Add this field
  String title;
  String content;
  String privacyStatus;
  String createdAt;
  String updatedAt;
  String syncStatus;

  Note({
    this.id,
    this.userId, // Add this to the constructor
    required this.title,
    required this.content,
    required this.privacyStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  }) {
    // Generate a unique string ID locally
    id ??= const Uuid().v4();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId, // Add this key
      'title': title,
      'content': content,
      'privacy_status': privacyStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['user_id'], // Retrieve the user_id
      title: map['title'],
      content: map['content'],
      privacyStatus: map['privacy_status'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      syncStatus: map['sync_status'],
    );
  }
}

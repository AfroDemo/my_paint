// lib/models/user.dart

import 'package:uuid/uuid.dart';

class User {
  String? localId;
  int? remoteId;
  String userName;
  String email;
  String password;
  String syncStatus;

  User({
    this.localId,
    this.remoteId,
    required this.userName,
    required this.email,
    required this.password,
    required this.syncStatus,
  }) {
    localId ??= const Uuid().v4();
  }

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'remote_id': remoteId,
      'username': userName,
      'email': email,
      'password': password,
      'sync_status': syncStatus,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      localId: map['local_id'] as String?,
      remoteId: map['remote_id'] as int?,
      userName: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      syncStatus: map['sync_status'] as String,
    );
  }
}

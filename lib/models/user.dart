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
      'localId': localId, // Changed from 'local_id'
      'remoteId': remoteId, // Changed from 'remote_id'
      'userName': userName, // Changed from 'username'
      'email': email,
      'password': password,
      'syncStatus': syncStatus, // Changed from 'sync_status'
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      localId: map['localId'] as String?, // Changed from 'local_id'
      remoteId: map['remoteId'] as int?, // Changed from 'remote_id'
      userName: map['userName'] as String, // Changed from 'username'
      email: map['email'] as String,
      password: map['password'] as String,
      syncStatus: map['syncStatus'] as String, // Changed from 'sync_status'
    );
  }
}

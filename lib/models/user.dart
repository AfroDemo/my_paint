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
      'localId': localId,
      'remoteId': remoteId,
      'userName': userName,
      'email': email,
      'password': password,
      'syncStatus': syncStatus,
    };
  }
}

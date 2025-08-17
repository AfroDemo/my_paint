class Note {
  int? id;
  String title;
  String content;
  String privacyStatus;
  String createdAt;
  String updatedAt;
  String syncStatus;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.privacyStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  //convert a note object into a Map.The keys must correspond
  //to the names of the columns in our database table
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'privacy_status': privacyStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }

  //constructor that creates a note object from  a Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      privacyStatus: map['privacy_status'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      syncStatus: map['sync_status'],
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_paint/models/user.dart';
import 'package:my_paint/models/note.dart';

class DatabaseHelper {
  static final _databaseName = "MyPaint.db";
  static final _databaseVersion = 4; // Increment to fix the column issue

  // Notes table
  static final notesTable = "notes";
  static final columnId = "id";
  static final columnUserId = "user_id"; // Add this - matches your Note model
  static final columnTitle = "title";
  static final columnContent = "content";
  static final columnPrivacyStatus = "privacy_status";
  static final columnCreatedAt = "created_at";
  static final columnUpdatedAt = "updated_at";
  static final columnSyncStatus = "sync_status";

  // Users table - using camelCase to match User model
  static final usersTable = "users";
  static final columnLocalId = "localId";
  static final columnRemoteId = "remoteId";
  static final columnUserName = "userName";
  static final columnEmail = "email";
  static final columnPassword = "password";
  static final columnUserSyncStatus = "syncStatus";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create notes table
    await db.execute('''
      CREATE TABLE $notesTable(
        $columnId TEXT PRIMARY KEY,
        $columnUserId INTEGER,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnPrivacyStatus TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnSyncStatus TEXT NOT NULL
      )
    ''');

    // Create users table with camelCase columns
    await db.execute('''
      CREATE TABLE $usersTable (
        $columnLocalId TEXT PRIMARY KEY,
        $columnRemoteId INTEGER,
        $columnUserName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnPassword TEXT NOT NULL,
        $columnUserSyncStatus TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      var tableExists = (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$usersTable'",
      )).isNotEmpty;

      if (!tableExists) {
        await db.execute('''
          CREATE TABLE $usersTable (
            $columnLocalId TEXT PRIMARY KEY,
            $columnRemoteId INTEGER,
            $columnUserName TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnUserSyncStatus TEXT NOT NULL
          )
        ''');
      }
    }

    if (oldVersion < 3) {
      var columns = await db.rawQuery("PRAGMA table_info($usersTable)");
      bool needsRecreation = false;

      for (var column in columns) {
        String columnName = column['name'] as String;
        if (columnName == 'sync_status' ||
            columnName == 'local_id' ||
            columnName == 'remote_id' ||
            columnName == 'username') {
          needsRecreation = true;
          break;
        }
      }

      if (needsRecreation) {
        var existingUsers = await db.query(usersTable);
        await db.execute('DROP TABLE $usersTable');
        await db.execute('''
          CREATE TABLE $usersTable (
            $columnLocalId TEXT PRIMARY KEY,
            $columnRemoteId INTEGER,
            $columnUserName TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnUserSyncStatus TEXT NOT NULL
          )
        ''');

        for (var user in existingUsers) {
          await db.insert(usersTable, {
            columnLocalId: user['local_id'] ?? user['localId'],
            columnRemoteId: user['remote_id'] ?? user['remoteId'],
            columnUserName: user['username'] ?? user['userName'],
            columnEmail: user['email'],
            columnPassword: user['password'],
            columnUserSyncStatus: user['sync_status'] ?? user['syncStatus'],
          });
        }
      }
    }

    // Fix the notes table column name mismatch (version 4)
    if (oldVersion < 4) {
      // Check if notes table has userId (camelCase) instead of user_id (snake_case)
      var noteColumns = await db.rawQuery("PRAGMA table_info($notesTable)");
      bool hasWrongColumn = false;

      for (var column in noteColumns) {
        String columnName = column['name'] as String;
        if (columnName == 'userId') {
          hasWrongColumn = true;
          break;
        }
      }

      if (hasWrongColumn) {
        // Backup existing notes
        var existingNotes = await db.query(notesTable);

        // Recreate notes table with correct column name
        await db.execute('DROP TABLE $notesTable');
        await db.execute('''
          CREATE TABLE $notesTable(
            $columnId TEXT PRIMARY KEY,
            $columnUserId INTEGER,
            $columnTitle TEXT NOT NULL,
            $columnContent TEXT NOT NULL,
            $columnPrivacyStatus TEXT NOT NULL,
            $columnCreatedAt TEXT NOT NULL,
            $columnUpdatedAt TEXT NOT NULL,
            $columnSyncStatus TEXT NOT NULL
          )
        ''');

        // Restore notes with correct column mapping
        for (var note in existingNotes) {
          await db.insert(notesTable, {
            columnId: note['id'],
            columnUserId:
                note['userId'], // Map from old camelCase to new snake_case
            columnTitle: note['title'],
            columnContent: note['content'],
            columnPrivacyStatus: note['privacy_status'],
            columnCreatedAt: note['created_at'],
            columnUpdatedAt: note['updated_at'],
            columnSyncStatus: note['sync_status'],
          });
        }
      }
    }
  }

  // New method to get a user who is already synced
  Future<User?> getSyncedUser() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      usersTable,
      where: '$columnUserSyncStatus = ? AND $columnRemoteId IS NOT NULL',
      whereArgs: ['synced'],
      limit: 1, // We only need the first user
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> hasUserRegistered() async {
    Database db = await instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $usersTable'),
    );
    return count! > 0;
  }

  Future<List<User>> queryPendingUsers() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      usersTable,
      where: '$columnUserSyncStatus = ?',
      whereArgs: ['pending_create'],
    );
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<int> insertNote(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(notesTable, row);
  }

  Future<int> updateNote(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.update(
      notesTable,
      row,
      where: '$columnId = ?',
      whereArgs: [row[columnId]],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(notesTable);
  }

  Future<List<Note>> queryPendingNotes() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      notesTable,
      where: '$columnSyncStatus!=?',
      whereArgs: ['synced'],
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(usersTable, row);
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String? localId = row[columnLocalId] as String?;
    if (localId == null) {
      throw ArgumentError('localId cannot be null for user update');
    }
    return await db.update(
      usersTable,
      row,
      where: '$columnLocalId = ?',
      whereArgs: [localId],
    );
  }
}

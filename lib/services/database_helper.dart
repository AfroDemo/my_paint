import 'package:my_paint/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_paint/models/user.dart';

class DatabaseHelper {
  static final _databaseName = "MyPaint.db";
  static final _databaseVersion =
      3; // Increment to fix any existing schema issues

  // Notes table
  static final notesTable = "notes";
  static final columnId = "id";
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
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
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
      // Check if users table exists
      var tableExists = (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$usersTable'",
      )).isNotEmpty;

      if (!tableExists) {
        // Create users table if it doesn't exist
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

    // Fix column name inconsistencies from version 2 to 3
    if (oldVersion < 3) {
      // Check current column names and fix if needed
      var columns = await db.rawQuery("PRAGMA table_info($usersTable)");
      bool needsRecreation = false;

      // Check if we have the old incorrect column names
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
        // Backup existing data
        var existingUsers = await db.query(usersTable);

        // Drop and recreate table with correct column names
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

        // Restore data with correct column names
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
  }

  // User-related methods
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

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(notesTable, row);
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

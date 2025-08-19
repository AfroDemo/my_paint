import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_paint/models/user.dart';

class DatabaseHelper {
  static final _databaseName = "MyPaint.db";
  // Increment the database version to trigger an upgrade
  static final _databaseVersion = 2;

  static final notesTable = "notes";
  static final usersTable = "users";

  static final columnId = "id";
  static final columnTitle = "title";
  static final columnContent = "content";
  static final columnPrivacyStatus = "privacy_status";
  static final columnCreatedAt = "created_at";
  static final columnUpdatedAt = "updated_at";
  static final columnSyncStatus = "sync_status";

  // Columns for the users table
  static final columnLocalId = "local_id";
  static final columnRemoteId = "remote_id";
  static final columnUserName = "username";
  static final columnEmail = "email";
  static final columnPassword = "password";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // open the database or create it if it does not exist
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // SQL code to create database tables
  Future _onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE $usersTable (
        $columnLocalId TEXT PRIMARY KEY,
        $columnRemoteId INTEGER,
        $columnUserName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnPassword TEXT NOT NULL,
        $columnSyncStatus TEXT NOT NULL
      )
    ''');
  }

  // Method to handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add a check to see if the table exists before altering
      var tableExists = (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$usersTable'",
      )).isNotEmpty;
      if (!tableExists) {
        // If the table doesn't exist, create it with the correct schema
        await db.execute('''
          CREATE TABLE $usersTable (
            $columnLocalId TEXT PRIMARY KEY,
            $columnRemoteId INTEGER,
            $columnUserName TEXT NOT NULL,
            $columnEmail TEXT NOT NULL,
            $columnPassword TEXT NOT NULL,
            $columnSyncStatus TEXT NOT NULL
          )
        ''');
      } else {
        // Handle adding new columns to an existing table
        await db.execute(
          'ALTER TABLE $usersTable ADD COLUMN $columnLocalId TEXT;',
        );
        await db.execute(
          'ALTER TABLE $usersTable ADD COLUMN $columnRemoteId INTEGER;',
        );
        await db.execute(
          'ALTER TABLE $usersTable ADD COLUMN $columnSyncStatus TEXT;',
        );
      }
    }
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
      where: '$columnSyncStatus = ?',
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

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(usersTable, row);
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String? localId = row[columnLocalId] as String?; // Use the correct key
    if (localId == null) {
      return 0;
    }
    return await db.update(
      usersTable,
      row,
      where: '$columnLocalId = ?',
      whereArgs: [localId],
    );
  }
}

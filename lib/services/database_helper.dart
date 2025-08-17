import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "MyPaint.db";
  static final _databaseVersion = 1;

  static final table = "notes";

  static final columnId = "id";
  static final columnTitle = "title";
  static final columnContent = "content";
  static final columnPrivacyStatus = "privacy_status";
  static final columnCreatedAt = "created_at";
  static final columnUpdatedAt = "updated_at";
  static final columnSyncStatus = "sync_status";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //open the database or create it if it does not exist
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  //SQL code to create database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE $table(
$columnId INTEGER PRIMARY KEY AUTOINCREMENT,
$columnTitle TEXT NOT NULL,
$columnContent TEXT NOT NULL,
$columnPrivacyStatus TEXT NOT NULL,
$columnCreatedAt TEXT NOT NULL,
$columnUpdatedAt TEXT NOT NULL,
$columnSyncStatus TEXT NOT NULL
)
''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }
}

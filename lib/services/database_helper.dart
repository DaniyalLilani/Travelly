import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE comments(
            id INTEGER PRIMARY KEY, 
            pinId INTEGER, 
            username TEXT, 
            handle TEXT, 
            comment TEXT, 
            image TEXT
          )
          ''',
        );
      },
    );
  }

  // Insert comment with the specified pinId
  Future<void> insertComment(Map<String, dynamic> comment, int pinId) async {
    final db = await database;
    // Add pinId to the comment before insertion
    comment['pinId'] = pinId.toString();
    await db.insert('comments', comment);
  }

  // Fetch comments associated with a specific pinId
  Future<List<Map<String, dynamic>>> fetchComments(int pinId) async {
    final db = await database;
    return await db.query('comments', where: 'pinId = ?', whereArgs: [pinId]);
  }
}

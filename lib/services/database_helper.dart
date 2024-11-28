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
    String path = join(await getDatabasesPath(), 'settings_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create a table for dark mode setting
        await db.execute(
          '''
          CREATE TABLE settings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isDarkMode INTEGER
          )
          ''',
        );

        // Insert default value for isDarkMode (0 = false)
        await db.insert(
          'settings',
          {'isDarkMode': 0},
        );
      },
    );
  }

  // Get the current isDarkMode value
  Future<bool> getIsDarkMode() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      columns: ['isDarkMode'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['isDarkMode'] == 1;
    } else {
      // Default to false if no entry exists
      return false;
    }
  }

  // Update the isDarkMode value
  Future<void> setIsDarkMode(bool isDarkMode) async {
    final db = await database;
    await db.update(
      'settings',
      {'isDarkMode': isDarkMode ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1], // Always update the first row
    );
  }
}

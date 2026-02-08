import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('passwords.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appName TEXT NOT NULL,
        appLink TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertPassword(PasswordEntry entry) async {
    final db = await database;
    return await db.insert('passwords', entry.toMap());
  }

  Future<List<PasswordEntry>> getAllPasswords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passwords',
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => PasswordEntry.fromMap(maps[i]));
  }

  Future<PasswordEntry?> getPasswordById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PasswordEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePassword(PasswordEntry entry) async {
    final db = await database;
    return await db.update(
      'passwords',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PasswordEntry>> searchPasswords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'passwords',
      where: 'appName LIKE ? OR username LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => PasswordEntry.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

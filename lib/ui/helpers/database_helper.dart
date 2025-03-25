import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Akun admin default
    await db.insert('users', {
      'email': 'admin@example.com',
      'password': 'admin123',
    });
  }

  Future<int> insertUser(User user) async {
    if (!User.isValidEmail(user.email)) {
      throw FormatException('Format email tidak valid');
    }

    final db = await database;
    try {
      return await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Email sudah terdaftar');
      }
      rethrow;
    }
  }

  Future<User?> getUser(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
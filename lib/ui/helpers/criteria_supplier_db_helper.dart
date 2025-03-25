import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/criteria_model.dart';
import '../models/supplier_model.dart';
import '../models/perhitungan_model.dart';

class CriteriaSupplierDbHelper {
  // Singleton pattern
  static final CriteriaSupplierDbHelper _instance = CriteriaSupplierDbHelper._internal();
  factory CriteriaSupplierDbHelper() => _instance;
  static Database? _database;

  CriteriaSupplierDbHelper._internal();

  // Database initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'supplier_selection.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables with foreign key constraints
    await db.execute('''
      CREATE TABLE criteria(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        weight REAL NOT NULL DEFAULT 1.0,
        timestamps TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE supplier(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact TEXT NOT NULL,
        address TEXT NOT NULL,
        timestamps TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE perhitungan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCriteria INTEGER NOT NULL,
        idSupplier INTEGER NOT NULL,
        value REAL NOT NULL,
        timestamps TEXT NOT NULL,
        FOREIGN KEY(idCriteria) REFERENCES criteria(id) ON DELETE CASCADE,
        FOREIGN KEY(idSupplier) REFERENCES supplier(id) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== CRITERIA OPERATIONS ====================
  Future<int> insertCriteria(Criteria criteria) async {
    final db = await database;
    return await db.insert('criteria', criteria.toMap());
  }

  Future<List<Criteria>> getAllCriteria() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'criteria',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Criteria.fromMap(maps[i]));
  }

  Future<Criteria?> getCriteriaById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'criteria',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Criteria.fromMap(maps.first);
  }

  Future<int> updateCriteria(Criteria criteria) async {
    final db = await database;
    return await db.update(
      'criteria',
      criteria.toMap(),
      where: 'id = ?',
      whereArgs: [criteria.id],
    );
  }

  Future<int> deleteCriteria(int id) async {
    final db = await database;
    return await db.delete(
      'criteria',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== SUPPLIER OPERATIONS ====================
  Future<int> insertSupplier(Supplier supplier) async {
    final db = await database;
    return await db.insert('supplier', supplier.toMap());
  }

  Future<List<Supplier>> getAllSupplier() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supplier',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }

  Future<Supplier?> getSupplierById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supplier',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Supplier.fromMap(maps.first);
  }

  Future<int> updateSupplier(Supplier supplier) async {
    final db = await database;
    return await db.update(
      'supplier',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return await db.delete(
      'supplier',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== PERHITUNGAN OPERATIONS ====================
  Future<int> insertPerhitungan(Perhitungan perhitungan) async {
    final db = await database;
    return await db.insert('perhitungan', perhitungan.toMap());
  }

  Future<List<Perhitungan>> getAllPerhitungan() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'perhitungan',
      orderBy: 'timestamps DESC',
    );
    return List.generate(maps.length, (i) => Perhitungan.fromMap(maps[i]));
  }

  Future<List<Perhitungan>> getPerhitunganBySupplier(int supplierId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'perhitungan',
      where: 'idSupplier = ?',
      whereArgs: [supplierId],
    );
    return List.generate(maps.length, (i) => Perhitungan.fromMap(maps[i]));
  }

  Future<List<Perhitungan>> getPerhitunganByCriteria(int criteriaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'perhitungan',
      where: 'idCriteria = ?',
      whereArgs: [criteriaId],
    );
    return List.generate(maps.length, (i) => Perhitungan.fromMap(maps[i]));
  }

  Future<int> updatePerhitungan(Perhitungan perhitungan) async {
    final db = await database;
    return await db.update(
      'perhitungan',
      perhitungan.toMap(),
      where: 'id = ?',
      whereArgs: [perhitungan.id],
    );
  }

  Future<int> deletePerhitungan(int id) async {
    final db = await database;
    return await db.delete(
      'perhitungan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== ADVANCED OPERATIONS ====================
  Future<void> deleteAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('perhitungan');
      await txn.delete('supplier');
      await txn.delete('criteria');
    });
  }

  Future<List<Map<String, dynamic>>> getSupplierWithScores() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        s.id, 
        s.name, 
        s.contact, 
        s.address,
        SUM(p.value * c.weight) as total_score
      FROM supplier s
      LEFT JOIN perhitungan p ON s.id = p.idSupplier
      LEFT JOIN criteria c ON p.idCriteria = c.id
      GROUP BY s.id
      ORDER BY total_score DESC
    ''');
  }

  // Close database connection (for testing)
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
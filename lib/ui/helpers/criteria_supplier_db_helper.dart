import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/criteria_model.dart';
import '../models/supplier_model.dart';
import '../models/perhitungan_model.dart';

class CriteriaSupplierDbHelper {
  static final CriteriaSupplierDbHelper _instance = CriteriaSupplierDbHelper._internal();
  factory CriteriaSupplierDbHelper() => _instance;
  static Database? _database;

  CriteriaSupplierDbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'criteria_supplier.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE criteria(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        weight REAL,
        type TEXT,
        timestamps TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE supplier(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        contact TEXT,
        address TEXT,
        timestamps TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE perhitungan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idCriteria INTEGER,
        idSupplier INTEGER,
        value REAL,
        timestamps TEXT
      )
    ''');
  }

  // CRUD untuk Criteria
  Future<int> insertCriteria(Criteria criteria) async {
    Database db = await database;
    return await db.insert('criteria', criteria.toMap());
  }

  Future<List<Criteria>> getAllCriteria() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('criteria');
    return List.generate(maps.length, (i) => Criteria.fromMap(maps[i]));
  }

  Future<int> updateCriteria(Criteria criteria) async {
    Database db = await database;
    return await db.update(
      'criteria',
      criteria.toMap(),
      where: 'id = ?',
      whereArgs: [criteria.id],
    );
  }

  Future<int> deleteCriteria(int id) async {
    Database db = await database;
    return await db.delete(
      'criteria',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD untuk Supplier
  Future<int> insertSupplier(Supplier supplier) async {
    Database db = await database;
    return await db.insert('supplier', supplier.toMap());
  }

  Future<List<Supplier>> getAllSupplier() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('supplier');
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }

  Future<int> updateSupplier(Supplier supplier) async {
    Database db = await database;
    return await db.update(
      'supplier',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    Database db = await database;
    return await db.delete(
      'supplier',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD untuk Perhitungan
  Future<int> insertPerhitungan(Perhitungan perhitungan) async {
    Database db = await database;
    return await db.insert('perhitungan', perhitungan.toMap());
  }

  Future<List<Perhitungan>> getAllPerhitungan() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('perhitungan');
    return List.generate(maps.length, (i) => Perhitungan.fromMap(maps[i]));
  }

  Future<int> updatePerhitungan(Perhitungan perhitungan) async {
    Database db = await database;
    return await db.update(
      'perhitungan',
      perhitungan.toMap(),
      where: 'id = ?',
      whereArgs: [perhitungan.id],
    );
  }

  Future<int> deletePerhitungan(int id) async {
    Database db = await database;
    return await db.delete(
      'perhitungan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
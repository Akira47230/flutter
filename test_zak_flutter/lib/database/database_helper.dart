import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/invoice.dart';
import '../models/warranty.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    // SQLite doesn't work on web, throw an error if accessed
    if (kIsWeb) {
      throw UnsupportedError('Database operations are not supported on web platform');
    }

    if (_database != null) return _database!;
    _database = await _initDB('invoices_warranties.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Skip on web
    if (kIsWeb) {
      throw UnsupportedError('Database initialization is not supported on web platform');
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table des factures
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT NOT NULL,
        storeName TEXT,
        amount REAL,
        purchaseDate TEXT NOT NULL,
        invoiceNumber TEXT,
        imagePath TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Table des garanties
    await db.execute('''
      CREATE TABLE warranties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT NOT NULL,
        brand TEXT,
        purchaseDate TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        durationMonths INTEGER NOT NULL,
        storeName TEXT,
        warrantyNumber TEXT,
        imagePath TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // ========== INVOICES ==========
  Future<int> insertInvoice(Invoice invoice) async {
    if (kIsWeb) return 0; // Skip on web
    final db = await database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<List<Invoice>> getAllInvoices() async {
    if (kIsWeb) return []; // Return empty list on web
    final db = await database;
    final maps = await db.query(
      'invoices',
      orderBy: 'purchaseDate DESC',
    );
    return maps.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<Invoice?> getInvoice(int id) async {
    if (kIsWeb) return null; // Return null on web
    final db = await database;
    final maps = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Invoice.fromMap(maps.first);
  }

  Future<int> updateInvoice(Invoice invoice) async {
    if (kIsWeb) return 0; // Skip on web
    final db = await database;
    return await db.update(
      'invoices',
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> deleteInvoice(int id) async {
    if (kIsWeb) return 0; // Skip on web
    final db = await database;
    return await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== WARRANTIES ==========
  Future<int> insertWarranty(Warranty warranty) async {
    if (kIsWeb) return 0; // Skip on web
    final db = await database;
    return await db.insert('warranties', warranty.toMap());
  }

  Future<List<Warranty>> getAllWarranties() async {
    if (kIsWeb) return []; // Return empty list on web
    final db = await database;
    final maps = await db.query(
      'warranties',
      orderBy: 'expiryDate ASC',
    );
    return maps.map((map) => Warranty.fromMap(map)).toList();
  }

  Future<List<Warranty>> getExpiringWarranties(int daysAhead) async {
    if (kIsWeb) return []; // Return empty list on web
    final db = await database;
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysAhead));
    final maps = await db.query(
      'warranties',
      where: 'expiryDate >= ? AND expiryDate <= ?',
      whereArgs: [
        now.toIso8601String(),
        threshold.toIso8601String(),
      ],
      orderBy: 'expiryDate ASC',
    );
    return maps.map((map) => Warranty.fromMap(map)).toList();
  }

  Future<Warranty?> getWarranty(int id) async {
    if (kIsWeb) return null; // Return null on web
    final db = await database;
    final maps = await db.query(
      'warranties',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Warranty.fromMap(maps.first);
  }

  Future<int> updateWarranty(Warranty warranty) async {
    if (kIsWeb) return 0; // Skip on web
    final db = await database;
    return await db.update(
      'warranties',
      warranty.toMap(),
      where: 'id = ?',
      whereArgs: [warranty.id],
    );
  }

  Future<int> deleteWarranty(int id) async {
    if (kIsWeb) return 0; // Skip on web
    final db = await database;
    return await db.delete(
      'warranties',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    if (kIsWeb) return; // Skip on web
    final db = await database;
    await db.close();
  }
}


import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'expense_tracker.db';
  static const _databaseVersion = 1;
  static const tableName = 'transactions';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(dbPath, _databaseName),
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert(tableName, transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final rows = await db.query(tableName, orderBy: 'date DESC, id DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.update(
      tableName,
      transaction.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}

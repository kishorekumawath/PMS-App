import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/db_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.dbName);
    return openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.propertiesTable} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colAddress} TEXT NOT NULL,
        ${DbConstants.colRentAmount} REAL NOT NULL,
        ${DbConstants.colStatus} TEXT NOT NULL,
        ${DbConstants.colCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tenantsTable} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colEmail} TEXT NOT NULL,
        ${DbConstants.colPhone} TEXT NOT NULL,
        ${DbConstants.colPropertyId} TEXT,
        ${DbConstants.colMoveInDate} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.colPropertyId})
          REFERENCES ${DbConstants.propertiesTable}(${DbConstants.colId})
          ON DELETE SET NULL
      )
    ''');

    await _createPaymentsTable(db);
  }

  // v1 → v2: recreate payments with ON DELETE CASCADE on both FK columns
  // so deleting a tenant or property also removes their payments.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE ${DbConstants.paymentsTable} RENAME TO payments_backup');
      await _createPaymentsTable(db);
      await db.execute(
          'INSERT INTO ${DbConstants.paymentsTable} SELECT * FROM payments_backup');
      await db.execute('DROP TABLE payments_backup');
    }
  }

  Future<void> _createPaymentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.paymentsTable} (
        ${DbConstants.colId} TEXT PRIMARY KEY,
        ${DbConstants.colTenantId} TEXT NOT NULL,
        ${DbConstants.colPropertyId} TEXT NOT NULL,
        ${DbConstants.colAmount} REAL NOT NULL,
        ${DbConstants.colDueDate} TEXT NOT NULL,
        ${DbConstants.colPaidDate} TEXT,
        ${DbConstants.colStatus} TEXT NOT NULL,
        ${DbConstants.colNotes} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.colTenantId})
          REFERENCES ${DbConstants.tenantsTable}(${DbConstants.colId})
          ON DELETE CASCADE,
        FOREIGN KEY (${DbConstants.colPropertyId})
          REFERENCES ${DbConstants.propertiesTable}(${DbConstants.colId})
          ON DELETE CASCADE
      )
    ''');
  }
}

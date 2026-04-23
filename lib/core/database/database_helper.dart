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
          REFERENCES ${DbConstants.tenantsTable}(${DbConstants.colId}),
        FOREIGN KEY (${DbConstants.colPropertyId})
          REFERENCES ${DbConstants.propertiesTable}(${DbConstants.colId})
      )
    ''');
  }
}

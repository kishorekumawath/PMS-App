import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/tenant_model.dart';

class TenantLocalDatasource {
  final DatabaseHelper _dbHelper;

  TenantLocalDatasource(this._dbHelper);

  Future<List<TenantModel>> getAllTenants() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('tenants', orderBy: 'created_at DESC');
      return maps.map(TenantModel.fromMap).toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<TenantModel?> getTenantById(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps =
          await db.query('tenants', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return TenantModel.fromMap(maps.first);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> insertTenant(TenantModel model) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'tenants',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> updateTenant(TenantModel model) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'tenants',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> deleteTenant(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('tenants', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}

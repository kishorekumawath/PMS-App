import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/property_model.dart';

class PropertyLocalDatasource {
  final DatabaseHelper _dbHelper;

  PropertyLocalDatasource(this._dbHelper);

  Future<List<PropertyModel>> getAllProperties() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('properties', orderBy: 'created_at DESC');
      return maps.map(PropertyModel.fromMap).toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<PropertyModel?> getPropertyById(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps =
          await db.query('properties', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return PropertyModel.fromMap(maps.first);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> insertProperty(PropertyModel model) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'properties',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> updateProperty(PropertyModel model) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'properties',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [model.id],
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('properties', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}

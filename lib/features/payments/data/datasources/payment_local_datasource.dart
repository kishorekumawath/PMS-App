import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/payment_model.dart';

class PaymentLocalDatasource {
  final DatabaseHelper _dbHelper;

  PaymentLocalDatasource(this._dbHelper);

  Future<List<PaymentModel>> getAllPayments() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('payments', orderBy: 'created_at DESC');
      return maps.map(PaymentModel.fromMap).toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<PaymentModel>> getPaymentsForTenant(String tenantId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'payments',
        where: 'tenant_id = ?',
        whereArgs: [tenantId],
        orderBy: 'due_date DESC',
      );
      return maps.map(PaymentModel.fromMap).toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> insertPayment(PaymentModel model) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'payments',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('payments', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/tenant_local_datasource.dart';
import '../models/tenant_model.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantLocalDatasource _datasource;

  TenantRepositoryImpl(this._datasource);

  @override
  Future<List<Tenant>> getAllTenants() async {
    try {
      return await _datasource.getAllTenants();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<Tenant> getTenantById(String id) async {
    try {
      final result = await _datasource.getTenantById(id);
      if (result == null) throw const NotFoundFailure('Tenant not found');
      return result;
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> addTenant(Tenant tenant) async {
    try {
      await _datasource.insertTenant(TenantModel.fromEntity(tenant));
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> updateTenant(Tenant tenant) async {
    try {
      await _datasource.updateTenant(TenantModel.fromEntity(tenant));
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> deleteTenant(String id) async {
    try {
      await _datasource.deleteTenant(id);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}

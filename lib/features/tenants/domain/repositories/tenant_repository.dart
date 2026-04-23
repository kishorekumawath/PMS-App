import '../entities/tenant.dart';

abstract interface class TenantRepository {
  Future<List<Tenant>> getAllTenants();
  Future<Tenant> getTenantById(String id);
  Future<void> addTenant(Tenant tenant);
  Future<void> updateTenant(Tenant tenant);
  Future<void> deleteTenant(String id);
}

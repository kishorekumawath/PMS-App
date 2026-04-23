import '../../../../core/usecases/usecase.dart';
import '../entities/tenant.dart';
import '../repositories/tenant_repository.dart';

class GetTenantById implements UseCase<Tenant, String> {
  final TenantRepository _repository;

  GetTenantById(this._repository);

  @override
  Future<Tenant> call(String params) {
    return _repository.getTenantById(params);
  }
}

import '../../../../core/usecases/usecase.dart';
import '../entities/tenant.dart';
import '../repositories/tenant_repository.dart';

class UpdateTenant implements UseCase<void, Tenant> {
  final TenantRepository _repository;

  UpdateTenant(this._repository);

  @override
  Future<void> call(Tenant params) {
    return _repository.updateTenant(params);
  }
}

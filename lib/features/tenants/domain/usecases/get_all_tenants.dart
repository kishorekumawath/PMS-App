import '../../../../core/usecases/usecase.dart';
import '../entities/tenant.dart';
import '../repositories/tenant_repository.dart';

class GetAllTenants implements UseCase<List<Tenant>, NoParams> {
  final TenantRepository _repository;

  GetAllTenants(this._repository);

  @override
  Future<List<Tenant>> call(NoParams params) {
    return _repository.getAllTenants();
  }
}

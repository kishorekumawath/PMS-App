import '../../../../core/usecases/usecase.dart';
import '../repositories/tenant_repository.dart';

class DeleteTenant implements UseCase<void, String> {
  final TenantRepository _repository;

  DeleteTenant(this._repository);

  @override
  Future<void> call(String params) {
    return _repository.deleteTenant(params);
  }
}

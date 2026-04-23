import '../../../../core/usecases/usecase.dart';
import '../repositories/property_repository.dart';

class DeleteProperty implements UseCase<void, String> {
  final PropertyRepository _repository;

  DeleteProperty(this._repository);

  @override
  Future<void> call(String params) {
    return _repository.deleteProperty(params);
  }
}

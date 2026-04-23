import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class GetAllProperties implements UseCase<List<Property>, NoParams> {
  final PropertyRepository _repository;

  GetAllProperties(this._repository);

  @override
  Future<List<Property>> call(NoParams params) {
    return _repository.getAllProperties();
  }
}

import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class GetPropertyById implements UseCase<Property, String> {
  final PropertyRepository _repository;

  GetPropertyById(this._repository);

  @override
  Future<Property> call(String params) {
    return _repository.getPropertyById(params);
  }
}

import '../../../../core/usecases/usecase.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class UpdateProperty implements UseCase<void, Property> {
  final PropertyRepository _repository;

  UpdateProperty(this._repository);

  @override
  Future<void> call(Property params) {
    return _repository.updateProperty(params);
  }
}

import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

class AddProperty implements UseCase<void, AddPropertyParams> {
  final PropertyRepository _repository;

  AddProperty(this._repository);

  @override
  Future<void> call(AddPropertyParams params) {
    final property = Property(
      id: UuidGenerator.generate(),
      name: params.name,
      address: params.address,
      rentAmount: params.rentAmount,
      status: PropertyStatus.vacant,
      createdAt: DateTime.now(),
    );
    return _repository.addProperty(property);
  }
}

class AddPropertyParams extends Equatable {
  final String name;
  final String address;
  final double rentAmount;

  const AddPropertyParams({
    required this.name,
    required this.address,
    required this.rentAmount,
  });

  @override
  List<Object?> get props => [name, address, rentAmount];
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/property.dart';
import '../../domain/usecases/add_property.dart';

sealed class PropertyEvent extends Equatable {
  const PropertyEvent();
}

class LoadProperties extends PropertyEvent {
  const LoadProperties();
  @override
  List<Object?> get props => [];
}

class AddPropertyEvent extends PropertyEvent {
  final AddPropertyParams params;
  const AddPropertyEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class UpdatePropertyEvent extends PropertyEvent {
  final Property property;
  const UpdatePropertyEvent(this.property);
  @override
  List<Object?> get props => [property];
}

class DeletePropertyEvent extends PropertyEvent {
  final String id;
  const DeletePropertyEvent(this.id);
  @override
  List<Object?> get props => [id];
}

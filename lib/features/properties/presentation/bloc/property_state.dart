import 'package:equatable/equatable.dart';

import '../../domain/entities/property.dart';

sealed class PropertyState extends Equatable {
  const PropertyState();
}

class PropertyInitial extends PropertyState {
  const PropertyInitial();
  @override
  List<Object?> get props => [];
}

class PropertyLoading extends PropertyState {
  const PropertyLoading();
  @override
  List<Object?> get props => [];
}

class PropertyLoaded extends PropertyState {
  final List<Property> properties;
  const PropertyLoaded(this.properties);
  @override
  List<Object?> get props => [properties];
}

class PropertyError extends PropertyState {
  final String message;
  const PropertyError(this.message);
  @override
  List<Object?> get props => [message];
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_property.dart';
import '../../domain/usecases/delete_property.dart';
import '../../domain/usecases/get_all_properties.dart';
import '../../domain/usecases/update_property.dart';
import '../../../../core/usecases/usecase.dart';
import 'property_event.dart';
import 'property_state.dart';

export 'property_event.dart';
export 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final GetAllProperties _getAll;
  final AddProperty _add;
  final UpdateProperty _update;
  final DeleteProperty _delete;

  PropertyBloc({
    required GetAllProperties getAll,
    required AddProperty add,
    required UpdateProperty update,
    required DeleteProperty delete,
  })  : _getAll = getAll,
        _add = add,
        _update = update,
        _delete = delete,
        super(const PropertyInitial()) {
    on<LoadProperties>(_onLoad);
    on<AddPropertyEvent>(_onAdd);
    on<UpdatePropertyEvent>(_onUpdate);
    on<DeletePropertyEvent>(_onDelete);
  }

  Future<void> _onLoad(
      LoadProperties event, Emitter<PropertyState> emit) async {
    emit(const PropertyLoading());
    try {
      final properties = await _getAll(const NoParams());
      emit(PropertyLoaded(properties));
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }

  Future<void> _onAdd(
      AddPropertyEvent event, Emitter<PropertyState> emit) async {
    try {
      await _add(event.params);
      final properties = await _getAll(const NoParams());
      emit(PropertyLoaded(properties));
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdatePropertyEvent event, Emitter<PropertyState> emit) async {
    try {
      await _update(event.property);
      final properties = await _getAll(const NoParams());
      emit(PropertyLoaded(properties));
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeletePropertyEvent event, Emitter<PropertyState> emit) async {
    try {
      await _delete(event.id);
      final properties = await _getAll(const NoParams());
      emit(PropertyLoaded(properties));
    } catch (e) {
      emit(PropertyError(e.toString()));
    }
  }
}

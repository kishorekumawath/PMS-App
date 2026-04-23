import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_local_datasource.dart';
import '../models/property_model.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyLocalDatasource _datasource;

  PropertyRepositoryImpl(this._datasource);

  @override
  Future<List<Property>> getAllProperties() async {
    try {
      return await _datasource.getAllProperties();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<Property> getPropertyById(String id) async {
    try {
      final result = await _datasource.getPropertyById(id);
      if (result == null) throw const NotFoundFailure('Property not found');
      return result;
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> addProperty(Property property) async {
    try {
      await _datasource.insertProperty(PropertyModel.fromEntity(property));
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> updateProperty(Property property) async {
    try {
      await _datasource.updateProperty(PropertyModel.fromEntity(property));
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> deleteProperty(String id) async {
    try {
      await _datasource.deleteProperty(id);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}

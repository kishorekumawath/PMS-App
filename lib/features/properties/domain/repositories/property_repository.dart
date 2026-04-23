import '../entities/property.dart';

abstract interface class PropertyRepository {
  Future<List<Property>> getAllProperties();
  Future<Property> getPropertyById(String id);
  Future<void> addProperty(Property property);
  Future<void> updateProperty(Property property);
  Future<void> deleteProperty(String id);
}

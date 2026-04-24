class DbConstants {
  static const dbName = 'pms.db';
  static const dbVersion = 2;

  static const propertiesTable = 'properties';
  static const tenantsTable = 'tenants';
  static const paymentsTable = 'payments';

  // properties columns
  static const colId = 'id';
  static const colName = 'name';
  static const colAddress = 'address';
  static const colRentAmount = 'rent_amount';
  static const colStatus = 'status';
  static const colCreatedAt = 'created_at';

  // tenants columns
  static const colEmail = 'email';
  static const colPhone = 'phone';
  static const colPropertyId = 'property_id';
  static const colMoveInDate = 'move_in_date';

  // payments columns
  static const colTenantId = 'tenant_id';
  static const colAmount = 'amount';
  static const colDueDate = 'due_date';
  static const colPaidDate = 'paid_date';
  static const colNotes = 'notes';
}

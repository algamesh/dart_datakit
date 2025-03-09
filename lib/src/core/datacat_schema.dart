/// Defines the required structure (schema) for a Datacat.
/// Each key in [requiredColumns] represents a column name,
/// and its value is the required [Type] (or null if no type check is needed).
/// If [strictColumns] is true, the Datacat must not contain any extra columns.
class DatacatSchema {
  final Map<String, Type?> requiredColumns;
  final bool strictColumns;

  DatacatSchema({
    required this.requiredColumns,
    this.strictColumns = false,
  });
}

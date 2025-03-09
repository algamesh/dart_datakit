import '../core/datacat.dart';

/// Provides data transformation functions.
class Transformations {
  /// Converts all string values in [columnName] to uppercase.
  static Datacat toUpperCase(Datacat datacat, String columnName) {
    int colIndex = datacat.columns.indexOf(columnName);
    if (colIndex == -1) throw ArgumentError('Column "$columnName" not found.');
    for (var row in datacat.rows) {
      var value = row[colIndex];
      if (value is String) {
        row[colIndex] = value.toUpperCase();
      }
    }
    return datacat;
  }
}

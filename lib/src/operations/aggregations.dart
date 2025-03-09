import '../core/datacat.dart';

/// Provides aggregation operations.
class Aggregations {
  /// Computes the sum of a numeric column.
  static num sum(Datacat datacat, String columnName) {
    int colIndex = datacat.columns.indexOf(columnName);
    if (colIndex == -1) {
      throw ArgumentError('Column "$columnName" not found.');
    }
    num total = 0;
    for (final row in datacat.rows) {
      final value = row[colIndex];
      if (value is num) total += value;
    }
    return total;
  }

  /// Computes the mean of a numeric column.
  static double mean(Datacat datacat, String columnName) {
    int colIndex = datacat.columns.indexOf(columnName);
    if (colIndex == -1) {
      throw ArgumentError('Column "$columnName" not found.');
    }
    num total = 0;
    int count = 0;
    for (final row in datacat.rows) {
      final value = row[colIndex];
      if (value is num) {
        total += value;
        count++;
      }
    }
    if (count == 0)
      throw ArgumentError('No numeric data in column "$columnName".');
    return total / count;
  }
}

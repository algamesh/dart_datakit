import '../core/datacat.dart';

/// Provides window (rolling) functions.
class WindowFunctions {
  /// Computes a simple moving average for a numeric column.
  static List<num?> movingAverage(
      Datacat datacat, String columnName, int windowSize) {
    int colIndex = datacat.columns.indexOf(columnName);
    if (colIndex == -1) throw ArgumentError('Column "$columnName" not found.');
    List<dynamic> values = datacat.rows.map((row) => row[colIndex]).toList();
    List<num?> result = List<num?>.filled(values.length, null);
    for (int i = 0; i < values.length; i++) {
      int windowStart = (i - windowSize + 1) < 0 ? 0 : i - windowSize + 1;
      List<num> window =
          values.sublist(windowStart, i + 1).whereType<num>().toList();
      if (window.isNotEmpty) {
        result[i] = window.reduce((a, b) => a + b) / window.length;
      }
    }
    return result;
  }
}

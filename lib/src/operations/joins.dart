import '../core/datacat.dart';

/// Provides join operations between Datacat objects.
class Joins {
  /// Performs an inner join on two Datacat objects based on the column [on].
  static Datacat innerJoin(Datacat left, Datacat right, String on) {
    int leftIndex = left.columns.indexOf(on);
    int rightIndex = right.columns.indexOf(on);
    if (leftIndex == -1 || rightIndex == -1) {
      throw ArgumentError('Join column "$on" must exist in both data objects.');
    }
    List<String> newColumns = List.from(left.columns);
    for (final col in right.columns) {
      if (col != on && !newColumns.contains(col)) {
        newColumns.add(col);
      }
    }
    List<List<dynamic>> newRows = [];
    final Map<dynamic, List<List<dynamic>>> rightIndexMap = {};
    for (final row in right.rows) {
      var key = row[rightIndex];
      rightIndexMap.putIfAbsent(key, () => []).add(row);
    }
    for (final lRow in left.rows) {
      var key = lRow[leftIndex];
      final matchingRows = rightIndexMap[key];
      if (matchingRows != null) {
        for (final rRow in matchingRows) {
          List<dynamic> combinedRow = [];
          combinedRow.addAll(lRow);
          for (int i = 0; i < right.columns.length; i++) {
            if (i == rightIndex) continue;
            combinedRow.add(rRow[i]);
          }
          newRows.add(combinedRow);
        }
      }
    }
    return Datacat(columns: newColumns, rows: newRows);
  }
}

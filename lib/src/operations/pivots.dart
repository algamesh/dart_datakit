import '../core/datacat.dart';

/// Provides pivot Datacat functionality.
class Pivots {
  /// Creates a pivot Datacat from [datacat] using [indexColumn] for rows,
  /// [pivotColumn] for new column headers, and [valueColumn] for values.
  /// Aggregates values using sum.
  static Datacat pivot(Datacat datacat, String indexColumn, String pivotColumn,
      String valueColumn) {
    int indexCol = datacat.columns.indexOf(indexColumn);
    int pivotCol = datacat.columns.indexOf(pivotColumn);
    int valueCol = datacat.columns.indexOf(valueColumn);
    if (indexCol == -1 || pivotCol == -1 || valueCol == -1) {
      throw ArgumentError('One or more specified columns not found.');
    }
    Map<dynamic, List<List<dynamic>>> groups = {};
    for (var row in datacat.rows) {
      var key = row[indexCol];
      groups.putIfAbsent(key, () => []).add(row);
    }
    Set<dynamic> pivotValues = {};
    for (var row in datacat.rows) {
      pivotValues.add(row[pivotCol]);
    }
    List<String> newColumns = [
      indexColumn,
      ...pivotValues.map((v) => v.toString()).toList()
    ];
    List<List<dynamic>> newRows = [];
    groups.forEach((key, groupRows) {
      Map<String, num> aggregation = {};
      for (var pv in pivotValues) {
        aggregation[pv.toString()] = 0;
      }
      for (var row in groupRows) {
        var pVal = row[pivotCol];
        var value = row[valueCol];
        if (value is num) {
          aggregation[pVal.toString()] = aggregation[pVal.toString()]! + value;
        }
      }
      List<dynamic> newRow = [key];
      for (var pv in pivotValues) {
        newRow.add(aggregation[pv.toString()]);
      }
      newRows.add(newRow);
    });
    return Datacat(columns: newColumns, rows: newRows);
  }
}

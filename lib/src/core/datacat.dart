import 'dart:convert';
import 'datacat_schema.dart';

/// A versatile data structure resembling a DataFrame.
/// It holds column names and rows of data, and it can enforce a schema.
class Datacat {
  List<String> columns;
  List<List<dynamic>> rows;

  /// Optional schema that enforces required columns and types.
  DatacatSchema? _schema;

  Datacat({
    required this.columns,
    required this.rows,
  }) {
    _normalizeRows();
  }

  /// Creates a Datacat that enforces the provided [schema].
  /// The columns will be set to the keys in the schema.
  /// Throws an error if the provided rows do not conform to the schema.
  Datacat.withSchema({
    required DatacatSchema schema,
    required List<List<dynamic>> rows,
  })  : _schema = schema,
        columns = schema.requiredColumns.keys.toList(),
        rows = rows {
    _verifySchemaColumns();
    _normalizeRows();
    _verifySchemaTypes();
  }

  /// Adds a new row and verifies it against the schema if defined.
  void addRow(List<dynamic> row) {
    if (row.length != columns.length) {
      throw ArgumentError(
          'Row length (${row.length}) must match columns length (${columns.length}).');
    }
    rows.add(row);
    if (_schema != null) {
      _verifyRowTypes(row);
    }
  }

  /// Updates a cell at [rowIndex] in column [columnName] with [newValue],
  /// then checks the schema.
  void updateCell(int rowIndex, String columnName, dynamic newValue) {
    int colIndex = columns.indexOf(columnName);
    if (colIndex == -1)
      throw ArgumentError('Column "$columnName" does not exist.');
    if (rowIndex < 0 || rowIndex >= rows.length) {
      throw ArgumentError('Row index $rowIndex is out of range.');
    }
    rows[rowIndex][colIndex] = newValue;
    if (_schema != null) {
      final requiredType = _schema!.requiredColumns[columnName];
      if (requiredType != null &&
          newValue != null &&
          newValue.runtimeType != requiredType) {
        throw ArgumentError(
            'Column "$columnName" expects $requiredType but got ${newValue.runtimeType}.');
      }
    }
  }

  /// Returns a new Datacat with the first [n] rows.
  Datacat head([int n = 5]) {
    return Datacat(columns: List.from(columns), rows: rows.take(n).toList());
  }

  /// Returns a new Datacat with the last [n] rows.
  Datacat tail([int n = 5]) {
    if (rows.isEmpty) return Datacat(columns: List.from(columns), rows: []);
    int start = rows.length - n;
    if (start < 0) start = 0;
    return Datacat(columns: List.from(columns), rows: rows.sublist(start));
  }

  /// Returns a new Datacat with only the selected columns.
  Datacat selectColumns(List<String> selectedColumns) {
    List<int> indices = selectedColumns.map((col) {
      int index = columns.indexOf(col);
      if (index == -1) throw ArgumentError('Column "$col" not found.');
      return index;
    }).toList();
    List<List<dynamic>> newRows = rows.map((row) {
      return indices.map((i) => row[i]).toList();
    }).toList();
    return Datacat(columns: selectedColumns, rows: newRows);
  }

  /// Returns a new Datacat with the specified columns dropped.
  Datacat dropColumns(List<String> dropColumns) {
    List<String> remaining =
        columns.where((col) => !dropColumns.contains(col)).toList();
    return selectColumns(remaining);
  }

  /// Returns a new Datacat sorted by the given column.
  Datacat sortBy(String columnName, {bool ascending = true}) {
    int index = columns.indexOf(columnName);
    if (index == -1) throw ArgumentError('Column "$columnName" not found.');
    List<List<dynamic>> sortedRows = List.from(rows);
    sortedRows.sort((a, b) {
      var aVal = a[index];
      var bVal = b[index];
      int cmp;
      if (aVal is Comparable && bVal is Comparable) {
        cmp = aVal.compareTo(bVal);
      } else {
        cmp = aVal.toString().compareTo(bVal.toString());
      }
      return ascending ? cmp : -cmp;
    });
    return Datacat(columns: List.from(columns), rows: sortedRows);
  }

  /// Groups rows by the given column and returns a Map from key to Datacat.
  Map<dynamic, Datacat> groupBy(String columnName) {
    int index = columns.indexOf(columnName);
    if (index == -1) throw ArgumentError('Column "$columnName" not found.');
    Map<dynamic, List<List<dynamic>>> groups = {};
    for (var row in rows) {
      var key = row[index];
      groups.putIfAbsent(key, () => []).add(row);
    }
    return groups.map((key, value) =>
        MapEntry(key, Datacat(columns: List.from(columns), rows: value)));
  }

  /// Computes summary statistics for numeric columns.
  /// Returns a map with each numeric column mapped to count, sum, mean, min, and max.
  Map<String, Map<String, num>> describe() {
    Map<String, Map<String, num>> summary = {};
    for (int i = 0; i < columns.length; i++) {
      String col = columns[i];
      List<num> numericValues = [];
      for (var row in rows) {
        var value = row[i];
        if (value is num) numericValues.add(value);
      }
      if (numericValues.isNotEmpty) {
        num total = numericValues.reduce((a, b) => a + b);
        num mean = total / numericValues.length;
        num min = numericValues.reduce((a, b) => a < b ? a : b);
        num max = numericValues.reduce((a, b) => a > b ? a : b);
        summary[col] = {
          'count': numericValues.length,
          'sum': total,
          'mean': mean,
          'min': min,
          'max': max,
        };
      }
    }
    return summary;
  }

  /// Fills missing (null) values in the specified column with [fillValue].
  Datacat fillNA(String columnName, dynamic fillValue) {
    int index = columns.indexOf(columnName);
    if (index == -1) throw ArgumentError('Column "$columnName" not found.');
    for (var row in rows) {
      if (row[index] == null) {
        row[index] = fillValue;
      }
    }
    return this;
  }

  /// Verifies that the Datacat's columns conform to the schema.
  void _verifySchemaColumns() {
    if (_schema == null) return;
    final schemaCols = _schema!.requiredColumns.keys.toSet();
    final actualCols = columns.toSet();
    if (!actualCols.containsAll(schemaCols)) {
      throw ArgumentError(
          'Missing required columns. Required: $schemaCols, Found: $actualCols');
    }
    if (_schema!.strictColumns && !schemaCols.containsAll(actualCols)) {
      throw ArgumentError(
          'Extra columns detected. Allowed: $schemaCols, Found: $actualCols');
    }
  }

  /// Verifies the type of each cell against the schema.
  void _verifySchemaTypes() {
    if (_schema == null) return;
    for (final row in rows) {
      _verifyRowTypes(row);
    }
  }

  /// Verifies that the values in a [row] match the schema type definitions.
  void _verifyRowTypes(List<dynamic> row) {
    final schemaColumns = _schema!.requiredColumns;
    for (int i = 0; i < columns.length; i++) {
      final colName = columns[i];
      final requiredType = schemaColumns[colName];
      if (requiredType != null) {
        final cellValue = row[i];
        if (cellValue != null && cellValue.runtimeType != requiredType) {
          throw ArgumentError(
              'Column "$colName" expects $requiredType but got ${cellValue.runtimeType}.');
        }
      }
    }
  }

  /// Normalizes each row to have the same number of elements as [columns].
  void _normalizeRows() {
    int colCount = columns.length;
    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      if (row.length < colCount) {
        rows[i] = [...row, ...List.filled(colCount - row.length, null)];
      } else if (row.length > colCount) {
        rows[i] = row.sublist(0, colCount);
      }
    }
  }

  /// Converts a row (list) into a map using column names as keys.
  Map<String, dynamic> _rowToMap(List<dynamic> row) {
    Map<String, dynamic> map = {};
    for (int i = 0; i < columns.length; i++) {
      map[columns[i]] = i < row.length ? row[i] : null;
    }
    return map;
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.writeln(columns.join(' | '));
    buffer.writeln('-' * (columns.length * 8));
    for (var row in rows.take(5)) {
      buffer.writeln(row.map((v) => v?.toString() ?? 'null').join(' | '));
    }
    if (rows.length > 5) {
      buffer.writeln('... ${rows.length - 5} more rows');
    }
    return buffer.toString();
  }

  /// Creates a Datacat from a JSON string representing a list of objects.
  factory Datacat.fromJsonString(String jsonString) {
    final decoded = json.decode(jsonString);
    if (decoded is! List) {
      throw ArgumentError('JSON input must be a list of objects.');
    }
    if (decoded.isEmpty) {
      return Datacat(columns: [], rows: []);
    }
    final allKeys = <String>{};
    for (final item in decoded) {
      if (item is Map) {
        allKeys.addAll(item.keys.map((k) => k.toString()));
      }
    }
    final colList = allKeys.toList();
    final rowList = <List<dynamic>>[];
    for (final item in decoded) {
      if (item is Map) {
        final row = colList.map((col) => item[col]).toList();
        rowList.add(row);
      }
    }
    return Datacat(columns: colList, rows: rowList);
  }

  /// Creates nested Datacats from a JSON string representing a map
  /// where each key maps to a list of objects.
  factory Datacat.fromJsonMapString(String jsonString) {
    final decoded = json.decode(jsonString);
    if (decoded is! Map) {
      throw ArgumentError(
          'JSON input must be a map with keys mapping to lists.');
    }
    final result = <String, Datacat>{};
    decoded.forEach((key, value) {
      if (value is List) {
        result[key.toString()] = Datacat.fromJsonString(json.encode(value));
      } else {
        throw ArgumentError('Value for key "$key" must be a list.');
      }
    });
    // Return a Datacat whose columns are the keys (names of nested tables)
    // and no rows. Adjust as needed.
    return Datacat(columns: result.keys.toList(), rows: []);
  }
}

import 'dart:convert';

/// A simplified data manipulation structure in Dart.
class Datacat {
  List<String> columns;
  List<List<dynamic>> rows;

  Datacat({
    required this.columns,
    required this.rows,
  }) {
    _normalizeRows();
  }

  /// Creates a Datacat from a JSON string that represents a list of objects.
  factory Datacat.fromJsonString(String jsonString) {
    final decoded = json.decode(jsonString);
    if (decoded is! List) {
      throw ArgumentError('JSON input must be a list/array of objects');
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
        final row = colList.map((colName) => item[colName]).toList();
        rowList.add(row);
      }
    }
    return Datacat(columns: colList, rows: rowList);
  }

  /// Creates multiple Datacat instances from a JSON string that represents
  /// a map whose keys are table names and whose values are lists of objects.
  static Map<String, Datacat> fromJsonMapString(String jsonString) {
    final decoded = json.decode(jsonString);
    if (decoded is! Map) {
      throw ArgumentError(
          'JSON input must be a map with table names as keys and list values');
    }
    final result = <String, Datacat>{};
    decoded.forEach((tableName, tableData) {
      if (tableData is List) {
        final allKeys = <String>{};
        for (final item in tableData) {
          if (item is Map) {
            allKeys.addAll(item.keys.map((k) => k.toString()));
          }
        }
        final colList = allKeys.toList();

        final rowList = <List<dynamic>>[];
        for (final item in tableData) {
          if (item is Map) {
            final row = colList.map((colName) => item[colName]).toList();
            rowList.add(row);
          }
        }
        result[tableName] = Datacat(columns: colList, rows: rowList);
      } else {
        throw ArgumentError(
            'Table data for "$tableName" must be a list of objects');
      }
    });
    return result;
  }

  factory Datacat.fromCsvString(String csvString) {
    final lines = csvString.trim().split('\n');
    if (lines.isEmpty) {
      return Datacat(columns: [], rows: []);
    }
    final colList = lines.first.split(',');
    final rowList = <List<dynamic>>[];
    for (int i = 1; i < lines.length; i++) {
      final fields = lines[i].split(',');
      rowList.add(fields);
    }
    return Datacat(columns: colList, rows: rowList);
  }

  Datacat head([int n = 5]) {
    final limitedRows = rows.take(n).toList();
    return Datacat(columns: List.from(columns), rows: limitedRows);
  }

  Datacat tail([int n = 5]) {
    if (rows.isEmpty) {
      return Datacat(columns: List.from(columns), rows: []);
    }
    final start = rows.length - n < 0 ? 0 : rows.length - n;
    final limitedRows = rows.sublist(start);
    return Datacat(columns: List.from(columns), rows: limitedRows);
  }

  Datacat selectColumns(List<String> selectedCols) {
    final colIndexMap = <String, int>{};
    for (int i = 0; i < columns.length; i++) {
      colIndexMap[columns[i]] = i;
    }

    final newRows = <List<dynamic>>[];
    for (final row in rows) {
      final subRow = <dynamic>[];
      for (final col in selectedCols) {
        final idx = colIndexMap[col];
        if (idx != null && idx < row.length) {
          subRow.add(row[idx]);
        } else {
          subRow.add(null);
        }
      }
      newRows.add(subRow);
    }
    return Datacat(columns: selectedCols, rows: newRows);
  }

  Datacat dropColumns(List<String> dropCols) {
    final keepCols = columns.where((c) => !dropCols.contains(c)).toList();
    return selectColumns(keepCols);
  }

  Datacat filterRows(bool Function(Map<String, dynamic> rowMap) test) {
    final filteredRows = <List<dynamic>>[];
    for (final row in rows) {
      final rowMap = _rowToMap(row);
      if (test(rowMap)) {
        filteredRows.add(row);
      }
    }
    return Datacat(columns: List.from(columns), rows: filteredRows);
  }

  void addColumn(String columnName,
      {List<dynamic>? values, dynamic defaultValue}) {
    if (columns.contains(columnName)) {
      throw ArgumentError('Column "$columnName" already exists.');
    }

    columns.add(columnName);
    if (values != null && values.length != rows.length) {
      throw ArgumentError(
        'Length of values (${values.length}) must match row count (${rows.length}).',
      );
    }
    for (int i = 0; i < rows.length; i++) {
      final rowValue = values != null ? values[i] : defaultValue;
      rows[i].add(rowValue);
    }
  }

  void sortBy(String columnName, {bool ascending = true}) {
    final colIndex = columns.indexOf(columnName);
    if (colIndex < 0) return;

    rows.sort((a, b) {
      final valA = a[colIndex];
      final valB = b[colIndex];
      int cmp;
      if (valA is Comparable && valB is Comparable) {
        cmp = valA.compareTo(valB);
      } else {
        cmp = valA.toString().compareTo(valB.toString());
      }
      return ascending ? cmp : -cmp;
    });
  }

  void _normalizeRows() {
    final colCount = columns.length;
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < colCount) {
        rows[i] = [...row, ...List.filled(colCount - row.length, null)];
      } else if (row.length > colCount) {
        rows[i] = row.sublist(0, colCount);
      }
    }
  }

  Map<String, dynamic> _rowToMap(List<dynamic> row) {
    final map = <String, dynamic>{};
    for (int i = 0; i < columns.length; i++) {
      if (i < row.length) {
        map[columns[i]] = row[i];
      } else {
        map[columns[i]] = null;
      }
    }
    return map;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeAll(columns, ' | ');
    buffer.writeln();
    buffer.write('${'-' * (columns.length * 8)}\n');

    final limit = rows.length > 5 ? 5 : rows.length;
    for (int i = 0; i < limit; i++) {
      final row = rows[i];
      final rowValues = row.map((v) => v ?? 'null').toList();
      buffer.writeAll(rowValues, ' | ');
      buffer.writeln();
    }

    if (rows.length > 5) {
      buffer.write('... ${rows.length - 5} more rows\n');
    }
    return buffer.toString();
  }
}

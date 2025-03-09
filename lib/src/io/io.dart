import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../core/datacat.dart';

/// I/O utilities for reading and writing CSV, JSON, and Excel files.
class IO {
  /// Reads a file and returns its content as a string.
  static Future<String> readFile(String path) async {
    final file = File(path);
    return await file.readAsString();
  }

  /// Writes [content] to a file at [path].
  static Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }

  /// Reads a JSON file and returns a Datacat.
  static Future<Datacat> readJsonAsDatacat(String path) async {
    final content = await readFile(path);
    return Datacat.fromJsonString(content);
  }

  /// Reads a CSV file and returns a Datacat.
  ///
  /// This function uses [CsvToListConverter] from the csv package,
  /// which properly handles quoted fields and escaped commas.
  static Future<Datacat> readCsvAsDatacat(String path) async {
    final content = await readFile(path);
    // Using CsvToListConverter with default settings:
    // textDelimiter is '"' and fieldDelimiter is ','.
    final converter =
        CsvToListConverter(eol: "\n", textDelimiter: '"', fieldDelimiter: ',');
    List<List<dynamic>> rows = converter.convert(content);
    if (rows.isEmpty) return Datacat(columns: [], rows: []);
    // Assume the first row contains column headers.
    final columns = rows.first.map((e) => e.toString()).toList();
    final dataRows = rows.skip(1).toList();
    return Datacat(columns: columns, rows: dataRows);
  }

  /// Writes a Datacat to a CSV file.
  ///
  /// Uses ListToCsvConverter to properly quote fields as needed.
  static Future<void> writeDatacatAsCsv(String path, Datacat datacat) async {
    List<List<dynamic>> csvData = [datacat.columns, ...datacat.rows];
    String csv = const ListToCsvConverter().convert(csvData);
    await writeFile(path, csv);
  }

  /// Reads an Excel file and returns a Datacat for the first sheet.
  ///
  /// Requires the 'excel' package.
  static Future<Datacat> readExcelAsDatacat(String path) async {
    final bytes = await File(path).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;
    if (sheet.maxRows == 0) return Datacat(columns: [], rows: []);
    // Assume the first row contains column headers.
    final columns =
        sheet.row(0).map((cell) => cell?.value?.toString() ?? '').toList();
    final dataRows = <List<dynamic>>[];
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i).map((cell) => cell?.value).toList();
      dataRows.add(row);
    }
    return Datacat(columns: columns, rows: dataRows);
  }

  /// Writes a Datacat to an Excel file.
  ///
  /// Creates a new Excel workbook with a single sheet named "Sheet1".
  static Future<void> writeDatacatAsExcel(String path, Datacat datacat) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    // Write the header row.
    sheet.appendRow(datacat.columns.cast<CellValue?>());
    // Write each data row.
    for (var row in datacat.rows) {
      // Cast each row to List<CellValue?>.
      sheet.appendRow(row.cast<CellValue?>());
    }
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(path);
      await file.writeAsBytes(fileBytes, flush: true);
    }
  }
}

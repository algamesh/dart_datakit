import 'package:csv/csv.dart';

/// Utility functions for type conversion and CSV parsing.
class Converters {
  /// Converts a string to a number if possible.
  static num? toNum(String input) {
    return num.tryParse(input);
  }

  /// Converts a string to a DateTime if possible.
  static DateTime? toDateTime(String input) {
    try {
      return DateTime.parse(input);
    } catch (_) {
      return null;
    }
  }

  /// Converts a string to a boolean if possible.
  /// Accepts "true" or "false" (case-insensitive).
  static bool? toBool(String input) {
    final lower = input.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
    return null;
  }

  /// CSV parser that handles quoted fields, escaped commas, etc.
  /// Returns a List of rows where each row is a List of String values.
  static List<List<String>> parseCsv(String csvString) {
    final converter = CsvToListConverter(
      eol: "\n",
      textDelimiter: '"',
      fieldDelimiter: ',',
      shouldParseNumbers: false, // Keep everything as String.
    );
    final rows = converter.convert(csvString);
    return rows
        .map((row) => row.map((cell) => cell?.toString() ?? '').toList())
        .toList();
  }
}

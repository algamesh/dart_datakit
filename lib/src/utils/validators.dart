/// Utility functions for data validation.
class Validators {
  /// Checks if the list has duplicate entries.
  static bool hasDuplicates(List<dynamic> list) {
    return list.toSet().length != list.length;
  }
}

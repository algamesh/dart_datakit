import 'datacat.dart';

/// A container that holds multiple Datacat objects,
/// analogous to a dataset containing multiple dataframes.
class Datakitties {
  final Map<String, Datacat> catalogues;

  Datakitties({required this.catalogues});

  /// Creates a Datakitties from a JSON string representing a map of catalogues.
  /// This is similar to Datacat.fromJsonMapString, but wraps the result.
  factory Datakitties.fromJsonMapString(String jsonString) {
    final catalogues = Datacat.fromJsonMapString(jsonString);
    return Datakitties(catalogues: catalogues);
  }

  /// Returns a list of all catalogue names.
  List<String> get catalogueNames => catalogues.keys.toList();

  /// Retrieves a catalogue (Datacat) by its name.
  Datacat? getCatalogue(String name) => catalogues[name];

  /// Adds a new catalogue to the Datakitties.
  void addCatalogue(String name, Datacat datacat) {
    if (catalogues.containsKey(name)) {
      throw ArgumentError('Catalogue "$name" already exists.');
    }
    catalogues[name] = datacat;
  }

  /// Removes a catalogue by its name.
  void removeCatalogue(String name) {
    if (!catalogues.containsKey(name)) {
      throw ArgumentError('Catalogue "$name" does not exist.');
    }
    catalogues.remove(name);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Datakitties contains ${catalogues.length} catalogues:');
    for (final key in catalogues.keys) {
      buffer.writeln(' - $key: ${catalogues[key]!.rows.length} rows');
    }
    return buffer.toString();
  }
}

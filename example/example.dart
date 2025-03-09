import 'package:dart_datakit/dart_datakit.dart';

void main() {
  // Define a schema: 'id' must be int, 'name' must be String, 'value' has no enforced type.
  final schema = DatacatSchema(
    requiredColumns: {
      'id': int,
      'name': String,
      'value': null,
    },
    strictColumns: true,
  );

  // Create a Datacat with the schema.
  final datacat = Datacat.withSchema(
    schema: schema,
    rows: [
      [1, 'Alice', 10],
      [2, 'Bob', 20],
      [3, 'Charlie', null],
    ],
  );

  print('Datacat with schema:');
  print(datacat);

  // Transformation: convert 'name' to uppercase.
  Transformations.toUpperCase(datacat, 'name');
  print('After toUpperCase:');
  print(datacat);

  // Additional functionalities.
  print('Head (first 2 rows):');
  print(datacat.head(2));

  print('Sorted by "value" descending:');
  print(datacat.sortBy('value', ascending: false));

  print('Summary statistics:');
  print(datacat.describe());

  // Pivot table example:
  final pivoted = Pivots.pivot(datacat, 'id', 'name', 'value');
  print('Pivoted Table:');
  print(pivoted);

  // Demonstrate schema enforcement:
  try {
    // This should throw an error because 'id' expects int.
    datacat.updateCell(0, 'id', 'InvalidType');
  } catch (e) {
    print('Caught error during schema check: $e');
  }
}

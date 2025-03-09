import 'package:dart_datakit/dart_datakit.dart';
import 'package:test/test.dart';

void main() {
  group('Datacat tests', () {
    test('Add row and update cell with schema enforcement', () {
      final schema = DatacatSchema(
        requiredColumns: {
          'id': int,
          'name': String,
          'value': null,
        },
        strictColumns: true,
      );
      final datacat = Datacat.withSchema(
        schema: schema,
        rows: [
          [1, 'Alice', 10],
        ],
      );
      datacat.addRow([2, 'Bob', 20]);
      datacat.updateCell(0, 'name', 'Alicia');
      expect(datacat.rows[0][1], equals('Alicia'));

      // Test type enforcement: updating 'id' with a non-int should throw.
      expect(
        () => datacat.updateCell(0, 'id', 'NotAnInt'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Select and drop columns', () {
      final datacat = Datacat(
        columns: ['id', 'name', 'value'],
        rows: [
          [1, 'Alice', 10],
          [2, 'Bob', 20],
        ],
      );
      final selected = datacat.selectColumns(['id', 'value']);
      expect(selected.columns, equals(['id', 'value']));
      final dropped = datacat.dropColumns(['name']);
      expect(dropped.columns, equals(['id', 'value']));
    });
  });
}

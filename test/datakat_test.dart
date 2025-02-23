import 'package:dart_datakit/dart_datakit.dart';
import 'package:test/test.dart';

void main() {
  group('DataCat Tests', () {
    test('Initialization', () {
      final dk = DataCat(columns: [
        'col1',
        'col2'
      ], rows: [
        [1, 2],
        [3, 4]
      ]);

      expect(dk.columns.length, equals(2));
      expect(dk.rows.length, equals(2));
      expect(dk.rows[0], equals([1, 2]));
    });

    test('fromJsonString', () {
      final jsonString = '[{"col1":1,"col2":2},{"col1":3,"col2":4}]';
      final dk = DataCat.fromJsonString(jsonString);
      expect(dk.columns, containsAll(['col1', 'col2']));
      expect(dk.rows.length, equals(2));
    });
  });
}

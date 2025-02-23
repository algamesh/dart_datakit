import 'package:dart_datakit/dart_datakit.dart';

void main() {
  // Create a DataCat instance with sample data.
  var dataCat = DataCat(
    columns: ['Name', 'Age', 'Score'],
    rows: [
      ['Alice', 30, 85],
      ['Bob', 25, 90],
      ['Charlie', 35, 75],
      ['Diana', 28, 95],
      ['Evan', 40, 80],
    ],
  );

  print('Original DataCat:');
  print(dataCat);

  // Display the first 3 rows.
  var headData = dataCat.head(3);
  print('\nHead (first 3 rows):');
  print(headData);

  // Display the last 2 rows.
  var tailData = dataCat.tail(2);
  print('\nTail (last 2 rows):');
  print(tailData);

  // Select specific columns: "Name" and "Score".
  var selectedData = dataCat.selectColumns(['Name', 'Score']);
  print('\nSelected Columns (Name and Score):');
  print(selectedData);

  // Add a new column "Passed" with boolean values.
  dataCat.addColumn('Passed', values: [true, true, false, true, true]);
  print('\nAfter adding "Passed" column:');
  print(dataCat);

  // Filter rows where Age is greater than 30.
  var filteredData = dataCat.filterRows((row) => row['Age'] > 30);
  print('\nFiltered rows (Age > 30):');
  print(filteredData);
}

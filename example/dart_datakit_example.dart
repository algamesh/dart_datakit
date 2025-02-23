import 'package:dart_datakit/dart_datakit.dart';

void main() {
  // Create a DataKat instance with sample data.
  var dataKat = DataKat(
    columns: ['Name', 'Age', 'Score'],
    rows: [
      ['Alice', 30, 85],
      ['Bob', 25, 90],
      ['Charlie', 35, 75],
      ['Diana', 28, 95],
      ['Evan', 40, 80],
    ],
  );

  print('Original DataKat:');
  print(dataKat);

  // Display the first 3 rows.
  var headData = dataKat.head(3);
  print('\nHead (first 3 rows):');
  print(headData);

  // Display the last 2 rows.
  var tailData = dataKat.tail(2);
  print('\nTail (last 2 rows):');
  print(tailData);

  // Select specific columns: "Name" and "Score".
  var selectedData = dataKat.selectColumns(['Name', 'Score']);
  print('\nSelected Columns (Name and Score):');
  print(selectedData);

  // Add a new column "Passed" with boolean values.
  dataKat.addColumn('Passed', values: [true, true, false, true, true]);
  print('\nAfter adding "Passed" column:');
  print(dataKat);

  // Filter rows where Age is greater than 30.
  var filteredData = dataKat.filterRows((row) => row['Age'] > 30);
  print('\nFiltered rows (Age > 30):');
  print(filteredData);
}

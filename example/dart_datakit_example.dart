import 'package:dart_datakit/dart_datakit.dart';

void main() {
  // Create a Datacat instance with sample data.
  var datacat = Datacat(
    columns: ['Name', 'Age', 'Score'],
    rows: [
      ['Alice', 30, 85],
      ['Bob', 25, 90],
      ['Charlie', 35, 75],
      ['Diana', 28, 95],
      ['Evan', 40, 80],
    ],
  );

  print('Original Datacat:');
  print(datacat);

  // Display the first 3 rows.
  var headData = datacat.head(3);
  print('\nHead (first 3 rows):');
  print(headData);

  // Display the last 2 rows.
  var tailData = datacat.tail(2);
  print('\nTail (last 2 rows):');
  print(tailData);

  // Select specific columns: "Name" and "Score".
  var selectedData = datacat.selectColumns(['Name', 'Score']);
  print('\nSelected Columns (Name and Score):');
  print(selectedData);

  // Add a new column "Passed" with boolean values.
  datacat.addColumn('Passed', values: [true, true, false, true, true]);
  print('\nAfter adding "Passed" column:');
  print(datacat);

  // Filter rows where Age is greater than 30.
  var filteredData = datacat.filterRows((row) => row['Age'] > 30);
  print('\nFiltered rows (Age > 30):');
  print(filteredData);
}

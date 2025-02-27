import '../lib/dart_datakit.dart';

void main() {
  // ----- Testing Datacat -----
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

  // ----- Testing Datakitties -----
  print('\n----- Testing Datakitties -----');

  // Create a JSON string representing multiple catalogues.
  const jsonString = '''
{
  "Users": [
    { "Name": "Alice", "Age": 30, "Score": 85 },
    { "Name": "Bob", "Age": 25, "Score": 90 }
  ],
  "Products": [
    { "Product": "Widget", "Price": 9.99 },
    { "Product": "Gadget", "Price": 12.99 }
  ]
}
''';

  // Create a Datakitties instance from the JSON string.
  var datakitties = Datakitties.fromJsonMapString(jsonString);
  print(datakitties);

  // List all catalogue names.
  print('\nCatalogues in Datakitties:');
  datakitties.catalogueNames.forEach((name) => print(' - $name'));

  // Retrieve and display the "Users" catalogue.
  var usersCatalogue = datakitties.getCatalogue('Users');
  if (usersCatalogue != null) {
    print('\nUsers catalogue:');
    print(usersCatalogue);

    // Select only "Name" and "Score" columns from the Users catalogue.
    var selectedUsers = usersCatalogue.selectColumns(['Name', 'Score']);
    print('\nSelected Columns (Name and Score) from Users:');
    print(selectedUsers);
  }

  // Add a new catalogue to Datakitties.
  var extraCatalogue = Datacat(
    columns: ['ID', 'Value'],
    rows: [
      [1, 'First'],
      [2, 'Second']
    ],
  );
  datakitties.addCatalogue('Extra', extraCatalogue);
  print('\nAfter adding "Extra" catalogue:');
  print(datakitties);

  // Remove the "Products" catalogue.
  datakitties.removeCatalogue('Products');
  print('\nAfter removing "Products" catalogue:');
  print(datakitties);
}

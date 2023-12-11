import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
class DatabaseService1 extends ChangeNotifier  {
final DatabaseReference _database = FirebaseDatabase.instance.reference();

Future<int?> fetchNumberOfGasRequests() async {
  try {
    DatabaseEvent event = await _database.child('GasRequests').once();
    dynamic value = event.snapshot.value;

    print('Value from Firebase: $value');

    if (value != null) {
      if (value is Map) {
        return value.length;
      } else {
        throw Exception('Invalid data format for gas requests: $value');
      }
    } else {
      return 0; // Return 0 if the gas_requests node is null or empty
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to fetch gas requests count');
  }
}
Future<int?> fetchNumberOfDeactivated() async {
  try {
    DatabaseEvent event = await _database.child('Riders').orderByChild("status").equalTo("deactivated").once();
    dynamic value = event.snapshot.value;

    print('Value from Firebase: $value');

    if (value != null) {
      if (value is Map) {
        return value.length;
      } else {
        throw Exception('Invalid data format for gas requests: $value');
      }
    } else {
      return 0; // Return 0 if the gas_requests node is null or empty
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to fetch gas requests count');
  }
}



Future<num?> fetchTotalEarnings() async {
  try {
    // Fetch data from the 'GasRequests' node ordered by 'fare'
    DatabaseEvent event = await FirebaseDatabase.instance
        .ref()
        .child('GasRequests')
        .orderByChild("fares")
        .once();

    // Get the value from the database snapshot
    dynamic value = event.snapshot.value;

    if (value != null) {
      // Check if the value is a Map (assuming each entry in 'GasRequests' is a Map)
      if (value is Map) {
        // Iterate through the Map and sum up the 'fare' values
        num totalEarnings = 0;
        value.forEach((key, entry) {
          if (entry is Map &&
              entry.containsKey('fares') &&
              entry['fares'] is String) {
            // Convert 'fare' to a numeric type before adding to totalEarnings
            num? fareAsNumber = num.tryParse(entry['fares']);
            if (fareAsNumber != null) {
              totalEarnings += fareAsNumber;
            }
          }
        });

        return totalEarnings;
      } else {
        // Throw an exception if the value is not a Map
        throw FormatException('Invalid data format for earnings');
      }
    } else {
      // Handle the case when the value is null
      return null;
    }
  } catch (e) {
    // Print the error and throw a new exception
    print('Error: $e');
    throw Exception('Failed to fetch earnings');
  }
}



}


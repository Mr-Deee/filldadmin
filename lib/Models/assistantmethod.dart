


import 'package:filldadmin/Models/GasStation.dart';
import 'package:filldadmin/Models/Rider.dart';
import 'package:filldadmin/Models/adminusers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AssistantMethod {
  // static void getCurrentOnlineUserInfo(BuildContext context) async {
  //
  //   // String? userId = firebaseUser!
  //   //     .uid; // ASSIGN UID FROM FIREBASE TO LOCAL STRING
  //   print('assistant methods step 5:: assign firebase uid to string');
  //
  //   Query reference = FirebaseDatabase.instance.ref().child("Riders").orderByChild("status").equalTo('deactivated');
  //       //.child(userId);
  //   print(
  //       'assistant methods step 6:: call users document from firebase database using userId');
  //   try {
  //     DatabaseEvent databaseEvent = (await reference.once()) ;
  //     var data =databaseEvent.snapshot.value;
  //
  //     if (data != null ) {
  //       print(
  //           'assistant methods step 7:: assign users data to usersCurrentInfo object');
  //
  //       // Assuming you have a RiderProvider that extends ChangeNotifier
  //       context.read<Users>().setUser(Users.fromMap(
  //           Map<String, dynamic>.from(databaseEvent.snapshot.value as dynamic)));
  //
  //       print(
  //           'assistant methods step 8:: assign users data to usersCurrentInfo object');
  //     } else {
  //       print('Data not found or status is null.');
  //     }
  //   } catch (error) {
  //     print('Error fetching data: $error');
  //     // Handle the error as needed
  //   }
  // }
  static void getGasOnlineUserInfo(BuildContext context) async {

    // String? userId = firebaseUser!
    //     .uid; // ASSIGN UID FROM FIREBASE TO LOCAL STRING
    print('assistant methods step 12:: assign firebase uid to string');

    final auth =FirebaseAuth.instance.currentUser!.uid; // CALL FIREBASE AUTH INSTANCE
    String? userId =auth; // ASSIGN UID FROM FIREBASE TO LOCAL STRING


    DatabaseReference reference = FirebaseDatabase.instance.ref().child("GasStation").child(userId);
        //.child(userId);
    print(
        'assistant methods step 3:: call users document from firebase database using userId');
    try {
      DatabaseEvent databaseEvent = (await reference.once()) ;
      var data =databaseEvent.snapshot.value;

      if (data != null ) {
        print(
            'assistant methods step 7:: assign users data to usersCurrentInfo object');

        // Assuming you have a RiderProvider that extends ChangeNotifier
        context.read<GasStation>().setUser(GasStation.fromMap(
            Map<String, dynamic>.from(databaseEvent.snapshot.value as dynamic)));

        print(
            'assistant methods step 8:: assign users data to usersCurrentInfo object');
      } else {
        print('Data not found or status is null.');
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle the error as needed
    }
  }



// reference.once().then((event) async {
  //     final dataSnapshot = event.snapshot;
  //     if (dataSnapshot.value != null) {
  //       print(
  //           'assistant methods step 7:: assign users data to usersCurrentInfo object');
  //
  //       // DatabaseEvent event = await reference.once();
  //       // print(event);
  //
  //       context.read<Rider>().setRider(Rider.fromMap(
  //           Map<String, dynamic>.from(event.snapshot.value as dynamic)));
  //       print(
  //           'assistant methods step 8:: assign users data to usersCurrentInfo object');
  //       // print(Users().firstname);
  //     }
  //   }
  //   );
  // }

}
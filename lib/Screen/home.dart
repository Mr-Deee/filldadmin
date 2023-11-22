import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/Rider.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {

  DatabaseReference _ridersRef = FirebaseDatabase.instance.ref().child('Riders');
  List<Rider> _riders = [];

  @override
  void initState() {
    super.initState();
    _loadRiders();
  }

  void _loadRiders() {
    // Assuming _ridersRef is an instance of DatabaseReference
    _ridersRef.onValue.listen((event) {
      _riders.clear(); // Clear the existing list of riders

      if (event.snapshot.value != null) {
        // Check if the snapshot has a value
        Map<dynamic, dynamic>? map = event.snapshot.value as Map<dynamic, dynamic>?;

        if (map != null) {
          // Check if the map is not null
          map.forEach((key, value) {
            // Iterate through the map
            // Assuming Rider class has a constructor that takes email and FirstName
            _riders.add(Rider(
              key,
              value['email'],// Access the email property from the map
              value['numberPlate'].toString(), // Access the FirstName property from the map
              value['status'],
              // value['imageUrl'],
              // 'isActive': isActive,
              // value['licensePlateNumber'],
            ));
          });
        }
      }

      // After updating the _riders list, trigger a rebuild of the UI
      setState(() {});
    });
  }




  void _editRiderStatus(Rider rider) {
    // Implement logic to edit rider status, for example, set isActive to true/false
    // rider.name = !rider.name;
    _ridersRef.child(rider.key).update({'status': 'activate'});
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      
      body:ListView.builder(
        itemCount: _riders.length,
        itemBuilder: (context, index) {
          Rider rider = _riders[index];
          return ListTile(
            // leading: CircleAvatar(
            //   backgroundImage: NetworkImage(rider.name),
            // ),
            title: Text(rider.email),
             subtitle: Text(rider.numberPlate),
            trailing: IconButton(
              icon: Icon( Icons.switch_access_shortcut_add_rounded),
              onPressed: () => _editRiderStatus(rider),
            ),
          );
        },
      ),
    );
  }
}

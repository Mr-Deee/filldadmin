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
    _ridersRef.onValue.listen((event) {
      _riders.clear(); // Clear the existing list of riders

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map<dynamic, dynamic>?;

        if (map != null) {
          map.forEach((key, value) {
            String status = value['status'];

            // Check if the user is deactivated based on the 'status' field
            if (status == 'deactivated') {
              _riders.add(Rider(
                key,
                value['email'],
                value['numberPlate'].toString(),
                status,
                //value['imageUrl'], // Uncomment this line if imageUrl is present in your data
                // 'isActive': isActive, // Uncomment this line if isActive is present in your data
               // value['licensePlateNumber'], // Uncomment this line if licensePlateNumber is present in your data
              ));
            }
          });
        }
      }

      setState(() {});
    });
  }




  void _editRiderStatus(Rider rider) {
    // Implement logic to edit rider status, for example, set isActive to true/false
    // rider.name = !rider.name;
    _ridersRef.child(rider.key).update({'status': 'activated'});
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

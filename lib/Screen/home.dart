import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Models/Rider.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseReference _ridersRef = FirebaseDatabase.instance.ref().child('Riders');
  List<Rider> _riders = [];

  @override
  void initState() {
    super.initState();
    _loadRiders();
  }

  void _loadRiders() {
    _ridersRef.onValue.listen((event) {
      _riders.clear();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map<dynamic, dynamic>?;

        if (map != null) {
          map.forEach((key, value) {
            String status = value['status'];

            if (status == 'deactivated') {
              _riders.add(
                  Rider(
                key,
                value['FirstName'],
                value['email'],
                value['numberPlate'].toString(),
                value['riderImageUrl'],
                // status,
              ));
            }
          });
        }
      }

      setState(() {});
    });
  }

  void _editRiderStatus(Rider rider) {
    _ridersRef.child(rider.key).update({'status': 'activated'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Deactivated Users"),
      ),
      body: _riders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _riders.length,
        itemBuilder: (context, index) {
          Rider rider = _riders[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 70,
              backgroundImage:rider.imageUrl != null
                  ? NetworkImage(rider.imageUrl)
                  : AssetImage("assets/images/user_icon.png")as ImageProvider<Object>,
            ),
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(rider.Name),
                ],
              ),
            ),
            subtitle: Text(rider.email),
            trailing: IconButton(
              icon: Icon(Icons.switch_account),
              onPressed: () => _editRiderStatus(rider),
            ),
          );
        },
      ),
    );
  }
}

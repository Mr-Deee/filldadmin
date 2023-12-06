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
    // _loadRiders();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Deactivated Users"),
      ),
      body: SafeArea(

        child: Column(

          children: [

            Container(

            )
          ],
        ),


      )
    );
  }


}

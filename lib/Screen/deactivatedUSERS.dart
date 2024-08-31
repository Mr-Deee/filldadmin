import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/Rider.dart';

class deactivatedusers extends StatefulWidget {
  const deactivatedusers({super.key});

  @override
  State<deactivatedusers> createState() => _deactivatedusersState();
}

class _deactivatedusersState extends State<deactivatedusers> {
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
            String status = value['status']??"";

            if (status == 'deactivated') {
              _riders.add(
                  Rider(
                    key,
                    value['FirstName'],
                    value['email'],
                    value['numberPlate'].toString(),
                    value['earnings'].toString(),
                    value['riderImageUrl']?.toString() ?? '',
                    value['car_details']['GhanaCardUrl']?.toString() ?? '',
                    value['car_details']['GhanaCardNumber']?.toString() ?? '',
                    value['car_details']['licensePlateNumber']?.toString() ?? '',

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
        title: Text("Deactived Users"),
      ),
      body: _riders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _riders.length,
        itemBuilder: (context, index) {
          Rider rider = _riders[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage:rider.imageUrl != null
                  ? NetworkImage(rider.imageUrl,scale: 1.0)
                  : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
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
            // trailing: IconButton(
            //   icon: Icon(Icons.switch_account),
            //   onPressed: () => _editRiderStatus(rider),
            // ),

            onTap:  () => _showRiderDetails(rider),
          );
        },
      ),
    );
  }

  void _showRiderDetails(Rider rider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rider Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: double.infinity,
                height: 150.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey, // You can set the desired background color
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: rider.imageUrl != null
                        ? NetworkImage(rider.imageUrl)
                        : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                height: 150.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey, // You can set the desired background color
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: rider.ghcardimageUrl != null
                        ? NetworkImage(rider.ghcardimageUrl)
                        : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
                  ),
                ),
              ),


              SizedBox(height: 10.0),
              Text('Name: ${rider.Name}'),
              Text('Email: ${rider.email}'),
              Text('Plate Number: ${rider.numberPlate}'),
              Text('GhanaCard: ${rider.ghcard??""}'),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _editRiderStatus(rider);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Activate'),
            ),
          ],
        );
      },
    );
  }

}

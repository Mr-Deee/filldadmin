import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/Rider.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  final Query  _ridersRef = FirebaseDatabase.instance.ref().child('Riders').orderByChild("earnings");
  List<Rider> _riders = [];
  @override
  void initState() {
    super.initState();
    _loadRiders();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Earnings"),
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
                  Text(rider.name),
                ],
              ),
            ),
            subtitle: Column(
              children: [
                Text(rider.email),
                Text(rider.earnings),
              ],
            ),
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
                    image: rider.imageUrl != null
                        ? NetworkImage(rider.imageUrl)
                        : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
                  ),
                ),
              ),


              SizedBox(height: 10.0),
              Text('Name: ${rider.name}'),
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
                // _editRiderStatus(rider);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Activate'),
            ),
          ],
        );
      },
    );
  }
  void _loadRiders() {
    _ridersRef.onValue.listen(
          (event) {
        _riders.clear();

        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? map = event.snapshot.value as Map<dynamic, dynamic>?;

          if (map != null) {
            map.forEach((key, value) {
              // Check if earnings exist and are valid
              if (value['earnings'] != null && value['earnings'] > 0) {
                // Safely access nested car_details data
                var carDetails = value['car_details'] as Map<dynamic, dynamic>?;

                _riders.add(Rider(
                  key: key,
                  name: value['FirstName'] ?? '',
                  email: value['email'] ?? '',
                  numberPlate: value['numberPlate']?.toString() ?? '',
                  earnings: value['earnings'].toString(),
                  number: value['phoneNumber']?.toString() ?? '',
                  imageUrl: value['riderImageUrl'] ?? '',
                  ghcardimageUrl: carDetails?['GhanaCardUrl'],
                  ghcard: carDetails?['GhanaCardNumber'],
                  licensePlate: carDetails?['licensePlateNumber']?.toString() ?? '',
                ));
              }
            });
          }
        }

        setState(() {});
      },
      onError: (Object error, StackTrace? stackTrace) {
        print('Error loading riders: $error');
        // You can add more error-handling logic here if necessary
      },
    );
  }

}
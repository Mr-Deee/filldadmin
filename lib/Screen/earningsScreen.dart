import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Models/Rider.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  final Query _ridersRef = FirebaseDatabase.instance.ref().child('Riders').orderByChild("earnings");
  List<Rider> _riders = [];

  @override
  void initState() {
    super.initState();
    _loadRiders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Earnings")),
      body: _riders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _riders.length,
        itemBuilder: (context, index) {
          Rider rider = _riders[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: rider.imageUrl != null
                  ? NetworkImage(rider.imageUrl)
                  : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
            ),
            title: Text(rider.name ?? "Unknown"), // Handling null
            subtitle: Text(rider.earnings ?? "No earnings"), // Handling null
            onTap: () => _showRiderDetails(rider),
          );
        },
      ),
    );
  }

  void _showRiderDetails(Rider rider) {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Rider Details'),
          content: Column(
            children: [
              Text("Name: ${rider.name}"),
              Text("Email: ${rider.email}"),
              Text("Earnings: ${rider.earnings}"),
              rider.imageUrl != null
                  ? Image.network(rider.imageUrl)
                  : Image.asset("assets/images/useri.png"),
              // rider.ghcardimageUrl != null
              //     ? Image.network(rider.ghcardimageUrl)
              //     : Container(), // Show empty if null
            ],
          ),
        ),
      );
    } catch (e) {
      print("Error showing rider details: $e");
    }
  }

  void _loadRiders() {
    _ridersRef.onValue.listen(
          (event) {
        _riders.clear();
        if (event.snapshot.value != null) {
          try {
            Map<dynamic, dynamic>? map = event.snapshot.value as Map<dynamic, dynamic>?;
            if (map != null) {
              map.forEach((key, value) {
                try {
                  var earningsRaw = value['earnings'];
                  int earnings = 0;
                  if (earningsRaw != null) {
                    earnings = int.tryParse(earningsRaw.toString()) ?? 0;
                  }

                  if (earnings > 0) {
                    var carDetails = value['car_details'] as Map<dynamic, dynamic>?;
                    _riders.add(Rider(
                      key: key,
                      name: value['FirstName'] ?? 'Unknown',
                      email: value['email'] ?? 'Unknown',
                      numberPlate: value['numberPlate']?.toString() ?? 'Unknown',
                      earnings: earnings.toString(),
                      number: value['phoneNumber']?.toString() ?? 'Unknown',
                      imageUrl: value['riderImageUrl'] ?? '',
                      ghcardimageUrl: carDetails?['GhanaCardUrl'],
                      ghcard: carDetails?['GhanaCardNumber'],
                      licensePlate: carDetails?['licensePlateNumber']?.toString() ?? 'Unknown',
                    ));
                  }
                } catch (e) {
                  print("Error parsing rider data: $e");
                }
              });
            }
          } catch (e) {
            print("Error parsing snapshot value: $e");
          }
        }
        setState(() {});
      },
      onError: (error) {
        print("Error loading riders from Firebase: $error");
      },
    );
  }
}

import 'package:filldadmin/Screen/requests.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/DatabaseService.dart';
import '../Models/Rider.dart';
import '../Models/adminusers.dart';
import '../main.dart';
import '../notifications/pushNotificationService.dart';
import 'addfacts.dart';
import 'deactivatedUSERS.dart';
import 'earningsScreen.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseReference _ridersRef =
      FirebaseDatabase.instance.ref().child('Riders');
  List<Rider> _riders = [];

  @override
  void initState() {
    super.initState();
    _loadRiders();
    getCurrentArtisanInfo();
    fetchOngoingRequests();
  }
  Users? riderinformation;

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService1>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Sign Out'),
                      backgroundColor: Colors.white,
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text('Are you certain you want to Sign Out?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            print('yes');
                            FirebaseAuth.instance.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/authpage", (route) => false);
                            // Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: Card(
                  color: Colors.white,
                  child: FutureBuilder<int?>(
                    future: databaseService.fetchNumberOfGasRequests(),
                    builder: (context, event) {
                      if (event.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        int? numberOfRequests = event.data;

                        if (numberOfRequests != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 100,
                                child: FutureBuilder<num?>(
                                  future: databaseService.fetchTotalEarnings(),
                                  builder: (context, event) {
                                    if (event.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else {
                                      num? earnings = event.data;

                                      if (earnings != null) {
                                        return FutureBuilder<int?>(
                                          future: databaseService
                                              .fetchNumberOfDeactivated(),
                                          builder:
                                              (context, deactivatedSnapshot) {
                                            if (deactivatedSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else {
                                              int? numberOfDeactivatedUsers =
                                                  deactivatedSnapshot.data;

                                              if (numberOfDeactivatedUsers !=
                                                  null) {
                                                return PieChart(
                                                  PieChartData(
                                                    sections: [
                                                      PieChartSectionData(
                                                        color: Colors.blue,
                                                        value: numberOfRequests
                                                            .toDouble(),
                                                        title: '',
                                                        radius: 20,
                                                      ),
                                                      PieChartSectionData(
                                                        color: Colors.tealAccent,
                                                        value:
                                                            earnings.toDouble(),
                                                        title: '',
                                                        radius: 20,
                                                      ),
                                                      PieChartSectionData(
                                                        color: Colors.redAccent,
                                                        value:
                                                            numberOfDeactivatedUsers
                                                                .toDouble(),
                                                        title: '',
                                                        radius: 20,
                                                      ),
                                                    ],
                                                    sectionsSpace: 0,
                                                    centerSpaceRadius: 20,
                                                    startDegreeOffset: -90,
                                                  ),
                                                );
                                              } else {
                                                return Text(
                                                  'Failed to fetch number of deactivated users',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.red),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      } else {
                                        return Text(
                                          'Failed to fetch earnings',
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.red),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 20),
                              // Text(
                              //   'Number of Requests: $numberOfRequests',
                              //   style: TextStyle(fontSize: 18),
                              // ),

                              FutureBuilder<num?>(
                                future: databaseService.fetchTotalEarnings(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    num? earnings = snapshot.data;

                                    if (earnings != null) {
                                      return Text(
                                        'Earnings: \GHS${earnings}',
                                        style: TextStyle(fontSize: 18),
                                      );
                                    } else {
                                      return Text(
                                        'Failed to fetch earnings',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.red),
                                      );
                                    }
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //gas stations
                                    FutureBuilder<num?>(
                                      future: databaseService
                                          .fetchNumberOfGasStation(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else {
                                          num? gasStation = snapshot.data;

                                          if (gasStation != null) {
                                            return Text(
                                              'GasStation: ${gasStation}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            );
                                          } else {
                                            return Text(
                                              'Failed to fetch earnings',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.red),
                                            );
                                          }
                                        }
                                      },
                                    ),
          //Add funnfact
                                    GestureDetector(
                                      onTap: () {

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                            builder: (context) =>
                                            AddFacts(),
                                        ),);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {


                                              },
                                              icon: const Icon(
                                                Icons.comment,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              'Add FunFact',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Legend for Color Codes:
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Legend for Requests
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: (){
                                         Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    Requests(),
                                              ));
                                      },
                                      child: Text('Requests($numberOfRequests)')),

                                    SizedBox(width: 20),

                                    // Legend for Earnings
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.tealAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 5),

                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EarningScreen(),
                                              ));
                                        },
                                        child: Text('Earnings')),

                                    SizedBox(width: 20),

                                    // Legend for Deactivated
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Padding(
                                      padding: const EdgeInsets.all(13.0),
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DeactivatedUsers(),
                                                ));
                                          },
                                          child: Text('Deactivated')),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        } else {
                          return Text(
                            'Failed to fetch number of requests',
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(left:10,top: 10.0),
                    child: Text(
                      "Ongoing Delieveries",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: Container(
                  height: 304,
                  width: 393,
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ongoingRequests.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: ongoingRequests.length,
                    itemBuilder: (context, index) {
                      final rider = ongoingRequests[index];
                      return ListTile(
                        leading: Container(
                          width: 60, // Specify a fixed width for the leading container
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: rider['profilepicture'] != null
                                ? NetworkImage(rider['profilepicture'])
                                : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.motorcycle, size: 16),
                                    SizedBox(width: 4),
                                    Text(rider['driver_name'] ?? ""),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 16),
                                    SizedBox(width: 4),
                                    Text(rider['client_name'] ?? ""),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.gas_meter, size: 16),
                                    SizedBox(width: 4),
                                    Text('GHS${rider["Gas Amount"]??'-'}'??"N/A"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.money, size: 16),
                                    SizedBox(width: 4),
                                    Text('GHS${rider["fare"]??'-'}'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        // subtitle: Row(
                        //   children: [
                        //     Icon(Icons.person_4_outlined, size: 16),
                        //     SizedBox(width: 4),
                        //     Text(rider["client_name"] ?? ""),
                        //   ],
                        // ),
                      );
                    },
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('Are you certain you want to Sign Out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                print('yes');
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
                // Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

    List<Map<String, dynamic>> ongoingRequests = [];

 Future<void> fetchOngoingRequests() async {
    final databaseReference = FirebaseDatabase.instance.ref('GasRequests').orderByChild('status').equalTo('onride');
    final snapshot = await databaseReference.get();
// print('geeer:$snapshot');

    databaseReference.onValue.listen((event) {
    if (snapshot.exists) {
      // print('geeer2:$snapshot');
       final List<Map<String, dynamic>> requests = [];
      (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
        requests.add({
          'id': key,
          'driver_name': value['driver_name'],
          'client_name': value['client_name'],
          'fare': value['fare'],
           'client_phone': value['client_phone'],
           'profilepicture': value['profilepicture'],
           'Gas Amount': value['Gas Amount'],
          // 'gasPrice': value['gasPrice'],
          // 'location': value['location'],
          // 'kilometers': value['kilometers'],
        });
      });
      setState(() {
        ongoingRequests = requests;

        //(snapshot.value as List).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  });
 }

  void _loadRiders() {
    _ridersRef
        .orderByChild('earnings')
        .limitToLast(1)
        .once()
        .then((DatabaseEvent event) {
      _riders.clear();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map<dynamic, dynamic>?;

        map?.forEach((key, value) {
          // Safely handle car_details and its nested fields
          var carDetails = value['car_details'] as Map<dynamic, dynamic>?;

          _riders.add(
            Rider(
              key: key,
              name: value['FirstName'] ?? '',
              email: value['email'] ?? '',
              numberPlate: value['numberPlate']?.toString() ?? '',
              earnings: value['earnings']?.toString() ?? '',
              number: value['phoneNumber']?.toString() ?? '',
              imageUrl: value['riderImageUrl'] ?? '',
              ghcardimageUrl: carDetails?['GhanaCardUrl'],
              ghcard: carDetails?['GhanaCardNumber'],
              licensePlate: carDetails?['licensePlateNumber']?.toString() ?? '',
            ),
          );
        });
      }

      setState(() {});
    }).catchError((error) {
      print('Error loading riders: $error');
    });
  }


  getCurrentArtisanInfo() async {
    currentfirebaseUser = await FirebaseAuth.instance.currentUser;
    admin.child(currentfirebaseUser!.uid).once().then((event) {
      // print("value");
      if (event.snapshot.value is Map<Object?, Object?>) {
        riderinformation = Users.fromMap((event.snapshot.value as Map<Object?, Object?>).cast<String, dynamic>());

      }

      // PushNotificationService pushNotificationService = PushNotificationService();
      // pushNotificationService.initialize(context);
      // pushNotificationService.getToken();
    });

    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();


  }
}
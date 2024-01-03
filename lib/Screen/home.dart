import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/DatabaseService.dart';
import '../Models/Rider.dart';
import '../main.dart';
import 'deactivatedUSERS.dart';

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
    var databaseService = Provider.of<DatabaseService1>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Dashboard",style: TextStyle(fontWeight: FontWeight.bold),),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      height: 200,
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
                                future: databaseService.fetchNumberOfDeactivated(),
                                builder: (context, deactivatedSnapshot) {
                                  if (deactivatedSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    int? numberOfDeactivatedUsers = deactivatedSnapshot.data;

                                    if (numberOfDeactivatedUsers != null) {
                                      return Card (
                                        elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.blue,
                                              value: numberOfRequests.toDouble(),
                                              title: '',
                                              radius: 60,
                                            ),
                                            PieChartSectionData(
                                              color: Colors.tealAccent,
                                              value: earnings.toDouble(),
                                              title: '',
                                              radius: 60,
                                            ),
                                            PieChartSectionData(
                                              color: Colors.redAccent,
                                              value: numberOfDeactivatedUsers.toDouble(),
                                              title: '',
                                              radius: 60,
                                            ),
                                          ],
                                          sectionsSpace: 0,
                                          centerSpaceRadius: 40,
                                          startDegreeOffset: -90,
                                        ),
                                      );)
                                    } else {
                                      return Text(
                                        'Failed to fetch number of deactivated users',
                                        style: TextStyle(fontSize: 18, color: Colors.red),
                                      );
                                    }
                                  }
                                },
                              );
                            } else {
                              return Text(
                                'Failed to fetch earnings',
                                style: TextStyle(fontSize: 18, color: Colors.red),
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
                    SizedBox(height: 10),
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
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            );
                          }
                        }
                      },
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
                          Text('Requests($numberOfRequests)'),
                      
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
                        Text('Earnings'),
                      
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
                          SizedBox(width: 5),
                          GestureDetector(

                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                  builder: (context) =>
                                  deactivatedusers(),
                              ));

                            },
                              child: Text('Deactivated')),
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
}


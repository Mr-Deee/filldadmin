import 'package:filldadmin/Models/GasStation.dart';
import 'package:filldadmin/Models/adminusers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../Models/assistantmethod.dart';
import '../utils/app_constant.dart';
import '../utils/app_data.dart';
import '../widgets/prefered_payment_widget.dart';
import '../widgets/smart_device_box_widget.dart';

class GasStationDashboard extends StatefulWidget {
  const GasStationDashboard({super.key});

  @override
  State<GasStationDashboard> createState() => _GasStationDashboardState();
}

class _GasStationDashboardState extends State<GasStationDashboard> {
  @override
  void initState() {
    setState(() {
      Provider.of<GasStation>(context, listen: false).gasInfo;
    });
    super.initState();
    AssistantMethod.getGasOnlineUserInfo(context);
    _locationService = LocationService();
    _getCurrentLocation();
  }

  String? selectedOption = 'momo'; // Set a default value
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();

  String currentGasStatus = ''; // Initialize with an appropriate default value
  LocationService? _locationService;
  Position? _currentPosition;
  String? _locationName;

  List<bool> isSelected = [false, false]; // Initially, no method selected
  Future<void> _getCurrentLocation() async {
    Position? currentPosition = await _locationService!.getCurrentLocation();
    String? locationName = await _locationService?.getLocationName(
        currentPosition!.latitude, currentPosition.longitude);

    setState(() {
      _currentPosition = currentPosition!;
      _locationName = locationName!;
    });
  }

  void getcurrentgas() {
    _databaseRef.once().then((DatabaseEvent event) {
      var data = event.snapshot.value as Map<String,
          dynamic>?; // Assuming 'GasStatus' is the key in Firebase where gas status is stored
      if (data != null && data['GasStatus'] != null) {
        currentGasStatus = data['GasStatus'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gasprovider = Provider.of<GasStation>(context).gasInfo;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppConstant.horizontalPadding,
                  right: AppConstant.horizontalPadding,
                  top: AppConstant.verticalPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Image.asset(
                    //   'assets/images/menu.png',
                    //   height: 30,
                    //   color: Colors.grey[800],
                    // ),
                    Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey[800],
                    ),
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
                                      Text(
                                          'Are you certain you want to Sign Out?'),
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
                                      Navigator.pushNamedAndRemoveUntil(context,
                                          "/authpage", (route) => false);
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
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstant.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome To Fill'd",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${gasprovider?.GasStationName}' ?? "",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 52,
                      ),
                    ),
                    Text(
                      '${gasprovider?.GasStationNumber}' ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: <Widget>[
                        Text('Current Location :$_locationName',
                            style: TextStyle(fontSize: 20.0))
                      ]),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstant.horizontalPadding,
                ),
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstant.horizontalPadding,
                ),
                child: Text(
                  'DASHBOARD',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              //More Or No Gas
              SizedBox(
                height: 300,
                child: Expanded(
                  child: GridView.builder(
                    itemCount: AppData.smartDevices.length,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.3,
                    ),
                    itemBuilder: (context, index) {
                      return SmartOptionBoxWidget(
                          smartDeviceName: AppData.smartDevices[index][0],
                          iconPath: AppData.smartDevices[index][1],
                          isPowerOn: AppData.smartDevices[index][2],
                          onChanged: (bool newValue) {
                            setState(() {
                              AppData.smartDevices[index][0] =
                                  newValue ? "No Gas" : "More Gas";
                              AppData.smartDevices[index][2] = newValue;
                              if (currentGasStatus !=
                                  AppData.smartDevices[index][0]) {
                                // Update the Firebase database with the new gas status
                                _databaseRef.update({
                                  "GasStatus": AppData.smartDevices[index][0]
                                });
                              }
                            });
                          });
                    },
                  ),
                ),
              ),
              //Prefered Payment

              // Prefered Payment
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstant.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'PREFERRED PAYMENT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      hint: Text('Select payment method'),
                      value: selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue!;
                        });
                      },
                      items: [

                        DropdownMenuItem<String>(
                        value: 'momo',
                        child: Text('Momo'),
                      ),
                        DropdownMenuItem<String>(
                          value: 'bank',
                          child: Text('Bank'),
                        ),]
                      //     .map<DropdownMenuItem<String>>((String value) {
                      //   return DropdownMenuItem<String>(
                      //     value: value,
                      //     child: Text(value),
                      //   );
                      // }).toList(),
                    ),
                    if (selectedOption!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          TextField(
                            controller: accountNumberController,
                            decoration: InputDecoration(
                              labelText: 'Account Number',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: accountNameController,
                            decoration: InputDecoration(
                              labelText: 'Account Name',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Save data to Firebase Realtime Database
                              saveDataToFirebase();
                            },
                            child: Text('Done'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveDataToFirebase() {
    // Use Firebase Realtime Database API to save data
    // Replace the following placeholder code with the actual Firebase code
    String accountNumber = accountNumberController.text;
    String accountName = accountNameController.text;
    _databaseRef.update({
      "AccountType": accountName,
      "AccountNumber":accountNumber,
    });

    // TODO: Add Firebase Realtime Database code to save accountNumber, accountName, and selectedOption
  }
}

final auth = firebaseUser?.uid;

final DatabaseReference _databaseRef =
    FirebaseDatabase.instance.ref().child('GasStation/$auth/');

class LocationService {
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.name ?? 'Location Name not available';
      } else {
        return 'Location Name not available';
      }
    } catch (e) {
      return 'Error getting location name';
    }
  }

  getCurrentLocation() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return currentPosition;
    } catch (e) {
      return null;
    }
  }
}

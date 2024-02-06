import 'dart:ui';

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
import '../Authpage.dart';
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
  Map<String, List<TimeOfDay>> dayTimeMap = Map();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController GasStationLocontroller = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController availableDaysController = TextEditingController();
  TextEditingController availableTimeController = TextEditingController();
  List<List<TimeOfDay>> availableTimes = List.generate(7, (index) => [TimeOfDay(hour: 0, minute: 0)]);
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String currentGasStatus = ''; // Initialize with an appropriate default value
  LocationService? _locationService;
  Position? _currentPosition;

  Map<String, Map<String, String>> selectedDays = {};
  List<bool> isSelected = [false, false]; // Initially, no method selected
  Future<void> _getCurrentLocation() async {
    Position? currentPosition = await _locationService!.getCurrentLocation();
    String? locationName = await _locationService?.getLocationName(
        currentPosition!.latitude, currentPosition.longitude);

    setState(() {
      _currentPosition = currentPosition!;
      // _locationName = locationName!;
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            '${gasprovider?.GasStationNumber}' ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            ' | ${gasprovider?.Location}' ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            ' | ${gasprovider?.Preferedpayment}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

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
              Column(
                children: [
                  SizedBox(
                      height: 130,
                      child: ListView.builder(
                        itemCount: AppData.smartDevices.length,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        itemBuilder: (context, index) {
                          return // Set the elevation for the card
                            SmartOptionBoxWidget(
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
                                      "GasStatus": AppData.smartDevices[index][0],
                                    });
                                  }
                                });
                              },
                            );
                        },
                      )),
                ],
              ),
              Column(
                children: [



                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:18.0),
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text('Preferred Payment'),
                                  content: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppConstant.horizontalPadding,
                                    ),
                                    child: SizedBox(
                                      height:360,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Icon(Icons.payments_outlined, size: 30, color: Colors.grey[800]),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'PREFERRED PAYMENT',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          DropdownButton<String>(
                                            // ... (unchanged)

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
                                                  child: Text('Mobile Money'),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: 'bank',
                                                  child: Text('Bank'),
                                                ),
                                              ]
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
                                  ),
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.payment),
                              const SizedBox(width: 10),
                              Text('Prefered Payment'),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text('Add Location'),
                                content: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstant.horizontalPadding,
                                  ),
                                  child: SizedBox(
                                    height: 200,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${gasprovider?.Location}"),
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: GasStationLocontroller,
                                          decoration: InputDecoration(
                                            labelText: 'Enter your Location.',
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Update location in the Firebase Realtime Database
                                            updateLocationInFirebase(GasStationLocontroller.text);
                                            Navigator.pop(context); // Close the pop-up after updating
                                          },
                                            child: Text('Update'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.location_on),
                            const SizedBox(width: 10),
                            Text('Add Location'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(top:8.0,right:12,left:12),
                        child: Text(
                          'Choose Available Days:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 290,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: days.length,
                          itemBuilder: (context, index) {
                            String day = days[index];

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedDays.containsKey(day), // You can set the initial value based on your data
                                    onChanged: (value) {
                                      setState(() {

                                        if (value != null && value) {
                                          _showTimePickerDialog(day as String);
                                        } else {
                                          selectedDays.remove(day);
                                        }

                                      });
                                      // Handle the checkbox change here
                                      // You may want to update a list of selected days
                                    },
                                  ),
                                  Text(days[index]),
                                  SizedBox(width: 20),


                                ],
                              
                              
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),



                ],
              ),
       // SizedBox(

              // Prefered Payment

            ],
          ),
        ]),
      ),
    ));


  }
  void updateLocationInFirebase( GasStationLocontroller) {
    // Assuming you have a specific node for gas station locations in your database
    _databaseRef.update({
      'Location': GasStationLocontroller,
    }).then((_) {
      print('Location updated successfully');
      // You can add any additiona logic after updating the location
    }).catchError((error) {
      print('Failed to update location: $error');
      // Handle errors if necessary
    });
  }

  Future<void> _showTimePickerDialog(String day) async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime != null) {
      TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: startTime,
      );

      if (endTime != null) {
        setState(() {


          // if (dayIndex != -1) {
          //   selectedDays[dayIndex] = true;
          //   _saveSelectedDays();
          // }
          selectedDays[day] = {
            "Start": startTime.format(context),
                "End": endTime.format(context)

          }  ;
      _saveSelectedDays();
        }
        );
      }
    }
  }

  void _saveSelectedDays()
  {
    _databaseRef.update({
      "SelectedDays": selectedDays,

    });
    // TODO: Implement your logic to save selected days and times
    print("Selected Days and Times: $selectedDays");
  }

  void saveDataToFirebase() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                  margin: EdgeInsets.all(15.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40.0)),
                  child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 6.0,
                            ),
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                            SizedBox(
                              width: 26.0,
                            ),
                            Text("Saving,please wait")
                          ],
                        ),
                      ))));
        });
    String locationData = GasStationLocontroller.text;
    String accountNumber = accountNumberController.text;
    String accountName = accountNameController.text;
    _databaseRef.update({
      "AccountType": accountName,
      "AccountNumber": accountNumber,
      "GasStationlocation": locationData,
    });
    Navigator.pop(context);
    displayToast("Saved ", context);
    // TODO: Add Firebase Realtime Database code to save accountNumber, accountName, and selectedOption
  }

  void savelocationDataToFirebase() {
    // Use Firebase Realtime Database API to save data
    // Replace the following placeholder code with the actual Firebase code
    String locationData = GasStationLocontroller.text;
    _databaseRef.update({
      "GasStationlocation": locationData,
    });
  }
}

final auth = FirebaseAuth.instance.currentUser?.uid;

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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Models/assistantmethod.dart';
import 'Screen/GasStationDashboard.dart';
import 'Screen/home.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignIn = true;

  // Position? currentPosition;
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestLocationPermission();
    // AssistantMethod.getCurrentOnlineUserInfo(context);
    // AssistantMethod.getGasOnlineUserInfo(context);
  }

  GoogleMapController? newGoogleMapController;

  TextEditingController _locationController = TextEditingController();

  void _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Location permission is granted, you can now access the location.
      // _getCurrentLocation();
    } else if (status.isDenied) {
      // Permission has been denied, show a snackbar or dialog to inform the user.
      // You can also open the device settings to allow the permission manually.
      openAppSettings();
    } else if (status.isPermanentlyDenied) {
      // The user has permanently denied the permission. You may show a dialog
      // with a link to the app settings.
    }
  }

  void _toggleForm(bool isSignIn) {
    setState(() {
      _isSignIn = isSignIn;
    });
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  double _sigmaX = 5; // from 0-10
  double _sigmaY = 5; // from 0-10
  double _opacity = 0.2;
  double _width = 350;
  double _height = 300;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  Future<void> _signin() async {
    final emailController = TextEditingController();

    // text editing controllers
    final passwordController = TextEditingController();
    try {
      // Step 1: Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Step 2: Save a flag to indicate that the user is logged in using shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pop(
            context); // Go back to the previous page (assuming this is a modal dialog).
      } else {
        print('Invalid credentials.');
      }
    } catch (e) {
      print('Error signing in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F3FA),
      //Color(0xff23252A),
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xa670cf88), Color(0xff98e6e6)],
                        // Gradient colors
                        begin: Alignment.topLeft,
                        // Gradient start position
                        end: Alignment.bottomRight, // Gradient end position
                      ),
                      // color: Color(0xffD1E9F6),
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          SizedBox(height: 52),
                          Container(
                            // autogroup5cgo8Cw (LrGFcrPtMqbkTfkxCG5cgo)
                            padding: EdgeInsets.fromLTRB(15, 150, 23, 8),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: AssetImage(
                                  'assets/images/delivery-with-white-background-1.png',
                                ),
                              ),
                            ),
                          ),
                          //
                          Text(
                            'GAS STATIONS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 1.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // _isSignIn ? SignInForm() : SignUpForm(),
                                  SizedBox(height: 1.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      AuthOptionButton(
                                        text: 'Login',
                                        isSelected: _isSignIn,
                                        onTap: () => _toggleForm(true),
                                      ),
                                      SizedBox(width: 20.0),
                                      AuthOptionButton(
                                        text: 'Sign Up',
                                        isSelected: !_isSignIn,
                                        onTap: () => _toggleForm(false),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  _isSignIn ? SignInForm() : SignUpForm(),
                ],
              ),
            )),
      ),
    );
  }
}

displayToast(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}

class AuthOptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const AuthOptionButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.0,
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10.0, left: 35, right: 35, bottom: 30),
        child: Column(
          children: [
            SizedBox(height: 30.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.black87, // Text color
                fontSize: 16.0, // Font size
              ),
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(
                  color: Colors.grey[600], // Label color
                  fontSize: 14.0, // Label font size
                ),
                hintText: 'Enter your e-mail',
                hintStyle: TextStyle(
                  color: Colors.grey[400], // Hint color
                  fontSize: 14.0, // Hint font size
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Color(0xff98e6e6), // Border color when enabled
                    width: 1.0, // Border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Colors.blue, // Border color when focused
                    width: 2.0, // Border width
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                // Background color
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 20.0, // Padding inside the TextField
                ),
                prefixIcon: Icon(
                  Icons.email_outlined, // Email icon
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 40.0),
            TextField(
              controller: _passwordController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.black87, // Text color
                fontSize: 16.0, // Font size
              ),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.grey[600], // Label color
                  fontSize: 14.0, // Label font size
                ),
                hintText: 'Password',
                hintStyle: TextStyle(
                  color: Colors.grey[400], // Hint color
                  fontSize: 14.0, // Hint font size
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Color(0xff98e6e6), // Border color when enabled
                    width: 1.0, // Border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Colors.blue, // Border color when focused
                    width: 2.0, // Border width
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Colors.white, // Border color
                    width: 0.0, // Border width
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                // Background color
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 20.0, // Padding inside the TextField
                ),
                prefixIcon: Icon(
                  Icons.password, // Email icon
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff72B2E4), Color(0xff98e6e6)],
                    // Gradient colors
                    begin: Alignment.topLeft,
                    // Gradient start position
                    end: Alignment.bottomRight, // Gradient end position
                  ),
                  borderRadius: BorderRadius.circular(13), // Rounded corners
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 200.0, // Minimum button width
                    minHeight: 50.0, // Minimum button height
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 16.0, // Text size
                    ),
                  ),
                ),
              ),
              onPressed: () {
                loginAndAuthenticateUser(context);
                AssistantMethod.getGasOnlineUserInfo(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                // Make button background transparent
                shadowColor: Colors.transparent,
                // Remove shadow to prevent overlap
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13), // Match border radius
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Future<bool> checkAdmin(String userEmail) async {
    DatabaseEvent adminSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('Admin')
        .orderByChild('email')
        .equalTo(userEmail)
        .once();

    return adminSnapshot.snapshot.value != null;
  }

  Future<bool> checkGasStation(String userEmail) async {
    DatabaseEvent gasStationSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('GasStation')
        .orderByChild('Email')
        .equalTo(userEmail)
        .once();

    return gasStationSnapshot.snapshot.value != null;
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async {
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
                            Text("Loging In,please wait")
                          ],
                        ),
                      ))));
        });

    String userEmail = _emailController.text.trim();
    // checkAdmin(userEmail).then((isAdmin) async {
    bool isAdmin = await checkAdmin(userEmail);

    final User? firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
      email: _emailController.text.toString().trim(),
      password: _passwordController.text.toString().trim(),
    )
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;
    // try {
    //   UserCredential userCredential =
    //   await _firebaseAuth.signInWithEmailAndPassword(
    //       email: _emailController.text, password: _passwordController.text);

    if (isAdmin) {
      final User? firebaseUser = (await _firebaseAuth
              .signInWithEmailAndPassword(
        email: _emailController.text.toString().trim(),
        password: _passwordController.text.toString().trim(),
      )
              .catchError((errMsg) {
        Navigator.pop(context);
        displayToast("Error" + errMsg.toString(), context);
      }))
          .user;
      // Email found in the admin table, navigate to home page
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Homepage()),
          (Route<dynamic> route) => false);
      displayToast("Logged-in ", context);

      // Navigator.pushAndRemoveUntil(context, '/Homepage');
    } else {
      // Email not found in the admin table, check gas station table
      bool isGasStation = await checkGasStation(userEmail);
      // checkGasStation(userEmail).then((isGasStation) {
      if (isGasStation) {
        // Email found in the gas station table, navigate to gas station page
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => GasStationDashboard()),
            (Route<dynamic> route) => false);
        displayToast("Logged-in to Dashboard ", context);
      } else {
        // Email not found in either table
        print('Email not found in admin or gas station table');
        // Handle accordingly, e.g., show an error message
      }
      ;
    }
    ;
  }
}

final emailController = TextEditingController();
final firstnameController = TextEditingController();
final lastnameController = TextEditingController();
final passwordeController = TextEditingController();
final phonecontroller = TextEditingController();
String _verificationId = "";
final passwordController = TextEditingController();
final FirebaseAuth _auth = FirebaseAuth.instance;

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // locatePosition();
    // // requestSmsPermission();
    // _getCurrentLocation();

    _requestLocationPermission();
  }

  String selectedCountryCode = '+233'; // Default country code

  String verificationId = '';
  GoogleMapController? newGoogleMapController;

  // Position? currentPosition;
  //
  final Random random = Random();

  void _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Location permission is granted, you can now access the location.
      // _getCurrentLocation();
    } else if (status.isDenied) {
      // Permission has been denied, show a snackbar or dialog to inform the user.
      // You can also open the device settings to allow the permission manually.
      openAppSettings();
    } else if (status.isPermanentlyDenied) {
      // The user has permanently denied the permission. You may show a dialog
      // with a link to the app settings.
    }
  }

  //Request permission On signup
  void requestSmsPermission() async {
    if (await Permission.sms.request().isGranted) {
      // You have the SEND_SMS permission.
    } else {
      // You don't have the SEND_SMS permission. Show a rationale and request the permission.
      if (await Permission.sms.request().isPermanentlyDenied) {
        // The user has permanently denied the permission.
        // You may want to navigate them to the app settings.
        openAppSettings();
      } else {
        // The user has denied the permission but not permanently.
        // You can request the permission again.
        requestSmsPermission();
      }
    }
  }

//SendVerififcation
  void sendVerificationCode() {
    final int verificationCode = random.nextInt(900000) + 100000;
    final String message = 'Your verification code is: $verificationCode';

    // sendMS(message);
    registerNewUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
                controller: firstnameController,
                decoration: InputDecoration(
                  labelText: 'Gas Station Name',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    // Rounded corners
                    borderSide: BorderSide(
                      color: Color(0xff98e6e6), // Border color when enabled
                      width: 1.0, // Border width
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    // Rounded corners
                    borderSide: BorderSide(
                      color: Colors.blue, // Border color when focused
                      width: 2.0, // Border width
                    ),
                  ),
                ))),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                labelText: 'Email',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Color(0xff98e6e6), // Border color when enabled
                    width: 1.0, // Border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Colors.blue, // Border color when focused
                    width: 2.0, // Border width
                  ),
                )),
          ),
        ),
        Row(
          children: [
            CountryCodePicker(
              onChanged: (CountryCode code) {
                setState(() {
                  selectedCountryCode = code.dialCode!;
                });
              },
              initialSelection: 'GH',
              // Initial country
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              favorite: ['+233', 'GH'],
            ),
            Container(
              width: 200.0, // Adjust to the desired width

              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: TextFormField(
                  controller: phonecontroller,
                  decoration: InputDecoration(
                      labelText: 'Momo Phone number',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        // Rounded corners
                        borderSide: BorderSide(
                          color: Color(0xff98e6e6), // Border color when enabled
                          width: 1.0, // Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        // Rounded corners
                        borderSide: BorderSide(
                          color: Colors.blue, // Border color when focused
                          width: 2.0, // Border width
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
                labelText: 'Password',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Color(0xff98e6e6), // Border color when enabled
                    width: 1.0, // Border width
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  borderSide: BorderSide(
                    color: Colors.blue, // Border color when focused
                    width: 2.0, // Border width
                  ),
                )),
            obscureText: true,
          ),
        ),





        ElevatedButton(
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff72B2E4), Color(0xff98e6e6)],
                // Gradient colors
                begin: Alignment.topLeft,
                // Gradient start position
                end: Alignment.bottomRight, // Gradient end position
              ),
              borderRadius: BorderRadius.circular(13), // Rounded corners
            ),
            child: Container(
              constraints: BoxConstraints(
                minWidth: 200.0, // Minimum button width
                minHeight: 50.0, // Minimum button height
              ),
              alignment: Alignment.center,
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 16.0, // Text size
                ),
              ),
            ),
          ),
          onPressed: () {
            registerNewUser(context);
            AssistantMethod.getGasOnlineUserInfo(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            // Make button background transparent
            shadowColor: Colors.transparent,
            // Remove shadow to prevent overlap
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(13), // Match border radius
            ),
          ),
        ),
      ],
    );
  }

  String? _verificationCode;
  User? firebaseUser;
  User? currentfirebaseUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> registerNewUser(BuildContext context) async {
    String fullPhoneNumber =
        '$selectedCountryCode${phonecontroller.text.trim().toString()}';

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
                      borderRadius: BorderRadius.circular(20.0)),
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
                            Text("Signing up,please wait...")
                          ],
                        ),
                      ))));
        });

    firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToast("Error" + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) // user created

    {
      //save use into to database

      Map userDataMap = {
        // "email": emailController.text.trim().toString(),
        // "Name": emailController.text.trim().toString(),
        // "Name": emailController.text.trim().toString(),

        "Email": emailController.text.trim().toString(),
        "GasStationName": firstnameController.text.trim().toString(),
        "Location": lastnameController.text.trim().toString(),
        "GasStationNumber": fullPhoneNumber,
        "Password": passwordController.text.trim().toString(),
      };
      gasStation.child(firebaseUser!.uid).set(userDataMap);
      // admin.child(firebaseUser!.uid).set(userDataMap);

      currentfirebaseUser = firebaseUser;
      // registerInfirestore(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthPage(),
        ),
      );
    } else {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) {
      //     return login();
      //   }),
      // );      // Navigator.pop(context);
      // error occured - display error
      displayToast("user has not been created", context);
    }
  }

  Future<void> registerInfirestore(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      FirebaseFirestore.instance.collection('GasStation').doc(user?.uid).set({
        'GasStation': firstnameController.text.toString().trim(),
        'MobileNumber': phonecontroller.toString().trim(),
        'Email': emailController.text.toString().trim(),
        'Password': passwordController.text.toString().trim(),
        'Phone': phonecontroller.text.toString().trim(),
        // 'Gender': Gender,
        // 'Date Of Birth': birthDate,
      });
    } else
      print("ahh shit");
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) {
    //     return SignInScreen();
    //   }),
    // );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Authpage.dart';
import 'Models/GasStation.dart';
import 'Models/adminusers.dart';
import 'Screen/GasStationDashboard.dart';
import 'Screen/deactivatedUSERS.dart';
import 'Screen/home.dart';
import 'Models/DatabaseService.dart';
import 'firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(

      MultiProvider(providers: [
    ChangeNotifierProvider<DatabaseService1>(
       create: (context) => DatabaseService1(),
    ),
    ChangeNotifierProvider<Users>(
      create: (context) => Users(),
    ),
   ChangeNotifierProvider<GasStation>(
      create: (context) => GasStation(),
    ),

  //
  //
  //
   ],

child: MyApp()));
  }
class DatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Future<int> fetchNumberOfRequests() async {
    try {
      DataSnapshot snapshot = (await _database.child('requests').once()) as DataSnapshot;
      return snapshot.value as int;
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch number of requests');
    }
  }

  Future<double> fetchEarnings() async {
    try {
      DataSnapshot snapshot = (await _database.child('earnings').once()) as DataSnapshot;
      return snapshot.value as double;
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch earnings');
    }
  }
}

DatabaseReference admin = FirebaseDatabase.instance.ref().child("Admin");
DatabaseReference gasStation = FirebaseDatabase.instance.ref().child("GasStation");

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filld Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),

    initialRoute:'/',

    //FirebaseAuth.instance.currentUser == null ? '/authpage'
        //: '/GasDash',
    routes: {

      "/": (context) => CheckUserRole(),
       "/GasDash": (context) => GasStationDashboard(),
      // "/search": (context) => SearchScreen(),
      "/authpage": (context) => AuthPage(),
      "/Homepage": (context) =>Homepage(),
      "/deactivatedusers": (context) =>deactivatedUsers(),
    });


    }



}


class CheckUserRole extends StatefulWidget {
  @override
  _CheckUserRoleState createState() => _CheckUserRoleState();
}

class _CheckUserRoleState extends State<CheckUserRole> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndNavigate();
  }
  void _checkUserRoleAndNavigate() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseEvent adminSnapshot = await _databaseReference.child('Admin').once();
      DatabaseEvent gasStationSnapshot = await _databaseReference.child('GasStation').once();

      if (adminSnapshot.snapshot.value != null &&
          (adminSnapshot.snapshot.value as Map<dynamic, dynamic>).containsKey(user.uid)) {
        // User is an admin
        Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/Homepage');});
      } else if (gasStationSnapshot.snapshot.value != null &&
          (gasStationSnapshot.snapshot.value as Map<dynamic, dynamic>).containsKey(user.uid)) {
        // User is a gas station

        Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/GasDash');});
      } else {
        // User is not assigned a role
        Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/authpage');});
      }
    } else {
      // No user logged in
      Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/authpage');});
    }
  }

  @override
  Widget build(BuildContext context) {
    // You can show a loading indicator while checking user role
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screen/HOME.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(

  //     MultiProvider(providers: [
  //   ChangeNotifierProvider<AppData>(
  //     create: (context) => AppData(),
  //   ),
  //   ChangeNotifierProvider<Users>(
  //     create: (context) => Users(),
  //   ),
  //
  //
  //
  //
  // ],

MyApp());
  }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filld Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

    initialRoute: FirebaseAuth.instance.currentUser == null
    ? '/Homepage'
        : '/Homepage',
    routes: {
      // "/splash": (context) => SplashScreen(),
      // "/MainScreen": (context) => MainScreen(),
      // "/search": (context) => SearchScreen(),
      // "/authpage": (context) => AuthPage(),
      "/Homepage": (context) => homepage(),
    });


    }



}



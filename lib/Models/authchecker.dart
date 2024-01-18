import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Authpage.dart';
import '../Screen/GasStationDashboard.dart';
import '../Screen/home.dart';

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // You can replace this with a loading widget
        } else {
          if (snapshot.hasData) {
            User? user = snapshot.data;

            // Check if 'admin' table exists for the user
            DatabaseReference adminRef = FirebaseDatabase.instance.ref().child('Admin/${user?.uid}');
            return FutureBuilder<DatabaseEvent>(
              future: adminRef.once(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // You can replace this with a loading widget
                } else {
                  bool isAdmin = adminSnapshot.data?.snapshot.value != null;

                  if (isAdmin) {
                    return Homepage(); // Redirect to admin page
                  } else {
                    // Check if 'client' table exists for the user
                    DatabaseReference clientRef = FirebaseDatabase.instance.reference().child('GasStation/${user?.uid}');
                    return FutureBuilder<DatabaseEvent>(
                      future: clientRef!.once(),
                      builder: (context, event) {
                        if (event.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // You can replace this with a loading widget
                        } else {
                          bool isClient = event.data?.snapshot.value != null;

                          if (isClient) {
                            return GasStationDashboard(); // Redirect to home page
                          } else {
                            return AuthPage(); // Redirect to authentication page
                          }
                        }
                      },
                    );
                  }
                }
              },
            );
          } else {
            // User is not logged in
            return AuthPage(); // Redirect to authentication page
          }
        }
      },
    );
  }
}

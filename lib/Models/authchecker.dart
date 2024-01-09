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
            DatabaseReference adminRef = FirebaseDatabase.instance
                .reference()
                .child('Admin/${user?.uid}');
            return FutureBuilder<DataSnapshot>(
              future: adminRef.once(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // You can replace this with a loading widget
                } else {
                  bool isAdmin = adminSnapshot.data?.value != null;

                  if (isAdmin) {
                    return AdminPage(); // Redirect to admin page
                  } else {
                    // Check if 'client' table exists for the user
                    DatabaseReference clientRef = FirebaseDatabase.instance
                        .reference()
                        .child('GasStation/${user?.uid}');
                    return FutureBuilder<DataSnapshot>(
                      future: clientRef.once(),
                      builder: (context, clientSnapshot) {
                        if (clientSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // You can replace this with a loading widget
                        } else {
                          bool isClient = clientSnapshot.data?.value != null;

                          if (isClient) {
                            return Homepage(); // Redirect to home page
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

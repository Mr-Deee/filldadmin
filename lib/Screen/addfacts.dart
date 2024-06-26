import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFacts extends StatefulWidget {
  const AddFacts({Key? key}) : super(key: key);

  @override
  State<AddFacts> createState() => _AddFactsState();
}

class _AddFactsState extends State<AddFacts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<DocumentSnapshot> funFacts = []; // List to store fun facts fetched from Firestore

  @override
  void initState() {
    super.initState();
    _fetchFunFacts();
  }

  // Future<void> _fetchFunFacts() async {
  //   final snapshot = await _database.child("fun_facts").once();
  //   if (snapshot.snapshot.value!= null) {
  //     final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
  //     final fetchedFacts = data.entries.map((entry) => {
  //       'details': entry.value['details'] as String,
  //     }).toList();
  //     setState(() {
  //       funFacts = fetchedFacts;
  //     });
  //   } else {
  //     print('No fun facts found in database');
  //   }
  // }

// ... rest of your build method using funFacts
  // Function to fetch fun facts from Firestore
  Future<void> _fetchFunFacts() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('fun_facts').get();
    setState(() {
      funFacts = querySnapshot.docs.cast<DocumentSnapshot<Object?>>();
    });
  }

  // Function to delete a fun fact from Firestore
  Future<void> _deleteFunFact(DocumentSnapshot document) async {
    await document.reference.delete();
    _fetchFunFacts(); // Fetch updated fun facts after deleting
  }
  void _submitFunFact() {

    String details = _detailsController.text;

    // Write to Firebase Realtime Database
    // DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    // databaseReference.child("fun_facts").push().set({
    //   'details': details,
    // });

    // Write to Cloud Firestore
    FirebaseFirestore.instance.collection('fun_facts').add({
      'details': details,
    });

    // Clear text fields after submitting
    _nameController.clear();
    _detailsController.clear();

    // Show a pop-up message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submitted'),
          content: Text('Fun fact submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchFunFacts();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Fun Fact'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            SizedBox(height: 16.0),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(
                labelText: 'Fun Fact Details',
              ),
              maxLines: null, // Allows multiple lines
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitFunFact,
              child: Text('Submit'),
            ),
            SizedBox(height: 16.0),
            Expanded(

              child: ListView.builder(
                itemCount: funFacts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Show full details when tapped
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(funFacts[index]['details']
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteFunFact(funFacts[index] as DocumentSnapshot<Object?>);
                                  Navigator.of(context).pop();
                                  },
                                child: Text('Delete'),
                              ),

                            ],
                          );
                        },
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          funFacts[index]['details'].toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

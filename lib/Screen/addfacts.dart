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
  List<Map<String, dynamic>> funFacts = [];

  @override
  void initState() {
    super.initState();
    _fetchFunFacts();
  }

  Future<void> _fetchFunFacts() async {
    final snapshot = await _database.child("fun_facts").once();
    if (snapshot.snapshot.value!= null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      final fetchedFacts = data.entries.map((entry) => {
        'details': entry.value['details'] as String,
      }).toList();
      setState(() {
        funFacts = fetchedFacts;
      });
    } else {
      print('No fun facts found in database');
    }
  }

// ... rest of your build method using funFacts

  void _submitFunFact() {
    String name = _nameController.text;
    String details = _detailsController.text;

    // Write to Firebase Realtime Database
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child("fun_facts").push().set({
      'name': name,
      'details': details,
    });

    // Write to Cloud Firestore
    FirebaseFirestore.instance.collection('fun_facts').add({
      'name': name,
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
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Fun Fact Name',
              ),
            ),
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
                            title: Text(funFacts[index]['name']),
                            content: Text(funFacts[index]['details']),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          funFacts[index]['details'],
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

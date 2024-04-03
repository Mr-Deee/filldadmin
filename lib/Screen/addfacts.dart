import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddFacts extends StatefulWidget {
  const AddFacts({super.key});

  @override
  State<AddFacts> createState() => _AddFactsState();
}

class _AddFactsState extends State<AddFacts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

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
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:emailjs/emailjs.dart';
import 'package:filldadmin/Models/adminusers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../Models/Rider.dart';
import 'package:http/http.dart' as http;
import 'package:emailjs/emailjs.dart' as emailjs;
class deactivatedusers extends StatefulWidget {
  const deactivatedusers({super.key});

  @override
  State<deactivatedusers> createState() => _deactivatedusersState();
}

class _deactivatedusersState extends State<deactivatedusers> {
  final DatabaseReference _ridersRef = FirebaseDatabase.instance.ref().child('Riders');
  List<Rider> _riders = [];
  bool _isSending = false;

  // Replace these with your Hubtel credentials and sender info
  final String clientId = 'ttuouezo';
  final String clientSecret = 'wxyewyap';
  final String sender = 'Filld';

  @override
  void initState() {
    super.initState();
    _loadRiders();
  }

  void _loadRiders() {
    _ridersRef.onValue.listen((event) {
      _riders.clear();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map<dynamic, dynamic>?;

        if (map != null) {
          map.forEach((key, value) {
            String status = value['status']??"";

            if (status == 'deactivated') {
              _riders.add(
                  Rider(
                    key,
                    value['FirstName'],
                    value['email'],
                    value['phoneNumber'].toString(),
                    value['numberPlate'].toString(),
                    value['earnings'].toString(),
                    value['riderImageUrl']?.toString() ?? '',
                    value['car_details']['ghanaCardUrl']?.toString() ?? '',
                    value['car_details']['ghanaCardNumber']?.toString() ?? '',
                    value['car_details']['licensePlateNumber']?.toString() ?? ,

                    // status,
                  ));
            }
          });
        }
      }

      setState(() {});
    });
  }

  void _editRiderStatus(Rider rider) {
    _ridersRef.child(rider.key).update({'status': 'activated'});

    _sendActivationEmail(rider.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Deactived Users"),
      ),
      body: _riders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _riders.length,
        itemBuilder: (context, index) {
          Rider rider = _riders[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage:rider.imageUrl != null
                  ? NetworkImage(rider.imageUrl,scale: 1.0)
                  : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
            ),
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(rider.Name),
                ],
              ),
            ),
            subtitle: Text(rider.email),
            // trailing: IconButton(
            //   icon: Icon(Icons.switch_account),
            //   onPressed: () => _editRiderStatus(rider),
            // ),

            onTap:  () => _showRiderDetails(rider),
          );
        },
      ),
    );
  }

  void _showRiderDetails(Rider rider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rider Details'),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
            
                Container(
                  width: double.infinity,
                  height: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey, // You can set the desired background color
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: rider.imageUrl != null
                          ? NetworkImage(rider.imageUrl)
                          : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  height: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey, // You can set the desired background color
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: rider.ghcardimageUrl != null
                          ? NetworkImage(rider.ghcardimageUrl)
                          : AssetImage("assets/images/useri.png") as ImageProvider<Object>,
                    ),
                  ),
                ),
            
            
                SizedBox(height: 10.0),
                Text('Name: ${rider.Name}'),
                Text('Email: ${rider.email}'),
                Text('Plate Number: ${rider.licenseplate}'),
                Text('GhanaCard: ${rider.ghcard??""}'),
                // Add more details as needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),

            TextButton(
              onPressed: () {
        final phoneNumber = rider.number.trim();
        final message ="Hi there you've been activated. Thank You";

        if (phoneNumber.isNotEmpty && message.isNotEmpty) {
        sendSms(phoneNumber, message);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Please fill in all fields'),
          ));
        }
                // String?  email1=currentfirebaseUser?.email;
                print(rider.email);
                // _sendActivationEmail(email1!);
                _sendActivationwebEmail(rider.email);
                _editRiderStatus(rider);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Activate'),
            ),
          ],
        );
      },
    );
  }



  Future<void> _sendActivationwebEmail(String email) async {
    try {
      final response = await EmailJS.send(
        'service_o2ij7m8', // Replace with your EmailJS service ID
        'template_7d6cpt7', // Replace with your EmailJS template ID
        {
          'to_email':email, // The email to which the activation email will be sent
          'subject': 'Your Account Has Been Activated!',
          'message': 'Hello, your account has been activated. You can now enjoy the app!',
        },
        const Options(
          publicKey: 'N1l73HklBxqzJG95A', // Replace with your EmailJS public (user) key
          privateKey: 'JAnCLaI0hA8xbim_HZ8vy', // Replace with your EmailJS private key (optional, but more secure)
        ),
      );

      if (response.status == 200) {
        print('Activation email sent to $email');
      } else {
        print('Failed to send email. Status code: ${response.status}');
      }
    } catch (error) {
      print('Failed to send email: $error');
    }
  }
  Future<void> _sendActivationEmail(String userEmail) async {
    final Email email = Email(
      body: 'Hello, your account has been activated. You can now enjoy the app!',
      subject: "Fill'd Rider Account Has Been Activated!",
      recipients: [userEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      print('Activation email sent to $userEmail');
    } catch (error) {
      print('Failed to send email: $error');
    }
  }
  Future<void> sendSms(String phoneNumber, String message) async {
    setState(() {
      _isSending = true;
    });

    final url = Uri.parse('https://sms.hubtel.com/v1/messages/send?');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/json',
        },
        body: '''
        {
          "From": "$sender",
          "To": "0503026630",
          "Content": "$message",
          "RegisteredDelivery": true
        }
        ''',
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('SMS sent successfully!'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send SMS: ${response.body}'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
}

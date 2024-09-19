import 'dart:convert';
import 'package:emailjs/emailjs.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:http/http.dart' as http;
import '../Models/Rider.dart';

class DeactivatedUsers extends StatefulWidget {
  const DeactivatedUsers({super.key});

  @override
  State<DeactivatedUsers> createState() => _DeactivatedUsersState();
}

class _DeactivatedUsersState extends State<DeactivatedUsers> {
  final DatabaseReference _ridersRef = FirebaseDatabase.instance.ref().child('Riders');
  List<Rider> _riders = [];
  bool _isSending = false;

  final String clientId = 'ttuouezo';
  final String clientSecret = 'wxyewyap';
  final String sender = "Fill'D";

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

        map?.forEach((key, value) {
          if (value['status'] == 'deactivated') {
            // Safely handle nested 'car_details' and other fields
            var carDetails = value['car_details'] as Map<dynamic, dynamic>?;

            Rider rider = Rider(
              key: key,
              name: value['FirstName'] ?? '', // Ensure null safety
              email: value['email'] ?? '',
              number: value['phoneNumber']?.toString() ?? '',
              numberPlate: value['numberPlate']?.toString() ?? '',
              earnings: value['earnings']?.toString() ?? '',
              imageUrl: carDetails?['riderImageUrl']?.toString() ?? '',
              ghcardimageUrl: carDetails?['ghanaCardUrl']?.toString() ?? '',
              ghcard: carDetails?['ghanaCardNumber']?.toString() ?? '',
              licensePlate: carDetails?['licensePlateNumber']?.toString() ?? '',
            );

            _riders.add(rider);
          }
        });
      }

      setState(() {});
    });
  }


  void _editRiderStatus(Rider rider) {
    _ridersRef.child(rider.key).update({'status': 'activated'});
    // _sendActivationEmail(rider.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Deactivated Users", style: TextStyle(fontSize: 15)),
      ),
      body: _riders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _riders.length,
        itemBuilder: (context, index) {
          Rider rider = _riders[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: (rider.imageUrl.isNotEmpty &&
                  Uri.tryParse(rider.imageUrl)?.isAbsolute == true)
                  ? NetworkImage(rider.imageUrl)
                  : const AssetImage("assets/images/user_icon.png") as ImageProvider,
              // onBackgroundImageError: (_, __) {
              //   // Handle the case when the image URL is invalid
              //   return  AssetImage("assets/images/user_icon.png");
              // },
            ),
            title: Text(
              rider.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              rider.email,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            onTap: () => _showRiderDetails(rider),
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
          title: const Text('Rider Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageContainer(rider.imageUrl),
                const SizedBox(height: 10),
                _buildImageContainer(rider.ghcardimageUrl),
                const SizedBox(height: 10),
                Text('Name: ${rider.name}'),
                Text('Email: ${rider.email}'),
                Text('Plate Number: ${rider.licensePlate}'),
                Text('GhanaCard: ${rider.ghcard ?? ""}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _handleRiderActivation(rider);
              },
              child: const Text('Activate'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageContainer(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : const AssetImage("assets/images/useri.png") as ImageProvider,
        ),
      ),
    );
  }

  void _handleRiderActivation(Rider rider) {
    final phoneNumber = rider.number.trim();
    final name = rider.name.trim();
    print('here$phoneNumber');
    final String message    = "Dear ${name}, your uploaded documents have been reviewed and approved."
        ' Welcome to a world of convenience, accept requests and earn as much you like. '
        "Thank you for delivering with Fill'D.";
    if (phoneNumber.isNotEmpty && message.isNotEmpty) {
      sendSms(phoneNumber, message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
    // _sendActivationWebEmail(rider.email);
    //_editRiderStatus(rider);
    Navigator.of(context).pop();
  }

  // Future<void> _sendActivationWebEmail(String email) async {
  //   try {
  //     final response = await EmailJS.send(
  //       'service_o2ij7m8',
  //       'template_7d6cpt7',
  //       {
  //         'to_email': email,
  //         'subject': 'Your Account Has Been Activated!',
  //         'message': '
  //       },
  //       const Options(
  //         publicKey: 'N1l73HklBxqzJG95A',
  //         privateKey: 'JAnCLaI0hA8xbim_HZ8vy',
  //       ),
  //     );
  //
  //     if (response.status == 200) {
  //       print('Activation email sent to $email');
  //     } else {
  //       print('Failed to send email. Status code: ${response.status}');
  //     }
  //   } catch (error) {
  //     print('Failed to send email: $error');
  //   }
  // }

  // Future<void> _sendActivationEmail(String userEmail) async {
  //   final Email email = Email(
  //     body: 'Hello, your account has been activated. You can now enjoy the app!',
  //     subject: "Fill'd Rider Account Has Been Activated!",
  //     recipients: [userEmail],
  //     isHTML: false,
  //   );
  //
  //   try {
  //     await FlutterEmailSender.send(email);
  //     print('Activation email sent to $userEmail');
  //   } catch (error) {
  //     print('Failed to send email: $error');
  //   }
  // }

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
        body: jsonEncode({
          "From": sender,
          "To": phoneNumber,
          "Content": message,
          "RegisteredDelivery": true,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SMS: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
}

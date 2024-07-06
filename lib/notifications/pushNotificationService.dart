
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io' show Platform;

import '../main.dart';
import 'notificationDialog.dart';

class PushNotificationService {




  final FirebaseMessaging messaging  = FirebaseMessaging.instance;


// PROBLEM STARTS HERE
  Future initialize(context) async{
    print("Start here");

    //  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) async{
    //   retrieveRideRequestInfo(getRideRequestId(message.data), context);
    //
    //
    // });


    FirebaseMessaging.onMessage.listen((RemoteMessage message)   {
      print('Got a message whilst in the foreground!');
      retrieveRideRequestInfo(getRideRequestId(message.data), context);


    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('in the foreground!');
      retrieveRideRequestInfo(getRideRequestId(message.data), context);
    });




    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      retrieveRideRequestInfo(getRideRequestId(context), context);
    }
  }



  Future getToken() async {
    String? token = await messaging.getToken();
    print("This is token :: ");
    print(token);
    Ridersdb.child(currentfirebaseUser!.uid).child("token").set(token);
    print("JUST GOT IT");
    messaging.subscribeToTopic("alldrivers");
    messaging.subscribeToTopic("allusers");
  }

  String getRideRequestId(Map<String, dynamic> message) {
    String rideRequestId = "";
    if (Platform.isAndroid) {
      print("This is Ride Request Id:: ");
      rideRequestId = message['ride_request_id'];
      print("ride_request_id");
      print(rideRequestId);
    }
    else {
      print("This is Ride Request Id:: ");
      rideRequestId = message['ride_request_id'];
      print(rideRequestId);
    }

    return rideRequestId;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context) {
    clientRequestRef.child(rideRequestId).once().then((event) {
      final map = event.snapshot.value as Map<dynamic,dynamic>;

      print("reqid3:$rideRequestId");
      // var dataSnapshot = value.snapshot;
      // final map = dataSnapshot.value as Map<dynamic, dynamic>;
      //var map = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (event.snapshot.value != null) {
      //  assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
        //assetsAudioPlayer.play();

        double pickUpLocationLat = double.parse(
            map['pickup']['latitude'].toString());
        double pickUpLocationLng = double.parse(
            map['pickup']['longitude'].toString());
        String pickUpAddress = map['pickup_address'].toString();

        double dropOffLocationLat = double.parse(
            map['dropoff']['latitude'].toString());
        double dropOffLocationLng = double.parse(
            map['dropoff']['longitude'].toString());
        String dropOffAddress = map['dropoff_address']
            .toString();

        String paymentMethod = map['payment_method'].toString();

        String client_name = map["client_name"];
        String client_phone = map["client_phone"];

        ClientDetails clientDetails = ClientDetails();
        clientDetails.ride_request_id = rideRequestId;
        clientDetails.pickup_address = pickUpAddress;
        clientDetails.dropoff_address = dropOffAddress;
        clientDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        clientDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        clientDetails.payment_method = paymentMethod;
        clientDetails.client_name = client_name;
        clientDetails.client_phone = client_phone;

        print("Information :: ");
        print(clientDetails.pickup_address);
        print(clientDetails.dropoff_address);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(clientDetails: clientDetails,),
        );


      }
    }
    );
  }
}



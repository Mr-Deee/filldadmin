

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Authpage.dart';import '../Models/adminusers.dart';
import '../Models/assistantmethod.dart';
import '../main.dart';

class NotificationDialog extends StatelessWidget {
  //final assetsAudioPlayer =AssetsAudioPlayer();


  final Users? clientDetails;
  NotificationDialog({this.clientDetails});


  @override
  Widget build(BuildContext context)
  {

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      elevation: 1.0,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Image.asset("assets/images/delivery-with-white-background-2.png", width: 100.0,),

            Text("FILL'D", style: TextStyle(fontFamily: "Brand Bold", fontSize: 20.0,color: Colors.black,fontWeight: FontWeight.bold),),

            Text("New Delivery Request", style: TextStyle(fontFamily: "Brand Bold", fontSize: 20.0,color: Colors.black,fontWeight: FontWeight.bold),),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Text("Pick Up", style: TextStyle(fontSize: 20.0,color: Colors.black),),
                   Image.asset("assets/images/pickup.png", height: 26.0, width: 26.0,),
                      SizedBox(width: 20.0,),
                     // Expanded(child: Container(
                     //     child:  Container(child: Text(clientDetails?.pickup_address??"", style: TextStyle(fontSize: 18.0,color: Colors.black), )),
                     //     //Text("Artisan Address", style: TextStyle(fontSize: 18.0,color: Colors.black), )),
                     // ),
                  //    ) ],
                  ] ),
                  // SizedBox(height: 20.0),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Image.asset("assets/images/location.png", height: 26.0, width: 26.0,),
                      SizedBox(width: 20.0,),

                      // Expanded(
                      //     child: Container(child: Text(clientDetails?.dropoff_address??"", style: TextStyle(fontSize: 18.0,color: Colors.black), )),
                      //
                      //     //Container(child: Text("Client Address", style: TextStyle(fontSize: 18.0,color: Colors.black38),))
                      // ),
                    ],
                  ),
                  SizedBox(height: 0.0),

                ],
              ),
            ),

            SizedBox(height: 15.0),
            Divider(height: 2.0, thickness: 8.0,color: Colors.black,),
            SizedBox(height: 0.0),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(

                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)),
                      backgroundColor: Colors.red,
                      // textColor: Colors.red,
                      padding: EdgeInsets.all(8.0),
                    ),

                    onPressed: ()
                    {
                      //assetsAudioPlayer.stop();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Decline".toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                  SizedBox(width: 25.0),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.green)),

                                    backgroundColor: Colors.green
                    ),

                    onPressed: ()
                    {
                      //assetsAudioPlayer.stop();
                     // checkAvailabilityOfRide(context);



                    },
                    //color: Colors.green,
                   // textColor: Colors.white,
                    child: Text("Accept".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                  ),

                ],
              ),
            ),

            SizedBox(height: 0.0),
          ],
        ),
      ),
    );
  }


}

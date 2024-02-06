import 'package:flutter/cupertino.dart';

class GasStation extends ChangeNotifier {
 String? key;
 String? GasStationName;
 String? GasStationNumber;
 String? email;
 String? Location;
 String? Preferedpayment ;

 String? numberPlate;


 // final String status;
 // bool isActive;

 GasStation({
  this.key,
  this.GasStationName,
  this.GasStationNumber,
  this.Preferedpayment,
  this.email,
  this.Location,
  this.numberPlate,


 });


 static GasStation fromMap(Map<String, dynamic> map) {
  return GasStation(
   key: map['id'],
   email: map["Email"],
   GasStationName: map["GasStationName"],
   GasStationNumber: map["GasStationNumber"],
   Location: map["Location"],
   Preferedpayment: map["Preferred Payment"]??"Not Set"
   // profilepicture: map["Profilepicture"].toString(),
   // phone : map["phone"],

  );
 }
 GasStation? _gasuserrInfo;

 GasStation? get gasInfo => _gasuserrInfo;

 void setUser(GasStation GS) {
  _gasuserrInfo = GS;
  notifyListeners();
}
}

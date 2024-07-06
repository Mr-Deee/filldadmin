import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientDetails
{
  String? pickup_address;
  String? dropoff_address;
  LatLng? pickup;
  LatLng ?dropoff;
  String ?ride_request_id;
  String ?payment_method;
  String ?client_name;
  String ?client_phone;

  ClientDetails({this.pickup_address, this.dropoff_address, this.pickup, this.dropoff, this.ride_request_id, this.payment_method, this.client_name, this.client_phone});
}
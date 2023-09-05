import "dart:developer" as developer;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '/model/map_api.dart';
import '/data/map_api_reader.dart';



class MapAPIController with ChangeNotifier {

  MapAPI mapAPI = MapAPI();


  Future updatePickupLatLng(LatLng value) async {
    mapAPI.pickupLatLng = value;
    notifyListeners();
  }

  Future updateDriverLatLng(LatLng value) async {
    mapAPI.driverLatLng = value;
    notifyListeners();
  }



  Future<bool> updateCustomer() async {
    developer.log("Check if there is a customer.");

    final result = await MapAPIReader().getCustomer();
    if (result["status"]) {
      final jsonVal = result["body"];
      mapAPI.customerId = jsonVal["customer_id"];
      mapAPI.customerPhonenumber = jsonVal["phone"];
      mapAPI.pickupAddr  = jsonVal["pickup_address"];
      mapAPI.dropoffAddr = jsonVal["dropoff_address"]; 
      mapAPI.pickupLatLng  = LatLng(jsonVal["pickup_latitude"], jsonVal["pickup_longitude"]);
      mapAPI.dropoffLatLng = LatLng(jsonVal["dropoff_latitude"], jsonVal["dropoff_longitude"]);

      mapAPI.price = jsonVal["price"];
      mapAPI.distance = jsonVal["distance"];
      mapAPI.duration = jsonVal["duration"];
      notifyListeners();
      return Future.value(true);
    }
    else {
      notifyListeners();
      return Future.value(false);
    }
  }

  

  // Start to end = S2E
  Future updateS2EPolyline() async {
    final result = await MapAPIReader().getPolyline(mapAPI.pickupLatLng, mapAPI.dropoffLatLng, Colors.orange.shade700);
    if (result["status"]) { mapAPI.s2ePolylines = result["polyline"]; }
    else { developer.log("Unable to find the path between pickup and dropoff locations."); }
    notifyListeners();
  }

  // Driver to start = D2S
  Future updateD2SPolyline() async {
    final result = await MapAPIReader().getPolyline(mapAPI.driverLatLng, mapAPI.pickupLatLng, Colors.brown.shade700);
    if (result["status"]) { mapAPI.d2sPolylines = result["polyline"]; }
    else { developer.log("Unable to find the path between driver and pickup locations."); }
    notifyListeners();
  }



  Future postTrip(int userId, String phonenumber, int vehicleID) async {
    await MapAPIReader().postTrip(userId, phonenumber, vehicleID, mapAPI);
    notifyListeners();
  }


  Future postDriverLatLng() async {
    await MapAPIReader().postDriverLatLng(mapAPI.driverLatLng);
  }



  Future saveTrip() async {
    await mapAPI.saveTrip();
  }

  Future loadTrip() async {
    await mapAPI.loadTrip();
    await updateS2EPolyline();
    await updateD2SPolyline();
    notifyListeners();
  }

  Future clearAll() async {
    await mapAPI.clearData();
    await mapAPI.loadTrip();
    mapAPI.s2ePolylines = Polyline(points: <LatLng>[]);
    mapAPI.d2sPolylines = Polyline(points: <LatLng>[]);
    notifyListeners();
  }
  
}



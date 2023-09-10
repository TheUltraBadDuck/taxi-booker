import 'dart:convert';
import "dart:developer" as developer;
import "package:http/http.dart" as http;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '/general/constant.dart';
import '/model/map_api.dart';
import '/data/map_api_reader.dart';



class MapAPIController with ChangeNotifier {

  MapAPI mapAPI = MapAPI();
  List< Map<String, dynamic> > customerList = [];



  void updatePickupLatLng(LatLng value) {
    mapAPI.pickupLatLng = value;
    notifyListeners();
  }

  void updateDriverLatLng(LatLng value) {
    mapAPI.driverLatLng = value;
    notifyListeners();
  }

  // Start to end = S2E
  Future<void> updateS2EPolyline() async {
    final result = await MapAPIReader().getPolyline(mapAPI.pickupLatLng, mapAPI.dropoffLatLng, Colors.orange.shade700);
    if (result["status"]) { mapAPI.s2ePolylines = result["polyline"]; }
    else { developer.log("Unable to find the path between pickup and dropoff locations."); }
    notifyListeners();
  }

  // Driver to start = D2S
  Future<void> updateD2SPolyline() async {
    final result = await MapAPIReader().getPolyline(mapAPI.driverLatLng, mapAPI.pickupLatLng, Colors.brown.shade700);
    if (result["status"]) { mapAPI.d2sPolylines = result["polyline"]; }
    else { developer.log("Unable to find the path between driver and pickup locations."); }
    notifyListeners();
  }

  Future<void> updateCustomer(int currCustomer) async {
    final jsonVal = customerList[currCustomer];

    mapAPI.customerId = jsonVal["customer_id"];
    mapAPI.customerPhonenumber = jsonVal["phone"];
    mapAPI.pickupAddr  = jsonVal["pickup_address"];
    mapAPI.dropoffAddr = jsonVal["dropoff_address"]; 
    mapAPI.pickupLatLng  = LatLng(jsonVal["pickup_latitude"], jsonVal["pickup_longitude"]);
    mapAPI.dropoffLatLng = LatLng(jsonVal["dropoff_latitude"], jsonVal["dropoff_longitude"]);

    mapAPI.price = jsonVal["price"];
    mapAPI.distance = jsonVal["distance"];
    mapAPI.duration = jsonVal["duration"];
    
    await updateS2EPolyline();
    await updateD2SPolyline();
    notifyListeners();
  }



  
  Future<void> loadCustomers() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.get(
        Uri.parse(Driver.nearbyBookingRequest),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "authentication": token,
        }
      );
    }, "Get 5 nearest customers");

    if (result["status"]) {
      for (int i = 0; i < result["body"].length; i++) {
        customerList.add(result["body"][i]);
      }
    }
    notifyListeners();
  }

  Future<void> sendBookingAccept() async {
    developer.log("Trying to send booking acceptance");
    // final result = await MapAPIReader().toggleFunction((String token) async {
    //   return http.post(
    //     Uri.parse(Driver.sendBookingAccept),
    //     headers: {
    //       "Content-Type": "application/json; charset=UTF-8",
    //       "authentication": token,
    //     },
    //     body: {}
    //   );
    // }, "Send Booking Acceptance");

    // if (result["status"]) {
    //   developer.log("Successfully send accepted booking acceptance.");
    // }
  }

  Future<void> patchDriverLatLng() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.patch(
        Uri.parse(Driver.setLatLong),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "authentication": token,
        },
        body: json.encode({
          "latitude": mapAPI.driverLatLng.latitude,
          "longitude": mapAPI.driverLatLng.longitude
        })
      );
    }, "Patch Driver Location");

    if (result["status"]) {
      developer.log("Successfully update latitude and longitude.");
    }
  }

  Future<LatLng> getCustomerLatLng() async {
    return const LatLng(10.0, 100.0);
  }





  Future<void> saveTrip() async {
    await mapAPI.saveTrip();
  }

  Future<void> loadTrip() async {
    await mapAPI.loadTrip();
    await updateS2EPolyline();
    await updateD2SPolyline();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await mapAPI.clearData();
    await mapAPI.loadTrip();
    mapAPI.s2ePolylines = Polyline(points: <LatLng>[]);
    mapAPI.d2sPolylines = Polyline(points: <LatLng>[]);
    notifyListeners();
  }
  
}



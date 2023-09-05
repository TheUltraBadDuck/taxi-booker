import "dart:developer" as developer;

import 'package:flutter/material.dart';
import 'package:flutter_app_texting/model/map_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

import '/general/function.dart';
import '/data/map_api_reader.dart';



class MapAPIController with ChangeNotifier {

  MapAPI mapAPI = MapAPI();



  Future updatePickupLatLng(LatLng value) async {
    mapAPI.pickupLatLng = value;
    notifyListeners();
  }

  Future updatePickupAddr() async {
    final result = await MapAPIReader().getAddr(mapAPI.pickupLatLng);
    if (result["status"]) {
      mapAPI.pickupAddr = result["body"];
    }
    else {
      developer.log("Unable to find the pickup address.");
    }
    notifyListeners();
  }



  Future<bool> updateDropoffbyText(String text) async {

    if (text.isEmpty) {
      return Future.value(false);
    }

    final result = await MapAPIReader().getPickedData(text);
    if (result["status"]) {
      mapAPI.dropoffLatLng = LatLng(result["body"].latLong.latitude, result["body"].latLong.longitude);
      mapAPI.dropoffAddr = result["body"].address;
      notifyListeners();
      return Future.value(true);
    }
    else {
      developer.log("Unable to find the dropoff pickedData.");
      notifyListeners();
      return Future.value(false);
    }
  }



  void updateDropoffByPickedData(PickedData pickedData) {
    mapAPI.dropoffAddr = pickedData.address;
    mapAPI.dropoffLatLng = LatLng( pickedData.latLong.latitude, pickedData.latLong.longitude );
    notifyListeners();
  }

  

  // Start to end = S2E
  Future updateS2EPolyline({int vehicleID = 0}) async {
    if (vehicleID == 0) {
      final result = await MapAPIReader().getPolyline(mapAPI.pickupLatLng, mapAPI.dropoffLatLng, Colors.orange.shade700, quick: true);
      if (result["status"]) {
        mapAPI.s2ePolylines = result["polyline"];
      }
      else {
        developer.log("Unable to find the path between pickup and dropoff locations.");
      }
    }
    else {
      final result = await MapAPIReader().getPolyline(mapAPI.pickupLatLng, mapAPI.dropoffLatLng, Colors.orange.shade700);
      if (result["status"]) {
        mapAPI.s2ePolylines = result["polyline"];
        mapAPI.distance = result["distance"];
        mapAPI.duration = result["duration"];
        mapAPI.goodHour = result["good_hour"];
        mapAPI.goodWeather = result["good_weather"];
        mapAPI.price = getPrice(result["distance"], vehicleID, goodHour: mapAPI.goodHour, goodWeather: mapAPI.goodWeather);
      }
      else {
        developer.log("Unable to find the path between pickup and dropoff locations.");
      }
    }
    notifyListeners();
  }



  // Driver to start = D2S
  Future updateD2SPolyline() async {
    final result = await MapAPIReader().getPolyline(mapAPI.driverLatLng, mapAPI.pickupLatLng, Colors.brown.shade700, quick: true);
    if (result["status"]) {
      mapAPI.d2sPolylines = result["polyline"];
    }
    else {
      developer.log("Unable to find the path between driver and pickup locations.");
    }
    notifyListeners();
  }
  


  Future<bool> updateReadDriver() async {
    final result = await MapAPIReader().getNearestDriver(mapAPI.pickupLatLng);
    if (result["status"]) {
      mapAPI.driverName = result["username"];
      mapAPI.driverPhonenumber = result["phonenumber"];
      mapAPI.driverLatLng = result["latlng"];
      notifyListeners();
      return Future.value(true);
    }
    else {
      developer.log("Unable to find the nearest driver.");
      notifyListeners();
      return Future.value(false);
    }
  }



  Future updateDriverLatLng() async {
    final newLatLng = await MapAPIReader().getDriverLatLng(mapAPI.driverId);
    mapAPI.driverLatLng = newLatLng;
    notifyListeners();
  }



  Future postTrip(int userId, String phonenumber, int vehicleID) async {
    await MapAPIReader().postTrip(userId, phonenumber, vehicleID, mapAPI);
    notifyListeners();
  }



  void updateDatetime(int hour, int minute) {
    mapAPI.bookingTime = DateTime.now().toLocal();
    if ((hour != 0) || (minute != 0)) {
      mapAPI.bookingTime = DateTime(mapAPI.bookingTime.year, mapAPI.bookingTime.month, mapAPI.bookingTime.day,
                                  hour, minute, 5, mapAPI.bookingTime.millisecond, mapAPI.bookingTime.microsecond);
      notifyListeners();
    }
  }



  void updatePrice(int newPrice) {
    mapAPI.price = newPrice;
    notifyListeners();
  }



  Future saveCustomer() async {
    await mapAPI.saveCustomer();
  }

  Future saveDriver() async {
    await mapAPI.saveDriver();
  }

  Future loadCustomer() async {
    await mapAPI.loadCustomer();
    await updateS2EPolyline();
    notifyListeners();
  }

  Future loadDriver() async {
    await mapAPI.loadDriver();
    await updateD2SPolyline();
    notifyListeners();
  }

  Future loadBookingTime() async {
    final newDate = await mapAPI.loadBookingTime();
    notifyListeners();
    return newDate;
  }

  Future clearAll() async {
    await mapAPI.clearData();
    await mapAPI.loadCustomer();
    await mapAPI.loadDriver();
    notifyListeners();
  }
  
}



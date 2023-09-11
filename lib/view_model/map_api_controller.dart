import 'dart:convert';
import "dart:developer" as developer;
import "package:http/http.dart" as http;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


import '/general/function.dart';
import '/general/constant.dart';
import '/data/map_api_reader.dart';
import '/model/map_api.dart';





// enum Status {
//     pending = "PENDING",
//     CONFIRM: "CONFIRM",
//     INPROGRESS: "INPROGRESS",
//     COMPLETED: "COMPLETED"
// }



class MapAPIController with ChangeNotifier {

  MapAPI mapAPI = MapAPI();


  void updatePickupLatLng(LatLng value) {
    mapAPI.pickupLatLng = value;
    notifyListeners();
  }

  void updatePickupAddr(String value) {
    mapAPI.pickupAddr = value;
    notifyListeners();
  }

  void updateDropoffLatLng(LatLng value) {
    mapAPI.dropoffLatLng = value;
    notifyListeners();
  }

  void updateDropoffAddr(String value) {
    mapAPI.dropoffAddr = value;
    notifyListeners();
  }

  void updateDriverLatLng(LatLng value) {
    mapAPI.driverLatLng = value;
    notifyListeners();
  }

  // Start to end = S2E
  Future<void> updateS2EPolyline({int vehicleID = 0}) async {
    final result = await MapAPIReader().getPolyline(mapAPI.pickupLatLng, mapAPI.dropoffLatLng, Colors.orange.shade700);
    if (result["status"]) { mapAPI.s2ePolylines = result["polyline"];
                            mapAPI.distance = result["distance"];
                            mapAPI.duration = result["duration"];
                            mapAPI.price = getPrice(result["distance"], vehicleID, goodHour: result["good_hour"], goodWeather: result["good_weather"]); }
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

  Future<bool> searchDropoff(String text) async {
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



  Future<String> getAddr(LatLng value) async {
    final result = await MapAPIReader().getAddr(value);
    if (result["status"]) {
      return result["body"];
    }
    else {
      developer.log("Unable to get the pickup address.");
      return "";
    }
  }



  Future<void> patchPickupLatLng() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.patch(
        Uri.parse(Customer.setLatLong),
        headers: { "Content-Type": "application/json; charset=UTF-8", "authentication": token },
        body: json.encode({ "latitude": mapAPI.pickupLatLng.latitude, "longitude": mapAPI.pickupLatLng.longitude })
      );
    }, "Patch pickup latlng");

    if (result["status"]) {
      developer.log("Successfully patch pickup location.");
    }
  }

  Future<bool> getDriverLocation() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      // print("${Customer.getDriverLocation}?booking_id=${mapAPI.tripId}");
      // return http.get(
      //   Uri.http("${Customer.getDriverLocation}?booking_id=${mapAPI.tripId}"),
      //   headers: {
      //     "Content-Type": "application/json; charset=UTF-8",
      //     "authentication": token
      //   }
      // );
      return http.post(
        Uri.parse(Customer.getDriverLocation),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "authentication": token
        },
        body: json.encode({ "booking_id": mapAPI.tripId })
      );
    }, "Get driver location");

    if (result["status"]) {
      developer.log("Successfully get driver data.");
      mapAPI.driverName = result["body"]["driver_name"];
      mapAPI.driverPhonenumber = result["body"]["driver_phone"];
      mapAPI.driverLatLng = LatLng(result["body"]["driver_latitude"], result["body"]["driver_longitude"]);
      notifyListeners();
      return Future.value(true);
    }
    else {
      return Future.value(false);
    }
  }



  Future<void> setTemp(Map value) async {
    mapAPI.pickupAddr = value["pickup_address"];
    mapAPI.dropoffAddr = value["dropoff_address"];

    mapAPI.pickupLatLng  = LatLng(value["pickup_latitude"],  value["pickup_longitude"]);
    mapAPI.dropoffLatLng = LatLng(value["dropoff_latitude"], value["dropoff_longitude"]);

    mapAPI.price = value["price"];
    mapAPI.distance = value["distance"];
    mapAPI.duration = value["duration"];

    mapAPI.bookingTime = value["booking_time"];

    notifyListeners();
  }



  void setSth(value) {
    mapAPI.tripId = value;
    notifyListeners();
  }





  Future<void> postBookingRequest(String customerPhonenumber, int vehicleID) async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      print(token);
      return http.post(
        Uri.parse(Customer.sendBookingRequest),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "authentication": token
        },
        body: json.encode({
          "driver_id": "",
          "status": "PENDING",
          "phone": "string",
          
          "booking_time": mapAPI.bookingTime.toString(),
          "car_type": vehicleID,

          "pickup_address":    mapAPI.pickupAddr,
          "dropoff_address":   mapAPI.dropoffAddr,
          "pickup_latitude":   mapAPI.pickupLatLng.latitude,
          "pickup_longitude":  mapAPI.pickupLatLng.longitude,
          "dropoff_latitude":  mapAPI.dropoffLatLng.latitude,
          "dropoff_longitude": mapAPI.dropoffLatLng.longitude,

          "price":    mapAPI.price,
          "distance": mapAPI.distance,
          "duration": mapAPI.duration
        })
      );
    }, "Update pickup latlng");

    if (result["status"]) {
      mapAPI.tripId = result["body"]["_id"];
      mapAPI.driverId = result["body"]["driver_id"];
      mapAPI.driverPhonenumber = result["body"]["phone"];
    }
    notifyListeners();
  }

  Future<void> rateDriver(int star) async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.post(
        Uri.parse(Customer.setDriverRate),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "authentication": token
        },
        body: {
          "driver_id": "string",
          "rate": star
        }
      );
    }, "Rate driver $star stars");

    if (result["status"]) {
      developer.log("Successfully rate driver $star stars.");
    }
  }



  void updateDatetime(int hour, int minute) {
    mapAPI.bookingTime = DateTime.now().toLocal();
    if ((hour != 0) || (minute != 0)) {
      mapAPI.bookingTime = DateTime(mapAPI.bookingTime.year, mapAPI.bookingTime.month, mapAPI.bookingTime.day,
                                  hour, minute, 5, mapAPI.bookingTime.millisecond, mapAPI.bookingTime.microsecond);
    }
    notifyListeners();
  }



  void updatePrice(int newPrice) {
    mapAPI.price = newPrice;
    notifyListeners();
  }



  Future<void> saveCustomer() async {
    await mapAPI.saveCustomer();
  }

  Future<void> saveDriver() async {
    await mapAPI.saveDriver();
  }

  Future<void> loadCustomer() async {
    await mapAPI.loadCustomer();
    await updateS2EPolyline();
    notifyListeners();
  }

  Future<void> loadDriver() async {
    await mapAPI.loadDriver();
    await updateD2SPolyline();
    notifyListeners();
  }

  Future<DateTime> loadBookingTime() async {
    final newDate = await mapAPI.loadBookingTime();
    notifyListeners();
    return newDate;
  }

  Future<void> clearAll() async {
    await mapAPI.clearData();
    await mapAPI.loadCustomer();
    await mapAPI.loadDriver();
    notifyListeners();
  }
  
}



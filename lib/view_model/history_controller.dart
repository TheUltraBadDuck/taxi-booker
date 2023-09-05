import 'package:flutter/material.dart';



class HistoryController with ChangeNotifier {

  List<String> destinations = [];
  List<String> times = [];

  
  Future preload() async {
    destinations = [
      "Cho Ben Thanh, Ho Chi Minh City, HC, Vietnam",
      "Landmark 81, Ho Chi Minh City, HC, Vietnam",
      "Bitexco Financial Tower, Ho Chi Minh City, HC, Vietnam"
    ];
    times = [  // mm/dd/yyyy
      "2023-06-20 12:20:05.815133", "2023-06-11 12:20:05.815133", "2023-06-04 12:20:05.815133"
    ];
  }


  void appendHistory(String newDestinations, String newTimes) {
    destinations.add(newDestinations);
    times.add(newTimes);
    notifyListeners();
  }
}







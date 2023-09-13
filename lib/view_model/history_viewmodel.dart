import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

import "/general/constant.dart";
import "/service/map_api_reader.dart";



class HistoryViewmodel with ChangeNotifier {

  List<dynamic> historyList = [];

  
  Future<void> load() async {
    final result = await MapAPIReader().toggleFunction((String token) async {
      return http.get(
        Uri.parse(Customer.getHistory),
        headers: { "Content-Type": "application/json; charset=UTF-8", "authentication": token }
      );
    }, "Get History of customer.");

    if (result["status"]) {
      historyList = result["body"];
    }
    notifyListeners();
  }
}



// class HistoryController with ChangeNotifier {

//   List<String> destinations = [];
//   List<String> times = [];

  
//   Future preload() async {
//     destinations = [
//       "Cho Ben Thanh, Ho Chi Minh City, HC, Vietnam",
//       "Landmark 81, Ho Chi Minh City, HC, Vietnam",
//       "Bitexco Financial Tower, Ho Chi Minh City, HC, Vietnam"
//     ];
//     times = [  // mm/dd/yyyy
//       "2023-06-20 12:20:05.815133", "2023-06-11 12:20:05.815133", "2023-06-04 12:20:05.815133"
//     ];
//   }


//   void appendHistory(String newDestinations, String newTimes) {
//     destinations.add(newDestinations);
//     times.add(newTimes);
//     notifyListeners();
//   }
// }








import 'package:flutter/material.dart';

import '/view/decoration.dart';
import '/view_model/user_controller.dart';



typedef StringCallback = Function(String value);



class AfterTaxiTrip extends StatefulWidget {
  const AfterTaxiTrip({ Key? key, required this.userController, required this.onReturn }) : super(key: key);
  final UserController userController;
  final VoidCallback onReturn;

  @override
  State<AfterTaxiTrip> createState() => _AfterTaxiTripState();
}



class _AfterTaxiTripState extends State<AfterTaxiTrip> {

  TextEditingController dropoffController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [

      Positioned(top: 0, bottom: 0, left: 0, right: 0, child: Container(
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5))
      )),
      Positioned(bottom: 0, left: 0, right: 0, child: Container(
        height: 240,
        color: Colors.amber.shade300,
        child: Center( child: Container(
          padding: const EdgeInsets.only(left: 60, right: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text("Cảm ơn bạn đã sử dụng ứng dụng và đến nơi. Chúc bạn đến nơi vui vẻ.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              BigButton( bold: true, width: 240, label: "Quay lại", onPressed: () => widget.onReturn()) // Ra khỏi giao diện chính
            ],
          ),
        )),
      ))

    ]);
  }
}



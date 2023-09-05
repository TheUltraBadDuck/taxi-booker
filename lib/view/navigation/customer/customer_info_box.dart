import 'package:flutter/material.dart';

import '/view_model/map_controller.dart';
import '/view/decoration.dart';
import '/general/function.dart';



class CustomerInfos extends StatelessWidget {

  const CustomerInfos({
    Key? key,
    required this.mapAPIController,
    required this.onAccepted,
    required this.onRejected
  }) : super(key: key);

  final MapAPIController mapAPIController;
  final VoidCallback onAccepted;
  final VoidCallback onRejected;


  @override
  Widget build(BuildContext context) {
    return Container(

      width: 60,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        color: Colors.amber.shade300,
        boxShadow: [BoxShadow(
          color: Colors.orange.shade300.withOpacity(0.5),
          spreadRadius: 0,
          blurRadius: 3,
          offset: const Offset(3, 3), // changes position of shadow
        )]
      ),

      child: Column(children: [

        const SizedBox(height: 10),

        Text(mapAPIController.mapAPI.customerPhonenumber, style: const TextStyle(fontSize: 20)),

        const SizedBox(height: 10),

        PositionBox(
          icon: Icon(Icons.add_circle, color: Colors.deepOrange.shade900),
          height: 45,
          position: mapAPIController.mapAPI.pickupAddr
        ),

        PositionBox(
          icon: Icon(Icons.place, color: Colors.deepOrange.shade900),
          height: 45,
          position: mapAPIController.mapAPI.dropoffAddr
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(child: PriceButton(text:"${mapAPIController.mapAPI.price} VNĐ")),
          Expanded(child: PriceButton(text: distanceToString(mapAPIController.mapAPI.distance))),
          Expanded(child: PriceButton(text: durationToString(mapAPIController.mapAPI.duration)))
        ]),

        const SizedBox(height: 10),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          BigButton(width: 150, color: Colors.deepOrange.shade800, bold: true, label: "Đồng ý.", onPressed: onAccepted),
          BigButton(width: 150, color: Colors.orange.shade500, bold: true, label: "Bỏ qua.", onPressed: onRejected),
        ])
      ])
        
    );
  }
}



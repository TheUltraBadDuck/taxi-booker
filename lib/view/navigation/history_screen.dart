import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/view/decoration.dart';
import '/view_model/history_controller.dart';
import '/view_model/account_controller.dart';



class HistoryScreen extends StatefulWidget {
  const HistoryScreen({ Key? key, required this.accountController }) : super(key: key);
  final AccountController accountController;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen> {

  bool loadOnce = false;


  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<HistoryController>(

      create: (_) => HistoryController(),
      builder: (BuildContext context, Widget? child) => StreamBuilder<int> (
          
        stream: preloadHistory(context.read<HistoryController>()),
      
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) => SingleChildScrollView(
          child: Container(
        
            padding: const EdgeInsets.all(15),
        
            child: Column(
              children: [
                ...(() {
                  int listLength = context.read<HistoryController>().destinations.length;
                  List<Widget> result = [];
                
                  for (int i = listLength - 1; i >= 0; i--) {
                    result.add(TripBox(
                      destination: context.watch<HistoryController>().destinations[i],
                      time: context.watch<HistoryController>().times[i],
                      accountController: widget.accountController
                    ));
                    result.add(const SizedBox(height: 15));
                  }
                
                  return result;
                } ()),
            ]),
          ),
        ),
      )
    );
  }

  Stream<int> preloadHistory(historyController) async* {
    if (!loadOnce) {
      loadOnce = true;
      await historyController.preload();
    }
  }
}



class TripBox extends StatelessWidget {
  const TripBox({
    Key? key,
    required this.destination,
    required this.time,
    required this.accountController,
  }) : super(key: key);

  final String destination;
  final String time;
  final AccountController accountController;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Container(

        height: 90,
        color: Colors.amber.shade200,
        child: Stack(clipBehavior: Clip.antiAliasWithSaveLayer, children: [

          Positioned(bottom: -20, left: -30, child: circle(Colors.amber.shade100, 45)),
          Positioned(top: -20, bottom: -20, right: -35, child: circle(Colors.yellow.shade100, 70)),
          Positioned(top: -15, bottom: -15, right: -30, child: circle(Colors.white, 60)),
          Positioned(top: 5, bottom: 5, left: 15, right: 105, child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                destination,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              )
            ]),
          ),
          Positioned(top: 0, bottom: 0, right: 25, child: Icon(
            Icons.directions_car, size: 42, color: Colors.amber.shade900
          ))
  
        ]),
    
      ),
    );
  }
}

import "dart:developer" as developer;

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '/view_model/history_controller.dart';
import '/view_model/account_controller.dart';

import '/view/decoration.dart';
import '/view/book/book_screen.dart' show BookScreen;




class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key, required this.accountController }) : super(key: key);
  final AccountController accountController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}




class _HomeScreenState extends State<HomeScreen> {

  int vehicleID = 1;
  bool loadOnce = false;

  bool duringTrip = false;



  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<HistoryController>(
        create: (_) => HistoryController(),
        builder: (BuildContext context, Widget? child) => StreamBuilder<int> (
          
        stream: preloadDuringTrip(context.watch<HistoryController>()),
      
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) => SingleChildScrollView(
          
          child: SizedBox(
            height: duringTrip ? 720 : 930,
            child: Stack(
              
              alignment: Alignment.center,
              children: [
      
                // --------------------- Nền bên ngoài ---------------------
                Positioned( top: -120, left: 0, right: 0, child: SizedBox(
                  width: 360,
                  height: 360,
                  child: Center(child: circle(Colors.yellow.shade50, 180))
                )),
      
                Positioned( top: -60, left: 0, right: 0, child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Center(child: circle(Colors.white, 120))
                )),
      
                Positioned( top: 230, bottom: -30, left: 0, right: 0, child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber.shade500,
                    borderRadius: const BorderRadius.all(Radius.circular(30))
                  ),
                )),
      
                Positioned( top: 240, bottom: -30, left: 0, right: 0, child: DottedBorder(
                  borderType: BorderType.RRect,
                  color: Colors.white,
                  radius: const Radius.circular(30),
                  dashPattern: const [20, 20],
                  strokeWidth: 3,
                  child: Container()
                )),
              
                Positioned( top: 250, bottom: -30, left: 0, right: 0, child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(30))
                  ),
                )),
      
                const Positioned( top: 30, left: 0, right: 0, child: Center(
                  child: Text("Xin chào", style: TextStyle( fontSize: 20))
                )),
      
                Positioned( top: 60, left: 0, right: 0, child: Center(
                  child: Text(
                    widget.accountController.account.map["full_name"],
                    style: const TextStyle( fontSize: 32, fontWeight: FontWeight.bold),
                  )
                )),
    
                
      
                ...(duringTrip ? duringTripScreen() : notDuringTripScreen(context.watch<HistoryController>()))
                
              ],
            ),
          ),
        ),
      ),
    );
  }


  Stream<int> preloadDuringTrip(historyController) async* {
    if (!loadOnce) {
      developer.log("Preload during trip.");
      loadOnce = true;
      await loadDuringTrip();
      await historyController.preload();
    }
  }


  


  List<Widget> notDuringTripScreen(historyController) {
    return [
      // --------------------- Chọn xe ---------------------
      Positioned( top: 130, left: 0, right: 0, child: Column(children: [
        const Text("Chọn xe", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Container(height: 1, width: 280, color: Colors.black)
      ])),
    
      Positioned( top: 180, child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleCarButton(id: vehicleID, toLeft: true, idChange: () {
            setState(() => vehicleID-- );

          }),
          const SizedBox(width: 30),
          CarWidget(text: getVehicleName(vehicleID), type: vehicleID),
          const SizedBox(width: 30),
          CircleCarButton(id: vehicleID, toLeft: false, idChange: () => setState(() => vehicleID++ ))
        ],
      )),
  
    
      // --------------------- Các nút điểm đã đi gần đây + tạo địa điểm mới ---------------------
      Positioned( top: 315, left: 0, right: 0, child: Column(children: [
        const Text("Địa điểm gần đây", style: TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Container(height: 1, width: 280, color: Colors.black)
      ])),
    
    
      Positioned( top: 375, left: 30, right: 30, child: Column(
        children: [
          ...(() {
            int listLength = historyController.destinations.length;
            List<Widget> result = [];

            int count = 0;
            for (int i = listLength - 1; i >= 0; i--) {
              count++;
              if (count >= 5) {
                break;
              }
              else {
                result.add(DestinationButton(
                  vehicleID: vehicleID,
                  destination: historyController.destinations[i],
                  time: historyController.times[i],
                  accountController: widget.accountController,
                  duringTrip: duringTrip,
                  saveDuringTrip: (bool value) async => saveDuringTrip(value)
                ));
                result.add(const SizedBox(height: 15));
              }
            }

            return result;

          } ()),
          
          SearchDestinationButton(
            vehicleID: vehicleID,
            accountController: widget.accountController,
            duringTrip: duringTrip,
            saveDuringTrip: (bool value) async => saveDuringTrip(value)
          )
          
        ]
      ))
    ];
  }


  List<Widget> duringTripScreen() {
    return [
      Positioned( top: 320, left: 60, right: 60, child: BigButton(
        label: "Chuyến xe của bạn đang bắt đầu",
        bold: true,
        onPressed: () => Navigator.push(
          context, MaterialPageRoute(
            builder: (context) => BookScreen(
              vehicleID: vehicleID,
              accountController: widget.accountController,
              duringTrip: duringTrip,
              saveDuringTrip: (bool value) async => saveDuringTrip(value)
            )
          )
        )
      ))
    ];
  }


  Future<void> saveDuringTrip(bool value) async {
    developer.log("[Save during trip] Save $value");
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool("duringTrip", value);
    setState(() => duringTrip = value);
  }



  Future<void> loadDuringTrip() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final newDuringTrip = sp.getBool("duringTrip");
    setState(() => duringTrip = newDuringTrip ?? false);
    developer.log("[Load during trip] Load $newDuringTrip");
  }
}



class CircleCarButton extends StatefulWidget {
  const CircleCarButton({
    Key? key,
    required this.toLeft,
    required this.id,
    required this.idChange
  }) : super(key: key);
  final bool toLeft;
  final int id;
  final VoidCallback idChange;

  @override
  State<CircleCarButton> createState() => _CircleCarButtonState();
}

class _CircleCarButtonState extends State<CircleCarButton> {
  @override
  Widget build(BuildContext context) {

    if (widget.toLeft) {
      return Container(
        width: 45,
        height: 90,
        decoration: BoxDecoration(
          color: widget.id == 1 ? Colors.white : Colors.yellow.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(9)),
          border: Border.all(
            color: Colors.amber.shade300,
            width: 3
          )
        ),

        child: IconButton(
          onPressed: () => widget.id == 1 ? null : setState(widget.idChange),
          icon: Icon(
            Icons.chevron_left,
            color: widget.id == 1 ? Colors.transparent : Colors.black,
            size: 24
          )
        )
      );
    }
    else {
      return Container(
        width: 45,
        height: 90,
        decoration: BoxDecoration(
          color: widget.id == 2 ? Colors.white : Colors.yellow.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(9)),
          border: Border.all(
            color: Colors.amber.shade300,
            width: 3
          )
        ),

        child: IconButton(
          onPressed: () => widget.id == 2 ? null : setState(widget.idChange),
          icon: Icon(
            Icons.chevron_right,
            color: widget.id == 2 ? Colors.transparent : Colors.black,
            size: 24
          )
        )
      );
    }
  }
}



class DestinationButton extends StatelessWidget {
  const DestinationButton({
    Key? key,
    required this.vehicleID,
    required this.destination,
    required this.time,
    required this.accountController,
    required this.duringTrip,
    required this.saveDuringTrip
  }) : super(key: key);

  final int vehicleID;
  final String destination;
  final String time;
  final AccountController accountController;
  final bool duringTrip;
  final Function(bool) saveDuringTrip;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Container(

        height: 90,
        color: Colors.amber.shade400,
        child: InkWell(
    
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookScreen(
            vehicleID: vehicleID,
            destination: destination,
            accountController: accountController,
            duringTrip: duringTrip,
            saveDuringTrip: (bool value) async => saveDuringTrip(value)
          ))),
    
          child: Stack(clipBehavior: Clip.antiAliasWithSaveLayer, children: [
            Positioned(bottom: -20, left: -30, child: circle(Colors.amber.shade300, 45)),
            Positioned(top: -20, bottom: -20, right: -35, child: circle(Colors.yellow.shade300, 70)),
            Positioned(top: -15, bottom: -15, right: -30, child: circle(Colors.yellow.shade200, 60)),
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
    
      ),
    );
  }
}



class SearchDestinationButton extends StatelessWidget {
  const SearchDestinationButton({
    Key? key,
    required this.vehicleID,
    required this.accountController,
    required this.duringTrip,
    required this.saveDuringTrip
  }) : super(key: key);

  final int vehicleID;
  final AccountController accountController;
  final bool duringTrip;
  final Function(bool) saveDuringTrip;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Container(

        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(width: 2, color: Colors.amber.shade400)
        ),
        child: InkWell(
    
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookScreen(
            vehicleID: vehicleID,
            accountController: accountController,
            duringTrip: duringTrip,
            saveDuringTrip: (bool value) async => saveDuringTrip(value)
          ))),
    
          child: Stack(clipBehavior: Clip.antiAliasWithSaveLayer, children: [
            Positioned(bottom: -20, left: -30, child: circle(Colors.yellow.shade100, 45)),
            Positioned(top: -20, bottom: -20, right: -35, child: circle(Colors.amber.shade200, 70)),
            Positioned(top: -15, bottom: -15, right: -30, child: circle(Colors.amber.shade400, 60)),
            const Positioned(top: 5, bottom: 5, left: 15, right: 90, child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Muốn đến một nơi khác sao?",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Bấm vào đây để tìm vị trí",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.left,
                )
              ]),
            ),
            const Positioned(top: 0, bottom: 0, right: 25, child: Icon(
              Icons.search, size: 42, color: Colors.white,
            ))
    
          ]),
        ),
    
      ),
    );
  }
}



class DuringTripButton extends StatelessWidget {
  const DuringTripButton({
    Key? key,
    required this.vehicleID,
    required this.accountController,
    required this.onSetTrip,
    required this.duringTrip,
    required this.saveDuringTrip
  }) : super(key: key);
  final int vehicleID;
  final AccountController accountController;
  final Function(bool) onSetTrip;
  final bool duringTrip;
  final Function(bool) saveDuringTrip;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Container(

        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(width: 2, color: Colors.amber.shade400)
        ),
        child: InkWell(
    
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookScreen(
            vehicleID: vehicleID,
            accountController: accountController,
            duringTrip: duringTrip,
            saveDuringTrip: (bool value) async => saveDuringTrip(value)
          ))),
    
          child: Stack(clipBehavior: Clip.antiAliasWithSaveLayer, children: [
            Positioned(bottom: -20, left: -30, child: circle(Colors.yellow.shade100, 45)),
            Positioned(top: -20, bottom: -20, right: -35, child: circle(Colors.amber.shade200, 70)),
            Positioned(top: -15, bottom: -15, right: -30, child: circle(Colors.amber.shade400, 60)),
            const Positioned(top: 5, bottom: 5, left: 15, right: 90, child: Text(
              "Bấm vào đây xem hành trình.",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            )),
            const Positioned(top: 0, bottom: 0, right: 25, child: Icon(
              Icons.directions_car, size: 42, color: Colors.white,
            ))
    
          ]),
        ),
    
      ),
    );
  }
}



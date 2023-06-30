import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:flutter_app_texting/themes/text_themes.dart';
import 'package:flutter_app_texting/screens/others/book_screen.dart' show BookScreen;




class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key, required this.customerInfo }) : super(key: key);
  final Map<String, dynamic> customerInfo;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  List<String> vehicleTypes = ["Chọn sau", "Xe 4 chỗ", "Xe 7 chỗ", "Xe 9 chỗ"];
  List<String> destinations = [
    "Bệnh viện P, Quận S, Tỉnh Q",
    "Khách sạn L, Quận M, Tỉnh Q",
    "Nhà hàng A, Quận B, Tỉnh R",
    "Nhà hàng xóm X, Quận M, Tỉnh Q"
  ];
  List<String> times = [  // mm/dd/yyyy
    "06/20/2023", "06/11/2023", "06/04/2023", "06/01/2023"
  ];

  int vehicleID = 1;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      
      child: SizedBox(
        height: 930,
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

            Positioned( top: 220, bottom: -30, left: 0, right: 0, child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade500,
                borderRadius: const BorderRadius.all(Radius.circular(30))
              ),
            )),

            Positioned( top: 230, bottom: -30, left: 0, right: 0, child: DottedBorder(
              borderType: BorderType.RRect,
              color: Colors.white,
              radius: const Radius.circular(30),
              dashPattern: const [20, 20],
              strokeWidth: 3,
              child: Container()
            )),
          
            Positioned( top: 240, bottom: -30, left: 0, right: 0, child: Container(
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
                widget.customerInfo["username"],
                style: const TextStyle( fontSize: 32, fontWeight: FontWeight.bold)
              )
            )),
          
          
            // --------------------- Chọn xe ---------------------
            Positioned( top: 130, left: 0, right: 0, child: Column(children: [
              const Text("Chọn xe", style: TextStyle(fontSize: 24)),
              const SizedBox(height: 5),
              Container(height: 1, width: 280, color: Colors.black)
            ])),
          
            Positioned( top: 180, child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleCarButton(id: vehicleID, toLeft: true, idChange: () => setState(() => vehicleID-- )),
                const SizedBox(width: 30),
                CarWidget(text: vehicleTypes[vehicleID]),
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
                for (int i = 0; i < (destinations.length <= 5 ? (destinations.length * 2 ~/ 1) : 9); i++)
                  i % 2 == 0 ?
                    DestinationButton(
                      vehicleID: vehicleID,
                      destination: destinations[i ~/ 2],
                      time: times[i ~/ 2]
                    ) : const SizedBox(height: 15),
                
                SearchDestinationButton(vehicleID: vehicleID)
              ]
          
            ))
          
          ],
        ),
      ),
    );
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
          color: widget.id == 3 ? Colors.white : Colors.yellow.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(9)),
          border: Border.all(
            color: Colors.amber.shade300,
            width: 3
          )
        ),

        child: IconButton(
          onPressed: () => widget.id == 3 ? null : setState(widget.idChange),
          icon: Icon(
            Icons.chevron_right,
            color: widget.id == 3 ? Colors.transparent : Colors.black,
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
  }) : super(key: key);
  final int vehicleID;
  final String destination;
  final String time;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Container(

        height: 90,
        color: Colors.amber.shade400,
        child: InkWell(
    
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookScreen(
              vehicleID: vehicleID,
              destination: destination
            ))
          ),
    
          child: Stack(clipBehavior: Clip.antiAliasWithSaveLayer, children: [
            Positioned(bottom: -20, left: -30, child: circle(Colors.amber.shade300, 45)),
            Positioned(top: -20, bottom: -20, right: -35, child: circle(Colors.yellow.shade300, 70)),
            Positioned(top: -15, bottom: -15, right: -30, child: circle(Colors.yellow.shade200, 60)),
            Positioned(top: 5, bottom: 5, left: 15, right: 120, child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.left,
                ),
                Text(
                  formalDate(time),
                  style: const TextStyle(fontSize: 14),
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
  const SearchDestinationButton({ Key? key, required this.vehicleID }) : super(key: key);
  final int vehicleID;

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
    
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookScreen(vehicleID: vehicleID))
          ),
    
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




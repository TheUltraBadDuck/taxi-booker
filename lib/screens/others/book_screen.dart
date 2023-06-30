import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:flutter_app_texting/themes/text_themes.dart';


typedef StringCallback = Function(String value);


String getVehicleName(int vehicleID) {
  switch (vehicleID) {
    case 1: return "Xe 4 chỗ";
    case 2: return "Xe 7 chỗ";
    case 3: return "Xe 9 chỗ";
    default: return "Bị lỗi gì rồi!!!";
  }
}

enum BookState { beforeDestination, afterDestination, waitForTaxi }



class BookScreen extends StatefulWidget {
  const BookScreen({ Key? key, required this.vehicleID, this.destination = "" }) : super(key: key);
  final int vehicleID;
  final String destination;

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {

  Map<String, dynamic> booking = {
    "pickup_address": "Vị trí A, quận B, thành phố C",
    "pickup_time": "10:30",
    "dropoff_time": "11:00"
  };
  Map<String, dynamic> driverInfo = {
    "username": "Thằng Nào Đó",
    "phonenumber": "6942069420",
    "vehicle_type": 1,
    "rate": 4.8
  };

  int currVehicleID = 0;
  String currDestination = "";
  BookState bookState = BookState.beforeDestination;

  TextEditingController dropoffController = TextEditingController();



  int getPrice(int vehicleID) {
    switch (vehicleID) {
      case 1: return 69420;
      case 2: return 696969;
      case 3: return 420420420;
      default: return -1;
    }
  }

  String getTimeDistance(int vehicleID, String pickupTime, String dropoffTime) {
    return "30 phút";
  }



  List<Widget> beforeDestination() {
    return [
      Positioned(top: 15, left: 15, right: 15, child: SearchBar(
        controller: dropoffController,
        onSubmitted: (String value) {
          setState(() => currDestination = value);
          setState(() => bookState = BookState.afterDestination);
        }
      )),
    ];
  }

  List<Widget> afterDestination() {
    return [
      // --------------------  Thanh vị trí -------------------- 
      Positioned(top: 15, left: 15, right: 15, child: PositionBox(
        icon: Icon(Icons.add_circle, color: Colors.deepOrange.shade900),
        position: booking["pickup_address"]
      )),
      Positioned(top: 75, left: 15, right: 15, child: PositionBox(
        icon: Icon(Icons.place, color: Colors.deepOrange.shade900),
        position: currDestination
      )),
      Positioned(top: 80, right: 30, child: IconButton(
        icon: const Icon(Icons.close, size: 28),
        onPressed: () => setState(() => bookState = BookState.beforeDestination)
      )),
      Positioned(top: 56, left: 44, child: Container(
        width: 2,
        height: 32,
        color: Colors.deepOrange.shade900
      )),


      // --------------------  Thông tin để đặt xe -------------------- 
      Positioned(bottom: -30, left: 0, right: 0, child: Container(
        height: 290,
        decoration: BoxDecoration(
          color: Colors.amber.shade500,
          borderRadius: const BorderRadius.all(Radius.circular(15))
        ),
      )),

      Positioned(bottom: -30, left: 0, right: 0, child: DottedBorder(
        borderType: BorderType.RRect,
        color: Colors.white,
        radius: const Radius.circular(15),
        dashPattern: const [20, 20],
        strokeWidth: 3,
        child: Container(height: 275)
      )),
      
      Positioned(bottom: -30, left: 0, right: 0, child: Container(

        padding: const EdgeInsets.all(15),

        height: 270,

        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),

        child: Column(children: [

          Row(children: [

            BigLeftRightButton(toLeft: true, id: currVehicleID, idChange: () => setState( () => currVehicleID-- )),

            const SizedBox(width: 15),

            Expanded(child: Column(children: [

              InfoText(
                title: "Loại xe: ",
                detail: getVehicleName(currVehicleID)
              ),

              const HorizontalLine(),

              InfoText(
                title: "Giá thành: ",
                detail: "\$${getPrice(currVehicleID)}"
              ),

              const HorizontalLine(),

              InfoText(
                title: "Thời gian: ",
                detail: getTimeDistance(currVehicleID, booking["pickup_time"], booking["dropoff_time"])
              ),

              Text(
                booking["pickup_time"] + " - " + booking["dropoff_time"],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              )

            ])),

            const SizedBox(width: 15),

            BigLeftRightButton(toLeft: false, id: currVehicleID, idChange: () => setState( () => currVehicleID++ )),

          ]),

          const SizedBox(height: 15),

          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 1, color: Colors.amber.shade300)
            ),
            child: BigButton(
              label: "Đặt taxi ngay!",
              onPressed: () => setState(() => bookState = BookState.waitForTaxi),
              bold: true,
              color: Colors.amber.shade700
            )
          ),

        ])
      ))
    ];
  }


  List<Widget> waitForTaxi() {
    return [
      
      // --------------------  Thanh vị trí -------------------- 
      Positioned(top: 15, left: 15, right: 15, child: PositionBox(
        icon: Icon(Icons.add_circle, color: Colors.deepOrange.shade900),
        position: booking["pickup_address"]
      )),
      Positioned(top: 75, left: 15, right: 15, child: PositionBox(
        icon: Icon(Icons.place, color: Colors.deepOrange.shade900),
        position: currDestination
      )),
      Positioned(top: 80, right: 30, child: IconButton(
        icon: const Icon(Icons.close, size: 28),
        onPressed: () => setState(() => bookState = BookState.beforeDestination)
      )),
      Positioned(top: 56, left: 44, child: Container(
        width: 2,
        height: 32,
        color: Colors.deepOrange.shade900
      )),


      // --------------------  Thông tin để chờ xe -------------------- 
      Positioned(bottom: -30, left: 0, right: 0, child: Container(
        height: 290,
        decoration: BoxDecoration(
          color: Colors.amber.shade500,
          borderRadius: const BorderRadius.all(Radius.circular(15))
        ),
      )),

      Positioned(bottom: -30, left: 0, right: 0, child: DottedBorder(
        borderType: BorderType.RRect,
        color: Colors.white,
        radius: const Radius.circular(15),
        dashPattern: const [20, 20],
        strokeWidth: 3,
        child: Container(height: 275)
      )),

      Positioned(bottom: -30, left: 0, right: 0, child: Container(

        padding: const EdgeInsets.all(15),
        height: 270,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),

        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          InfoBox(height: 45,  child: Center(
            child: InfoText(title: "Giá thành: ", detail: "\$${getPrice(driverInfo["vehicle_type"])}")
          )),

          const SizedBox(height: 10),

          InfoBox(height: 45, child: Center(
            child: InfoText(title: "Thời gian: ", detail: booking["pickup_time"] + " - " + booking["dropoff_time"])
          )),

          const SizedBox(height: 10),

          InfoBox(height: 100, child: Center(
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox.fromSize(
                size: const Size.fromRadius(32),
                child: Image.asset("assets/images/avatar.jpg")
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(children: [
                  const SizedBox(height: 20),
                  InfoText(title: "Tên: ", detail: driverInfo["username"]),
                  const HorizontalLine(),
                  InfoText(title: "Số điện thoại: ", detail: driverInfo["phonenumber"]),
                ]),
              )
            ])
          )),

        ])

      ))
      
    ];
  }


  List<Widget> showPage() {
    switch(bookState) {
      case BookState.beforeDestination: return beforeDestination();
      case BookState.afterDestination:  return afterDestination();
      case BookState.waitForTaxi:       return waitForTaxi();
      default: return [const Text("ERROR at BookState")];
    }
  }




  @override
  Widget build(BuildContext context) {

    // Vừa cập nhật xe ở widget HomeScreen, vừa thay đổi được xe ở widget BookScreen này
    if (currVehicleID == 0)    {
      currVehicleID   = widget.vehicleID;
    }
    // Mới vào: không có giá trị gì.
    if (currDestination == "") {     
      // Nếu nhấn các nút có "địa chỉ" ở "Địa điểm gần đây" của HomeScreen, thực hiện cái này   
      if (widget.destination != "") {
        currDestination = widget.destination;
        bookState = BookState.afterDestination;
      }
      // Nếu nhấn "Không thấy nơi cần đến", thực hiện cái này
      else {
        bookState = BookState.beforeDestination;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: bookAppBar("Đặt vị trí"),
      body: Stack(children: showPage())
    );
  }

}




class SearchBar extends StatefulWidget {
  const SearchBar({
    Key? key,
    required this.controller,
    required this.onSubmitted
  }) : super(key: key);
  final TextEditingController controller;
  final StringCallback onSubmitted;

  @override
  State<SearchBar> createState() => _SearchBarState();
}


class _SearchBarState extends State<SearchBar> {

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.only(left: 5, right: 5),
      height: 55,
      
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        border: Border.all(
          color: Colors.amber.shade300,
          width: 3
        )
      ),

      child: TextField(
        controller: widget.controller,
        onSubmitted: (String value) async => widget.onSubmitted(value),
        
        decoration: InputDecoration(

          hintText: "Bạn muốn đi đâu？",

          border: InputBorder.none,

          prefixIcon: IconButton(
            icon: const Icon(Icons.search, size: 20),
            color: Colors.blueGrey.shade600,
            onPressed: () => setState(() => widget.onSubmitted(widget.controller.text) ),
          ),

          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 20),
            color: Colors.blueGrey.shade600,
            onPressed: () => setState(() => widget.controller.clear() )
          )

        ),
      ),
    );
  }
}



class PositionBox extends StatelessWidget {
  const PositionBox({ Key? key, required this.icon, required this.position }) : super(key: key);
  final Icon icon;
  final String position;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        border: Border.all(
          color: Colors.amber.shade300,
          width: 3
        )
      ),
      child: Row(children: [
        icon,
        const SizedBox(width: 15),
        Text(position, style: const TextStyle(fontSize: 16))
      ])
    );
  }
}



class BigLeftRightButton extends StatefulWidget {
  const BigLeftRightButton({
    Key? key,
    required this.toLeft,
    required this.id,
    required this.idChange
  }) : super(key: key);
  final bool toLeft;
  final int id;
  final VoidCallback idChange;

  @override
  State<BigLeftRightButton> createState() => _BigLeftRightButtonState();
}

class _BigLeftRightButtonState extends State<BigLeftRightButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.toLeft) {
      return InkWell(
        onTap: () => widget.id == 1 ? null : setState(widget.idChange),
        child: Container(
          width: 60,
          height: 135,
          decoration: BoxDecoration(
            color: widget.id == 1 ? Colors.white : Colors.yellow.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(9)),
            border: Border.all(
              color: Colors.amber.shade300,
              width: 3
            )
          ),
          child: Center(child: Icon(
            Icons.chevron_left,
            size: 32,
            color: widget.id == 1 ? Colors.transparent : Colors.black
          )),
        ),
      );
    }
    else {
      return InkWell(
        onTap: () => widget.id == 3 ? null : setState(widget.idChange),
        child: Container(
          width: 60,
          height: 135,
          decoration: BoxDecoration(
            color: widget.id == 3 ? Colors.white : Colors.yellow.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(9)),
            border: Border.all(
              color: Colors.amber.shade300,
              width: 3
            )
          ),
          child: Center(child: Icon(
            Icons.chevron_right,
            size: 32,
            color: widget.id == 3 ? Colors.transparent : Colors.black
          )),
        ),
      );
    }
  }
}



class InfoText extends StatelessWidget {
  const InfoText({ Key? key, required this.title, required this.detail }) : super(key: key);
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 5),
      Text(detail, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
    ]);
  }
}



class InfoBox extends StatelessWidget {
  const InfoBox({
    Key? key,
    required this.height,
    required this.child
  }) : super(key: key);
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(width: 1, color: Colors.amber.shade300),
        color: Colors.yellow.shade50
      ),
      child: child
    );
  }
}



class HorizontalLine extends StatelessWidget {
  const HorizontalLine({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5, right: 15),
      height: 1,
      color: Colors.amber.shade300
    );
  }
}



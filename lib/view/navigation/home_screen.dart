import 'dart:async';
import "dart:developer" as developer;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/notification.dart';
import '/general/function.dart';
import '/view_model/user_controller.dart';
import '/view_model/map_controller.dart';
import 'customer/customer_accepted_box.dart';
import 'customer/customer_info_box.dart';



typedef BoolCallBack = Function(bool value);

enum DriverState { idleState, receiveState, tripState }



class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key, required this.userController, required this.setNavigatable }) : super(key: key);
  final UserController userController;
  final BoolCallBack setNavigatable;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {

  // Thông tin người dùng (vị trí hiện tại, vị trí cần đến, khoảng cách, thời gian)
  int vehicleID = 0;


  // Thông tin liên quan để hiển thị trên bản đồ
  bool allowedNavigation = false;
  Location location = Location();

  MapController mapController = MapController();

  bool driverPickingUp = false;

  final Noti noti = Noti();

  Timer? receiveCustomerTimer;
  Timer? sendDriverLatLngTimer;

  bool loadReceiveCustomerTimerOnce = false;
  bool loadSendDriverLatLngTimerOnce = false;

  int numTemp = 0;
  bool loadOnce = false;




  bool active = true;
  bool tracking = true;

  DriverState driverState = DriverState.idleState;



  @override
  void initState() {
    super.initState();
    noti.initialize();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.orange.shade100,

      body: ChangeNotifierProvider(

        create: (_) {
          MapAPIController mapAPIController = MapAPIController();

          // Lắng nghe định vị GPS
          location.onLocationChanged.listen((LocationData currLocation) {
            final newLocation = LatLng(currLocation.latitude!, currLocation.longitude!);

            double distance = getDescrateDistanceSquare(mapAPIController.mapAPI.driverLatLng, newLocation);
            if (distance > 10e-7) {

              if (mounted) {
                mapAPIController.updateDriverLatLng(newLocation);
                setState(() => allowedNavigation = true);
              }

              // Cập nhật nếu đến đích
              if (driverPickingUp && (getDescrateDistanceSquare(mapAPIController.mapAPI.driverLatLng, mapAPIController.mapAPI.dropoffLatLng) < 20e-6)) {
                finishTrip(mapAPIController);
              }
            }
            if ((distance > 20e-6) && (tracking)) {
              setState(() => mapController.move(mapAPIController.mapAPI.driverLatLng, 16.5));
            }

            // Lắng nghe khách hàng
            if ((driverState == DriverState.tripState) && !driverPickingUp) {
              if (getDescrateDistanceSquare(mapAPIController.mapAPI.pickupLatLng, mapAPIController.mapAPI.driverLatLng) < 10e-7) {
                setState(() => driverPickingUp = true);
              }
            }
          });

          return mapAPIController;
        },

        builder: (BuildContext context, Widget? child) => Stack(children: [
      
          // -------------------- Bản đồ --------------------
          Positioned(top: 0, bottom: 0, left: 0, right: 0, child: StreamBuilder(
      
            stream: _waitForServerObserver(context.read<MapAPIController>()),
          
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) => FlutterMap(
            mapController: mapController,
            options: MapOptions(center: context.watch<MapAPIController>().mapAPI.pickupLatLng, zoom: 16.5),
          
            nonRotatedChildren: [
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
            ],
          
      
            children: [
          
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
          
              PolylineLayer(
                polylines: [
                  context.watch<MapAPIController>().mapAPI.s2ePolylines,
                  if (!driverPickingUp) context.watch<MapAPIController>().mapAPI.d2sPolylines
                ],
              ),
          
              MarkerLayer(
                markers: [
                  if (allowedNavigation)
                    Marker( point: context.watch<MapAPIController>().mapAPI.driverLatLng, width: 20, height: 20, builder: (context) => const DriverPoint() ),
                  if ((driverState != DriverState.idleState) && !driverPickingUp)
                    Marker( point: context.watch<MapAPIController>().mapAPI.pickupLatLng, width: 20, height: 20, builder: (context) => const CustomerPoint() ),
                  if (driverState != DriverState.idleState)
                    Marker( point: context.watch<MapAPIController>().mapAPI.dropoffLatLng, width: 20, height: 20, builder: (context) => const DestiPoint() )
                ],
              )
          
            ],
          ),
          )),
      
      
      
      
          // -------------------- Tên người sử dụng --------------------
          Positioned(top: 15, left: 15, right: 15, child: Container(
            width: MediaQuery.of(context).size.width,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(9)),
              boxShadow: [BoxShadow(
                color: Colors.orange.shade300.withOpacity(0.5),
                spreadRadius: 0,
                blurRadius: 3,
                offset: const Offset(3, 3),
              )]
            ),

            child: Center(child: child)
          )),
      
          Positioned(top: 22, left: 30, child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Xin chào, ", style: TextStyle(fontSize: 20)),
              Text(widget.userController.account.map["name"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
            ]
          )),
      
          Positioned(top: 22, right: 120, child: Column(children: [
            const Text("Hoạt động", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Switch(
              value: active,
              activeColor: Colors.amber.shade500,
              onChanged: (bool value) { setState(() => active = value); widget.setNavigatable(!value); },
            )
          ])),
      
          Positioned(top: 22, right: 30, child: Column(children: [
            const Text("Theo dõi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Switch(
              value: tracking,
              activeColor: Colors.amber.shade500,
              onChanged: (bool value) => setState(() => tracking = value),
            )
          ])),
      
      
      
          // -------------------- Thông tin khác --------------------
      
            // if (driverState == DriverState.idleState)
            //   ...[
            //     Positioned(bottom: 15, left: 15, child: DriverInfoBox(
            //       width: 200,
            //       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            //         Text("$moneyEarned VNĐ", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            //         const Text("Tiền thu được", style: TextStyle(fontSize: 18))
            //       ])
            //     )),
      
            //     Positioned(bottom: 15, right: 15, child: DriverInfoBox(
            //       width: 135,
            //       child: Row( children: [
            //         Text("  $totalWork", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
            //         const Text(" cước", style: TextStyle(fontSize: 24), textAlign: TextAlign.left)
            //       ])
            //     )),
            //   ]
      
            // else if (driverState == DriverState.receiveState)
            if (driverState == DriverState.receiveState)
              Positioned(bottom: 15, left: 15, right: 15, child: CustomerInfos(
                mapAPIController: context.read<MapAPIController>(),
                onAccepted: () => setState(() => driverState = DriverState.tripState),
                onRejected: () {
                  context.read<MapAPIController>().clearAll();
                  setState(() {
                    loadReceiveCustomerTimerOnce = false;
                    driverState = DriverState.idleState;
                  });
                }
              ))
      
            else if (driverState == DriverState.tripState)
              Positioned(bottom: 15, left: 15, right: 15, child: CustomerInfosAccepted(
                mapAPIController: context.read<MapAPIController>(),
                onCancelled: () async => finishTrip(context.read<MapAPIController>())
              ))
        ]),
      )
    );
  }



  Future finishTrip(mapAPIController) async {
    setState(() {
      driverPickingUp = false;
      driverState = DriverState.idleState;
      loadReceiveCustomerTimerOnce = false;
    });
    await mapAPIController.clearAll();
    noti.showBox("Chuyến đi thành công!", "Cảm ơn bạn đã chở khách hàng đến nơi.");
  }



  Stream<int>_waitForServerObserver(mapAPIController) async* {

    if (!loadOnce) {
      loadOnce = true;
      developer.log("Pre-loading the map data");

      final currLocation = await location.getLocation();
      final newLocation = LatLng(currLocation.latitude!, currLocation.longitude!);
      if (mounted) {
        setState(() {
          mapAPIController.mapAPI.pickupLatLng = newLocation;
          allowedNavigation = true;
        });
      }
    }


    if (!loadReceiveCustomerTimerOnce) {
      loadReceiveCustomerTimerOnce = true;
      receiveCustomerTimer = Timer.periodic(const Duration(seconds: 5), (timerRunning) async {
        try {
          if (mounted) {
            if (await mapAPIController.updateCustomer()) {
              mapAPIController.updateS2EPolyline();
              mapAPIController.updateD2SPolyline();
              setState(() => driverState = DriverState.receiveState);
              receiveCustomerTimer?.cancel();
            }
          }
        }
        catch (e) { throw Exception("Failed code when reading driver, at book_screen.dart. Error type: ${e.toString()}"); }
      });
    }


    if (!loadSendDriverLatLngTimerOnce && allowedNavigation) {
      loadSendDriverLatLngTimerOnce = true;
      sendDriverLatLngTimer = Timer.periodic(const Duration(seconds: 5), (timerRunning) async {
        try {
          if (mounted) {
            mapAPIController.postDriverLatLng();
          }
        }
        catch (e) { throw Exception("Failed code when reading driver, at book_screen.dart. Error type: ${e.toString()}"); }
      });
    }
    

    yield 0;
  }

}




class CustomerPoint extends StatelessWidget {
  const CustomerPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: Colors.amber.shade800,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: Colors.white, width: 3)
      )
    );
  }

}



class DestiPoint extends StatelessWidget {
  const DestiPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade900,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: Colors.white, width: 3)
      )
    );
  }
}



class DriverPoint extends StatelessWidget {
  const DriverPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade300,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: Colors.brown.shade700, width: 3)
      )
    );
  }
}



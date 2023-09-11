import 'dart:async';
import "dart:developer" as developer;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '/service/firebase_notification.dart';
import '/service/notification.dart';
import '/general/function.dart';
import '/view_model/account_controller.dart';
import '/view_model/map_api_controller.dart';
import '/view/decoration.dart';
import '/view/navigation/customer/customer_accepted_box.dart';
import '/view/navigation/customer/customer_info_box.dart';



enum DriverState { receiveState, tripState }



class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key, required this.accountController, required this.setLogoutAble }) : super(key: key);
  final AccountController accountController;
  final Function(bool) setLogoutAble;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {

  // Thông tin liên quan để hiển thị trên bản đồ
  bool allowedNavigation = false;
  Location location = Location();

  MapController mapController = MapController();

  bool driverPickingUp = false;

  final Noti noti = Noti();




  bool duringTrip = false;
  bool tracking = true;

  DriverState driverState = DriverState.receiveState;
  int customerLength = 0;
  int currCustomer = 0;



  @override
  void initState() {
    super.initState();
    noti.initialize();
  }


  @override
  void dispose() {
    super.dispose();
    postDriverTimer?.cancel();
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
            if ((distance > 20e-6) && tracking) {
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
                  if ((driverState == DriverState.tripState) && !driverPickingUp)
                    Marker( point: context.watch<MapAPIController>().mapAPI.pickupLatLng, width: 20, height: 20, builder: (context) => const CustomerPoint() ),
                  if (driverState == DriverState.tripState)
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
              Text(widget.accountController.account.map["full_name"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
            ]
          )),
      
          Positioned(top: 22, right: 30, child: Column(children: [
            const Text("Theo dõi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Switch(
              value: tracking,
              activeColor: Colors.amber.shade500,
              onChanged: (bool value) => setState(() => tracking = value),
            )
          ])),
      
      
      
          // -------------------- Thông tin khác --------------------

          if (driverState == DriverState.receiveState)
            Positioned(bottom: 15, left: 15, right: 15, child: CustomerInfos(
              mapAPIController: context.read<MapAPIController>(),
              currCustomer: currCustomer,
              onTapLeft: ()  { if (currCustomer > 0) setState(() => currCustomer--); },
              onTapRight: () { if (currCustomer < customerLength - 1) setState(() => currCustomer++); }, 
              onAccepted: () async {
                if (context.mounted) await context.read<MapAPIController>().updateCurrentCustomer(currCustomer);
                if (context.mounted) {
                  if (await context.read<MapAPIController>().sendBookingAccept()) {
                    if (context.mounted) await context.read<MapAPIController>().saveTrip();
                    await saveDuringTrip(true);
                    setState(() => driverState = DriverState.tripState);
                    // FireBaseAPI.sendMessage("f7W0AYWLQmS99_gAvJIfKt:APA91bGu3D8wufjhtUrfDd069hFcKKpppaCfH0fpQdg7DoFwMy4zgcb8womqHOI7jFapFzQQz5WjGZdHep948pg5iYDzjoskkEQCk4koUyRQq2t6ynbqyAgszj5Kz2g1DGqtIjnmjYRw");
                    widget.setLogoutAble(false);
                  }
                }
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
    setState(() { driverPickingUp = false;
                  driverState = DriverState.receiveState;
                  currCustomer = 0; });
    widget.setLogoutAble(true);
    noti.showBox("Chuyến đi thành công!", "Cảm ơn bạn đã chở khách hàng đến nơi.");
    await saveDuringTrip(false);
    await mapAPIController.completeTrip();
    await mapAPIController.clearTrip();
    await mapAPIController.loadCustomers();
    setState(() => customerLength = mapAPIController.customerList.length);
  }



  Timer? postDriverTimer;
  bool loadPostDriverOnce = false;
  bool loadOnce = false;
  Stream<int> _waitForServerObserver(mapAPIController) async* {

    if (!loadOnce && widget.accountController.account.map["_id"] != "") {
      loadOnce = true;
      final currLocation = await location.getLocation();
      mapAPIController.updateDriverLatLng(LatLng(currLocation.latitude!, currLocation.longitude!));

      await loadDuringTrip();
      if (duringTrip) {
        await mapAPIController.loadTrip();
        setState(() { driverState = DriverState.tripState;
                      widget.setLogoutAble(false); });
      }
      else {
        await mapAPIController.loadCustomers();
        setState(() => customerLength = mapAPIController.customerList.length);
      }
    }


    if (!loadPostDriverOnce && allowedNavigation) {
      loadPostDriverOnce = true;
      postDriverTimer = Timer.periodic(const Duration(seconds: 10), (timerRunning) async {
        await mapAPIController.patchDriverLatLng();
      });
    }
    
    
    yield 0;
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



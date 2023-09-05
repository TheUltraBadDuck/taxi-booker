import 'dart:async';
import "dart:developer" as developer;

import 'package:flutter/material.dart';
import 'package:flutter_app_texting/view/book/before_taxi.dart';

//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';

import '/view_model/user_controller.dart';
import '/view_model/map_controller.dart';
import '/view_model/general_controller.dart';

import '/view/book/after_dest.dart';
import '/view/book/after_taxi.dart';
import '/view/book/before_dest.dart';
import '/view/book/during_taxi.dart';
import '/view/book/schedule_taxi.dart';

import '/general/function.dart';
import '/notification.dart';



class BookScreen extends StatefulWidget {
  const BookScreen({
    Key? key,
    required this.vehicleID,
    this.destination = "",
    required this.userController,
    required this.duringTrip,
    required this.saveDuringTrip,
    required this.loadDuringTrip
  }) : super(key: key);

  final int vehicleID;
  final String destination;
  final UserController userController;
  final bool duringTrip;
  final Function(bool) saveDuringTrip;
  final VoidCallback loadDuringTrip;

  @override
  State<BookScreen> createState() => _BookScreenState();
}


class _BookScreenState extends State<BookScreen> {

  // Thông tin người dùng (vị trí hiện tại, vị trí cần đến, khoảng cách, thời gian)
  int vehicleID = 0;
  // Các trạng thái
  BookStateController bookStateController = BookStateController();

  // Thông tin liên quan để hiển thị trên bản đồ
  bool allowedNavigation = false;
  Location location = Location();
  MapController mapController = MapController();

  Timer? driverFoundTimer;
  Timer? driverPickedUpTimer;
  
  bool loadDriverFoundTimerOnce = false;
  bool loadDriverPickedUpTimerOnce = false;

  bool goodHour = true;
  bool goodWeather = true;

  // Thông tin tài xế
  bool foundDriver = false;
  bool driverPickingUp = false;
  bool loadTripOnce = false;

  final Noti noti = Noti();

  late var listenLocation;



  Stream<int> _readDriver(mapAPIController) async* {
    
    if (!loadTripOnce) {

      loadTripOnce = true;

      if (widget.duringTrip) {
        developer.log("Pre-loading trip");
        vehicleID = widget.vehicleID;

        final newBookState = await bookStateController.load();
        
        switch (newBookState) {

          case BookState.scheduleTaxiArrival:
            developer.log(" > Scheduled taxi arrival.");

            final newBookingTime = await mapAPIController.loadBookingTime();
            final timeDist = newBookingTime.compareTo(DateTime.now());


            if (timeDist > 0) {   // Chưa đến thời điểm cần đặt
              bookStateController.value = newBookState;
            }
            else {                // Đã đến hoặc đã qua thời điểm cần đặt
              await mapAPIController.loadCustomer();
              setState(() {
                bookStateController.value = BookState.beforeTaxiArrival;
                mapController.move(mapAPIController.mapAPI.pickupLatLng, 16);
              });
              allowedNavigation = true;
            }
            break;


          case BookState.beforeTaxiArrival:
            developer.log(" > Before taxi arrival.");
            await mapAPIController.loadCustomer();
            setState(() {
              bookStateController.value = newBookState;
              mapController.move(mapAPIController.mapAPI.pickupLatLng, 16);
            });
            allowedNavigation = true;
            break;

          
          case BookState.duringTaxiArrival:
            developer.log(" > During taxi arrival.");
            await mapAPIController.loadCustomer();
            await mapAPIController.loadDriver();
            setState(() {
              bookStateController.value = newBookState;
              mapController.move(mapAPIController.mapAPI.pickupLatLng, 16);
            });
            allowedNavigation = true;
            break;
          

          default:
            developer.log(" > Invalid taxi arrival.");
            await mapAPIController.clearAll();
            await widget.saveDuringTrip(false);
            setState(() {
              bookStateController.value = BookState.beforeSearch;
            });
            break;
        }
      }


      else {
        developer.log("Pre-loading dropoff data if it exists");

        if (vehicleID == 0) {
          vehicleID = widget.vehicleID;
        }

        // Cập nhật vị trí cần đến
        if (widget.destination.isNotEmpty) {
          try {
            final currLocation = await location.getLocation();
            final newLocation = LatLng(currLocation.latitude!, currLocation.longitude!);
            if (mounted) {
              await mapAPIController.updatePickupLatLng(newLocation);
              await mapAPIController.updatePickupAddr();
              if (await mapAPIController.updateDropoffbyText(widget.destination)) {
                await mapAPIController.updateS2EPolyline(vehicleID: vehicleID);
              }
              setState(() {
                mapController.move(mapAPIController.mapAPI.pickupLatLng, 16);
                bookStateController.value = BookState.afterSearch;
                allowedNavigation = true;
              });
            }
          }
          catch (e) {
            developer.log("ERRRORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR. Error type: $e");
          }
        }
      }
    }

    
    switch (bookStateController.value) {

      // Chờ tài xế chấp nhận cước đi
      case BookState.beforeTaxiArrival:
        if (!loadDriverFoundTimerOnce) {
          loadDriverFoundTimerOnce = true;
          driverFoundTimer = Timer.periodic(const Duration(seconds: 5), (timerRunning) async {
            try {
              if (mounted) {
                if (await mapAPIController.updateReadDriver()) {
                  setState(() => bookStateController.value = BookState.duringTaxiArrival);
                  await mapAPIController.updateD2SPolyline();
                  await mapAPIController.saveDriver();
                  await bookStateController.save();
                  driverFoundTimer?.cancel();
                }
              }
            }
            catch (e) { throw Exception("Failed code when reading driver, at book_screen.dart. Error type: ${e.toString()}"); }
          });
        }
        break;
      
        // Chờ tài xế đến đón
        case BookState.duringTaxiArrival:
          if (!loadDriverPickedUpTimerOnce) {
            loadDriverPickedUpTimerOnce = true;
            driverPickedUpTimer = Timer.periodic(const Duration(seconds: 5), (timerRunning) async {
              try {
                if (!driverPickingUp) {
                  if (mounted) {
                    await mapAPIController.updateDriverLatLng();
                  }
                }
                else {
                  driverPickedUpTimer?.cancel();
                }
              }
              catch (e) { throw Exception("Failed code when updating paths, at book_screen.dart. Error type: ${e.toString()}"); }
            });
          }
          break;
        
        // Chờ đến hẹn
        default:
          break;
    }



    

    yield 0;
  }


  // --------------------  Các hàm chính -------------------- 


  @override
  _BookScreenState() {
    location.enableBackgroundMode(enable: true);
  }



  @override
  void initState() {
    super.initState();
    noti.initialize();
  }



  @override
  void dispose() {
    super.dispose();
    listenLocation.cancel();
  }
  


  @override
  Widget build(BuildContext context) {

    // Widget
    return Scaffold(
        
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Text("Đặt vị trí", style: TextStyle(fontSize: 28)),
        backgroundColor: Colors.amber.shade300,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {
          Navigator.pop(context);
          // if (bookStateController.value == BookState.duringTaxiArrival) {
          //   warningModal(context, "Hãy đi đến địa điểm cần đến để có thể quay lại.");
          // }
          // else {
          //   Navigator.pop(context);
          // }
        })
      ),


      
      body: ChangeNotifierProvider(

        create: (_) {
          MapAPIController mapAPIController = MapAPIController();

          // Lắng nghe định vị GPS
          listenLocation = location.onLocationChanged.listen((LocationData currLocation) {
            final newLocation = LatLng(currLocation.latitude!, currLocation.longitude!);

            if (getDescrateDistanceSquare(mapAPIController.mapAPI.pickupLatLng, newLocation) > 10e-7) {

              if (mounted) {
                setState(() {
                  mapAPIController.mapAPI.pickupLatLng = newLocation;
                  allowedNavigation = true;
                });
              }

              // Cập nhật nếu đến đích
              if (getDescrateDistanceSquare(mapAPIController.mapAPI.pickupLatLng, mapAPIController.mapAPI.dropoffLatLng) < 10e-7) {
                bookStateController.value = BookState.afterTaxiArrival;
              }
            }


            // Lắng nghe tài xế
            if ((bookStateController.value == BookState.duringTaxiArrival) && !driverPickingUp) {
              if (getDescrateDistanceSquare(mapAPIController.mapAPI.pickupLatLng, mapAPIController.mapAPI.driverLatLng) < 10e-7) {
                setState(() => driverPickingUp = true);
                noti.showBox("Taxi đã đến", "Hãy bắt đầu hành trình đi đến nơi cần đến nào!");
              }
            }
          });

          return mapAPIController;
        },



        builder: (BuildContext context, Widget? child) => Stack(children: [
        
          Positioned(top: 0, bottom: 0, left: 0, right: 0, child: StreamBuilder<int>(
        
            stream: _readDriver(context.read<MapAPIController>()),
        
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) => FlutterMap(
        
              mapController: mapController,
        
              options: MapOptions(
                center: context.watch<MapAPIController>().mapAPI.pickupLatLng,
                zoom: 16.5
              ),
        
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
                    if (bookStateController.value == BookState.duringTaxiArrival && !driverPickingUp) context.watch<MapAPIController>().mapAPI.d2sPolylines
                  ],
                ),
        
                MarkerLayer(
                  markers: [
                    if (allowedNavigation)
                      Marker( point: context.watch<MapAPIController>().mapAPI.pickupLatLng, width: 20, height: 20, builder: (context) => const CustomerPoint() ),
                    if (bookStateController.value != BookState.beforeSearch)
                      Marker( point: context.watch<MapAPIController>().mapAPI.dropoffLatLng, width: 20, height: 20, builder: (context) => const DestiPoint() ),
                    if ((bookStateController.value == BookState.duringTaxiArrival) && !driverPickingUp)
                      Marker( point: context.watch<MapAPIController>().mapAPI.driverLatLng, width: 20, height: 20,  builder: (context) => const DriverPoint() )
                  ],
                )
        
              ],
            )
          )),
        
          Positioned(top: 0, bottom: 0, left: 0, right: 0, child: (() {
            
            switch(bookStateController.value) {

              case BookState.beforeSearch:
                return BeforeDestination(
                  userController: widget.userController,
                  vehicleID: vehicleID,
                  onSubmitted: (PickedData pickedData) async {
                    if (await widget.userController.checkTokens()) {
                      if (context.mounted) {
                        context.read<MapAPIController>().updatePickupAddr();
                        context.read<MapAPIController>().updateDropoffByPickedData(pickedData);
                        context.read<MapAPIController>().updateS2EPolyline(vehicleID: vehicleID);
                      }
                      setState(() {
                        mapController.move(context.read<MapAPIController>().mapAPI.pickupLatLng, 16);
                        bookStateController.value = BookState.afterSearch;
                      });
                    }
                  }
                );

              case BookState.afterSearch:
                return AfterDestination(
                  userController: widget.userController,
                  vehicleID: vehicleID,
                  pickupAddr: context.watch<MapAPIController>().mapAPI.pickupAddr,
                  dropoffAddr: context.watch<MapAPIController>().mapAPI.dropoffAddr,

                  price: context.watch<MapAPIController>().mapAPI.price,
                  distance: context.watch<MapAPIController>().mapAPI.distance,
                  duration: context.watch<MapAPIController>().mapAPI.duration,

                  onPressCancel: () => setState(() => bookStateController.value = BookState.beforeSearch),
                  onPressOK: (bool selectingDate) async {
                    if (await widget.userController.checkTokens()) {
                      if (selectingDate) {
                        if (context.mounted) noti.showBoxWithTimes("Đã đến giờ khởi hành!", "Hãy chuẩn bị mọi thứ trước khi đi.", context.read<MapAPIController>().mapAPI.bookingTime);
                        if (context.mounted) await context.read<MapAPIController>().saveCustomer();
                        setState(() => bookStateController.value = BookState.scheduleTaxiArrival);
                      }
                      else {
                        if (context.mounted) await context.read<MapAPIController>().postTrip(widget.userController.account.map["id"], "0123456789", widget.vehicleID);
                        if (context.mounted) await context.read<MapAPIController>().saveCustomer();
                        setState(() => bookStateController.value = BookState.beforeTaxiArrival);
                      }
                      await bookStateController.save();
                      widget.saveDuringTrip(true);
                    }
                  },

                  onChangeVehicleLeft: () => setState( () {
                    vehicleID--;
                    context.read<MapAPIController>().updatePrice(
                      getPrice(context.read<MapAPIController>().mapAPI.distance, vehicleID, goodHour: goodHour, goodWeather: goodWeather)
                    );
                  }),
                  onChangeVehicleRight: () => setState( () {
                    vehicleID++;
                    context.read<MapAPIController>().updatePrice(
                      getPrice(context.read<MapAPIController>().mapAPI.distance, vehicleID, goodHour: goodHour, goodWeather: goodWeather)
                    );
                  }),

                  onChangeTimeForVip: (int hour, int minute) {
                    context.read<MapAPIController>().updateDatetime(hour, minute);
                  }
                );

              case BookState.beforeTaxiArrival:
                return BeforeTaxiTrip(
                  userController: widget.userController,
                  vehicleID: vehicleID,
                  pickupAddr: context.watch<MapAPIController>().mapAPI.pickupAddr,
                  dropoffAddr: context.watch<MapAPIController>().mapAPI.dropoffAddr,
                  distance: context.watch<MapAPIController>().mapAPI.distance,
                  duration: context.watch<MapAPIController>().mapAPI.duration
                );

              case BookState.duringTaxiArrival:
                return DuringTaxiTrip(
                  userController: widget.userController,
                  vehicleID: vehicleID,
                  pickupAddr: context.watch<MapAPIController>().mapAPI.pickupAddr,
                  dropoffAddr: context.watch<MapAPIController>().mapAPI.dropoffAddr,
                  distance: context.watch<MapAPIController>().mapAPI.distance,
                  duration: context.watch<MapAPIController>().mapAPI.duration,
                  driverName: context.watch<MapAPIController>().mapAPI.driverName,
                  driverPhonenumber: context.watch<MapAPIController>().mapAPI.driverPhonenumber
                );

              case BookState.afterTaxiArrival:
                return AfterTaxiTrip(
                  userController: widget.userController,
                  onReturn: () async {
                    if (await widget.userController.checkTokens()) {
                      widget.saveDuringTrip(false);
                      if (context.mounted) await context.read<MapAPIController>().clearAll();
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                );

              case BookState.scheduleTaxiArrival:
                return ScheduleTaxiTrip(
                  userController: widget.userController,
                  onReturn: () async {
                    if (await widget.userController.checkTokens()) {
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                );

              default: return const Text("ERROR at BookState");
            }
          } ()))
        
        ]),
      )
    );
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



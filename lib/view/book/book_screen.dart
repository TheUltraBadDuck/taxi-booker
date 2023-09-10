import 'dart:async';
import "dart:developer" as developer;

import 'package:flutter/material.dart';
import 'package:flutter_app_texting/view/book/before_taxi.dart';

//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';

import '/view_model/account_controller.dart';
import '/view_model/map_api_controller.dart';

import 'after_search.dart';
import '/view/book/after_taxi.dart';
import 'before_search.dart';
import '/view/book/during_taxi.dart';
import '/view/book/schedule_taxi.dart';
import '/view/decoration.dart';

import '/general/function.dart';
import '/service/notification.dart';



enum BookState {
  beforeSearch,         // Chưa đặt địa chỉ cần đến: Yêu cầu sệt
  afterSearch,          // Hiện thông tin đường đi giữa điểm bắt đầu và điểm kết thúc, giá tiền, quãng đường và thời gian
  beforeTaxiArrival,    // Chờ tài xế phản hồi
  duringTaxiArrival,    // Chờ tài xế trước và sau khi chở mình đi đến nơi cần đến
  afterTaxiArrival,     // Kết thúc
  scheduleTaxiArrival,  // Dành cho khách hàng VIP: đặt cuộc hẹn
  error
}



class BookScreen extends StatefulWidget {
  const BookScreen({
    Key? key,
    required this.vehicleID,
    this.destination = "",
    required this.accountController,
    required this.duringTrip,
    required this.saveDuringTrip
  }) : super(key: key);

  final int vehicleID;
  final String destination;
  final AccountController accountController;
  final bool duringTrip;
  final Function(bool) saveDuringTrip;

  @override
  State<BookScreen> createState() => _BookScreenState();
}



class _BookScreenState extends State<BookScreen> {

  // Thông tin người dùng (vị trí hiện tại, vị trí cần đến, khoảng cách, thời gian)
  int vehicleID = 0;
  BookState bookState = BookState.beforeSearch;

  // Thông tin liên quan để hiển thị trên bản đồ
  bool allowedNavigation = false;
  Location location = Location();
  MapController mapController = MapController();



  bool goodHour = true;
  bool goodWeather = true;

  // Thông tin tài xế
  bool driverPickingUp = false;
  bool loadTripOnce = false;

  final Noti noti = Noti();

  late var listenLocation;



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
    patchCustomerTimer?.cancel();
    driverFoundTimer?.cancel();
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
                setState(() { mapAPIController.mapAPI.pickupLatLng = newLocation;
                              allowedNavigation = true; });
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
              options: MapOptions(center: context.watch<MapAPIController>().mapAPI.pickupLatLng, zoom: 16.5),
        
              nonRotatedChildren: [
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors',
                                          onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')))
                  ],
                ),
              ],
        
              children: [
        
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app'),
        
                PolylineLayer(
                  polylines: [
                    context.watch<MapAPIController>().mapAPI.s2ePolylines,
                    if (bookState == BookState.duringTaxiArrival && !driverPickingUp) context.watch<MapAPIController>().mapAPI.d2sPolylines
                  ],
                ),
        
                MarkerLayer(
                  markers: [
                    if (allowedNavigation)
                      Marker( point: context.watch<MapAPIController>().mapAPI.pickupLatLng, width: 20, height: 20, builder: (context) => const CustomerPoint() ),
                    if (bookState != BookState.beforeSearch)
                      Marker( point: context.watch<MapAPIController>().mapAPI.dropoffLatLng, width: 20, height: 20, builder: (context) => const DestiPoint() ),
                    if ((bookState == BookState.duringTaxiArrival) && !driverPickingUp)
                      Marker( point: context.watch<MapAPIController>().mapAPI.driverLatLng, width: 20, height: 20,  builder: (context) => const DriverPoint() )
                  ],
                )
        
              ],
            )
          )),
        
          Positioned(top: 0, bottom: 0, left: 0, right: 0, child: (() {
            
            switch (bookState) {

              case BookState.beforeSearch:
                return BeforeSearchBox(
                  accountController: widget.accountController,
                  vehicleID: vehicleID,
                  onSubmitted: (PickedData pickedData) async {
                    context.read<MapAPIController>().updateDropoffAddr(pickedData.address);
                    context.read<MapAPIController>().updateDropoffLatLng(LatLng(pickedData.latLong.latitude, pickedData.latLong.longitude));
                    context.read<MapAPIController>().updatePickupAddr(
                          await context.read<MapAPIController>().getAddr(context.read<MapAPIController>().mapAPI.pickupLatLng));
                    
                    if (context.mounted) await context.read<MapAPIController>().updateS2EPolyline(vehicleID: vehicleID);
                    await saveBookState(BookState.afterSearch);
                    setState(() => mapController.move(context.read<MapAPIController>().mapAPI.pickupLatLng, 16));
                  }
                );

              case BookState.afterSearch:
                return AfterSearchBox(
                  accountController: widget.accountController,
                  vehicleID: vehicleID,
                  mapAPIController: context.watch<MapAPIController>(),

                  onPressCancel: () async => await saveBookState(BookState.beforeSearch),
                  
                  onPressOK: (bool selectingDate) async {
                    if (selectingDate) {
                      noti.showBoxWithTimes("Đã đến giờ khởi hành!", "Hãy chuẩn bị mọi thứ trước khi đi.", context.read<MapAPIController>().mapAPI.bookingTime);
                      await saveBookState(BookState.scheduleTaxiArrival);
                    }
                    else {
                      if (context.mounted) await context.read<MapAPIController>().postBookingRequest(widget.accountController.account.map["phone"], widget.vehicleID);
                      await saveBookState(BookState.beforeTaxiArrival);
                    }
                    if (context.mounted) await context.read<MapAPIController>().saveCustomer();
                    await widget.saveDuringTrip(true);
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

                  onChangeTimeForVip: (int hour, int minute) => context.read<MapAPIController>().updateDatetime(hour, minute)
                );

              case BookState.beforeTaxiArrival:
                return BeforeTaxiTrip(
                  accountController: widget.accountController,
                  vehicleID: vehicleID,
                  mapAPIController: context.watch<MapAPIController>()
                );

              case BookState.duringTaxiArrival:
                return DuringTaxiTrip(
                  accountController: widget.accountController,
                  vehicleID: vehicleID,
                  mapAPIController: context.watch<MapAPIController>()
                );

              case BookState.afterTaxiArrival:
                return AfterTaxiTrip(
                  accountController: widget.accountController,
                  onRated:   (int star) async {
                    await widget.saveDuringTrip(false);
                    if (context.mounted) await context.read<MapAPIController>().rateDriver(star);
                    if (context.mounted) await context.read<MapAPIController>().clearAll();
                    if (context.mounted) Navigator.pop(context);
                  },
                  onIgnored: () async {
                    await widget.saveDuringTrip(false);
                    if (context.mounted) await context.read<MapAPIController>().clearAll();
                    if (context.mounted) Navigator.pop(context);
                  }
                );

              case BookState.scheduleTaxiArrival:
                return ScheduleTaxiTrip(
                  accountController: widget.accountController,
                  onReturn: () async {
                    if (context.mounted) Navigator.pop(context);
                  }
                );

              default: return const Text("ERROR at BookState");
            }
          } ()))
        
        ]),
      )
    );
  }



  Timer? patchCustomerTimer;
  Timer? driverFoundTimer;
  
  bool loadPatchCustomerOnce = false;
  bool loadDriverFoundTimerOnce = false;


  Stream<int> _readDriver(mapAPIController) async* {
    
    if (!loadTripOnce) {
      loadTripOnce = true;

      if (widget.duringTrip) {
        developer.log("Pre-loading trip");
        vehicleID = widget.vehicleID;

        await saveBookState(BookState.beforeTaxiArrival);

        bookState = BookState.beforeTaxiArrival;

        switch (bookState) {

          case BookState.scheduleTaxiArrival:
            developer.log(" > Scheduled taxi arrival.");

            final newBookingTime = await mapAPIController.loadBookingTime();
            final timeDist = newBookingTime.compareTo(DateTime.now());

            if (timeDist < 0) {                // Đã đến hoặc đã qua thời điểm cần đặt
              await mapAPIController.loadCustomer();
              await saveBookState(BookState.beforeTaxiArrival);
              setState(() {
                allowedNavigation = true;
                mapController.move(mapAPIController.mapAPI.pickupLatLng, 16);
              });
            }
            break;


          case BookState.beforeTaxiArrival:
            developer.log(" > Before taxi arrival.");
            await mapAPIController.loadCustomer();
            setState(() {
              allowedNavigation = true;
              mapController.move(mapAPIController.mapAPI.pickupLatLng, 16);
            });
            break;

          
          case BookState.duringTaxiArrival:
            developer.log(" > During taxi arrival.");
            await mapAPIController.loadCustomer();
            await mapAPIController.loadDriver();
            setState(() {
              allowedNavigation = true;
              mapController.move(mapAPIController.mapAPI.pickupLatLng, 16);
            });
            break;
          

          default:
            developer.log(" > Invalid taxi arrival.");
            await mapAPIController.clearAll();
            await widget.saveDuringTrip(false);
            await saveBookState(BookState.beforeSearch);
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
              mapAPIController.updatePickupLatLng(newLocation);
              await mapAPIController.patchPickupLatLng();
              await mapAPIController.updatePickupAddr(widget.destination);
              if (await mapAPIController.searchDropoff(widget.destination)) {
                await mapAPIController.updateS2EPolyline(vehicleID: vehicleID);
              }
              await saveBookState(BookState.afterSearch);
              setState(() { mapController.move(mapAPIController.mapAPI.pickupLatLng, 16);
                            allowedNavigation = true; });
            }
          }
          catch (e) {
            developer.log("ERRRORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR. Error type: $e");
          }
        }
      }
    }



    if (!loadPatchCustomerOnce) {
      loadPatchCustomerOnce = true;
      // Lắng nghe định vị GPS
      patchCustomerTimer = Timer.periodic(const Duration(seconds: 10), (timerRunning) async {
        await mapAPIController.patchPickupLatLng();
      });
    }


    // Chờ tài xế chấp nhận cước đi
    if (!loadDriverFoundTimerOnce && (bookState == BookState.beforeTaxiArrival)) {
      loadDriverFoundTimerOnce = true;
      driverFoundTimer = Timer.periodic(const Duration(seconds: 10), (timerRunning) async {
        if (mounted) {
          if (await mapAPIController.getDriverLocation()) {
            if (bookState == BookState.beforeTaxiArrival) {
              await saveBookState(BookState.duringTaxiArrival);
            }
            else if (bookState == BookState.duringTaxiArrival) {
              // Cập nhật nếu gặp được tài xế
              if (getDescrateDistanceSquare(mapAPIController.mapAPI.pickupLatLng, mapAPIController.mapAPI.driverLatLng) < 10e-7 && !driverPickingUp) {
                setState(() => driverPickingUp = true);
                noti.showBox("Taxi đã đến", "Hãy bắt đầu hành trình đi đến nơi cần đến nào!");
              }

              // Cập nhật nếu đến đích
              if (getDescrateDistanceSquare(mapAPIController.mapAPI.pickupLatLng, mapAPIController.mapAPI.dropoffLatLng) < 10e-7) {
                await saveBookState(BookState.afterTaxiArrival);
              }
            }
          }
        }
      });
    }

    yield 0;
  }




  Future<void> saveBookState(BookState value) async {
    developer.log("[Save bookstate] Save $value");
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt("bookState", bookState.index);
    setState(() => bookState = value);
  }

  Future<void> loadBookState() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() => bookState = BookState.values[sp.getInt("bookState")!]);
    developer.log("[Load bookstate] Load $bookState");
  }
}



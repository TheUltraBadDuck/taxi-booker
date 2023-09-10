// const String authRegister     = "http://thaivanthien.site/";
// const String authLogin        = "http://thaivanthien.site/api/auth/login";
// const String authRefreshToken = "http://thaivanthien.site/api/auth/refreshtoken";
// const String users            = "http://thaivanthien.site/api/users";


const String headPoint = "http://192.168.1.7";  // Giả lập xãi địa chỉ IP riêng thay vì localhost

class Auth {
  static const String port = "3001";
  static const String register = "$headPoint:$port/auth/users/createNewUser";
  static const String login = "$headPoint:$port/auth/login";
  static const String logout = "$headPoint:$port/auth/logout";
  static const String refresh = "$headPoint:$port/auth/refresh";
}

class Driver {
  static const String port = "3003";
  static const String setLatLong = "$headPoint:$port/setLatLong";
  static const String userInfo = "$headPoint:$port/userInfor";
  static const String nearbyBookingRequest = "$headPoint:$port/getNearbyBookingRequest";
  static const String sendBookingAccept = "$headPoint:$port/sendBookingAccept";
}

class Customer {
  static const String port = "3004";
  static const String sendBookingRequest = "$headPoint:$port/sendBookingRequest";
  static const String getHistory = "$headPoint:$port/getHistory";
  static const String setLatLong = "$headPoint:$port/setLatLong";
  static const String userInfo = "$headPoint:$port/userInfor";
  static const String setDriverRate = "$headPoint:$port/rateDriver";
  static const String getDriverRate = "$headPoint:$port/driverRate";
  static const String getDriverLocation = "$headPoint:$port/getDriverLocationByBR";
}



// String key = "AIzaSyBEIQrm2irTkeGi1nfw3ioFsmyiS57T3Ms";  // Google Maps Platform API
String key = "5b3ce3597851110001cf6248a17a15c7935141519dcdb98574a2fb78";  // Openroute Service API

String web = "https://api.openrouteservice.org";
String directionsService = "v2/directions/driving-car";
String searchGeocoding   = "geocode/search";

String locationWeb = "https://nominatim.openstreetmap.org";



String weatherKey = "858004abd45308fe346f5310ef414fb2";
String weatherWeb = "https://api.openweathermap.org";
String oneCall = "data/3.0/onecall";


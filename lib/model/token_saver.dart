import "dart:developer" as developer;

import 'package:shared_preferences/shared_preferences.dart';




// Singleton
class TokenSaver {

  Map<String, dynamic> map = { "accessToken": "", "refreshToken": "", "userId": -1, "email": "", "status": "failed" };

  static final TokenSaver _instance = TokenSaver._internal();
  TokenSaver._internal();

  factory TokenSaver() {
    return _instance;
  }

  Future save(Map<String, dynamic> newToken) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      await sp.setString("accessToken",  newToken["accessToken"]);
      await sp.setString("refreshToken", newToken["refreshToken"]);
      await sp.setInt(   "userId",       newToken["userId"]);
      await sp.setString("email",        newToken["email"]);
      await sp.setString("status",       newToken["status"]);
    }
    catch (e) { developer.log("Map error:\nException: $e\nMap:$newToken"); }
  }
  
  Future load() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      map["accessToken"]  = sp.getString("accessToken")!;
      map["refreshToken"] = sp.getString("refreshToken")!;
      map["userId"]       = sp.getInt("userId")!;
      map["email"]        = sp.getString("email")!;
      map["status"]       = sp.getString("status")!;
    }
    catch (e) { developer.log("Throw error at loadTokenValue(). Exception: $e"); }
  }

  Future clear() async {
    save(emptyMap());
  }

  static Map<String, dynamic> emptyMap() {
    return { "accessToken": "", "refreshToken": "", "userId": -1, "email": "", "status": "failed" };
  }
}



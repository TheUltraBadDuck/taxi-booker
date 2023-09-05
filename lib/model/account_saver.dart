import "dart:developer" as developer;

import 'package:shared_preferences/shared_preferences.dart';



// Vẫn là Singleton
class AccountSaver {

  Map<String, dynamic> map = { "id": -1, "name": "", "email": "", "password": "", "isVip": false };

  static final AccountSaver _instance = AccountSaver._internal();
  AccountSaver._internal();

  factory AccountSaver() {
    return _instance;
  }

  // Lệ thuộc vào class Token, nên không có constructor
 
  Future save(Map<String, dynamic> newAccount, { bool newVipStatus = false }) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt(   "id",          newAccount["id"]);
    await sp.setString("username",    newAccount["name"]);
    await sp.setString("phonenumber", newAccount["email"]);
    await sp.setString("password",    newAccount["password"]);
    await sp.setBool(  "isVip",       newVipStatus);
  }
  
  Future load() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      map["id"]       = sp.getInt("id")!;
      map["name"]     = sp.getString("username")!;
      map["email"]    = sp.getString("phonenumber")!;
      map["password"] = sp.getString("password")!;
      map["isVip"]    = sp.getBool("isVip")!;
    }
    catch (e) { developer.log("Throw error at loadInfoValue(). Exception: $e"); }
  }

    Future clear() async {
    save(emptyMap());
  }

  static Map<String, dynamic> emptyMap() {
    return { "id": -1, "name": "", "email": "", "password": "" };
  }
}
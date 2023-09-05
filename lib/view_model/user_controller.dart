import 'package:flutter/material.dart';
import '/model/account_saver.dart';
import '/model/token_saver.dart';

import '../data/user_reader.dart';



class UserController with ChangeNotifier {

  TokenSaver token = TokenSaver();
  AccountSaver account = AccountSaver();



  // * Tự động load khi mới bắt đầu chương trình
  Future preload() async {
    await token.load();           // Load from Shared Preferences
    if (await checkTokens()) {
      await account.load();       // Load from Shared Preferences
    }
    notifyListeners();
  }



  // * Đăng ký
  Future updateRegister() async {

  }



  // * Đăng nhập
  Future<bool> updateLogIn(String phonenumber, String password) async {
    final result = await UserDataReader().logIn(phonenumber, password);
    if (result["status"]) {
      token.map = result["token"];
      account.map = result["account"];
      await token.save(result["token"]);
      await account.save(result["account"]);
      return Future.value(true);
    }
    return Future.value(false);
  }


  // * Đăng xuất
  Future updateLogOut() async {
    token.map = TokenSaver.emptyMap();
    account.map = AccountSaver.emptyMap();
    await token.clear();
    await account.clear();
  }

  

  // * Kiểm tra token
  Future<bool> checkTokens() async {

    final result = await UserDataReader().checkTokens(token);

    if (result["status"]) {
      if (result["type"] == TokenType.validWithRefreshToken) {
        await token.save(result["body"]);
        token.map = result["body"];
      }
      return Future.value(true);
    }
    else {
      if (result["type"] == TokenType.invalidDueToOutOfDate) {
        token.map = TokenSaver.emptyMap();
        account.map = AccountSaver.emptyMap();
        await token.clear();
        await account.clear();
      }
      return Future.value(false);
    }

  }
}



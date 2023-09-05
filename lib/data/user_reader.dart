import 'dart:convert';
import "dart:developer" as developer;
import "package:http/http.dart" as http;


import '/model/token_saver.dart';

import '/general/constant.dart';



enum TokenType { noAccount, validWithAccessToken, validWithRefreshToken, invalidDueToOutOfDate, httpError }



class UserDataReader {


  
  // ! ! ! ! ! ! Chưa xong ! ! ! ! ! !
  // * Đăng ký tài khoản
  Future< Map<String, dynamic> > register(String username, String phonenumber, String password) async {
    // Đọc url để tìm tài khoản
    var response = await http.post(Uri.parse(authRegister),
                                      headers: { "Content-Type": "application/json; charset=UTF-8" },
                                      body: jsonEncode({ "username": username, "email": phonenumber, "password": password }));

    try {
      Map<String, dynamic> result = { "read": true };

      if (response.statusCode == 200) {
        // Do something
      }
      else {
        developer.log("Failed HTTP when logging in: ${response.statusCode}");
      }
      return result;

    }
    catch (e) { throw Exception("Failed code when trying to register an account, at saved_data.dart. Error type: ${e.toString()}"); }
  }



  // * Đăng nhập tài khoản
  // *
  // * RETURN: {
  // *   status: true,
  // *   token: <Map>,
  // *   account: <Map>
  // * }
  // *
  Future< Map<String, dynamic> > logIn(String phonenumber, String password) async {

    Map<String, dynamic> result = { "status": true };
    var response = await http.post(Uri.parse(authLogin),
                                    headers: { "Content-Type": "application/json; charset=UTF-8" },
                                    body: jsonEncode({ "email": phonenumber, "password": password }));

    try {
      
      if (response.statusCode == 200) {
        developer.log("Successfully find the account's tokens.");

        var jsonVal = json.decode(response.body);
        result["token"] = jsonVal;


        // Đọc url để điền thông tin cho account
        response = await http.get(Uri.parse("$users/${jsonVal["userId"]}"));

        if (response.statusCode == 200) {
          developer.log("Successfully find the account's data.");

          final newUserData = json.decode(utf8.decode(response.bodyBytes));
          result["account"] = newUserData;
        }

        else {
          developer.log("Failed HTTP when getting profile: ${response.statusCode}");
          result["status"] = false;
        }
      }
      else {
        developer.log("Failed HTTP when logging in: ${response.statusCode}");
      }
      return result;
    }
    catch (e) { throw Exception("Failed code when trying to log in, at saved_data.dart. Error type: ${e.toString()}"); }
  }




  // *
  // * Kiểm tra token ở mỗi lần khai báo, đăng nhập, v.v...
  // *

  Future< Map<String, dynamic> > checkTokens(TokenSaver token) async {

    Map<String, dynamic> result = { "status": true };

    // Nếu không có ID nào được lưu (chưa đăng nhập, đăng nhập bị lỗi,...)
    // Trả về giá trị rỗng
    if (token.map["userId"] == -1) {
      result["status"] = false;
      result["type"] = TokenType.noAccount;
      return result;
    }

    // Nếu có ID, đọc nó
    final response = await http.get(Uri.parse("$users/${ token.map["userId"] }"),
                                              headers: { "Authorization": "Bearer ${ token.map["accessToken"] }" });

    // 200: chạy bình thường (access token hợp lệ, được quăng vào trong code)
    if (response.statusCode == 200) {
      developer.log("The access token is still valid.");
      result["type"] = TokenType.validWithAccessToken;
    }

    // 401: không cho đăng nhập dù đúng tài khoản (access token hết hạn)
    else if (response.statusCode == 401) {
      developer.log("The access token is expired! Trying to update a new one with refresh token.");
      try {
        // Sử dụng refresh token để cấp lại cái mới
        final newResponse = await http.post(Uri.parse(authRefreshToken), body: { "refreshtoken": token.map["refreshToken"] });

        // 200: refresh token hợp lệ: cập nhật lại access token và refresh token
        if (newResponse.statusCode == 200) {
          final newToken = json.decode(newResponse.body);
          result["type"] = TokenType.validWithRefreshToken;
          result["body"] = newToken;
          return result;
        }

        // Lỗi khác: refresh token hết hạ. Khi này, sẽ bắt đăng nhập lại
        else {
          developer.log("Failed HTTP when logging in: ${response.statusCode}");
          result["status"] = false;
          result["type"] = TokenType.invalidDueToOutOfDate;
        }
      }
      catch (e) { throw Exception("Failed code when trying to read users, at saved_data.dart. Error type: ${e.toString()}"); }
    }

    // Lỗi khác:
    else {
      developer.log("Failed HTTP at automaticallyGetProfile() when logging in: ${response.statusCode}");
      result["status"] = false;
      result["type"] = TokenType.httpError;
    }

    return result;
  }
}
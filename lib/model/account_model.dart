class AccountModel {  // Singleton

  Map<String, dynamic> map = {
    "_id": "",
    "phone": "",
    "password": "",
    "full_name": "",
    "role": "",
    "longitude": -1,
    "latitude": -1,
    "is_Vip": false
  };

  static final AccountModel _instance = AccountModel._internal();
  AccountModel._internal();

  factory AccountModel() {
    return _instance;
  }

  void clear() {
    map = {
      "_id": "",
      "phone": "",
      "password": "",
      "full_name": "",
      "role": "",
      "longitude": -1,
      "latitude": -1,
      "is_Vip": false
    };
  }
}
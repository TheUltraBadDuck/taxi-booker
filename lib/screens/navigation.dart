import 'package:flutter/material.dart';

import 'package:flutter_app_texting/themes/text_themes.dart';

import 'package:flutter_app_texting/screens/navigation/home_screen.dart' show HomeScreen;
import 'package:flutter_app_texting/screens/navigation/history_screen.dart' show HistoryScreen;
import 'package:flutter_app_texting/screens/navigation/wallet_screen.dart' show WalletScreen;
import 'package:flutter_app_texting/screens/others/profile_screen.dart' show ProfileScreen;

import 'package:flutter_app_texting/screens/account/register_screen.dart' show RegisterScreen;
import 'package:flutter_app_texting/screens/account/login_screen.dart' show LoginScreen;



class NavigationChange extends StatefulWidget {
  const NavigationChange({ Key? key }) : super(key: key);

  @override
  State<NavigationChange> createState() => _NavigationChangeState();
}


class _NavigationChangeState extends State<NavigationChange> {

  int bottomId = 0;
  bool hasAccount = false;
  bool toLogIn = false;

  Map<String, dynamic> customerInfo = {
    "username": "",
    "password_hash": "",
    "phonenumber": ""
  };

  List<Widget> _children = [];

  _NavigationChangeState() {
    _children = [
      HomeScreen(customerInfo: customerInfo),
      const WalletScreen(),
      const HistoryScreen(),
      ProfileScreen(
        customerInfo: customerInfo,
        onLogOut: () => setState(() {
          hasAccount = false;
          bottomId = 0;
          toLogIn = false;
        })
      )
    ];
  }

  @override
  Widget build(BuildContext context) {

    if (hasAccount) {

      return Scaffold(

        backgroundColor: Colors.yellow.shade100,
        
        body: SafeArea(child: _children[bottomId]),

        bottomNavigationBar: BottomNavigationBar(

          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.deepOrange.shade800,
          unselectedItemColor: Colors.orange.shade600,
          
          selectedLabelStyle:   const TextStyle( fontWeight: FontWeight.bold ),
          unselectedLabelStyle: const TextStyle( ),
          selectedIconTheme:    const IconThemeData( size: 32 ),
          unselectedIconTheme:  const IconThemeData( size: 24 ),

          currentIndex: bottomId,
          onTap: (value) => setState(() => bottomId = value),
          
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home),    label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.wallet),  label: "Wallet"),
            BottomNavigationBarItem(icon: Icon(Icons.book),    label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.person),  label: "Profile"),
          ],
        ),
      );

    }
    else {
      return Scaffold(

        backgroundColor: Colors.amber.shade700,

        body: SafeArea( child: Stack(children: [

          // --------------------- Trang trí ---------------------
          Positioned(top: -60, right: -60, child: circle(Colors.amber.shade600, 90)),
          Positioned(top: 30, left: 90, right: 45, child:
            !toLogIn ? Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                "Chào bạn!",
                style: TextStyle(fontSize: 28, color: Colors.brown.shade900, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end
              ),
              Text(
                "Hãy đăng ký để bắt đầu.",
                style: TextStyle(fontSize: 24, color: Colors.brown.shade900, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end
              )
            ]) : Text(
              "Đăng nhập tài khoản",
              style: TextStyle(fontSize: 28, color: Colors.brown.shade900, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end
            ),
          ),

          Positioned(top: 120, left: -235, child: Container(
            width: 710, height: 760,
            decoration: BoxDecoration(
              color: Colors.yellow.shade600,
              borderRadius: const BorderRadius.all(Radius.circular(300))
            ),
          )),

          Positioned(top: 150, left: -240, child: Container(
            width: 700, height: 700,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(300))
            ),
          )),

          // --------------------- Trường nhập ---------------------
          toLogIn ? LoginScreen(
            onLogIn: () => setState(() {
              customerInfo["username"] = "Người sử dụng";
              customerInfo["password_hash"] = "conbobietbay";
              customerInfo["phonenumber"] = "0123456789";
              hasAccount = true;
            }),
            switchToRegister: () => setState(() => toLogIn = false)
          ) : RegisterScreen(
            onLogIn: (String username, String passwordHash, String phonenumber) => setState(() {
              customerInfo["username"] = username;
              customerInfo["password_hash"] = passwordHash;
              customerInfo["phonenumber"] = phonenumber;
              hasAccount = true;
            }),
            switchToLogin: () => setState(() => toLogIn = true)
          )

        ]))
      );
    }

  }
}



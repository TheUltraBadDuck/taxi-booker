import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '/view/navigation/home_screen.dart' show HomeScreen;
import '/view/navigation/history_screen.dart' show HistoryScreen;
import '/view/navigation/profile_screen.dart' show ProfileScreen;

import '/view/account/register_screen.dart' show RegisterScreen;
import '/view/account/login_screen.dart' show LoginScreen;

import '/view_model/user_controller.dart';



enum ScreenState {
  registerScreen,
  loginScreen,
  applicationScreens
} ScreenState screenState = ScreenState.registerScreen;




class NavigationChange extends StatefulWidget {
  const NavigationChange({ Key? key }) : super(key: key);

  @override
  State<NavigationChange> createState() => _NavigationChangeState();
}


class _NavigationChangeState extends State<NavigationChange> {

  int bottomId = 0;             // Navigation
  List<Widget> _children = [];  // Navigation



  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      
      create: (_) {
        UserController userController = UserController();
        _children = [
          HomeScreen(userController: userController),
          HistoryScreen(userController: userController),
          ProfileScreen(userController: userController, onLogOut: () async {
            setState(() {
              bottomId = 0;
              screenState = ScreenState.registerScreen;
            });
            await userController.updateLogOut();
          })
        ];
        return userController;
      },


      builder: (context, child) => StreamBuilder<int> (
        
        stream: preload(Provider.of<UserController>(context)),
    
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
    
          if (Provider.of<UserController>(context).token.map["userId"] != -1) {
            screenState = ScreenState.applicationScreens;
          }
          else {
            if (screenState == ScreenState.applicationScreens) {
              screenState = ScreenState.registerScreen;
            }
          }
    
    
    
          switch (screenState) {
    
            case ScreenState.registerScreen:
              return RegisterScreen(
                // token: token,
                onLogIn: (String username, String passwordHash, String phonenumber) => setState(() {
                  screenState = ScreenState.applicationScreens;
                }),
                switchToLogin: () => setState(() => screenState = ScreenState.loginScreen)
              );
    
              
            case ScreenState.loginScreen:
              
              return LoginScreen(
                userController: Provider.of<UserController>(context),
                onLogIn: () => setState(() => screenState = ScreenState.applicationScreens),
                switchToRegister: () => setState(() => screenState = ScreenState.registerScreen)
              );
            
            
            case ScreenState.applicationScreens:
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
                    BottomNavigationBarItem(icon: Icon(Icons.map),     label: "Bản đồ"),
                    BottomNavigationBarItem(icon: Icon(Icons.wallet),  label: "Lịch sử"),
                    BottomNavigationBarItem(icon: Icon(Icons.person),  label: "Tài khoản"),
                  ],
                ),
              );
    
    
            default:
              return Text("Lỗi ScreenState: $screenState");
          }
        }
      ),
    );
  }



  bool preloadOnce = false;
  Stream<int> preload(userController) async* {
    if (!preloadOnce) {
      await userController.preload();
      preloadOnce = true;
    }
  }
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '/view/navigation/home_screen.dart' show HomeScreen;
import '/view/navigation/history_screen.dart' show HistoryScreen;
import '/view/navigation/profile_screen.dart' show ProfileScreen;

import '/view/account/register_screen.dart' show RegisterScreen;
import '/view/account/login_screen.dart' show LoginScreen;

import '/view_model/account_controller.dart';
import '/view/decoration.dart';



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

  bool navigatable = false;



  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      
      create: (_) {
        AccountController accountController = AccountController();
        _children = [
          HomeScreen(accountController: accountController, setNavigatable: (bool value) {
            setState(() => navigatable = value);
          }),
          HistoryScreen(accountController: accountController),
          ProfileScreen(accountController: accountController, onLogOut: () async {
            setState(() {
              bottomId = 0;
              screenState = ScreenState.registerScreen;
            });
            await accountController.updateLogOut();
          })
        ];
        return accountController;
      },


      builder: (context, child) => StreamBuilder<int> (
        
        stream: preload(Provider.of<AccountController>(context)),
    
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
    
          if (Provider.of<AccountController>(context).account.map["_id"] != "") {
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
                accountController: Provider.of<AccountController>(context),
                onLogIn: () => setState(() => screenState = ScreenState.applicationScreens),
                switchToLogin: () => setState(() => screenState = ScreenState.loginScreen)
              );
    
              
            case ScreenState.loginScreen:
              return LoginScreen(
                accountController: Provider.of<AccountController>(context),
                onLogIn: () => setState(() => screenState = ScreenState.applicationScreens),
                switchToRegister: () => setState(() => screenState = ScreenState.registerScreen)
              );
            
            
            case ScreenState.applicationScreens:
              return Scaffold(
    
                backgroundColor: Colors.yellow.shade100,
                body: SafeArea(child: IndexedStack(index: bottomId, children: _children)),
    
                bottomNavigationBar: BottomNavigationBar(
    
                  type: BottomNavigationBarType.fixed,
    
                  selectedItemColor: Colors.deepOrange.shade800,
                  unselectedItemColor: Colors.orange.shade600,
                  
                  selectedLabelStyle:   const TextStyle( fontWeight: FontWeight.bold ),
                  unselectedLabelStyle: const TextStyle( ),
                  selectedIconTheme:    const IconThemeData( size: 32 ),
                  unselectedIconTheme:  const IconThemeData( size: 24 ),
    
                  currentIndex: bottomId,
                  onTap: (value) {
                    if (navigatable) {
                      setState(() => bottomId = value);
                    }
                    else {
                      warningModal(context, "Hãy tắt nút 'Hoạt động' ở trên để có thể thao tác nút dưới đây.");
                    }
                  },
                  
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
  Stream<int> preload(accountController) async* {
    if (!preloadOnce) {
      await accountController.preload();
      preloadOnce = true;
    }
  }
}



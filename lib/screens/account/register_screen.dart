import 'package:flutter/material.dart';

import 'package:flutter_app_texting/themes/text_themes.dart';


typedef CustomerCallback = Function(String val_1, String val_2, String val_3);


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({ Key? key, required this.onLogIn, required this.switchToLogin }) : super(key: key);
  final CustomerCallback onLogIn;
  final VoidCallback switchToLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(top: 180, bottom: 15, left: 5, right: 60),
      child: Center(
        child: Column(
          children: [
    
            // Trường nhập
            RegularTextField(controller: usernameController,       labelText: "Tên người dùng",    obscureText: false),
            RegularTextField(controller: phonenumberController,    labelText: "Số điện thoại",     obscureText: false),
            RegularTextField(controller: passwordController,       labelText: "Mật khẩu",          obscureText: true),
            RegularTextField(controller: repeatPasswordController, labelText: "Nhập lại mật khẩu", obscureText: true),
    
            const SizedBox(height: 30),
    
            // Nút đăng ký
            BigButton(label: "Đăng ký ngay!", onPressed: () => widget.onLogIn(
              usernameController.text,
              passwordController.text,
              phonenumberController.text
            )),

            const SizedBox(height: 60),
    
            // Nút lựa chọn đăng nhập thay vì đăng ký
            MaterialButton(
              onPressed: () => widget.switchToLogin(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Đã có tài khoản rồi? Hãy ", style: TextStyle(fontSize: 16)),
                  Text("Đăng nhập", style: TextStyle(color: Colors.orange.shade900, decoration: TextDecoration.underline, fontSize: 16)) 
                ],
              ),
            )
            
          ]
        ),
      ),
    );
  }
}




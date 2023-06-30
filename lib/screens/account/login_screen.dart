import 'package:flutter/material.dart';

import 'package:flutter_app_texting/themes/text_themes.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key, required this.onLogIn, required this.switchToRegister }) : super(key: key);
  final VoidCallback onLogIn;
  final VoidCallback switchToRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {

  TextEditingController phonenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool hasPhoneNumber = false;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(top: 180, bottom: 15, left: 5, right: 60),
      child: Center(
        child: Column(
          children: hasPhoneNumber ? [
            
            const SizedBox(height: 30),

            // Nhập số điện thoại
            Container(
              margin: const EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "以下に6桁のコードを入力してください",
                style: TextStyle(fontSize: 32, color: Colors.blueGrey.shade600)
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(6,
                (i) => Container(
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  width: 45,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                    border: Border.all(
                      color: Colors.indigo.shade300,
                      width: 1
                    )
                  ),
                  child: const TextField(

                  ),
                )
              ),
            ),

            const SizedBox(height: 30),

            OutlinedButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () {
                print(widget);
                widget.onLogIn();
                widget.switchToRegister();
                setState(() => hasPhoneNumber = false);
              },
              child: const Text("証明する！", style: TextStyle(fontSize: 24))
            ),


          ] : [
    
            RegularTextField(controller: phonenumberController, labelText: "Số điện thoại", obscureText: false),
            RegularTextField(controller: phonenumberController, labelText: "Mật khẩu",      obscureText: true),

            // Nút quên mật khẩu
            MaterialButton(
              onPressed: () => widget.switchToRegister(),
              child: Text("Quên mật khẩu?", style: TextStyle(color: Colors.orange.shade900, decoration: TextDecoration.underline, fontSize: 16))
            ),

            const SizedBox(height: 30),
    
            // Nút đăng nhập
            BigButton(label: "Đăng nhập ngay!", onPressed: () => widget.onLogIn()),

            const SizedBox(height: 60),
    
            // Nút lựa chọn đăng ký thay vì đăng nhập
            MaterialButton(
              onPressed: () => widget.switchToRegister(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản? Hãy ", style: TextStyle(fontSize: 16)),
                  Text("Đăng ký", style: TextStyle(color: Colors.orange.shade900, decoration: TextDecoration.underline, fontSize: 16)) 
                ],
              ),
            )

          ]
        ),
      ),
    );
  }

}
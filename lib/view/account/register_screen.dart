import 'package:flutter/material.dart';

import '/view/decoration.dart';


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

    return Scaffold(

      backgroundColor: Colors.amber.shade700,

      body: SafeArea( child: Stack( children: [

        // --------------------- Trang trí ---------------------
        Positioned(top: -60, right: -60, child: circle(Colors.amber.shade600, 90)),
        Positioned(top: 30, left: 90, right: 45, child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text( "Chào bạn!", textAlign: TextAlign.end,
              style: TextStyle(fontSize: 28, color: Colors.brown.shade900, fontWeight: FontWeight.bold)),

            Text( "Hãy đăng ký để bắt đầu.", textAlign: TextAlign.end,
              style: TextStyle(fontSize: 24, color: Colors.brown.shade900, fontWeight: FontWeight.bold)),
          ]
        )),

        Positioned(top: 120, left: -235, right: 30, child: Container(
          width: 710, height: 760,
          decoration: BoxDecoration(
            color: Colors.yellow.shade600,
            borderRadius: const BorderRadius.all(Radius.circular(300))
          ),
        )),

        Positioned(top: 150, left: -240, right: 40, child: Container(
          width: 700, height: 700,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(300))
          ),
        )),

        // --------------------- Trường nhập ---------------------
        Positioned(top: 180, left: 15, right: 60, child: Column( children: [
          RegularTextField(controller: usernameController,       labelText: "Tên người dùng",    obscureText: false),
          RegularTextField(controller: phonenumberController,    labelText: "Số điện thoại",     obscureText: false),
          RegularTextField(controller: passwordController,       labelText: "Mật khẩu",          obscureText: true),
          RegularTextField(controller: repeatPasswordController, labelText: "Nhập lại mật khẩu", obscureText: true),
        ])),

        // --------------------- Nút đăng ký ---------------------
        Positioned(top: 540, left: 90, right: 120, child: BigButton(
          bold: true,
          label: "Đăng ký ngay!",
          onPressed: () {
            String warningText = getWarningText(
              usernameController.text, phonenumberController.text,
              passwordController.text, repeatPasswordController.text);

            if (warningText.isEmpty) {
              widget.onLogIn( usernameController.text, passwordController.text, phonenumberController.text );
            }
            else {
              warningModal(context, warningText);
            }
          }
        )),

        Positioned(top: 640, left: 15, right: 60, child: MaterialButton(
          onPressed: () => widget.switchToLogin(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Đã có tài khoản rồi? Hãy ", style: TextStyle(fontSize: 16)),
              Text("Đăng nhập", style: TextStyle(color: Colors.orange.shade900, decoration: TextDecoration.underline, fontSize: 16)) 
            ],
          ),
        ))

      ]))
    );     
  }
}



String getWarningText(String username, String phoneNumber, String password, String repeatPassword) {
  if (!hasUsername(username)) {
    return "Không có tên người dùng.\nHãy nhập tên yêu thích của bạn, có thể là tên thật hoặc nickname.";
  }
  else if (!hasPhoneNumber(phoneNumber)) {
    return "Bạn cần nhập số điện thoại để sử dụng app này.";
  }
  else if (!validPhoneNumber(phoneNumber)) {
    return "Số điện thoại không hợp lệ.\nBạn hãy kiểm tra số điện thoại có đúng không.";
  }
  else if (!correctRangePassword(password)) {
    return "Mật khẩu không hợp lệ.\nSố lượng ký tự của mật khẩu là từ 8 đến 20.";
  }
  else if (!validPassword(password)) {
    return "Mật khẩu không hợp lệ.\nKý tự phải chứa ít nhất 1 chữ thường, 1 chữ hoa và 1 chữ số.";
  }
  else if (!confirmPassword(password, repeatPassword)) {
    return "Mật khẩu không hợp lệ. Mật khẩu nhập lại không khớp.";
  }
  return "";
}


bool hasUsername(String username) {
  return username.isNotEmpty;
}

bool hasPhoneNumber(String phonenumber) {
  return phonenumber.isNotEmpty;
}

bool validPhoneNumber(String phonenumber) {
  return phonenumber.length == 10;
}

bool correctRangePassword(String password) {
  return (password.length >= 8) && (password.length <= 20);
}

bool validPassword(String password) {
  // Kiểm tra mật khẩu hợp lệ trước
  // Độ dài từ 8 - 20
  // Có chứa ít nhất 1 ký tự a-z, 1 ký tự A-Z, 1 ký tự số
  return RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])').hasMatch(password);
}

bool confirmPassword(String password, String passswordConfirm) {
  return password == passswordConfirm;
}
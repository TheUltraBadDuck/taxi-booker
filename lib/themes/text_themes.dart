import 'package:flutter/material.dart';



AppBar bookAppBar(String title) {
  return AppBar(
    toolbarHeight: 60,
    title: Text(title, style: const TextStyle(fontSize: 28)),
    backgroundColor: Colors.amber.shade300,
    foregroundColor: Colors.black,
    elevation: 0
  );
}

Text registerTitle(String title) {
  return Text(
    title,
    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
    textAlign: TextAlign.end
  );
}

Container circle(Color color, double radius) {
  return Container(
    width: radius * 2,
    height: radius * 2,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(radius))
    )
  );
}

class OverAllPage extends StatelessWidget {
  const OverAllPage({ Key? key, required this.child }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      color: Colors.white,
      child: child
    );
  }
}




class RegularTextField extends StatefulWidget {
  RegularTextField({ Key? key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.text = ""
  }) : super(key: key) {
    controller.text = text;
  }
  final TextEditingController controller;
  final String labelText;
  final String text;
  final bool obscureText;
  
  @override
  State<RegularTextField> createState() => _RegularTextFieldState();
}

class _RegularTextFieldState extends State<RegularTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
      child: TextField(
        
        style: TextStyle( fontSize: 20, color: Colors.amber.shade900 ),
        cursorColor: Colors.amber.shade900,

        obscureText: widget.obscureText,

        controller: widget.controller,
        onSubmitted: (String value) async => print("YAY $value"),
        decoration: InputDecoration(
    
          labelText: widget.labelText,
          labelStyle: TextStyle( fontSize: 18, color: Colors.grey.shade700 ),
          floatingLabelStyle: TextStyle( color: Colors.brown.shade700 ),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow.shade100)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow.shade200)),
    
        ),
      ),
    );
  }
}




TextStyle usernameTitle() {
  return const TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold
  );
}

TextStyle signatureSubtitle() {
  return TextStyle(
    color: Colors.indigo.shade50,
    fontSize: 16
  );
}



class BigButton extends StatefulWidget {
  const BigButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.width = 230.0,
    this.fontSize = 24,
    this.bold = false,
    this.color = Colors.transparent
  }) : super(key: key);
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double fontSize;
  final bool bold;
  final Color color;

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.bold) {
      return SizedBox(
        width: widget.width,
        child: ElevatedButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(15),
            backgroundColor: widget.color.opacity == Colors.transparent.opacity ? Colors.deepOrange.shade600 : widget.color,
            foregroundColor: Colors.white
          ),
          onPressed: () => widget.onPressed(),
          child: Text(widget.label, style: TextStyle(fontSize: widget.fontSize))
        ),
      );
    }
    else {
      return SizedBox(
        width: widget.width,
        child: OutlinedButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(15),
            side: BorderSide(color: Colors.yellow.shade100)
          ),
          onPressed: () => widget.onPressed(),
          child: Text(widget.label, style: TextStyle(fontSize: widget.fontSize, color: Colors.deepOrange.shade600))
        ),
      );
    }
  }
}



class CarWidget extends StatelessWidget {
  const CarWidget({ Key? key, required this.text }) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox.fromSize(
            size: const Size.fromRadius(24),
            child: Image.asset("assets/images/avatar.jpg")
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          )
        ]
      ),
    );
  }
}



String formalDate(String date) {
  String formalDate = "Ngày ";
  formalDate += date.substring(3, 5);

  switch (date.substring(0, 2)) {
    case "01": formalDate += " / 1 / "; break;
    case "02": formalDate += " / 2 / "; break;
    case "03": formalDate += " / 3 / "; break;
    case "04": formalDate += " / 4 / "; break;
    case "05": formalDate += " / 5 / "; break;
    case "06": formalDate += " / 6 / "; break;
    case "07": formalDate += " / 7 / "; break;
    case "08": formalDate += " / 8 / "; break;
    case "09": formalDate += " / 9 / "; break;
    case "10": formalDate += " / 10 / "; break;
    case "11": formalDate += " / 11 / "; break;
    case "12": formalDate += " / 12 / "; break;
  }
  formalDate += date.substring(6, 10);

  return formalDate;
}



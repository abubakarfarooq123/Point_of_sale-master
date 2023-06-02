import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/home_screen.dart';

class LoginWaiting extends StatefulWidget {
  const LoginWaiting({Key? key}) : super(key: key);

  @override
  _LoginWaitingState createState() => _LoginWaitingState();
}

class _LoginWaitingState extends State<LoginWaiting> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitRipple(
                color: Colors.blue,
                size: 100.0,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Logging In',
                style: GoogleFonts.roboto(
                  color: Colors.blue,
                  fontSize: 20.0,
                ),
              ),
            ],
          )),
    );
  }
}
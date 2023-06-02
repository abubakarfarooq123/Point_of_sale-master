import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../user/login.dart';


class Fwaiting extends StatefulWidget {
  const Fwaiting({Key? key}) : super(key: key);

  @override
  _FwaitingState createState() => _FwaitingState();
}

class _FwaitingState extends State<Fwaiting> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
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
            SpinKitFadingFour(
              color: Colors.blue,
              size: 100.0,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Sending Email',
              style: GoogleFonts.roboto(
                color: Colors.blue,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
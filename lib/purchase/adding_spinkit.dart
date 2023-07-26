import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/purchase/purchase.dart';

import '../user/login.dart';


class Waiting_Adding extends StatefulWidget {
  const Waiting_Adding({Key? key}) : super(key: key);

  @override
  _Waiting_AddingState createState() => _Waiting_AddingState();
}

class _Waiting_AddingState extends State<Waiting_Adding> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Purchase()));
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
              'Adding Purchase',
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
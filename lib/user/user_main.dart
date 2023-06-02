import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/user/login.dart';
import 'package:pos/user/signup.dart';

class Main_User extends StatelessWidget {
  const Main_User({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
                Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                      image: DecorationImage(
                        image: AssetImage("assets/images/ss.png"),
                      )
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                         Padding(
                          padding: const EdgeInsets.only(top: 350),
                          child: Text(
                            "SELLIO",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              fontSize: 30
                            ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 05),
                          child: Text(
                            "Point of Sale",
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 22
                            ),),
                        ),
                      ],
                    ),
                ),
            SizedBox(
              height: 50,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Login()));
                },
                child: Container(
                  height: 50,
                  width:
                  320,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
    child: Center(
      child: Text("Login",style: GoogleFonts.roboto(
      color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
                  ),
    ),
            ),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterPage()));
                },
                child: Container(
                  height: 50,
                  width:
                  320,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text("Registration",style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),),
                  ),
                )),

          ],
        ),
      ),
    );
  }
}

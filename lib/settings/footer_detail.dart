import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/user/edit_profile.dart';


import '../home/drawer.dart';
import '../splashScreens/loginout.dart';

enum MenuItem{
  item1,
  item2,
}
class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Footer Details",
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (value) {
              if (value == MenuItem.item1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Edit_Profile()));
              }
              if (value == MenuItem.item2) {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginOut()));

                    (route) => false;
              }
            },
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                value: MenuItem.item1,
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 10,),
                    Text(
                      "Edit Profile", style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16
                    ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: MenuItem.item2,
                child: Row(
                  children: [
                    Icon(Icons.login_outlined),
                    SizedBox(width: 10,),
                    Text(
                      "Logout", style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16
                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text("Sale Invoice Footer",style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Sale Note',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text("Sale Invoice Footer Notes",style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Jawad and Brothers',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text("Quotation Invoice Footer Title",style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Quotation Notes',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text("Quotation Invoice Footer Notes",style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Jawad and Brothers',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text("Purchase Invoice Footer Title",style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Purchase Note',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text("Purchase Invoice Footer Notes",style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Jawad and Brothers',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 230),
                  child: Container(
                    height: 50.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: InkWell(
                      onTap: () {
                      },
                      child: Center(
                        child: Text(
                          'Update',
                          style: GoogleFonts.roboto(
                            fontSize: 17.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),

          ],
        ),

      ),
    );
  }

  Widget bottomSheet(context) {
    return Container(
      height: 80.0,
      width: MediaQuery
          .of(context)
          .size
          .width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "Choose Profile photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 7.0,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(
                Icons.camera,
                color: Color.fromARGB(255, 218, 162, 16),
                size: 30.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              label: Text("Camera"),
            ),
            SizedBox(
              width: 40.0,
            ),
            TextButton.icon(
              icon: Icon(
                Icons.image,
                color: Color.fromARGB(255, 218, 162, 16),
                size: 30.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }
}
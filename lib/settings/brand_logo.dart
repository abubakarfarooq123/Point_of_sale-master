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
class Brand extends StatefulWidget {
  const Brand({Key? key}) : super(key: key);

  @override
  State<Brand> createState() => _BrandState();
}

class _BrandState extends State<Brand> {
  String? url;
  String? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Businesses",
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

            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Stack(
                fit: StackFit.loose,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      url != null
                          ? CircleAvatar(
                        radius: 80.0,
                        backgroundImage: AssetImage("assets/images/logo.png"),
                      )
                          : image != ''
                          ? CircleAvatar(
                        radius: 80.0,
                        backgroundImage: AssetImage("assets/images/logo.png"),
                      )
                          : CircleAvatar(
                        radius: 80.0,
                        backgroundColor: Colors.black,
                        backgroundImage: AssetImage(
                            'assets/images/user.png'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 120.0, left: 90.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: ((builder) =>
                                  bottomSheet(context)),
                            );
                          },
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.blue,
                            size: 35.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                            "Business Title",
                            style: GoogleFonts.roboto(
                        color: Colors.black,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                      ),
                      Expanded(
                        child: Text(
                          "Registraion Number",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 18,right: 18,top: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: 'Title',
                        ),
                      ),
                    ),
                    ),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 18,right: 18,top: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: 'Number',
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Phone Number",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Email",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 18,right: 18,top: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: 'Phone',
                        ),
                      ),
                    ),
                    ),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 18,right: 18,top: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
                  child: Text("Address Line",style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18,right: 18),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Address',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Zip Code",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "City",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 18,right: 18,top: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: 'Postal Code',
                        ),
                      ),
                    ),
                    ),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 18,right: 18,top: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: 'City',
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
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
                color: Colors.blue,
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
                color: Colors.blue,
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
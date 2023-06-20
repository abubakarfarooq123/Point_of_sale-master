import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';
import 'package:pos/warehouse/warehouse.dart';

import '../splashScreens/loginout.dart';
enum MenuItem{
  item1,
  item2,
}
class Add_Warehouse extends StatefulWidget {
  @override
  State<Add_Warehouse> createState() => _Add_WarehouseState();
}
class _Add_WarehouseState extends State<Add_Warehouse> {
  final _formKey = GlobalKey<FormState>();

  var name='';
  var address ='';
  var phone ='';
  var city = '';
  var state = '';
  var zipcode = '';
  var country = '';
  final nameController = TextEditingController();
  final countryController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipcodeController = TextEditingController();
  void dispose() {
    nameController.dispose();
    countryController.dispose();
    addressController.dispose();
    phoneController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipcodeController.dispose();
    super.dispose();
  }

  add() async {
    await FirebaseFirestore.instance
        .collection('warehouse')
        .doc()
        .set({
      'item': name,
      'phone': phone,
      'addres':address,
      'city': city,
      'state':state,
      'zipcode': zipcode,
      'country': country,
      'cost': '',
    })
        .then((value) => print('User Added'))
        .catchError((error) => print('Failed to add user: $error'));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Warehouse(),
      ),
    );
  }
  List<String> gender =['Male','Female','N/A'];
  String selected = '';
  var setvalue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Add New Warehouse",
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (value){
              if(value== MenuItem.item1){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Edit_Profile()));
              }
              if(value== MenuItem.item2){
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginOut()));

                    (route) => false;
              }

            },
            itemBuilder: (context)=>[
              PopupMenuItem(
                value: MenuItem.item1,
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 10,),
                    Text(
                      "Edit Profile",style: GoogleFonts.roboto(
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
                      "Logout",style: GoogleFonts.roboto(
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
          children: [
            new Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Warehouse Title',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        icon: Icon(
                          FontAwesomeIcons.house,
                          color: Colors.blue,
                        ),
                      ),
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Title';
                          }
                          return null;
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18,right: 18,bottom: 18,top: 18),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'Phone',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        icon: Icon(
                          FontAwesomeIcons.phone,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: 'Address',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        icon: Icon(
                          FontAwesomeIcons.home,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        hintText: 'City',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        icon: Icon(
                          FontAwesomeIcons.city,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: stateController,
                      decoration: InputDecoration(
                        hintText: 'State',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        icon: Icon(
                          Icons.real_estate_agent_rounded,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: zipcodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'ZipCode',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        icon: Icon(
                          FontAwesomeIcons.locationArrow,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: countryController,
                      decoration: InputDecoration(
                        hintText: 'Country',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        icon: Icon(
                          FontAwesomeIcons.globe,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  // ignore: deprecated_member_use
                  Container(
                    height: 45.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue

                    ),
                    child: InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            name = nameController.text;
                            country = countryController.text;
                            phone = phoneController.text;
                            address = addressController.text;
                            city = cityController.text;
                            state = stateController.text;
                            zipcode = zipcodeController.text;
                          });
                          add();
                        }
                      },
                      child: Center(
                        child: Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

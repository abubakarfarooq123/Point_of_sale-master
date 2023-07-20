import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';

import '../splashScreens/loginout.dart';
import 'customer.dart';

enum MenuItem {
  item1,
  item2,
}

class Add_Customer extends StatefulWidget {
  @override
  State<Add_Customer> createState() => _Add_CustomerState();
}

class _Add_CustomerState extends State<Add_Customer> {
  List<String> gender = ['Male', 'Female', 'N/A'];
  String selected = '';
  var setvalue;
  final _formKey = GlobalKey<FormState>();

  var name = "";
  var email = "";
  var phone = "";
  var address = "";
  var city = "";
  var state = "";
  var zipcode = "";
  var country = "";
  var previous_blanace = "";

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipcodeController = TextEditingController();
  final countryController = TextEditingController();
  final previous_balanceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipcodeController.dispose();
    countryController.dispose();
    previous_balanceController.dispose();
    super.dispose();
  }

  Future<void> adduser() async {
    print("UserEmail is :" + email);
    print('Values are ' + name + email + phone);
  }

  add() async {
    DocumentReference docRef =
    FirebaseFirestore.instance.collection('customer').doc();
    var brandId = docRef.id;

    await docRef.set({
    'id': brandId,
          'name': name,
          'email': email,
          'phone': phone,
          'gender': setvalue,
          'address': address,
          'city': city,
          'state': state,
          'zip': zipcode,
          'country': country,
          'previous': previous_blanace,
      'total_spend': "",
      'invoices': "",
        })
        .then((value) => print('User Added'))
        .catchError((error) => print('Failed to add user: $error'));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Customer(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Add New Customer",
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Edit_Profile()));
              }
              if (value == MenuItem.item2) {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginOut()));

                (route) => false;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: MenuItem.item1,
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Edit Profile",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: MenuItem.item2,
                child: Row(
                  children: [
                    Icon(Icons.login_outlined),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Logout",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
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
                          hintText: 'Name',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          icon: Icon(
                            FontAwesomeIcons.user,
                            color: Colors.blue,
                          ),
                        ),
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Name';
                          }
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Email ID',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          errorStyle: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15.0,
                          ),
                          icon: Icon(
                            FontAwesomeIcons.envelope,
                            color: Colors.blue,
                          ),
                        ),
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Email';
                          } else if (!value.contains('@')) {
                            return 'Please Enter Valid Email';
                          }
                          return null;
                        }),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.only(left: 14, right: 14, top: 14),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(
                                Icons.assignment_ind_outlined,
                                color: Colors.blue,
                                size: 35,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 279,
                                height: 60,
                                padding: EdgeInsets.only(left: 16, right: 16),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(15)),
                                child: DropdownButton(
                                  hint: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Please choose Gender',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  iconSize: 40.0,
                                  value: setvalue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      setvalue = newValue;
                                    });
                                  },
                                  items: gender.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            selected,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.teal[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 18, right: 18, bottom: 18),
                    child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Phone',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
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
                        controller: phoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Phone';
                          }
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Address',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
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
                        controller: addressController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Address';
                          }
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'City',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
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
                        controller: cityController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter City';
                          }
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'State',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
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
                        controller: stateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter State';
                          }
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'ZipCode',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
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
                        controller: zipcodeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter ZipCode';
                          }
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Country',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
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
                        controller: countryController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Country';
                          }
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Previous Balance Due',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          errorStyle: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15.0,
                          ),
                          icon: Icon(
                            FontAwesomeIcons.cashRegister,
                            color: Colors.blue,
                          ),
                        ),
                        controller: previous_balanceController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Balance';
                          }
                          return null;
                        }),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // ignore: deprecated_member_use
                  Container(
                    height: 45.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    child: InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            name = nameController.text;
                            email = emailController.text;
                            phone = phoneController.text;
                            address = addressController.text;
                            city = cityController.text;
                            state = stateController.text;
                            zipcode = zipcodeController.text;
                            country = countryController.text;
                            previous_blanace = previous_balanceController.text;
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/items/discount/discount.dart';
import 'package:pos/user/edit_profile.dart';

import '../../splashScreens/loginout.dart';
enum MenuItem{
  item1,
  item2,
}
class Add_discount extends StatefulWidget {
  @override
  State<Add_discount> createState() => _Add_discountState();
}
class _Add_discountState extends State<Add_discount> {
  final _formKey = GlobalKey<FormState>();

  var lable = "";
  final lableController = TextEditingController();
  final amountTextController = TextEditingController();
  String amountText = '';
  String selectedType = 'Amount';

  void addButtonPressed() async{
    double finalAmount = double.parse(amountText);

    if (selectedType == 'Percentage') {
      finalAmount = finalAmount / 100; // Treat as a percentage
    }

    // Perform calculations or further processing with the final amount
    // (e.g., store, display, etc.)

    // Reset the fields or perform any other necessary actions
    DocumentReference docRef = FirebaseFirestore.instance.collection('Discount').doc();
    var UnitId = docRef.id;

    await docRef.set({
      'id': UnitId,
      'amount': finalAmount.toString(),
      'type': selectedType,
      'lable': lable
    });
    setState(() {
      amountText = '';
      selectedType = 'Amount';
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Discount(),
      ),
    );
  }

  void dispose() {
    lableController.dispose();
    amountTextController.dispose();
    super.dispose();
  }

  List<String> amount =['Amount','Percentage'];
  String selected = '';
  var setvalue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "New Discount",
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 30,top: 30),
                    child: Text("Add New Discount",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,),
                    child: Text("Lable",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Lable',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                        controller: lableController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Lable';
                          }
                          return null;
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,),
                    child: Text("Amount",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            amountText = value;
                          });
                        },
                        decoration: InputDecoration(
                        hintText: 'Amount',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                        controller: amountTextController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Amount';
                          }
                          return null;
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,bottom: 20),
                    child: Text("Discount",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16
                    ),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14,right: 14),
                    child: Container(
                      height: 60,
                      width: 340,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400,)
                      ),
                      child: DropdownButton<String>(
                        underline: SizedBox(),
                        isExpanded: true,
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 0,
                          ),
                        ),
                        value: selectedType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedType = newValue!;
                          });
                        },
                        items: <String>['Amount', 'Percentage']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,top: 5),
                              child: Text(value),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),


                  SizedBox(height: 20,),
                  // ignore: deprecated_member_use
                  Padding(
                    padding: const EdgeInsets.only(left: 25,top: 20),
                    child: Container(
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
                              lable = lableController.text;
                              amountText = amountTextController.text;
                            });
                            addButtonPressed();
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

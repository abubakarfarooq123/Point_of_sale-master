import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../splashScreens/loginout.dart';

enum MenuItem {
  item1,
  item2,
}

class Add_Inventory extends StatefulWidget {
  @override
  State<Add_Inventory> createState() => _Add_InventoryState();
}

class _Add_InventoryState extends State<Add_Inventory> {

  List<String> supplier = ['WareHouse1', 'WareHouse2', 'Warehouse3'];
  String selected1 = '';
  var setvalue1;
  List<String> Item = ['Bag', 'bean', 'hooters'];
  String selected2 = '';
  var setvalue2;
  TextEditingController _date = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "New Inventory",
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15,top: 20,bottom: 15),
              child: Text("Create New Stock Adjustment",style: GoogleFonts.roboto(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),),
            ),
            new Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            "Date",
                            style: GoogleFonts.roboto(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            "Ware House",
                            style: GoogleFonts.roboto(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14,right: 14,top:12),
                          child: TextFormField(
                            controller: _date,
                            decoration: InputDecoration(
                              hintText: 'Pick Date',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onTap: () async {
                              DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickeddate != null) {
                                setState(() {
                                  _date.text = DateFormat('yyyy-MM-dd')
                                      .format(pickeddate);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child:Padding(
                          padding: const EdgeInsets.only(left: 14,right: 14,top: 12),
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                      width: 150,
                                      height: 62,
                                      padding: EdgeInsets.only(left: 16, right: 16),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius: BorderRadius.circular(15)),
                                      child: DropdownButton(
                                        hint: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 35),
                                        ),
                                        isExpanded: true,
                                        icon: Visibility(
                                            visible: false,
                                            child: Icon(Icons.arrow_downward)),
                                        underline: SizedBox(),
                                        value: setvalue1,
                                        onChanged: (newValue) {
                                          setState(() {
                                            setvalue1 = newValue;
                                          });
                                        },
                                        items: supplier.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                Text(
                                  selected1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: Text(
                      "Select Item",
                      style:
                      GoogleFonts.roboto(color: Colors.black, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14,right: 14,top: 14),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Container(
                                width: 329,
                                height: 60,
                                padding: EdgeInsets.only(left: 16,right: 16),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey,width: 1),
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: DropdownButton(
                                  hint: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Please choose Item',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  isExpanded: true,
                                  icon: Icon(Icons.arrow_drop_down_circle,color: Colors.transparent,),
                                  underline: SizedBox(),
                                  value: setvalue2,
                                  onChanged: (newValue) {
                                    setState(() {
                                      setvalue2 = newValue;
                                    });
                                  },
                                  items: Item.map((String value) {
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
                            selected2,
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                        columnSpacing: 21,
                        headingRowColor: MaterialStateColor.resolveWith(
                              (states) {
                            return Colors.blue;
                          },
                        ),
                        // border: TableBorder(
                        //   borderRadius: BorderRadius.circular(20),
                        // ),
                        dividerThickness: 3,
                        showBottomBorder: true,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Product',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Current Stock',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Unit Cost',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Quantity',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'New Quantity',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          DataColumn(label: Text(""),),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('Wash Powder')),
                            DataCell(Text('10')),
                            DataCell(Text('501')),
                            DataCell(Text('3')),
                            DataCell(Text('7')),
              DataCell( IconButton(onPressed: (){}, icon: Icon(Icons.cancel),color: Colors.red,),),
            ],
                          ),
                          DataRow(cells: [
                            DataCell(Text('Powder')),
                            DataCell(Text('30')),
                            DataCell(Text('1001')),
                            DataCell(Text('10')),
                            DataCell(Text('20')),
                            DataCell( IconButton(onPressed: (){}, icon: Icon(Icons.cancel),color: Colors.red,),),

                          ]),

                        ]),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 80,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    child: InkWell(
                  onTap: (){},
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      height: 40,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:Center(
                          child: Text(
                              "Cancel"
                          ),) ,
                    ),
                  ),
                )),
                Expanded(
                    child: InkWell(
                      onTap: (){},
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          height: 40,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:Center(
                            child: Text(
                                "Continue"
                            ),) ,
                        ),
                      ),
                    ))

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showMyDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: 600,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 30),
                  child: Text(
                    "Add New Discount",
                    style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          "Lable",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          "Amount",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Lable',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 20),
                  child: Text(
                    "Discount",
                    style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                        child: Text(
                          "OR",
                          style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 14),
                        )),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, bottom: 20),
                  child: Text(
                    "Discount",
                    style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 45.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    child: InkWell(
                      onTap: () {},
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
        ),
      ),
    );
  }

  Widget showTaxDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: 600,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 30),
                  child: Text(
                    "Add New Tax",
                    style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          "Lable",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          "Amount",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Lable',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 20),
                  child: Text(
                    "Type",
                    style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                        child: Text(
                          "OR",
                          style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 14),
                        )),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, bottom: 20),
                  child: Text(
                    "Tax",
                    style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 45.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    child: InkWell(
                      onTap: () {},
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
        ),
      ),
    );
  }

  Widget showExtraDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: 450,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 30),
                  child: Text(
                    "Add Extra Charges",
                    style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    "Charge Title",
                    style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Title',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    "Charge Amount",
                    style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 45.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    child: InkWell(
                      onTap: () {},
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
        ),
      ),
    );
  }
}

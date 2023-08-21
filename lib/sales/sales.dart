import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/sales/add_sales.dart';
import 'package:pos/user/edit_profile.dart';

import '../splashScreens/loginout.dart';

enum MenuItem{
  item1,
  item2,
}

class Sales extends StatefulWidget {
  const Sales({Key? key}) : super(key: key);

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Sales",
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
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14,top: 20,bottom: 14),
                    child: Container(
                      height: 50,
                      width: 230,
                      child: TextField(
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(color: Colors.black)),
                          prefixIcon: Icon(
                            Icons.search_outlined,
                            color: Colors.grey,
                          ),
                          hintText: "Search...",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,),
                    child: InkWell(
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue
                        ),
                        child: Icon(FontAwesomeIcons.filePdf,color: Colors.white,size: 18,),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,),
                    child: InkWell(
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.blue
                        ),
                        child: Icon(
                          FontAwesomeIcons.fileCsv,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              DataTable(
                  columnSpacing:45,
                  headingRowColor: MaterialStateColor.resolveWith((states) {return Colors.blue;},),
                  // border: TableBorder(
                  //   borderRadius: BorderRadius.circular(20),
                  // ),
                  dividerThickness: 3,
                  showBottomBorder: true,
                  columns: [
                    DataColumn(
                      label:  Text('Sale #',style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Date',style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Customer',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Items',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Sub Total',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Discount',style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Tax',style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Grand Total',style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Due Date',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(label: Text(""))
                  ],
                  rows: [

                    DataRow(cells: [
                      DataCell(Text('QUOT# 1'),
                      ),
                      DataCell(Text('2023/13/4'),
                      ),
                      DataCell(Text('Ali'),
                      ),
                      DataCell(Text('1'),
                      ),
                      DataCell(Text('Rs. 123'),
                      ),
                      DataCell(Text('Rs. 10'),
                      ),
                      DataCell(Text('Rs. 5'),
                      ),
                      DataCell(Text('20.0'),
                      ),
                      DataCell(Text('2023/13/4'),
                      ),
                      DataCell( Row(
                        children: [
                          IconButton(onPressed: (){}, icon: Icon(Icons.edit),color: Colors.blue,),
                          SizedBox(
                            width: 5,
                          ),
                          IconButton(onPressed: (){}, icon: Icon(Icons.delete),color: Colors.blue,),
                        ],
                      ),),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('QUOT# 2'),
                      ),
                      DataCell(Text('2023/23/2'),
                      ),
                      DataCell(Text('Hami'),
                      ),
                      DataCell(Text('2'),
                      ),
                      DataCell(Text('Rs. 180'),
                      ),
                      DataCell(Text('Rs. 40'),
                      ),
                      DataCell(Text('Rs. 10'),
                      ),
                      DataCell(Text('Rs. 10'),
                      ),
                      DataCell(Text('2023/23/3'),
                      ),
                      DataCell( Row(
                        children: [
                          IconButton(onPressed: (){}, icon: Icon(Icons.edit),color: Colors.blue,),
                          SizedBox(
                            width: 5,
                          ),
                          IconButton(onPressed: (){}, icon: Icon(Icons.delete),color: Colors.blue,),
                        ],
                      ),),
                    ]),


                  ]),


            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Add_Sales()));

        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}

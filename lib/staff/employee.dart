import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';
import 'package:pos/staff/add_employee.dart';

import '../splashScreens/loginout.dart';
enum MenuItem{
  item1,
  item2,
}

class Employee extends StatefulWidget {
  const Employee({Key? key}) : super(key: key);

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore.collection('employee').get();
    return snapshot.docs;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Employee",
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
                  value: MenuItem.item2,
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 10,),
                      Text(
                        "Edit Profile",style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 16
                      ),),
                    ],
                  )),
              PopupMenuItem(
                  value: MenuItem.item1,
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
        child:FutureBuilder<List<DocumentSnapshot>>(
          future: fetchEmployeeData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<DocumentSnapshot> data = snapshot.data!;
              return Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14, top: 20, bottom: 14),
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
                      child: Icon(FontAwesomeIcons.filePdf, color: Colors.white,
                        size: 18,),
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
                      child: Icon(FontAwesomeIcons.fileCsv, color: Colors.white,
                        size: 18,),
                    ),
                  ),
                ),

              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                  columnSpacing: 60,
                  headingRowColor: MaterialStateColor.resolveWith((states) {
                    return Colors.blue;
                  },),
                  // border: TableBorder(
                  //   borderRadius: BorderRadius.circular(20),
                  // ),
                  dividerThickness: 3,
                  showBottomBorder: true,
                  columns: [
                    DataColumn(
                      label: Text('Name', style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),),
                    ),
                    DataColumn(
                      label: Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Text('Email', style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Role', style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Phone', style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                      ),
                    ),
                  ],
                rows: data.map((document) {
                  Map<String, dynamic> employeeData = document.data() as Map<String, dynamic>;
                  String name = employeeData['Name'];
                  String email = employeeData['email'];
                  String role = employeeData['role'];
                  String phone = employeeData['phone'];

                  return DataRow(
                    cells: [
                      DataCell(Text(name)),
                      DataCell(Text(email)),
                      DataCell(Text(role)),
                      DataCell(Text(phone)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }
      //       else if (snapshot.hasError) {
      //   return Text('Error: ${snapshot.error}');
      // } else {
      //   return CircularProgressIndicator();
      // }
    },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Add_User()));

        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../home/drawer.dart';
import '../../../splashScreens/loginout.dart';
import '../../../user/edit_profile.dart';

enum MenuItem {
  item1,
  item2,
}

class Discount_Report extends StatefulWidget {
  const Discount_Report({super.key});

  @override
  State<Discount_Report> createState() => _Discount_ReportState();
}

class _Discount_ReportState extends State<Discount_Report> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore
        .collection('Discount')
        .get();
    return snapshot.docs;
  }
  // String calculateTotalInvoices(List<DocumentSnapshot> data) {
  //   double totalInvoices = 0.0;
  //   for (final document in data) {
  //     Map<String, dynamic> employeeData =
  //     document.data() as Map<String, dynamic>;
  //     totalInvoices += employeeData['grand'];
  //   }
  //   return totalInvoices.toString();
  // }
  // String calculateTotalprofit(List<DocumentSnapshot> data) {
  //   double totalInvoices = 0.0;
  //   for (final document in data) {
  //     Map<String, dynamic> employeeData =
  //     document.data() as Map<String, dynamic>;
  //     totalInvoices += employeeData['due'];
  //   }
  //   return totalInvoices.toString();
  // }
  //
  // String calculateTotalCount(List<DocumentSnapshot> data) {
  //   int totalInvoices = 0;
  //   for (final document in data) {
  //     Map<String, dynamic> employeeData =
  //     document.data() as Map<String, dynamic>;
  //     totalInvoices = employeeData['purchase'];
  //   }
  //   return totalInvoices.toString();
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Discount Report",
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
        child: FutureBuilder<List<DocumentSnapshot>>(
            future: fetchEmployeeData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<DocumentSnapshot> data = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 100,top: 20),
                        child: Text("Jawad & Brothers",style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 17
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10,top: 10),
                        child: Text("Select Discount:",style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17
                        ),),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 60, top: 20, bottom: 14),
                              child: Center(
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
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     SizedBox(
                      //       width: 20,
                      //     ),
                      //     Column(
                      //       children: [
                      //         Text("Total Purchases",
                      //           style: GoogleFonts.poppins(
                      //               color: Colors.black,
                      //               fontWeight: FontWeight.bold
                      //           ),),
                      //         SizedBox(
                      //           height: 10,
                      //         ),
                      //         Text(
                      //           'Rs. ${calculateTotalInvoices(data)}',
                      //         ),
                      //       ],
                      //     ),
                      //     SizedBox(
                      //       width: 40,
                      //     ),
                      //     Column(children: [
                      //       Text("Sale Count",
                      //         style: GoogleFonts.poppins(
                      //             color: Colors.black,
                      //             fontWeight: FontWeight.bold
                      //         ),),
                      //       SizedBox(
                      //         height: 10,
                      //       ),
                      //       Text(calculateTotalCount(data)),
                      //     ],
                      //     ),
                      //     SizedBox(
                      //       width: 40,
                      //     ),
                      //     Column(children: [
                      //       Text("Total Due",style: GoogleFonts.poppins(
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.bold
                      //       ),),
                      //       SizedBox(
                      //         height: 10,
                      //       ),
                      //       Text(calculateTotalprofit(data)),
                      //     ],),
                      //   ],
                      // ),
                      SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 180,
                          headingRowColor: MaterialStateColor.resolveWith(
                                (states) {
                              return Colors.blue;
                            },
                          ),
                          dividerThickness: 3,
                          showBottomBorder: true,
                          columns: [
                            DataColumn(
                              label: Text(
                                'Title',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Title Amount',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          ],
                          rows: List<DataRow>.generate(data.length, (index) {
                            Map<String, dynamic> employeeData =
                            data[index].data() as Map<String, dynamic>;
                            String title = employeeData['lable'].toString();
                            String item = employeeData['amount'].toString();
                            return DataRow(
                              cells: [

                                DataCell(Text(title)),
                                DataCell(Text(item)),
                              ],
                            );
                          }).toList(),
                        ),
                      )

                    ],
                  ),
                );
              }
            }
        ),
      ),
    );
  }
}

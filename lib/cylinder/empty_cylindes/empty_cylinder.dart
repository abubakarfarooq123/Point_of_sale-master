import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/drawer.dart';
import '../../splashScreens/loginout.dart';
import '../../user/edit_profile.dart';
import 'add_empty_cylinders.dart';
enum MenuItem {
  item1,
  item2,
}
class Empty_Cylinders extends StatefulWidget {
  const Empty_Cylinders({super.key});

  @override
  State<Empty_Cylinders> createState() => _Empty_CylindersState();
}

class _Empty_CylindersState extends State<Empty_Cylinders> {
  bool isisRowSelected = false;
  int selectedRowIndex = -1; // Track the index of the selected row


  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore.collection('empty_cylinder').get();
    return snapshot.docs;
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Object?> getValuesFromFirebase() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('empty_cylinder')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return {}; // Default empty map if the document doesn't exist
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Empty Cylinders",
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
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 18,
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
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Logout",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 18,
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
      body: FutureBuilder<List<DocumentSnapshot>>(
          future: fetchEmployeeData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<DocumentSnapshot> data = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 14, top: 20, bottom: 14),
                            child: Container(
                              height: 50,
                              width: 230,
                              child: TextField(
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
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
                            padding: const EdgeInsets.only(left: 10),
                            child: InkWell(
                              onTap: () {
                                showDeleteConfirmationDialog(context, data, selectedRowIndex);
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: selectedRowIndex != -1
                                      ? Colors.red
                                      : Colors.grey.withOpacity(0.5),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: InkWell(
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: selectedRowIndex != -1
                                      ? Colors.blue
                                      : Colors.grey.withOpacity(0.5),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.filePdf,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: InkWell(
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: selectedRowIndex != -1
                                      ? Colors.blue
                                      : Colors.grey.withOpacity(0.5),
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
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 45,
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
                              'Purchase #',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Purchase Date',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              'Supplier',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Warehouse',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Cylinder Title',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                              'Total Amount',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Paid',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Remaining',
                              style: GoogleFonts.roboto(
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
                        ],
                        rows: List<DataRow>.generate(data.length, (index) {
                          Map<String, dynamic> employeeData =
                          data[index].data() as Map<String, dynamic>;
                          String purchase = employeeData['purchase'].toString();
                          String date = employeeData['pickdate'];
                          String supplier = employeeData['supplier'];
                          String warehouse = employeeData['warehouse'].toString();
                          String cylinder = employeeData['cylinder'].toString();
                          String quantity = employeeData['quantity'].toString();
                          String total = employeeData['total'].toString();
                          String paid = employeeData['piad'].toString();
                          String remaining = employeeData['remaining'].toString();
                          String duedate = employeeData['duedate'];
                          return DataRow.byIndex(
                            index: index,
                            selected: selectedRowIndex == index,
                            onSelectChanged: (selected) {
                              setState(() {
                                if (selected!) {
                                  selectedRowIndex = index;
                                } else {
                                  selectedRowIndex = -1;
                                }
                              });
                            },
                            cells: [
                              DataCell(Text(
                                "PUR# ${purchase}",
                                style: GoogleFonts.roboto(),
                              )),
                              DataCell(Text(date !=null ? date : '' )),
                              DataCell(Text(supplier !=null ? supplier : '' )),
                              DataCell(Text(warehouse !=null ? warehouse : '' )),
                              DataCell(Text(cylinder !=null ? cylinder  : '' )),
                              DataCell(Text(quantity !=null ? quantity  : '' )),
                               DataCell(Text(total !=null ? total : '0.0'  )),
                              DataCell(Text(paid !=null ? paid : '' )),
                              DataCell(Text(remaining !=null ? remaining : '0.0')),
                              DataCell(Text(duedate !=null ? duedate  : '' )),
                            ],
                          );
                        }).toList(),
                        dataRowColor: MaterialStateColor.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.grey.withOpacity(0.5);
                          }
                          return Colors.transparent;
                        }),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Add_Empty_Cylinder()));
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
  void showDeleteConfirmationDialog(BuildContext context, List<dynamic> data, int selectedRowIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete?'),
          actions: [
            TextButton(
              onPressed: () {
                // Perform cancel action
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: selectedRowIndex != -1
                  ? () {
                // Perform the action for the delete button
                Map<String, dynamic> selectedEmployeeData =
                data[selectedRowIndex].data() as Map<String, dynamic>;
                String selectedEmployeeId = selectedEmployeeData['id'];

                // Delete the selected row data from Firebase
                firestore.collection('empty_cylinder').doc(selectedEmployeeId).delete().then((value) {
                  // Row data deleted successfully
                  setState(() {
                    data.removeAt(selectedRowIndex); // Remove the selected row from the local data list
                    selectedRowIndex = -1; // Reset the selected row index
                  });

                  // Close the dialog
                  Navigator.of(context).pop();
                }).catchError((error) {
                  // Error occurred while deleting row data
                  print('Error deleting row data: $error');
                });
              }
                  : null,
              child: Text('Delete'),
            ),

          ],
        );
      },
    );
  }

}


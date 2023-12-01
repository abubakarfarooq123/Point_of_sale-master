import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';
import 'package:pos/warehouse/add_warehouse.dart';

import '../splashScreens/loginout.dart';

enum MenuItem {
  item1,
  item2,
}

class Warehouse extends StatefulWidget {
  const Warehouse({Key? key}) : super(key: key);

  @override
  State<Warehouse> createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore.collection('warehouse').get();
    return snapshot.docs;
  }
  bool isisRowSelected = false;
  int selectedRowIndex = -1; // Track the index of the selected row


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Warehouse",
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
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<DocumentSnapshot> data = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          padding: const EdgeInsets.only(left: 10),
                          child: InkWell(
                            onTap: (){
                              showEditProfileDetailDialog(context, data[selectedRowIndex]);
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: selectedRowIndex != -1 ? Colors.grey : Colors.grey.withOpacity(0.5),
                              ),
                              child: Icon(
                                FontAwesomeIcons.eye,
                                color: Colors.white,
                                size: 18,
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
                                color: selectedRowIndex != -1 ? Colors.red : Colors.grey.withOpacity(0.5),
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
                                color: selectedRowIndex != -1 ? Colors.blue : Colors.grey.withOpacity(0.5),
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
                                color: selectedRowIndex != -1 ? Colors.blue : Colors.grey.withOpacity(0.5),
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
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 30,
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
                            'Name',
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Address',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Phone',
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'City',
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Total Cost',
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                      rows: List<DataRow>.generate(data.length, (index) {
                        Map<String, dynamic> employeeData =
                        data[index].data() as Map<String, dynamic>;
                        String name = employeeData['item'];
                        String phone = employeeData['phone'];
                        String addres = employeeData['addres'];
                        String city = employeeData['city'];
                        String cost = employeeData['cost'];

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
                            DataCell(Text(name)),
                            DataCell(Text(addres)),
                            DataCell(Text(phone)),
                            DataCell(Text(city)),
                            DataCell(Text(cost)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Add_Warehouse()));
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
                firestore.collection('warehouse').doc(selectedEmployeeId).delete().then((value) {
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
  // Widget buildTransactionsTab(String customerId) {
  //   Future<List<DocumentSnapshot>> fetchSalesDataForCustomer(
  //       String customerId) async {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('Purchase')
  //         .where('warehouse', isEqualTo: customerId)
  //         .get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       String matchingDocumentId = querySnapshot.docs.first.id; // Get the document ID of the matched document
  //       // Access the 'details' subcollection within the matched document
  //       QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance
  //           .collection('Purchase')
  //           .doc(matchingDocumentId)
  //           .collection('details')
  //           .get();
  //
  //       return subcollectionSnapshot.docs;
  //     } else {
  //       return []; // Return an empty list if no matching document is found
  //     }
  //   }
  //
  //
  //   Future<List<DocumentSnapshot>> fetchPaymentForCustomer(
  //       String customerId) async {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('Corn')
  //         .where('warehouse', isEqualTo: customerId)
  //         .get();
  //
  //     return querySnapshot.docs;
  //   }
  //
  //   Future<List<DocumentSnapshot>> fetchAdditionalDataForCustomer(
  //       String customerId) async {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('cylinder')
  //         .where('warehouse', isEqualTo: customerId)
  //         .get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       String matchingDocumentId = querySnapshot.docs.first.id; // Get the document ID of the matched document
  //       // Access the 'details' subcollection within the matched document
  //       QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance
  //           .collection('cylinder')
  //           .doc(matchingDocumentId)
  //           .collection('details')
  //           .get();
  //
  //       return subcollectionSnapshot.docs;
  //     } else {
  //       return []; // Return an empty list if no matching document is found
  //     }
  //   }
  //
  //   Future<List<DocumentSnapshot>> fetchemptycylinder(
  //       String customerId) async {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('empty_cylinder')
  //         .where('warehouse', isEqualTo: customerId)
  //         .get();
  //
  //     return querySnapshot.docs;
  //   }
  //   return FutureBuilder<List<List<DocumentSnapshot>>>(
  //     future: Future.wait([
  //       fetchSalesDataForCustomer(customerId),
  //       fetchPaymentForCustomer(customerId),
  //       fetchAdditionalDataForCustomer(customerId), // Fetch additional data
  //       fetchemptycylinder(customerId),
  //     ]),
  //     builder: (context, snapshots) {
  //       if (snapshots.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshots.hasError || snapshots.data == null) {
  //         return Center(child: Text('No Sales and Payments Data Available'));
  //       } else {
  //         List<DocumentSnapshot> salesData = snapshots.data![0];
  //         List<DocumentSnapshot> paymentsData = snapshots.data![1];
  //         List<DocumentSnapshot> additionalData = snapshots.data![2]; // Additional data
  //         List<DocumentSnapshot> emptyData = snapshots.data![3]; // Additional data
  //
  //         List<Map<String, dynamic>> tableData = [];
  //
  //         salesData.forEach((transactionData) {
  //           var transactionAmount = transactionData['Item'];
  //           var transactionDate = transactionData['Quantity'];
  //
  //           tableData.add({
  //             'Date': transactionDate,
  //             'Sale': 'Rs. ${transactionAmount.toString()}',
  //            });
  //
  //           paymentsData.forEach((transactionData) {
  //             var transactionAmount = transactionData['item'];
  //             var transactionDate = transactionData['total_quantity'];
  //
  //             tableData.add({
  //               'Date': transactionDate,
  //               'Sale': 'Rs. ${transactionAmount.toString()}',
  //             });
  //           });
  //
  //         });
  //
  //         // Process additionalData similarly to salesData and paymentsData
  //         additionalData.forEach((transactionData) {
  //           var transactionAmount = transactionData['Item'];
  //           var transactionDate = transactionData['Quantity'];
  //
  //           tableData.add({
  //             'Date': transactionDate,
  //             'Sale': 'Rs. ${transactionAmount.toString()}',
  //           });
  //
  //           emptyData.forEach((transactionData) {
  //             var transactionAmount = transactionData['cylinder'];
  //             var transactionDate = transactionData['quantity'];
  //
  //             tableData.add({
  //               'Date': transactionDate,
  //               'Sale': 'Rs. ${transactionAmount.toString()}',
  //             });
  //           });
  //         });
  //
  //         return SingleChildScrollView(
  //           child: Container(
  //             decoration: BoxDecoration(
  //               border: Border.all(color: Colors.blue),
  //             ),
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: DataTable(
  //                 headingRowColor:
  //                 MaterialStateColor.resolveWith((states) => Colors.blue),
  //                 dataRowColor:
  //                 MaterialStateColor.resolveWith((states) => Colors.white),
  //                 columns: [
  //                   DataColumn(
  //                     label: Text('Date', style: TextStyle(color: Colors.white)),
  //                   ),
  //                   DataColumn(
  //                     label: Text('Sale', style: TextStyle(color: Colors.white)),
  //                   ),
  //
  //                 ],
  //                 rows: tableData.map((rowData) {
  //                   return DataRow(cells: [
  //                     DataCell(Text(rowData['Date'])),
  //                     DataCell(
  //                       Text(
  //                         rowData['Sale'],
  //                         style: TextStyle(
  //                           color:
  //                           rowData['Sale'].startsWith('-') ? Colors.red : Colors.black,
  //                         ),
  //                       ),
  //                     ),
  //                   ]);
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  // Widget buildTransactionsTab(String customerId) {
  //   Future<Map<String, int>> fetchItemQuantitiesForCustomer(
  //       String customerId) async {
  //     QuerySnapshot purchaseSnapshot = await FirebaseFirestore.instance
  //         .collection('Purchase')
  //         .where('warehouse', isEqualTo: customerId)
  //         .get();
  //
  //     Map<String, int> itemQuantities = {};
  //
  //     for (QueryDocumentSnapshot purchaseDoc in purchaseSnapshot.docs) {
  //       // Access the 'details' subcollection
  //       QuerySnapshot detailsSnapshot = await FirebaseFirestore.instance
  //           .collection('Purchase')
  //           .doc(purchaseDoc.id) // Access the specific purchase document
  //           .collection('details')
  //           .get();
  //
  //       for (QueryDocumentSnapshot itemDoc in detailsSnapshot.docs) {
  //         String itemName = itemDoc['Item'];
  //         int itemQuantity = int.parse(itemDoc['Quantity']);
  //
  //         // Use null-aware operators to update or initialize the item quantity in the map
  //         itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) + itemQuantity;
  //       }
  //     }
  //
  //     return itemQuantities;
  //   }
  //
  //   return FutureBuilder<Map<String, int>>(
  //     future: fetchItemQuantitiesForCustomer(customerId),
  //     builder: (context, itemQuantitiesSnapshot) {
  //       if (itemQuantitiesSnapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (itemQuantitiesSnapshot.hasError ||
  //           itemQuantitiesSnapshot.data == null) {
  //         return Center(child: Text('No Data Available'));
  //       } else {
  //         Map<String, int>? itemQuantities = itemQuantitiesSnapshot.data;
  //
  //         List<Map<String, dynamic>> tableData = [];
  //
  //         itemQuantities?.forEach((itemName, itemQuantity) {
  //           tableData.add({
  //             'Item Name': itemName,
  //             'Quantity': itemQuantity.toString(),
  //           });
  //         });
  //
  //         return SingleChildScrollView(
  //           child: Container(
  //             decoration: BoxDecoration(
  //               border: Border.all(color: Colors.blue),
  //             ),
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: DataTable(
  //                 headingRowColor: MaterialStateColor.resolveWith(
  //                         (states) => Colors.blue),
  //                 dataRowColor:
  //                 MaterialStateColor.resolveWith((states) => Colors.white),
  //                 columns: [
  //                   DataColumn(
  //                     label: Text('Item Name',
  //                         style: TextStyle(color: Colors.white)),
  //                   ),
  //                   DataColumn(
  //                     label: Text('Quantity',
  //                         style: TextStyle(color: Colors.white)),
  //                   ),
  //                 ],
  //                 rows: tableData.map((rowData) {
  //                   return DataRow(cells: [
  //                     DataCell(Text(rowData['Item Name'])),
  //                     DataCell(Text(rowData['Quantity'])),
  //                   ]);
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }


  Widget buildTransactionsTab(String customerId) {
    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchSalesDataForCustomer(
        String customerId) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Purchase')
          .where('warehouse', isEqualTo: customerId)
          .get();

      List<DocumentSnapshot> documents = querySnapshot.docs;

      List<QueryDocumentSnapshot<Map<String, dynamic>>> detailsData = [];

      for (var document in documents) {
        QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance
            .collection('Purchase')
            .doc(document.id)
            .collection('details') // Subcollection name
            .get();

        // Cast each document to the correct type and add it to the detailsData list
        detailsData.addAll(subcollectionSnapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>());
      }

      return detailsData;
    }
    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchcylinder(
        String customerId) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cylinder')
          .where('warehouse', isEqualTo: customerId)
          .get();

      List<DocumentSnapshot> documents = querySnapshot.docs;

      List<QueryDocumentSnapshot<Map<String, dynamic>>> detailsData = [];

      for (var document in documents) {
        QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance
            .collection('cylinder')
            .doc(document.id)
            .collection('details') // Subcollection name
            .get();

        // Cast each document to the correct type and add it to the detailsData list
        detailsData.addAll(subcollectionSnapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>());
      }

      return detailsData;
    }

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchCorn(
        String customerId) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Corn') // Change to 'corn' collection
          .where('warehouse', isEqualTo: customerId)
          .get();

      return querySnapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
    }


    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchempty(
        String customerId) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('empty_cylinder') // Change to 'corn' collection
          .where('warehouse', isEqualTo: customerId)
          .get();

      return querySnapshot.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
    }

    return FutureBuilder<List<List<QueryDocumentSnapshot<Map<String, dynamic>>>>>(
      // Use Future.wait to combine the results of both functions
      future: Future.wait([
        fetchSalesDataForCustomer(customerId),
        fetchcylinder(customerId),
        fetchCorn(customerId),
        fetchempty(customerId),
      ]),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshots.hasError || snapshots.data == null) {
          return Center(child: Text('No Sales and Payments Data Available'));
        } else {

          List<DocumentSnapshot> salesData = snapshots.data![0];
          List<DocumentSnapshot> cylinderData = snapshots.data![1];

          List<DocumentSnapshot> cornData = snapshots.data![2];
          List<DocumentSnapshot> emptyData = snapshots.data![3];

          List<Map<String, dynamic>> tableData = [];

          salesData.forEach((transactionData) {
            var transactionAmount = transactionData['Item'].toString(); // Convert to String
            var transactionDate = transactionData['Quantity'].toString(); // Convert to String
            var rate = transactionData['Rate'].toString(); // Convert to String
            var totalAmount = transactionData['Subtotal'].toString(); // Convert to String
            var grandAmount = transactionData['Grandtotal'].toString(); // Convert to String

            tableData.add({
              'Item': transactionAmount,
              'Quantity': '$transactionDate',
              'Rate': rate,
              'Subtotal': totalAmount,
              'grand': grandAmount,
            });
          });
          cylinderData.forEach((transactionData) {
            var transactionAmount = transactionData['Item'].toString(); // Convert to String
            var transactionDate = transactionData['Quantity'].toString(); // Convert to String
            var totalAmount = transactionData['Per'].toString(); // Convert to String
            var grandAmount = transactionData['total'].toString(); // Convert to String

            tableData.add({
              'Item': transactionAmount,
              'Quantity': '$transactionDate',
              'Rate': '',
              'Subtotal': totalAmount,
              'grand': grandAmount,
            });

          });

          cornData.forEach((transactionData) {
            var transactionAmount = transactionData['Item'].toString(); // Convert to String
            var transactionDate = transactionData['Quantity'].toString(); // Convert to String
            var rate = transactionData['price'].toString(); // Convert to String
            var grandAmount = transactionData['grand'].toString(); // Convert to String

            tableData.add({
              'Item': transactionAmount,
              'Quantity': '$transactionDate',
              'Rate': rate,
              'Subtotal': '',
              'grand': grandAmount,
            });

          });

          emptyData.forEach((transactionData) {
            var transactionAmount = transactionData['Item'].toString(); // Convert to String
            var transactionDate = transactionData['Quantity'].toString(); // Convert to String
            var rate = transactionData['today_amount'].toString(); // Convert to String
            var grandAmount = transactionData['total'].toString(); // Convert to String

            tableData.add({
              'Item': transactionAmount,
              'Quantity': '$transactionDate',
              'Rate': rate,
              'Subtotal': '',
              'grand': grandAmount,
            });

          });


          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.blue),
                  dataRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.white),
                  columns: [
                    DataColumn(
                      label: Text('Item', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Quantity', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Rate', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Sub Total', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Grand Total', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  rows: tableData.map((rowData) {
                    return DataRow(cells: [
                      DataCell(Text(rowData['Item'])),
                      DataCell(Text(rowData['Quantity'])),
                      DataCell(Text(rowData['Rate'])),
                      DataCell(Text(rowData['Subtotal'])),
                      DataCell(Text(rowData['grand'])),

                    ]);
                  }).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }





  void showEditProfileDetailDialog(BuildContext context, dynamic customerData) {
    String name = customerData['item'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: AlertDialog(

              title: Container(
                height: 50,
                width: 320,
                child: Stack(
                  children: [
                    Positioned(
                      left: 5,
                      top: 10,
                      child: Text('${name} Details',style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    SizedBox(
                      width: 83,
                    ),
                    Positioned(
                      right: 5,
                      child: IconButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.clear,size: 32,)),
                    )
                  ],
                ),
              ),
              content: Column(
                children: [
                  buildTransactionsTab(customerData['item']),
              ],
              ),
            ),
          );
      },
    );
  }



}







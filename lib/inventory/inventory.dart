import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';

import '../splashScreens/loginout.dart';

enum MenuItem {
  item1,
  item2,
}

class Inventory extends StatefulWidget {
  const Inventory({Key? key}) : super(key: key);

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore.collection('Product').get();
    return snapshot.docs;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Object?> getValuesFromFirebase() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('Product')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return {}; // Default empty map if the document doesn't exist
  }

  Future<List<Map<String, dynamic>>> getProductsFromFirebase(List<String> inventoryProductIDs) async {
    List<Map<String, dynamic>> products = [];
    QuerySnapshot productSnapshot = await _firestore.collection('Product').get();

    for (QueryDocumentSnapshot doc in productSnapshot.docs) {
      Map<String, dynamic> productData = doc.data() as Map<String, dynamic>;

      // Assuming there's a 'productID' field in your Product data
      String productID = productData['id'];

      // Check if the productID exists in the Inventory's product IDs
      if (inventoryProductIDs.contains(productID)) {
        products.add(productData);
        print('Added product with productID: $productID'); // Add this line to print the productID
      }
    }

    return products;
  }


  bool radioButtonValue = false;
  bool showMinMaxDropdowns = false;
  String? selectedValue;

  String? selectedCategoryId;
  String? selectedBrandId;

  bool isisRowSelected = false;
  int selectedRowIndex = -1; // Track the index of the selected row

  var name = "";
  var sku = "";
  var restoke = "";
  var retail = "";
  var wholesale = "";
  var descript = "";
  var parchoon = "";

  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final restokeController = TextEditingController();
  final retailController = TextEditingController();
  final wholesaleController = TextEditingController();
  final descriptController = TextEditingController();
  final parchoonController = TextEditingController();

  void initState() {
    super.initState();
    // Call a function to listen for new customer additions
    fetchEmployeeData();
    getValuesFromFirebase().then((values) {
      setState(() {
        Map<String, dynamic> data = values as Map<String, dynamic>;
        nameController.text = data['item'] ?? '';
        skuController.text = data['sku']?.toString() ?? '';
        wholesaleController.text = data['wholesale'] ?? '';
        retailController.text = data['retail']?.toString() ?? '';
        parchoonController.text = data['parchoonval']?.toString() ?? '';
        descriptController.text = data['des']?.toString() ?? '';
        restokeController.text = data['restoke']?.toString() ?? '';
        selectedCategoryId = data['category']?.toString() ?? '';
        selectedBrandId = data['brand']?.toString() ?? '';
        // Update other controller values as needed
      });
    });
  }



  Future<List<String>> getProductIDsFromInventory() async {
    List<String> productIDs = [];


    QuerySnapshot purchaseQuerySnapshot = await FirebaseFirestore.instance
        .collection('Inventory')
        .get();

    for (QueryDocumentSnapshot purchaseDoc in purchaseQuerySnapshot.docs) {
      // Here, you can add the user-specific filter for 'Purchase' documents
      // based on the user's ID or other criteria.

      QuerySnapshot subcollectionQuery = await FirebaseFirestore.instance
          .collection('Inventory')
          .doc(purchaseDoc.id)
          .collection('items') // Replace 'details' with the actual subcollection name
          .get();

      // Now, you can add the documents from the 'details' subcollection to your list.
      for (QueryDocumentSnapshot subDoc in subcollectionQuery.docs) {
        String productID = (subDoc.data() as Map<String, dynamic>)['productID'] as String;
        productIDs.add(productID);
        print(subDoc.data());
      }
    }

    return productIDs;
  }



  double totalCostValue = 0;
  double totalSaleValue = 0;
  double totalWholesaleValue = 0;
  double totalParchoonValue = 0;

// Generate rows and calculate column totals

    @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Inventory",
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
        child: FutureBuilder(
            future: getProductIDsFromInventory(),
            builder: (context, inventorySnapshot) {
              if (inventorySnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (inventorySnapshot.hasError) {
                return Text('Error: ${inventorySnapshot.error}');
              } else {
                List<String> inventoryProductIDs = inventorySnapshot.data as List<String>;

                return FutureBuilder(
                    future: getProductsFromFirebase(inventoryProductIDs),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (productSnapshot.hasError) {
                        return Text('Error: ${productSnapshot.error}');
                      } else {
                        List<Map<String, dynamic>> data = productSnapshot.data as List<Map<String, dynamic>>;

                        // Here, you should have the productData ready to use in your DataTable.



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
                                        borderSide:
                                        BorderSide(color: Colors.black)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide:
                                        BorderSide(color: Colors.black)),
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
                                  showEditProfileDetailDialog(
                                      context, data[selectedRowIndex]);
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: selectedRowIndex != -1
                                        ? Colors.grey
                                        : Colors.grey.withOpacity(0.5),
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
                              padding: const EdgeInsets.only(
                                left: 10,
                              ),
                              child: InkWell(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.blue),
                                  child: Icon(
                                    FontAwesomeIcons.filePdf,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                              ),
                              child: InkWell(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.blue),
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
                                'Product',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Stock Availability',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Cost Value',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Sale Value',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'WholeSale Value',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Parchoon Value',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(data.length, (index) {
                            Map<String, dynamic> employeeData = data[index];
                            String name = employeeData['item'];
                            String brand = employeeData['brand'];
                            String category = employeeData['category'];
                            String sku = employeeData['sku'];
                            String rate = employeeData['rate'].toString();

                            dynamic unitData = employeeData['unit'];

                            String unit;


                            if (unitData is List<dynamic>) {
                              unit = unitData.join(', ');
                            } else if (unitData is String) {
                              unit = unitData;
                            } else {
                              unit = '';
                            }
                            String quantity = employeeData['quantity']
                                .toString();

                            Map<String,
                                dynamic> simpleValues = employeeData['simple_values'] ??
                                {};


                            String unit1Data = '';

                            if (unitData is List<dynamic> &&
                                unitData.length > 1) {
                              unit1Data = unitData[1].toString();
                            }
                            double quantityqqq = double.parse(
                                employeeData['quantity']);


                            double costValue = double.parse(rate) * quantityqqq;
                            double saleValue = simpleValues[unit1Data]['retail'] *
                                quantityqqq;
                            double wholesaleValue = simpleValues[unit1Data]['wholesale'] *
                                quantityqqq;
                            double parchoonValue = simpleValues[unit1Data]['parchoonval'] *
                                quantityqqq;

                            // Update column totals
                            totalCostValue += costValue;
                            totalSaleValue += saleValue;
                            totalWholesaleValue += wholesaleValue;
                            totalParchoonValue += parchoonValue;


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
                                DataCell(Text(name ?? '')),

                                DataCell(Text(quantity ?? '')),
                                DataCell(Text((double.parse(rate) * quantityqqq)
                                    .toString() ?? '')),
                                DataCell(Text(
                                    (simpleValues[unit1Data]['retail'] *
                                        quantityqqq).toString() ?? '')),
                                DataCell(Text(
                                    (simpleValues[unit1Data]['wholesale'] *
                                        quantityqqq).toString() ?? '')),
                                DataCell(Text(
                                    (simpleValues[unit1Data]['parchoonval'] *
                                        quantityqqq).toString() ?? '')),

                              ],


                            );
                          }
                          ).toList()
                            ..add(
                              DataRow(
                                color: MaterialStateColor.resolveWith((states) {
                                  return Colors.grey.withOpacity(
                                      0.5); // Set the background color to grey for the total quantity row
                                }),
                                cells: [
                                  DataCell(Text('Total:')),
                                  DataCell(Text('')),
                                  // Empty cell for the second column
                                  DataCell(Text(totalCostValue.toString())),
                                  // Use the appropriate total variable here
                                  DataCell(Text(totalSaleValue.toString())),
                                  DataCell(
                                      Text(totalWholesaleValue.toString())),
                                  DataCell(Text(totalParchoonValue.toString())),
                                ],
                              ),
                            ),

                          dataRowColor: MaterialStateColor.resolveWith((
                              states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.grey.withOpacity(0.5);
                            }
                            return Colors.transparent;
                          }),

                        ),

                      ),
                    ],
                  );
                }
              }
          );
        }
      }
      )
      ),

    );
  }

  Widget buildTransactionsTab(String customerId) {
    Future<List<DocumentSnapshot>> fetchSalesDataForCustomer(String customerId) async {
      try {
        List<DocumentSnapshot> detailDocuments = [];

        QuerySnapshot purchaseQuerySnapshot = await FirebaseFirestore.instance
            .collection('Inventory')
            .get();

        for (var purchaseDoc in purchaseQuerySnapshot.docs) {
          QuerySnapshot subcollectionQuery = await FirebaseFirestore.instance
              .collection('Inventory')
              .doc(purchaseDoc.id)
              .collection('items')
              .where('productID', isEqualTo: customerId)
              .get();

          detailDocuments.addAll(subcollectionQuery.docs);

          // After adding documents to detailDocuments, check if quantity is zero
          // If yes, delete the empty subcollection
          for (var subDoc in subcollectionQuery.docs) {
            var quantity = subDoc['quantitytominus']; // Assuming 'Quantity' is the field with quantity
            if (quantity == 0) {
              await deleteEmptySubcollection('Inventory', purchaseDoc.id, 'items');
              break; // Exit the loop after deleting the subcollection
            }
          }
        }

        return detailDocuments;
      } catch (e) {
        print('Error fetching data: $e');
        throw e; // You can handle the error as needed in your application
      }
    }



    return FutureBuilder<List<List<DocumentSnapshot>>>(
      future: Future.wait([
        fetchSalesDataForCustomer(customerId),
      ]),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshots.hasError || snapshots.data == null) {
          return Center(child: Text('No Sales and Payments Data Available'));
        } else {
          List<DocumentSnapshot> salesData = snapshots.data![0];

          List<Map<String, dynamic>> tableData = [];

          salesData.forEach((transactionData) {
            var transactionAmount = transactionData['Item'];
            var transactionDate = transactionData['Quantity'];
            var tenderedAmount = transactionData['Rate'];
            var date = transactionData['date'];
            var remain = transactionData['sell'];

            tableData.add({
              'date': date,
              'Item': transactionAmount,
              'Quantity': '$transactionDate',
              'remain': '$remain',
              'Rate': tenderedAmount,
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
                      label:
                      Text('Added', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label:
                      Text('Item', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Unit Price', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label:
                      Text('Total', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label:
                      Text('Available', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label:
                      Text('Cost', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  rows: tableData.map((rowData) {

                    double cost = 0.0;
                    var rate = double.tryParse(rowData['Rate']?.replaceAll(',', '') ?? '') ?? 0.0;
                    var remain = double.tryParse(rowData['remain']?.replaceAll(',', '') ?? '') ?? 0.0;
                    var quantity = double.tryParse(rowData['Quantity']?.replaceAll(',', '') ?? '') ?? 0.0;


                    if (rowData['remain'] != '0.0') {
                      cost = rate * remain;
                    } else {
                      cost = rate * quantity;
                    }

                    return DataRow(cells: [
                      DataCell(Text(rowData['date'])),
                      DataCell(
                        Text(
                          rowData['Item'].toString(),
                        ),
                      ),
                      DataCell(
                        Text(
                          rowData['Rate'].toString(),

                        ),
                      ),
                      DataCell(
                        Text(
                          rowData['Quantity'].toString(),
                        ),
                      ),
                      DataCell(Text((rowData['remain'] != "" ?rowData['remain'] : rowData['Quantity']).toString())),
                      DataCell(Text(cost.toStringAsFixed(2))),
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


  Future<void> deleteEmptySubcollection(String parentCollection, String parentDocument, String subcollectionName) async {
    try {
      QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance
          .collection(parentCollection)
          .doc(parentDocument)
          .collection(subcollectionName)
          .get();

      if (subcollectionSnapshot.docs.isEmpty) {
        // Subcollection is empty, delete it
        await FirebaseFirestore.instance
            .collection(parentCollection)
            .doc(parentDocument)
            .collection(subcollectionName)
            .doc()
            .delete();

        print('Subcollection "$subcollectionName" deleted.');
      }
    } catch (e) {
      print('Error deleting subcollection: $e');
      // Handle the error as needed in your application
    }
  }


  void showEditProfileDetailDialog(BuildContext context, dynamic customerData) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: AlertDialog(
              title: Container(
                height: 40,
                width: 320,
                child: Stack(
                  children: [
                    Positioned(
                      left: 5,
                      top: 10,
                      child: Text(
                        "${customerData['item']}",style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 83,
                    ),
                    Positioned(
                      right: 5,
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.clear,
                            size: 32,
                          )),
                    )
                  ],
                ),
              ),
              content:
                        Column(
                          children: [

                            SingleChildScrollView(
                              child: Container(
                                  height: 300,
                                  child: buildTransactionsTab(
                                      customerData['id'] ?? '')),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),

                  ),

          );
      },
    );
  }
}

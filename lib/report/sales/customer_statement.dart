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

class Customer_statement_Report extends StatefulWidget {
  const Customer_statement_Report({super.key});

  @override
  State<Customer_statement_Report> createState() =>
      _Customer_statement_ReportState();
}

class _Customer_statement_ReportState extends State<Customer_statement_Report> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore
        .collection('Sales')
        .orderBy('purchase', descending: true)
        .get();
    return snapshot.docs;
  }

  String calculateTotalInvoices(List<DocumentSnapshot> data) {
    double totalInvoices = 0.0;
    for (final document in data) {
      Map<String, dynamic> employeeData =
          document.data() as Map<String, dynamic>;
      totalInvoices += employeeData['grand'];
    }
    return totalInvoices.toString();
  }

  String calculateTotalprofit(List<DocumentSnapshot> data) {
    double totalInvoices = 0.0;
    for (final document in data) {
      Map<String, dynamic> employeeData =
          document.data() as Map<String, dynamic>;
      totalInvoices += employeeData['due'];
    }
    return totalInvoices.toString();
  }

  String calculateTotalCount(List<DocumentSnapshot> data) {
    int totalInvoices = 0;
    for (final document in data) {
      Map<String, dynamic> employeeData =
          document.data() as Map<String, dynamic>;
      totalInvoices = employeeData['purchase'];
    }
    return totalInvoices.toString();
  }

  SupplierModel? selectedSupplier;

  List<Map<String, dynamic>> filteredData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Customer Statement",
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 22,
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
                        padding: const EdgeInsets.only(left: 100, top: 20),
                        child: Text(
                          "Jawad & Brothers",
                          style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          "Select Customer:",
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, top: 10, bottom: 20),
                              child: Container(
                                width: 330,
                                height: 60,
                                padding: EdgeInsets.only(left: 16, right: 0),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('customer')
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    List<SupplierModel> unitItems = [];
                                    snapshot.data?.docs.forEach((doc) {
                                      String docId = doc.id;
                                      String title = doc['name'];
                                      unitItems
                                          .add(SupplierModel(docId, title));
                                    });

                                    return DropdownButton<SupplierModel>(
                                      iconSize: 40,
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      hint: Text('Select Customer'),
                                      value: selectedSupplier,
                                      items: unitItems.map((unit) {
                                        return DropdownMenuItem<SupplierModel>(
                                          value: unit,
                                          child: Text(unit.s_name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSupplier = value;
                                          filteredData = data
                                              .map((doc) => doc.data()
                                                  as Map<String, dynamic>)
                                              .where((employeeData) =>
                                                  employeeData['customer'] ==
                                                  selectedSupplier!.s_name)
                                              .toList();

                                          print(
                                              'The selected unit ID is ${selectedSupplier?.s_id}');
                                          print(
                                              'The selected unit title is ${selectedSupplier?.s_name}');
                                          // Perform further operations with the selected unit
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedSupplier != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 120),
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width/1.75,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        selectedSupplier!.s_name,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            selectedSupplier = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      SizedBox(
                        height: 20,
                      ),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: DataTable(
                      //     columnSpacing: 45,
                      //     headingRowColor: MaterialStateColor.resolveWith(
                      //           (states) {
                      //         return Colors.blue;
                      //       },
                      //     ),
                      //     dividerThickness: 3,
                      //     showBottomBorder: true,
                      //     columns: [
                      //       DataColumn(
                      //         label: Text(
                      //           'Sale #',
                      //           style: GoogleFonts.roboto(
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //       DataColumn(
                      //         label: Text(
                      //           'Customer',
                      //           style: GoogleFonts.roboto(
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //       DataColumn(
                      //         label: Text(
                      //           'Sub Total',
                      //           style: GoogleFonts.roboto(
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //       DataColumn(
                      //         label: Text(
                      //           'Grand Total',
                      //           style: GoogleFonts.roboto(
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //       DataColumn(
                      //         label: Text(
                      //           'Paid',
                      //           style: GoogleFonts.roboto(
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //       DataColumn(
                      //         label: Text(
                      //           'Due',
                      //           style: GoogleFonts.roboto(
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //     rows: List<DataRow>.generate(filteredData.length, (index) {
                      //       // Use filteredData instead of the original data
                      //       Map<String, dynamic> employeeData = filteredData[index];
                      //       String purchase =
                      //       employeeData['purchase'].toString();
                      //       String supplier =
                      //       employeeData['customer'].toString();
                      //       double subtotal = employeeData['subtotal'];
                      //       double grandtotal = employeeData['grand'];
                      //       String paid = employeeData['tender'].toString();
                      //       double due = employeeData['final'];
                      //       return DataRow(
                      //         cells: [
                      //           DataCell(Text(
                      //             "Sale# ${purchase}",
                      //             style: GoogleFonts.poppins(),
                      //           )),
                      //           DataCell(Text(supplier)),
                      //           DataCell(Text(subtotal.toStringAsFixed(2))),
                      //           DataCell(Text(grandtotal.toStringAsFixed(2))),
                      //           DataCell(Text(paid)),
                      //           DataCell(Text(due.toStringAsFixed(2))),
                      //         ],
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),

                      if (selectedSupplier != null &&
                          selectedSupplier!.s_name != null)
                        buildTransactionsTab(selectedSupplier!.s_name)
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  String iditem='';

  Widget buildTransactionsTab(String customerId) {
    Future<List<DocumentSnapshot>> fetchSalesDataForCustomer(
        String customerId) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Sales')
          .where('customer', isEqualTo: customerId)
          .get();

      return querySnapshot.docs;
    }

    Future<List<DocumentSnapshot>> fetchPaymentForCustomer(
        String customerId) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('customer')
          .where('name', isEqualTo: customerId)
          .get();

      return querySnapshot.docs;
    }

    Future<List<DocumentSnapshot>> fetchAdditionalDataForCustomer(
        String customerId) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Corn') // Replace with your actual collection name
          .where('supplier', isEqualTo: customerId)
          .get();

      return querySnapshot.docs;
    }

    return FutureBuilder<List<List<DocumentSnapshot>>>(
      future: Future.wait([
        fetchSalesDataForCustomer(customerId),
        fetchPaymentForCustomer(customerId),
        fetchAdditionalDataForCustomer(customerId), // Fetch additional data
      ]),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshots.hasError || snapshots.data == null) {
          return Center(child: Text('No Sales and Payments Data Available'));
        } else {
          List<DocumentSnapshot> salesData = snapshots.data![0];
          List<DocumentSnapshot> paymentsData = snapshots.data![1];
          List<DocumentSnapshot> additionalData =
              snapshots.data![2]; // Additional data

          List<dynamic> tableData = [];

          additionalData.forEach((additionalTransactionData) {
            var additionalTransactionAmount =
                additionalTransactionData['grand'];
            var additionalTransactionDate =
                additionalTransactionData['pickdate'];
            var additionalTenderedAmount = additionalTransactionData['paid'];
            double remaining = additionalTransactionData['remaining'];

            tableData.add({
              'type': "",
              'Date': additionalTransactionDate,
              'Sale': 'Rs. $additionalTransactionAmount',
              'Get': '',
              'Gave': remaining.toString(),
              'previous': ''
            });

            tableData.add({
              'type': "",
              'Date': additionalTransactionDate,
              'Sale': '',
              'Get': 'Rs. $additionalTenderedAmount',
              'Gave': remaining.toString(),
              'previous': '',
            });

            // Add any other processing specific to the additional data here
          });
          paymentsData.forEach((paymentdata) {
            for (var reverseEntry in paymentdata['receive']) {
              tableData.add({
                'type': "Payment In",
                'Date': reverseEntry['date'].toString(),
                'Sale': "---",
                'Get': reverseEntry['amount'].toString(),
                'Gave': "---",
                'previous': reverseEntry['newbalnce'].toString(),
              });
            }

            for (var reverseEntry in paymentdata['reverse']) {
              tableData.add({
                'type': "Payment Out",
                'Date': reverseEntry['date'].toString(),
                'Sale': reverseEntry['amount'].toString(),
                'Get': '---',
                'Gave': '---',
                'previous': reverseEntry['newbalnce'].toString(),
              });
            }
          });
          salesData.forEach((transactionData) {
            iditem = transactionData['id'];
            print("objectiditem $iditem");
            double transactionAmount = transactionData['grand'];
            var transactionDate = transactionData['pickdate'];
            var tenderedAmount = transactionData['tender'];
            double finalAmount = transactionData['final'];
            String previsusus = transactionData['after'];
            double previousValue = double.parse(previsusus);

            tableData.add({
              'type': "buildSalesTable",
              'Date': transactionDate,
              'Sale': 'Rs. ${transactionAmount.toStringAsFixed(1)}',
              'Get': 'Rs. $tenderedAmount',
              'Gave': finalAmount.toStringAsFixed(1),
              'previous': previousValue.toStringAsFixed(1) ??
                  '', // Update 'previous' with the found value
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
                dataRowHeight: 300,
                headingRowColor:
                    MaterialStateColor.resolveWith((states) => Colors.blue),
                dataRowColor:
                    MaterialStateColor.resolveWith((states) => Colors.white),
                columns: [
                  DataColumn(
                    label: Text('Type', style: TextStyle(color: Colors.white)),
                  ),
                  DataColumn(
                    label: Text('Date', style: TextStyle(color: Colors.white)),
                  ),
                  DataColumn(
                    label: Text('Total', style: TextStyle(color: Colors.white)),
                  ),
                  DataColumn(
                    label: Text('Receiving',
                        style: TextStyle(color: Colors.white)),
                  ),
                  DataColumn(
                    label: Text('Invoice Due',
                        style: TextStyle(color: Colors.white)),
                  ),
                  DataColumn(
                    label:
                        Text('Balance', style: TextStyle(color: Colors.white)),
                  ),
                ],
                rows: tableData.map((rowData) {
                  if (rowData['type'] == "buildSalesTable") {
                    return DataRow(cells: [
                      DataCell(rowData['type'] is Widget
                          ? rowData['type']
                          : buildSalesTable(iditem)),
                      DataCell(Text(rowData['Date'].toString())),
                      DataCell(
                        Text(
                          rowData['Sale'],
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          rowData['Get'],
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          rowData['Gave'],
                          style: TextStyle(
                            color: rowData['Gave'].startsWith('-')
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ),
                      DataCell(Text(rowData['previous'].toString())),
                    ]);
                  } else {
                    return DataRow(cells: [
                      DataCell(Text(rowData['type'])),
                      DataCell(Text(rowData['Date'].toString())),
                      DataCell(Text(rowData['Sale'])),
                      DataCell(Text(rowData['Get'])),
                      DataCell(Text(rowData['Gave'])),
                      DataCell(Text(rowData['previous'].toString())),
                    ]);
                  }
                }).toList(),
              ),
            ),
          ));
        }
      },
    );
  }

  String purchase ='';
  Widget buildSalesTable(String itemID) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Sales').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(); // Loading indicator while fetching data
        }

        List<DataRow> tableData = [];

        snapshot.data?.docs.forEach((document) {
          var data = document.data() as Map<String, dynamic>;
          var documentItemID = data['id'];
          int purchase1 = data['purchase'];
          purchase = purchase1.toString();

          // Access data from the subcollection 'details'
          var detailsCollection = document.reference.collection('details');

          // Check if the document's itemID matches the provided itemID
          if (documentItemID == itemID) {
            // Use a separate StreamBuilder to fetch and display data from 'details'
            int purchase1 = data['purchase'];
            purchase = purchase1.toString();

            tableData.add(
              DataRow(
                cells: [
                  DataCell(
                    StreamBuilder<QuerySnapshot>(
                      stream: detailsCollection.snapshots(),
                      builder: (context, detailsSnapshot) {
                        if (!detailsSnapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        // Build your subcollection data here
                        List<DataRow> detailData = [];
                        detailsSnapshot.data?.docs.forEach((detailDocument) {
                          var detail = detailDocument.data() as Map<String, dynamic>;
                          detailData.add(DataRow(
                            cells: [
                              DataCell(Text(detail['Item'].toString())),
                              DataCell(Text(detail['Quantity'].toString())),
                              DataCell(Text(detail['Rate'].toString())),
                              DataCell(Text(detail['Grandtotal'].toString())),
                            ],
                          ));
                        });

                        return DataTable(
                          columns: [
                            DataColumn(label: Text('Item')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Rate')),
                            DataColumn(label: Text('Grandtotal')),
                          ],
                          rows: detailData,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        });

        return SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(label: Text('SALE #$purchase')),
            ],
            rows: tableData,
          ),
        );
      },
    );
  }




}

class SupplierModel {
  String s_id;
  String s_name;

  SupplierModel(this.s_id, this.s_name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierModel &&
          runtimeType == other.runtimeType &&
          s_id == other.s_id;

  @override
  int get hashCode => s_id.hashCode;
}

class TableInsideTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: Text('Table Inside Table'),
          ),
        ];
      },
      body: SingleChildScrollView(
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
                  label: Text('Outer Table',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          Text("New"),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("New"),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("New"),
                        ],
                      ),
                    ],
                  )),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

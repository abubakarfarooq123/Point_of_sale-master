import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';
import '../splashScreens/loginout.dart';
import 'add_customers.dart';

import 'package:intl/intl.dart';

enum MenuItem {
  item1,
  item2,
}

class Customer extends StatefulWidget {
  const Customer({Key? key}) : super(key: key);

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> data = [];
  List<QueryDocumentSnapshot> filteredData = [];

// Function to filter data based on name and phone number
  Future<void> fetchCustomerData() async {
    QuerySnapshot snapshot = await firestore.collection('customer').get();
    setState(() {
      data = snapshot.docs;
      filteredData = data; // Initialize filteredData with the initial data
    });
  }

  void filterData(String query) {
    setState(() {
      filteredData = data.where((item) {
        String name = item['name'].toString().toLowerCase();
        String phone = item['phone'].toString().toLowerCase();
        query = query.toLowerCase();

        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  var name = "";
  var email = "";
  var phone = "";
  var address = "";
  var city = "";
  var state = "";
  var zipcode = "";
  var invoices = "";
  var country = "";
  var previous_blanace = "";
  var total_spend = "";

  final total_spendController = TextEditingController();
  final invoicesController = TextEditingController();
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

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore.collection('customer').get();
    return snapshot.docs;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Object?> getValuesFromFirebase() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('customer')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return {};
  }

  // int activeCustomerCount = 0;
  int deletedCustomerCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCustomerData(); // Fetch initial data

    // Call a function to listen for new customer additions
    getValuesFromFirebase().then((values) {
      setState(() {
        Map<String, dynamic> data = values as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email']?.toString() ?? '';
        phoneController.text = data['phone'] ?? '';
        setvalue = data['gender']?.toString() ?? '';
        cityController.text = data['city']?.toString() ?? '';
        zipcodeController.text = data['zip']?.toString() ?? '';
        countryController.text = data['country']?.toString() ?? '';
        stateController.text = data['state']?.toString() ?? '';
        addressController.text = data['address']?.toString() ?? '';
        invoicesController.text = data['invoices']?.toString() ?? '';
        total_spendController.text = data['total_spend']?.toString() ?? '';

        // Update other controller values as needed
      });
    });
    // listenForNewCustomers();
    _purchasedateController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  var setvalue3;

  TextEditingController _purchasedateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  Future<List<QueryDocumentSnapshot>> getDeletedCustomers() async {
    // Query Firestore for deleted customers
    QuerySnapshot querySnapshot = await firestore
        .collection('customer')
        .where('isDeleted', isEqualTo: true)
        .get();

    // Return the list of deleted customer documents
    return querySnapshot.docs;
  }

  List<String> payment = ['Cash', 'Check', 'Debit', 'Bank', 'Due'];
  String selected3 = '';

  List<String> mode = ['Receivable', 'Reverse'];
  String selected4 = '';
  var setvalue4;

  // void listenForNewCustomers() {
  //   firestore.collection('customer').snapshots().listen((snapshot) {
  //     // Update the active customer count when a new customer is added
  //     setState(() {
  //       activeCustomerCount = snapshot.docs.length;
  //     });
  //   });
  // }

  List<String> gender = ['Male', 'Female', 'N/A'];
  String selected = '';
  var setvalue;

  String calculateTotalSpend(List<DocumentSnapshot> data) {
    double totalSpend = 0.0;
    for (final document in data) {
      Map<String, dynamic> employeeData =
          document.data() as Map<String, dynamic>;
      totalSpend += double.parse(employeeData['total_spend']);
    }
    return totalSpend.toStringAsFixed(1);
  }

  String calculateTotalInvoices(List<DocumentSnapshot> data) {
    int totalInvoices = 0;
    for (final document in data) {
      Map<String, dynamic> employeeData =
          document.data() as Map<String, dynamic>;
      totalInvoices += int.parse(employeeData['invoices']);
    }
    return totalInvoices.toString();
  }

  String calculateTotalBalanceDue(List<DocumentSnapshot> data) {
    double totalBalanceDue = 0.0;
    for (final document in data) {
      Map<String, dynamic> employeeData =
          document.data() as Map<String, dynamic>;
      totalBalanceDue += double.parse(employeeData['previous']);
    }

    // Check if totalBalanceDue is zero or negative
    if (totalBalanceDue <= 0) {
      return '0.00'; // Display zero as a string with two decimal places
    } else {
      return totalBalanceDue.toStringAsFixed(2);
    }
  }

  String calculateTotalBalancePay(List<DocumentSnapshot> data) {
    double totalBalanceDue = 0.0;
    for (final document in data) {
      Map<String, dynamic> employeeData =
          document.data() as Map<String, dynamic>;
      double previousValue = double.parse(employeeData['previous']);

      if (previousValue < 0) {
        totalBalanceDue += previousValue.abs();
      }
    }
    return totalBalanceDue.toStringAsFixed(2);
  }



  bool isisRowSelected = false;
  int selectedRowIndex = -1; // Track the index of the selected row

  double duesAmount = 0.0;

  void listenForCustomers() {
    firestore.collection('customer').doc().get().then((snapshot) {
      setState(() {
        duesAmount = snapshot.data()!['previous'];
      });
    }).catchError((error) {
      print('Error fetching dues data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {

    List<QueryDocumentSnapshot> validData = filteredData.where((customerData) {
      Map<String, dynamic>? data = customerData.data() as Map<String, dynamic>?;
      return data != null && (!data.containsKey('isDeleted') || data['isDeleted'] == false);
    }).toList();

    List<DataRow> rows = List<DataRow>.generate(validData.length, (index) {
      QueryDocumentSnapshot customerData = validData[index];
      String name = customerData['name'];
      String email = customerData['email'];
      String phone = customerData['phone'];
      String city1 = customerData['city'];
      String country1 = customerData['country'];
      String spend = customerData['total_spend'];
      String invoices = customerData['invoices'];
      String due = customerData['previous'];
      String cnic = customerData['cnic'];

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
          DataCell(Text(phone)),
          DataCell(Text(email)),
          DataCell(Text(cnic)),
          DataCell(Text(city1)),
          DataCell(Text(country1)),
          DataCell(Text(spend)),
          DataCell(Text(invoices)),
          DataCell(Text(due)),
        ],
      );
    });

// Use the 'rows' list in your DataTable widget

    int activeCustomerCount = validData.length;

    int deletedCustomerCount = data.where((customerData) {
      Map<String, dynamic>? data = customerData.data() as Map<String, dynamic>?;
      return data != null && data['isDeleted'] == true;
    }).length;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Customers",
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
                                controller: _searchController,
                                onChanged: (query) {
                                  filterData(query);
                                },
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
                                showInstallmentDialog(
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
                                  FontAwesomeIcons.cashRegister,
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
                                showEditProfileDetailDialog(context, data[selectedRowIndex]);
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
                            padding: const EdgeInsets.only(left: 10),
                            child: InkWell(
                              onTap: () {
                                showEditProfileDialog(
                                    context, data[selectedRowIndex]);
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: selectedRowIndex != -1
                                      ? Colors.green
                                      : Colors.grey.withOpacity(0.5),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.edit,
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
                                showDeleteConfirmationDialog(
                                    context, data, selectedRowIndex);
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
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, top: 50),
                                      child: Icon(
                                        FontAwesomeIcons.userPlus,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 50, left: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activeCustomerCount.toString(),
                                            style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 26),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 7, top: 20, right: 10),
                                  child: Text(
                                    "Active Customers",
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              // Get the deleted customer data
                              List<QueryDocumentSnapshot> deletedCustomers =
                                  await getDeletedCustomers();

                              // Call the function to show the dialog with the deleted customer data
                              showRecoverDeletedCustomersDialog(
                                  context, deletedCustomers);
                            },
                            child: Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30, top: 50),
                                        child: Icon(
                                          FontAwesomeIcons.userMinus,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 50, left: 20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              deletedCustomerCount.toString(),
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 26),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 7, top: 20, right: 10),
                                    child: Text(
                                      "Delete Customers",
                                      style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.lime,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 40),
                                      child: Icon(
                                        FontAwesomeIcons.clock,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 40, left: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Rs. ${calculateTotalBalanceDue(data)}",
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 2, top: 10),
                                  child: Text(
                                    "Receivable (Dues)",
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 40),
                                      child: Icon(
                                        FontAwesomeIcons.clock,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 40, left: 7),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Rs. ${calculateTotalBalancePay(data)}',
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 2, top: 10),
                                  child: Text(
                                    "Payable (Dues)",
                                    style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8, top: 8, bottom: 20),
                      child: Text(
                        'Active Customers',
                        style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 30,
                        headingRowColor:
                            MaterialStateColor.resolveWith((states) {
                          return Colors.blue;
                        }),
                        dividerThickness: 3,
                        showBottomBorder: true,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Name',
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
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CNIC',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'City',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Country',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Total Spent',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Invoices',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Balance Due',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        rows: rows
                          ..add(
                            DataRow(
                              color: MaterialStateColor.resolveWith((states) {
                                return Colors.grey.withOpacity(
                                    0.5); // Set the background color to grey for the total quantity row
                              }),
                              cells: [
                                DataCell(Text('Total:')),
                                DataCell(Text('')), // An empty cell for spacing
                                DataCell(Text('')), // An empty cell for spacing
                                DataCell(Text('')), // An empty cell for spacing
                                DataCell(Text('')), // An empty cell for spacing
                                DataCell(Text('')), // An empty cell for spacing
                                DataCell(
                                  Text(
                                    calculateTotalSpend(data),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    calculateTotalInvoices(data),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    calculateTotalBalanceDue(data),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        dataRowColor: MaterialStateColor.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.grey.withOpacity(0.5);
                          }
                          return Colors.transparent;
                        }),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                );
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Add_Customer()));
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, List<dynamic> data, int selectedRowIndex) async {
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
                  ? () async {
                // Perform the action for the delete button
                Map<String, dynamic> selectedCustomerData =
                data[selectedRowIndex].data() as Map<String, dynamic>;
                String selectedCustomerId = selectedCustomerData['id'];
                double previousBalance = double.parse(selectedCustomerData['previous']) ?? 0;

                if (previousBalance == 0) {
                  try {
                    // Set a flag to mark the record as deleted
                    await firestore.collection('customer').doc(selectedCustomerId).update({
                      'isDeleted': true,
                    });

                    // Update the local data list
                    setState(() {
                      data.removeAt(selectedRowIndex);
                      selectedRowIndex = -1;
                    });

                    // Close the dialog
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => Customer()));
                  } catch (error) {
                    // Handle the error
                    print('Error marking record as deleted: $error');
                  }
                } else {
                  // Customer has a non-zero previous balance, show an alert
                  Navigator.of(context).pop(); // Close the current dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Cannot Delete'),
                        content: Text('Customer has a non-zero previous balance and cannot be deleted.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the alert dialog
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
                  : null,
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }



  Future<void> deleteCustomerFromFirebase(QueryDocumentSnapshot customerDocument) async {
    try {
      // Assuming you have a reference to the Firestore instance
      await FirebaseFirestore.instance
          .collection('customer') // Replace 'customers' with your collection name
          .doc(customerDocument.id) // Get the document ID of the customer
          .delete();

      Navigator.of(context).pop();
      // Optionally, you can also perform any additional cleanup or state updates here
    } catch (e) {
      print('Error deleting customer: $e');
      // Handle any errors here
    }
  }


  void showRecoverDeletedCustomersDialog(BuildContext context, List<dynamic> deletedCustomers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deleted Customers'),
          content: Container(
            height: 300, // Adjust the height as needed
            width: 300, // Adjust the width as needed
            child: ListView.builder(
              itemCount: deletedCustomers.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> deletedCustomerData =
                deletedCustomers[index].data() as Map<String, dynamic>;
                String name = deletedCustomerData['name'];
                return Column(
                  children: [
                    ListTile(
                      title: Text(name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min, // To make the items inline
                        children: [
                          InkWell(
                            onTap: () {
                              recoverDeletedCustomer(deletedCustomers[index]);
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => Customer()));
                            },
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(child: Icon(Icons.refresh_sharp, color: Colors.white))),
                          ),
                          SizedBox(width: 20), // Add some spacing between the icons
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text('Are you sure you want to delete $name permanently?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          // Perform the delete action from Firebase
                                          await deleteCustomerFromFirebase(deletedCustomers[index]);

                                          // Close the dialog
                                          Navigator.of(context).pop();

                                          // Optionally, you can also refresh your list after deleting
                                          // Call the function to reload your data or update your state
                                          // reloadCustomerList();
                                        },
                                        child: Text('Delete'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(child: Icon(Icons.delete, color: Colors.white))),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 1,
                      height: 1,
                      color: Colors.grey.withOpacity(0.4),
                    ), // Add a Divider widget after each ListTile
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );

      },
    );
  }

// Example function to recover a deleted customer
  void recoverDeletedCustomer(QueryDocumentSnapshot customerSnapshot) {
    String customerId = customerSnapshot['id'];

    // Perform the recovery logic, e.g., update the 'isDeleted' flag in Firebase
    firestore.collection('customer').doc(customerId).update({
      'isDeleted': false,
    }).then((value) {
      // Customer recovered successfully
      // You can also refresh the data list or take other actions as needed
    }).catchError((error) {
      // Handle error if recovery fails
    });
  }

  Widget _buildTab(String text, IconData iconData) {
    return Tab(
      child: Row(
        children: [
          Icon(
            iconData,
            color: Colors.blue,
          ),
          SizedBox(width: 5), // Adjust spacing as needed
          Text(
            text,
            style: GoogleFonts.roboto(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void showEditProfileDialog(BuildContext context, dynamic customerData) {
    void _updateSelectedValues() {
      String name1 = nameController.text;
      String phone1 = phoneController.text;
      String address1 = addressController.text;
      String city1 = cityController.text;
      String state1 = stateController.text;
      String zipcode1 = zipcodeController.text;
      String country1 = countryController.text;
      String selectedGender1 = setvalue;
      String spend = previous_balanceController.text;

      Map<String, dynamic> data = {
        'name': name1,
        'gender': selectedGender1,
        'phone': phone1,
        'city': city1,
        'country': country1,
        'state': state1,
        'zip': zipcode1,
        'address': address1,
        'previous': spend,
      };

      FirebaseFirestore.instance
          .collection('customer')
          .doc(customerData['id'])
          .update(data);
    }

    nameController.text = customerData['name'] ?? '';
    emailController.text = customerData['email']?.toString() ?? '';
    phoneController.text = customerData['phone'] ?? '';
    setvalue = customerData['gender']?.toString() ?? '';
    cityController.text = customerData['city']?.toString() ?? '';
    zipcodeController.text = customerData['zip']?.toString() ?? '';
    countryController.text = customerData['country']?.toString() ?? '';
    stateController.text = customerData['state']?.toString() ?? '';
    previous_balanceController.text =
        customerData['previous']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Implement your edit profile dialog here
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Edit Profile'),
            content: Column(
              children: [
                new Form(
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
                          onChanged: (value) => name = value,
                        ),
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
                          readOnly: true,
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.only(left: 14, right: 14, top: 14),
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              // Row(
                              //   children: [
                              //     Icon(
                              //       Icons.assignment_ind_outlined,
                              //       color: Colors.blue,
                              //       size: 35,
                              //     ),
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //     Container(
                              //       width: 279,
                              //       height: 60,
                              //       padding: EdgeInsets.only(left: 16, right: 16),
                              //       decoration: BoxDecoration(
                              //           border: Border.all(
                              //               color: Colors.grey, width: 1),
                              //           borderRadius: BorderRadius.circular(15)),
                              //       child: DropdownButton(
                              //         hint: Padding(
                              //           padding: const EdgeInsets.only(top: 10),
                              //           child: Text(
                              //             'Please choose Gender',
                              //             style: TextStyle(
                              //               color: Colors.black54,
                              //             ),
                              //           ),
                              //         ),
                              //         isExpanded: true,
                              //         underline: SizedBox(),
                              //         iconSize: 40.0,
                              //         value: setvalue,
                              //         onChanged: (newValue) {
                              //           setState(() {
                              //             setvalue = newValue;
                              //           });
                              //         },
                              //         items: gender.map((String value) {
                              //           return new DropdownMenuItem<String>(
                              //             value: value,
                              //             child: new Text(value),
                              //           );
                              //         }).toList(),
                              //       ),
                              //     ),
                              //   ],
                              // ),
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
                        padding: const EdgeInsets.only(
                            left: 18, right: 18, bottom: 18),
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
                          onChanged: (value) => phone = value,
                        ),
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
                          onChanged: (value) => address = value,
                        ),
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
                          onChanged: (value) => city = value,
                        ),
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
                          onChanged: (value) => state = value,
                        ),
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
                          onChanged: (value) => zipcode = value,
                        ),
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
                          onChanged: (value) => country = value,
                        ),
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
                        ),
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
                            _updateSelectedValues();
                            Navigator.of(context).pop();
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
      },
    );
  }

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

          List<Map<String, dynamic>> tableData = [];

          salesData.forEach((transactionData) {
            var transactionAmount = transactionData['grand'];
            var transactionDate = transactionData['pickdate'];
            var tenderedAmount = transactionData['tender'];

            tableData.add({
              'Date': transactionDate,
              'Sale': 'Rs. $transactionAmount',
              'Get': '',
              'Note': '',
              'Gave': '',
            });

            tableData.add({
              'Date': transactionDate,
              'Sale': '',
              'Get': 'Rs. $tenderedAmount',
              'Note': '',
              'Gave': '',
            });

            paymentsData.forEach((paymentdata) {
              for (var reverseEntry in paymentdata['receive']) {
                tableData.add({
                  'Date': reverseEntry['date'].toString(),
                  'Sale': '',
                  'Get': reverseEntry['amount'].toString(),
                  'Note': reverseEntry['notes'].toString(),
                  'Gave': '',
                });
              }

              for (var reverseEntry in paymentdata['reverse']) {
                tableData.add({
                  'Date': reverseEntry['date'].toString(),
                  'Sale': '',
                  'Get': '',
                  'Note': reverseEntry['notes'].toString(),
                  'Gave': '- ${reverseEntry['amount'].toString()}',
                });
              }
            });
          });

          // Process additionalData similarly to salesData and paymentsData
          additionalData.forEach((additionalTransactionData) {
            var additionalTransactionAmount =
                additionalTransactionData['grand'];
            var additionalTransactionDate =
                additionalTransactionData['pickdate'];
            var additionalTenderedAmount = additionalTransactionData['paid'];

            tableData.add({
              'Date': additionalTransactionDate,
              'Sale': 'Rs. $additionalTransactionAmount',
              'Get': '',
              'Note': '',
              'Gave': '',
            });

            tableData.add({
              'Date': additionalTransactionDate,
              'Sale': '',
              'Get': 'Rs. $additionalTenderedAmount',
              'Note': '',
              'Gave': '',
            });

            // Add any other processing specific to the additional data here
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
                          Text('Date', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label:
                          Text('Sale', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Get', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label:
                          Text('Gave', style: TextStyle(color: Colors.white)),
                    ),
                    DataColumn(
                      label:
                          Text('Note', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  rows: tableData.map((rowData) {
                    return DataRow(cells: [
                      DataCell(Text(rowData['Date'])),
                      DataCell(
                        Text(
                          rowData['Sale'],
                          style: TextStyle(
                            color: rowData['Sale'].startsWith('-')
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          rowData['Get'],
                          style: TextStyle(
                            color: rowData['Get'].startsWith('-')
                                ? Colors.red
                                : Colors.green,
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
                      DataCell(Text(rowData['Note'])),
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
    nameController.text = customerData['name'] ?? '';
    emailController.text = customerData['email']?.toString() ?? '';
    phoneController.text = customerData['phone'] ?? '';
    setvalue = customerData['gender']?.toString() ?? '';
    cityController.text = customerData['city']?.toString() ?? '';
    zipcodeController.text = customerData['zip']?.toString() ?? '';
    countryController.text = customerData['country']?.toString() ?? '';
    stateController.text = customerData['state']?.toString() ?? '';
    String spend = customerData['previous']?.toString() ?? '';
    double spendAsDouble = double.tryParse(spend) ?? 0.0;

    List<String> reverseList = [];
    List<dynamic> reverseData = customerData['reverse'];
    if (reverseData != null) {
      for (var reverse in reverseData) {
        reverseList.add(reverse.toString());
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DefaultTabController(
          length: 2,
          child: SingleChildScrollView(
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
                        '${nameController.text} Deposit',
                        style: GoogleFonts.roboto(
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
              content: Column(
                children: [
                  TabBar(
                    indicator: null,
                    indicatorColor: Colors.blue,
                    // Set the indicator color to transparent

                    tabs: [
                      _buildTab('Profile', Icons.account_circle),
                      _buildTab('Transactions', Icons.history),
                    ],
                  ),
                  Container(
                    height: 800,
                    width: 320,
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nameController.text,
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.greenAccent.shade200),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Icon(
                                          Icons.fiber_manual_record,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Active",
                                          style: GoogleFonts.roboto(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.local_phone_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      phoneController.text,
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Phone Number",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.email_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      emailController.text,
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Email Address",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_city,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      addressController.text,
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Address",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.pin_drop,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cityController.text,
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "City",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 100,
                                ),
                                Icon(
                                  Icons.pin_drop_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      zipcodeController.text,
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "ZipCode",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.edit_location_alt_sharp,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stateController.text,
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "State",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 80,
                                ),
                                Icon(
                                  Icons.location_city_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      countryController.text,
                                      style: GoogleFonts.roboto(
                                        color: Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Country",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                "Total Sales Count ${invoicesController.text}",
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                "Sales Amount Rs. ${total_spendController.text}",
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    nameController.text,
                                    style: GoogleFonts.roboto(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    phoneController.text,
                                    style: GoogleFonts.roboto(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Total Sales: ",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                ),
                                Text(
                                  "2222",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Divider(
                              height: 1,
                              color: Colors.black.withOpacity(0.3),
                              thickness: 1,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                "Summary",
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SingleChildScrollView(
                              child: Container(
                                  height: 300,
                                  child: buildTransactionsTab(
                                      customerData['name'] ?? '')),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 40,
                              width: 320,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 10,
                                    top: 12,
                                    child: Text(
                                      "Due Balance: ",
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 12,
                                    child: Text(
                                      "Rs. ${spendAsDouble.toStringAsFixed(2)}",
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double reverse = 0.0;

  void showInstallmentDialog(BuildContext context, dynamic customerData) {
    String previousVal = '';
    Future<void> increaseItemQuantity() async {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('customer')
                .doc(customerData['id'])
                .get();

        previousVal = snapshot.data()!['previous'];

        print("CurrentValue $previousVal");

        double enteredAmount = double.parse(previousVal);

        if (enteredAmount != null) {
          if (setvalue4 == 'Receivable') {
            double amount = double.parse(_amountController.text);
            double newval = enteredAmount - amount;
            String updatedValue = newval.toString();

            dynamic existingReceive = snapshot.data()!['receive'];

            List<dynamic> existingReceiveList =
                existingReceive is List ? List.from(existingReceive) : [];

            Map<String, dynamic> existingReceiveEntry = {
              'date': _purchasedateController.text,
              'notes': _notesController.text,
              'amount': amount.toString(),
              'previous': enteredAmount.toStringAsFixed(2),
              'newbalnce': updatedValue,
            };

// Append the new reverse entry map to the list
            existingReceiveList.add(existingReceiveEntry);

            await FirebaseFirestore.instance
                .collection('customer')
                .doc(customerData['id'])
                .update({
              'previous': updatedValue,
              'receive': existingReceiveList,
            });
          } else if (setvalue4 == 'Reverse') {
            double amount = double.parse(_amountController.text);
            reverse = amount;
            double newval = enteredAmount + amount;
            String updatedValue = newval.toString();
            String reverse1 = reverse.toString();

            dynamic existingReverse = snapshot.data()!['reverse'];

            List<dynamic> existingReverseList =
                existingReverse is List ? List.from(existingReverse) : [];

            Map<String, dynamic> reverseEntry = {
              'date': _purchasedateController.text,
              'notes': _notesController.text,
              'amount': reverse1,
              'previous': enteredAmount.toString(),
              'newbalnce': updatedValue,
            };

// Append the new reverse entry map to the list
            existingReverseList.add(reverseEntry);

            await FirebaseFirestore.instance
                .collection('customer')
                .doc(customerData['id'])
                .update({
              'previous': updatedValue,
              'reverse': existingReverseList,
              // Update the "reverse" field with the new list
            });
          }
        }
      } catch (e) {
        print("Error: $e");
      }
    }

    double spend = 0.0;

    nameController.text = customerData['name'] ?? '';
    emailController.text = customerData['email']?.toString() ?? '';
    phoneController.text = customerData['phone'] ?? '';
    setvalue = customerData['gender']?.toString() ?? '';
    cityController.text = customerData['city']?.toString() ?? '';
    zipcodeController.text = customerData['zip']?.toString() ?? '';
    countryController.text = customerData['country']?.toString() ?? '';
    stateController.text = customerData['state']?.toString() ?? '';
    String? spendStr = customerData['previous']?.toString();
     spend = double.parse(spendStr ?? '0.0');
    
     showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: AlertDialog(
              title: Container(
                width: 320,
                height: 40,
                child: Stack(
                  children: [
                    Positioned(
                      left: 5,
                      top: 10,
                      child: Text(
                        '${nameController.text} Deposit',
                        style: GoogleFonts.roboto(
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
              content: Column(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.black45,
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Form(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Payment Date",
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            controller: _purchasedateController,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: _purchasedateController
                                        .text.isEmpty
                                    ? DateTime
                                        .now() // Use current date if the field is empty
                                    : DateFormat('dd/MM/yyyy').parse(
                                        _purchasedateController
                                            .text), // Parse existing value
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              ).then((date) {
                                if (date != null) {
                                  setState(() {
                                    final formattedDate =
                                        DateFormat('dd/MM/yyyy').format(date);
                                    _purchasedateController.text =
                                        formattedDate;
                                  });
                                }
                              });
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Payment Method",
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: [
                                    Container(
                                      width: 208,
                                      height: 60,
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: DropdownButton(
                                        hint: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 15),
                                          child: Text(
                                            'Select Method',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        isExpanded: true,
                                        icon: Visibility(
                                            visible: false,
                                            child: Icon(Icons.arrow_downward)),
                                        underline: SizedBox(),
                                        value: setvalue3,
                                        onChanged: (newValue) {
                                          setState(() {
                                            setvalue3 = newValue;
                                          });
                                        },
                                        items: payment.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  selected3,
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
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Payment Mode",
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: [
                                    Container(
                                      width: 208,
                                      height: 60,
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: DropdownButton(
                                        hint: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 15),
                                          child: Text(
                                            'Select Mode',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        isExpanded: true,
                                        icon: Visibility(
                                            visible: false,
                                            child: Icon(Icons.arrow_downward)),
                                        underline: SizedBox(),
                                        value: setvalue4,
                                        onChanged: (newValue) {
                                          setState(() {
                                            setvalue4 = newValue;
                                          });
                                        },
                                        items: mode.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  selected4,
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
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Recieving Amount",
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _amountController,
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Payment Notes",
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              hintText: 'Notes',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Container(
                          height: 30,
                          width: 320,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 5,
                                child: Text(
                                  "Dues",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 5,
                                child: Text(
                                  "Rs. ${spend.toStringAsFixed(2)}",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 100,
                          width: 320,
                          child: Stack(
                            children: [
                              Positioned(
                                  left: 5,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.4),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Cancel",
                                          style: GoogleFonts.roboto(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                              Positioned(
                                  right: 5,
                                  child: InkWell(
                                    onTap: () {
                                      increaseItemQuantity();
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Continue",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

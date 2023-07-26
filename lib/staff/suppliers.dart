import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/staff/add_suppliers.dart';
import 'package:pos/user/edit_profile.dart';
import '../splashScreens/loginout.dart';
import 'add_customers.dart';

enum MenuItem {
  item1,
  item2,
}

class Suppliers extends StatefulWidget {
  const Suppliers({Key? key}) : super(key: key);

  @override
  State<Suppliers> createState() => _SuppliersState();
}

class _SuppliersState extends State<Suppliers> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore.collection('supplier').get();
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
    return {}; // Default empty map if the document doesn't exist
  }

  int activeCustomerCount = 0;
  int deletedCustomerCount = 0;
  bool isisRowSelected = false;
  int selectedRowIndex = -1; // Track the index of the selected row


  var company ="";
  var name = "";
  var email = "";
  var phone = "";
  var address = "";
  var city = "";
  var state = "";
  var zipcode = "";
  var country = "";
  var previous_blanace = "";
  var agency = "";
  var comment = "";
  String? purchase;
  String? paid;


  final companyController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipcodeController = TextEditingController();
  final countryController = TextEditingController();
  final previous_balanceController = TextEditingController();
  final agencyController = TextEditingController();
  final commentController = TextEditingController();




  @override
  void initState() {
    super.initState();
    // Call a function to listen for new customer additions
    getValuesFromFirebase().then((values) {
      setState(() {
        Map<String, dynamic> data = values as Map<String, dynamic>;
        addressController.text = data['address']?.toString() ?? '';
        agencyController.text = data['agency']?.toString() ?? '';
        cityController.text = data['city']?.toString() ?? '';
        commentController.text = data['comment']?.toString() ?? '';
        companyController.text = data['company']?.toString() ?? '';
        countryController.text = data['country']?.toString() ?? '';
        emailController.text = data['email']?.toString() ?? '';
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        previous_balanceController.text = data['previous']?.toString() ?? '';
        purchase = data['purchase']?.toString() ?? '';
        stateController.text = data['state']?.toString() ?? '';
        paid = data['total_paid']?.toString() ?? '';
        zipcodeController.text = data['zip']?.toString() ?? '';


        // Update other controller values as needed
      });
    });
    listenForNewCustomers();
  }

  @override

  void listenForNewCustomers() async {
    // Get the initial list of documents
    var initialSnapshot = await firestore.collection('supplier').get();
    activeCustomerCount = initialSnapshot.docs.length;

    // Save the initial snapshot document IDs to compare with new snapshots
    List<String> previousSnapshotIds = initialSnapshot.docs.map((doc) => doc.id).toList();

    firestore.collection('supplier').snapshots().listen((snapshot) {
      // Get the current list of documents
      List<DocumentSnapshot> currentSnapshot = snapshot.docs;

      // Calculate the deleted supplier count
      int deletedCount = 0;
      for (var id in previousSnapshotIds) {
        if (!currentSnapshot.any((doc) => doc.id == id)) {
          deletedCount++;
        }
      }

      // Update the deleted supplier count and active customer count
      setState(() {
        deletedCustomerCount = deletedCount;
        activeCustomerCount = currentSnapshot.length;
      });

      // Update the previous snapshot document IDs for the next iteration
      previousSnapshotIds = currentSnapshot.map((doc) => doc.id).toList();
    });
  }


  //
  // void deleteCustomer(String customerId) {
  //   firestore.collection('supplier').doc(customerId).delete().then((value) {
  //     // Customer deleted successfully, reduce the active customer count by 1
  //     setState(() {
  //       activeCustomerCount--;
  //       deletedCustomerCount++;
  //     });
  //   }).catchError((error) {
  //     // Handle any errors that occur during deletion
  //     print('Error deleting customer: $error');
  //   });
  // }

  double duesAmount = 0.0;

  void listenForCustomers() {
    firestore.collection('supplier').doc().get().then((snapshot) {
      setState(() {
        duesAmount = snapshot.data()!['previous'];
      });
    }).catchError((error) {
      print('Error fetching dues data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Suppliers",
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
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
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
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: selectedRowIndex != -1 ? Colors.grey : Colors.grey.withOpacity(0.5),
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
                                showEditProfileDialog(context, data[selectedRowIndex]);
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: selectedRowIndex != -1 ? Colors.green : Colors.grey.withOpacity(0.5),
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
                                        FontAwesomeIcons.handshake,
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
                                    "Active Suppliers",
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
                                        FontAwesomeIcons.handshakeSlash,
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
                                    "Delete Suppliers",
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
                                          top: 40, left: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Rs 1123.41",
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
                                      padding:
                                          const EdgeInsets.only(top: 40, left: 7),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Rs 11333.41",
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
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Active Suppliers',
                        style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 41,
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
                              label: Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Text(
                                  'Phone',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Email',
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
                                'Country',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Agency',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Company',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total Paid',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Purchases',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Amount Payable',
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(data.length, (index) {
                            Map<String, dynamic> employeeData =
                            data[index].data() as Map<String, dynamic>;
                            String name = employeeData['name'];
                            String email = employeeData['email'];
                            String phone = employeeData['phone'];
                            String city1 = employeeData['city'];
                            String country1 = employeeData['country'];
                            String agency1 = employeeData['agency'];
                            String company = employeeData['company'];
                            String spend = employeeData['total_paid'];
                            String inovices = employeeData['purchase'];
                            String due = employeeData['previous'];

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
                                DataCell(Text(city1)),
                                DataCell(Text(country1)),
                                DataCell(Text(agency1)),
                                DataCell(Text(company)),
                                DataCell(Text(spend)),
                                DataCell(Text(inovices)),
                                DataCell(Text(due)),
                              ],
                            );
                          }),
                          dataRowColor: MaterialStateColor.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.grey.withOpacity(0.5);
                            }
                            return Colors.transparent;
                          }),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Add_Suppliers()));
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
                firestore.collection('supplier').doc(selectedEmployeeId).delete().then((value) {
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
  void showEditProfileDialog(BuildContext context, dynamic customerData) {


    void _updateSelectedValues() {
      String address1 = addressController.text;
      String agency1 = agencyController.text;
      String city1 = cityController.text;
      String comment1 = commentController.text;
      String company1 = companyController.text;
      String country1 = countryController.text;
      String email1 = emailController.text;
      String name1 = nameController.text;
      String phone1 = phoneController.text;
      String previous1 = previous_balanceController.text;
      String state1 = stateController.text;
      String zipcode1 = zipcodeController.text;




      Map<String, dynamic> data = {
        'address': address1,
        'agency':agency1,
        'city': city1,
        'comment':comment1,
        'company': company1,
        'country': country1,
        'email':email1,
        'name': name1,
        'phone': phone1,
        'previous':previous1,
        'state':state1,
        'zip':zipcode1,

      };

      FirebaseFirestore.instance
          .collection('supplier')
          .doc(customerData['id'])
          .update(data);
    }

    addressController.text = customerData['address']?.toString() ?? '';
    agencyController.text = customerData['agency']?.toString() ?? '';
    cityController.text = customerData['city']?.toString() ?? '';
    commentController.text = customerData['comment']?.toString() ?? '';
    companyController.text = customerData['company']?.toString() ?? '';
    countryController.text = customerData['country']?.toString() ?? '';
    emailController.text = customerData['email']?.toString() ?? '';
    nameController.text = customerData['name'] ?? '';
    phoneController.text = customerData['phone'] ?? '';
    previous_balanceController.text = customerData['previous']?.toString() ?? '';
    purchase = customerData['purchase']?.toString() ?? '';
    stateController.text = customerData['state']?.toString() ?? '';
    paid = customerData['total_paid']?.toString() ?? '';
    zipcodeController.text = customerData['zip']?.toString() ?? '';

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
                            hintText: 'Company Name',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey,width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            icon: Icon(
                              FontAwesomeIcons.building,
                              color: Colors.blue,
                            ),
                          ),
                          controller: companyController,
                          onChanged: (value) => company = value,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Name',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey,width: 1),
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
                                borderSide: BorderSide(color: Colors.grey,width: 1),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Email';
                              } else if (!value.contains('@')) {
                                return 'Please Enter Valid Email';
                              }
                              return null;
                            },
                            onChanged: (value) => email = value,

                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 18,right: 18,bottom: 18),
                        child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Phone',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey,width: 1),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Phone';
                              }
                              return null;
                            },
                          onChanged: (value) => phone = value,

                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Address',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey,width: 1),
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
                                borderSide: BorderSide(color: Colors.grey,width: 1),
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
                                borderSide: BorderSide(color: Colors.grey,width: 1),
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
                                borderSide: BorderSide(color: Colors.grey,width: 1),
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
                                borderSide: BorderSide(color: Colors.grey,width: 1),
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
                              borderSide: BorderSide(color: Colors.grey,width: 1),
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
                          onChanged: (value) => previous_blanace = value,

                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Agency Name',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey,width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorStyle: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                              icon: Icon(
                                Icons.supervised_user_circle_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            controller: agencyController,
                          onChanged: (value) => agency = value,

                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                            minLines: 5,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Comments',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey,width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              errorStyle: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15.0,
                              ),
                              icon: Icon(
                                Icons.comment,
                                color: Colors.blue,
                              ),
                            ),
                            controller: commentController,
                          onChanged: (value) => comment = value,

                        ),
                      ),

                      SizedBox(height: 20,),
                      // ignore: deprecated_member_use
                      Container(
                        height: 45.0,
                        width: 320.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue

                        ),
                        child: InkWell(
                          onTap: () {
                            _updateSelectedValues();
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => Suppliers()));

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
  void showEditProfileDetailDialog(BuildContext context, dynamic customerData) {

    addressController.text = customerData['address']?.toString() ?? '';
    agencyController.text = customerData['agency']?.toString() ?? '';
    cityController.text = customerData['city']?.toString() ?? '';
    commentController.text = customerData['comment']?.toString() ?? '';
    companyController.text = customerData['company']?.toString() ?? '';
    countryController.text = customerData['country']?.toString() ?? '';
    emailController.text = customerData['email']?.toString() ?? '';
    nameController.text = customerData['name'] ?? '';
    phoneController.text = customerData['phone'] ?? '';
    previous_balanceController.text = customerData['previous']?.toString() ?? '';
    purchase = customerData['purchase']?.toString() ?? '';
    stateController.text = customerData['state']?.toString() ?? '';
    paid = customerData['total_paid']?.toString() ?? '';
    zipcodeController.text = customerData['zip']?.toString() ?? '';


    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Implement your edit profile dialog here
        return SingleChildScrollView(
          child: AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${nameController.text} Profile',style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),),
                SizedBox(
                  width: 63,
                ),
                IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.clear,size: 32,))
              ],
            ),
            content: Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.4),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Text(nameController.text,style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    SizedBox(
                      width: 45,
                    ),
                    Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.greenAccent.shade200
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Icon(Icons.fiber_manual_record,color: Colors.green,size: 18,),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Active",style: GoogleFonts.roboto(
                              color: Colors.green,
                            ),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 360,
                  width: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.4),width: 1),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 30,
                        width: 280,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Positioned(
                              left: 10,
                              child: Text("Phone :",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                            SizedBox(
                              width: 55,
                            ),
                            Positioned(
                              right: 10,
                              child: Text(phoneController.text,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 30,
                        width: 280,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Positioned(
                              left: 10,
                              child: Text("Email :",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                            SizedBox(
                              width: 55,
                            ),
                            Positioned(
                              right: 10,
                              child: Text(emailController.text,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 30,
                        width: 280,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Positioned(
                              left: 10,
                              child: Text("Address :",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                            SizedBox(
                              width: 55,
                            ),
                            Positioned(
                              right: 10,
                              child: Text(addressController.text,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 30,
                        width: 280,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Positioned(
                              left: 10,
                              child: Text("City :",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                            SizedBox(
                              width: 55,
                            ),
                            Positioned(
                              right: 10,
                              child: Text(cityController.text,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 30,
                        width: 280,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Positioned(
                              left: 10,
                              child: Text("State :",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                            SizedBox(
                              width: 55,
                            ),
                            Positioned(
                              right: 10,
                              child: Text(stateController.text,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 30,
                        width: 280,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Positioned(
                              left: 10,
                              child: Text("ZipCode :",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                            SizedBox(
                              width: 55,
                            ),
                            Positioned(
                              right: 10,
                              child: Text(zipcodeController.text,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 30,
                        width: 280,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Positioned(
                              left: 10,
                              child: Text("Country :",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                            SizedBox(
                              width: 55,
                            ),
                            Positioned(
                              right: 10,
                              child: Text(
                                countryController.text,
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.withOpacity(0.4),
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

}

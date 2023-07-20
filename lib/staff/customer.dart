import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';
import '../splashScreens/loginout.dart';
import 'add_customers.dart';

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
  var total_spend="";

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
    return {}; // Default empty map if the document doesn't exist
  }

  int activeCustomerCount = 0;
  int deletedCustomerCount = 0;

  @override
  void initState() {
    super.initState();
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
    listenForNewCustomers();
  }

  void listenForNewCustomers() {
    firestore.collection('customer').snapshots().listen((snapshot) {
      // Update the active customer count when a new customer is added
      setState(() {
        activeCustomerCount = snapshot.docs.length;
      });
    });
  }
  List<String> gender = ['Male', 'Female', 'N/A'];
  String selected = '';
  var setvalue;


  void deleteCustomer(String customerId) {
    firestore.collection('customer').doc(customerId).delete().then((value) {
      // Customer deleted successfully, reduce the active customer count by 1
      setState(() {
        activeCustomerCount--;
        deletedCustomerCount++;
      });
    }).catchError((error) {
      // Handle any errors that occur during deletion
      print('Error deleting customer: $error');
    });
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
                                            "Rs $duesAmount",
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
                        headingRowColor: MaterialStateColor.resolveWith((states) {
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
                        rows: List<DataRow>.generate(data.length, (index) {
                          Map<String, dynamic> employeeData =
                          data[index].data() as Map<String, dynamic>;
                          String name = employeeData['name'];
                          String email = employeeData['email'];
                          String phone = employeeData['phone'];
                          String city1 = employeeData['city'];
                          String country1 = employeeData['country'];
                          String spend = employeeData['total_spend'];
                          String invoices = employeeData['invoices'];
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
                              DataCell(Text(spend)),
                              DataCell(Text(invoices)),
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
                firestore.collection('customer').doc(selectedEmployeeId).delete().then((value) {
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
      String name1 = nameController.text;
      String phone1 = phoneController.text;
      String address1 = addressController.text;
      String city1 = cityController.text;
      String state1 = stateController.text;
      String zipcode1 = zipcodeController.text;
      String country1 = countryController.text;
      String selectedGender1 = setvalue;


      Map<String, dynamic> data = {
        'name': name1,
        'gender': selectedGender1,
        'phone': phone1,
        'city': city1,
        'country': country1,
        'state':state1,
        'zip':zipcode1,
        'address': address1,

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
                              Row(
                                children: [
                                  Icon(
                                    Icons.assignment_ind_outlined,
                                    color: Colors.blue,
                                    size: 35,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 279,
                                    height: 60,
                                    padding: EdgeInsets.only(left: 16, right: 16),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                        borderRadius: BorderRadius.circular(15)),
                                    child: DropdownButton(
                                      hint: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          'Please choose Gender',
                                          style: TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      iconSize: 40.0,
                                      value: setvalue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          setvalue = newValue;
                                        });
                                      },
                                      items: gender.map((String value) {
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
                        padding:
                        const EdgeInsets.only(left: 18, right: 18, bottom: 18),
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
                        readOnly: true,
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
  void showEditProfileDetailDialog(BuildContext context, dynamic customerData) {

    nameController.text = customerData['name'] ?? '';
    emailController.text = customerData['email']?.toString() ?? '';
    phoneController.text = customerData['phone'] ?? '';
    setvalue = customerData['gender']?.toString() ?? '';
    cityController.text = customerData['city']?.toString() ?? '';
    zipcodeController.text = customerData['zip']?.toString() ?? '';
    countryController.text = customerData['country']?.toString() ?? '';
    stateController.text = customerData['state']?.toString() ?? '';

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
                  width: 83,
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
                  color: Colors.black45,
                  thickness: 1,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Icon(Icons.account_circle,color: Colors.blue,size: 25,),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Profile",style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nameController.text,style: GoogleFonts.roboto(
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
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.local_phone_outlined,color: Colors.grey,size: 20,),
                   SizedBox(
                     width: 10,
                   ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phoneController.text,style: GoogleFonts.roboto(
                          color: Colors.black87,
                      fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                        "Phone Number",style: GoogleFonts.roboto(
                          color: Colors.black,
                            fontSize: 10
                        ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.email_outlined,color: Colors.grey,size: 20,),
                    SizedBox(
                      width: 5,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emailController.text,style: GoogleFonts.roboto(
                            color: Colors.black87,
                            fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Email Address",style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 10
                        ),
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
                    Icon(Icons.location_city,color: Colors.grey,size: 20,),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          addressController.text,style: GoogleFonts.roboto(
                            color: Colors.black87,
                            fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Address",style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 12
                        ),
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
                    Icon(Icons.pin_drop,color: Colors.grey,size: 20,),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cityController.text,style: GoogleFonts.roboto(
                            color: Colors.black87,
                            fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "City",style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 10
                        ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 105,
                    ),
                    Icon(Icons.pin_drop_outlined,color: Colors.grey,size: 20,),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zipcodeController.text,style: GoogleFonts.roboto(
                            color: Colors.black87,
                            fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "ZipCode",style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 10
                        ),
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
                    Icon(Icons.edit_location_alt_sharp,color: Colors.grey,size: 20,),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stateController.text,style: GoogleFonts.roboto(
                            color: Colors.black87,
                            fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "State",style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 10
                        ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 95,
                    ),
                    Icon(Icons.location_city_outlined,color: Colors.grey,size: 20,),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          countryController.text,style: GoogleFonts.roboto(
                            color: Colors.black87,
                            fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Country",style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 10
                        ),
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
                  child: Text("Total Sales Count ${invoicesController.text}",style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text("Sales Amount Rs. ${total_spendController.text}",style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

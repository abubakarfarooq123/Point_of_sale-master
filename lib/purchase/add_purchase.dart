import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/home/home_screen.dart';
import 'package:pos/purchase/purchase.dart';
import 'package:pos/user/edit_profile.dart';
import 'package:intl/intl.dart';

import '../splashScreens/loginout.dart';

enum MenuItem {
  item1,
  item2,
}

class Add_Purchase extends StatefulWidget {
  @override
  State<Add_Purchase> createState() => _Add_PurchaseState();
}

class _Add_PurchaseState extends State<Add_Purchase> {
  TextEditingController? _dateController;
  double? amountPaid;

  @override
  void initState() {
    super.initState();
    assignGrandTotal();
    calculateGrandTotal();
    calculateGrandTotalwithTax();
    fetchPurchaseCount();
    _dateController = TextEditingController(text: getCurrentDate());
  }

  Widget? tableWidget;

  String selectedProductUnit = '';
  String selectedProductquantity = '';
  String selectedProductexpiry = '';
  String selectedProductrate = '';

  String getCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }
  double displaybalancedue = 0.0;
  bool isPercentageDiscount =
      false; // Add this line above the showMyDialog() method
  double grandTotal = 0.0; // Add this line above the showMyDialog() method


  bool isPercentagetax = false;



  add() async {
    DocumentReference docRef =
    FirebaseFirestore.instance.collection('Purchase').doc();
    var brandId = docRef.id;

    await docRef
        .set({
      'id': brandId,
      'item': selectedProduct!.p_name,
      'count':selectedItemCount,
      'purchase': currentPurchaseCount,
      'pickdate':_purchasedateController.text,
      'duedate': _due_dateController,
      'warehouse': selectedCategory!.c_title,
      'supplier': selectedSupplier!.s_name,
      'quantity':_quantityController,
      'subtotal': subtotal,
      'grand': grandTotal,
      'discount': selectedDiscount!.d_amount,
      'tax': selectedTax!.t_amount,
      'rate': _ratesController,
    })
        .then((value) => print('User Added'))
        .catchError((error) => print('Failed to add user: $error'));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Purchase(),
      ),
    );
  }










  Future<void> increaseItemByOnesupplier(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('supplier')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['purchase'];

      print("CurrentValue $currentValue");

      int? parsedValue = int.tryParse(currentValue);
      if (parsedValue != null) {
        int incrementedValue = parsedValue + 1;
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();
        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('supplier')
            .doc(itemId)
            .update({'purchase': updatedValue});
      } else {
        print("Failed to parse the current value as an integer");
      }

      // int incrementedValue = int.parse(currentValue) + 1;
      //
      // print("incrementedValue $incrementedValue");

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }

  int selectedItemCount =0;


  void calculateGrandTotalwithTax() {
    if (selectedTax != null) {
      double? taxAmount = double.tryParse(selectedTax!.t_amount);
      if (taxAmount != null) {
        if (taxAmount < 1) {
          // Discount amount is a percentage (e.g., 0.6)
          double taxPercentage = taxAmount;
          double taxValue = subtotal * taxPercentage;
          grandTotal = subtotal + taxValue;
          isPercentagetax = true;
        } else {
          // Discount amount is a fixed amount (e.g., 50)
          grandTotal = subtotal + taxAmount;
          isPercentagetax = false;
        }
      } else {
        grandTotal = subtotal;
        isPercentagetax = false;
      }
    } else {
      grandTotal = subtotal;
      isPercentagetax = false;
    }
  }

  void calculateGrandTotal() {
    if (selectedDiscount != null) {
      double? discountAmount = double.tryParse(selectedDiscount!.d_amount);
      if (discountAmount != null) {
        if (discountAmount < 1) {
          // Discount amount is a percentage (e.g., 0.6)
          double discountPercentage = discountAmount;
          double discountValue = subtotal * discountPercentage;
          grandTotal = subtotal - discountValue;
          isPercentageDiscount = true;
        } else {
          // Discount amount is a fixed amount (e.g., 50)
          grandTotal = subtotal - discountAmount;
          isPercentageDiscount = false;
        }
      } else {
        grandTotal = subtotal;
        isPercentageDiscount = false;
      }
    } else {
      grandTotal = subtotal;
      isPercentageDiscount = false;
    }
  }
    void assignGrandTotal() {
      setState(() {
        if (amountPaidController.text.isNotEmpty) {
          double enteredValue = double.parse(amountPaidController.text);
          if( grandTotal!=null ){
            displaybalancedue = grandTotal - enteredValue;
            print("Grand Null Display is $displaybalancedue");
          }
          if( subtotal!=null ){
            displaybalancedue = subtotal - enteredValue;
            print("Sub Null Display is $displaybalancedue");
          }
        } else {
          if (grandTotal != null) {
            displaybalancedue = grandTotal;
            print("Gand Display is $displaybalancedue");
          }
          displaybalancedue = subtotal;
          print("Sub Display is $displaybalancedue");
        }
      });
    }

  String selectedDiscountText = "0"; // Initialize with default value
  String selectedTaxText = "0"; // Initialize with default value

  final _formKey = GlobalKey<FormState>();
  final _formKeyTax = GlobalKey<FormState>();
  Set<ProductModel> selectedProducts = {}; // Initialize the set

  var lable = "";
  final lableController = TextEditingController();
  final amountTextController = TextEditingController();
  String amountText = '';
  String selectedType = 'Amount';

  void addButtonPressed() async {
    double finalAmount = double.parse(amountText);

    if (selectedType == 'Percentage') {
      finalAmount = finalAmount / 100; // Treat as a percentage
    }

    // Perform calculations or further processing with the final amount
    // (e.g., store, display, etc.)

    // Reset the fields or perform any other necessary actions
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('Discount').doc();
    var UnitId = docRef.id;

    await docRef.set({
      'id': UnitId,
      'amount': finalAmount.toString(),
      'type': selectedType,
      'lable': lable
    });
    setState(() {
      amountText = '';
      selectedType = 'Amount';
    });
  }
  TextEditingController amountPaidController = TextEditingController();
  String? balanceDue ="";



  @override

  void dispose() {
    lableController.dispose();
    amountTextController.dispose();
    _dateController?.dispose();
    labletaxController.dispose();
    amountTexttaxController.dispose();
    super.dispose();
  }

  final _formKeytax = GlobalKey<FormState>();

  var labletax = "";
  final labletaxController = TextEditingController();
  final amountTexttaxController = TextEditingController();
  String amounttaxText = '';
  String selectedtaxType = 'Amount';

  void addButtonPressedTax() async {
    double finalAmount = double.parse(amounttaxText);

    if (selectedType == 'Percentage') {
      finalAmount = finalAmount / 100; // Treat as a percentage
    }

    DocumentReference docRef =
        FirebaseFirestore.instance.collection('tax').doc();
    var UnitId = docRef.id;

    await docRef.set({
      'id': UnitId,
      'amount': finalAmount.toString(),
      'type': selectedtaxType,
      'lable': labletax,
    });
    setState(() {
      amountText = '';
      selectedType = 'Amount';
    });
    Navigator.of(context).pop();
  }

  @override
  void _toggleTable() {
    setState(() {
      showTable = !showTable;
    });
  }

  TextEditingController _ratesController = TextEditingController();
  TextEditingController _expiryController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  bool showTable = false;
  List<Map<String, dynamic>> tableData = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int currentPurchaseCount = 0; // Define a variable to hold the current count

  Future<void> fetchPurchaseCount() async {
    DocumentSnapshot documentSnapshot = await firestore
        .collection('purchase')
        .doc('count_document')
        .get();
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey('count')) {
        currentPurchaseCount = data['count'] as int;
      }
    }
  }

  void clearTable() {
    setState(() {
      tableData.clear();
      showTable = false;
    });
  }


  Future<void> increaseItemByOneamount(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('supplier')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['total_paid'];

      print("CurrentValue $currentValue");

      double enteredAmount = double.parse(currentValue);
      if (enteredAmount != null) {
        double incrementedValue = enteredAmount + double.parse(amountPaidController.text);
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();


        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('supplier')
            .doc(itemId)
            .update({'total_paid': updatedValue});
      } else {
        print("Failed to parse the current value as an integer");
      }

      // int incrementedValue = int.parse(currentValue) + 1;
      //
      // print("incrementedValue $incrementedValue");

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }
  Future<void> increaseItemByOnebalance(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('supplier')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['previous'];

      print("CurrentValue $currentValue");

      double enteredAmount = double.parse(currentValue);
      if (enteredAmount != null) {
        double incrementedValue = enteredAmount + displaybalancedue;
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();


        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('supplier')
            .doc(itemId)
            .update({'previous': updatedValue});
      } else {
        print("Failed to parse the current value as an integer");
      }

      // int incrementedValue = int.parse(currentValue) + 1;
      //
      // print("incrementedValue $incrementedValue");

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }


  bool isTableVisible = true;

  Future<void> increaseItemByOne(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Product')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['quantity'];

      print("CurrentValue $currentValue");

      double enteredAmount = double.parse(currentValue);
      if (enteredAmount != null) {
        double incrementedValue =
            enteredAmount + int.parse(_quantityController.text);
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();

        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('Product')
            .doc(itemId)
            .update({'quantity': updatedValue});
      } else {
        print("Failed to parse the current value as an integer");
      }

      // int incrementedValue = int.parse(currentValue) + 1;
      //
      // print("incrementedValue $incrementedValue");

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }

  void _updateSelectedValues(String Itemid) {
    String expiry = _expiryController.text;
    String rates = _ratesController.text;

    // Update selected height and weight in Firebase
    FirebaseFirestore.instance.collection('Product').doc(Itemid).update({
      'rate': rates,
      'expiry': expiry,
    }).then((_) {
      print('Selected values updated successfully');
    }).catchError((error) {
      print('Error updating selected values: $error');
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Object?> getValuesFromFirebase(String Itemid) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('Product').doc(Itemid).get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return {}; // Default empty map if the document doesn't exist
  }

  void buildTable() {
    tableWidget = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 31,
        headingRowColor: MaterialStateColor.resolveWith((states) {
          return Colors.blue;
        }),
        dividerThickness: 3,
        showBottomBorder: true,
        columns: [
          DataColumn(
            label: Text(
              'Product',
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
              'Unit Price',
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
            label: Text(
              'Action',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
        rows: tableData.map((data) {
          return DataRow(
            cells: [
              DataCell(Text(data['Item'])),
              DataCell(Text(data['Quantity'])),
              DataCell(Text(data['Rate'])),
              DataCell(Text(data['Subtotal'])),
              DataCell(
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      isTableVisible = !isTableVisible;
                    });
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  DiscountModel? selectedDiscount;
  TaxModel? selectedTax;

  CategoryModel? selectedCategory;
  SupplierModel? selectedSupplier;
  ProductModel? selectedProduct;

  List<String> amount = ['Amount'];
  String selected11 = '';
  var setvalue11;
  var setvalue;
  String selected = '';
  List<String> supplier = ['Jawad', 'Ali', 'Abu Bakar'];
  String selected1 = '';
  var setvalue1;
  List<String> Item = ['Bag', 'bean', 'hooters'];
  String selected2 = '';
  var setvalue2;
  List<String> payment = ['Cash', 'Check', 'Debit', 'Bank', 'Due'];
  String selected3 = '';
  var setvalue3;
  List<String> Discount = ['D( Rs 10 )', 'D( Rs 30 )', 'D( Rs 5 )'];
  String selected4 = '';
  var setvalue4;
  List<String> tax = ['Tax Of cargo( 10% )', 'For Shipping( 20% )'];
  String selected5 = '';
  var setvalue5;
  double subtotal = 0.0;

  //
  // int newPurchaseCount = currentPurchaseCount + 1;
  // await firestore.collection('your_collection').doc('count_document').set({
  // 'count': newPurchaseCount,
  // });
  void savePurchase(String ItemID) {
    int quantity = int.parse(_quantityController.text);
    double rate = double.parse(_ratesController.text);
    // Calculate the total amount

    subtotal = quantity * rate;
  }

  TextEditingController _purchasedateController = TextEditingController();
  TextEditingController _due_dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "New Purchase",
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
                    const Icon(Icons.login_outlined),
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
        child: Column(
          children: [
            Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Basic Information",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      "Purchase No.",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: TextFormField(
                      enabled: false,
                      initialValue: (currentPurchaseCount + 1).toString(),
                      decoration: InputDecoration(
                        hintText: 'Purchase',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            "Purchase Date",
                            style: GoogleFonts.roboto(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            "Due Date",
                            style: GoogleFonts.roboto(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                              controller: _purchasedateController,
                              decoration: InputDecoration(
                                hintText: 'Pick Date',
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    _dateController?.text =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                  });
                                }
                              }),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            controller: _due_dateController,
                            decoration: InputDecoration(
                              hintText: 'Pick Date',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onTap: () async {
                              DateTime? pickdate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickdate != null) {
                                setState(() {
                                  _due_dateController.text =
                                      DateFormat('yyyy-MM-dd').format(pickdate);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Warehouse",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 10, bottom: 20),
                    child: Container(
                      width: 330,
                      height: 60,
                      padding: EdgeInsets.only(left: 16, right: 0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('warehouse')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          List<CategoryModel> unitItems = [];
                          snapshot.data?.docs.forEach((doc) {
                            String docId = doc.id;
                            String title = doc['item'];
                            unitItems.add(CategoryModel(docId, title));
                          });

                          return DropdownButton<CategoryModel>(
                            iconSize: 40,
                            isExpanded: true,
                            underline: SizedBox(),
                            hint: Text('Select Warehouse'),
                            value: selectedCategory,
                            items: unitItems.map((unit) {
                              return DropdownMenuItem<CategoryModel>(
                                value: unit,
                                child: Text(unit.c_title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                                setvalue = value;
                                print(
                                    'The selected unit ID is ${selectedCategory?.c_id}');
                                print('The selected unit ID1 is $setvalue');
                                print(
                                    'The selected unit title is ${selectedCategory?.c_title}');
                                // Perform further operations with the selected unit
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Suppliers",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 10, bottom: 20),
                    child: Container(
                      width: 330,
                      height: 60,
                      padding: EdgeInsets.only(left: 16, right: 0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('supplier')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          List<SupplierModel> unitItems = [];
                          snapshot.data?.docs.forEach((doc) {
                            String docId = doc.id;
                            String title = doc['name'];
                            unitItems.add(SupplierModel(docId, title));
                          });

                          return DropdownButton<SupplierModel>(
                            iconSize: 40,
                            isExpanded: true,
                            underline: SizedBox(),
                            hint: Text('Select Supplier'),
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
                                setvalue = value;
                                print(
                                    'The selected unit ID is ${selectedSupplier?.s_id}');
                                print('The selected unit ID1 is $setvalue');
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
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Line Item",
                        style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 8),
                    child: Text(
                      "Select Item",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    child: Container(
                        width: 330,
                        height: 60,
                        padding: EdgeInsets.only(left: 16, right: 16),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(15)),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Product')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            List<ProductModel> productItems = [];
                            snapshot.data?.docs.forEach((doc) {
                              String docId = doc.id;
                              String item = doc['item'];
                              productItems.add(ProductModel(docId, item));
                            });

                            // Assign the first brand item as the default selectedBrand
                            return DropdownButton<ProductModel>(
                              iconSize: 40,
                              isExpanded: true,
                              underline: SizedBox(),
                              hint: Text('Select Item'),
                              value: selectedProduct,
                              items: productItems.map((product) {
                                return DropdownMenuItem<ProductModel>(
                                  value: product,
                                  child: Text(product.p_name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedProduct = value;
                                  setvalue = value;
                                  print(
                                      'The selected brand ID is ${selectedProduct!.p_id}');
                                  print(
                                      'The selected brand ID1 is ${setvalue}');
                                  print(
                                      'The selected brand title is ${selectedProduct!.p_name}');
                                  // Perform further operations with the selected brand
                                  if (value != null) {
                                    selectedProducts?.add(value);
                                  } else {
                                    selectedProducts?.remove(selectedProduct);
                                  }

                                  // Update the selected item count
                                  selectedItemCount = selectedProducts.length ?? 0;
                                  print("selectedItemCount is $selectedItemCount");

                                  // Perform further operations with the selected brand

                                  getValuesFromFirebase(selectedProduct!.p_id)
                                      .then((values) {
                                    setState(() {
                                      Map<String, dynamic> data =
                                          values as Map<String, dynamic>;
                                      _quantityController.text =
                                          data['quantity']?.toString() ?? '';
                                      _expiryController.text =
                                          data['expiry'] ?? '';
                                      _ratesController.text =
                                          data['rate']?.toString() ?? '';
                                      selectedProductUnit = data['unit'];
                                      // Update other controller values as needed
                                    });
                                  });

                                  ProductModel selectedProductModel =
                                      productItems.firstWhere(
                                    (product) =>
                                        product.p_name ==
                                            selectedProduct?.p_name &&
                                        product.p_id == selectedProduct?.p_id,
                                    orElse: () => ProductModel('', ''),
                                  );
                                  if (selectedProductModel.p_name.isNotEmpty) {
                                    print(
                                        'Selected Product: ${selectedProductModel.p_name}');
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Container(
                                            height: 600,
                                            width: 320,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Form(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            right: 8,
                                                            top: 25,
                                                            bottom: 8),
                                                    child: Text(
                                                      "${selectedProductModel.p_name} Detail",
                                                      style: GoogleFonts.roboto(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    width: 230,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Stock Information",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 17,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                          Text(
                                                            "Available: ${_quantityController.text}",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 17,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 10),
                                                        child: Text(
                                                          "Item Unit",
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                        ),
                                                      )),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10,
                                                                  right: 10),
                                                          child: TextFormField(
                                                            initialValue:
                                                                selectedProductUnit,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                            ),
                                                            enabled: false,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 10),
                                                        child: Text(
                                                          "Item Quantity",
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                        ),
                                                      )),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10,
                                                                  right: 10),
                                                          child: TextFormField(
                                                            controller:
                                                                _quantityController,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10,
                                                                  top: 10),
                                                          child: Text(
                                                            "Expiry",
                                                            style: GoogleFonts
                                                                .roboto(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 10,
                                                                  top: 10),
                                                          child: TextFormField(
                                                            controller:
                                                                _expiryController,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                            ),
                                                            onTap: () async {
                                                              DateTime?
                                                                  pickdate =
                                                                  await showDatePicker(
                                                                context:
                                                                    context,
                                                                initialDate:
                                                                    DateTime
                                                                        .now(),
                                                                firstDate:
                                                                    DateTime(
                                                                        2000),
                                                                lastDate:
                                                                    DateTime(
                                                                        2101),
                                                              );
                                                              if (pickdate !=
                                                                  null) {
                                                                setState(() {
                                                                  _expiryController
                                                                      .text = DateFormat(
                                                                          'yyyy-MM-dd')
                                                                      .format(
                                                                          pickdate);
                                                                });
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 10),
                                                        child: Text(
                                                          "Rates",
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                        ),
                                                      )),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10,
                                                                  right: 10),
                                                          child: TextFormField(
                                                            controller:
                                                                _ratesController,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 10),
                                                        child: Text(
                                                          "Total ",
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                        ),
                                                      )),
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 20,
                                                                top: 10),
                                                        child: Text(
                                                          "501",
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18),
                                                        ),
                                                      )),
                                                    ],
                                                  ),
                                                  SizedBox(height: 40),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 10,
                                                                right: 10),
                                                        child: Container(
                                                          height: 40,
                                                          width: 80,
                                                          decoration: BoxDecoration(
                                                              color: Colors.grey
                                                                  .shade500,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Center(
                                                            child: Text(
                                                              "Cancel",
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                      Expanded(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 10,
                                                                right: 10),
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            savePurchase(
                                                                selectedProductModel!
                                                                    .p_id);
                                                            setState(() {
                                                              tableData.add({
                                                                'Item':
                                                                    selectedProductModel
                                                                        .p_name,
                                                                'Quantity':
                                                                    _quantityController
                                                                        .text,
                                                                'Rate':
                                                                    _ratesController
                                                                        .text,
                                                                'Subtotal': subtotal
                                                                    .toString(),
                                                              });
                                                              showTable = true;
                                                            });
                                                            setState(() {
                                                              buildTable();
                                                              _toggleTable();
                                                            });
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    Colors.blue,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Center(
                                                              child: Text(
                                                                "Add",
                                                                style: GoogleFonts.roboto(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                            );
                          },
                        )),
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  if (tableWidget != null) tableWidget!,
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Billing",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          "Sub Totals ",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          "Rs. ${subtotal.toString()}",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Row(
                          children: [
                            Text(
                              "Discount",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => showMyDialog());
                                },
                                child: Icon(
                                  FontAwesomeIcons.edit,
                                  color: Colors.black,
                                  size: 18,
                                ))
                          ],
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          "Rs. ${selectedDiscountText}${selectedDiscount != null && double.parse(selectedDiscount!.d_amount) < 1 ? '%' : ''}",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Row(
                          children: [
                            Text(
                              "Tax",
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => showTaxDialog());
                                },
                                icon: Icon(
                                  FontAwesomeIcons.edit,
                                  color: Colors.black,
                                  size: 17,
                                )),
                          ],
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          "Rs. ${selectedTaxText}${selectedTax != null && double.parse(selectedTax!.t_amount) < 1 ? '%' : ''}",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          "Grand Total",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          'Rs. ${selectedDiscount != null && selectedTax != null ?
                          grandTotal.toString() : selectedDiscount != null ?
                          grandTotal.toString() : selectedTax != null ? grandTotal.toString() :
                          subtotal.toString()}',
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 15, right: 15),
                    child: Divider(
                      color: Colors.grey.shade400,
                      thickness: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          "Payment Method",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 14, right: 14, top: 14),
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: [
                                    Container(
                                      width: 150,
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
                                              top: 10, left: 35),
                                          child: Text(
                                            'Cash',
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
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          "Amount Payed",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 10, right: 20),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller:  amountPaidController,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onChanged: (value) {
                              assignGrandTotal();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 15, right: 15),
                    child: Divider(
                      color: Colors.grey.shade400,
                      thickness: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 10),
                        child: Text(
                          "Balance Due",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 50, top: 10),
                        child: Text(
                          "${displaybalancedue.toString()}",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                          ),
                        ),
                      )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, top: 20),
                    child: Container(
                      height: 45.0,
                      width: 320.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade400),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => showExtraDialog());
                        },
                        child: Center(
                          child: Text(
                            'Add Extra Charges',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ignore: deprecated_member_use
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, top: 20),
                          child: Container(
                            height: 45.0,
                            width: 320.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.greenAccent),
                            child: InkWell(
                              onTap: () {},
                              child: Center(
                                child: Text(
                                  'Save & Print',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15, top: 20),
                          child: Container(
                            height: 45.0,
                            width: 320.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => HomeScreen()));

                                _updateSelectedValues(selectedProduct!.p_id);
                                increaseItemByOne(selectedProduct!.p_id);
                                increaseItemByOnebalance(selectedSupplier!.s_id);
                                increaseItemByOneamount(selectedSupplier!.s_id);
                                increaseItemByOnesupplier(selectedSupplier!.s_id);
                              },
                              child: Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
  }

  Widget showMyDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: 600,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 30),
                  child: Text(
                    "Add New Discount",
                    style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          "Lable",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          "Amount",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            controller: lableController,
                            decoration: InputDecoration(
                              hintText: 'Lable',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            controller: amountTextController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 20),
                  child: Text(
                    "Discount",
                    style:
                        GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: Container(
                    height: 60,
                    width: 340,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade400,
                        )),
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: 0,
                        ),
                      ),
                      value: selectedType,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue!;
                        });
                      },
                      items: <String>['Amount', 'Percentage']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, top: 5),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                        child: Text(
                      "OR",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 14),
                    )),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, bottom: 20),
                  child: Text(
                    "Discount",
                    style:
                        GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 329,
                        height: 60,
                        padding: EdgeInsets.only(left: 16, right: 16),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(15)),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Discount')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            List<DiscountModel> discountItems = [];
                            snapshot.data?.docs.forEach((doc) {
                              String docId = doc.id;
                              String amount = doc['amount'];
                              discountItems.add(DiscountModel(docId, amount));
                            });
                            return DropdownButton<DiscountModel>(
                              iconSize: 40,
                              isExpanded: true,
                              underline: SizedBox(),
                              hint: Text("Select Discount"),
                              value: selectedDiscount,
                              items: discountItems.map((discount) {
                                return DropdownMenuItem<DiscountModel>(
                                  value: discount,
                                  child: Text(discount.d_amount),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDiscount = value;
                                  setvalue = value;
                                  selectedDiscountText =
                                      (selectedDiscount != null)
                                          ? selectedDiscount!.d_amount
                                          : "0";

                                  print(
                                      'The selected unit ID is ${selectedDiscount?.d_id}');
                                  print(
                                      'The selected unit ID is ${selectedDiscountText}');

                                  print('The selected unit ID1 is $setvalue');
                                  print(
                                      'The selected unit title is ${selectedDiscount?.d_amount}');
                                  // Perform further operations with the selected unit
                                });
                              },
                            );
                          },
                        ),
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

                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 45.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    child: InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            lable = lableController.text;
                            amountText = amountTextController.text;
                          });
                          Navigator.of(context).pop();
                          addButtonPressed();
                          calculateGrandTotal();
                        } else {
                          Navigator.of(context).pop();
                          calculateGrandTotal();
                        }
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
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showTaxDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: 600,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Form(
            key: _formKeytax,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 30),
                  child: Text(
                    "Add New Tax",
                    style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          "Lable",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          "Amount",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            controller: labletaxController,
                            decoration: InputDecoration(
                              hintText: 'Lable',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            controller: amountTexttaxController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Amount',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 20),
                  child: Text(
                    "Type",
                    style:
                        GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: Container(
                    height: 60,
                    width: 340,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade400,
                        )),
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: 0,
                        ),
                      ),
                      value: selectedtaxType,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedtaxType = newValue!;
                        });
                      },
                      items: <String>['Amount', 'Percentage']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, top: 5),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                        child: Text(
                      "OR",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 14),
                    )),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, bottom: 20),
                  child: Text(
                    "Tax",
                    style:
                        GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 280,
                        height: 60,
                        padding: EdgeInsets.only(left: 16, right: 0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('tax')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            List<TaxModel> unitItems = [];
                            snapshot.data?.docs.forEach((doc) {
                              String docId = doc.id;
                              String title = doc['amount'];
                              unitItems.add(TaxModel(docId, title));
                            });

                            return DropdownButton<TaxModel>(
                              iconSize: 40,
                              isExpanded: true,
                              underline: SizedBox(),
                              hint: Text('Select Tax'),
                              value: selectedTax,
                              items: unitItems.map((unit) {
                                return DropdownMenuItem<TaxModel>(
                                  value: unit,
                                  child: Text(unit.t_amount),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedTax = value;
                                  setvalue = value;
                                  selectedTaxText = (selectedTax != null)
                                      ? selectedTax!.t_amount
                                      : "0";
                                  print(
                                      'The selected unit ID is ${selectedTax?.t_id}');
                                  print('The selected unit ID1 is $setvalue');
                                  print(
                                      'The selected unit title is ${selectedTax?.t_amount}');
                                  // Perform further operations with the selected unit
                                });
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        selected5,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 45.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    child: InkWell(
                      onTap: () {
                        if (_formKeytax.currentState!.validate()) {
                          setState(() {
                            labletax = labletaxController.text;
                            amounttaxText = amountTexttaxController.text;
                          });
                          Navigator.of(context).pop();
                          addButtonPressedTax();
                          calculateGrandTotalwithTax();
                        } else {
                          Navigator.of(context).pop();
                          calculateGrandTotalwithTax();
                        }
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
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showExtraDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: 450,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 30),
                  child: Text(
                    "Add Extra Charges",
                    style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    "Charge Title",
                    style:
                        GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Title',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(
                    "Charge Amount",
                    style:
                        GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 45.0,
                    width: 320.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue),
                    child: InkWell(
                      onTap: () {},
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
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryModel {
  String c_id;
  String c_title;

  CategoryModel(this.c_id, this.c_title);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          c_id == other.c_id;

  @override
  int get hashCode => c_id.hashCode;
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

class ProductModel {
  String p_id;
  String p_name;

  ProductModel(this.p_id, this.p_name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          p_id == other.p_id;

  @override
  int get hashCode => p_id.hashCode;
}

class DiscountModel {
  String d_id;
  String d_amount;

  DiscountModel(this.d_id, this.d_amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscountModel &&
          runtimeType == other.runtimeType &&
          d_id == other.d_id;

  @override
  int get hashCode => d_id.hashCode;
}

class TaxModel {
  String t_id;
  String t_amount;

  TaxModel(this.t_id, this.t_amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxModel &&
          runtimeType == other.runtimeType &&
          t_id == other.t_id;

  @override
  int get hashCode => t_id.hashCode;
}

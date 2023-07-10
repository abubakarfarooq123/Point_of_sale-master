import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/items/product/add_product.dart';
import 'package:pos/sales/quotation.dart';
import 'package:pos/staff/add_suppliers.dart';
import 'package:pos/user/edit_profile.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../splashScreens/loginout.dart';
import '../staff/add_customers.dart';

enum MenuItem {
  item1,
  item2,
}

class Add_Quotation extends StatefulWidget {
  @override
  State<Add_Quotation> createState() => _Add_QuotationState();
}

class _Add_QuotationState extends State<Add_Quotation> {
  double? amountPaid;
  double? taxAdd;
  CustomerModel? selectedCustomer;


  @override
  void initState() {
    super.initState();
    assignGrandTotal();
    calculateGrandTotal();
    getDataFromFirebase();
    calculateGrandTotalwithTax();
    calculatedextragrandtotal();
    _purchasedateController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
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
  bool isPercentageDiscount = false;
  double grandTotal = 0.0; // Add this line above the showMyDialog() method

  bool isPercentagetax = false;
  var pickdate = "";
  var duedate = "";
  var pickdate1 = "";
  var duedate1 = "";


  int currentPurchaseCount = 0;

  add() async {
    DocumentReference docRef =
    FirebaseFirestore.instance.collection('Quotation').doc();
    var brandId = docRef.id;

    await docRef.set({
      'id': brandId,
      'item': selectedProduct!.p_name,
      'count': selectedItemCount,
      'quotation': currentPurchaseCount,
      'pickdate': pickdate1,
      'validdate': duedate1,
      'customer': selectedCustomer!.c_name,
      'subtotal': selectedProducts.length > 1 ? combosubtotal : subtotal,
      'grand': selectedDiscount != null && selectedTax != null
          ? grandTotal
          : selectedDiscount != null
          ? grandTotal
          : selectedTax != null
          ? grandTotal
          : selectedProducts.length > 1
          ? combosubtotal
          : subtotal,
      'discount':
      selectedDiscount?.d_amount != null ? selectedDiscount!.d_amount : 0.0,
      'tax': selectedTax?.t_amount != null ? selectedTax!.t_amount : 0.0,
      'extra': amounts,
    });
    setState(() {
      currentPurchaseCount++;
    });
    await FirebaseFirestore.instance
        .collection('Quotation')
        .doc(brandId)
        .update({'quotation': currentPurchaseCount});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Quotation(),
      ),
    );
  }
  var amounts="";
  var label = "";

  int selectedItemCount = 0;
  double extraamount = 0.0;


  void calculatedextragrandtotal() {
    if (_extraamountController.text != null) {
      double extraAmount = double.tryParse(_extraamountController.text) ?? 0.0;
      double dist = ((selectedTax !=null && selectedDiscount != null) ? grandTotal :
      selectedDiscount != null ? grandTotal : selectedProducts.length > 1 ? combosubtotal : subtotal) +
          extraAmount;
      grandTotal = dist;
    }
  }

  double? discountValue;

  void calculateGrandTotalwithTax() {

    if (selectedTax != null) {
      double? taxAmount = double.tryParse(selectedTax!.t_amount);
      if (taxAmount != null) {
        if (taxAmount < 1) {
          // Discount amount is a percentage (e.g., 0.6)
          double discountPercentage = taxAmount;
          discountValue =
              (selectedDiscount != null ? grandTotal : selectedProducts.length > 1 ? combosubtotal : subtotal) *
                  discountPercentage;
          print("discount val $discountValue");
          taxAdd =
              (selectedDiscount != null ? grandTotal : selectedProducts.length > 1 ? combosubtotal : subtotal) +
                  discountValue!;
          print("Discount Grand Total ${taxAdd.toString()}");
          grandTotal = taxAdd!;
          displaybalancedue = grandTotal;
        } else {
          // Discount amount is a fixed amount (e.g., 50)
          double discountadd =
              (selectedDiscount != null ? grandTotal : selectedProducts.length > 1 ? combosubtotal : subtotal) +
                  taxAmount;
          print("Discount without Percentage Grand Total ${grandTotal.toString()}");
          grandTotal = discountadd;
          displaybalancedue = grandTotal;
        }
      } else {
        grandTotal = selectedProducts.length > 1 ? combosubtotal : subtotal;
        print("No Discount Sub Total ${grandTotal.toString()}");
        displaybalancedue = grandTotal;
      }
    }
  }
  // void calculateGrandTotalwithTax() {
  //   print("Baker ${grandTotal.toString()}");
  //   if (selectedTax != null) {
  //     double? taxAmount = double.tryParse(selectedTax!.t_amount);
  //     if (taxAmount != null) {
  //       if (taxAmount < 1) {
  //         // Discount amount is a percentage (e.g., 0.6)
  //         double taxPercentage = taxAmount;
  //         print("TaxPercentage $taxPercentage");
  //         double taxValue =
  //             ((selectedProducts.length > 1 && selectedDiscount == null) ? combosubtotal : selectedProducts.length == 1 ? subtotal :
  //             (selectedDiscount != null ? grandTotal : subtotal)) * taxPercentage;
  //
  //         grandTotal =
  //             (selectedProducts.length > 1 ? grandTotal : grandTotal) +
  //                 taxValue;
  //         displaybalancedue = grandTotal;
  //         print("Tax Grand Total ${grandTotal.toString()}");
  //         isPercentagetax = true;
  //       } else {
  //         // Discount amount is a fixed amount (e.g., 50)
  //         grandTotal =
  //             (selectedProducts.length > 1 ? grandTotal : grandTotal) +
  //                 taxAmount;
  //         displaybalancedue = grandTotal;
  //         print("Combo Tax Grand Total ${grandTotal.toString()}");
  //         isPercentagetax = false;
  //       }
  //     } else {
  //       grandTotal = selectedProducts.length > 1 ? grandTotal : grandTotal;
  //       displaybalancedue = grandTotal;
  //       print("Simple Tax Grand Total ${grandTotal.toString()}");
  //
  //       isPercentagetax = false;
  //     }
  //   } else {
  //     grandTotal = selectedProducts.length > 1 ? grandTotal : grandTotal;
  //     displaybalancedue = grandTotal;
  //     isPercentagetax = false;
  //   }
  // }

  double? discountadd;

  void calculateGrandTotal() {
    print("SubTotal ${subtotal.toString()}");
    print("Grand ${grandTotal.toString()}");
    print("Discount ${discountadd.toString()}");
    print("GrandTAx ${discountValue.toString()}");

    if(discountadd != null){
      grandTotal = (grandTotal + discountValue!) - discountadd!;
      print("NewGrand $grandTotal");
      if (selectedDiscount != null) {
        double? discountAmount = double.tryParse(selectedDiscount!.d_amount);
        if (discountAmount != null) {
          if (discountAmount < 1) {
            // Discount amount is a percentage (e.g., 0.6)
            double discountPercentage = discountAmount;
            double discountValue =
                (selectedTax != null ? grandTotal : selectedProducts.length > 1 ? combosubtotal : subtotal) *
                    discountPercentage;
            print("discount val $discountValue");
            discountadd =
                (selectedTax != null ? grandTotal:selectedProducts.length > 1 ? combosubtotal : subtotal) -
                    discountValue;
            print("Discount Grand Total ${discountadd.toString()}");
            grandTotal = discountadd!;
            displaybalancedue = grandTotal;
          } else {
            // Discount amount is a fixed amount (e.g., 50)
            double discountadd =
                (selectedTax != null ? grandTotal:selectedProducts.length > 1 ? combosubtotal : subtotal) -
                    discountAmount;
            print("Discount without Percentage Grand Total ${grandTotal.toString()}");
            grandTotal = discountadd;
            displaybalancedue = grandTotal;
          }
        } else {
          grandTotal = selectedProducts.length > 1 ? combosubtotal :subtotal;
          displaybalancedue = grandTotal;
        }
      }
    }
    else{
      if (selectedDiscount != null) {
        double? discountAmount = double.tryParse(selectedDiscount!.d_amount);
        if (discountAmount != null) {
          if (discountAmount < 1) {
            // Discount amount is a percentage (e.g., 0.6)
            double discountPercentage = discountAmount;
            double discountValue =
                (selectedTax != null ? grandTotal : selectedProducts.length > 1 ? combosubtotal : subtotal) *
                    discountPercentage;
            print("discount val $discountValue");
            discountadd =
                (selectedTax != null ? grandTotal:selectedProducts.length > 1 ? combosubtotal : subtotal) -
                    discountValue;
            print("Discount Grand Total ${discountadd.toString()}");
            grandTotal = discountadd!;
            displaybalancedue = grandTotal;
          } else {
            // Discount amount is a fixed amount (e.g., 50)
            double discountadd =
                (selectedTax != null ? grandTotal:selectedProducts.length > 1 ? combosubtotal : subtotal) -
                    discountAmount;
            print("Discount without Percentage Grand Total ${grandTotal.toString()}");
            grandTotal = discountadd;
            displaybalancedue = grandTotal;
          }
        } else {
          grandTotal = selectedProducts.length > 1 ? combosubtotal :subtotal;
          displaybalancedue = grandTotal;
        }
      }
    }
  }

  void assignGrandTotal() {
    print("Grand total balance due ${grandTotal.toString()}");
    print("Grand total balance due ${subtotal.toString()}");

    setState(() {

      if (amountPaidController.text.isNotEmpty) {
        double enteredValue = double.parse(amountPaidController.text);
        print("Grand total Entered ${enteredValue}");
        print("Great Grand total Entered ${grandTotal}");

        if (grandTotal == 0) {
          displaybalancedue = subtotal - enteredValue;
        } else {
          displaybalancedue = grandTotal - enteredValue;
        }

        print("Grand Null Display is $displaybalancedue");
      }
    });
  }

  String selectedDiscountText = "0"; // Initialize with default value
  String selectedTaxText = "0"; // Initialize with default value

  final _formKey = GlobalKey<FormState>();
  final _extraformKeytax = GlobalKey<FormState>();
  Set<ProductModel> selectedProducts = {}; // Initialize the set

  var lable = "";
  final lableController = TextEditingController();
  final amountTextController = TextEditingController();
  final _extraamountController = TextEditingController();
  final _extralableController = TextEditingController();
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
  String? balanceDue = "";

  @override
  void dispose() {
    lableController.dispose();
    amountTextController.dispose();
    _purchasedateController.dispose();
    labletaxController.dispose();
    _extraamountController.dispose();
    super.dispose();
  }

  final _formKeytax = GlobalKey<FormState>();
  final formKey = GlobalKey<FormState>();

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

  String? validationError;
  String? validationErrorsupplier;
  String? validationErroritem;

  TextEditingController _ratesController = TextEditingController();
  TextEditingController _expiryController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  bool showTable = false;
  List<Map<String, dynamic>> tableData = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  getDataFromFirebase() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Quotation')
        .orderBy('quotation')
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Iterate over the retrieved documents
      for (QueryDocumentSnapshot document in snapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        // Access the fields within the document
        var value = data['quotation'];
        // Do something with the retrieved data
        print('Retrieved value: $value');
        currentPurchaseCount = value;
      }
    } else {
      print('No documents found in the collection.');
    }

    print('Current purchase count: $currentPurchaseCount');
  }

  void clearTable() {
    setState(() {
      tableData.clear();
      showTable = false;
    });
  }




  bool isTableVisible = true;



  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Object?> getValuesFromFirebase(String Itemid) async {
    DocumentSnapshot snapshot =
    await _firestore.collection('Product').doc(Itemid).get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return {}; // Default empty map if the document doesn't exist
  }
  bool isButtonClicked = false;


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

  double combosubtotal = 0.0;

  void savePurchase(String ItemID) {
    int quantity = int.parse(_quantityController.text);
    double rate = double.parse(_ratesController.text);
    double itemSubtotal =
        quantity * rate; // Calculate the subtotal for the current item
    if (selectedItemCount > 1) {
      combosubtotal = subtotal + itemSubtotal;
      displaybalancedue = combosubtotal;
      print("Subbbbb tooooo $displaybalancedue");
      print(
          "SUbtotal  is $subtotal"); // Accumulate the subtotal for each selected item
    } else {
      subtotal = itemSubtotal;
      print("Subbbbb tooooo $subtotal");
      displaybalancedue = subtotal;
      print(
          "SUbtotal 2 is $subtotal"); // Accumulate the subtotal for each selected item
    }
    subtotal = itemSubtotal;
    print("Print Subtital for 2 $subtotal");
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
          "New Quotation",
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
        child: Column(
          children: [
            new Form(
              key: formKey,
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
                          "Header",
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
                      "Quote No.",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width / 1.1,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 15),
                        child: Text(
                          (currentPurchaseCount + 1).toString(),
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
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
                            "Quotation Date",
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
                            "Quotation Valid Date",
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
                            readOnly: true, // Prevents keyboard from appearing
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
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: TextFormField(
                            readOnly: true, // Prevents keyboard from appearing
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            controller: _due_dateController,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              ).then((date) {
                                if (date != null) {
                                  setState(() {
                                    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                                    _due_dateController.text = formattedDate;
                                  });
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Customer",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
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
                              Container(
                                width: 279,
                                height: 60,
                                padding: EdgeInsets.only(left: 16, right: 16),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                    borderRadius: BorderRadius.circular(15)),
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
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    List<CustomerModel> discountItems = [];
                                    snapshot.data?.docs.forEach((doc) {
                                      String docId = doc.id;
                                      String name = doc['name'];
                                      discountItems.add(CustomerModel(docId, name));
                                    });
                                    return DropdownButton<CustomerModel>(
                                      iconSize: 40,
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      hint: Text("Select Customer"),
                                      value: selectedCustomer,
                                      items: discountItems.map((customer) {
                                        return DropdownMenuItem<CustomerModel>(
                                          value: customer,
                                          child: Text(customer.c_name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCustomer = value;
                                          setvalue = value;
                                          print('The selected unit ID is ${selectedCustomer?.c_id}');
                                          print('The selected unit ID1 is $setvalue');
                                          print('The selected unit title is ${selectedCustomer?.c_name}');
                                          // Perform further operations with the selected unit
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Add_Customer()));
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.userPlus,
                                    size: 22,
                                    color: Colors.black,
                                  ))
                            ],
                          ),
                          Text(
                            selected1,
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
                  Row(
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
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: Container(
                            width: 279,
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
                                      validationErroritem = null;
                                      print(
                                          'The selected brand ID is ${selectedProduct!.p_id}');
                                      print(
                                          'The selected brand ID1 is ${setvalue}');
                                      print(
                                          'The selected brand title is ${selectedProduct!.p_name}');
                                      // Perform further operations with the selected brand
                                      if (selectedProduct == null) {
                                        validationErroritem =
                                        'Please select an Item';
                                      }

                                      if (value != null) {
                                        selectedProducts?.add(value);
                                      } else {
                                        selectedProducts?.remove(selectedProduct);
                                      }

                                      // Update the selected item count
                                      selectedItemCount =
                                          selectedProducts.length ?? 0;
                                      print(
                                          "selectedItemCount is $selectedItemCount");

                                      // for (var product in selectedProducts) {
                                      //   subtotal += product.price; // Assuming 'price' is the property representing the item's price
                                      //    print("Subtotal combo is : $subtotal");
                                      // }

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
                                                                keyboardType:
                                                                TextInputType
                                                                    .number,
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
                                                                keyboardType:
                                                                TextInputType
                                                                    .number,
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
                        width: 5,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Add_product()));
                          },
                          icon: Icon(
                            FontAwesomeIcons.userPlus,
                            size: 22,
                            color: Colors.black,
                          ))
                    ],
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  if (tableWidget != null) tableWidget!,
                  SizedBox(
                    height: 10,
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
                              "Rs. ${selectedProducts.length > 1 ? combosubtotal.toStringAsFixed(2) : subtotal.toStringAsFixed(2)}",
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
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => showMyDialog());
                                },
                                icon: Icon(
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
                        padding: const EdgeInsets.only(left: 30),
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
                          'Rs. ${_extraamountController.text.isNotEmpty ? grandTotal:
                          (selectedDiscount != null && selectedTax != null) ?
                          grandTotal.toString() : selectedDiscount != null ?
                          grandTotal.toString() : selectedTax != null ?
                          grandTotal.toString() : selectedProducts.length > 1 ?
                          combosubtotal.toStringAsFixed(2) :
                          subtotal.toStringAsFixed(2)}',

                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (isButtonClicked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30, top: 10),
                          child: Text(
                            label,
                            style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              // Reset the extra label, amount, and grand total
                              label = '';
                              amounts = '';
                              grandTotal -= double.tryParse(_extraamountController.text) ?? 0.0;
                              isButtonClicked = false;
                            });
                          },
                        ),

                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 150, top: 10),
                              child: Text(
                                amounts,
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
                    padding:
                        const EdgeInsets.only(top: 10, left: 15, right: 15),
                    child: Divider(
                      color: Colors.grey.shade400,
                      thickness: 1,
                    ),
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
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    pickdate1 = _purchasedateController.text;
                                    duedate1 = _due_dateController.text;
                                  });
                                }
                                add();

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
                SizedBox(
                  height: 20,
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
            key: _extraformKeytax,
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
                    controller: _extralableController,
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
                    controller: _extraamountController,
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
                      onTap: () {
                        if (_extraformKeytax.currentState!.validate()) {
                          setState(() {
                            Navigator.of(context).pop();
                            calculatedextragrandtotal(); // Update the extraamount variable
                            isButtonClicked = true;
                            label = _extralableController.text;
                            amounts = _extraamountController.text;
                          });
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
class CustomerModel {
  String c_id;
  String c_name;

  CustomerModel(this.c_id, this.c_name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomerModel &&
              runtimeType == other.runtimeType &&
              c_id == other.c_id;

  @override
  int get hashCode => c_id.hashCode;
}
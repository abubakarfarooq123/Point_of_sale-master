import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos/cylinder/cylinder_.dart';
import '../../home/drawer.dart';
import '../../splashScreens/loginout.dart';
import '../../user/edit_profile.dart';

enum MenuItem {
  item1,
  item2,
}

class Add_Cylinder extends StatefulWidget {
  const Add_Cylinder({super.key});

  @override
  State<Add_Cylinder> createState() => _Add_CylinderState();
}

class _Add_CylinderState extends State<Add_Cylinder> {
  double remaining = 0.0;

  // add() {
  //   DocumentReference docRef =
  //       FirebaseFirestore.instance.collection('cylinder').doc();
  //   var brandId = docRef.id;
  //
  //   docRef.set({
  //     'id': brandId,
  //     'cylinder': selectedCylinder!.cy_title,
  //     'count': selectedItemCount,
  //     'warehouse': selectedCategory!.c_title,
  //     'purchase': currentPurchaseCount,
  //     'pickdate': pickdate,
  //     'duedate': duedate,
  //     'supplier': selectedSupplier!.s_name,
  //     'today_amount': amountPaidValue,
  //     'quantity': quantity1,
  //     'per_cylinder': grandTotal,
  //     'total': greatgrandTotal,
  //     'weight': selectedCylinder!.amount,
  //     'piad': amounttotoPaidController.text,
  //     'remaining': remaining,
  //     'extra':extraAmountValue,
  //
  //   });
  //   setState(() {
  //     currentPurchaseCount++;
  //   });
  //   FirebaseFirestore.instance
  //       .collection('cylinder')
  //       .doc(brandId)
  //       .update({'purchase': currentPurchaseCount});
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Cylinder(),
  //     ),
  //   );
  // }

  CategoryModel? selectedCategory;
  CylinderModel? selectedCylinder;

  var company = "";
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
  void dispose() {
    companyController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipcodeController.dispose();
    countryController.dispose();
    previous_balanceController.dispose();
    agencyController.dispose();
    commentController.dispose();
    super.dispose();
  }

  int currentPurchaseCount = 0;

  void initState() {
    getDataFromFirebase();
    // Add a listener to the TextEditingController to trigger calculations when text changes
    _purchasedateController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
    super.initState();

  }

  void resetTextField() {
    quantityController.text = '';
    amountPaidController.text = '';
    _extraamountController.text = '';
  }

  int selectedItemCount = 0;

  SupplierModel? selectedSupplier;
  final formKey = GlobalKey<FormState>();

  double grandTotal = 0.0;
  double greatgrandTotal = 0.0;

  Set<CylinderModel> selectedCylinders = {}; // Initialize the set

  void lastvalue() {
    setState(() {
      if (amounttotoPaidController.text.isNotEmpty) {
        double enteredValue = double.parse(amounttotoPaidController.text);
        remaining = (selectedCylinders.length > 1 ? combosubtotal :
        (extragrand != null && extragrand > 0) ? extragrand :
        greatgrandTotal) - enteredValue;
        print("the value remaining is $remaining");
      } else {
        remaining = greatgrandTotal;
      }
    });
  }

  double subtotal = 0.0;
  double previoussubtotal = 0.0;
  double combosubtotal = 0.0;

  double lastRate = 0.0;
  int quantity = 0;
  double rate = 0.0;
  double displaybalancedue = 0.0;

  void assignGrandTotal() {
    setState(() {
      if (amountPaidController.text.isNotEmpty &&
          quantityController.text.isNotEmpty) {
        double enteredValue = double.parse(amountPaidController.text);
        double selectedAmount = selectedCylinder?.amount ?? 0.0;
        double enteredQuantity = double.parse(quantityController.text);

        if (selectedAmount <= 11.8) {
          grandTotal = enteredValue;
          greatgrandTotal = grandTotal * enteredQuantity;

          print("value <= 11.8 is $grandTotal");
          print("value of > 11.8 is $greatgrandTotal");
        } else {
          grandTotal = (enteredValue / 11.8) * selectedAmount;
          greatgrandTotal = grandTotal * enteredQuantity;
          print("value of > 11.8 is $grandTotal");
          print("value of > 11.8 is $greatgrandTotal");
        }
        if (selectedItemCount > 1) {
          combosubtotal = subtotal + greatgrandTotal;
          displaybalancedue = combosubtotal;
          previoussubtotal = greatgrandTotal;
          print("Combosubtotal: $combosubtotal");
        } else {
          subtotal = greatgrandTotal;
          displaybalancedue = subtotal;
          previoussubtotal = subtotal;
          print("Subtotal: $subtotal");
        }
        print('The calculated grandTotal is $grandTotal');
      }
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
        double incrementedValue = enteredAmount + remaining;
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();

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


  double rateWithextra = 0.0;

  double extragrand = 0.0;
  bool showTable = false;
  void _toggleTable() {
    setState(() {
      showTable = !showTable;
    });
  }
  String amountPaidValue='';
  String extraAmountValue ='';
  String quantity1 ='';


  void onSaveButtonPressed() {
    Map<String, dynamic> newData = {
      'Item': selectedCylinder!.cy_title,
      'Weight': selectedCylinder!.amount,
      'Quantity': quantity1,
      'Rate': amountPaidValue,
      'Extra': extraAmountValue,
      'Per': grandTotal,
      'total': greatgrandTotal,
    };

    DocumentReference docRef = FirebaseFirestore.instance.collection('cylinder').doc();
    var brandId = docRef.id;

    docRef.set({
      'id': brandId,
      'cylinder': selectedCylinder!.cy_title,
      'count': selectedItemCount,
      'warehouse': selectedCategory!.c_title,
      'purchase': currentPurchaseCount,
      'pickdate': pickdate,
      'duedate': duedate,
      'supplier': selectedSupplier!.s_name,
      'today_amount': amountPaidValue,
      'quantity': quantity1,
      'per_cylinder': grandTotal,
      'total': greatgrandTotal,
      'weight': selectedCylinder!.amount,
      'piad': amounttotoPaidController.text,
      'remaining': remaining,
      'extra': extraAmountValue,
    });

    saveDataToFirestore(tableData, brandId); // Pass the brandId to the saveDataToFirestore() method

    setState(() {
      currentPurchaseCount++;
    });
    FirebaseFirestore.instance.collection('cylinder').doc(brandId).update({'purchase': currentPurchaseCount});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Cylinder(),
      ),
    );
  }

  void saveDataToFirestore(List<Map<String, dynamic>> data, String brandId) async {
    DocumentReference cylinderDocRef = FirebaseFirestore.instance.collection('cylinder').doc(brandId);

    CollectionReference detailsSubcollectionRef = cylinderDocRef.collection('details');

    QuerySnapshot existingTables = await detailsSubcollectionRef.get();
    existingTables.docs.forEach((doc) => doc.reference.delete());

    List<Future<void>> addOperations = data.map((tableData) {
      return detailsSubcollectionRef.add(tableData);
    }).toList();

    await Future.wait(addOperations);
  }


  void saveDataAndResetFields(BuildContext context) {
    amountPaidValue = amountPaidController.text;
    extraAmountValue = _extraamountController.text;
    quantity1 = quantityController.text;

    Map<String, dynamic> newData = {
      'Item': selectedCylinder!.cy_title,
      'Weight': selectedCylinder!.amount,
      'Quantity': quantity1,
      'Rate': amountPaidValue,
      'Extra': extraAmountValue,
      'Per': grandTotal,
      'total': greatgrandTotal,
    };

    // Add the new data to the tableData list
    setState(() {
      tableData.add(newData);
    });


    resetTextField();
    Navigator.of(context).pop();
  }






  List<Map<String, dynamic>> tableData = [];

  void clearTable() {
    setState(() {
      tableData.clear();
      showTable = false;
    });
  }

  Widget? tableWidget;

  void calculatedextragrandtotal() {
    if (_extraamountController.text.isNotEmpty) {
      double extraAmount = double.tryParse(_extraamountController.text) ?? 0.0;
      double quantity = double.tryParse(quantityController.text) ?? 0.0;
      double amountrate = double.tryParse(amountPaidController.text) ?? 0.0;
      double selectedAmount = selectedCylinder?.amount ?? 0.0;

      double disctamount = extraAmount / quantity;

      rateWithextra = amountrate + disctamount;

      if (selectedAmount <= 11.8) {
        grandTotal = rateWithextra;
        greatgrandTotal = grandTotal * quantity;
        print("object rate withe tehe e$greatgrandTotal");
      } else {
        grandTotal = (rateWithextra / 11.8) * selectedAmount;
        greatgrandTotal = grandTotal * quantity;
        print("object rate withe tehe eauaha $greatgrandTotal");
      }

      print("selectedCylinders length: ${selectedCylinders.length}");
    }

  }
  double extraForSecondProduct = 0.0;
  double extraValueForSecondProduct=0.0;

  void lastextragrand() {
    if (selectedCylinders.length > 1) {
      if (_extraamountController.text.isEmpty) {
        extraForSecondProduct = extragrand;
        print("snhss dghsg  gwg wg $extraForSecondProduct");
        extraValueForSecondProduct =
        (_extraamountController != null &&
            _extraamountController.text.isNotEmpty)
            ? extragrand
            : greatgrandTotal;
        print("11727927922 $extraValueForSecondProduct");
        greatgrandTotal = extraValueForSecondProduct + extraForSecondProduct;
        print("si hhdh hd hdh  $greatgrandTotal");
        extragrand = greatgrandTotal;
      } else {
        print("qiy3wyye7y y  7 y33 $extragrand");
        extragrand += greatgrandTotal;
        print("no no no ononono  $extragrand");
      }
    } else {
      extragrand = greatgrandTotal;
      print("16282  gg g gd $extragrand");
    }


  }
  void updateDataTable(Map<String, dynamic> newData) {
    setState(() {
      tableData.add(newData);
    });
  }


  //
  // double rateWithoutDiscount = 0.0;
  // calculatediscount() {
  //   if (selectedDiscount != null) {
  //     double? discountAmount = double.tryParse(selectedDiscount!.d_amount);
  //     if (discountAmount != null && discountAmount < 1) {
  //       rateWithoutDiscount = lastRate -
  //           ((selectedTax != null ? rateWithoutTax : lastRate) *
  //               discountAmount);
  //
  //       double itemSubtotalWithDiscount = quantity * rateWithoutDiscount;
  //
  //       // Use the original rate for calculations and display
  //       _ratesController.text = rateWithoutDiscount.toString();
  //       print(
  //           "Discount-adjusted rates controller value: ${_ratesController.text}");
  //       print(
  //           "Item subtotal after discount adjustment: $itemSubtotalWithDiscount");
  //
  //       grandTotal = itemSubtotalWithDiscount;
  //       globalGrandTotal = grandTotal;
  //     } else {
  //       double disctamount = discountAmount! / quantity;
  //       rateWithoutDiscount =
  //           (selectedTax != null ? rateWithoutTax : lastRate) - disctamount;
  //       double itemSubtotalWithDiscount = quantity * rateWithoutDiscount;
  //       _ratesController.text = rateWithoutDiscount.toString();
  //       grandTotal = itemSubtotalWithDiscount;
  //       globalGrandTotal = grandTotal;
  //       print("New enw enww ew $grandTotal");
  //       print("New enw enww ew  ahsjgs agjs sg j $rateWithoutDiscount");
  //     }
  //   } else {
  //     grandTotal = previoussubtotal;
  //     print("No Discount Subtotal: ${grandTotal.toString()}");
  //     disc = grandTotal;
  //     globalGrandTotal = grandTotal;
  //   }
  // }
  //
  // double rateWithoutTax = 0.0;
  // calculatetax() {
  //   if (selectedTax != null) {
  //     double? discountAmount = double.tryParse(selectedTax!.t_amount);
  //     if (discountAmount != null && discountAmount < 1) {
  //       rateWithoutTax = lastRate +
  //           ((selectedDiscount != null ? rateWithoutDiscount : lastRate) /
  //               discountAmount);
  //       double itemSubtotalWithDiscount = quantity * rateWithoutTax;
  //
  //       // Use the original rate for calculations and display
  //       _ratesController.text = rateWithoutTax.toString();
  //       print(
  //           "Discount-adjusted rates controller value: ${_ratesController.text}");
  //       print(
  //           "Item subtotal after discount adjustment: $itemSubtotalWithDiscount");
  //
  //       grandTotal = itemSubtotalWithDiscount;
  //     } else {
  //       double disctamount = discountAmount! / quantity;
  //       rateWithoutTax = disctamount! +
  //           (selectedDiscount != null ? rateWithoutDiscount : lastRate);
  //
  //       //  rateWithoutTax = discountAmount! + (selectedDiscount !=null ? rateWithoutDiscount :
  //       // lastRate );
  //
  //       double itemSubtotalWithDiscount = quantity * rateWithoutTax;
  //       _ratesController.text = rateWithoutTax.toString();
  //       grandTotal = itemSubtotalWithDiscount;
  //       print("New enw enww ew $grandTotal");
  //       print("New enw enww ew  ahsjgs agjs sg j $rateWithoutTax");
  //     }
  //   } else {
  //     grandTotal = selectedProducts.length > 1 ? combosubtotal : subtotal;
  //     print("No Tax Sub Total: ${grandTotal.toString()}");
  //     disc = grandTotal;
  //     print("Tax Grand Total: $disc");
  //   }
  // }

  TextEditingController _purchasedateController = TextEditingController();
  TextEditingController _due_dateController = TextEditingController();
  TextEditingController _extraamountController = TextEditingController();

  var pickdate = "";
  var duedate = "";

  getDataFromFirebase() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('cylinder')
        .orderBy('purchase')
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Iterate over the retrieved documents
      for (QueryDocumentSnapshot document in snapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        // Access the fields within the document
        var value = data['purchase'];
        // Do something with the retrieved data
        print('Retrieved value: $value');
        currentPurchaseCount = value;
      }
    } else {
      print('No documents found in the collection.');
    }

    print('Current purchase count: $currentPurchaseCount');
  }

  var setvalue;
  TextEditingController amountPaidController = TextEditingController();
  TextEditingController amounttotoPaidController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Add Cylinder",
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      "Purchase No.",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 18,
                      ),
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            controller: _purchasedateController,
                            readOnly: true,
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            controller: _due_dateController,
                            readOnly: true,
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              ).then((date) {
                                if (date != null) {
                                  setState(() {
                                    final formattedDate =
                                        DateFormat('dd/MM/yyyy').format(date);
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
                      "Warehouse",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 18,
                      ),
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
                      "Supplier",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 10, bottom: 20),
                        child: Container(
                          width: 270,
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
                                return Center(
                                    child: CircularProgressIndicator());
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
                      SizedBox(
                        width: 5,
                      ),
                      IconButton(
                          onPressed: () {
                            showEditProfileDialog(context);
                          },
                          icon: Icon(
                            FontAwesomeIcons.userPlus,
                            size: 27,
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Select Cylinder",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 18,
                      ),
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
                            .collection('cylinder_type')
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
                          List<CylinderModel> unitItems = [];
                          snapshot.data?.docs.forEach((doc) {
                            String docId = doc.id;
                            String title = doc['lable'];
                            double amount = double.parse(
                                doc['amount']); // Convert string to double
                            unitItems.add(CylinderModel(docId, title, amount));
                          });
                          return DropdownButton<CylinderModel>(
                            iconSize: 40,
                            isExpanded: true,
                            underline: SizedBox(),
                            hint: Text('Select Cylinder'),
                            value: selectedCylinder,
                            items: unitItems.map((unit) {
                              return DropdownMenuItem<CylinderModel>(
                                value: unit,
                                child: Text(unit.cy_title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCylinder = value;

                                if (value != null) {
                                  selectedCylinders.add(value);
                                } else {
                                  selectedCylinders.remove(selectedCylinder);
                                }

                                selectedItemCount = selectedCylinders.length ?? 0;

                                print(
                                    "selectedItemCount is $selectedItemCount");
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              content: SingleChildScrollView(
                                                child: Container(
                                                  height: 1300,
                                                  width: 320,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Form(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 5,
                                                        top: 20,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Type:  ',
                                                            style: GoogleFonts.roboto(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            selectedCylinder!
                                                                .cy_title,
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              top: 20,
                                                              bottom: 26),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Weight:    ',
                                                            style: GoogleFonts.roboto(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            "${selectedCylinder!.amount}",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              top: 10),
                                                      child: Text(
                                                        "Enter Quantity",
                                                        style:
                                                            GoogleFonts.roboto(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 8,
                                                          top: 18,
                                                          bottom: 18),
                                                      child: TextFormField(
                                                          controller:
                                                              quantityController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Enter Quantity",
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Please Enter Quantity';
                                                            }
                                                            return null;
                                                          }),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        "Enter Today Rate",
                                                        style:
                                                            GoogleFonts.roboto(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 8,
                                                          top: 18,
                                                          bottom: 18),
                                                      child: TextFormField(
                                                          controller:
                                                              amountPaidController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Enter today rate",
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0),
                                                            ),
                                                          ),
                                                          onFieldSubmitted:
                                                              (value) {
                                                            assignGrandTotal();
                                                          },
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Please Enter rate';
                                                            }
                                                            return null;
                                                          }),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        "Enter Extra Amount",
                                                        style:
                                                        GoogleFonts.roboto(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 8,
                                                          top: 18,
                                                          bottom: 18),
                                                      child: TextFormField(
                                                          controller:
                                                              _extraamountController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Enter Extra Amount",
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0),
                                                            ),
                                                          ),
                                                          onFieldSubmitted:
                                                              (value) {
                                                            calculatedextragrandtotal();
                                                            // This will trigger a rebuild to update the "Total" value
                                                          },
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Please Enter Amount';
                                                            }
                                                            return null;
                                                          }),
                                                    ),

                                                    SizedBox(height: 26),
                                                    Center(
                                                      child: Container(
                                                        height: 40,
                                                        width: 280,
                                                        decoration: BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: InkWell(
                                                          onTap: () {
                                                            saveDataAndResetFields(context);
                                                            lastextragrand();
                                                          },
                                                          child: Center(
                                                              child: Text(
                                                            'Save',
                                                            style: GoogleFonts
                                                                .roboto(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18),
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    });
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 35,
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
                                'Cylinder',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Weight',
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
                                'Today\'s Rate',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Extra Amount',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Per Cylinder Price',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total Price',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Remove',
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
                                DataCell(Text(data['Weight'].toString())),
                                DataCell(Text(data['Quantity'].toString())),
                                DataCell(
                                  Text(
                                    data['Rate'].toString(),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['Extra'].toString(),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['Per'].toString(),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    data['total'].toString(),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        tableData.remove(selectedCylinder); // Remove the row from the data list
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15, top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Total: ",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text(
                          "${
                              selectedCylinders.length > 1 ? combosubtotal :
                              (extragrand != null && extragrand > 0) ? extragrand.toString() :
                          greatgrandTotal.toStringAsFixed(2)}",
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 25),
                    child: Text(
                      "Paid Amount",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: amounttotoPaidController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter Paid Amount",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        lastvalue();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          "Remaining Amount:",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        Text(
                          "${remaining.toStringAsFixed(2)}",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15, top: 20),
                    child: Container(
                      height: 45.0,
                      width: 320.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
                      child: InkWell(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            if (selectedCylinder == null) {
                              // Display error message for missing item selection
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please select cylinder type."),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.fixed,
                                ),
                              );
                            } else if (selectedCategory == null) {
                              // Display error message for missing category selection
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please select a Warehouse."),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.fixed,
                                ),
                              );
                            } else if (selectedSupplier == null) {
                              // Display error message for missing warehouse selection
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please select a Supplier."),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.fixed,
                                ),
                              );
                            } else {
                              // All selections are made, proceed with the add() function
                              setState(() {
                                pickdate = _purchasedateController.text;
                                duedate = _due_dateController.text;
                              });
                              // add();
                              increaseItemByOneamount(selectedSupplier!.s_id);
                              onSaveButtonPressed();
                              print(" it is $currentPurchaseCount");
                            }
                          }
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
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEditProfileDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    add() async {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('supplier').doc();
      var brandId = docRef.id;
      previous_blanace = previous_balanceController.text.trim();
      if (previous_blanace.isEmpty) {
        previous_blanace =
            '0'; // Set default value of '0' if no value is entered
      }
      await docRef
          .set({
            'id': brandId,
            'company': company,
            'name': name,
            'email': email,
            'phone': phone,
            'address': address,
            'city': city,
            'state': state,
            'zip': zipcode,
            'country': country,
            'previous': previous_blanace,
            'total_paid': "0",
            'purchase': "0",
            'comment': comment,
            'agency': agency,
          })
          .then((value) => print('User Added'))
          .catchError((error) => print('Failed to add user: $error'));
      Navigator.of(context).pop();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Implement your edit profile dialog here
        return StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 200),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.clear,
                        size: 32,
                      ),
                    ),
                  ),
                  new Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Company Name',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              icon: Icon(
                                FontAwesomeIcons.building,
                                color: Colors.blue,
                              ),
                            ),
                            controller: companyController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Company Name';
                              }
                              return null;
                            },
                          ),
                        ),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Name';
                                }
                                return null;
                              }),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Email';
                                } else if (!value.contains('@')) {
                                  return 'Please Enter Valid Email';
                                }
                                return null;
                              }),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Phone';
                                }
                                return null;
                              }),
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
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Agency Name',
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
                                  Icons.supervised_user_circle_outlined,
                                  color: Colors.blue,
                                ),
                              ),
                              controller: agencyController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Agency Name';
                                }
                                return null;
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextFormField(
                            minLines: 5,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Comments',
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
                                Icons.comment,
                                color: Colors.blue,
                              ),
                            ),
                            controller: commentController,
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
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  company = companyController.text;
                                  name = nameController.text;
                                  email = emailController.text;
                                  phone = phoneController.text;
                                  address = addressController.text;
                                  city = cityController.text;
                                  state = stateController.text;
                                  zipcode = zipcodeController.text;
                                  country = countryController.text;
                                  previous_blanace =
                                      previous_balanceController.text;
                                  agency = agencyController.text;
                                  comment = commentController.text;
                                });
                                add();
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
        });
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

class CylinderModel {
  String cy_id;
  String cy_title;
  double amount;

  CylinderModel(this.cy_id, this.cy_title, this.amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CylinderModel &&
          runtimeType == other.runtimeType &&
          cy_id == other.cy_id;

  @override
  int get hashCode => cy_id.hashCode;
}

// selectedCylinder != null
//     ? Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//     Row(
//       children: [
//         SizedBox(
//           width: 20,
//         ),
//         Expanded(child: Text('Selected Cylinder:',style: GoogleFonts.roboto(
//           color: Colors.black,
//           fontWeight: FontWeight.bold,
//           fontSize: 18
//         ),)),
//         Expanded(child: Text('${selectedCylinder!.cy_title}',style: GoogleFonts.roboto(
//             color: Colors.black,
//             fontSize: 18
//         ),)),
//       ],
//     ),
//
//     SizedBox(
//       height: 15,
//     ),
//     Row(
//       children: [
//         SizedBox(
//           width: 20,
//         ),
//         Expanded(child: Text('Cylinder Weight:',style: GoogleFonts.roboto(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 18
//         ),)),
//         Expanded(child: Text('${selectedCylinder!.amount}',style: GoogleFonts.roboto(
//             color: Colors.black,
//             fontSize: 18
//         ),)),
//       ],
//     ),
//   ],
// )
//     : Padding(
//       padding: const EdgeInsets.only(left: 20),
//       child: Text('No cylinder selected',style: GoogleFonts.roboto(
//   color: Colors.black,
//   fontWeight: FontWeight.bold,
//   fontSize: 18
// ),),
//     ),
// SizedBox(
//   height: 35,
// ),
// Padding(
//   padding: const EdgeInsets.only(left: 10),
//   child: Text(
//     "Enter Quantity",
//     style:
//     GoogleFonts.roboto(color: Colors.black, fontSize: 18,),
//   ),
// ),
// Padding(
//   padding: EdgeInsets.all(18.0),
//   child: TextFormField(
//     controller: quantityController,
//     keyboardType: TextInputType.number,
//     decoration: InputDecoration(
//       labelText: "Enter Quantity",
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//     ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please Enter Quantity';
//         }
//         return null;
//       }
//   ),
// ),
// SizedBox(
//   height: 15,
// ),
// Padding(
//   padding: const EdgeInsets.only(left: 10),
//   child: Text(
//     "Enter Today Rate",
//     style:
//     GoogleFonts.roboto(color: Colors.black, fontSize: 18,),
//   ),
// ),
// Padding(
//   padding: EdgeInsets.all(18.0),
//   child: TextFormField(
//     controller: amountPaidController,
//     keyboardType: TextInputType.number,
//     decoration: InputDecoration(
//       labelText: "Enter today rate",
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//     ),
//     onFieldSubmitted:
//         (value) {
//       assignGrandTotal();
//     },
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please Enter rate';
//         }
//         return null;
//       }
//   ),
// ),
// SizedBox(
//   height: 20,
// ),
// Row(
//   children: [
//     SizedBox(
//       width: 20,
//     ),
//     Text('Price for single cylinder:',style: GoogleFonts.roboto(
//         color: Colors.black,
//         fontWeight: FontWeight.bold,
//         fontSize: 18
//     )),
//     SizedBox(
//       width: 50,
//     ),
//     Text('${grandTotal.toStringAsFixed(2)}',style: GoogleFonts.roboto(
//         color: Colors.black,
//         fontSize: 18
//     )),
//   ],
// ),
// SizedBox(
//   height: 20,
// ),
// Row(
//   children: [
//     SizedBox(
//       width: 20,
//     ),
//     Text('Total Price:',style: GoogleFonts.roboto(
//         color: Colors.black,
//         fontWeight: FontWeight.bold,
//         fontSize: 18
//     )),
//     SizedBox(
//       width: 140,
//     ),
//     Text('${greatgrandTotal.toStringAsFixed(2)}',style: GoogleFonts.roboto(
//         color: Colors.black,
//         fontSize: 18
//     )),
//   ],
// ),

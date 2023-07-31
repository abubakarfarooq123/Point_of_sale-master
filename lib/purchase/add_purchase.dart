import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
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
  double? amountPaid;
  double? taxAdd;

  @override
  void initState() {
    super.initState();
    assignGrandTotal();
    _extraamountController.addListener(() {
      if (!_extraAmountFocusNode.hasFocus) {
        calculatedextragrandtotal();
      }
    });
    getDataFromFirebase();
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

  int currentPurchaseCount = 0;

  add()  {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('Purchase').doc();
    var brandId = docRef.id;

     docRef.set({
      'id': brandId,
      'item': selectedProduct!.p_name,
      'count': selectedItemCount,
      'purchase': currentPurchaseCount,
      'pickdate': pickdate,
      'duedate': duedate,
      'warehouse': selectedCategory!.c_title,
      'supplier': selectedSupplier!.s_name,
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
    });
    setState(() {
      currentPurchaseCount++;
    });
     FirebaseFirestore.instance
        .collection('Purchase')
        .doc(brandId)
        .update({'purchase': currentPurchaseCount});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Purchase(),
      ),
    );
  }

  var amounts = "";
  var label = "";

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
      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }

  int selectedItemCount = 0;
  double extraamount = 0.0;
  double extragrand = 0.0;

  FocusNode _extraAmountFocusNode = FocusNode();

  double extraValueForSecondProduct=0.0;

  void newextralastgrand() {
    print("Global Discount: $globalGrandTotal");
    print("Tax Global: $taxgrand");
    print("ExtraGlobal: $extragrand");
    if (selectedProducts.length > 1) {
      if (_extraamountController.text.isEmpty) {
        extraForSecondProduct = extragrand;
        print("snhss dghsg  gwg wg $extraForSecondProduct");
        extraValueForSecondProduct =
            (selectedDiscount != null && selectedTax != null)
                ? grandTotal
                : selectedDiscount != null
                    ? grandTotal
                    : (_extraamountController != null &&
                            _extraamountController.text.isNotEmpty)
                        ? grandTotal
                        : grandTotal;
        print("11727927922 $extraValueForSecondProduct");
        grandTotal = extraValueForSecondProduct + extraForSecondProduct;
        print("si hhdh hd hdh  $grandTotal");
        extragrand = grandTotal;
      } else {
        print("qiy3wyye7y y  7 y33 $extragrand");
        extragrand += grandTotal;
        print("no no no ononono  $extragrand");
      }
    } else {
      extragrand = grandTotal;
      print("16282  gg g gd $extragrand");
    }
  }

  double? discountValue;
  double disc = 0.0;

  double? taxValue;
  double globalGrandTotal = 0.0;


  double taxgrand = 0.0;



  double discountForSecondProduct = 0.0;

  double extraForSecondProduct = 0.0;

  double taxForSecondProduct = 0.0;

  double nothingForSecondProduct = 0.0;
  void newlastgrand() {
    print("new last grand global: $globalGrandTotal");
    print("new last grand Tax Global: $taxgrand");
    if (selectedProducts.length > 1) {
      if (selectedTax == null) {
        double taxValueForSecondProduct;
        taxValueForSecondProduct = taxgrand;
        print("haajajakhdjhss $taxValueForSecondProduct");
        discountForSecondProduct = selectedDiscount != null
            ? grandTotal
            : (_extraamountController != null &&
                    _extraamountController.text.isNotEmpty)
                ? grandTotal
                : subtotal;
        print("62228 $discountForSecondProduct");
        grandTotal = discountForSecondProduct + taxValueForSecondProduct;
        print("taxValueForSecondProductjsjsjs $grandTotal");
        print("Updated Tax Grand Total: $grandTotal");
        taxgrand = grandTotal;
        print("Updated Tax Grand Grand Total: $taxgrand");
      } else {
        print("Tax Grand Total: $grandTotal");
        taxgrand += grandTotal;
        print("Updated Tax Grand Total: $taxgrand");
      }
    } else {
      taxgrand = grandTotal;
      print("Updated Tax Grand Total: $taxgrand");
    }
  }


  void newlastgranddiscount() {
    print("new last grand discount Global Discount: $globalGrandTotal");
    print("new last grand discount Tax Global: $taxgrand");
    if (selectedProducts.length > 1) {
      if (selectedDiscount == null && selectedTax == null) {
        double discountValueForSecondProduct;
        discountValueForSecondProduct = globalGrandTotal;
        print("tahat sha pi do do do  $discountValueForSecondProduct");
        nothingForSecondProduct = selectedTax != null
            ? grandTotal
            : (_extraamountController != null &&
                    _extraamountController.text.isNotEmpty)
                ? grandTotal
                : subtotal;
        print("values of the disco $nothingForSecondProduct");
        grandTotal = nothingForSecondProduct + discountValueForSecondProduct;
        print("geto grand total $grandTotal");
        print("Updated Tax Grand Total for disico: $grandTotal");
        globalGrandTotal = grandTotal;
        print("Updated Tax Grand Grand disico Total : $globalGrandTotal");
      }

      if (selectedDiscount == null) {
        double discountValueForSecondProduct;
        discountValueForSecondProduct = globalGrandTotal;
        print("tahat sha pi do do do  $discountValueForSecondProduct");
        taxForSecondProduct = selectedTax != null
            ? grandTotal
            : (_extraamountController != null &&
                    _extraamountController.text.isNotEmpty)
                ? grandTotal
                : subtotal;
        print("values of the disco $taxForSecondProduct");
        grandTotal = taxForSecondProduct + discountValueForSecondProduct;
        print("geto grand total $grandTotal");
        print("Updated Tax Grand Total for disico: $grandTotal");
        globalGrandTotal = grandTotal;
        print("Updated Tax Grand Grand disico Total : $globalGrandTotal");
      } else {
        print("discount disico Grand Total: $grandTotal");
        globalGrandTotal += grandTotal;
        print("Updated Global Grand Total: $globalGrandTotal");
      }
    } else {
      globalGrandTotal = grandTotal;
      print("Updated last Global Grand Total: $taxgrand");
    }
  }

  double? discountadd;

  void assignGrandTotal() {
    print("Grand total balance due ${disc.toString()}");
    print("Grand total balance due ${subtotal.toString()}");

    setState(() {
      if (amountPaidController.text.isNotEmpty) {
        double enteredValue = double.parse(amountPaidController.text);
        print("Grand total Entered ${enteredValue}");
        print("Great Grand total Entered ${grandTotal}");

        if (selectedDiscount != null && selectedTax != null) {
          taxgrand -= enteredValue;
          print("tax last grand $taxgrand");
        } else if (selectedProducts.length > 1 && selectedTax == null) {
          taxgrand -= enteredValue;
          print("tax last aaa grand $taxgrand");
        } else if (selectedDiscount != null) {
          globalGrandTotal -= enteredValue;
          print("tax last global grand $globalGrandTotal");
        } else if (selectedTax != null) {
          taxgrand -= enteredValue;
          print("tax last aaaaa grandta  at a $taxgrand");
        } else {
          grandTotal -= enteredValue;
          print("tax last grandaaaaaaa aaaa $grandTotal");
        }
      }
    });
  }

  String selectedDiscountText = "0"; // Initialize with default value
  String selectedTaxText = "0"; // Initialize with default value

  Set<ProductModel> selectedProducts = {}; // Initialize the set

  var lable = "";
  final lableController = TextEditingController();
  final amountTextController = TextEditingController();
  final _extraamountController = TextEditingController();
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

  String? validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a warehouse';
    }
    return null;
  }


  @override
  void dispose() {
    lableController.dispose();
    amountTextController.dispose();
    _ratesController.dispose();
    _quantityController.dispose();
    _extraamountController.dispose();
    _purchasedateController.dispose();
    labletaxController.dispose();
    amountTexttaxController.dispose();
    _extraamountController.dispose();
    super.dispose();
  }

  void resetTextField() {
    _extraamountController.text = ''; // Clear the text field value
  }

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
        .collection('Purchase')
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

  void clearTable() {
    setState(() {
      tableData.clear();
      showTable = false;
    });
  }

  Future<void> increaseItemByOnewarehouse(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('warehouse')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['cost'];

      print("CurrentValue $currentValue");

      double enteredAmount = double.parse(currentValue);
      if (enteredAmount != null) {
        double incrementedValue = enteredAmount +
            (selectedDiscount != null && selectedTax != null
                ? grandTotal
                : selectedDiscount != null
                    ? grandTotal
                    : selectedTax != null
                        ? grandTotal
                        : selectedProducts.length > 1
                            ? combosubtotal
                            : subtotal);
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();

        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('warehouse')
            .doc(itemId)
            .update({'cost': updatedValue});
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
        double incrementedValue =
            enteredAmount + double.parse(amountPaidController.text);
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
        if (amountPaidController.text != null &&
            amountPaidController.text.isNotEmpty) {
          double incrementedValue = enteredAmount +
              ((selectedDiscount != null && selectedTax != null) ?
              taxgrand : (selectedProducts.length > 1 && selectedTax == null) ?
              taxgrand : selectedDiscount != null
                  ? globalGrandTotal
                  : selectedTax != null ? taxgrand :
              grandTotal);
          print("incrementedValue $incrementedValue");
          String updatedValue = incrementedValue.toString();

          // Now you can use the updatedValue as needed
          await FirebaseFirestore.instance
              .collection('supplier')
              .doc(itemId)
              .update({'previous': updatedValue});
          print("incrementedValue $incrementedValue");

        }
        else {
          double incrementedValue = enteredAmount +
              ((selectedDiscount != null && selectedTax != null) ?
              taxgrand : (selectedProducts.length > 1 && selectedTax == null) ?
              taxgrand : selectedDiscount != null
                  ? globalGrandTotal
                  : selectedTax != null ? taxgrand :
              grandTotal);
          print("incrementedValue $incrementedValue");
          String updatedValue = incrementedValue.toString();

          // Now you can use the updatedValue as needed
          await FirebaseFirestore.instance
              .collection('supplier')
              .doc(itemId)
              .update({'previous': updatedValue});
          print("incrementedValue $incrementedValue");

        }
      }
    }
    catch (error) {
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

  bool isButtonClicked = false;

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
  double previoussubtotal = 0.0;
  double combosubtotal = 0.0;

  double lastRate = 0.0;
  int quantity = 0;
  double rate = 0.0;

  void savePurchase(String itemID) {
    quantity = int.tryParse(_quantityController.text) ?? 0;
    rate = double.tryParse(_ratesController.text) ?? 0.0;
    double itemSubtotal =
        quantity * rate; // Calculate the subtotal for the current item
    lastRate = rate;

    if (selectedItemCount > 1) {
      combosubtotal = subtotal + itemSubtotal;
      disc = combosubtotal;
      displaybalancedue = combosubtotal;
      previoussubtotal = itemSubtotal;
      grandTotal = itemSubtotal;
      print("Combosubtotal: $combosubtotal");
    } else {
      subtotal = itemSubtotal;
      disc = combosubtotal;
      displaybalancedue = subtotal;
      previoussubtotal = subtotal;
      grandTotal = itemSubtotal;
      print("Subtotal: $subtotal");
    }
  }

  double rateWithextra = 0.0;
  void calculatedextragrandtotal() {
    print("ggjgsgjjhgsjjgss $grandTotal");

    if (_extraamountController.text.isNotEmpty) {
      double extraAmount = double.tryParse(_extraamountController.text) ?? 0.0;
      double disctamount = extraAmount! / quantity;
      rateWithextra = ((selectedTax != null && selectedDiscount != null)
              ? rateWithoutTax
              : selectedTax != null
                  ? rateWithoutTax
                  : selectedDiscount != null
                      ? rateWithoutDiscount
                      : lastRate) +
          disctamount;

      double itemSubtotalWithDiscount = quantity * rateWithextra;
      _ratesController.text = rateWithextra.toString();
      grandTotal = itemSubtotalWithDiscount;
      print("rxts u aahhs sh hs h H $extragrand");
    }
  }

  double rateWithoutDiscount = 0.0;
  calculatediscount() {
    if (selectedDiscount != null) {
      double? discountAmount = double.tryParse(selectedDiscount!.d_amount);
      if (discountAmount != null && discountAmount < 1) {
        rateWithoutDiscount = lastRate -
            ((selectedTax != null ? rateWithoutTax : lastRate) *
                discountAmount);

        double itemSubtotalWithDiscount = quantity * rateWithoutDiscount;

        // Use the original rate for calculations and display
        _ratesController.text = rateWithoutDiscount.toString();
        print(
            "Discount-adjusted rates controller value: ${_ratesController.text}");
        print(
            "Item subtotal after discount adjustment: $itemSubtotalWithDiscount");

        grandTotal = itemSubtotalWithDiscount;
        globalGrandTotal = grandTotal;
      } else {
        double disctamount = discountAmount! / quantity;
        rateWithoutDiscount =
            (selectedTax != null ? rateWithoutTax : lastRate) - disctamount;
        double itemSubtotalWithDiscount = quantity * rateWithoutDiscount;
        _ratesController.text = rateWithoutDiscount.toString();
        grandTotal = itemSubtotalWithDiscount;
        globalGrandTotal = grandTotal;
        print("New enw enww ew $grandTotal");
        print("New enw enww ew  ahsjgs agjs sg j $rateWithoutDiscount");
      }
    } else {
      grandTotal = previoussubtotal;
      print("No Discount Subtotal: ${grandTotal.toString()}");
      disc = grandTotal;
      globalGrandTotal = grandTotal;
    }
  }

  double rateWithoutTax = 0.0;
  calculatetax() {
    if (selectedTax != null) {
      double? discountAmount = double.tryParse(selectedTax!.t_amount);
      if (discountAmount != null && discountAmount < 1) {
        rateWithoutTax = lastRate +
            ((selectedDiscount != null ? rateWithoutDiscount : lastRate) /
                discountAmount);
        double itemSubtotalWithDiscount = quantity * rateWithoutTax;

        // Use the original rate for calculations and display
        _ratesController.text = rateWithoutTax.toString();
        print(
            "Discount-adjusted rates controller value: ${_ratesController.text}");
        print(
            "Item subtotal after discount adjustment: $itemSubtotalWithDiscount");

        grandTotal = itemSubtotalWithDiscount;
      } else {
        double disctamount = discountAmount! / quantity;
        rateWithoutTax = disctamount! +
            (selectedDiscount != null ? rateWithoutDiscount : lastRate);

        //  rateWithoutTax = discountAmount! + (selectedDiscount !=null ? rateWithoutDiscount :
        // lastRate );

        double itemSubtotalWithDiscount = quantity * rateWithoutTax;
        _ratesController.text = rateWithoutTax.toString();
        grandTotal = itemSubtotalWithDiscount;
        print("New enw enww ew $grandTotal");
        print("New enw enww ew  ahsjgs agjs sg j $rateWithoutTax");
      }
    } else {
      grandTotal = selectedProducts.length > 1 ? combosubtotal : subtotal;
      print("No Tax Sub Total: ${grandTotal.toString()}");
      disc = grandTotal;
      print("Tax Grand Total: $disc");
    }
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
                                validationError = null;
                                print(
                                    'The selected unit ID is ${selectedCategory?.c_id}');
                                print('The selected unit ID1 is $setvalue');
                                print(
                                    'The selected unit title is ${selectedCategory?.c_title}');
                                // Perform further operations with the selected unit
                                if (selectedCategory == null) {
                                  validationError = 'Please select a warehouse';
                                }
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
                                validationErrorsupplier = null;

                                print(
                                    'The selected unit ID is ${selectedSupplier?.s_id}');
                                print('The selected unit ID1 is $setvalue');
                                print(
                                    'The selected unit title is ${selectedSupplier?.s_name}');
                                // Perform further operations with the selected unit
                                if (selectedSupplier == null) {
                                  validationErrorsupplier =
                                      'Please select a Supplier';
                                }
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
                              productItems.add(ProductModel(docId, item, 0));
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
                                    selectedProducts.add(value);
                                  } else {
                                    selectedProducts.remove(selectedProduct);
                                  }

                                  // Update the selected item count
                                  selectedItemCount =
                                      selectedProducts.length ?? 0;
                                  print(
                                      "selectedItemCount is $selectedItemCount");

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
                                    orElse: () => ProductModel('', '', 0),
                                  );
                                  if (selectedProductModel.p_name.isNotEmpty) {
                                    print(
                                        'Selected Product: ${selectedProductModel.p_name}');
                                    selectedDiscount = null;
                                    selectedTax = null;
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              content: SingleChildScrollView(
                                                child: Container(
                                                  height: 1300,
                                                  width: 320,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Form(
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 8,
                                                                  right: 8,
                                                                  top: 25,
                                                                  bottom: 8),
                                                          child: Text(
                                                            "${selectedProductModel.p_name} Detail",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color:
                                                                  Colors.black,
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
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 10),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  "Stock Information",
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Text(
                                                                  "Available: ${_quantityController.text}",
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        17,
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
                                                                style: GoogleFonts.roboto(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            )),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        right:
                                                                            10),
                                                                child:
                                                                    TextFormField(
                                                                  initialValue:
                                                                      selectedProductUnit,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .grey,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                    ),
                                                                  ),
                                                                  enabled:
                                                                      false,
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
                                                                style: GoogleFonts.roboto(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            )),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        right:
                                                                            10),
                                                                child:
                                                                    TextFormField(
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
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
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
                                                                        left:
                                                                            10,
                                                                        top:
                                                                            10),
                                                                child: Text(
                                                                  "Expiry",
                                                                  style: GoogleFonts.roboto(
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
                                                                        right:
                                                                            10,
                                                                        top:
                                                                            10),
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _expiryController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .grey,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15),
                                                                    ),
                                                                  ),
                                                                  onTap:
                                                                      () async {
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
                                                                      setState(
                                                                          () {
                                                                        _expiryController
                                                                            .text = DateFormat(
                                                                                'yyyy-MM-dd')
                                                                            .format(pickdate);
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
                                                                style: GoogleFonts.roboto(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            )),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        right:
                                                                            10),
                                                                child:
                                                                    TextFormField(
                                                                        keyboardType:
                                                                            TextInputType
                                                                                .number,
                                                                        controller:
                                                                            _ratesController,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(color: Colors.grey, width: 1),
                                                                            borderRadius:
                                                                                BorderRadius.circular(15),
                                                                          ),
                                                                        ),
                                                                        onChanged:
                                                                            (value) {
                                                                          if (value.isNotEmpty &&
                                                                              double.tryParse(value) != null) {
                                                                            savePurchase(selectedProductModel.p_id);
                                                                          }
                                                                        }),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .centerStart,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 10,
                                                                    left: 10,
                                                                    bottom: 10),
                                                            child: Text(
                                                              "Discount",
                                                              style: GoogleFonts.roboto(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 14,
                                                                  right: 14),
                                                          child: Column(
                                                            children: <Widget>[
                                                              Container(
                                                                width: 329,
                                                                height: 60,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            16),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                ),
                                                                child: StreamBuilder<
                                                                    QuerySnapshot>(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Discount')
                                                                      .snapshots(),
                                                                  builder: (BuildContext
                                                                          context,
                                                                      AsyncSnapshot<
                                                                              QuerySnapshot>
                                                                          snapshot) {
                                                                    if (snapshot
                                                                        .hasError) {
                                                                      return Text(
                                                                          'Error: ${snapshot.error}');
                                                                    }
                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return Center(
                                                                          child:
                                                                              CircularProgressIndicator());
                                                                    }
                                                                    List<DiscountModel>
                                                                        discountItems =
                                                                        [];
                                                                    discountItems.add(
                                                                        DiscountModel(
                                                                            '',
                                                                            "Please select discount")); // Add default "Please select discount" option
                                                                    snapshot
                                                                        .data
                                                                        ?.docs
                                                                        .forEach(
                                                                            (doc) {
                                                                      String
                                                                          docId =
                                                                          doc.id;
                                                                      String
                                                                          amount =
                                                                          doc['amount'];
                                                                      discountItems.add(DiscountModel(
                                                                          docId,
                                                                          amount));
                                                                    });

                                                                    // Check if the selectedDiscount is null or the default option, then set it to null
                                                                    if (selectedDiscount ==
                                                                            null ||
                                                                        selectedDiscount!
                                                                            .d_id
                                                                            .isEmpty ||
                                                                        selectedDiscount!.d_amount ==
                                                                            "Please select discount") {
                                                                      selectedDiscount =
                                                                          null;
                                                                    }

                                                                    return DropdownButton<
                                                                        DiscountModel>(
                                                                      iconSize:
                                                                          40,
                                                                      isExpanded:
                                                                          true,
                                                                      underline:
                                                                          SizedBox(),
                                                                      value:
                                                                          selectedDiscount,
                                                                      items: discountItems
                                                                          .map(
                                                                              (discount) {
                                                                        return DropdownMenuItem<
                                                                            DiscountModel>(
                                                                          value:
                                                                              discount,
                                                                          child:
                                                                              Text(discount.d_amount),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(
                                                                            () {
                                                                          selectedDiscount =
                                                                              value;
                                                                          setvalue =
                                                                              value;
                                                                          selectedDiscountText = (selectedDiscount != null)
                                                                              ? selectedDiscount!.d_amount
                                                                              : "0";
                                                                          // calculateGrandTotal();
                                                                          calculatediscount();
                                                                          print(
                                                                              'The selected unit ID is ${selectedDiscount?.d_id}');
                                                                          print(
                                                                              'The selected unit ID is ${selectedDiscountText}');
                                                                          print(
                                                                              'The selected unit ID1 is $setvalue');
                                                                          print(
                                                                              'The selected unit title is ${selectedDiscount?.d_amount}');
                                                                        });
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .centerStart,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 10,
                                                                    left: 10,
                                                                    bottom: 10),
                                                            child: Text(
                                                              "Tax",
                                                              style: GoogleFonts.roboto(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 14,
                                                                  right: 14),
                                                          child: Column(
                                                            children: <Widget>[
                                                              Container(
                                                                width: 280,
                                                                height: 60,
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                ),
                                                                child: StreamBuilder<
                                                                    QuerySnapshot>(
                                                                  stream: FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'tax')
                                                                      .snapshots(),
                                                                  builder: (BuildContext
                                                                          context,
                                                                      AsyncSnapshot<
                                                                              QuerySnapshot>
                                                                          snapshot) {
                                                                    if (snapshot
                                                                        .hasError) {
                                                                      return Text(
                                                                          'Error: ${snapshot.error}');
                                                                    }
                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return Center(
                                                                          child:
                                                                              CircularProgressIndicator());
                                                                    }
                                                                    List<TaxModel>
                                                                        unitItems =
                                                                        [];
                                                                    snapshot
                                                                        .data
                                                                        ?.docs
                                                                        .forEach(
                                                                            (doc) {
                                                                      String
                                                                          docId =
                                                                          doc.id;
                                                                      String
                                                                          title =
                                                                          doc['amount'];
                                                                      unitItems.add(TaxModel(
                                                                          docId,
                                                                          title));
                                                                    });

                                                                    return DropdownButton<
                                                                        TaxModel>(
                                                                      iconSize:
                                                                          40,
                                                                      isExpanded:
                                                                          true,
                                                                      underline:
                                                                          SizedBox(),
                                                                      hint: Text(
                                                                          'Select Tax'),
                                                                      value:
                                                                          selectedTax,
                                                                      items: unitItems
                                                                          .map(
                                                                              (unit) {
                                                                        return DropdownMenuItem<
                                                                            TaxModel>(
                                                                          value:
                                                                              unit,
                                                                          child:
                                                                              Text(unit.t_amount),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged:
                                                                          (value) {
                                                                        setState(
                                                                            () {
                                                                          selectedTax =
                                                                              value;
                                                                          setvalue =
                                                                              value;
                                                                          selectedTaxText = (selectedTax != null)
                                                                              ? selectedTax!.t_amount
                                                                              : "0";
                                                                          calculatetax();
                                                                          // calculateGrandTotalwithTax();
                                                                          // savePurchase(selectedProductModel.p_id);

                                                                          print(
                                                                              'The selected unit ID is ${selectedTax?.t_id}');
                                                                          print(
                                                                              'The selected unit ID1 is $setvalue');
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
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      20.0,
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 30,
                                                                  top: 30),
                                                          child: Text(
                                                            "Add Extra Charges",
                                                            style: GoogleFonts
                                                                .roboto(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 10,
                                                          ),
                                                          child: Text(
                                                            "Charge Amount",
                                                            style: GoogleFonts
                                                                .roboto(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(14.0),
                                                          child: TextFormField(
                                                            controller:
                                                                _extraamountController,
                                                            focusNode:
                                                                _extraAmountFocusNode,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Amount',
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
                                                            onFieldSubmitted:
                                                                (value) {
                                                              calculatedextragrandtotal();
                                                            },
                                                          ),
                                                        ),
                                                        Container(
                                                          alignment:
                                                              AlignmentDirectional
                                                                  .centerStart,
                                                          child: Text(
                                                            // "Rs. ${
                                                            //     (selectedDiscount !=null &&
                                                            //         selectedTax !=null) ?
                                                            //     taxgrand.toString() :
                                                            //     selectedDiscount !=null ?globalGrandTotal.toString()
                                                            //     : selectedTax != null ? taxgrand.toString() :
                                                            //     selectedProducts.length > 1 ? combosubtotal:
                                                            //     subtotal.toString()}",
                                                            grandTotal
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                                child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10,
                                                                      top: 10,
                                                                      right:
                                                                          10),
                                                              child: Container(
                                                                height: 40,
                                                                width: 80,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade500,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Cancel",
                                                                    style: GoogleFonts.roboto(
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
                                                                      right:
                                                                          10),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  amounts =
                                                                      _extraamountController
                                                                          .text;
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  if(selectedTax !=null){
                                                                    newlastgrand();
                                                                  }
                                                                  if(selectedDiscount !=null){
                                                                    newlastgranddiscount();
                                                                  }
                                                                  calculatedextragrandtotal();
                                                                  newextralastgrand();
                                                                  setState(() {
                                                                    tableData
                                                                        .add({
                                                                      'Item': selectedProductModel
                                                                          .p_name,
                                                                      'Quantity':
                                                                          _quantityController
                                                                              .text,
                                                                      'Rate': _ratesController
                                                                          .text,
                                                                      'Subtotal':
                                                                          previoussubtotal,
                                                                      'Discount': (selectedProducts.length > 1 &&
                                                                              selectedDiscount == null)
                                                                          ? '0'
                                                                          : "${selectedDiscountText}${selectedDiscount != null && double.parse(selectedDiscount!.d_amount) < 1 ? '%' : ''}",
                                                                      'Tax': (selectedProducts.length > 1 &&
                                                                              selectedTax == null)
                                                                          ? '0'
                                                                          : "${selectedTaxText}${selectedTax != null && double.parse(selectedTax!.t_amount) < 1 ? '%' : ''}",
                                                                      'Amount': (selectedProducts.length > 1 &&
                                                                          (_extraamountController.text == null ||  _extraamountController.text.isEmpty))
                                                                          ? '0'
                                                                          : amounts.toString(),
                                                                      'Grandtotal':
                                                                      (selectedProducts.length > 1 &&
                                                                          _extraamountController.text.isEmpty) ? extraValueForSecondProduct :
                                                                      (selectedProducts.length > 1 &&
                                                                              selectedTax ==
                                                                                  null)
                                                                          ? discountForSecondProduct
                                                                              .toString()
                                                                          : (selectedProducts.length > 1 && selectedDiscount == null)
                                                                              ? taxForSecondProduct.toString()
                                                                              : grandTotal.toString(),
                                                                    });
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  width: 80,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .blue,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
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
                                            );
                                          });
                                        })
                                      .then((value) {
                                        // Reset the text field value when the dialog is closed
                                        resetTextField();
                                      });
                                  }
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
                  if (tableWidget != null) tableWidget!,
                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
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
                            'Discount',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Tax',
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
                            'Grand Total',
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
                            DataCell(Text(data['Quantity'])),
                            DataCell(Text(data['Rate'])),
                            DataCell(
                              Text(
                                data['Subtotal'].toString(),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['Discount'].toString(),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['Tax'].toString(),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['Amount'].toString(),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['Grandtotal'].toString(),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    tableData.remove(data);  // Remove the row from the data list
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
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
                          'Rs. ${
                              (extragrand != null && extragrand > 0)
                                  ? extragrand.toString() :
                              (selectedDiscount != null && selectedTax != null) ? taxgrand.toString() : (selectedProducts.length > 1 && selectedTax == null) ? taxgrand.toString() : selectedDiscount != null ? globalGrandTotal.toString() : selectedTax != null ? taxgrand.toString() : grandTotal.toString()}',
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
                            controller: amountPaidController,
                            decoration: InputDecoration(
                              hintText: '0',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onFieldSubmitted:
                                (value) {
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
                  SizedBox(
                    height: 10,
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
                          "Rs. ${(selectedDiscount != null && selectedTax != null) ? taxgrand.toString() : (selectedProducts.length > 1 && selectedTax == null) ? taxgrand.toString() : selectedDiscount != null ? globalGrandTotal.toString() : selectedTax != null ? taxgrand.toString() : grandTotal.toString()}",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
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
                          "Total Amount",
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
                          'Rs. ${
                              (extragrand != null && extragrand > 0)
                                  ? extragrand.toString() :
                              (selectedDiscount != null && selectedTax != null) ? taxgrand.toString() : (selectedProducts.length > 1 && selectedTax == null) ? taxgrand.toString() : selectedDiscount != null ? globalGrandTotal.toString() : selectedTax != null ? taxgrand.toString() : grandTotal.toString()}',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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
                              grandTotal -= double.tryParse(
                                      _extraamountController.text) ??
                                  0.0;
                              displaybalancedue = grandTotal;
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
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 25, top: 20),
                  //   child: Container(
                  //     height: 45.0,
                  //     width: 320.0,
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(20),
                  //         color: Colors.grey.shade400),
                  //     child: InkWell(
                  //       onTap: () {
                  //         showDialog(
                  //             context: context,
                  //             builder: (context) => showExtraDialog());
                  //       },
                  //       child: Center(
                  //         child: Text(
                  //           'Add Extra Charges',
                  //           style: TextStyle(
                  //             fontSize: 16.0,
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                              color: Colors.blue,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  if (selectedProduct == null) {
                                    // Display error message for missing item selection
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Please select an Item first."),
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
                                    add();
                                    _updateSelectedValues(selectedProduct!.p_id);
                                    increaseItemByOne(selectedProduct!.p_id);
                                    increaseItemByOnebalance(selectedSupplier!.s_id);
                                    increaseItemByOneamount(selectedSupplier!.s_id);
                                    increaseItemByOnesupplier(selectedSupplier!.s_id);
                                    increaseItemByOnewarehouse(selectedCategory!.c_id);
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
  double p_grandTotal;

  ProductModel(this.p_id, this.p_name, this.p_grandTotal);

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

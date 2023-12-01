import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/sales/sales.dart';
import 'package:pos/staff/add_customers.dart';
import 'package:pos/user/edit_profile.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../splashScreens/loginout.dart';

enum MenuItem {
  item1,
  item2,
}

enum SelectedValue { Retail, Wholesale, Parchoon }

class Add_Sales extends StatefulWidget {
  @override
  State<Add_Sales> createState() => _Add_SalesState();
}

class _Add_SalesState extends State<Add_Sales> {
  SelectedValue selectedRadio = SelectedValue.Retail;

  List<Map<String, dynamic>> tableData = [];
  bool showTable = false;

  Map<String, dynamic> productData = {}; // Initialize as needed

  void clearTable() {
    setState(() {
      tableData.clear();
      showTable = false;
    });
  }

  void initState() {
    super.initState();
    fetchCategories();
    getDataFromFirebase();
    fetchbrands();
    _purchasedateController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  List<String> amount = ['Amount', 'Percentage'];
  String selected = '';
  var setvalue;
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
  TextEditingController _purchasedateController = TextEditingController();
  TextEditingController gramController = TextEditingController();
  TextEditingController _due_dateController = TextEditingController();

  TextEditingController retailController = TextEditingController();
  TextEditingController parchoonController = TextEditingController();
  TextEditingController wholesaleController = TextEditingController();

  List<Map<String, dynamic>> originalProductData =
  []; // Initialize an empty list

// Call your function to fetch product data


  List<Map<String, dynamic>> filteredProductData =
  []; // List to hold filtered product data

  TextEditingController searchController = TextEditingController();
  TextEditingController _amounttenderController = TextEditingController();

  UnitModel? selectedUnit;

  TextEditingController _expiry_date = TextEditingController();
  int currentPurchaseCount = 0;

  void dispose() {
    _purchasedateController.dispose();
    _due_dateController.dispose();
    _amounttenderController.dispose();
    super.dispose();
  }

  String formatQuantityAndUnit(double quantity, String unitString) {
    List<String> unitList = unitString.split(', ');

    if (unitList.length >= 2) {
      String unit1 = unitList[0];
      String unit2 = unitList[1];

      if ((unit1 == unit0Data) && (unit2 == unit1Data)) {
        int bags = (quantity / conversion!).floor();
        double kg = quantity % conversion!;

        if (bags > 0 && kg > 0) {
          return '$bags $unit1Data and ${kg.toStringAsFixed(2)} $unit0Data';
        } else if (bags > 0) {
          return '$bags $unit1Data';
        } else {
          return '${quantity.toStringAsFixed(2)} $unit0Data';
        }
      } else {
        return '${quantity.toStringAsFixed(2)} ${unitList.join(' ')}';
      }
    } else {
      return '${quantity.toStringAsFixed(2)} ${unitList.isNotEmpty
          ? unitList[0]
          : unit0Data}';
    }
  }

  Set<ProductModel> selectedProducts = {}; // Initialize the set
  ProductModel? selectedProduct; // Initialize the set

  final _extraamountController = TextEditingController();

  CustomerModel? selectedCustomer;

  List<String> categories = [
    'All Categories'
  ]; // Initialize with the "All Categories" button
  String selectedCategories = 'All Categories'; // Track the selected category
  List<String> brands = [
    'All Brands'
  ]; // Initialize with the "All Categories" button
  String selectedbrands = 'All Brands'; // Track the selected category

  void fetchCategories() async {
    // Replace this with your Firebase collection reference
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('category').get();

    setState(() {
      categories
          .addAll(snapshot.docs.map((doc) => doc['title'] as String).toList());
    });
  }

  void fetchbrands() async {
    // Replace this with your Firebase collection reference
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('brand').get();

    setState(() {
      brands
          .addAll(snapshot.docs.map((doc) => doc['title'] as String).toList());
    });
  }

  String selectedCategory = 'All Items'; // Initialize with 'All' as default

  double displaybalancedue = 0.0;
  bool isPercentageDiscount = false;
  double grandTotal = 0.0; // Add this line above the showMyDialog() method

  double? discountadd;

  double extraForSecondProduct = 0.0;

  double extraamount = 0.0;
  double extragrand = 0.0;

  double taxForSecondProduct = 0.0;

  double nothingForSecondProduct = 0.0;

  double? discountValue;
  double disc = 0.0;

  double? taxValue;
  double globalGrandTotal = 0.0;

  double taxgrand = 0.0;

  double discountForSecondProduct = 0.0;
  double extraValueForSecondProduct = 0.0;
  bool isPercentagetax = false;

  var pickdate = "";
  var duedate = "";

  bool saleCompleted = false; // Flag to track if the sale is completed

  Future<String> getPreviousBalanceForCustomer(String customerId) async {
    String previousBalance = "";

    DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
        .collection('customer')
        .doc(customerId)
        .get();

    if (customerSnapshot.exists) {
      // If the customer exists, retrieve their previous balance
      previousBalance = customerSnapshot.get('previous') ?? " ";
      print("object objectobjectobjectobjectobject $previousBalance");
    }

    return previousBalance;
  }


  void onSaveButtonPressed(customerId) async {
    String previousBalanceString = await getPreviousBalanceForCustomer(
        customerId);
    double previousBalance = 0.0;

    if (previousBalanceString.isNotEmpty) {
      previousBalance = double.parse(previousBalanceString);
    }

    double valueToSubtract = finalsValue != null && finalsValue != ""
        ? finalsValue
        : selectedfinalDiscount != null ? newdisocunt : selectedfinalTax != null
        ? newTax
        : (extragrand != null && extragrand > 0)
        ? extragrand
        : (selectedDiscount != null && selectedTax != null)
        ? taxgrand
        : (selectedProducts.length > 1 && selectedTax == null)
        ? taxgrand
        : selectedDiscount != null ? globalGrandTotal : selectedTax != null
        ? taxgrand
        : grandTotal; // Display formatted grandTotal

    double incrementedValue;
    String updatedValue = '';

    if (previousBalance != "") {
      incrementedValue = previousBalance + valueToSubtract;
      updatedValue = incrementedValue.toString();
      print("incrementedValue before  $incrementedValue");
    }
    else {
      incrementedValue = valueToSubtract;
      updatedValue = incrementedValue.toString();
      print("incrementedValue after  $incrementedValue");
    }
    DocumentReference docRef =
    FirebaseFirestore.instance.collection('Sales').doc();
    var brandId = docRef.id;

    docRef.set({
      'id': brandId,
      'count': selectedItemCount,
      'purchase': currentPurchaseCount,
      'pickdate': pickdate,
      'duedate': duedate,
      'reverse': "0.0",
      'profit':selectedProducts.length > 1
          ? comboprofit
          : profit,
      'customer': selectedCustomer!.c_name ?? "",
      'subtotal': selectedProducts.length > 1 ? combosubtotal : subtotal ?? "",
      'grand': selectedfinalDiscount != null ? newdisocunt :
      selectedfinalTax != null ? newTax :
      (extragrand != null && extragrand > 0) ? extragrand :
      (selectedDiscount != null && selectedTax != null) ? taxgrand :
      (selectedProducts.length > 1 && selectedTax == null) ? taxgrand :
      selectedDiscount != null ? globalGrandTotal : selectedTax != null ?
      taxgrand : grandTotal,
      'discount':
      selectedfinalDiscount?.d_amount != null
          ? selectedfinalDiscount!.d_amount
          : 0.0,
      'final': finalsValue,
      'due': dueValue,
      'tender': tenderValue,
      'previous': previousBalanceString,
      'after': updatedValue,
    });

    saveDataToFirestore(tableData,
        brandId); // Pass the brandId to the saveDataToFirestore() method

    setState(() {
      currentPurchaseCount++;
    });

    FirebaseFirestore.instance.collection('Sales').doc(brandId).update(
        {'purchase': currentPurchaseCount});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Sales(),
      ),
    );
  }


  void saveDataToFirestore(List<Map<String, dynamic>> data,
      String brandId) async {
    DocumentReference cylinderDocRef = FirebaseFirestore.instance.collection(
        'Sales').doc(brandId);

    CollectionReference detailsSubcollectionRef = cylinderDocRef.collection(
        'details');

    QuerySnapshot existingTables = await detailsSubcollectionRef.get();
    existingTables.docs.forEach((doc) => doc.reference.delete());

    List<Future<void>> addOperations = data.map((tableData) {
      return detailsSubcollectionRef.add(tableData);
    }).toList();

    await Future.wait(addOperations);
  }


  // add(String customerId)  async{
  //
  //   String previousBalanceString = await getPreviousBalanceForCustomer(customerId);
  //   double previousBalance = 0.0;
  //
  //   if (previousBalanceString.isNotEmpty) {
  //     previousBalance = double.parse(previousBalanceString);
  //   }
  //
  //   double valueToSubtract = finalsValue != null && finalsValue != ""
  //       ? finalsValue
  //       : selectedfinalDiscount !=null ? newdisocunt : selectedfinalTax !=null ? newTax : (extragrand != null && extragrand > 0) ? extragrand : (selectedDiscount != null && selectedTax != null) ? taxgrand : (selectedProducts.length > 1 && selectedTax == null) ? taxgrand : selectedDiscount != null ? globalGrandTotal : selectedTax != null ? taxgrand : grandTotal;   // Display formatted grandTotal
  //
  //   double incrementedValue;
  //   String updatedValue ='';
  //
  //   if (previousBalance != "")
  //   {
  //     incrementedValue = previousBalance + valueToSubtract;
  //      updatedValue = incrementedValue.toString();
  //     print("incrementedValue before  $incrementedValue");
  //   }
  //   else {
  //     incrementedValue = valueToSubtract;
  //      updatedValue = incrementedValue.toString();
  //     print("incrementedValue after  $incrementedValue");
  //
  //   }
  //
  //   DocumentReference docRef =
  //       FirebaseFirestore.instance.collection('Sales').doc();
  //   var brandId = docRef.id;
  //
  //   docRef.set({
  //     'id': brandId,
  //     'count': selectedItemCount,
  //     'purchase': currentPurchaseCount,
  //     'pickdate': pickdate,
  //     'duedate': duedate,
  //     'reverse':"0.0",
  //     'customer': selectedCustomer!.c_name ?? "",
  //     'subtotal': selectedProducts.length > 1 ? combosubtotal : subtotal ?? "",
  //     'grand': selectedfinalDiscount !=null ? newdisocunt :
  //     selectedfinalTax !=null ? newTax :
  //     (extragrand != null && extragrand > 0) ? extragrand :
  //     (selectedDiscount != null && selectedTax != null) ? taxgrand :
  //     (selectedProducts.length > 1 && selectedTax == null) ? taxgrand :
  //     selectedDiscount != null ? globalGrandTotal : selectedTax != null ?
  //     taxgrand : grandTotal,
  //     'discount':
  //         selectedfinalDiscount?.d_amount != null ? selectedfinalDiscount!.d_amount : 0.0,
  //     'final':finalsValue,
  //     'due':dueValue,
  //     'tender':tenderValue,
  //     'previous': previousBalanceString,
  //     'after': updatedValue,
  //   });
  //   setState(() {
  //     currentPurchaseCount++;
  //   });
  //   FirebaseFirestore.instance
  //       .collection('Sales')
  //       .doc(brandId)
  //       .update({'purchase': currentPurchaseCount});
  //   saleCompleted = true;
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Sales(),
  //     ),
  //   );
  // }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  getDataFromFirebase() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Sales')
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

  TextEditingController amountPaidController = TextEditingController();

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

  TextEditingController _quantityController = TextEditingController();

  DiscountModel? selectedDiscount;
  DiscountModel? selectedfinalDiscount;
  TaxModel? selectedTax;
  TaxModel? selectedfinalTax;

  double subtotal = 0.0;
  double previoussubtotal = 0.0;
  double combosubtotal = 0.0;

  double lastRate = 0.0;
  double quantity = 0.0;
  double rate = 0.0;

  int selectedItemCount = 0;

  double initialRatesValue =
  0.0; // Store the initial rates value for comparison
  double ratesValue = 0.0;

  double finalsValue = 0.0;
  double dueValue = 0.0;
  double tenderValue = 0.0;
  double previousValue = 0.0;


  ValueNotifier<double> dueNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<double> finalNotifier = ValueNotifier<double>(0.0);

  void amountCalculation() {
    if (_amounttenderController.text.isNotEmpty) {
      tenderValue = double.parse(_amounttenderController.text);
      previousValue =
      (selectedfinalDiscount != null ? newdisocunt : selectedfinalTax != null
          ? newTax
          : (extragrand != null && extragrand > 0)
          ? extragrand
          : (selectedDiscount != null && selectedTax != null)
          ? taxgrand
          : (selectedProducts.length > 1 && selectedTax == null)
          ? taxgrand
          : selectedDiscount != null ? globalGrandTotal : selectedTax != null
          ? taxgrand
          : grandTotal);

      finalsValue = (tenderValue - previousValue).abs();
      print("finalsValuefinalsValue $finalsValue");

      dueValue = 0.0;

      if (tenderValue > previousValue) {
        dueValue = tenderValue - previousValue;
        print("dueValuedueValue $dueValue");
        finalsValue = 0.0;
        dueNotifier.value = dueValue;
        print("dueValuedueValue ${dueNotifier.value}");
      }

      finalNotifier.value = finalsValue; // Update the finalNotifier's value
    }
    else {
      finalsValue = grandTotal;
      finalNotifier.value =
          grandTotal; // Set to 0.0 if _amounttenderController is empty
      dueValue = 0.0;
    }
    setState(() {

    });
  }


  void _updateQuantity(String selectedDropdownValue, productData) {
    ratesValue = double.tryParse(gramController.text)!;

    double originalValue = 0.0;

    if (selectedDropdownValue == productData['unit1Data']) {
      originalValue = double.tryParse(
        selectedRadio == SelectedValue.Wholesale
            ? productData['simple_values'][unit1Data]['wholesale']
            : selectedRadio == SelectedValue.Parchoon
            ? productData['simple_values'][unit1Data]['parchoonval']
            : productData['simple_values'][unit1Data]['retail'],
      ) ??
          0.0;
      print("ajhshshs hshsh s haksjhsks hs $originalValue");
    } else if (selectedDropdownValue == productData['unit0Data']) {
      originalValue = selectedRadio == SelectedValue.Wholesale
          ? productData['divided_values'][unit0Data]['wholesaleval']
          : selectedRadio == SelectedValue.Parchoon
          ? productData['divided_values'][unit0Data]['parchoon']
          : productData['divided_values'][unit0Data]['val'] ?? 0.0;
      print("ajhshshs hshsh s h $originalValue");
    }

    if (ratesValue != 0 && ratesValue != null) {
      if (selectedDropdownValue == productData['unit0Data']) {
        double newRates = ratesValue / originalValue;
        print("ajhshshs hshsh s hsms,ssj $newRates");
        _quantityController.text = newRates.toStringAsFixed(2);
      } else if (selectedDropdownValue == productData['unit1Data']) {
        double eeeRates = ratesValue / originalValue;
        double newratettte = eeeRates * double.parse(productData['conversion']);
        _quantityController.text = newratettte.toStringAsFixed(2);
      }
    }
    double itemcount = ratesValue;

    if (selectedItemCount >= 1) {
      subtotal += itemcount;
      combosubtotal = subtotal;
      grandTotal = itemcount;
      print("Subtotal Old: $grandTotal");
    } else {
      subtotal = itemcount;
      grandTotal = itemcount;
      print("Subtotal old 2222 $subtotal");
    }
  }

  double updatedAvailableQuantity = 0.0;
  double AvailableQuantity = 0.0;

  ValueNotifier<double> grandTotalNotifier = ValueNotifier<double>(0.0);
  String newupdated = '';

  double enteredQuantity = 0.0;

  String currentValue = '';


  Future<void> increaseItemByOneamount(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('customer')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['previous'];

      print("CurrentValue $currentValue");


      double enteredAmount = double.parse(currentValue);

      double valueToSubtract = finalsValue != null && finalsValue != ""
          ? finalsValue
          : selectedfinalDiscount != null ? newdisocunt : selectedfinalTax !=
          null ? newTax : (extragrand != null && extragrand > 0)
          ? extragrand
          : (selectedDiscount != null && selectedTax != null)
          ? taxgrand
          : (selectedProducts.length > 1 && selectedTax == null)
          ? taxgrand
          : selectedDiscount != null ? globalGrandTotal : selectedTax != null
          ? taxgrand
          : grandTotal; // Display formatted grandTotal

      print("valueToSubtract valueToSubtract $valueToSubtract");

      double incrementedValue = enteredAmount + valueToSubtract;

      print("incrementedValue $incrementedValue");
      String updatedValue = incrementedValue.toString();

      await FirebaseFirestore.instance
          .collection('customer')
          .doc(itemId)
          .update({'previous': updatedValue});

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }


  Future<void> increaseItemBytotalspend(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('customer')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['total_spend'];

      print("CurrentValue $currentValue");


      double enteredAmount = double.parse(currentValue);

      double valueToSubtract = tenderValue;

      print("valueToSubtract valueToSubtract $valueToSubtract");

      double incrementedValue = enteredAmount + valueToSubtract;

      print("incrementedValue $incrementedValue");
      String updatedValue = incrementedValue.toString();

      await FirebaseFirestore.instance
          .collection('customer')
          .doc(itemId)
          .update({'total_spend': updatedValue});

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }



  // Future<void> updateInventoryQuantities(productData, String itemId, String selectedDropdownValue) async {
  //   // Initialize with a future timestamp
  //   Timestamp earliestTimestamp = Timestamp.now();
  //
  //   while (true) {
  //     // Retrieve inventories ordered by timestamp
  //     QuerySnapshot inventoryQuerySnapshot = await FirebaseFirestore.instance
  //         .collection('Inventory')
  //         .orderBy('timestamp')
  //         .get();
  //
  //     // Find the earliest inventory with the specified productID
  //     QueryDocumentSnapshot? earliestInventory;
  //     for (QueryDocumentSnapshot inventoryDoc in inventoryQuerySnapshot.docs) {
  //       QuerySnapshot subcollectionQuery = await FirebaseFirestore.instance
  //           .collection('Inventory')
  //           .doc(inventoryDoc.id)
  //           .collection('items')
  //           .where('productID', isEqualTo: itemId)
  //           .get();
  //
  //       if (subcollectionQuery.docs.isNotEmpty) {
  //         Timestamp inventoryTimestamp = (inventoryDoc.data() as Map<String, dynamic>)['timestamp'];
  //         if (inventoryTimestamp.compareTo(earliestTimestamp) < 0) {
  //           earliestTimestamp = inventoryTimestamp;
  //           earliestInventory = inventoryDoc;
  //         }
  //       }
  //     }
  //
  //     // Check if an earliest inventory is found
  //     if (earliestInventory != null) {
  //       QuerySnapshot subcollectionQuery = await FirebaseFirestore.instance
  //           .collection('Inventory')
  //           .doc(earliestInventory.id)
  //           .collection('items')
  //           .where('productID', isEqualTo: itemId)
  //           .get();
  //
  //       // Iterate through items in the earliest inventory
  //       for (QueryDocumentSnapshot subDoc in subcollectionQuery.docs) {
  //         String sellString = (subDoc.data() as Map<String, dynamic>)['quantitytominus'];
  //         double sell = double.tryParse(sellString) ?? 0.0;
  //
  //         double sold = 0.0;
  //
  //         // Check if quantitytominus in the earliest inventory is zero
  //         if (sell == 0) {
  //           // Delete the earliest inventory
  //           await FirebaseFirestore.instance.collection('Inventory').doc(earliestInventory.id).delete();
  //           print('Deleted Inventory with ID: ${earliestInventory.id}');
  //           continue; // Skip updating quantities for this inventory
  //         }
  //
  //         // Your existing logic for updating quantities based on selectedDropdownValue
  //         if (selectedDropdownValue == productData['unit0Data']) {
  //           sold = sell - quantity;
  //         }
  //         else if (selectedDropdownValue == productData['unit1Data']) {
  //           if(sell < conversion!){
  //             sold = sell - quantity;
  //           }
  //           else{
  //             double converrrrss = sell / conversion!;
  //             print("sold $converrrrss");
  //             double newq = converrrrss - quantity;
  //             print("hshs $newq");
  //             sold = newq * conversion!;
  //             print("lastqqq lastqqq $sold");
  //           }
  //
  //         }
  //         else {
  //           print("Pata ni yar");
  //         }
  //
  //         // Update sell and quantitytominus
  //         await FirebaseFirestore.instance
  //             .collection('Inventory')
  //             .doc(earliestInventory.id)
  //             .collection('items')
  //             .doc(subDoc.id)
  //             .update({'sell': sold.toStringAsFixed(2), 'quantitytominus': sold.toStringAsFixed(2)});
  //
  //         print('Sell value updated for Inventory ID: ${earliestInventory.id}, Document ID: ${subDoc.id}');
  //       }
  //     } else {
  //       // No more relevant inventories found, exit the loop
  //       break;
  //     }
  //   }
  // }

  Future<void> increaseItemByOneInvoice(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('customer')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['invoices'];

      print("CurrentValue $currentValue");

      int? parsedValue = int.tryParse(currentValue);
      if (parsedValue != null) {
        int incrementedValue = parsedValue + 1;
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();
        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('customer')
            .doc(itemId)
            .update({'invoices': updatedValue});
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


  Future<void> increaseItemQuantity(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Product')
          .doc(itemId)
          .get();
      currentValue = snapshot.data()!['quantity'];

      print("CurrentValue $currentValue");

      double? enteredAmount = double.parse(currentValue);
      if (enteredAmount != null) {
        enteredAmount = newaahaha;
        print("incrementedValue $enteredAmount");
        String updatedValue = enteredAmount.toString();

        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('Product')
            .doc(itemId)
            .update({'quantity': updatedValue});
      }
      else {
        print("Failed to parse the current value as an integer");
      }

      print('Item value incremented successfully.');
    } catch (error) {

    }
    setState(() {});
  }



  Future<void> quantitytill(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Product')
          .doc(itemId)
          .get();

      String currentValue = snapshot.data()!['tillquantitysale'];
      print("CurrentValue tillquantitysale$currentValue");

      double updatedValue = quantity + double.parse(currentValue);
      double updatedValueString = updatedValue;
      print("updatedValueString tillquantitysale $updatedValueString");

      await FirebaseFirestore.instance
          .collection('Product')
          .doc(itemId)
          .update({'tillquantitysale': updatedValueString.toStringAsFixed(2),
      });
      print('Item value updated successfully.');
    } catch (error) {
      print('Error updating item value: $error');
    }
  }

  Future<void> tillgrand(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Product')
          .doc(itemId)
          .get();

      String currentValue = snapshot.data()!['tillgrandsale'];
      print("CurrentValue $currentValue");

      double updatedValue = selectedDiscount != null && selectedTax != null
          ? grandTotal
          : selectedDiscount != null
          ? grandTotal
          : selectedTax != null
          ? grandTotal
          : selectedProducts.length > 1
          ? combosubtotal
          : subtotal + double.parse(currentValue);

      double updatedValueString = updatedValue;
      print("tillgrandsale tillgrandsale $updatedValueString");

      await FirebaseFirestore.instance
          .collection('Product')
          .doc(itemId)
          .update({'tillgrandsale': updatedValueString.toStringAsFixed(2),
      });
      print('Item value updated successfully.');
    } catch (error) {
      print('Error updating item value: $error');
    }
  }



  Future<void> updateInventoryQuantities(productData, String itemId, String selectedDropdownValue) async {
    // Initialize with a future timestamp
    Timestamp earliestTimestamp = Timestamp.now();

    // Retrieve inventories ordered by timestamp
    QuerySnapshot inventoryQuerySnapshot = await FirebaseFirestore.instance
        .collection('Inventory')
        .get();

    QueryDocumentSnapshot? earliestInventory;

    List<QueryDocumentSnapshot> items = [];

    for (QueryDocumentSnapshot inventoryDoc in inventoryQuerySnapshot.docs) {
      QuerySnapshot subcollectionQuery = await FirebaseFirestore.instance
          .collection('Inventory')
          .doc(inventoryDoc.id)
          .collection('items')
          .orderBy('timestamp', descending: false)
          .where('productID', isEqualTo: itemId)
          .get();

      items.addAll(subcollectionQuery.docs);

      print("Total Length of Matching Documents: ${items.length}");

      print("subcollectionQuery Length ${subcollectionQuery.docs.length}");


      if (subcollectionQuery.docs.isNotEmpty) {
        Timestamp inventoryTimestamp = (inventoryDoc.data() as Map<String, dynamic>)['timestamp'];
        if (inventoryTimestamp.compareTo(earliestTimestamp) < 0) {
          earliestTimestamp = inventoryTimestamp;
          earliestInventory = inventoryDoc;
        }
      }
    }

    // Check if an earliest inventory is found
    if (earliestInventory != null) {
      CollectionReference itemsCollection = FirebaseFirestore.instance.collection('Inventory').doc(earliestInventory.id).collection('items');

      QuerySnapshot subcollectionQuery = await itemsCollection.where('productID', isEqualTo: itemId).get();


      print("itemsCollection ${itemsCollection.id}");
      int counter = 0;

      for (QueryDocumentSnapshot subDoc in subcollectionQuery.docs) {

        counter++;

        String see = (subDoc.data() as Map<String, dynamic>)['quantitytominus'];
        print("see see see $see");
        double sell = double.parse(see);
        // Calculate the new sold value
        double newSold = 0.0;
        double latest = 0.0;

        if (selectedDropdownValue == productData['unit0Data']) {
          newSold = sell - quantity;
          if(quantity > sell){
            latest = newSold;
            newSold = 0.0;
            print("object 111 $latest");
          }
          else{
            latest = newSold;
          }
        } else if (selectedDropdownValue == productData['unit1Data']) {
          if (sell < conversion!) {
            newSold = sell - quantity;
            if(quantity > sell){
              latest = newSold;
              print("object 222 $latest");
              newSold = 0.0;
            }
            else{
              latest = newSold;
            }
          }
          else {
            double converrrrss = sell / conversion!;
            double newq = converrrrss - quantity;
            newSold = newq * conversion!;
            if(quantity > sell){
              latest = newSold;
              print("object 333 $latest");
              newSold = 0.0;
            }
            else{
              latest = newSold;
            }
          }
        } else {
          print("Pata ni yar");
        }

        if (latest <= 0) {
          // If the remaining quantity is zero or negative, delete the current item document
          await itemsCollection.doc(subDoc.id).delete();

          print("Deleted item with ID: ${subDoc.id}");


          // Get the next least timed same id collection and minus the remaining quantities from that
          QuerySnapshot secondTimestampInventoryQuerySnapshot = await FirebaseFirestore.instance
              .collection('Inventory')
              .doc(earliestInventory.id)
              .collection('items')
              .orderBy('timestamp', descending: false) // Order by timestamp in ascending order
              .where('productID', isEqualTo: itemId)
              .get();

          print("secondTimestampInventoryQuerySnapshot ${secondTimestampInventoryQuerySnapshot.docs.length}");

          if (secondTimestampInventoryQuerySnapshot.docs.isNotEmpty) {
            QueryDocumentSnapshot secondTimestampInventory = secondTimestampInventoryQuerySnapshot.docs[0];

            double newwuaa = double.parse((secondTimestampInventory.data() as Map<String, dynamic>)['quantitytominus']);

            double newvalue1 = newwuaa - latest;
            print("newvalue1newvalue1 $newvalue1");
            await FirebaseFirestore.instance
                .collection('Inventory')
                .doc(earliestInventory.id)
                .collection('items')
                .doc(secondTimestampInventory.id)
                .update({'quantitytominus': newvalue1.toStringAsFixed(2)});
          }
          else {
            // Handle the case where no matching documents are found in the next collection
            // You might want to log an error or take other appropriate actions
            print("No matching documents found in the next collection.");
          }


          // Break out of the loop
          break;
        }

        // Update sell and quantitytominus
        await FirebaseFirestore.instance
            .collection('Inventory')
            .doc(earliestInventory.id)
            .collection('items')
            .doc(subDoc.id)
            .update({'sell': newSold.toStringAsFixed(2), 'quantitytominus': newSold.toStringAsFixed(2)});

        print('Sell value updated for Inventory ID: ${earliestInventory.id}, Document ID: ${subDoc.id}');
      }
    }
  }







  Future<void> increaseItemByOne(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Product')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['additional'];

      print("CurrentValue $currentValue");

      double enteredAmount = double.parse(currentValue);
      if (enteredAmount != null) {
        double incrementedValue = enteredAmount + newaaaavailable;
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();

        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('Product')
            .doc(itemId)
            .update({'additional': updatedValue});
      } else {
        print("Failed to parse the current value as an integer");
      }

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }

  void updatedvalues(String selectedDropdownValue, productData) {
    if (selectedDropdownValue == productData['unit1Data']) {
      parchoonController.text =
          productData['simple_values'][unit1Data]?['parchoonval']?.toString() ??
              'N/A';
      retailController.text =
          productData['simple_values'][unit1Data]?['retail']?.toString() ??
              'N/A';
      wholesaleController.text =
          productData['simple_values'][unit1Data]?['wholesale']?.toString() ??
              'N/A';
    } else if (selectedDropdownValue == productData['unit0Data']) {
      parchoonController.text =
          productData['divided_values'][unit0Data]?['parchoon']?.toString() ??
              'N/A';
      retailController.text =
          productData['divided_values'][unit0Data]?['val']?.toString() ?? 'N/A';
      wholesaleController.text = productData['divided_values'][unit0Data]
                  ?['wholesaleval']
              ?.toString() ??
          'N/A';
    } else {
      print("No Value");
    }
  }

  double newaaaavailable = 0.0;

  double newaahaha = 0.0;

  double lastqqq = 0.0;

  // Map<String, double> itemQuantities = {};
  Map<String, double> newaahahaMap = {};


  void savePurchase(productData, String selectedDropdownValue) {
    quantity = double.tryParse(_quantityController.text) ?? 0;

    rate = double.tryParse(selectedRadio == SelectedValue.Wholesale
            ? wholesaleController.text
            : selectedRadio == SelectedValue.Parchoon
                ? parchoonController.text
                : retailController.text) ??
        0.0;
    double itemSubtotal = quantity *
        rate; // Use ratesValue if not null, otherwise calculate itemSubtotal

    lastRate = rate;

    enteredQuantity = double.tryParse(_quantityController.text) ?? 0;
    double originalAvailableQuantity = double.parse(productData['quantity']);

    String productId = productData['id']; // Replace 'id' with the actual ID field name

    if (selectedDropdownValue == productData['unit1Data']) {
      if (productData['unit0Data'] == "") {
        AvailableQuantity = originalAvailableQuantity;
        updatedAvailableQuantity = (AvailableQuantity - enteredQuantity).abs();


        if (enteredQuantity > originalAvailableQuantity) {
          newaaaavailable = updatedAvailableQuantity;
          newaahaha = 0.0;
          print("productData['available'] ${available}");
        } else {
          setState(() {
            newaahaha = updatedAvailableQuantity;
          });

          print("productData['available'] ${available}");
        }
      } else if (productData['unit0Data'] != "") {
        String conversionString111 = productData['conversion'];
        conversionString111 =
            conversionString111.replaceAll(',', ''); // Remove commas
        double itemConversionaaaaa =
            double.tryParse(conversionString111) ?? 1.0;

        AvailableQuantity = originalAvailableQuantity / itemConversionaaaaa;
        print("AvailableQuantityAvailableQuantity $AvailableQuantity");
        updatedAvailableQuantity = (AvailableQuantity - enteredQuantity).abs();
        print(
            "updatedAvailableQuantity updatedAvailableQuantity $updatedAvailableQuantity");
        lastqqq = updatedAvailableQuantity * itemConversionaaaaa;
        print("lastqqq lastqqq $lastqqq");

        if (enteredQuantity > originalAvailableQuantity) {
          newaaaavailable = updatedAvailableQuantity * conversion!;
          newaahaha = 0.0;
          print("productData['available'] ${available}");
        } else {
          setState(() {
            newaahaha = lastqqq;
          });

          print("productData['available'] ${available}");
        }
      }
    }
    else if (selectedDropdownValue == productData['unit0Data']) {
      AvailableQuantity = originalAvailableQuantity;
      updatedAvailableQuantity = (AvailableQuantity - enteredQuantity).abs();
      if (enteredQuantity > originalAvailableQuantity) {
        newaaaavailable = updatedAvailableQuantity;
        newaahaha =0.0;
        print("productData['available'] ${available}");
      } else {
        setState(() {
          newaahaha = updatedAvailableQuantity;
        });

        print("productData['available'] ${available}");
      }
    }

    dynamic unitData = productData['unit'];

    newupdated = formatQuantityAndUnit(lastqqq, unitData.join(', '));

    if (enteredQuantity > originalAvailableQuantity) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Insufficient Quantity'),
            content: Column(
              children: [
                Text("You have Enter $newupdated more than Available Quantity"),
                Text(
                    "You don't have that much quantity. Do you still want to add the value?"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialogue
                  setState(() {
                    available = formatQuantityAndUnit(0.0, unitData.join(', '));
                    productData['available'] = available;
                  });
                  _updateUIAndContinueSaving(productData, itemSubtotal);
                },
                child: Text('OK, Add It'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialogue
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } else {
      _updateUIAndContinueSaving(productData, itemSubtotal);
    }
    setState(() {});
  }

  void _updateUIAndContinueSaving(productData, double itemSubtotal) {
    if (selectedItemCount >= 1) {
      print("TtTTTubtotal: $itemSubtotal");
      subtotal += itemSubtotal; // Accumulate the subtotal for all items
      print("Double Subtotalajajajaja: $subtotal");
      combosubtotal = subtotal;
      print("Double Subtotalajajajajaaaaekiujkssa: $combosubtotal");
      disc = combosubtotal;
      displaybalancedue = combosubtotal;
      previoussubtotal = itemSubtotal;
      grandTotal = itemSubtotal;
      grandTotalNotifier.value =
          grandTotal; // Notify listeners about the change

      print("Double Subtotal: $subtotal");
    } else {
      subtotal = itemSubtotal;
      disc = combosubtotal;
      displaybalancedue = subtotal;
      previoussubtotal = subtotal;
      grandTotal = itemSubtotal;
      grandTotalNotifier.value =
          grandTotal; // Notify listeners about the change
      print("Single Subtotal $subtotal");
    }

    setState(() {});
  }

  void retrieveOriginalValues(String itemId) async {
    // Get the original values from the database
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Product')
        .doc(itemId)
        .get();
    double? new11 = snapshot.data()?['quantity'];

    setState(() {
      double latest = newaahaha + new11! ?? 0.0;
      print("latestlatestlatest $latest");
      FirebaseFirestore.instance
          .collection('Product')
          .doc(itemId)
          .update({'quantity': latest.toString()});
    });
  }
  // void onPop() {
  //   retrieveOriginalValues(productData['id']);
  //   _quantityController.clear();
  //   Navigator.of(context).pop();
  // }

  var amounts = "";

  final formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> selectedItemsData = [];

  void saveDataAndResetFields(
      BuildContext context, productData, String selectedDropdownValue) {
    amounts = _extraamountController.text;

    Map<String, dynamic> newData = {
      'Item': productData['name'],
      'Quantity':
          '${_quantityController.text} ${selectedDropdownValue == productData['unit1Data'] ? productData['unit1Data'] : productData['unit0Data']}',
      'Rate': selectedRadio == SelectedValue.Wholesale
          ? wholesaleController.text
          : selectedRadio == SelectedValue.Parchoon
              ? parchoonController.text
              : retailController.text,
      'Subtotal': previoussubtotal,
      'Discount': (selectedProducts.length > 1 && selectedDiscount == null)
          ? '0'
          : "${selectedDiscountText}${selectedDiscount != null && double.parse(selectedDiscount!.d_amount) < 1 ? '%' : ''}",
      'Tax': (selectedProducts.length > 1 && selectedTax == null)
          ? '0'
          : "${selectedTaxText}${selectedTax != null && double.parse(selectedTax!.t_amount) < 1 ? '%' : ''}",
      'Amount': (selectedProducts.length > 1 &&
              (_extraamountController.text == null ||
                  _extraamountController.text.isEmpty))
          ? '0'
          : amounts.toString(),
      'Grandtotal':
          (selectedProducts.length > 1 && _extraamountController.text.isEmpty)
              ? extraValueForSecondProduct
              : (selectedProducts.length > 1 && selectedTax == null)
                  ? discountForSecondProduct.toString()
                  : (selectedProducts.length > 1 && selectedDiscount == null)
                      ? taxForSecondProduct.toString()
                      : grandTotal.toString(),
    };
    setState(() {
      tableData.add(newData);
    });

    Map<String, dynamic> itemData = {
      'itemId': selectedProduct!.p_id,
      'quantity': _quantityController.text,
    };

    selectedItemsData.add(itemData);


    resetTextField();
    print(newData);
  }

  void completePurchase() async {
    for (Map<String, dynamic> itemData in selectedItemsData) {
      String itemId = itemData['itemId'];
      String quantity = itemData['quantity'];

      await increaseItemQuantity(itemId);
    }
  }


  double rateWithextra = 0.0;
  void calculatedextragrandtotal() {
    if (_extraamountController.text.isNotEmpty) {
      double extraAmount = double.tryParse(_extraamountController.text) ?? 0.0;
      double disctamount = extraAmount / quantity;
      rateWithextra = ((selectedTax != null && selectedDiscount != null)
              ? rateWithoutTax
              : selectedTax != null
                  ? rateWithoutTax
                  : selectedDiscount != null
                      ? rateWithoutDiscount
                      : lastRate) +
          disctamount;

      double itemSubtotalWithDiscount = quantity * rateWithextra;
      selectedRadio == SelectedValue.Wholesale
          ? wholesaleController.text
          : selectedRadio == SelectedValue.Parchoon
              ? parchoonController.text
              : retailController.text = rateWithextra.toString();
      grandTotal = itemSubtotalWithDiscount;
      grandTotalNotifier.value =
          grandTotal; // Notify listeners about the change
    }
  }

  double selectedValue =0.0;

  double profit =0.0;

  double purchaseval = 0.0;

  double comboprofit =0.0;
  double subprofit =0.0;

  double itemsub=0.0;

  void profitcalculation(String selectedDropdownValue, productData) {

    print("gagrsfsfsgs $grandTotal");

    selectedValue = double.parse(selectedRadio == SelectedValue.Wholesale
        ? wholesaleController.text
        : selectedRadio == SelectedValue.Parchoon
        ? parchoonController.text
        : retailController.text);
    print("purchaseval $selectedValue");

    purchaseval = ratedata;

    if (selectedDropdownValue == productData['unit1Data']) {
      if (productData['unit0Data'] == "") {
        double resuilt = selectedValue - purchaseval;
        print("resuilt $resuilt");

       itemsub = resuilt * quantity;
        print("itemsub $itemsub");

      } else if (productData['unit0Data'] != "") {
        double resuilt = selectedValue - minidata;
        print("second resuilt $resuilt");

         itemsub = resuilt * quantity;
        print("second itemsub $itemsub");

      }
    }
    else if (selectedDropdownValue == productData['unit0Data']) {


      double resuilt = selectedValue - minidata;
      print("third resuilt $resuilt");

     itemsub = resuilt * quantity;
      print("third itemsub $itemsub");

    }


    print("purchasevalaaaa $purchaseval");



    if (selectedItemCount > 1) {
      comboprofit = subprofit + itemsub;
      profit = itemsub;
      print("profiteee: $comboprofit");
    }
    else {
      profit = itemsub;
      subprofit = profit;
      print("Subtotal Profit: $profit");
    }

  }

  double rateWithoutDiscount = 0.0;

  void calculatediscount() {
    if (selectedDiscount != null) {
      double? discountAmount = double.tryParse(selectedDiscount!.d_amount);
      if (discountAmount != null && discountAmount < 1) {
        rateWithoutDiscount = lastRate -
            ((selectedTax != null ? rateWithoutTax : lastRate) *
                discountAmount);

        double itemSubtotalWithDiscount = quantity * rateWithoutDiscount;

        selectedRadio == SelectedValue.Wholesale
            ? wholesaleController.text
            : selectedRadio == SelectedValue.Parchoon
                ? parchoonController.text
                : retailController.text = rateWithoutDiscount.toString();

        grandTotal = itemSubtotalWithDiscount;
        globalGrandTotal = grandTotal;
      } else {
        double disctamount = discountAmount! / quantity;
        rateWithoutDiscount =
            (selectedTax != null ? rateWithoutTax : lastRate) - disctamount;
        double itemSubtotalWithDiscount = quantity * rateWithoutDiscount;
        selectedRadio == SelectedValue.Wholesale
            ? wholesaleController.text
            : selectedRadio == SelectedValue.Parchoon
                ? parchoonController.text
                : retailController.text = rateWithoutDiscount.toString();
        grandTotal = itemSubtotalWithDiscount;
        globalGrandTotal = grandTotal;
      }
      grandTotalNotifier.value =
          grandTotal; // Notify listeners about the change
    } else {
      grandTotal = previoussubtotal;
      grandTotalNotifier.value =
          grandTotal; // Notify listeners about the change
      disc = grandTotal;
      globalGrandTotal = grandTotal;
    }
  }
  double newdisocunt =0.0;
  double newTax =0.0;

  void calculatefinaldiscount() {
    if (selectedfinalDiscount != null) {
      double? discountAmount = double.tryParse(selectedfinalDiscount!.d_amount);
      if (discountAmount != null && discountAmount < 1) {
        newdisocunt = grandTotal -
            ((selectedfinalTax != null ? newTax : grandTotal) *
                discountAmount);

        grandTotal = newdisocunt;
      } else {
        newdisocunt =
            (selectedfinalTax != null ? newTax : grandTotal) - discountAmount!;
        grandTotal = newdisocunt;

      }
      grandTotalNotifier.value = grandTotal; // Notify listeners about the change
    } else {
      grandTotal = previoussubtotal;
      grandTotalNotifier.value = grandTotal; // Notify listeners about the change
    }
  }

  void calculatefinaltax() {
    if (selectedfinalTax != null) {
      double? discountAmount = double.tryParse(selectedfinalTax!.t_amount);
      if (discountAmount != null && discountAmount < 1) {
        newTax = grandTotal -
            ((selectedfinalDiscount != null ? newdisocunt : grandTotal) *
                discountAmount);

        grandTotal = newTax;
      } else {
        newTax =
            (selectedfinalDiscount != null ? newdisocunt : grandTotal) - discountAmount!;
        grandTotal = newTax;

      }
      grandTotalNotifier.value = grandTotal; // Notify listeners about the change
    } else {
      grandTotal = previoussubtotal;
      grandTotalNotifier.value = grandTotal; // Notify listeners about the change
    }
  }

  double rateWithoutTax = 0.0;

  void resetTextField() {
    _extraamountController.text = ''; // Clear the text field value
    gramController.text = '';
    _quantityController.text = '';
  }

  void calculatetax() {
    if (selectedTax != null) {
      double? discountAmount = double.tryParse(selectedTax!.t_amount);
      if (discountAmount != null && discountAmount < 1) {
        rateWithoutTax = lastRate +
            ((selectedDiscount != null ? rateWithoutDiscount : lastRate) /
                discountAmount);
        double itemSubtotalWithDiscount = quantity * rateWithoutTax;

        selectedRadio == SelectedValue.Wholesale
            ? wholesaleController.text
            : selectedRadio == SelectedValue.Parchoon
                ? parchoonController.text
                : retailController.text = rateWithoutTax.toString();

        grandTotal = itemSubtotalWithDiscount;
      } else {
        double disctamount = discountAmount! / quantity;
        rateWithoutTax = disctamount! +
            (selectedDiscount != null ? rateWithoutDiscount : lastRate);

        double itemSubtotalWithDiscount = quantity * rateWithoutTax;
        selectedRadio == SelectedValue.Wholesale
            ? wholesaleController.text
            : selectedRadio == SelectedValue.Parchoon
                ? parchoonController.text
                : retailController.text = rateWithoutTax.toString();
        grandTotal = itemSubtotalWithDiscount;
      }
      grandTotalNotifier.value =
          grandTotal; // Notify listeners about the change
    } else {
      grandTotal = selectedProducts.length > 1 ? combosubtotal : subtotal;
      grandTotalNotifier.value =
          grandTotal; // Notify listeners about the change
      disc = grandTotal;
    }
  }

  String selectedDiscountText = "0"; // Initialize with default value
  String selectedTaxText = "0"; // Initialize with default value

  @override
  Widget build(BuildContext context) {
    return
    Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Sales",
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
                          "Sales Information",
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
                      "Bill No.",
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
                            "Date",
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
                    padding: const EdgeInsets.only(left: 10, top: 10),
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
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    List<CustomerModel> discountItems = [];
                                    snapshot.data?.docs.forEach((doc) {
                                      String docId = doc.id;
                                      String name = doc['name'];
                                      discountItems
                                          .add(CustomerModel(docId, name));
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
                                          print(
                                              'The selected unit ID is ${selectedCustomer?.c_id}');
                                          print(
                                              'The selected unit ID1 is $setvalue');
                                          print(
                                              'The selected unit title is ${selectedCustomer?.c_name}');
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
                  Padding(
                    padding: const EdgeInsets.only(left: 14, bottom: 14),
                    child: Container(
                      height: 50,
                      width: 320,
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            filteredProductData =
                                originalProductData.where((product) {
                              return product['sku'] != null &&
                                      product['sku'] != 0 &&
                                      product['sku']
                                          .toString()
                                          .contains(value) ||
                                  product['name']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                            }).toList();
                          });
                        },
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(
                            Icons.search_outlined,
                            color: Colors.grey,
                          ),
                          hintText: "Enter Product Name or SKU",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0), // Add horizontal spacing here
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedCategories = category;
                                });
                              },
                              child: Container(
                                height: 35,
                                width: 90.0, // Adjust the width as needed
                                decoration: BoxDecoration(
                                  color: selectedCategories == category
                                      ? Colors.blue
                                      : Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: GoogleFonts.roboto(
                                      color: selectedCategories == category
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: brands.map((category) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0), // Add horizontal spacing here
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedbrands = category;
                                });
                              },
                              child: Container(
                                height: 35,
                                width: 90.0, // Adjust the width as needed
                                decoration: BoxDecoration(
                                  color: selectedbrands == category
                                      ? Colors.blue
                                      : Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: GoogleFonts.roboto(
                                      color: selectedbrands == category
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FutureBuilder<List<String>>(
                    future: getProductIDsFromInventory(), // Get the inventory product IDs
                    builder: (context, inventorySnapshot) {
                      if (inventorySnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show a loading indicator while fetching Inventory data
                      } else if (inventorySnapshot.hasError) {
                        return Text('Error: ${inventorySnapshot.error}');
                      } else {
                        List<String> inventoryProductIDs = inventorySnapshot.data ?? [];

                        // Call getAllItemsData with inventoryProductIDs
                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: getAllItemsData(inventoryProductIDs),
                          builder: (context, productSnapshot) {
                            if (productSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Show a loading indicator while fetching Product data
                            } else if (productSnapshot.hasError) {
                              return Text('Error: ${productSnapshot.error}');
                            } else {
                              List<Map<String, dynamic>> filteredProducts = productSnapshot.data ?? [];

                              if (selectedCategories != 'All Categories') {
                                filteredProducts = filteredProducts.where((product) {
                                  return product['category'] == selectedCategories;
                                }).toList();
                              }

                              if (selectedbrands != 'All Brands') {
                                filteredProducts = filteredProducts.where((product) {
                                  return product['brand'] == selectedbrands;
                                }).toList();
                              }

                              // Now you have the filtered product data in the 'filteredProducts' list
                              // You can use this data to build your UI or perform any other operations.

                              // Example: Build a ListView of item cards
                              return Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Container(
                                  height: 400,
                                  width: 320,
                                  child: ListView(
                                    children: filteredProducts.map((productData) {
                                      return Column(
                                        children: [
                                          buildItemCard(productData), // Call your function to build each item card
                                          SizedBox(height: 20), // Add a SizedBox for spacing
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  ),


                  // FutureBuilder<List<Map<String, dynamic>>>(
                  //   future: getAllItemsData(),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return CircularProgressIndicator();
                  //     } else if (snapshot.hasError) {
                  //       return Text('Error: ${snapshot.error}');
                  //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  //       return Text('No data available.');
                  //     } else {
                  //       List<Map<String, dynamic>> filteredProducts =
                  //           snapshot.data!;
                  //
                  //
                  //       return Padding(
                  //         padding: const EdgeInsets.all(18.0),
                  //         child: Container(
                  //           height: 400,
                  //           width: 320,
                  //           child: ListView(
                  //             children: filteredProducts.map((productData) {
                  //               return Column(
                  //                 children: [
                  //                   buildItemCard(
                  //                       productData), // Call your function to build each item card
                  //                   SizedBox(
                  //                       height:
                  //                           20), // Add a SizedBox for spacing
                  //                 ],
                  //               );
                  //             }).toList(),
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //   },
                  // ),

                  SizedBox(height: 30),
                  SizedBox(
                    height: 20,
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
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 31,
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) {
                          return Colors.blue;
                        },
                      ),
                      // border: TableBorder(
                      //   borderRadius: BorderRadius.circular(20),
                      // ),
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
                                    tableData.remove(
                                        data); // Remove the row from the data list
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
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
                          "Sub Total ",
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
                          selectedfinalDiscount !=null ? selectedfinalDiscount!.d_amount : "0.0",
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      )),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //         child: Padding(
                  //       padding: const EdgeInsets.only(left: 30, top: 10),
                  //       child: Row(
                  //         children: [
                  //           Text(
                  //             "Tax",
                  //             style: GoogleFonts.roboto(
                  //                 color: Colors.black,
                  //                 fontWeight: FontWeight.bold,
                  //                 fontSize: 16),
                  //           ),
                  //           SizedBox(
                  //             width: 5,
                  //           ),
                  //           IconButton(
                  //               onPressed: () {
                  //                 showDialog(
                  //                     context: context,
                  //                     builder: (context) => showTaxDialog());
                  //               },
                  //               icon: Icon(
                  //                 FontAwesomeIcons.edit,
                  //                 color: Colors.black,
                  //                 size: 17,
                  //               )),
                  //         ],
                  //       ),
                  //     )),
                  //     Expanded(
                  //         child: Padding(
                  //       padding: const EdgeInsets.only(left: 30, top: 10),
                  //       child: Text(
                  //         selectedfinalTax !=null ? selectedfinalTax!.t_amount : "0.0",
                  //         style: GoogleFonts.roboto(
                  //             color: Colors.black,
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 18),
                  //       ),
                  //     )),
                  //   ],
                  // ),
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
                          'Rs. ${selectedfinalDiscount !=null ? newdisocunt.toStringAsFixed(2) : selectedfinalTax !=null ? newTax.toStringAsFixed(2) : (extragrand != null && extragrand > 0) ? extragrand.toStringAsFixed(2) : (selectedDiscount != null && selectedTax != null) ? taxgrand.toStringAsFixed(2) : (selectedProducts.length > 1 && selectedTax == null) ? taxgrand.toStringAsFixed(2) : selectedDiscount != null ? globalGrandTotal.toStringAsFixed(2) : selectedTax != null ? taxgrand.toStringAsFixed(2) : grandTotal.toStringAsFixed(2)}',
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
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
                          // showDialog(
                          //     context: context,
                          //     builder: (context) => showExtraDialog());
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

                  Padding(
                    padding: const EdgeInsets.only(left: 25, top: 20),
                    child: Container(
                      height: 45.0,
                      width: 320.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => showPaymentDialog(productData));
                        },
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
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
                                color: Colors.redAccent),
                            child: InkWell(
                              onTap: () {
                                selectedProducts.add(ProductModel(
                                  productData['id'], // Replace with the appropriate field from productData
                                  productData['name'], // Replace with the appropriate field from productData
                                  0.0, // Set the initial grandTotal value here
                                ));
                                String itemId = productData['id'];
                                print("objectobjectobjectobject $itemId");
                                retrieveOriginalValues(itemId);
                              },
                              child: Center(
                                child: Text(
                                  'Exit',
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
                              onTap: () {},
                              child: Center(
                                child: Text(
                                  'Hold',
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
          height: 250,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Form(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10, bottom: 20),
                    child: Text(
                      "Discount",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 14, right: 14),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 329,
                          height: 60,
                          padding: EdgeInsets.only(
                              left: 16, right: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey, width: 1),
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Discount')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot>
                                snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                    'Error: ${snapshot.error}');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child:
                                    CircularProgressIndicator());
                              }
                              List<DiscountModel> discountItems =
                              [];
                              discountItems.add(DiscountModel('',
                                  "Please select discount")); // Add default "Please select discount" option
                              snapshot.data?.docs.forEach((doc) {
                                String docId = doc.id;
                                String amount = doc['amount'];
                                discountItems.add(
                                    DiscountModel(docId, amount));
                              });

                              // Check if the selectedDiscount is null or the default option, then set it to null
                              if (selectedfinalDiscount == null ||
                                  selectedfinalDiscount!
                                      .d_id.isEmpty ||
                                  selectedfinalDiscount!.d_amount ==
                                      "Please select discount") {
                                selectedfinalDiscount = null;
                              }

                              return DropdownButton<DiscountModel>(
                                iconSize: 40,
                                isExpanded: true,
                                underline: SizedBox(),
                                value: selectedfinalDiscount,
                                items:
                                discountItems.map((discount) {
                                  return DropdownMenuItem<
                                      DiscountModel>(
                                    value: discount,
                                    child:
                                    Text(discount.d_amount),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedfinalDiscount = value;
                                    setvalue = value;
                                    selectedDiscountText =
                                    (selectedfinalDiscount != null)
                                        ? selectedfinalDiscount!
                                        .d_amount
                                        : "0";
                                    // calculateGrandTotal();
                                    calculatefinaldiscount();
                                    print(
                                        'The selected unit ID is ${selectedfinalDiscount?.d_id}');
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
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryButton(String categoryName) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = categoryName;
        });
      },
      child: Container(
        height: 30,
        width: 75.0, // Adjust the width as needed
        decoration: BoxDecoration(
          color: selectedCategory == categoryName
              ? Colors.blue
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            categoryName,
            style: GoogleFonts.roboto(
                color: selectedCategory == categoryName
                    ? Colors.white
                    : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String? quantitytt;
  String? unit1Data;
  String? unit;
  String? unit0Data;
  String? newavailable;
  double? conversion;
  String available = '';

  String parchoonval = '';
  String retail = '';
  String wholesale = '';




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
double ratedata =0.0;
  double minidata =0.0;

  Future<List<Map<String, dynamic>>> getAllItemsData(List<String> inventoryProductIDs) async {
    QuerySnapshot productSnapshot =
    await FirebaseFirestore.instance.collection('Product').get();

    List<Map<String, dynamic>> productData = [];

    productSnapshot.docs.forEach((doc) {
      Map<String, dynamic> simpleValues = {};
      Map<String, dynamic> dividedValues = {};

      String conversionString = doc.get('conversion');
      conversionString = conversionString.replaceAll(',', ''); // Remove commas
      conversion = double.tryParse(conversionString) ?? 1.0;

      String ratesconvernion = doc.get('rate');
      ratesconvernion = ratesconvernion.replaceAll(',', ''); // Remove commas
      ratedata = double.tryParse(ratesconvernion) ?? 1.0;

      String converserate = doc.get('minirate');
      converserate =
          converserate.replaceAll(',', ''); // Remove commas
      minidata = double.parse(converserate);





      dynamic unitData = doc.get('unit');

      unit1Data = unitData[1].toString();

      if (unit1Data != "") {
        simpleValues = doc.get('simple_values') ?? {};
      }
      unit0Data = unitData[0].toString();
      if (unit0Data != "") {
        dividedValues = doc.get('divided_values') ?? {};
      }

      // Check if the product's ID is in the inventory
      if (inventoryProductIDs.contains(doc.get('id'))) {
        productData.add({
          'name': doc.get('item'),
          'simple_values': simpleValues,
          'id': doc.get('id'),
          'divided_values': dividedValues,
          'quantity': doc.get('quantity'),
          'category': doc.get('category'),
          'brand': doc.get('brand'),
          'conversion': doc.get('conversion'),
          'unit': doc.get('unit'),
          'available': formatQuantityAndUnit(
              double.parse(doc.get('quantity')), doc.get('unit').join(', ')),
          'restoke': doc.get('restoke'),
          'sku': doc.get('sku'),
          'unit1Data': unit1Data,
          'unit0Data': unit0Data,
        });
      }
    });

    return productData;
  }



  Widget buildItemCard(productData) {
    String selectedDropdownValue =
        productData['unit1Data']; // Initialize with default value
    return Card(
      child: InkWell(
        onTap: () {
          selectedDiscount = null;
          selectedTax = null;
          showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    updatedvalues(selectedDropdownValue, productData);
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          width: 320,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Form(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 25, bottom: 8),
                                  child: Text(
                                    "${productData['name']} Detail",
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
                                    color: double.parse(
                                                productData['quantity']) <
                                            double.parse(productData['restoke'])
                                        ? CupertinoColors
                                            .destructiveRed // Show red background if quantity < restoke
                                        : CupertinoColors.activeGreen,
                                    // Show green background if quantity >= restoke
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Stock Information",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 17,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          "${productData['available']}",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 15,
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
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 10),
                                      child: Text(
                                        "Item Unit",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 10),
                                        child: DropdownButtonFormField<String>(
                                          value: selectedDropdownValue,
                                          items: (productData['unit']
                                                  as List<dynamic>)
                                              .map<DropdownMenuItem<String>>(
                                            (dynamic unit) {
                                              return DropdownMenuItem<String>(
                                                value: unit.toString(),
                                                child: Text(unit.toString()),
                                              );
                                            },
                                          ).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedDropdownValue = newValue!;

                                              if (selectedDropdownValue ==
                                                  productData['unit1Data']) {
                                                parchoonController.text =
                                                    productData['simple_values']
                                                                    [unit1Data]
                                                                ?['parchoonval']
                                                            .toString() ??
                                                        'N/A';
                                                retailController.text =
                                                    productData['simple_values']
                                                                    [unit1Data]
                                                                ?['retail']
                                                            .toString() ??
                                                        'N/A';
                                                wholesaleController.text =
                                                    productData['simple_values']
                                                                    [unit1Data]
                                                                ?['wholesale']
                                                            .toString() ??
                                                        'N/A';
                                              } else if (selectedDropdownValue ==
                                                  productData['unit0Data']) {
                                                parchoonController.text =
                                                    productData['divided_values']
                                                                    [unit0Data]
                                                                ?['parchoon']
                                                            ?.toString() ??
                                                        'N/A';
                                                retailController.text =
                                                    productData['divided_values']
                                                                    [unit0Data]
                                                                ?['val']
                                                            ?.toString() ??
                                                        'N/A';
                                                wholesaleController.text =
                                                    productData['divided_values']
                                                                    [unit0Data]
                                                                ?[
                                                                'wholesaleval']
                                                            ?.toString() ??
                                                        'N/A';
                                              } else {
                                                print("No Value");
                                              }
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Unit',
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(15),
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
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 10),
                                      child: Text(
                                        "Item Quantity",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 10),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: _quantityController,
                                          decoration: InputDecoration(
                                            hintText: 'Quantity',
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            if ((selectedRadio ==
                                                        SelectedValue
                                                            .Wholesale &&
                                                    wholesaleController
                                                        .text.isNotEmpty) ||
                                                (selectedRadio ==
                                                        SelectedValue
                                                            .Parchoon &&
                                                    parchoonController
                                                        .text.isNotEmpty) ||
                                                (selectedRadio ==
                                                        SelectedValue.Retail &&
                                                    retailController
                                                        .text.isNotEmpty)) {
                                              savePurchase(productData,
                                                  selectedDropdownValue);
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
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 10),
                                      child: Text(
                                        "Rates",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 10),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            if ((selectedRadio ==
                                                        SelectedValue
                                                            .Wholesale &&
                                                    wholesaleController
                                                        .text.isNotEmpty) ||
                                                (selectedRadio ==
                                                        SelectedValue
                                                            .Parchoon &&
                                                    parchoonController
                                                        .text.isNotEmpty) ||
                                                (selectedRadio ==
                                                        SelectedValue.Retail &&
                                                    retailController
                                                        .text.isNotEmpty)) {
                                              savePurchase(productData,
                                                  selectedDropdownValue);
                                            }
                                          },
                                          controller: selectedRadio ==
                                                  SelectedValue.Wholesale
                                              ? wholesaleController
                                              : selectedRadio ==
                                                      SelectedValue.Parchoon
                                                  ? parchoonController
                                                  : retailController,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, bottom: 10),
                                    child: Text(
                                      "Discount",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width: 329,
                                        height: 60,
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Discount')
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                            List<DiscountModel> discountItems =
                                                [];
                                            discountItems.add(DiscountModel('',
                                                "Please select discount")); // Add default "Please select discount" option
                                            snapshot.data?.docs.forEach((doc) {
                                              String docId = doc.id;
                                              String amount = doc['amount'];
                                              discountItems.add(
                                                  DiscountModel(docId, amount));
                                            });

                                            // Check if the selectedDiscount is null or the default option, then set it to null
                                            if (selectedDiscount == null ||
                                                selectedDiscount!
                                                    .d_id.isEmpty ||
                                                selectedDiscount!.d_amount ==
                                                    "Please select discount") {
                                              selectedDiscount = null;
                                            }

                                            return DropdownButton<
                                                DiscountModel>(
                                              iconSize: 40,
                                              isExpanded: true,
                                              underline: SizedBox(),
                                              value: selectedDiscount,
                                              items:
                                                  discountItems.map((discount) {
                                                return DropdownMenuItem<
                                                    DiscountModel>(
                                                  value: discount,
                                                  child:
                                                      Text(discount.d_amount),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedDiscount = value;
                                                  setvalue = value;
                                                  selectedDiscountText =
                                                      (selectedDiscount != null)
                                                          ? selectedDiscount!
                                                              .d_amount
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
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, bottom: 10),
                                    child: Text(
                                      "Tax",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width: 280,
                                        height: 60,
                                        padding:
                                            EdgeInsets.only(left: 16, right: 0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('tax')
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                            List<TaxModel> unitItems = [];
                                            snapshot.data?.docs.forEach((doc) {
                                              String docId = doc.id;
                                              String title = doc['amount'];
                                              unitItems
                                                  .add(TaxModel(docId, title));
                                            });

                                            return DropdownButton<TaxModel>(
                                              iconSize: 40,
                                              isExpanded: true,
                                              underline: SizedBox(),
                                              hint: Text('Select Tax'),
                                              value: selectedTax,
                                              items: unitItems.map((unit) {
                                                return DropdownMenuItem<
                                                    TaxModel>(
                                                  value: unit,
                                                  child: Text(unit.t_amount),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedTax = value;
                                                  setvalue = value;
                                                  selectedTaxText =
                                                      (selectedTax != null)
                                                          ? selectedTax!
                                                              .t_amount
                                                          : "0";
                                                  calculatetax();

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
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Container(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      "Extra Charge Amount",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 16),
                                    ),
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
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      calculatedextragrandtotal();
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Container(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      "Amount for Grams",
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: TextFormField(
                                    controller: gramController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Amount',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onFieldSubmitted: (value) {
                                      _updateQuantity(
                                          selectedDropdownValue, productData);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, right: 10),
                                  child: Column(
                                    children: [
                                      RadioListTile<SelectedValue>(
                                        title: Text('Retail'),
                                        value: SelectedValue.Retail,
                                        groupValue: selectedRadio,
                                        onChanged: (SelectedValue? value) {
                                          setState(() {
                                            selectedRadio = value!;
                                          });
                                          savePurchase(productData,
                                              selectedDropdownValue); // Call savePurchase function here
                                        },
                                      ),
                                      RadioListTile<SelectedValue>(
                                        title: Text('Wholesale'),
                                        value: SelectedValue.Wholesale,
                                        groupValue: selectedRadio,
                                        onChanged: (SelectedValue? value) {
                                          setState(() {
                                            selectedRadio = value!;
                                          });
                                          savePurchase(productData,
                                              selectedDropdownValue); // Call savePurchase function here
                                        },
                                      ),
                                      RadioListTile<SelectedValue>(
                                        title: Text('Parchoon'),
                                        value: SelectedValue.Parchoon,
                                        groupValue: selectedRadio,
                                        onChanged: (SelectedValue? value) {
                                          setState(() {
                                            selectedRadio = value!;
                                          });
                                          savePurchase(productData,
                                              selectedDropdownValue); // Call savePurchase function here
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder<double>(
                                  valueListenable: grandTotalNotifier,
                                  builder: (context, grandTotal, child) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, top: 20),
                                            child: Text(
                                              "Total ",
                                              style: GoogleFonts.roboto(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, top: 10),
                                            child: Text(
                                              grandTotal.toStringAsFixed(2),
                                              style: GoogleFonts.roboto(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 10, right: 10),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade500,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                            child: Text(
                                              "Cancel",
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 10, right: 10),
                                      child: InkWell(
                                        onTap: () {
                                          selectedProducts.add(ProductModel(
                                            productData[
                                                'id'], // Replace with the appropriate field from productData
                                            productData[
                                                'name'], // Replace with the appropriate field from productData
                                            0.0, // Set the initial grandTotal value here
                                          ));

                                          selectedItemCount =
                                              selectedProducts.length ?? 0;
                                          print(
                                              "ajakhshjsjhs jysushsj hs$selectedItemCount");
                                          Navigator.of(context).pop();
                                          if (selectedTax != null) {
                                            newlastgrand();
                                          }
                                          if (selectedDiscount != null) {
                                            newlastgranddiscount();
                                          }
                                          calculatedextragrandtotal();
                                          newextralastgrand();
                                          String itemId = productData['id'];
                                          print("aajaaj $itemId");
                                          // increaseItemQuantity(itemId);
                                          updateInventoryQuantities(productData,itemId,selectedDropdownValue);
                                          // increaseItemQuantityPurchase(itemId);
                                          profitcalculation(selectedDropdownValue,productData);
                                          print("aaaaahahhahahah $selectedDropdownValue");

                                          quantitytill(itemId);
                                          tillgrand(itemId);

                                          saveDataAndResetFields(
                                              context,
                                              productData,
                                              selectedDropdownValue);
                                            },
                                        child: Container(
                                          height: 40,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                            child: Text(
                                              "Add",
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }));
        },
        child: Container(
          width: 320,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/logo.png"),
                  )),
                ),
              ),
              Positioned(
                left: 80,
                top: 25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productData['name'],
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (productData['sku'] != 0 && productData['sku'] != "")
                          Text(
                            "SKU: ${productData['sku']}, ",
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 11,
                            ),
                          ),
                        SizedBox(width: 6),
                        Text(
                          "Sale Rate: ${productData['simple_values'][unit1Data]?['retail'] ?? 'N/A'}",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "WholeSale: ${productData['simple_values'][unit1Data]?['wholesale'] ?? 'N/A'}",
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 15,
                top: 22,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Center(
                    child: Text(
                      "${productData['available']}",
                      style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, bottom: 20),
                  child: Text(
                    "Tax",
                    style:
                        GoogleFonts.roboto(color: Colors.black, fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 14, right: 14),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 280,
                        height: 60,
                        padding:
                        EdgeInsets.only(left: 16, right: 0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey, width: 1),
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('tax')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot>
                              snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child:
                                  CircularProgressIndicator());
                            }
                            List<TaxModel> unitItems = [];
                            snapshot.data?.docs.forEach((doc) {
                              String docId = doc.id;
                              String title = doc['amount'];
                              unitItems
                                  .add(TaxModel(docId, title));
                            });

                            return DropdownButton<TaxModel>(
                              iconSize: 40,
                              isExpanded: true,
                              underline: SizedBox(),
                              hint: Text('Select Tax'),
                              value: selectedfinalTax,
                              items: unitItems.map((unit) {
                                return DropdownMenuItem<
                                    TaxModel>(
                                  value: unit,
                                  child: Text(unit.t_amount),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedfinalTax = value;
                                  setvalue = value;
                                  selectedTaxText =
                                  (selectedfinalTax != null)
                                      ? selectedfinalTax!
                                      .t_amount
                                      : "0";
                                  calculatefinaltax();
                                  print(
                                      'The selected unit ID is ${selectedfinalTax?.t_id}');
                                  print(
                                      'The selected unit ID1 is $setvalue');
                                  print(
                                      'The selected unit title is ${selectedfinalTax?.t_amount}');
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

  Widget showPaymentDialog(productData) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          height: 800,
          width: 320,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 20),
                  child: Text("Make Payment",
                      style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 15)),
                ),
                SizedBox(
                  height: 15,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black,
                ),
                SizedBox(
                  height: 15,
                ),
                ValueListenableBuilder<double>(
                  valueListenable: grandTotalNotifier,
                  builder: (context, grandTotal, child) {
                    return Center(
                      child: Text(
                          'Rs. ${selectedfinalDiscount !=null ? newdisocunt.toStringAsFixed(2) : selectedfinalTax !=null ? newTax.toStringAsFixed(2) : (extragrand != null && extragrand > 0) ? extragrand.toStringAsFixed(2) : (selectedDiscount != null && selectedTax != null) ? taxgrand.toStringAsFixed(2) : (selectedProducts.length > 1 && selectedTax == null) ? taxgrand.toStringAsFixed(2) : selectedDiscount != null ? globalGrandTotal.toStringAsFixed(2) : selectedTax != null ? taxgrand.toStringAsFixed(2) : grandTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: Text(
                    'Sale # ${currentPurchaseCount + 1}',
                    style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                      "Amount Tendered",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 14,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _amounttenderController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Enter a number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (newValue) {
                      amountCalculation(); // Call your amountCalculation function here
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                      "Payment Method",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 14,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              width: 250,
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
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                      "Balance Due",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 14,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 15),
                      child: ValueListenableBuilder<double>(
                        valueListenable: finalNotifier,
                        builder: (context, finalsValue, child) {
                          final displayValue = finalsValue != null && finalsValue != ""
                              ? finalsValue.toStringAsFixed(2)  // Display formatted finalsValue
                              : selectedfinalDiscount !=null ? newdisocunt.toString() : selectedfinalTax !=null ? newTax.toString : (extragrand != null && extragrand > 0) ? extragrand.toString() : (selectedDiscount != null && selectedTax != null) ? taxgrand.toString() : (selectedProducts.length > 1 && selectedTax == null) ? taxgrand.toString() : selectedDiscount != null ? globalGrandTotal.toString() : selectedTax != null ? taxgrand.toString() : grandTotal.toString();   // Display formatted grandTotal

                          return  Text(
                              '${displayValue}',

                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),

                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                      "Change",
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 14,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 15),
                      child: ValueListenableBuilder<double>(
                        valueListenable: dueNotifier, // Use dueNotifier here
                        builder: (context, dueValue, child) {
                          return Text(
                              dueValue.toString(), // Display the dueValue from dueNotifier
                              style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                          );
                        },
                      ),
                    ),
                  ),
                ),
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
                        if (formKey.currentState!.validate()) {
                          if (selectedCustomer == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select Customer First."),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.fixed,
                              ),
                            );
                          } else {
                            setState(() {
                              pickdate = _purchasedateController.text;
                              duedate = _due_dateController.text;
                            });
                            onSaveButtonPressed(selectedCustomer!.c_id);
                            increaseItemByOneamount(selectedCustomer!.c_id);
                            increaseItemBytotalspend(selectedCustomer!.c_id);
                            increaseItemByOneInvoice(selectedCustomer!.c_id);
                            completePurchase();
                            print(" it is $currentPurchaseCount");
                          }
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

class UnitModel {
  String u_id;
  String u_title;

  UnitModel(this.u_id, this.u_title);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitModel &&
          runtimeType == other.runtimeType &&
          u_id == other.u_id;

  @override
  int get hashCode => u_id.hashCode;
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


















// Future<void> updateInventoryQuantities(productData, String itemId, String selectedDropdownValue) async {
//   // Initialize with a future timestamp
//   Timestamp earliestTimestamp = Timestamp.now();
//
//   while (true) {
//     // Retrieve inventories ordered by timestamp
//     QuerySnapshot inventoryQuerySnapshot = await FirebaseFirestore.instance
//         .collection('Inventory')
//         .orderBy('timestamp')
//         .get();
//
//     // Find the earliest inventory with the specified productID
//     QueryDocumentSnapshot? earliestInventory;
//     for (QueryDocumentSnapshot inventoryDoc in inventoryQuerySnapshot.docs) {
//       QuerySnapshot subcollectionQuery = await FirebaseFirestore.instance
//           .collection('Inventory')
//           .doc(inventoryDoc.id)
//           .collection('items')
//           .where('productID', isEqualTo: itemId)
//           .get();
//
//       if (subcollectionQuery.docs.isNotEmpty) {
//         Timestamp inventoryTimestamp = (inventoryDoc.data() as Map<String, dynamic>)['timestamp'];
//         if (inventoryTimestamp.compareTo(earliestTimestamp) < 0) {
//           earliestTimestamp = inventoryTimestamp;
//           earliestInventory = inventoryDoc;
//         }
//       }
//     }
//
//     // Check if an earliest inventory is found
//     if (earliestInventory != null) {
//       QuerySnapshot subcollectionQuery = await FirebaseFirestore.instance
//           .collection('Inventory')
//           .doc(earliestInventory.id)
//           .collection('items')
//           .where('productID', isEqualTo: itemId)
//           .get();
//
//       // Check if quantitytominus in the earliest inventory is zero
//       bool isQuantityZero = true;
//
//       // Iterate through items in the earliest inventory
//       for (QueryDocumentSnapshot subDoc in subcollectionQuery.docs) {
//         String sellString = (subDoc.data() as Map<String, dynamic>)['quantitytominus'];
//         double sell = double.tryParse(sellString) ?? 0.0;
//
//         // Check if any item's quantitytominus is not zero
//         if (sell != 0) {
//           isQuantityZero = false;
//           break; // No need to check further, we found a non-zero quantity
//         }
//       }
//
//       // If quantitytominus is zero, delete the earliest inventory
//       if (isQuantityZero) {
//         await FirebaseFirestore.instance.collection('Inventory').doc(earliestInventory.id).delete();
//         print('Deleted Inventory with ID: ${earliestInventory.id}');
//         continue; // Skip processing this inventory, move to the next one
//       }
//
//       // Calculate total sell for the present timestamp
//       double totalSellForPresentTimestamp = 0.0;
//
//       // Iterate through items in the earliest inventory
//       for (QueryDocumentSnapshot subDoc in subcollectionQuery.docs) {
//         String sellString = (subDoc.data() as Map<String, dynamic>)['quantitytominus'];
//         double sell = double.tryParse(sellString) ?? 0.0;
//
//         // Add to total sell for the present timestamp
//         totalSellForPresentTimestamp += sell;
//       }
//
//       // Calculate the remaining quantity to be deducted from the next timestamp inventory
//       int remainingQuantity = quantity;
//
//       if (remainingQuantity > totalSellForPresentTimestamp) {
//         // Quantity is greater than available sell for the present timestamp
//         // Find the next inventory with a higher timestamp and deduct the remaining quantity from it
//         QuerySnapshot nextInventoryQuerySnapshot = await FirebaseFirestore.instance
//             .collection('Inventory')
//             .orderBy('timestamp', descending: true) // Order by timestamp in descending order to get the next inventory
//             .startAfter([earliestTimestamp]) // Start after the current earliest timestamp
//             .limit(1) // Get only the next inventory
//             .get();
//
//         if (nextInventoryQuerySnapshot.docs.isNotEmpty) {
//           QueryDocumentSnapshot nextInventory = nextInventoryQuerySnapshot.docs.first;
//
//           // Your logic to deduct the remaining quantity from the next inventory
//           QuerySnapshot nextInventoryItemsQuery = await FirebaseFirestore.instance
//               .collection('Inventory')
//               .doc(nextInventory.id)
//               .collection('items')
//               .where('productID', isEqualTo: itemId)
//               .get();
//
//           // Calculate and deduct the remaining quantity from the next inventory's items
//           for (QueryDocumentSnapshot nextInventoryItem in nextInventoryItemsQuery.docs) {
//             String nextInventorySellString = (nextInventoryItem.data() as Map<String, dynamic>)['quantitytominus'];
//             double nextInventorySell = double.tryParse(nextInventorySellString) ?? 0.0;
//
//             if (selectedDropdownValue == productData['unit0Data']) {
//               sold = nextInventorySell - quantity;
//             }
//             else if (selectedDropdownValue == productData['unit1Data']) {
//               if(nextInventorySell < conversion!){
//                 sold = nextInventorySell - quantity;
//               }
//               else{
//                 double converrrrss = nextInventorySell / conversion!;
//                 print("sold $converrrrss");
//                 double newq = converrrrss - quantity;
//                 print("hshs $newq");
//                 sold = newq * conversion!;
//                 print("lastqqq lastqqq $sold");
//               }
//
//             }
//             else {
//               print("Pata ni yar");
//             }
//
//             await FirebaseFirestore.instance
//                 .collection('Inventory')
//                 .doc(nextInventory.id)
//                 .collection('items')
//                 .doc(nextInventoryItem.id)
//                 .update({'sell': sold.toStringAsFixed(2), 'quantitytominus': sold.toStringAsFixed(2)});
//           }
//         }
//       }
//
//       // Your existing logic for updating quantities based on selectedDropdownValue
//       // ...
//
//       // Update sell and quantitytominus for the present inventory
//       // ...
//
//       // Print relevant information
//       // ...
//
//     } else {
//       // No more relevant inventories found, exit the loop
//       break;
//     }
//   }
// }

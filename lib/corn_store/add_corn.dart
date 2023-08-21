import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos/corn_store/corn_store.dart';
import '../home/drawer.dart';
import '../splashScreens/loginout.dart';
import '../user/edit_profile.dart';

enum MenuItem {
  item1,
  item2,
}

class Add_Corn extends StatefulWidget {
  const Add_Corn({super.key});

  @override
  State<Add_Corn> createState() => _Add_CornState();
}

class _Add_CornState extends State<Add_Corn>
    with AutomaticKeepAliveClientMixin<Add_Corn> {
  @override
  bool get wantKeepAlive => true;

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

  List<ProductModel> selectedProducts = [];

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
    _textEditingController.removeListener(_performCalculation);
    _textEditingController.dispose();
    super.dispose();
  }

  var setvalue;
  TextEditingController amountPaidController = TextEditingController();



double lastvalue =0.0;

  void assignGrandTotal() {

    setState(() {
      if (amountPaidController.text.isNotEmpty) {
        double enteredValue = double.parse(amountPaidController.text);
        lastvalue = _result - enteredValue;
        print("last value in $lastvalue");
      }
      else{
        lastvalue = _result;
        print("last value in $lastvalue");
      }
    });
  }

  void _performCalculation() {
    double inputValue = double.tryParse(_textEditingController.text) ?? 0.0;
    if (_isSwitchedOn) {
      _functionWhenSwitchedOn(inputValue);
    } else {
      _functionWhenSwitchedOff(inputValue);
    }
  }

  void addNewRowWithSameProduct() {
    if (selectedProduct != null) {
      setState(() {
        selectedProducts.add(
          ProductModel(
            selectedProduct!.p_id,
            selectedProduct!.p_name,
            0, // Empty quantity for the new row
            0, // You can set any default value for the new row
          ),
        );
      });
    }
  }

  List<ProductModel> selectedProduct1 = [];

  double calculateTotalQuantity() {
    double totalQuantity = 0.0; // Initialize as double
    selectedProducts.forEach((product) {
      totalQuantity += product.quantity.toDouble(); // Convert int to double
    });
    return totalQuantity;
  }
String bag="";
  int currentPurchaseCount = 0;


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
        double incrementedValue = enteredAmount + _result;
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

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }





  Future<void> increaseItemByOne(String itemId) async {
    try {
      double totalQuantity = calculateTotalQuantity();

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
            enteredAmount + totalQuantity;
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();

        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('Product')
            .doc(itemId)
            .update({'quantity': updatedValue,
        'rate' : _isSwitchedOn ? _textEditingController.text : finalval,
        });
      } else {
        print("Failed to parse the current value as an integer");
      }

      print('Item value incremented successfully.');
    } catch (error) {
      print('Error incrementing item value: $error');
    }
  }


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
      if (enteredAmount != null) {
        double valueToSubtract = lastvalue != 0  ? lastvalue : _result;
        double incrementedValue = enteredAmount - valueToSubtract;

        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();

        await FirebaseFirestore.instance
            .collection('customer')
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




  Future<String> getPreviousBalanceForCustomer(String customerId) async {
    String previousBalance = "";

    DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
        .collection('customer')
        .doc(customerId)
        .get();

    if (customerSnapshot.exists) {
      // If the customer exists, retrieve their previous balance
      previousBalance = customerSnapshot.get('previous') ?? " ";
    }

    return previousBalance;
  }

  add(String customerId)  async{
    double totalQuantity = calculateTotalQuantity();


    String previousBalanceString = await getPreviousBalanceForCustomer(customerId);
    double previousBalance = 0.0;

    if (previousBalanceString.isNotEmpty) {
      previousBalance = double.parse(previousBalanceString);
    }

    double valueToSubtract = lastvalue != 0  ? lastvalue : _result;
    double incrementedValue;
    if (previousBalance != 0.0) {
      incrementedValue = previousBalance - valueToSubtract;
    } else {
      incrementedValue = valueToSubtract;
    }

    print("incrementedValue $incrementedValue");
    String updatedValue = incrementedValue.toString();

    DocumentReference docRef =
    FirebaseFirestore.instance.collection('Corn').doc();
    var brandId = docRef.id;

    docRef.set({
      'id': brandId,
      'item': selectedProduct!.p_name,
      'count': selectedItemCount,
      'warehouse': selectedCategory!.c_title,
      'purchase': currentPurchaseCount,
      'pickdate': pickdate,
      'duedate': duedate,
      'supplier': selectedSupplier!.s_name,
      'price': _textEditingController.text,
      'paid': amountPaidController.text,
      'remaining': lastvalue,
      'total_quantity':totalQuantity,
      'grand': _result,
      'bag':bag,
      'previous': previousBalanceString,
      'after': updatedValue,


    });
    setState(() {
      currentPurchaseCount++;
    });
    await FirebaseFirestore.instance
        .collection('customer')
        .doc(customerId)
        .update({'previous': updatedValue});

  FirebaseFirestore.instance
        .collection('Corn')
        .doc(brandId)
        .update({'purchase': currentPurchaseCount});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Corn_Store(),
      ),
    );
  }
  CategoryModel? selectedCategory;


  @override
  void initState() {
    getDataFromFirebase();
    // Add a listener to the TextEditingController to trigger calculations when text changes
    _textEditingController.addListener(_performCalculation);
    _purchasedateController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
    super.initState();
  }

  SupplierModel? selectedSupplier;
  ProductModel? selectedProduct;

  String getCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }
  final formKey = GlobalKey<FormState>();


  TextEditingController _purchasedateController = TextEditingController();
  TextEditingController _due_dateController = TextEditingController();
  var pickdate = "";
  var duedate = "";

  getDataFromFirebase() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Corn')
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
  TextEditingController quantityController = TextEditingController();
  Map<int, TextEditingController> quantityControllers = {};

  @override
  bool _isSwitchedOn = false;
  double _result = 0.0;
  TextEditingController _textEditingController = TextEditingController();

  void _functionWhenSwitchedOff(double value) {
    // Function to be performed when the switch is turned ON
    double totalQuantity = calculateTotalQuantity(); // Call the function to get the totalQuantity
    setState(() {
      _result = value * totalQuantity;
      finalval = value * 50;
      print("result ts ts ts $_result");
    });
  }




  double finalval =0.0;

  double bags =0.0;
  int selectedItemCount = 0;

  void _functionWhenSwitchedOn(double value) {
    // Function to be performed when the switch is turned OFF
    double totalQuantity = calculateTotalQuantity(); // Call the function to get the totalQuantity

    setState(() {
     double bag = totalQuantity/ 50;
      _result = bag * value; // Perform a simple calculation, e.g., halve the input value
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalQuantity = calculateTotalQuantity();

    int bags = (totalQuantity ~/ 50).toInt(); // Calculate the number of bags (integer division)
    double remainingKilograms = totalQuantity % 50; // Calculate the remaining kilograms
     bag = "$bags Bags";
    if (remainingKilograms > 0) {
      bag += " and $remainingKilograms Kilograms";
    }
    String textFieldLabel =
        _isSwitchedOn ? "Enter value for Bags: " : "Enter value for KG: ";
    String textFieldLabel2 =
    _isSwitchedOn ? "Price for Bags: " : "Price for KG: ";


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Add Corns",
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                                initialDate: _purchasedateController.text.isEmpty
                                    ? DateTime.now() // Use current date if the field is empty
                                    : DateFormat('dd/MM/yyyy').parse(_purchasedateController.text), // Parse existing value
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              ).then((date) {
                                if (date != null) {
                                  setState(() {
                                    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                                    _purchasedateController.text = formattedDate;
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
                      "Customers",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
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
                                unitItems.add(SupplierModel(docId, title));
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
                          ))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Select Item",
                      style:
                          GoogleFonts.roboto(color: Colors.black, fontSize: 16),
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
                              productItems.add(ProductModel(docId, item, 0, 0));
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
                                selectedProducts.add(
                                    value!); // Add the selected product to the list
                                setState(() {
                                  selectedProduct = value;
                                  FirebaseFirestore.instance
                                      .collection('Product')
                                      .doc(selectedProduct!.p_id)
                                      .get()
                                      .then((docSnapshot) {
                                    if (docSnapshot.exists) {
                                      // Fetch the quantity and unit price from the document
                                      int quantity = docSnapshot['quantity'];
                                      double unitPrice =
                                          docSnapshot['unitPrice'];

                                      // Update the selectedProduct with fetched data
                                      selectedProduct = ProductModel(
                                        selectedProduct!.p_id,
                                        selectedProduct!.p_name,
                                        unitPrice, // Update the unitPrice in the selectedProduct
                                        quantity
                                            .toDouble(), // Update the quantity in the selectedProduct
                                      );
                                    } else {
                                      int defaultQuantity = 1;
                                      double defaultUnitPrice = 0.0;

                                      selectedProduct = ProductModel(
                                        selectedProduct!.p_id,
                                        selectedProduct!.p_name,
                                        defaultUnitPrice,
                                        defaultQuantity.toDouble(),
                                      );
                                    }
                                  }).catchError((error) {
                                    // Handle any errors that occur during fetching data
                                    print('Error fetching data: $error');
                                  });
                                });
                                // quantityControllers[selectedProduct!.p_id] = TextEditingController();
                                selectedItemCount =
                                    selectedProducts.length ?? 0;

                              },
                            );
                          },
                        )),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 60,
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
                            'Product Name',
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
                            'Remove',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      rows: List.generate(selectedProducts.length, (index) {
                        ProductModel product = selectedProducts[index];

                        // Check if we have already created a controller for this product
                        if (!quantityControllers.containsKey(index)) {
                          quantityControllers[index] = TextEditingController(
                            text: (product.quantity != null &&
                                    product.quantity != 0)
                                ? product.quantity.toString()
                                : '',
                          );
                        }

                        return DataRow(cells: [
                          DataCell(Text(product.p_name)),
                          DataCell(TextField(
                            onChanged: (value) {
                              setState(() {
                                product.quantity =
                                    double.parse(value); // Parse as double
                              });
                            },
                            onEditingComplete: () {
                              addNewRowWithSameProduct(); // Call the function to add a new row
                            },
                            keyboardType: TextInputType.number,
                            controller: quantityControllers[
                                index], // Use the corresponding controller
                          )),
                          DataCell(IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                selectedProducts.remove(
                                    product); // Remove the selected product from the list
                              });
                            },
                          )),
                        ]);
                      }).toList()
                        ..add(
                          DataRow(
                              color: MaterialStateColor.resolveWith((states) {
                                return Colors.grey.withOpacity(
                                    0.5); // Set the background color to grey for the total quantity row
                              }),
                              cells: [
                                DataCell(Text(
                                    '')), // Empty cell for the 'Remove' column
                                DataCell(Text(
                                  'Total',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                )),

                                DataCell(Text(
                                  calculateTotalQuantity().toStringAsFixed(
                                      2), // Show total quantity with two decimal places
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                )),
                              ]),
                        ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          "Total Quantity :",
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width/3.2,
                      ),
                      Text(
                          '${calculateTotalQuantity().toStringAsFixed(2)} Kg', // Show total quantity with two decimal places
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          "Weight in Bags :",
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width/5.6,
                      ),
                      Expanded(
                        child: Text(
                          bag, // Show total quantity with two decimal places
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 30),
                    child: Row(
                      children: [
                        Text(
                          textFieldLabel,
                          style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                        ),
                        Switch(
                          value: _isSwitchedOn,
                          onChanged: (value) {
                            setState(() {
                              _isSwitchedOn = value;
                              double inputValue = double.tryParse(
                                      _textEditingController.text) ??
                                  0.0;
                              if (_isSwitchedOn) {
                                _functionWhenSwitchedOn(inputValue);}
                              else {
                                _functionWhenSwitchedOff(inputValue);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter a number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Number';
                          }
                          return null;
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          "$textFieldLabel2",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$_result",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 20,top: 20),
                    child: Text("Total Paid:",style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: amountPaidController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Enter a number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Number ';
                          }
                          return null;
                        },
                      onFieldSubmitted:
                          (value) {
                        assignGrandTotal();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          "Remaining Amount: ",
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width/6.7,
                      ),
                      Text(
                        'Rs. ${lastvalue.toStringAsFixed(2)} ', // Show total quantity with two decimal places
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                 Padding(
                      padding: const EdgeInsets.only( top: 20),
                      child: Center(
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
                                }
                                else if (selectedCategory == null) {
                                  // Display error message for missing category selection
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Please select a Warehouse."),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.fixed,
                                    ),
                                  );
                                }
                                else if (selectedSupplier == null) {
                                  // Display error message for missing warehouse selection
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Please select a Supplier."),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.fixed,
                                    ),
                                  );
                                }
                                else {
                                  // All selections are made, proceed with the add() function
                                  setState(() {
                                    pickdate = _purchasedateController.text;
                                    duedate = _due_dateController.text;
                                  });
                                  add(selectedSupplier!.s_id);
                                  increaseItemByOne(selectedProduct!.p_id);
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

    void add()  {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('customer').doc();
      var brandId = docRef.id;

       docRef.set({
        'id': brandId,
        'name': name,
        'email': email,
        'phone': phone,
        'gender': setvalue,
        'address': address,
        'city': city,
        'state': state,
        'zip': zipcode,
        'country': country,
        'previous': previous_blanace,
        'total_spend': "",
        'invoices': "",
         'gender':"",
      }).then((value) {
        print('User Added');
        // Clear the input fields after adding the customer
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        addressController.clear();
        cityController.clear();
        stateController.clear();
        zipcodeController.clear();
        countryController.clear();
        previous_balanceController.clear();
        // Reset the dropdown value and selected text
        setState(() {
          setvalue = '';
        });
      }).catchError((error) => print('Failed to add user: $error'));
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter City';
                                }
                                return null;
                              }),
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

class ProductModel {
  String p_id;
  String p_name;
  double quantity;
  double unitPrice;

  ProductModel(this.p_id, this.p_name, this.unitPrice, this.quantity);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          p_id == other.p_id;

  @override
  int get hashCode => p_id.hashCode;
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
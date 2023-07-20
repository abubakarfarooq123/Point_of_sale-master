import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/items/product/add_product.dart';
import 'package:pos/user/edit_profile.dart';

import '../../splashScreens/loginout.dart';

import 'Brand.dart';

enum MenuItem {
  item1,
  item2,
}

class Product extends StatefulWidget {
  const Product({Key? key}) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {

  bool radioButtonValue = false;
  bool showMinMaxDropdowns = false;
  String? selectedValue;

  String? selectedCategoryId;
  String? selectedBrandId;

  bool isisRowSelected = false;
  int selectedRowIndex = -1; // Track the index of the selected row
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore.collection('Product').get();
    return snapshot.docs;
  }

  String selected = '';
  var setvalue;
  var setid;
  String selected1 = '';
  var setvalue1;
  List<String> unit = [
    'kg',
    'm',
    'g',
  ];
  String selected2 = '';
  var setvalue2;

  bool showAdditionalTextField = false;
  TextEditingController additionalTextController = TextEditingController();

  List<Get_Brand> brands = [];
  String? combinedValue;
  double? dividedValue;
  double? parchoondividedValue;
  double? wholesaledividedValue;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Object?> getValuesFromFirebase() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('Product')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return {}; // Default empty map if the document doesn't exist
  }

  void initState() {
    super.initState();
    // Call a function to listen for new customer additions
    fetchEmployeeData();
    getValuesFromFirebase().then((values) {
      setState(() {
        Map<String, dynamic> data = values as Map<String, dynamic>;
        nameController.text = data['item'] ?? '';
        skuController.text = data['sku']?.toString() ?? '';
        wholesaleController.text = data['wholesale'] ?? '';
        retailController.text = data['retail']?.toString() ?? '';
       parchoonController.text = data['parchoonval']?.toString() ?? '';
        descriptController.text = data['des']?.toString() ?? '';
        restokeController.text = data['restoke']?.toString() ?? '';
        selectedCategoryId = data['category']?.toString() ?? '';
        selectedBrandId = data['brand']?.toString() ?? '';
        // Update other controller values as needed
      });
    });
   }



  var name = "";
  var sku = "";
  var restoke = "";
  var retail = "";
  var wholesale = "";
  var descript = "";
  var parchoon = "";
  BrandModel? selectedBrand; // Declare the vafriable
  CategoryModel? selectedCategory; // Declare the variable
  UnitModel? selectedUnit; // Declare the variable

  UnitModel? selectedUnitMax;
  UnitModel? selectedUnitMin; // Declare the variable
// Declare the variable

  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final restokeController = TextEditingController();
  final retailController = TextEditingController();
  final wholesaleController = TextEditingController();
  final descriptController = TextEditingController();
  final parchoonController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Products",
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
                              width: 120,
                              child: TextField(
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide:
                                          BorderSide(color: Colors.black)),
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 45,
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
                              'Products',
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Brand',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Category',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'SKU',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Unit',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Purchase Price',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Retail Price',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Wholesale Price',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Parchoon Price',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Stock Availabiltiy',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Description',
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
                          String name = employeeData['item'];
                          String brand = employeeData['brand'];
                          String category = employeeData['category'];
                          String sku = employeeData['sku'];
                          String unit = employeeData['unit'];
                          String rate = employeeData['rate'];
                          String retail = employeeData['retail'];
                          String wholesale = employeeData['wholesale'];
                          String parchoon = employeeData['parchoonval'];
                          String quantity = employeeData['quantity'];
                          String des = employeeData['des'];

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
                              DataCell(Text(name ?? '')),
                              DataCell(Text(brand ?? '')),
                              DataCell(Text(category ?? '')),
                              DataCell(Text(sku ?? '')),
                              DataCell(Text(unit ?? '')),
                              DataCell(Text(rate ?? '')),
                              DataCell(Text(retail ?? '')),
                              DataCell(Text(wholesale ?? '')),
                              DataCell(Text(parchoon ?? '')),
                              DataCell(Text(quantity ?? '')),
                              DataCell(Text(des ?? '')),
                            ],
                          );
                        }).toList(),
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
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Add_product()));
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
                firestore.collection('Product').doc(selectedEmployeeId).delete().then((value) {
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
      String sku1 = skuController.text;
      String restoke1 = restokeController.text;
      String retail1 = retailController.text;
      String whole1 = wholesaleController.text;
      String desc1 = descriptController.text;
      String parchoon1 = parchoonController.text;



      Map<String, dynamic> data = {
        'item': name1,
        'sku':sku1 ,
        'restoke': restoke1,
        'retail': retail1,
        'wholesale': whole1,
        'des': desc1,
        'parchoonval':parchoon1,
        'brand': selectedBrand !=null ? selectedBrand!.title : selectedBrandId,
        'category': selectedCategory !=null ? selectedCategory!.c_title : selectedCategoryId,



      };
      FirebaseFirestore.instance
          .collection('Product')
          .doc(customerData['id'])
          .update(data);
    }

    nameController.text = customerData['item'] ?? '';
    skuController.text = customerData['sku']?.toString() ?? '';
    restokeController.text = customerData['restoke'] ?? '';
    retailController.text = customerData['retail']?.toString() ?? '';
    wholesaleController.text = customerData['wholesale']?.toString() ?? '';
    descriptController.text = customerData['des']?.toString() ?? '';
    parchoonController.text = customerData['parchoonval']?.toString() ?? '';
    selectedCategoryId = customerData['category']?.toString() ?? '';
    selectedBrandId= customerData['brand']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Implement your edit profile dialog here
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Edit ${nameController.text}'),
                content: Column(
                  children: [
                    Form(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Item Title',
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                icon: Icon(
                                  FontAwesomeIcons.shop,
                                  color: Colors.blue,
                                ),
                              ),
                              controller: nameController,
                              onChanged: (value) => name = value,

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
                                        FontAwesomeIcons.brandsFontAwesome,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: 159,
                                        height: 60,
                                        padding: EdgeInsets.only(left: 16, right: 0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey, width: 1),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('brand')
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
                                            List<BrandModel> unitItems = [];
                                            snapshot.data?.docs.forEach((doc) {
                                              String docId = doc.id;
                                              String title = doc['title'];
                                              unitItems.add(BrandModel(docId, title));
                                            });

                                            return DropdownButton<BrandModel>(
                                              icon: null,
                                              iconEnabledColor: Colors.white,
                                              isExpanded: true,
                                              underline: SizedBox(),
                                              hint: Text(selectedBrandId!,style: GoogleFonts.roboto(
                                                color: Colors.black
                                              ),),
                                              value: selectedBrand,
                                              items: unitItems.map((unit) {
                                                return DropdownMenuItem<BrandModel>(
                                                  value: unit,
                                                  child: Text(unit.title),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedBrand = value;
                                                  setvalue = value;
                                                  print('The selected unit ID is ${selectedBrand?.id}');
                                                  print('The selected unit ID1 is $setvalue');
                                                  print('The selected unit title is ${selectedBrand?.title}');
                                                  // Perform further operations with the selected unit
                                                });
                                              },
                                            );

                                          },
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
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.category,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      // Container(
                                      //   width: 159,
                                      //   height: 60,
                                      //   padding: EdgeInsets.only(left: 16, right: 16),
                                      //   decoration: BoxDecoration(
                                      //     border: Border.all(color: Colors.grey, width: 1),
                                      //     borderRadius: BorderRadius.circular(15),
                                      //   ),
                                      //   child: StreamBuilder<QuerySnapshot>(
                                      //     stream: FirebaseFirestore.instance.collection('category').snapshots(),
                                      //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      //       if (snapshot.hasError) {
                                      //         return Text('Error: ${snapshot.error}');
                                      //       }
                                      //       if (snapshot.connectionState == ConnectionState.waiting) {
                                      //         return Center(child: CircularProgressIndicator());
                                      //       }
                                      //
                                      //       List<CategoryModel> categoryItems = [];
                                      //       snapshot.data?.docs.forEach((doc) {
                                      //         String docId = doc.id;
                                      //         String title = doc['title'];
                                      //
                                      //         categoryItems.add(CategoryModel(docId, title));
                                      //
                                      //         // Check if the retrieved category ID matches the selected category ID
                                      //         if (docId == selectedCategory?.c_id) {
                                      //           selectedCategory = CategoryModel(docId, title);
                                      //         }
                                      //       });
                                      //
                                      //       // If the selected category is still null and there are items in the list, assign the first category as the default
                                      //       if (selectedCategory == null && categoryItems.isNotEmpty) {
                                      //         selectedCategory = categoryItems[0];
                                      //       }
                                      //
                                      //       return DropdownButton<CategoryModel>(
                                      //         iconSize: 40,
                                      //         isExpanded: true,
                                      //         underline: SizedBox(),
                                      //         hint: Text('Select Warehouse'),
                                      //         value: selectedCategory,
                                      //         items: categoryItems.map((unit) {
                                      //           return DropdownMenuItem<CategoryModel>(
                                      //             value: unit,
                                      //             child: Text(unit.c_title),
                                      //           );
                                      //         }).toList(),
                                      //         onChanged: (value) {
                                      //           setState(() {
                                      //             selectedCategory = value;
                                      //             setvalue = value;
                                      //             print(
                                      //                 'The selected unit ID is ${selectedCategory?.c_id}');
                                      //             print('The selected unit ID1 is $setvalue');
                                      //             print(
                                      //                 'The selected unit title is ${selectedCategory?.c_title}');
                                      //             // Perform further operations with the selected unit
                                      //             if (selectedCategory == null) {
                                      //              }
                                      //           });
                                      //         },
                                      //       );
                                      //
                                      //
                                      //     },
                                      //   ),
                                      // ),
                                      Container(
                                        width: 159,
                                        height: 60,
                                        padding: EdgeInsets.only(left: 16, right: 0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey, width: 1),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('category')
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
                                              String title = doc['title'];
                                              unitItems.add(CategoryModel(docId, title));
                                            });

                                            return DropdownButton<CategoryModel>(
                                              icon:null,
                                              iconEnabledColor: Colors.white,
                                              isExpanded: true,
                                              underline: SizedBox(),
                                              hint: Text(selectedCategoryId!,style: GoogleFonts.roboto(
                                                color: Colors.black
                                              ),),
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
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    selected1,
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
                            const EdgeInsets.only(
                                left: 18, right: 18, bottom: 18),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'SKU',
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
                                  FontAwesomeIcons.barcode,
                                  color: Colors.blue,
                                ),
                              ),
                              controller: skuController,
                              onChanged: (value) => sku = value,

                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Restoke Alert',
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
                                  FontAwesomeIcons.box,
                                  color: Colors.blue,
                                ),
                              ),
                              controller: restokeController,
                              onChanged: (value) => restoke = value,

                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Retail Price',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                errorStyle: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 15.0,
                                ),
                                icon: Icon(
                                  FontAwesomeIcons.moneyBill,
                                  color: Colors.blue,
                                ),
                              ),
                              controller: retailController,
                              onChanged: (value) => retail = value,

                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Wholesale Price',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                errorStyle: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 15.0,
                                ),
                                icon: Icon(
                                  Icons.money,
                                  color: Colors.blue,
                                ),
                              ),
                              controller: wholesaleController,
                              onChanged: (value) => wholesale = value,

                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Parchoon Price',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1),
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
                              controller: parchoonController,
                              onChanged: (value) => parchoon = value,

                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: TextFormField(
                              minLines: 5,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Description',
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
                              controller: descriptController,
                              onChanged: (value) => descript= value,

                            ),
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          // ignore: deprecated_member_use
                          Container(
                            height: 45.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue),
                            child: InkWell(
                              onTap: () {
                                _updateSelectedValues();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Product(),
                                  ),
                                );
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
          }
        );
      },
    );
  }
  String? Unitid;
  String? rate;
  String? stock;
  void showEditProfileDetailDialog(BuildContext context, dynamic customerData) {

    nameController.text = customerData['item'] ?? '';
    skuController.text = customerData['sku']?.toString() ?? '';
    restokeController.text = customerData['restoke'] ?? '';
    retailController.text = customerData['retail']?.toString() ?? '';
    wholesaleController.text = customerData['wholesale']?.toString() ?? '';
    descriptController.text = customerData['des']?.toString() ?? '';
    parchoonController.text = customerData['parchoonval']?.toString() ?? '';
    selectedCategoryId = customerData['category']?.toString() ?? '';
    selectedBrandId= customerData['brand']?.toString() ?? '';
    Unitid= customerData['unit']?.toString() ?? '';
    rate = customerData['rate']?.toString() ?? '';
    stock = customerData['quantity']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Implement your edit profile dialog here
        return SingleChildScrollView(
          child: AlertDialog(
            title: Container(
              height: 40,
              child: Stack(
                children: [
                  Text('${nameController.text} Profile',style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),),
                  Positioned(
                    right: 7,
                    bottom:3,
                    child: IconButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.clear,size: 32,)),
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
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.4),width: 1),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                        SizedBox(
                        width: 20,
                  
                      ),
                  Text(
                              "Product: ",style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),
                            ),
                  SizedBox(
                    width: 20,
                  
                  ),
                  Text(
                              nameController.text,
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.4),
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                              "Product Sku: ",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                            ),
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                              skuController.text,
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.4),
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                              "Brand: ",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                            ),
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                              selectedBrandId!,
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(  
                        height: 1,
                        color: Colors.grey.withOpacity(0.4),
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                              "Category: ",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                            ),
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                              selectedCategoryId!,
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.4),
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                              "Unit: ",style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            Unitid!,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.4),
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            "Purchase Prcie: ",style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            rate!,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.4),
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            "Sale Price: ",style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            retailController.text,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.4),
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            "WholeSale: ",style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            wholesaleController.text,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.4),
                        thickness: 1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            "Stock Available: ",style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                          ),
                          SizedBox(
                            width: 20,
                  
                          ),
                          Text(
                            stock!,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 16,
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
        );
      },
    );
  }



}

class BrandModel {
  String id;
  String title;

  BrandModel(this.id, this.title);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BrandModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
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
// Column(
//   children: [
//     Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 8),
//           child: Icon(
//             Icons.ad_units,
//             color: Colors.blue,
//             size: 28,
//           ),
//         ),
//         SizedBox(
//           width: 10,
//         ),
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               radioButtonValue = !radioButtonValue;
//               showMinMaxDropdowns = radioButtonValue;
//               if (!showMinMaxDropdowns) {
//                 showAdditionalTextField = false;
//                 additionalTextController.clear();
//               }
//             });
//           },
//           child: Row(
//             children: [
//               SizedBox(
//                 width: 3,
//               ),
//               Text(
//                 "Select Multi Units",
//                 style: GoogleFonts.roboto(
//                     color: Colors.black,
//                     fontSize: 16),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: radioButtonValue
//                       ? Colors.blue
//                       : Colors.transparent,
//                 ),
//                 padding: EdgeInsets.all(8.0),
//                 child: radioButtonValue
//                     ? Icon(Icons.radio_button_checked,
//                     color: Colors.white)
//                     : Icon(
//                     Icons.radio_button_unchecked),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//     Offstage(
//       offstage: showMinMaxDropdowns,
//       child: Padding(
//         padding: const EdgeInsets.only(
//             left: 10, top: 10, bottom: 30),
//         child: Container(
//           width: 120,
//           height: 60,
//           padding: EdgeInsets.only(
//               left: 16, right: 0),
//           decoration: BoxDecoration(
//             border: Border.all(
//                 color: Colors.grey, width: 1),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('Unit')
//                 .snapshots(),
//             builder: (BuildContext context,
//                 AsyncSnapshot<
//                     QuerySnapshot> snapshot) {
//               if (snapshot.hasError) {
//                 return Text(
//                     'Error: ${snapshot.error}');
//               }
//               if (snapshot.connectionState ==
//                   ConnectionState.waiting) {
//                 return Center(
//                     child: CircularProgressIndicator());
//               }
//               List<UnitModel> unitItems = [];
//               snapshot.data?.docs.forEach((doc) {
//                 String docId = doc.id;
//                 String title = doc['name'];
//                 unitItems.add(
//                     UnitModel(docId, title));
//               });
//
//               return DropdownButton<UnitModel>(
//                 iconSize: 40,
//                 isExpanded: true,
//                 underline: SizedBox(),
//                 hint: Text('Select unit'),
//                 value: selectedUnit,
//                 items: unitItems.map((unit) {
//                   return DropdownMenuItem<UnitModel>(
//                     value: unit,
//                     child: Text(unit.u_title),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     selectedUnit = value;
//                     setvalue = value;
//                     print(
//                         'The selected unit ID is ${selectedUnit
//                             ?.u_id}');
//                     print(
//                         'The selected unit ID1 is $setvalue');
//                     print(
//                         'The selected unit title is ${selectedUnit
//                             ?.u_title}');
//                     // Perform further operations with the selected unit
//                   });
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//     ),
//     Offstage(
//       offstage: !showMinMaxDropdowns,
//       child: Column(
//         children: [
//           SizedBox(
//             height: 20,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment
//                 .spaceAround,
//             children: [
//               Text(
//                 "Minimum Unit",
//                 style: GoogleFonts.roboto(
//                     color: Colors.black,
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold),
//               ),
//               SizedBox(
//                 width: 4,
//               ),
//               Text(
//                 "Maximum Unit",
//                 style: GoogleFonts.roboto(
//                     color: Colors.black,
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold),
//               ),
//               SizedBox(
//                 width: 10,
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment
//                 .spaceEvenly,
//             children: [
//               SizedBox(
//                 width: 20,
//               ),
//               Expanded(
//                 child: Container(
//                   width: 120,
//                   height: 60,
//                   padding:
//                   EdgeInsets.only(left: 16, right: 0),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                         color: Colors.grey, width: 1),
//                     borderRadius: BorderRadius
//                         .circular(15),
//                   ),
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('Unit')
//                         .snapshots(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<QuerySnapshot>
//                         snapshot) {
//                       if (snapshot.hasError) {
//                         return Text(
//                             'Error: ${snapshot
//                                 .error}');
//                       }
//                       if (snapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return Center(
//                             child:
//                             CircularProgressIndicator());
//                       }
//                       List<UnitModel> unitItems = [];
//                       snapshot.data?.docs.forEach((
//                           doc) {
//                         String docId = doc.id;
//                         String title = doc['name'];
//                         unitItems
//                             .add(
//                             UnitModel(docId, title));
//                       });
//
//                       return DropdownButton<
//                           UnitModel>(
//                         iconSize: 40,
//                         isExpanded: true,
//                         underline: SizedBox(),
//                         hint: Text('Select unit'),
//                         value: selectedUnitMin,
//                         items: unitItems.map((unit) {
//                           return DropdownMenuItem<
//                               UnitModel>(
//                             value: unit,
//                             child: Text(unit.u_title),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedUnitMin = value;
//                             setvalue = value;
//                             print(
//                                 'The selected unit ID is ${selectedUnitMin
//                                     ?.u_id}');
//                             print(
//                                 'The selected unit ID1 is $setvalue');
//                             print(
//                                 'The selected unit title is ${selectedUnitMin
//                                     ?.u_title}');
//                             // Perform further operations with the selected unit
//                           });
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(width: 16.0),
//               Expanded(
//                 child: Container(
//                     width: 159,
//                     height: 60,
//                     padding:
//                     EdgeInsets.only(
//                         left: 16, right: 16),
//                     decoration: BoxDecoration(
//                         border: Border.all(
//                             color: Colors.grey,
//                             width: 1),
//                         borderRadius:
//                         BorderRadius.circular(15)),
//                     child: StreamBuilder<
//                         QuerySnapshot>(
//                       stream: FirebaseFirestore
//                           .instance
//                           .collection('Unit')
//                           .snapshots(),
//                       builder: (BuildContext context,
//                           AsyncSnapshot<QuerySnapshot>
//                           snapshot) {
//                         if (snapshot.hasError) {
//                           return Text(
//                               'Error: ${snapshot
//                                   .error}');
//                         }
//                         if (snapshot
//                             .connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(
//                               child:
//                               CircularProgressIndicator());
//                         }
//                         List<UnitModel> unitItems = [
//                         ];
//                         snapshot.data?.docs.forEach((
//                             doc) {
//                           String docId = doc.id;
//                           String title = doc['name'];
//                           unitItems
//                               .add(UnitModel(
//                               docId, title));
//                         });
//
//                         // Assign the first brand item as the default selectedBrand
//                         if (selectedUnitMax == null &&
//                             unitItems.isNotEmpty) {
//                           selectedUnitMax =
//                           unitItems[0];
//                         }
//
//                         return DropdownButton<
//                             UnitModel>(
//                           iconSize: 40,
//                           isExpanded: true,
//                           underline: SizedBox(),
//                           value: selectedUnitMax,
//                           items: unitItems.map((
//                               unit) {
//                             return DropdownMenuItem<
//                                 UnitModel>(
//                               value: unit,
//                               child: Text(
//                                   unit.u_title),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedUnitMax = value;
//                               setvalue = value;
//                               if (selectedUnitMax !=
//                                   null) {
//                                 showAdditionalTextField =
//                                 true;
//                               } else {
//                                 showAdditionalTextField =
//                                 false;
//                                 additionalTextController
//                                     .clear();
//                               }
//                               print(
//                                   'The selected brand ID is ${selectedUnitMax!
//                                       .u_id}');
//                               print(
//                                   'The selected brand ID1 is ${setvalue}');
//                               print(
//                                   'The selected brand title is ${selectedUnitMax!
//                                       .u_title}');
//                               // Perform further operations with the selected brand
//                             });
//                             combinedValue =
//                             '${selectedUnitMin!
//                                 .u_title} - ${selectedUnitMax!
//                                 .u_title}';
//                           },
//                         );
//                       },
//                     )),
//               ),
//               SizedBox(
//                 width: 20,
//               ),
//             ],
//           ),
//           if (showAdditionalTextField)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Conversion Quantity ${selectedUnitMin!
//                           .u_title} -${selectedUnitMax!
//                           .u_title}",
//                       style: GoogleFonts.roboto(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   TextFormField(
//                     controller: additionalTextController,
//                     keyboardType: TextInputType
//                         .number,
//                     decoration: InputDecoration(
//                       labelText: 'Add Number',
//                       border: OutlineInputBorder(
//                           borderRadius:
//                           BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     ),
//     SizedBox(
//       height: 10,
//     ),
//   ],
// ),
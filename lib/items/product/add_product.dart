import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/items/product/product.dart';
import 'package:pos/user/edit_profile.dart';
import '../../splashScreens/loginout.dart';
import 'Brand.dart';

enum MenuItem {
  item1,
  item2,
}

class Add_product extends StatefulWidget {
  @override
  State<Add_product> createState() => _Add_productState();
}

class _Add_productState extends State<Add_product> {
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
  @override
  void initState() {
    super.initState();
    fetchBrands().then((brands) {
      setState(() {
        this.brands = brands;
      });
      selectedUnit =
          UnitModel(selectedUnitMin!.u_title, selectedUnitMax!.u_title);
      fetchData();
    });
  }

  final _formKey = GlobalKey<FormState>();

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

  void dispose() {
    nameController.dispose();
    skuController.dispose();
    restokeController.dispose();
    retailController.dispose();
    wholesaleController.dispose();
    parchoonController.dispose();
    descriptController.dispose();
    additionalTextController.dispose();
    super.dispose();
  }

  double? dividedValue;
  double? parchoondividedValue;
  double? wholesaledividedValue;

  add() async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('Product').doc();
    var brandId = docRef.id;

    await docRef
        .set({
          'id': brandId,
          'item': name,
          'brand': selectedBrand!.title,
          'category': selectedCategory!.c_title,
          'unit': selectedUnit?.u_title != null
              ? selectedUnit!.u_title
              : combinedValue,
          'sku': sku,
          'restoke': restoke,
          'retail': retail,
          'wholesale': wholesale,
          'des': descript,
          'quantity': '0',
          'expiry': '',
          'rate': '0',
          'conversion': additionalTextController.text,
          'val': dividedValue,
          'wholesaleval': wholesaledividedValue,
          'parchoon': parchoondividedValue,
          'parchoonval': parchoon,
        })
        .then((value) => print('User Added'))
        .catchError((error) => print('Failed to add user: $error'));
    print('combinedValue: $combinedValue');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Product(),
      ),
    );
  }

  bool radioButtonValue = false;
  bool showMinMaxDropdowns = false;
  String? selectedValue;

  List<String> collection1Data = [];
  List<String> collection2Data = [];
  List<String> collection3Data = [];

  @override
  Future<void> fetchData() async {
    // Fetch data from collection1
    QuerySnapshot collection1Snapshot =
        await FirebaseFirestore.instance.collection('brand').get();
    collection1Snapshot.docs.forEach((QueryDocumentSnapshot doc) {
      setState(() {
        collection1Data.add(doc[
            'title']); // Replace 'fieldName' with the desired field name from your document
      });
    });

    // Fetch data from collection2
    QuerySnapshot collection2Snapshot =
        await FirebaseFirestore.instance.collection('category').get();
    collection2Snapshot.docs.forEach((QueryDocumentSnapshot doc) {
      setState(() {
        collection2Data.add(doc[
            'title']); // Replace 'fieldName' with the desired field name from your document
      });
    });

    QuerySnapshot collection3Snapshot =
        await FirebaseFirestore.instance.collection('Unit').get();
    collection3Snapshot.docs.forEach((QueryDocumentSnapshot doc) {
      setState(() {
        collection3Data.add(doc[
            'lable']); // Replace 'fieldName' with the desired field name from your document
      });
    });
  }

  // String itemId = FirebaseFirestore.instance.collection('brand').doc().id;

  // Function to increase the item by one
  Future<void> increaseItemByOne(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('brand')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['item'];

      print("CurrentValue $currentValue");

      int? parsedValue = int.tryParse(currentValue);
      if (parsedValue != null) {
        int incrementedValue = parsedValue + 1;
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();
        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('brand')
            .doc(itemId)
            .update({'item': updatedValue});
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

  Future<void> increaseItemByOneCategory(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('category')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['item'];

      print("CurrentValue $currentValue");

      int? parsedValue = int.tryParse(currentValue);
      if (parsedValue != null) {
        int incrementedValue = parsedValue + 1;
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();
        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('category')
            .doc(itemId)
            .update({'item': updatedValue});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Add Product",
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
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: InkWell(
                      child: Container(
                        child: DottedBorder(
                          color: Colors.black,
                          strokeWidth: 3,
                          dashPattern: [4, 4],
                          child: Container(
                            height: 160,
                            width: 190,
                            child: Center(
                              child: Image.asset("assets/images/img.png",
                                  width: 80, height: 60),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Title';
                          }
                          return null;
                        }),
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
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                      List<BrandModel> brandItems = [];
                                      snapshot.data?.docs.forEach((doc) {
                                        String docId = doc.id;
                                        String title = doc['title'];
                                        brandItems
                                            .add(BrandModel(docId, title));
                                      });

                                      // Assign the first brand item as the default selectedBrand
                                      if (selectedBrand == null &&
                                          brandItems.isNotEmpty) {
                                        selectedBrand = brandItems[0];
                                      }

                                      return DropdownButton<BrandModel>(
                                        iconSize: 40,
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        value: selectedBrand,
                                        items: brandItems.map((brand) {
                                          return DropdownMenuItem<BrandModel>(
                                            value: brand,
                                            child: Text(brand.title),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedBrand = value;
                                            setvalue = value;
                                            print(
                                                'The selected brand ID is ${selectedBrand!.id}');
                                            print(
                                                'The selected brand ID1 is ${setvalue}');
                                            print(
                                                'The selected brand title is ${selectedBrand!.title}');
                                            // Perform further operations with the selected brand
                                          });
                                        },
                                      );
                                    },
                                  )),
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
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                      List<CategoryModel> catogryItems = [];
                                      snapshot.data?.docs.forEach((doc) {
                                        String docId = doc.id;
                                        String title = doc['title'];
                                        catogryItems
                                            .add(CategoryModel(docId, title));
                                      });

                                      // Assign the first brand item as the default selectedBrand
                                      if (selectedCategory == null &&
                                          catogryItems.isNotEmpty) {
                                        selectedCategory = catogryItems[0];
                                      }

                                      return DropdownButton<CategoryModel>(
                                        iconSize: 40,
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        value: selectedCategory,
                                        items: catogryItems.map((category) {
                                          return DropdownMenuItem<
                                              CategoryModel>(
                                            value: category,
                                            child: Text(category.c_title),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedCategory = value;
                                            setvalue = value;
                                            print(
                                                'The selected brand ID is ${selectedCategory!.c_id}');
                                            print(
                                                'The selected brand ID1 is ${setvalue}');
                                            print(
                                                'The selected brand title is ${selectedCategory!.c_title}');
                                            // Perform further operations with the selected brand
                                          });
                                        },
                                      );
                                    },
                                  )),
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
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Icon(
                              Icons.ad_units,
                              color: Colors.blue,
                              size: 35,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                radioButtonValue = !radioButtonValue;
                                showMinMaxDropdowns = radioButtonValue;
                                if (!showMinMaxDropdowns) {
                                  showAdditionalTextField = false;
                                  additionalTextController.clear();
                                }
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "Select Multi Units",
                                  style: GoogleFonts.roboto(
                                      color: Colors.black, fontSize: 16),
                                ),
                                SizedBox(
                                  width: 115,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: radioButtonValue
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: radioButtonValue
                                      ? Icon(Icons.radio_button_checked,
                                          color: Colors.white)
                                      : Icon(Icons.radio_button_unchecked),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Offstage(
                        offstage: showMinMaxDropdowns,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30, top: 10, bottom: 30),
                          child: Container(
                            width: 280,
                            height: 60,
                            padding: EdgeInsets.only(left: 16, right: 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Unit')
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
                                List<UnitModel> unitItems = [];
                                snapshot.data?.docs.forEach((doc) {
                                  String docId = doc.id;
                                  String title = doc['name'];
                                  unitItems.add(UnitModel(docId, title));
                                });

                                return DropdownButton<UnitModel>(
                                  iconSize: 40,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  hint: Text('Select unit'),
                                  value: selectedUnit,
                                  items: unitItems.map((unit) {
                                    return DropdownMenuItem<UnitModel>(
                                      value: unit,
                                      child: Text(unit.u_title),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedUnit = value;
                                      setvalue = value;
                                      print(
                                          'The selected unit ID is ${selectedUnit?.u_id}');
                                      print(
                                          'The selected unit ID1 is $setvalue');
                                      print(
                                          'The selected unit title is ${selectedUnit?.u_title}');
                                      // Perform further operations with the selected unit
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Offstage(
                        offstage: !showMinMaxDropdowns,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Minimum Unit",
                                  style: GoogleFonts.roboto(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "Maximum Unit",
                                  style: GoogleFonts.roboto(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Container(
                                    width: 280,
                                    height: 60,
                                    padding:
                                        EdgeInsets.only(left: 16, right: 0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Unit')
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
                                        List<UnitModel> unitItems = [];
                                        snapshot.data?.docs.forEach((doc) {
                                          String docId = doc.id;
                                          String title = doc['name'];
                                          unitItems
                                              .add(UnitModel(docId, title));
                                        });

                                        return DropdownButton<UnitModel>(
                                          iconSize: 40,
                                          isExpanded: true,
                                          underline: SizedBox(),
                                          hint: Text('Select unit'),
                                          value: selectedUnitMin,
                                          items: unitItems.map((unit) {
                                            return DropdownMenuItem<UnitModel>(
                                              value: unit,
                                              child: Text(unit.u_title),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedUnitMin = value;
                                              setvalue = value;
                                              print(
                                                  'The selected unit ID is ${selectedUnitMin?.u_id}');
                                              print(
                                                  'The selected unit ID1 is $setvalue');
                                              print(
                                                  'The selected unit title is ${selectedUnitMin?.u_title}');
                                              // Perform further operations with the selected unit
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: Container(
                                      width: 279,
                                      height: 60,
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('Unit')
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
                                          List<UnitModel> unitItems = [];
                                          snapshot.data?.docs.forEach((doc) {
                                            String docId = doc.id;
                                            String title = doc['name'];
                                            unitItems
                                                .add(UnitModel(docId, title));
                                          });

                                          // Assign the first brand item as the default selectedBrand
                                          if (selectedUnitMax == null &&
                                              unitItems.isNotEmpty) {
                                            selectedUnitMax = unitItems[0];
                                          }

                                          return DropdownButton<UnitModel>(
                                            iconSize: 40,
                                            isExpanded: true,
                                            underline: SizedBox(),
                                            value: selectedUnitMax,
                                            items: unitItems.map((unit) {
                                              return DropdownMenuItem<
                                                  UnitModel>(
                                                value: unit,
                                                child: Text(unit.u_title),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedUnitMax = value;
                                                setvalue = value;
                                                if (selectedUnitMax != null) {
                                                  showAdditionalTextField =
                                                      true;
                                                } else {
                                                  showAdditionalTextField =
                                                      false;
                                                  additionalTextController
                                                      .clear();
                                                }
                                                print(
                                                    'The selected brand ID is ${selectedUnitMax!.u_id}');
                                                print(
                                                    'The selected brand ID1 is ${setvalue}');
                                                print(
                                                    'The selected brand title is ${selectedUnitMax!.u_title}');
                                                // Perform further operations with the selected brand
                                              });
                                              combinedValue =
                                                  '${selectedUnitMin!.u_title} - ${selectedUnitMax!.u_title}';
                                            },
                                          );
                                        },
                                      )),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                            if (showAdditionalTextField)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Conversion Quantity ${selectedUnitMin!.u_title} -${selectedUnitMax!.u_title}",
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    TextFormField(
                                      controller: additionalTextController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Add Number',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.only(left: 18, right: 18, bottom: 18),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter SKU Number';
                          }
                          return null;
                        }),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Restoke';
                          }
                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Retail Price',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Price';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            additionalTextController.text.isNotEmpty) {
                          double retailValue = double.tryParse(value) ?? 0;
                          double additionalValue =
                              double.tryParse(additionalTextController.text) ??
                                  0;

                          if (additionalValue != 0) {
                            setState(() {
                              dividedValue = retailValue / additionalValue;
                            });
                          } else {
                            setState(() {
                              dividedValue = null;
                            });
                          }
                        } else {
                          setState(() {
                            dividedValue = null;
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Wholesale Price',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Price';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            additionalTextController.text.isNotEmpty) {
                          double wholesaleValue = double.tryParse(value) ?? 0;
                          double additionalValue =
                              double.tryParse(additionalTextController.text) ??
                                  0;

                          if (additionalValue != 0) {
                            setState(() {
                              wholesaledividedValue =
                                  wholesaleValue / additionalValue;
                            });
                          } else {
                            setState(() {
                              wholesaledividedValue = null;
                            });
                          }
                        } else {
                          setState(() {
                            wholesaledividedValue = null;
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Parchoon Price',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
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
                      controller: parchoonController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Price';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            additionalTextController.text.isNotEmpty) {
                          double parchoonValue = double.tryParse(value) ?? 0;
                          double additionalValue =
                              double.tryParse(additionalTextController.text) ??
                                  0;

                          if (additionalValue != 0) {
                            setState(() {
                              parchoondividedValue =
                                  parchoonValue / additionalValue;
                            });
                          } else {
                            setState(() {
                              parchoondividedValue = null;
                            });
                          }
                        } else {
                          setState(() {
                            parchoondividedValue = null;
                          });
                        }
                      },
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Description';
                          }
                          return null;
                        }),
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
                            sku = skuController.text;
                            restoke = restokeController.text;
                            retail = retailController.text;
                            wholesale = wholesaleController.text;
                            parchoon = parchoonController.text;
                            descript = descriptController.text;
                          });
                          add();
                          increaseItemByOne(selectedBrand!.id);
                          increaseItemByOne(selectedUnit!.u_id);
                          increaseItemByOne(selectedUnitMin!.u_id);
                          increaseItemByOne(selectedUnitMax!.u_id);
                          increaseItemByOneCategory(selectedCategory!.c_id);
                          print('the item id is ${selectedBrand!.id}');
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

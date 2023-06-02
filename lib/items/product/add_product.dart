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

enum MenuItem{
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
  String selected1 = '';
  var setvalue1;
  List<String> unit =['kg','m','g',];
  String selected2 = '';
  var setvalue2;

  List<Get_Brand> brands = [];
  late Get_Brand selectedBrand;

  @override
  void initState() {
    super.initState();
    fetchBrands().then((brands) {
      setState(() {
        this.brands = brands;
      });
      fetchData();
    });
  }
  final _formKey = GlobalKey<FormState>();

  var name = "";
  var sku = "";
  var restoke = "";
  var retail = "";
  var wholesale = "";
  var purchase = "";
  var descript = "";


  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final restokeController = TextEditingController();
  final retailController = TextEditingController();
  final purchaseController = TextEditingController();
  final wholesaleController = TextEditingController();
  final descriptController = TextEditingController();

  void dispose() {
    nameController.dispose();
    skuController.dispose();
    restokeController.dispose();
    retailController.dispose();
    purchaseController.dispose();
    wholesaleController.dispose();
    descriptController.dispose();
    super.dispose();
  }

  add() async {
    await FirebaseFirestore.instance
        .collection('Product')
        .doc()
        .set({
      'item': name,
      'brand': setvalue,
      'category':setvalue1,
      'unit': setvalue2,
      'sku':sku,
      'restoke': restoke,
      'retail':retail,
      'wholesale':wholesale,
      'purchase': purchase,
      'des':descript
    })
        .then((value) => print('User Added'))
        .catchError((error) => print('Failed to add user: $error'));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Product(),
      ),
    );
  }
  List<String> collection1Data = [];
  List<String> collection2Data = [];
  List<String> collection3Data = [];

  @override

  Future<void> fetchData() async {
    // Fetch data from collection1
    QuerySnapshot collection1Snapshot = await FirebaseFirestore.instance.collection('brand').get();
    collection1Snapshot.docs.forEach((QueryDocumentSnapshot doc) {
      setState(() {
        collection1Data.add(doc['title']); // Replace 'fieldName' with the desired field name from your document
      });
    });

    // Fetch data from collection2
    QuerySnapshot collection2Snapshot = await FirebaseFirestore.instance.collection('category').get();
    collection2Snapshot.docs.forEach((QueryDocumentSnapshot doc) {
      setState(() {
        collection2Data.add(doc['title']); // Replace 'fieldName' with the desired field name from your document
      });
    });

    QuerySnapshot collection3Snapshot = await FirebaseFirestore.instance.collection('Unit').get();
    collection3Snapshot.docs.forEach((QueryDocumentSnapshot doc) {
      setState(() {
        collection3Data.add(doc['lable']); // Replace 'fieldName' with the desired field name from your document
      });
    });
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
            onSelected: (value){
              if(value== MenuItem.item1){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Edit_Profile()));
              }
              if(value== MenuItem.item2){
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginOut()));

                    (route) => false;
              }

            },
            itemBuilder: (context)=>[
              PopupMenuItem(
                value: MenuItem.item1,
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 10,),
                    Text(
                      "Edit Profile",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16
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
                    SizedBox(width: 10,),
                    Text(
                      "Logout",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16
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
            new Form(
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
                              dashPattern: [4,4],
                              child: Container(
                          height:160,
                                width:190,
                                child: Center(
                                  child: Image.asset("assets/images/img.png",width: 80,height: 60),
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
                          borderSide: BorderSide(color: Colors.grey,width: 1),
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
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14,right: 14,top: 14),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(FontAwesomeIcons.brandsFontAwesome,color: Colors.blue,size: 35,),
                              SizedBox(width: 10,),
                              Container(
                                width: 279,
                                height: 60,
                                padding: EdgeInsets.only(left: 16,right: 16),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey,width: 1),
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child:StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('brand').snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    List<DropdownMenuItem<String>> dropdownItems = [];
                                    snapshot.data?.docs.forEach((doc) {
                                      dropdownItems.add(
                                        DropdownMenuItem(
                                          value: doc['title'],
                                          child: Text(doc['title']),
                                        ),
                                      );
                                    });
                                    return DropdownButton<String>(
                                      iconSize: 40,
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      value: setvalue,
                                      items: dropdownItems,
                                      onChanged: (value) {
                                        setState(() {
                                          setvalue = value;
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
                    padding: const EdgeInsets.only(left: 14,right: 14),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(Icons.category,color: Colors.blue,size: 35,),
                              SizedBox(width: 10,),
                              Container(
                                width: 279,
                                height: 60,
                                padding: EdgeInsets.only(left: 16,right: 16),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey,width: 1),
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('category').snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    List<DropdownMenuItem<String>> dropdownItems = [];
                                    snapshot.data?.docs.forEach((doc) {
                                      dropdownItems.add(
                                        DropdownMenuItem(
                                          value: doc['title'],
                                          child: Text(doc['title']),
                                        ),
                                      );
                                    });
                                    return DropdownButton<String>(
                                      iconSize: 40,
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      value: setvalue1,
                                      items: dropdownItems,
                                      onChanged: (value) {
                                        setState(() {
                                          setvalue1 = value;
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
                    padding: const EdgeInsets.only(left: 14,right: 14),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Icon(Icons.ad_units_outlined,color: Colors.blue,size: 35,),
                              SizedBox(width: 10,),
                              Container(
                                width: 279,
                                height: 60,
                                padding: EdgeInsets.only(left: 16,right: 16),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey,width: 1),
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('Unit').snapshots(),
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    List<DropdownMenuItem<String>> dropdownItems = [];
                                    snapshot.data?.docs.forEach((doc) {
                                      dropdownItems.add(
                                        DropdownMenuItem(
                                          value: doc['lable'],
                                          child: Text(doc['lable']),
                                        ),
                                      );
                                    });
                                    return DropdownButton<String>(
                                      iconSize: 40,
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      value: setvalue2,
                                      items: dropdownItems,
                                      onChanged: (value) {
                                        setState(() {
                                          setvalue2 = value;
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
                            selected2,
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
                    padding: const EdgeInsets.only(left: 18,right: 18,bottom: 18),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'SKU',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
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
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Restoke Alert',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
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
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Retail Price',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
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
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Wholesale Price',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
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
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Purchase Price',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
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
                        controller: purchaseController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Price';
                          }
                          return null;
                        }
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
                        controller: descriptController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Description';
                          }
                          return null;
                        }
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
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            name = nameController.text;
                            sku = skuController.text;
                            restoke = restokeController.text;
                           retail = retailController.text;
                           purchase = purchaseController.text;
                           wholesale = wholesaleController.text;
                            descript = descriptController.text;
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
  }
}

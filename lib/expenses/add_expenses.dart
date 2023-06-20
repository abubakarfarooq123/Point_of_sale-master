import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/expenses/expenses.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/user/edit_profile.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:intl/intl.dart';
import '../splashScreens/loginout.dart';
import '../user/login.dart';

enum MenuItem {
  item1,
  item2,
}
FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference totalAmountsCollection = firestore.collection('expenses_category');

class Add_Expenses extends StatefulWidget {
  @override
  State<Add_Expenses> createState() => _Add_ExpensesState();
}

class _Add_ExpensesState extends State<Add_Expenses> {
  final _formKey = GlobalKey<FormState>();
  CategoryModel? selectedCategory; // Declare the variable

  expensecategoryModel? selectedexpenseCategory;

  double? totalAmount;

  var date = "";
  final dateController = TextEditingController();
  var amount = "";
  final amountController = TextEditingController();

  final selectedCategoryController = TextEditingController();
  var note = "";
  final noteController = TextEditingController();

  void dispose() {
    dateController.dispose();
    amountController.dispose();
    noteController.dispose();
    selectedCategoryController.dispose();
    super.dispose();
  }

  add() async {
    await FirebaseFirestore.instance
        .collection('expense')
        .doc()
        .set({
          'date': date,
          'category': selectedCategory!.c_title,
          'amount': amount,
          'note': note,
        })
        .then((value) => print('User Added'))
        .catchError((error) => print('Failed to add user: $error'));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Expenses(),
      ),
    );
  }

  List<String> role = ['load', 'unload', 'loading'];
  String selected = '';
  var setvalue;
  Future<void> increaseItemByOneCategory(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('expenses_category')
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
            .collection('expenses_category')
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

  Future<void> increaseItemByOne(String itemId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('expenses_category')
          .doc(itemId)
          .get();
      String currentValue = snapshot.data()!['amount'];

      print("CurrentValue $currentValue");

      double enteredAmount = double.parse(currentValue);
      if (enteredAmount != null) {
        double incrementedValue = enteredAmount + double.parse(amountController.text);
        print("incrementedValue $incrementedValue");
        String updatedValue = incrementedValue.toString();


        // Now you can use the updatedValue as needed
        await FirebaseFirestore.instance
            .collection('expenses_category')
            .doc(itemId)
            .update({'amount': updatedValue});
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
          "Add New Expense",
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
            SizedBox(
              height: 20,
            ),
            new Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Icon(Icons.calendar_month,
                            color: Colors.blue, size: 35),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 18, bottom: 28),
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            controller: dateController,
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
                                    dateController.text = formattedDate;
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
                                        .collection('expenses_category')
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
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('expenses_category')
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
                          List<expensecategoryModel> expensecatogryItems = [];
                          snapshot.data?.docs.forEach((doc) {
                            String docId = doc.id;
                            String amount = doc['amount'];
                            expensecatogryItems
                                .add(expensecategoryModel(docId, amount));
                          });

                          // Assign the first brand item as the default selectedBrand
                          if (selectedCategory == null &&
                              expensecatogryItems.isNotEmpty) {
                            selectedexpenseCategory = expensecatogryItems[0];
                          }
                          return TextFormField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Amount Rs.',
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Restoke';
                                }
                                return null;
                              }

                              );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 18, right: 18, bottom: 18, top: 18),
                    child: TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(
                        hintText: 'Note',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 15.0,
                        ),
                        icon: Icon(
                          FontAwesomeIcons.noteSticky,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 280,
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
                            note = noteController.text;
                            amount = amountController.text;
                            date = dateController.text;
                          });
                          add();
                          increaseItemByOneCategory(selectedCategory!.c_id);
                          increaseItemByOne(selectedexpenseCategory!.c_id);

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

class expensecategoryModel {
  String c_id;
  String c_amount;

  expensecategoryModel(this.c_id, this.c_amount);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is expensecategoryModel &&
          runtimeType == other.runtimeType &&
          c_id == other.c_id;

  @override
  int get hashCode => c_id.hashCode;
}

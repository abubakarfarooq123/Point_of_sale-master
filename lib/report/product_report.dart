import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../home/drawer.dart';
import '../../../splashScreens/loginout.dart';
import '../../../user/edit_profile.dart';
import '../items/product/add_product.dart';

enum MenuItem {
  item1,
  item2,
}

class Product_Report extends StatefulWidget {
  const Product_Report({super.key});

  @override
  State<Product_Report> createState() => _Product_ReportState();
}

class _Product_ReportState extends State<Product_Report> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore
        .collection('Product')
        .get();
    return snapshot.docs;
  }
  UnitModel getUnitItemByIndex(List<UnitModel> unitItems, int index) {
    if (index >= 0 && index < unitItems.length) {
      return unitItems[index];
    } else {
      return UnitModel('', ''); // Return a default unit or handle as needed
    }
  }

  List<UnitModel> unitItems = []; // Define the list of unit items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Product Report",
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
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<DocumentSnapshot> data = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 100,top: 20),
                        child: Text("Jawad & Brothers",style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 17
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10,top: 10),
                        child: Text("Select Product:",style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17
                        ),),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [

                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 60, top: 20, bottom: 14),
                              child: Center(
                                child: Container(
                                  height: 50,
                                  width: 230,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(40),
                                          borderSide: BorderSide(color: Colors.black)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(40),
                                          borderSide: BorderSide(color: Colors.black)),
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
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 20,
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
                                'Total Quantity Purchased',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total Purchased Quantity Pirce',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total Quantity Sell',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total Quantity Sell Price',
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

                          ],
                          rows: List<DataRow>.generate(data.length, (index) {
                            Map<String, dynamic> employeeData =
                            data[index].data() as Map<String, dynamic>;
                            String name = employeeData['item'];
                            String brand = employeeData['brand'];
                            String category = employeeData['category'];
                            String sku = employeeData['sku'];
                            dynamic unitData = employeeData['unit'];
                            String unit;

                            if (unitData is List<dynamic>) {
                              unit = unitData.join(', ');
                            } else if (unitData is String) {
                              unit = unitData;
                            } else {
                              unit = '';
                            }
                            String quantity = employeeData['quantity'].toString();

                            String tillgrandpur = employeeData['tillgrandpur'].toString();
                            String tillgrandsale = employeeData['tillgrandsale'].toString();
                            String tillquantity = employeeData['tillquantity'].toString();
                            String tillquantitysale = employeeData['tillquantitysale'].toString();

                            Map<String, dynamic> simpleValues = employeeData['simple_values'] ?? {};
                            UnitModel selectedUnitItem = getUnitItemByIndex(unitItems, index);

                            Map<String, dynamic> selectedUnitValues = simpleValues[selectedUnitItem.u_title] ?? {};

                            String unit1Data = '';

                            if (unitData is List<dynamic> && unitData.length > 1) {
                              unit1Data = unitData[1].toString();
                            }



                            return DataRow(

                              cells: [
                                DataCell(Text(name ?? '')),
                                DataCell(Text(brand ?? '')),
                                DataCell(Text(category ?? '')),
                                DataCell(Text(sku ?? '')),
                                DataCell(Text(unit ?? '')),
                                DataCell(Text(tillquantity)),
                                DataCell(Text(tillgrandpur)),
                                DataCell(Text(tillquantitysale)),
                                DataCell(Text(tillgrandsale)),
                                DataCell(Text(quantity ?? '')),
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
                  ),
                );
              }
            }
        ),
      ),
    );
  }
}

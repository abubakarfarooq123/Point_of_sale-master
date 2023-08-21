import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/drawer.dart';
import '../../splashScreens/loginout.dart';
import '../../user/edit_profile.dart';

enum MenuItem {
  item1,
  item2,
}

class Stock_Info_Cylinder extends StatefulWidget {
  const Stock_Info_Cylinder({super.key});

  @override
  State<Stock_Info_Cylinder> createState() => _Stock_Info_CylinderState();
}

class _Stock_Info_CylinderState extends State<Stock_Info_Cylinder> {
  Map<String, int> cylinderQuantities =
      {}; // Map to keep track of cylinder quantities

  Future<Map<String, int>> getCylinderDetails() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('cylinder').get();

    final itemQuantityMap = Map<String, int>();

    for (final cylinderDoc in querySnapshot.docs) {
      final subCollectionSnapshot =
          await cylinderDoc.reference.collection('details').get();

      for (final detailsDoc in subCollectionSnapshot.docs) {
        final item = detailsDoc['Item'] as String;
        final nestedQuantity = detailsDoc['Quantity'] as String;
        final intQuantity = int.tryParse(nestedQuantity) ?? 0;

        if (itemQuantityMap.containsKey(item)) {
          itemQuantityMap[item] = itemQuantityMap[item]! + intQuantity;
        } else {
          itemQuantityMap[item] = intQuantity;
        }
      }
    }

    return itemQuantityMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Cylinder Stock",
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
            SizedBox(
              height: 30,
            ),
            Container(
              child: Text(
                "Stock Info Empty",
                style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('empty_cylinder')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      final emptyDocuments = snapshot.data!.docs;
                      final emptyStockInfo = calculateStockInfo(emptyDocuments);

                      print('Empty Cylinder Stock Info: $emptyStockInfo');

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Empty Cylinder List:",
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: emptyStockInfo.length * 2 -
                                1, // Add space for dividers
                            itemBuilder: (context, index) {
                              // Check if the current index is odd, to show the divider
                              if (index.isOdd) {
                                return Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  height: 1,
                                );
                              }
                              final dataIndex = index ~/ 2;
                              final cylinderName =
                                  emptyStockInfo.keys.elementAt(dataIndex);
                              final quantity =
                                  emptyStockInfo.values.elementAt(dataIndex);

                              return ListTile(
                                title: Text(
                                  cylinderName,
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text('Quantity: $quantity'),
                                trailing: quantity < 0
                                    ? Icon(Icons.warning, color: Colors.red)
                                    : null,
                              );
                            },
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 1,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cylinder')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      final cylinderDocuments = snapshot.data!.docs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Filled Cylinder List:",
                                style: GoogleFonts.roboto(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          FutureBuilder<Map<String, int>>(
                            future: getCylinderDetails(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              final cylinderDetails = snapshot.data!;

                              return ListView.separated(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: cylinderDetails.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final cylinderName =
                                      cylinderDetails.keys.elementAt(index);
                                  final totalQuantity =
                                      cylinderDetails[cylinderName];

                                  return ListTile(
                                    title: Text(
                                      cylinderName,
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle:
                                        Text('Total Quantity: $totalQuantity'),
                                  );
                                },
                              );
                            },
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 1,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> calculateStockInfo(List<QueryDocumentSnapshot> documents) {
    final stockInfo = Map<String, int>();

    for (final doc in documents) {
      final cylinder = doc['cylinder'] as String;
      final count = int.tryParse(doc['quantity'] ?? '0') ?? 0;
      print('Cylinder: $cylinder, Quantity: $count');

      if (stockInfo.containsKey(cylinder)) {
        stockInfo[cylinder] = stockInfo[cylinder]! + count;
      } else {
        stockInfo[cylinder] = count;
      }
    }

    return stockInfo;
  }

  Map<String, int> calculateStockInfo1(List<QueryDocumentSnapshot> documents) {
    final stockInfo = Map<String, int>();

    for (final doc in documents) {
      final cylinder = doc['Item'] as String;
      final count = int.tryParse(doc['Quantity'] ?? '0') ??
          0; // Handle String to int conversion
      print('Cylinder: $cylinder, Quantity: $count');

      if (stockInfo.containsKey(cylinder)) {
        stockInfo[cylinder] = stockInfo[cylinder]! + count;
      } else {
        stockInfo[cylinder] = count;
      }
    }

    return stockInfo;
  }
}

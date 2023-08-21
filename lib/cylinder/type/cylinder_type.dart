// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pos/cylinder/type/add_cylinder_type.dart';
//
// import '../../home/drawer.dart';
// import '../../splashScreens/loginout.dart';
// import '../../user/edit_profile.dart';
// enum MenuItem {
//   item1,
//   item2,
// }
// class Cylinder_Type extends StatefulWidget {
//   const Cylinder_Type({super.key});
//
//   @override
//   State<Cylinder_Type> createState() => _Cylinder_TypeState();
// }
//
// class _Cylinder_TypeState extends State<Cylinder_Type> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<Object?> getValuesFromFirebase() async {
//     DocumentSnapshot snapshot = await _firestore
//         .collection('cylinder_type')
//         .doc(FirebaseAuth.instance.currentUser?.uid)
//         .get();
//     if (snapshot.exists) {
//       return snapshot.data();
//     }
//     return {}; // Default empty map if the document doesn't exist
//   }
//
//   bool isisRowSelected = false;
//   int selectedRowIndex = -1; // Track the index of the selected row
//
//   var lable = "";
//   final lableController = TextEditingController();
//   final amountTextController = TextEditingController();
//   String amountText = '';
//
//   void initState() {
//     super.initState();
//     // Call a function to listen for new customer additions
//     getValuesFromFirebase().then((values) {
//       setState(() {
//         Map<String, dynamic> data = values as Map<String, dynamic>;
//         lableController.text = data['lable'] ?? '';
//         amountTextController.text = data['amount'] ?? '';
//       });
//     });
//   }
//
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   Future<List<DocumentSnapshot>> fetchEmployeeData() async {
//     QuerySnapshot snapshot = await firestore.collection('cylinder_type').get();
//     return snapshot.docs;
//   }
//
//   @override
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: Text(
//           "Cylinder Type",
//           style: GoogleFonts.roboto(
//             color: Colors.black,
//             fontSize: 25,
//           ),
//         ),
//         iconTheme: IconThemeData(color: Colors.black),
//         actions: [
//           PopupMenuButton<MenuItem>(
//             onSelected: (value) {
//               if (value == MenuItem.item1) {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => Edit_Profile()));
//               }
//               if (value == MenuItem.item2) {
//                 FirebaseAuth.instance.signOut();
//                 Navigator.pushReplacement(context,
//                     MaterialPageRoute(builder: (context) => LoginOut()));
//
//                     (route) => false;
//               }
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: MenuItem.item1,
//                 child: Row(
//                   children: [
//                     Icon(Icons.edit),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Text(
//                       "Edit Profile",
//                       style:
//                       GoogleFonts.roboto(color: Colors.black, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: MenuItem.item2,
//                 child: Row(
//                   children: [
//                     Icon(Icons.login_outlined),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     Text(
//                       "Logout",
//                       style:
//                       GoogleFonts.roboto(color: Colors.black, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: FutureBuilder<List<DocumentSnapshot>>(
//           future: fetchEmployeeData(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             } else {
//               List<DocumentSnapshot> data = snapshot.data!;
//               return SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 14, top: 20, bottom: 14),
//                             child: Container(
//                               height: 50,
//                               width: 230,
//                               child: TextField(
//                                 decoration: InputDecoration(
//                                   focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(40),
//                                       borderSide: BorderSide(color: Colors.black)),
//                                   enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(40),
//                                       borderSide: BorderSide(color: Colors.black)),
//                                   prefixIcon: Icon(
//                                     Icons.search_outlined,
//                                     color: Colors.grey,
//                                   ),
//                                   hintText: "Search...",
//                                   hintStyle: TextStyle(color: Colors.grey),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 10),
//                             child: InkWell(
//                               onTap: () {
//                                 showEditProfileDialog(context, data[selectedRowIndex]);
//                               },
//                               child: Container(
//                                 height: 40,
//                                 width: 40,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(30),
//                                   color: selectedRowIndex != -1 ? Colors.green : Colors.grey.withOpacity(0.5),
//                                 ),
//                                 child: Icon(
//                                   FontAwesomeIcons.edit,
//                                   color: Colors.white,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 10),
//                             child: InkWell(
//                               onTap: () {
//                                 showDeleteConfirmationDialog(context, data, selectedRowIndex);
//                               },
//                               child: Container(
//                                 height: 40,
//                                 width: 40,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(30),
//                                   color: selectedRowIndex != -1 ? Colors.red : Colors.grey.withOpacity(0.5),
//                                 ),
//                                 child: Icon(
//                                   Icons.delete,
//                                   color: Colors.white,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 10),
//                             child: InkWell(
//                               child: Container(
//                                 height: 40,
//                                 width: 40,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(30),
//                                   color: selectedRowIndex != -1 ? Colors.blue : Colors.grey.withOpacity(0.5),
//                                 ),
//                                 child: Icon(
//                                   FontAwesomeIcons.filePdf,
//                                   color: Colors.white,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 10, right: 10),
//                             child: InkWell(
//                               child: Container(
//                                 height: 40,
//                                 width: 40,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(30),
//                                   color: selectedRowIndex != -1 ? Colors.blue : Colors.grey.withOpacity(0.5),
//                                 ),
//                                 child: Icon(
//                                   FontAwesomeIcons.fileCsv,
//                                   color: Colors.white,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         columnSpacing: 180,
//                         headingRowColor: MaterialStateColor.resolveWith(
//                               (states) {
//                             return Colors.blue;
//                           },
//                         ),
//                         dividerThickness: 3,
//                         showBottomBorder: true,
//                         columns: [
//                           DataColumn(
//                             label: Text(
//                               'Lable',
//                               style: GoogleFonts.roboto(
//                                   fontWeight: FontWeight.bold, color: Colors.white),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'Amount',
//                               style: GoogleFonts.roboto(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                         rows: List<DataRow>.generate(data.length, (index) {
//                           Map<String, dynamic> employeeData =
//                           data[index].data() as Map<String, dynamic>;
//                           String lable = employeeData['lable'];
//                           String amount2 = employeeData['amount'];
//                           return DataRow.byIndex(
//                             index: index,
//                             selected: selectedRowIndex == index,
//                             onSelectChanged: (selected) {
//                               setState(() {
//                                 if (selected!) {
//                                   selectedRowIndex = index;
//                                 } else {
//                                   selectedRowIndex = -1;
//                                 }
//                               });
//                             },
//                             cells: [
//                               DataCell(Text(
//                                 lable,
//                                 style: GoogleFonts.poppins(),
//                               )),
//                               DataCell(Text(
//                                 amount2.toString(),
//                                 style: GoogleFonts.poppins(),
//                               )),
//                             ],
//                           );
//                         }),
//                         dataRowColor: MaterialStateColor.resolveWith((states) {
//                           if (states.contains(MaterialState.selected)) {
//                             return Colors.grey.withOpacity(0.5);
//                           }
//                           return Colors.transparent;
//                         }),
//
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         ),
//         ),
//       drawer: MyDrawer(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//               context, MaterialPageRoute(builder: (context) => Add_Cylinder_Type()));
//         },
//         backgroundColor: Colors.blue,
//         child: Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//   void showDeleteConfirmationDialog(BuildContext context, List<dynamic> data, int selectedRowIndex) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Confirmation'),
//           content: Text('Are you sure you want to delete?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 // Perform cancel action
//                 Navigator.of(context).pop(false);
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: selectedRowIndex != -1
//                   ? () {
//                 // Perform the action for the delete button
//                 Map<String, dynamic> selectedEmployeeData =
//                 data[selectedRowIndex].data() as Map<String, dynamic>;
//                 String selectedEmployeeId = selectedEmployeeData['id'];
//
//                 // Delete the selected row data from Firebase
//                 firestore.collection('cylinder_type').doc(selectedEmployeeId).delete().then((value) {
//                   // Row data deleted successfully
//                   setState(() {
//                     data.removeAt(selectedRowIndex); // Remove the selected row from the local data list
//                     selectedRowIndex = -1; // Reset the selected row index
//                   });
//
//                   // Close the dialog
//                   Navigator.of(context).pop();
//                 }).catchError((error) {
//                   // Error occurred while deleting row data
//                   print('Error deleting row data: $error');
//                 });
//               }
//                   : null,
//               child: Text('Delete'),
//             ),
//
//           ],
//         );
//       },
//     );
//   }
//   void showEditProfileDialog(BuildContext context, dynamic customerData) {
//
//
//     void _updateSelectedValues() {
//       String title1 = lableController.text;
//       String amount1 = amountTextController.text;
//
//
//       Map<String, dynamic> data = {
//         'lable' : title1,
//         'amount': amount1,
//
//       };
//
//       FirebaseFirestore.instance
//           .collection('cylinder_type')
//           .doc(customerData['id'])
//           .update(data);
//     }
//
//     lableController.text = customerData['lable'] ?? '';
//     amountTextController.text = customerData['amount'] ?? '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         // Implement your edit profile dialog here
//         return SingleChildScrollView(
//           child: AlertDialog(
//             title: Text('Edit Cylinder'),
//             content: Column(
//               children: [
//                 new Form(
//                   child: Column(
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.all(18.0),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             hintText: 'Lable',
//                             enabledBorder: OutlineInputBorder(
//                               borderSide:
//                               BorderSide(color: Colors.grey, width: 1),
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                           controller: lableController,
//                           onChanged: (value) => lable = value,
//
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(18.0),
//                         child: TextFormField(
//                           decoration: InputDecoration(
//                             hintText: 'Amount',
//                             enabledBorder: OutlineInputBorder(
//                               borderSide:
//                               BorderSide(color: Colors.grey, width: 1),
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                           keyboardType: TextInputType.number,
//                           controller: amountTextController,
//                           onChanged: (value) => amountText = value,
//
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       // ignore: deprecated_member_use
//                       Container(
//                         height: 45.0,
//                         width: 320.0,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             color: Colors.blue),
//                         child: InkWell(
//                           onTap: () {
//                             _updateSelectedValues();
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => Cylinder_Type(),
//                               ),
//                             );
//                           },
//                           child: Center(
//                             child: Text(
//                               'Update',
//                               style: TextStyle(
//                                 fontSize: 20.0,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20.0,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
// }

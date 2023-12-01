import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/home/drawer.dart';
import 'package:pos/sales/add_sales.dart';
import 'package:pos/user/edit_profile.dart';

import '../splashScreens/loginout.dart';

enum MenuItem{
  item1,
  item2,
}

class Sales extends StatefulWidget {
  const Sales({Key? key}) : super(key: key);

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<List<DocumentSnapshot>> fetchEmployeeData() async {
    QuerySnapshot snapshot = await firestore
        .collection('Sales')
        .orderBy('purchase', descending: true)
        .get();
    return snapshot.docs;
  }

  bool isisRowSelected = false;
  int selectedRowIndex = -1; // Track the index of the selected row
  List<Map<String, dynamic>> detailsList = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body:
      SingleChildScrollView(
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14,top: 20,bottom: 14),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: InkWell(
                          onTap: () {
                            showEditProfileDetailDialog(
                                context, data[selectedRowIndex]);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: selectedRowIndex != -1
                                  ? Colors.grey
                                  : Colors.grey.withOpacity(0.5),
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
                        padding: const EdgeInsets.only(left: 10,),
                        child: InkWell(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.blue
                            ),
                            child: Icon(FontAwesomeIcons.filePdf,color: Colors.white,size: 18,),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10,),
                        child: InkWell(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.blue
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
                          'Sale #',
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Date',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Customer',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Items #',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Sub Totals',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Discounts',
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
                          'Tendered Amount',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Remaining',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Change',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Before Sale Due',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'After Sale Due',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Due Date',
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
                      String purchase = employeeData['purchase'].toString();
                      String date = employeeData['pickdate'];
                      String supplier = employeeData['customer'];
                      String item = employeeData['count'].toString();
                      String subtotal = employeeData['subtotal'].toString();
                      String discount = employeeData['discount'].toString();
                      String grandtotal = employeeData['grand'].toString();
                      String tender = employeeData['tender'].toString();
                      String final1 = employeeData['final'].toString();
                      String due = employeeData['due'].toString();
                      String before = employeeData['previous'].toString();
                      String after = employeeData['after'].toString();
                      String duedate = employeeData['duedate'];
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
                          DataCell(Text(
                            "SALE# ${purchase}",
                            style: GoogleFonts.poppins(),
                          )),
                          DataCell(Text(date)),
                          DataCell(Text(supplier)),
                          DataCell(Text(item)),
                          DataCell(Text(subtotal)),
                          DataCell(Text(discount)),
                          DataCell(Text(grandtotal)),
                          DataCell(Text(tender)),
                          DataCell(Text(final1)),
                          DataCell(Text(due)),
                          DataCell(Text(before)),
                          DataCell(Text(after)),
                          DataCell(Text(duedate)),
                        ],
                      );
                    }).toList(),
                  ),
                ),


              ],
            )
        );
    }
    },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Add_Sales()));

        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
  void showEditProfileDetailDialog(BuildContext context, dynamic customerData,) async {
    detailsList.clear(); // Clear the list before populating it with data

    String id = customerData['id'];
    String date = customerData['pickdate'];
    String billno = customerData['purchase'].toString();
    String supplier = customerData['customer'];
    String due = customerData['duedate'] !="" ? customerData['duedate'] : "N/A";
    String name = customerData['purchase'].toString();
    double grandd = customerData['grand'];
    double sub = customerData['subtotal'];
    double tender = customerData['tender'];
    double previous = double.parse(customerData['previous']);
    double after =  double.parse(customerData['after']);
    double remaining = customerData['final'];

    CollectionReference detailsCollection =
    FirebaseFirestore.instance.collection('Sales/$id/details');

    // Retrieve documents from the collection
    QuerySnapshot querySnapshot = await detailsCollection.get();

    // Loop through the documents and add details to the list
    querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Cast the data to a Map<String, dynamic>
        Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;

        // Access the 'item', 'quantity', and 'rate' fields from the document data
        String item = data['Item'].toString();
        String quantity = data['Quantity'].toString();
        String rate = data['Rate'].toString();
        String discount = data['Discount'].toString();
        String tax = data['Tax'].toString();
        String amount = data['Amount'].toString();
        String subtotal = data['Subtotal'].toString();
        String grandtotal = data['Grandtotal'].toString();

        // Create a map with the details and add it to the list
        Map<String, dynamic> details = {
          'item': item,
          'quantity': quantity,
          'rate': rate,
          'discount': discount,
          'tax': tax,
          'amount': amount,
          'subtotal': subtotal,
          'grandtotal': grandtotal,
        };

        detailsList.add(details);
      }
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Container(
              height: 50,
              width: 320,
              child: Stack(
                children: [
                  Positioned(
                    left: 5,
                    top: 10,
                    child: Text(
                      'Sale# ${name} Details',
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 83,
                  ),
                  Positioned(
                    right: 5,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.clear,
                          size: 32,
                        )),
                  )
                ],
              ),
            ),
            content: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.4),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text("Bill No:",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(billno,style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                    SizedBox(
                      width: 15,
                    ),
                    Text("Customer:",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 7,
                    ),
                    Text(supplier,style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text("Date:",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(date,style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                    SizedBox(
                      width: 23,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text("Due Date:",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(due,style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                  ],
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
                          'Item',
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'QTY',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Rate',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Subtotal',
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
                          'Discount',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Amount',
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
                    ],
                    rows: List<DataRow>.generate(detailsList.length, (index) {
                      Map<String, dynamic> detailData = detailsList[index];
                      String item = detailData['item'].toString(); // Use 'item' instead of 'Item'
                      String quantity = detailData['quantity'].toString(); // Use 'quantity' instead of 'Quantity'
                      String rate = detailData['rate'].toString(); // Use 'rate' instead of 'Rate'
                      String subtotal = detailData['subtotal'].toString();
                      String grandtotal = detailData['grandtotal'].toString();
                      String discount = detailData['discount'].toString();
                      String tax = detailData['tax'].toString();
                      String extra = detailData['amount'].toString(); // Use 'amount' instead of 'Amount'

                      return DataRow(
                        cells: [
                          DataCell(Text(
                            item,
                            style: GoogleFonts.poppins(),
                          )),
                          DataCell(Text(quantity)),
                          DataCell(Text(rate)),
                          DataCell(Text(subtotal)),
                          DataCell(Text(discount)),
                          DataCell(Text(tax)),
                          DataCell(Text(extra)),
                          DataCell(Text(grandtotal)),
                        ],
                      );
                    })
                        .toList(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
               Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Details",style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20,right: 10),
                  child: Divider(
                    height: 2,
                    color: Colors.grey.withOpacity(0.4),
                    thickness: 4,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text("SubTotal",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(sub.toStringAsFixed(2),style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                  ],
                ),

                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text("Grand Total",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(grandd.toStringAsFixed(2),style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text("Amount Tender",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(tender.toStringAsFixed(2),style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text("Remaining",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(remaining.toStringAsFixed(2),style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text("Balance Before Sale",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(previous.toStringAsFixed(2),style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text("Balance After Sale:",style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      width: 10,
                    ),
                    Text(after.toStringAsFixed(2),style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                InkWell(
                  onTap: (){},
                  child: Padding(
                    padding: const EdgeInsets.only(left: 150),
                    child: Container(
                      height: 30,
                      width: 90,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Center(
                        child: Text("Print",style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
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

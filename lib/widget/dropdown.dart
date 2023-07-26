// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../corn_store/add_corn.dart';
//
// class ProductDropdownWidget extends StatefulWidget {
//   final Stream<QuerySnapshot> stream;
//   final Function(ProductModel) onChanged;
//
//   ProductDropdownWidget({required this.stream, required this.onChanged});
//
//   @override
//   _ProductDropdownWidgetState createState() => _ProductDropdownWidgetState();
// }
//
// class _ProductDropdownWidgetState extends State<ProductDropdownWidget> {
//   ProductModel? selectedProduct;
//   List<ProductModel> selectedProducts = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 330,
//       height: 60,
//       padding: EdgeInsets.only(left: 16, right: 16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey, width: 1),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child:StreamBuilder<QuerySnapshot>(
//         stream: widget.stream,
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           List<ProductModel> productItems = [];
//           snapshot.data?.docs.forEach((doc) {
//             String docId = doc.id;
//             String item = doc['item'];
//             productItems.add(ProductModel(docId, item, 0, 0));
//           });
//
//           return DropdownButton<ProductModel>(
//             iconSize: 40,
//             isExpanded: true,
//             underline: SizedBox(),
//             hint: Text('Select Item'),
//             value: selectedProduct,
//             items: productItems.map((product) {
//               return DropdownMenuItem<ProductModel>(
//                 value: product,
//                 child: Text(product.p_name),
//               );
//             }).toList(),
//             onChanged: (value) {
//               widget.onChanged(value!);
//               setState(() {
//                 selectedProduct = value;
//                 FirebaseFirestore.instance
//                     .collection('Product')
//                     .doc(selectedProduct!.p_id)
//                     .get()
//                     .then((docSnapshot) {
//                   if (docSnapshot.exists) {
//                     int quantity = docSnapshot['quantity'];
//                     double unitPrice = docSnapshot['unitPrice'];
//
//                     selectedProduct = ProductModel(
//                       selectedProduct!.p_id,
//                       selectedProduct!.p_name,
//                       unitPrice,
//                       quantity.toDouble(),
//                     );
//                   } else {
//                     int defaultQuantity = 1;
//                     double defaultUnitPrice = 0.0;
//
//                     selectedProduct = ProductModel(
//                       selectedProduct!.p_id,
//                       selectedProduct!.p_name,
//                       defaultUnitPrice,
//                       defaultQuantity.toDouble(),
//                     );
//                   }
//                 }).catchError((error) {
//                   print('Error fetching data: $error');
//                 });
//               });
//             },
//           );
//         },
//       ),
//
//     );
//   }
// }

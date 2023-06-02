import 'package:firebase_database/firebase_database.dart';

class Get_Brand {
  String name;
  int itemCount;

  Get_Brand(this.name, this.itemCount);
}

Future<List<Get_Brand>> fetchBrands() async {
  DatabaseReference brandsRef = FirebaseDatabase.instance.reference().child('brand');
  DataSnapshot snapshot = (await brandsRef.once()) as DataSnapshot;

  List<Get_Brand> brands = [];
  Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>; // Cast snapshot.value to Map<dynamic, dynamic>

  data.forEach((key, value) {
    Get_Brand brand = Get_Brand(key.toString(), value['item'] as int); // Cast the 'itemCount' value to int
    brands.add(brand);
  });

  return brands;
}

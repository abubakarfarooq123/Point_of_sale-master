import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/home/home_screen.dart';
import 'package:pos/items/brand/brand.dart';
import 'package:pos/items/category.dart';
import 'package:pos/items/discount/discount.dart';
import 'package:pos/items/tax/tax.dart';
import 'package:pos/items/units/units.dart';
import 'package:pos/purchase/purchase.dart';
import 'package:pos/report/report_detail.dart';
import 'package:pos/return/sale_return.dart';
import 'package:pos/sales/quotation.dart';
import 'package:pos/staff/customer.dart';
import 'package:pos/staff/employee.dart';
import 'package:pos/staff/suppliers.dart';
import 'package:pos/items/product/product.dart';

import '../category/category.dart';
import '../expenses/expenses.dart';
import '../inventory/inventory.dart';
import '../return/purcahse_return.dart';
import '../sales/sales.dart';
import '../settings/setting.dart';
import '../warehouse/warehouse.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                title: Text("Dashboard", style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
                ),
                leading: Icon(FontAwesomeIcons.dashboard),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen()));
                },
              ),
              ExpansionTile(
                title: Text(
                  "Staff",
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                  ),
                ),
                leading: Icon(Icons.supervised_user_circle_rounded, size: 28,),
                children: [
                  ListTile(
                    title: Text("Employees", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(FontAwesomeIcons.users),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => Employee()));
                    },
                  ),
                  ListTile(
                    title: Text("Roles", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(Icons.work_outline),

                    onTap: () {},
                  ),
                ],
              ),
              ListTile(
                title: Text("Customer", style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
                ),
                leading: Icon(FontAwesomeIcons.user),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Customer()));

                },
              ),
              ExpansionTile(
                title: Text(
                  "Items",
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                  ),
                ),
                leading: Icon(FontAwesomeIcons.shop),
                children: [
                  ListTile(
                    title: Text("Products", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(FontAwesomeIcons.cube),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Product()));
                    },
                  ),
                  ListTile(
                    title: Text("Categories", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(Icons.category),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Category_name()));


                    },
                  ),
                  ListTile(
                    title: Text("Brands", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(FontAwesomeIcons.brandsFontAwesome),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Brand()));
                    },
                  ),
                  ListTile(
                    title: Text("Discounts", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(FontAwesomeIcons.percentage),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Discount()));
                    },
                  ),
                  ListTile(
                    title: Text("Tax", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(FontAwesomeIcons.handPaper),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Tax()));
                    },
                  ),

                  ListTile(
                    title: Text("Unit", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(FontAwesomeIcons.legal),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Units()));

                    },
                  ),
                ],
              ),
              ListTile(
                title: Text("Suppliers", style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
                ),
                leading: Icon(FontAwesomeIcons.handshake),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Suppliers()));
                },
              ),
              ListTile(
                title: Text("Purchases", style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
                ),
                leading: Icon(FontAwesomeIcons.calculator),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Purchase()));

                },
              ),
              ExpansionTile(
                title: Text(
                  "Sales",
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                  ),
                ),
                leading: Icon(Icons.point_of_sale_sharp, size: 28,),
                children: [
                  ListTile(
                    title: Text("Sales", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(FontAwesomeIcons.cartShopping),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Sales()));

                    },
                  ),
                  ListTile(
                    title: Text("Quotations", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(Icons.format_quote_outlined),

                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Quotation()));

                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  "Returns",
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                  ),
                ),
                leading: Icon(Icons.assignment_return_outlined, size: 28,),
                children: [
                  ListTile(
                    title: Text("Sales Return", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(Icons.compare_arrows_outlined),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Sales_Return()));
                    },
                  ),
                  ListTile(
                    title: Text("Purchase Return", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(Icons.compare_arrows_outlined),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Purchase_Return()));

                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  "Expenses",
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                  ),
                ),
                leading: Icon(Icons.attach_money_outlined, size: 28,),
                children: [
                  ListTile(
                    title: Text("Expenses", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(FontAwesomeIcons.moneyBill),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Expenses()));
                    },
                  ),
                  ListTile(
                    title: Text("Categories", style: GoogleFonts.roboto(
                      color: Colors.black,
                    ),
                    ),
                    leading: Icon(Icons.category),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Category_aa()));
                    },
                  ),
                ],
              ),
              ListTile(
                title: Text("Reports", style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
                ),
                leading: Icon(Icons.report),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Report()));
                },
              ),
              ListTile(
                title: Text("Warehouses", style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
                ),
                leading: Icon(Icons.warehouse),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Warehouse()));

                },
              ),
              ListTile(
                title: Text("Inventory", style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
                ),
                leading: Icon(Icons.inventory),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Inventory()));

                },
              ),
              ListTile(
                title: Text("Settings", style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
                ),
                leading: Icon(Icons.settings),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Settings()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
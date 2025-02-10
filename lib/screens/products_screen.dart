import 'package:flutter/material.dart';
import 'package:kakao_farmer/screens/products_screen_tabs/create_product_screen_tab.dart';
import 'package:kakao_farmer/screens/products_screen_tabs/list_products_screen_tab.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              children: [CreateProductScreenTab(), ListProductsScreenTab()],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 3,
                      offset: const Offset(2, 2))
                ]),
            child: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.create), text: "Ajouter"),
                Tab(icon: Icon(Icons.list), text: "Liste"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

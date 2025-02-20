import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/order.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/screens/orders_tabs/my_orders_screen_tab.dart';
import 'package:kakao_farmer/screens/orders_tabs/others_orders_screen_tab.dart';
import 'package:kakao_farmer/widgets/shadowed_container.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              children: [MyOrdersScreenTab(), OthersOrdersScreenTab()],
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
                Tab(icon: Icon(Icons.send), text: "Envoyées"),
                Tab(icon: Icon(Icons.receipt), text: "Reçues")
              ],
            ),
          )
        ],
      ),
    );
  }
}

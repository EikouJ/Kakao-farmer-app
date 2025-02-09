import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/order.dart';
import 'package:kakao_farmer/models/product.dart';
import 'package:kakao_farmer/models/user.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/widgets/shadowed_container.dart';

class StatisticsScreenTab extends StatefulWidget {
  const StatisticsScreenTab({super.key});

  @override
  State<StatisticsScreenTab> createState() => _StatisticsScreenTabState();
}

class _StatisticsScreenTabState extends State<StatisticsScreenTab> {
  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

  late Future<List<Order>> _futureOrdersDatas = _fetchOrders();

  @override
  void initState() {
    super.initState();

    _futureOrdersDatas = _fetchOrders();
  }

  Future<User> _fetchUser(int id) async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/users/$id"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);

      if (body is! Map<String, dynamic>) {
        throw Exception('Failed to load product: Invalid response format');
      }

      User user = User.fromJson(body);

      return user;
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<Product> _fetchProduct(int id) async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/products/$id"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      //print(body.runtimeType);
      if (body is! Map<String, dynamic>) {
        throw Exception('Failed to load product: Invalid response format');
      }

      Product product = Product.fromJson(body);

      product.user = await _fetchUser(body["seller_id"]);

      return product;
    } else {
      throw Exception('Failed to load product ${response.statusCode}');
    }
  }

  Future<List<Order>> _fetchOrders() async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/orders/all"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Order> orders = await Future.wait(body.map((dynamic item) async {
        Product product = await _fetchProduct(item["product_id"]);
        Order order = Order.fromJson(item);
        order.product = product;
        return order;
      }).toList());

      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  int _calculateTotalSales(List<Order> orders) {
    return orders.length;
  }

  double _calculateTotalRevenue(List<Order> orders) {
    double totalRevenue = 0.0;
    for (var order in orders) {
      totalRevenue += order.totalPrice!;
    }
    return totalRevenue;
  }

  int _calculateUserSales(List<Order> orders) {
    return orders
        .where((order) =>
            order.product!.user!.id! == Glob.userId &&
            order.status == "validated")
        .length;
  }

  int _calculateUserBuys(List<Order> orders) {
    return orders
        .where((order) =>
            order.user!.id == Glob.userId && order.status == "validated")
        .length;
  }

  @override
  Widget build(BuildContext context) {
    //return Scaffold(body: LineChartWidget(isShowingMainData: true));
    return Scaffold(
      body: FutureBuilder<List<Order>>(
        future: _futureOrdersDatas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            List<Order> orders = snapshot.data!;
            int totalSales = _calculateTotalSales(orders);
            double totalRevenue = _calculateTotalRevenue(orders);
            int userSales = _calculateUserSales(orders);
            int userBuys = _calculateUserBuys(orders);

            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                _buildShadowedContainer('Total Sales: $totalSales'),
                _buildShadowedContainer(
                    'Total Revenue: \$${totalRevenue.toStringAsFixed(2)}'),
                _buildShadowedContainer('Your Sales: $userSales'),
                _buildShadowedContainer('Your Buys: $userBuys'),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildShadowedContainer(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(text),
    );
  }
}

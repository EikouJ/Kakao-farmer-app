import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/order.dart';
import 'package:kakao_farmer/models/product.dart';
import 'package:kakao_farmer/models/user.dart';
import "package:http/http.dart" as http;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Statistiques"),
    );
  }
}

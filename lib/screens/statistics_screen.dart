import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  /*Future<User> _fetchUser(int id) async {
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

      print("\n\n\n USER");
      inspect(user);

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

      print("\n\n\n PRODUCT");
      inspect(product);
      print("\n\n\n");

      return product;
    } else {
      throw Exception('Failed to load product ${response.statusCode}');
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

      print("\n\n\n PRODUCT");
      inspect(product);
      print("\n\n\n");

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
        Order order = Order.fromJson(item);
        return order;
      }).toList());

      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Statistiques"),
    );
  }
}

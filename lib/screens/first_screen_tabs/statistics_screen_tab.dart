import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/order.dart';
import 'package:kakao_farmer/models/user.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/widgets/shadowed_container.dart';
import 'package:intl/intl.dart';

class StatisticsScreenTab extends StatefulWidget {
  const StatisticsScreenTab({super.key});

  @override
  State<StatisticsScreenTab> createState() => _StatisticsScreenTabState();
}

class _StatisticsScreenTabState extends State<StatisticsScreenTab> {
  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

  List<String> statsTypes = ["Journalier", "Mensuel", "Annuel"];

  String? currentType;
  String buyingText = "", sellingText = "";
  DateTime? _selectedDate;
  DateTime? _startDate;
  int? _selectedYear;
  bool _isLoadingValue = false;

  double _totalDailyPurchased = 0;
  double _totalDailySold = 0;

  double _totalMonthlyPurchased = 0;
  double _totalMonthlySold = 0;

  double _totalYearlyPurchased = 0;
  double _totalYearlySold = 0;

  late Future<List<Order>> sentsOrdersFutureDatas, receivedsOrdersFutureDatas;

  @override
  void initState() {
    super.initState();

    sentsOrdersFutureDatas = _fetchSentOrders();
    receivedsOrdersFutureDatas = _fetchReceivedOrders();
  }

  // Fetch sent orders from api
  Future<List<Order>> _fetchSentOrders() async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/orders/"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Order> orders = await Future.wait(body.map((dynamic item) async {
        Order order = Order.fromJson(item);
        return order;
      }).toList());

      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Fetch user from api
  Future<User> _fetchUser(int id) async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/users/$id"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(utf8.decode(response.bodyBytes));

      if (body is! Map<String, dynamic>) {
        throw Exception('Failed to fetch user: Invalid response format');
      }

      User user = User.fromJson(body);

      return user;
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Fetch received order from api
  Future<List<Order>> _fetchReceivedOrders() async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/orders/all"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Order> orders = await Future.wait(body.map((dynamic item) async {
        User user = await _fetchUser(item["user_id"]);
        Order order = Order.fromJson(item);
        order.user = user;
        return order;
      }).toList());

      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<double> _calculateTotalDailySentOrders(DateTime date) async {
    //if (_selectedDate == null) return;

    List<Order> sentOrders = await sentsOrdersFutureDatas;
    double total = 0;

    for (Order order in sentOrders) {
      DateTime orderDate = DateTime.parse(order.createdAt!);
      if (order.status == 'validated' &&
          orderDate.year == date.year &&
          orderDate.month == date.month &&
          orderDate.day == date.day) {
        total += order.totalPrice!;
      }
    }

    return total;
  }

  Future<double> _calculateTotalDailyReceivedOrders(DateTime date) async {
    //if (_selectedDate == null) return;

    List<Order> receivedOrders = await receivedsOrdersFutureDatas;
    double total = 0;

    for (Order order in receivedOrders) {
      DateTime orderDate = DateTime.parse(order.createdAt!);
      if (order.status == 'validated' &&
          orderDate.year == date.year &&
          orderDate.month == date.month &&
          orderDate.day == date.day) {
        total += order.totalPrice!;
      }
    }

    return total;
  }

  Future<double> _calculateTotalSentOrdersBetweenDates(
      DateTime startDate, DateTime endDate) async {
    List<Order> sentOrders = await sentsOrdersFutureDatas;
    double total = 0;

    for (Order order in sentOrders) {
      DateTime orderDate = DateTime.parse(order.createdAt!);
      if (order.status == 'validated' &&
          orderDate.isAfter(startDate) &&
          orderDate.isBefore(endDate)) {
        total += order.totalPrice!;
      }
    }

    return total;
  }

  Future<double> _calculateTotalReceivedOrdersBetweenDates(
      DateTime startDate, DateTime endDate) async {
    List<Order> receivedOrders = await receivedsOrdersFutureDatas;
    double total = 0;

    for (Order order in receivedOrders) {
      DateTime orderDate = DateTime.parse(order.createdAt!);
      if (order.status == 'validated' &&
          orderDate.isAfter(startDate) &&
          orderDate.isBefore(endDate)) {
        total += order.totalPrice!;
      }
    }

    return total;
  }

  Future<double> _calculateTotalYearlySentOrders(int year) async {
    List<Order> sentOrders = await sentsOrdersFutureDatas;
    double total = 0;

    for (Order order in sentOrders) {
      DateTime orderDate = DateTime.parse(order.createdAt!);
      if (order.status == 'validated' && orderDate.year == year) {
        total += order.totalPrice!;
      }
    }

    return total;
  }

  Future<double> _calculateTotalYearlyReceivedOrders(int year) async {
    List<Order> receivedOrders = await receivedsOrdersFutureDatas;
    double total = 0;

    for (Order order in receivedOrders) {
      DateTime orderDate = DateTime.parse(order.createdAt!);
      if (order.status == 'validated' && orderDate.year == year) {
        total += order.totalPrice!;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Statistiques",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                  fontSize: 24),
            ),
            SizedBox(
              height: 20,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Type Statistiques',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.category,
                  color: Colors.grey,
                ),
              ),
              items: statsTypes.map((String str) {
                return DropdownMenuItem<String>(
                  value: str,
                  child: Text(str),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  currentType = newValue!;
                  print(newValue);
                  switch (newValue) {
                    case "Journalier":
                      buyingText = "Achats Journaliers";
                      sellingText = "Ventes Journalières";
                      break;
                    case "Mensuel":
                      buyingText = "Achats Mensuels";
                      sellingText = "Ventes Mensuelles";
                      break;
                    case "Annuel":
                      buyingText = "Achats Annuels";
                      sellingText = "Ventes Annuelles";
                      break;
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return "Sélectionner un type";
                }
                return null;
              },
            ),
            if (currentType != null) ...[
              SizedBox(
                height: 20,
              ),
              if (currentType == "Journalier") ...[
                ElevatedButton(
                  onPressed: () async {
                    _selectDate(context);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 128)),
                  child: Text(_selectedDate == null
                      ? 'Sélectionner une date'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                ),
                ShadowedContainer(
                    content: Text(
                  buyingText,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                )),
                ShadowedContainer(
                    content: Column(
                  children: [
                    Text(
                      "Total achats",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!_isLoadingValue) ...[
                      Text(
                        "$_totalDailyPurchased Fcfa",
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ] else
                      CircularProgressIndicator(),
                  ],
                )),
                ShadowedContainer(
                    content: Text(
                  sellingText,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                )),
                ShadowedContainer(
                    content: Column(
                  children: [
                    Text(
                      "Total ventes",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!_isLoadingValue) ...[
                      Text(
                        "$_totalDailySold Fcfa",
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ] else
                      CircularProgressIndicator(),
                  ],
                ))
              ],
              if (currentType == "Mensuel") ...[
                ElevatedButton(
                  onPressed: () async {
                    _selectStartDate(context);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 128)),
                  child: Text(_startDate == null
                      ? 'Sélectionner une date de départ'
                      : "Du ${DateFormat('yyyy-MM-dd').format(_startDate!)} au ${DateFormat('yyyy-MM-dd').format(_startDate!.add(const Duration(days: 31)))}"),
                ),
                ShadowedContainer(
                    content: Text(
                  buyingText,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                )),
                ShadowedContainer(
                    content: Column(
                  children: [
                    Text(
                      "Total achats",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!_isLoadingValue) ...[
                      Text(
                        "$_totalMonthlyPurchased Fcfa",
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ] else
                      CircularProgressIndicator(),
                  ],
                )),
                ShadowedContainer(
                    content: Text(
                  sellingText,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                )),
                ShadowedContainer(
                    content: Column(
                  children: [
                    Text(
                      "Total ventes",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!_isLoadingValue) ...[
                      Text(
                        "$_totalMonthlySold Fcfa",
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ] else
                      CircularProgressIndicator(),
                  ],
                ))
              ],
              if (currentType == "Annuel") ...[
                DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: InputDecoration(
                    labelText: 'Année',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: const Color.fromARGB(255, 0, 0, 128))),
                    prefixIcon: Icon(
                      Icons.numbers,
                      color: Colors.grey,
                    ),
                  ),
                  items:
                      List<int>.generate(5, (i) => 2024 + i).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    _isLoadingValue = true;
                    setState(() {
                      _selectedYear = newValue!;
                    });

                    _calculateTotalYearlySentOrders(_selectedYear!)
                        .then((value) => setState(() {
                              _totalYearlyPurchased = value;
                              _isLoadingValue = false;
                            }));

                    _calculateTotalYearlyReceivedOrders(_selectedYear!)
                        .then((value) => setState(() {
                              _totalYearlySold = value;
                              _isLoadingValue = false;
                            }));
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Sélectionner une année";
                    }
                    return null;
                  },
                ),
                ShadowedContainer(
                    content: Text(
                  buyingText,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                )),
                ShadowedContainer(
                    content: Column(
                  children: [
                    Text(
                      "Total achats",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!_isLoadingValue) ...[
                      Text(
                        "$_totalYearlyPurchased Fcfa",
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ] else
                      CircularProgressIndicator(),
                  ],
                )),
                ShadowedContainer(
                    content: Text(
                  sellingText,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                )),
                ShadowedContainer(
                    content: Column(
                  children: [
                    Text(
                      "Total ventes",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!_isLoadingValue) ...[
                      Text(
                        "$_totalYearlySold Fcfa",
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ] else
                      CircularProgressIndicator(),
                  ],
                ))
              ],
            ]
          ],
        ),
      )),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2034),
    );

    _isLoadingValue = true;

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

        if (_selectedDate != null) {
          _calculateTotalDailySentOrders(_selectedDate!)
              .then((value) => setState(() {
                    _totalDailyPurchased = value;
                    _isLoadingValue = false;
                  }));

          _calculateTotalDailyReceivedOrders(_selectedDate!)
              .then((value) => setState(() {
                    _totalDailySold = value;
                    _isLoadingValue = false;
                  }));
        }
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2034),
    );

    _isLoadingValue = true;
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;

        DateTime endDate = _startDate!.add(const Duration(days: 31));

        if (_startDate != null) {
          _calculateTotalSentOrdersBetweenDates(_startDate!, endDate)
              .then((value) => setState(() {
                    _totalMonthlyPurchased = value;
                    _isLoadingValue = false;
                  }));

          _calculateTotalReceivedOrdersBetweenDates(_startDate!, endDate)
              .then((value) => setState(() {
                    _totalMonthlySold = value;
                    _isLoadingValue = false;
                  }));
        }
      });
    }
  }
}

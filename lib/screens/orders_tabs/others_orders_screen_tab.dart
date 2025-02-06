import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/order.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/widgets/shadowed_container.dart';

class OthersOrdersScreenTab extends StatefulWidget {
  const OthersOrdersScreenTab({super.key});

  @override
  State<OthersOrdersScreenTab> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OthersOrdersScreenTab> {
  static const _pageSize = 5;
  final PagingController<int, Order> _pagingController =
      PagingController(firstPageKey: 0);

  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;
  List<Order> allOrders = [];

  // Cache principale avec Hive
  late Box mainCache;

  late Future<List<Order>> _futureOrdersDatas;

  // Initialisation
  @override
  void initState() {
    super.initState();
    mainCache = Hive.box(Glob.mainCache);

    _pagingController.addPageRequestListener((pageKey) {
      _fetchAllOrders().then((_) {
        _fetchPage(pageKey);
      });
    });
  }

  Future<void> _fetchAllOrders() async {
    try {
      allOrders = await _fetchOrders();
    } catch (error) {
      print("\n\n Error fetch all orders");
      print(error);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          allOrders.skip(pageKey * _pageSize).take(_pageSize).toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
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
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day < 10 ? "0${dateTime.day}" : dateTime.day}-${dateTime.month < 10 ? "0${dateTime.month}" : dateTime.month}-${dateTime.year}  ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Text(
          "Commandes reçues",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: PagedListView<int, Order>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Order>(
                itemBuilder: (context, order, index) => ShadowedContainer(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(16),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commande #${order.id}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Date: ${formatDate(order.date!)}'),
                        SizedBox(height: 8),
                        Text('Total: ${order.totalPrice} FCFA'),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /*IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editOrder(context, order),
                        ),*/
                            if (order.status == "pending")
                              Text(
                                "En attente",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            if (order.status == "canceled")
                              Text(
                                "Annulée",
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            if (order.status == "validated")
                              Text(
                                "Validée",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            if (order.status == "rejected")
                              Text(
                                "rejetée",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            if (order.status == "pending") ...[
                              FilledButton(
                                  onPressed: () async {
                                    _validatedOrder(order.id!).then((_) {
                                      setState(() {
                                        _fetchAllOrders();
                                        _pagingController.refresh();
                                      });
                                    });
                                  },
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withAlpha(30),
                                      overlayColor: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withAlpha(120),
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Text("Valider")
                                    ],
                                  )),
                              FilledButton(
                                  onPressed: () async {
                                    await _showCancelConfirmation(
                                            context, order.id!)
                                        .then((confirmed) {
                                      if (confirmed) {
                                        setState(() {
                                          _fetchAllOrders();
                                          _pagingController.refresh();
                                        });
                                      }
                                    });
                                  },
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red.withAlpha(30),
                                      overlayColor: Colors.red.withAlpha(120),
                                      foregroundColor: Colors.red),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Text("Rejeter")
                                    ],
                                  ))
                            ]
                          ],
                        ),
                      ],
                    ))),
          ),
        )
      ],
    ));
  }

  Future<void> _validatedOrder(int id) async {
    final token = Glob.token;
    final response = await http.patch(
      Uri.parse("$apiHead/orders/$id/validate"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //_showDialogMsg(context, "Ordere supprimé avec succès");
    } else {
      throw Exception('Failed to validate order');
    }
  }

  Future<void> _rejectOrder(int id) async {
    final token = Glob.token;
    final response = await http.patch(
      Uri.parse("$apiHead/orders/$id/reject"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //_showDialogMsg(context, "Ordere supprimé avec succès");
    } else {
      throw Exception('Failed to validate order');
    }
  }

  Future<bool> _showCancelConfirmation(BuildContext context, int id) async {
    bool t = true;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment annuler cette commande ?'),
          actions: [
            TextButton(
              onPressed: () {
                t = false;
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                _rejectOrder(id);
                //_deleteOrder(id); // ESupprimer le order
                t = true;
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );

    return t;
  }
}

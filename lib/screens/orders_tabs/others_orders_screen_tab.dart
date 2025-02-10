import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/order.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/models/user.dart';
import 'package:kakao_farmer/widgets/shadowed_container.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  WebSocketChannel? channel;

  // Initialisation
  @override
  void initState() {
    super.initState();
    mainCache = Hive.box(Glob.mainCache);

    channel = Glob.channel;

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

  Future<List<Order>> _fetchOrders() async {
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

  Future<http.Response> _createNotification(
      int userId, String title, String content) async {
    final token = Glob.token;
    //final userId = Glob.userId;

    final response = await http.post(Uri.parse("$apiHead/notifications/"),
        headers: <String, String>{
          "Content-type": "application/json;charset=UTF-8",
          'Authorization': "Bearer $token"
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": userId,
          "title": title,
          "content": content
        }));

    if (response.statusCode == 201 || response.statusCode == 200) {
      channel!.sink.add(jsonEncode({
        "type": "send_notification",
        "targetId": userId,
        "title": title,
        "content": content
      }));

      return response;
    } else {
      print("Impossible d'envoyer la notification");
      print(response.statusCode);
      print(response.body);
      return response;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  String addZeroBefore(int data) {
    return "${data < 10 ? "0$data" : data}";
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${addZeroBefore(dateTime.day)}-${addZeroBefore(dateTime.month)}-${dateTime.year}  ${addZeroBefore(dateTime.hour)}:${addZeroBefore(dateTime.minute)}';
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
                      Text('Date: ${formatDate(order.createdAt!)}'),
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
                                  _validatedOrder(order.id!, order.user!.id!)
                                      .then((_) {
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
                                          context, order.id!, order.user!.id!)
                                      .then((confirmed) {
                                    if (confirmed) {
                                      setState(() {
                                        _fetchAllOrders().then(
                                            (_) => _pagingController.refresh());
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
                  )),
              noItemsFoundIndicatorBuilder: (context) => Center(
                child: Text(
                  'Vous n\'avez reçu aucune commande',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
          ),
        )
      ],
    ));
  }

  Future<void> _validatedOrder(int id, int userId) async {
    final token = Glob.token;
    final response = await http.patch(
      Uri.parse("$apiHead/orders/$id/validate"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //_showDialogMsg(context, "Ordere supprimé avec succès");
      await _createNotification(userId, "Commande validée",
          "Votre commande a été validée par le propriétaire du produits");
    } else {
      throw Exception('Failed to validate order ${response.statusCode}');
    }
  }

  Future<void> _rejectOrder(int id, int userId) async {
    final token = Glob.token;
    final response = await http.patch(
      Uri.parse("$apiHead/orders/$id/reject"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //_showDialogMsg(context, "Ordere supprimé avec succès");
      await _createNotification(userId, "Commande rejetée",
          "Votre commande a été refusée par le propriétaire du produits");
    } else {
      throw Exception('Failed to validate order');
    }
  }

  Future<bool> _showCancelConfirmation(
      BuildContext context, int id, int userId) async {
    bool t = true;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment rejeter cette commande ?'),
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
                _rejectOrder(id, userId);
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

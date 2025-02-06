import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/order.dart';
import 'package:kakao_farmer/models/post.dart';
import 'package:kakao_farmer/models/product.dart';
import 'package:kakao_farmer/models/user.dart';
import 'package:kakao_farmer/screens/first_screen_tabs/screens/list_own_posts_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final Product? product;

  const CreateOrderScreen({super.key, required this.product});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

  // Formulaire
  final _formKey = GlobalKey<FormState>();

  // Cache principale avec Hive
  late Box mainCache;

  // Loading
  bool isLoading = false;

  // Variables pour la commande
  Product? product;
  User? user;
  int? quantity = 0;
  double? totalPrice = 0;
  String? date = "";

  // Initialisation
  @override
  void initState() {
    super.initState();

    mainCache = Hive.box(Glob.mainCache);
  }

  // Creer un post
  Future<http.Response> _createOrder(int quantity) async {
    final token = Glob.token;
    final userId = Glob.userId;

    final totalPrice = quantity * widget.product!.price!;
    final response = await http.post(Uri.parse("$apiHead/orders/"),
        headers: <String, String>{
          "Content-type": "application/json;charset=UTF-8",
          'Authorization': "Bearer $token"
        },
        body: jsonEncode(<String, dynamic>{
          "product_id": widget.product!.id,
          "user_id": userId,
          "quantity": quantity,
          "total_price": totalPrice
        }));

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("commande enregistrée avec succès")),
      );

      setState(() {
        isLoading = false;
      });

      Navigator.pop(context);
      return response;
    } else {
      print("Impossible d'enregistrer la commande");
      print(response.statusCode);
      print(response.body);
      return response;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestion des commandes",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              Text(
                "Passer une commande",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 25),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                widget.product!.name!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Prix : ${widget.product!.price!} FCFA",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Articles restants : ${widget.product!.stock}",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Quantité',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.numbers,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Entrer la quantite";
                        }
                        if (int.parse(value) < 0) {
                          return "Entrer un nombre positif";
                        }
                        if (int.parse(value) > widget.product!.stock!) {
                          return "Nombre d'articles insuffisants";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        quantity = int.parse(value!);
                      },
                    ),
                  ),
                  //const SizedBox(width: 10),
                  //const Text('u', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      setState(() {
                        isLoading = true;
                      });
                      _createOrder(quantity!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor),
                  child: const Text("Passer la commande")),
            ],
          ),
        ),
      )),
    );
  }
}

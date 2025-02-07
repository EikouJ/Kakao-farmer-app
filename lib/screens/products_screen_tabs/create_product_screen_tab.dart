import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/product.dart';

class CreateProductScreenTab extends StatefulWidget {
  const CreateProductScreenTab({super.key});

  @override
  State<CreateProductScreenTab> createState() => _CreateProductScreenTabState();
}

class _CreateProductScreenTabState extends State<CreateProductScreenTab> {
  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

  // Formulaire
  final _formKey = GlobalKey<FormState>();

  // Variables pour le produit
  String name = "";
  double price = 0;
  String city = "";
  int stock = 0;

  // Initialisation
  @override
  void initState() {
    super.initState();
  }

  // Creer un produit
  Future<http.Response> _createProduct(Product product) async {
    final token = Glob.token;
    final response = await http.post(Uri.parse("$apiHead/products/"),
        headers: <String, String>{
          "Content-type": "application/json;charset=UTF-8",
          'Authorization': "Bearer $token"
        },
        body: jsonEncode(<String, dynamic>{
          "name": product.name,
          "price": product.price,
          "city": product.city,
          "stock": product.stock
        }));

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("produit enregistré avec succès")),
      );
      Navigator.pop(context);
      return response;
    } else {
      print("Impossible d'enregistrer le produit");
      print(response.statusCode);
      print(response.body);
      return response;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Text(
                "Vente de Cacao",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Ajouter un stock de produits a vendre",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.text_fields_sharp,
                    color: Colors.grey,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Entrer un nom pour votre produit";
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Prix',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.attach_money_rounded,
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Entrer un prix";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        price = double.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('FCFA', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Ville',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.location_city,
                    color: Colors.grey,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Entrer une ville";
                  }
                  return null;
                },
                onSaved: (value) {
                  city = value!;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Stock',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.inventory,
                    color: Colors.grey,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Entrer le stock";
                  }
                  return null;
                },
                onSaved: (value) {
                  stock = int.parse(value!);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final newProduct = Product(
                        name: name,
                        price: price,
                        city: city,
                        stock: stock,
                      );

                      _createProduct(newProduct);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor),
                  child: const Text("Ajouter")),
            ],
          ),
        ),
      )),
    );
  }
}

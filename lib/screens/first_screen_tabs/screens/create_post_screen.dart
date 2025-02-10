import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/post.dart';
import 'package:kakao_farmer/models/product.dart';
import 'package:kakao_farmer/screens/first_screen_tabs/screens/list_own_posts_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

  // Formulaire
  final _formKey = GlobalKey<FormState>();

  // Cache principale avec Hive
  late Box mainCache;

  // Variables pour le post
  Product? product;
  String link = "";
  String description = "";
  String type = "";

  late Future<List<Product>> _futureProductsDatas;

  // For spinner management
  bool _isloading = false;

  // Controlleurs pour les zones de textes
  TextEditingController linkController = TextEditingController(text: "");
  TextEditingController descriptionController = TextEditingController(text: "");

  // Valeurs possibles pour le type de poste
  List<String> optionsTypes = ["Image", "Video"];

  // Initialisation
  @override
  void initState() {
    super.initState();

    mainCache = Hive.box(Glob.mainCache);

    _futureProductsDatas = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final token = Glob.token;

    final response = await http.get(Uri.parse("$apiHead/products/"),
        headers: <String, String>{
          'Content-type': "application/json",
          'Authorization': "Bearer $token"
        });

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Product> products =
          body.map((dynamic item) => Product.fromJson(item)).toList();

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Creer un post
  Future<http.Response> _createPost(Post post) async {
    final token = Glob.token;
    final response = await http.post(Uri.parse("$apiHead/posts/"),
        headers: <String, String>{
          "Content-type": "application/json;charset=UTF-8",
          'Authorization': "Bearer $token"
        },
        body: jsonEncode(<String, dynamic>{
          "product_id": product!.id,
          "link": link,
          "description": description,
          "type": type
        }));

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("poste enregistré avec succès")),
      );

      setState(() {
        linkController.clear();
        descriptionController.clear();
        _isloading = false;
      });
      // Navigator.pop(context);
      return response;
    } else {
      print("Impossible d'enregistrer le poste");
      print(response.statusCode);
      print(response.body);

      setState(() {
        _isloading = false;
      });

      return response;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestion des postes",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
              child: SingleChildScrollView(
                  child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Ajouter des postes",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 25),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  FutureBuilder<List<Product>>(
                    future:
                        _futureProductsDatas, // Assumes you have a method to fetch products
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Product>> snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return DropdownButtonFormField<Product>(
                        decoration: InputDecoration(
                          labelText: 'Produit',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.shopping_cart,
                            color: Colors.grey,
                          ),
                        ),
                        items: snapshot.data!.map((Product product) {
                          return DropdownMenuItem<Product>(
                            value: product,
                            child: Text(product.name!),
                          );
                        }).toList(),
                        onChanged: (Product? newValue) {
                          setState(() {
                            product = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Sélectionner un produit";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.url,
                    controller: linkController,
                    decoration: InputDecoration(
                      labelText: 'Lien',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.link,
                        color: Colors.grey,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Entrer un lien pour votre produit";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      link = value!;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    maxLines: 4,
                    minLines: 3,
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.description,
                        color: Colors.grey,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Entrer une description pour votre produit";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value!;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Type',
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
                    items: optionsTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value.toLowerCase(),
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        type = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Sélectionner un produit";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          setState(() {
                            _isloading = true;
                          });

                          final newPost = Post(
                            product: product,
                            link: link,
                            description: description,
                            type: type,
                          );

                          _createPost(newPost);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Text("Ajouter le poste")),
                ],
              ),
            ),
          ))),
          if (_isloading)
            Container(
              color: Colors.black54, // Fond semi-transparent
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 0, 0, 128),
                ), // Spinner
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ListOwnPostsScreen()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.list_alt),
      ),
    );
  }
}

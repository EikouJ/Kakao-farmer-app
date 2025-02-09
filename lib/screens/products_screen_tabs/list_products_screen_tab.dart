import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/product.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/widgets/own_product_widget.dart';

class ListProductsScreenTab extends StatefulWidget {
  const ListProductsScreenTab({super.key});

  @override
  State<ListProductsScreenTab> createState() => _ListProductsScreenTabState();
}

class _ListProductsScreenTabState extends State<ListProductsScreenTab> {
  static const _pageSize = 5;
  final PagingController<int, Product> _pagingController =
      PagingController(firstPageKey: 0);

  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;
  List<Product> allProducts = [];

  // Cache principale avec Hive
  late Box mainCache;

  late Future<List<Product>> _futureProductsDatas;

  // Initialisation
  @override
  void initState() {
    super.initState();
    mainCache = Hive.box(Glob.mainCache);

    _pagingController.addPageRequestListener((pageKey) {
      _fetchAllProducts().then((_) {
        _fetchPage(pageKey);
      });
    });
  }

  Future<void> _fetchAllProducts() async {
    try {
      allProducts = await _fetchProducts();
    } catch (error) {
      print("\n\n Error fetch all products");
      print(error);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          allProducts.skip(pageKey * _pageSize).take(_pageSize).toList();
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

  Future<List<Product>> _fetchProducts() async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/products/"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Product> products = await Future.wait(body.map((dynamic item) async {
        Product product = Product.fromJson(item);
        return product;
      }).toList());

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagedListView<int, Product>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Product>(
            itemBuilder: (context, product, index) => OwnProductWidget(
                  product: product,
                  onDelete: () => {
                    _showDeleteConfirmation(context, product.id!).then((_) {
                      setState(() {
                        _fetchAllProducts();
                        _pagingController.refresh();
                      });
                    })
                  },
                  onEdit: () => _editProduct(context, product),
                )),
      ),
    );
  }

  void _editProduct(BuildContext context, Product product) {
    Navigator.of(context).pop(product);
  }

  Future<void> _deleteProduct(int id) async {
    final token = Glob.token;
    final response = await http.delete(
      Uri.parse("$apiHead/products/$id"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //_showDialogMsg(context, "Producte supprimé avec succès");
    } else {
      throw Exception('Failed to delete product');
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int id) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer ce produit ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(id).then((_) {
                  //_showDialogMsg(context, "Produit supprimé avec succès");
                });
                //_deleteProduct(id); // ESupprimer le product
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogMsg(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('message'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

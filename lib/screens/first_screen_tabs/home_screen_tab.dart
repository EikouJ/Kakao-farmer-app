import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/post.dart';
import 'package:kakao_farmer/models/product.dart';
import 'package:kakao_farmer/models/user.dart';
import 'package:kakao_farmer/screens/first_screen_tabs/screens/create_post_screen.dart';
import 'package:kakao_farmer/widgets/post_widget.dart';
import 'package:kakao_farmer/widgets/shadowed_container.dart';
import 'package:http/http.dart' as http;

class HomeScreenTab extends StatefulWidget {
  const HomeScreenTab({super.key});

  @override
  State<HomeScreenTab> createState() => _HomeScreenTabState();
}

class _HomeScreenTabState extends State<HomeScreenTab> {
  static const _pageSize = 5;
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 0);

  final String apiHead = Glob.apiHead;
  late Box mainCache;
  List<Post> allPosts = [];

  @override
  void initState() {
    super.initState();
    mainCache = Hive.box(Glob.mainCache);

    _pagingController.addPageRequestListener((pageKey) {
      print("LOG");
      _fetchAllPosts().then((_) {
        _fetchPage(pageKey);
      });
    });
    /*_fetchAllPosts().then((_) {
      _pagingController.addPageRequestListener((pageKey) {
        print("LOG");
        _fetchPage(pageKey);
      });
    });*/
  }

  Future<void> _fetchAllPosts() async {
    try {
      allPosts = await _fetchPosts();

      print("\n\n\n TEST");
      /*_pagingController.addPageRequestListener((pageKey) {
        print("\n\n\n 3.2 - LIST");
        _fetchPage(pageKey);
      });*/

      print("\n\n\n 2 - FETCH ALL POSTS");
    } catch (error) {
      print("\n\n Error fetch all posts");
      print(error);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      print("\n\n\n 4.1 - LIST ${Glob.userStatus}");
      final newItems =
          allPosts.skip(pageKey * _pageSize).take(_pageSize).toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }

      print("\n\n\n 4.2 - LIST");
      inspect(newItems);
      print("\n\n\n");
    } catch (error) {
      print("\n\n Error fetch Page");
      print(error);
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

  Future<List<Post>> _fetchPosts() async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/posts/"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Post> posts = await Future.wait(body.map((dynamic item) async {
        Product product = await _fetchProduct(item["product_id"]);
        print("INSPECT PRODUCT");
        inspect(product);
        Post post = Post.fromJson(item);
        post.product = product;
        return post;
      }).toList());

      // D'abord récupérer tous les product_ids
      /*List<int> productIds =
          body.map<int>((item) => item["product_id"] as int).toList();

      // Récupérer tous les produits en une seule fois
      Map<int, Product> products = {};
      for (int id in productIds) {
        products[id] = await _fetchProduct(id);
      }

      // Créer les posts avec leurs produits associés
      return body.map<Post>((item) {
        Post post = Post.fromJson(item);
        post.product = products[item["product_id"]];
        return post;
      }).toList();*/

      /*List<Post> posts =
          body.map((dynamic item) => Post.fromJson(item)).toList();*/

      print("\n\n\n 1- RESPONSE BODY");
      inspect(posts);
      print("\n\n\n");

      return posts;
    } else {
      throw Exception('Failed to load posts');
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
      body: PagedListView<int, Post>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, post, index) => PostWidget(post: post)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreatePostScreen()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

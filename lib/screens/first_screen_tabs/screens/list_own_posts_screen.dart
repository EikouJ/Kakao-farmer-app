import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/post.dart';
import "package:http/http.dart" as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/widgets/own_post_widget.dart';

class ListOwnPostsScreen extends StatefulWidget {
  const ListOwnPostsScreen({super.key});

  @override
  State<ListOwnPostsScreen> createState() => _ListOwnPostsScreenState();
}

class _ListOwnPostsScreenState extends State<ListOwnPostsScreen> {
  static const _pageSize = 5;
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 0);

  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;
  List<Post> allPosts = [];

  // Cache principale avec Hive
  late Box mainCache;

  late Future<List<Post>> _futurePostsDatas;

  // Initialisation
  @override
  void initState() {
    super.initState();
    mainCache = Hive.box(Glob.mainCache);

    _pagingController.addPageRequestListener((pageKey) {
      _fetchAllPosts().then((_) {
        _fetchPage(pageKey);
      });
    });
  }

  Future<void> _fetchAllPosts() async {
    try {
      allPosts = await _fetchPosts();
    } catch (error) {
      print("\n\n Error fetch all posts");
      print(error);
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          allPosts.skip(pageKey * _pageSize).take(_pageSize).toList();
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

  Future<List<Post>> _fetchPosts() async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/user-posts/"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Post> posts = await Future.wait(body.map((dynamic item) async {
        Post post = Post.fromJson(item);
        return post;
      }).toList());

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
      appBar: AppBar(
        title: const Text(
          "Gestion des postes",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PagedListView<int, Post>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, post, index) => OwnPostWidget(
            post: post,
            onDelete: () => {
              _showDeleteConfirmation(context, post.id!).then((_) {
                setState(() {
                  _fetchAllPosts();
                  _pagingController.refresh();
                });
              })
            },
            onEdit: () => _editPost(context, post),
          ),
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Text(
              'Aucun poste disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  void _editPost(BuildContext context, Post post) {
    Navigator.of(context).pop(post);
  }

  Future<void> _deletePost(int id) async {
    final token = Glob.token;
    final response = await http.delete(
      Uri.parse("$apiHead/posts/$id"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      //_showDialogMsg(context, "Poste supprimé avec succès");
    } else {
      throw Exception('Failed to delete post');
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int id) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer ce post ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _deletePost(id).then((_) {
                  //_showDialogMsg(context, "Poste supprimé avec succès");
                });
                //_deletePost(id); // ESupprimer le post
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

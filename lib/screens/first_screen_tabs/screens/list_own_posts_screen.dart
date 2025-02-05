import 'package:flutter/material.dart';

class ListOwnPostsScreen extends StatefulWidget {
  const ListOwnPostsScreen({super.key});

  @override
  State<ListOwnPostsScreen> createState() => _ListOwnPostsScreenState();
}

class _ListOwnPostsScreenState extends State<ListOwnPostsScreen> {
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

      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

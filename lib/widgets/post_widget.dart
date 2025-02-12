import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/like_response.dart';
import 'package:kakao_farmer/models/post.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kakao_farmer/screens/create_order_screen.dart';
import "package:http/http.dart" as http;

class PostWidget extends StatefulWidget {
  final String? image;
  final Post post;

  const PostWidget({super.key, required this.post, this.image});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

  late ValueNotifier<bool> isLiked;
  late ValueNotifier<int> likesCount;

  @override
  void initState() {
    super.initState();

    isLiked = ValueNotifier<bool>(false);
    likesCount = ValueNotifier<int>(widget.post.likesCount ?? 0);
    _fetchIfUseLiked();
  }

  Future<http.Response> _likePost() async {
    final token = Glob.token;

    final response =
        await http.post(Uri.parse("$apiHead/likes/${widget.post.id}/"),
            headers: <String, String>{
              "Content-type": "application/json;charset=UTF-8",
              'Authorization': "Bearer $token"
            },
            body: jsonEncode(<String, dynamic>{}));

    if (response.statusCode == 201 || response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      LikeResponse lr = LikeResponse.fromJson(data);
      isLiked.value = lr.isLiked!;
      likesCount.value = lr.likesCount!;
      return response;
    } else {
      print("Impossible de liker");
      print(response.statusCode);
      print(response.body);
      return response;
    }
  }

  Future<void> _fetchIfUseLiked() async {
    final token = Glob.token;
    final response = await http.get(
      Uri.parse("$apiHead/likes/${widget.post.id}/user/liked"),
      headers: <String, String>{'Authorization': "Bearer $token"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      dynamic body = json.decode(utf8.decode(response.bodyBytes));
      isLiked.value = body["is_liked"];
      print(response.body);
    } else {
      throw Exception('Failed to load liked $response');
    }
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return 'publié le ${dateTime.day < 10 ? "0${dateTime.day}" : dateTime.day}-${dateTime.month < 10 ? "0${dateTime.month}" : dateTime.month}-${dateTime.year} à ${dateTime.hour}:${dateTime.minute}';
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      elevation: 0, // Supprime l'ombre de la carte
      shape: RoundedRectangleBorder(
        side: BorderSide.none, // Supprime les contours de la carte
      ),
      child: Column(
        children: [
          Divider(indent: 10, endIndent: 10, color: Colors.grey),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/user-circle.png'), // Image de l'avatar du propriétaire
            ),
            title:
                Text(widget.post.product!.user!.name!), // Nom du propriétaire
            subtitle: Text(formatDate(widget.post.date!)), // Date du post
          ),
          Divider(indent: 10, endIndent: 10, color: Colors.grey),
          if (widget.image != null)
            Image.asset(widget.image!), // Affiche l'image si elle est présente
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.product!.name!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
                if (widget.post.description!.length > 100)
                  Column(
                    children: [
                      Text(
                        '${widget.post.description!.substring(0, 100)}...',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Text(widget.post.description!),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Lire plus'),
                      ),
                    ],
                  )
                else
                  Text(
                    widget.post.description!,
                    style: TextStyle(fontSize: 16),
                  ),
                FutureBuilder(
                  future: Connectivity().checkConnectivity(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasData &&
                        snapshot.data != ConnectivityResult.none) {
                      return Image.network(
                        widget.post.link!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.fill,
                      );
                      //return Text("NOTHING");
                    } else {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            'No data',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
          ),
          // Ligne de séparation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ValueListenableBuilder<bool>(
                  valueListenable: isLiked,
                  builder: (context, liked, child) {
                    return TextButton.icon(
                      icon: Icon(
                          liked ? Icons.thumb_up_alt : Icons.thumb_up_off_alt,
                          color: Theme.of(context).colorScheme.primary),
                      label: ValueListenableBuilder(
                          valueListenable: likesCount,
                          builder: (context, likes, child) {
                            return Text(formatNumber(likes));
                          }),
                      onPressed: () {
                        _likePost();
                      },
                    );
                  }),
              /*TextButton.icon(
                icon: Icon(Icons.comment,
                    color: Theme.of(context).colorScheme.primary),
                label: Text('Comment'),
                onPressed: () {
                  // Action pour commenter
                },
              ),*/
              TextButton.icon(
                icon: Icon(Icons.shopping_cart,
                    color: Theme.of(context).colorScheme.primary),
                label: Text('Commander'),
                onPressed: () {
                  //_showOrderConfirmation(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreateOrderScreen(product: widget.post.product)));
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.share,
                    color: Theme.of(context).colorScheme.primary),
                label: Text('Share'),
                onPressed: () {
                  // Action pour partager
                },
              ),
            ],
          ),
          Divider(indent: 10, endIndent: 10, color: Colors.grey),
        ],
      ),
    );
  }

  /*void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Commander cet article ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateOrderScreen(product: widget.post.product)));
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
  }*/
}

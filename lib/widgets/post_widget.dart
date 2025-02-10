import 'package:flutter/material.dart';
import 'package:kakao_farmer/models/post.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kakao_farmer/screens/create_order_screen.dart';

class PostWidget extends StatelessWidget {
  final String? image;
  final Post post;

  const PostWidget({super.key, required this.post, this.image});

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return 'publié le ${dateTime.day < 10 ? "0${dateTime.day}" : dateTime.day}-${dateTime.month < 10 ? "0${dateTime.month}" : dateTime.month}-${dateTime.year} à ${dateTime.hour}:${dateTime.minute}';
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
                  'assets/owner_avatar.png'), // Image de l'avatar du propriétaire
            ),
            title: Text(post.product!.user!.name!), // Nom du propriétaire
            subtitle: Text(formatDate(post.date!)), // Date du post
          ),
          Divider(indent: 10, endIndent: 10, color: Colors.grey),
          if (image != null)
            Image.asset(image!), // Affiche l'image si elle est présente
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.product!.name!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
                if (post.description!.length > 100)
                  Column(
                    children: [
                      Text(
                        '${post.description!.substring(0, 100)}...',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: SingleChildScrollView(
                                child: Text(post.description!),
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
                    post.description!,
                    style: TextStyle(fontSize: 16),
                  ),
                FutureBuilder(
                  future: Connectivity().checkConnectivity(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasData &&
                        snapshot.data != ConnectivityResult.none) {
                      /*return Image.network(
                        post.link!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.fill,
                      );*/
                      return Text("NOTHING");
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
              TextButton.icon(
                icon: Icon(Icons.thumb_up_off_alt,
                    color: Theme.of(context).colorScheme.primary),
                label: Text('Like'),
                onPressed: () {
                  // Action pour like
                },
              ),
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
                              CreateOrderScreen(product: post.product)));
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

  void _showOrderConfirmation(BuildContext context) {
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
                            CreateOrderScreen(product: post.product)));
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
  }
}

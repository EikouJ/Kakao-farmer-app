import 'package:flutter/material.dart';
import 'package:kakao_farmer/models/post.dart';

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
              children: [
                //Image.network(post.link!),
                Text(
                  post.description!,
                  style: TextStyle(fontSize: 16),
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
                icon: Icon(Icons.share,
                    color: Theme.of(context).colorScheme.primary),
                label: Text('Share'),
                onPressed: () {
                  // Action pour partager
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.shopping_cart,
                    color: Theme.of(context).colorScheme.primary),
                label: Text('Commander'),
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
}

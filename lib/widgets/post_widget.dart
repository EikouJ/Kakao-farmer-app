import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String? image;
  final String description;

  const PostWidget({
    super.key,
    required this.image,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 0, // Supprime l'ombre de la carte
      shape: RoundedRectangleBorder(
        side: BorderSide.none, // Supprime les contours de la carte
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/owner_avatar.png'), // Image de l'avatar du propriétaire
            ),
            title: Text('Nom du Propriétaire'), // Nom du propriétaire
            subtitle: Text('Date du post'), // Date du post
          ),
          Divider(),
          if (image != null)
            Image.asset(image!), // Affiche l'image si elle est présente
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Divider(), // Ligne de séparation
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
              TextButton.icon(
                icon: Icon(Icons.comment,
                    color: Theme.of(context).colorScheme.primary),
                label: Text('Comment'),
                onPressed: () {
                  // Action pour commenter
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
        ],
      ),
    );
  }
}

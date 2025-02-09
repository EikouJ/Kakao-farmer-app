import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/post.dart';
import "package:http/http.dart" as http;

class OwnPostWidget extends StatelessWidget {
  final String? image;
  final Post post;
  final Function() onEdit;
  final Function() onDelete;

  const OwnPostWidget(
      {super.key,
      required this.post,
      this.image,
      required this.onDelete,
      required this.onEdit});

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
            title: Text(formatDate(post.date!)), // Date du post
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
                  "Description : ${post.description!}",
                  style: TextStyle(fontSize: 16),
                ),

                FutureBuilder(
                  future: Connectivity().checkConnectivity(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasData &&
                        snapshot.data != ConnectivityResult.none) {
                      return Image.network(post.link!);
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
              /*TextButton.icon(
                icon: Icon(Icons.edit, color: Colors.amber),
                label: Text(
                  'Modifier',
                  style: TextStyle(color: Colors.amber),
                ),
                onPressed: () {
                  //_editPost(context, post);
                  onEdit();
                },
              ),*/
              TextButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  //_showDeleteConfirmation(context, post.id!);
                  onDelete();
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

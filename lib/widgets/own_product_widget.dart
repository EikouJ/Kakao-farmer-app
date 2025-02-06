import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/models/product.dart';
import "package:http/http.dart" as http;

class OwnProductWidget extends StatelessWidget {
  final String? image;
  final Product product;
  final Function() onEdit;
  final Function() onDelete;

  const OwnProductWidget(
      {super.key,
      required this.product,
      this.image,
      required this.onDelete,
      required this.onEdit});

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
          Divider(indent: 2, endIndent: 2, color: Colors.grey),
          ListTile(
            tileColor: Theme.of(context)
                .colorScheme
                .primary, // Change background color
            title: Text(
              product.name!,
              style: TextStyle(color: Colors.white),
            ), // Date du product
          ),
          Divider(indent: 2, endIndent: 2, color: Colors.grey),
          Text(
            "Prix : ${product.price!} FCFA",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Ville : ${product.city!}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Stock : ${product.stock!}",
            style: TextStyle(fontSize: 16),
          ),

          // Ligne de séparation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
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

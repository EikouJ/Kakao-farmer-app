import 'package:kakao_farmer/models/user.dart';

class Product {
  final int? id;
  final String? name;
  final double? price;
  final String? city;
  final int? stock;

  User? user;

  Product({this.id, this.user, this.name, this.price, this.city, this.stock});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'city': city,
      'stock': stock,
      'user': user?.toJson()
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        city: json['city'],
        stock: json['stock']);
  }
}

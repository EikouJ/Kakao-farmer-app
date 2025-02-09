import 'package:kakao_farmer/models/product.dart';
import 'package:kakao_farmer/models/user.dart';

class Order {
  final int? id;
  Product? product;
  User? user;
  final int? quantity;
  final double? totalPrice;
  final String? createdAt;
  final String? status;

  Order(
      {this.id,
      this.product,
      this.user,
      this.quantity,
      this.totalPrice,
      this.createdAt,
      this.status});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product?.toJson(),
      'user': user?.toJson(),
      'quantity': quantity,
      'total_price': totalPrice,
      'created_at': createdAt,
      'status': status
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        quantity: json['quantity'],
        totalPrice: json['total_price'],
        createdAt: json['created_at'],
        status: json['status']);
  }
}

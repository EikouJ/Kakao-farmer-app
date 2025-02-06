import 'package:kakao_farmer/models/product.dart';
import 'package:kakao_farmer/models/user.dart';

class Order {
  final int? id;
  Product? product;
  User? user;
  final int? quantity;
  final double? totalPrice;
  final String? date;
  final String? status;

  Order(
      {this.id,
      this.product,
      this.user,
      this.quantity,
      this.totalPrice,
      this.date,
      this.status});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product?.toJson(),
      'user': user?.toJson(),
      'quantity': quantity,
      'total_price': totalPrice,
      'date': date,
      'status': status
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        quantity: json['quantity'],
        totalPrice: json['total_price'],
        date: json['date'],
        status: json['status']);
  }
}

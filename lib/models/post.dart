import 'package:kakao_farmer/models/product.dart';

class Post {
  final int? id;
  Product? product;
  final String? link;
  final String? description;
  final String? type;
  final String? date;

  Post(
      {this.id,
      this.product,
      this.link,
      this.description,
      this.type,
      this.date});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product?.toJson(),
      'link': link,
      'description': description,
      'type': type,
      'date': date
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        link: json['link'],
        description: json['description'],
        type: json['type'],
        date: json['date']);
  }
}

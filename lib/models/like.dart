import 'package:kakao_farmer/models/user.dart';

class Like {
  final int? id;
  final int? userId;
  final int? materialId;
  final bool? isLiked;
  User? user;

  Like({this.id, this.userId, this.materialId, this.isLiked});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'user_id': userId,
      'material_id': materialId,
      'is_liked': isLiked
    };
  }

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
        id: json['id'],
        userId: json['user_id'],
        materialId: json['material_id']);
  }
}

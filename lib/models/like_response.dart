import 'package:kakao_farmer/models/post.dart';

class LikeResponse {
  final int? postId;
  final bool? isLiked;
  final int? likesCount;
  Post? post;

  LikeResponse({this.postId, this.isLiked, this.likesCount});

  Map<String, dynamic> toJson() {
    return {
      'post': post?.toJson(),
      'post_id': postId,
      'likes_count': likesCount
    };
  }

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeResponse(
        postId: json["post_id"],
        isLiked: json["is_liked"],
        likesCount: json["likes_count"]);
  }
}

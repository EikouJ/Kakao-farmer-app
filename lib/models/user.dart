class User {
  final int? id;
  final String? name;
  final String? username;
  final String? email;
  final String? status;

  User({this.id, this.name, this.username, this.email, this.status});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'status': status,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        username: json['price'],
        email: json['city'],
        status: json['stock']);
  }
}

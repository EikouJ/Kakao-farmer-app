import 'package:web_socket_channel/web_socket_channel.dart';

class Glob {
  static String? token;
  //static dynamic user;

  static int? userId;
  static String? userStatus;

  static dynamic currentExchange;
  //static const String apiHead = "https://kakao-farmer-backend.onrender.com";
  static const String apiHead = "http://localhost:8000";

  static const String wsUrl = "ws://localhost:5501";

  static WebSocketChannel? channel;

  static String mainCache = "mainCache";
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/screens/home_screen.dart';
import 'package:kakao_farmer/screens/login_screen.dart';

/*
  Verifie si l'utilisateur est connecte ou non
 */
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //For Hive
  late Box mainCache;

  // Init state
  @override
  void initState() {
    super.initState();

    mainCache = Hive.box(Glob.mainCache);
  }

  // Recupere les element dans la base de donnees Hive
  dynamic _readValue(String key) {
    return mainCache.get(key);
  }

  bool _isLoggedIn() {
    return _readValue("token") != null && _readValue("user_id") != null;
  }

  @override
  Widget build(BuildContext context) {
    Glob.token = _readValue("token");
    Glob.userId = _readValue("user_id");
    Glob.userStatus = _readValue("user_status");

    return _isLoggedIn() ? const HomeScreen() : const HomeScreen();
    //return HomeScreen();
  }
}

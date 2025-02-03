import 'package:flutter/material.dart';
import 'package:kakao_farmer/screens/first_screen_tabs/home_screen_tab.dart';
import 'package:kakao_farmer/screens/first_screen_tabs/scanner_screen_tab.dart';
import 'package:kakao_farmer/screens/first_screen_tabs/statistics_screen_tab.dart';
import 'package:kakao_farmer/screens/learn_tabs/add_formation_screen_tab.dart';
import 'package:kakao_farmer/screens/learn_tabs/reading_screen_tab.dart';
import 'package:kakao_farmer/screens/learn_tabs/video_screen_tab.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              children: [
                ScannerScreenTab(),
                HomeScreenTab(),
                StatisticsScreenTab()
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 3,
                      offset: const Offset(2, 2))
                ]),
            child: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.camera), text: "Scanner"),
                Tab(icon: Icon(Icons.home), text: "Accueil"),
                Tab(icon: Icon(Icons.graphic_eq), text: "Statistiques"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

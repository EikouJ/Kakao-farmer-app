import 'package:flutter/material.dart';
import 'package:kakao_farmer/screens/learn_tabs/add_formation_screen_tab.dart';
import 'package:kakao_farmer/screens/learn_tabs/reading_screen_tab.dart';
import 'package:kakao_farmer/screens/learn_tabs/video_screen_tab.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
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
                DocScreenTab(),
                ReadingScreenTab(),
                AddFormationScreenTab()
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
                Tab(icon: Icon(Icons.menu_book_outlined), text: "Lecture"),
                Tab(
                    icon: Icon(Icons.video_collection_outlined),
                    text: "Playlist"),
                Tab(icon: Icon(Icons.post_add), text: "Créer"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

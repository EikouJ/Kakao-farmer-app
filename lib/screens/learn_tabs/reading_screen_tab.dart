import 'package:flutter/material.dart';
import 'package:kakao_farmer/screens/learn_tabs/cards/details/header_text_field.dart';
import 'package:kakao_farmer/screens/learn_tabs/cards/course_slider.dart';
import 'package:kakao_farmer/screens/learn_tabs/cards/course_horizontal_slider.dart';
import 'package:ionicons/ionicons.dart'; // Importation d'Ionic pour les icônes

class ReadingScreenTab extends StatefulWidget {
  const ReadingScreenTab({super.key});

  @override
  State<ReadingScreenTab> createState() => _ReadingScreenTab();
}

class _ReadingScreenTab extends State<ReadingScreenTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bonjour User",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF650F00),
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Apprenez avec nous!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Action pour le bouton de recherche
            },
            icon: Icon(Ionicons.search),
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 253, 253),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      HeaderTextField(
                        title: "Pour vous",
                      ),
                      const CourseHorizontalSlider(),
                      const SizedBox(height: 10),
                      HeaderTextField(title: "Populaire"),
                      const CourseSlider(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

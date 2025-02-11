import 'dart:convert';
import 'package:go_router/go_router.dart';
import "package:flutter/material.dart";
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/screens/main_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_farmer/screens/learn_tabs/cards/details/course_detail_page.dart';

void main() async {
  //  Initialisation de Hive
  await Hive.initFlutter();

  // Open box for storing datas
  await Hive.openBox(Glob.mainCache);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kakao Farmer",
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 131, 41, 41), // Marron foncé
        scaffoldBackgroundColor: Color.fromARGB(255, 230, 230, 230), // Beige
        colorScheme: ColorScheme(
          primary: const Color.fromARGB(255, 131, 41, 41), // Marron foncé
          secondary: Color(0xFF2E7D32), // Vert forêt
          surface: Color.fromARGB(255, 230, 230, 230), // Beige
          error: Colors.red,
          onPrimary: Colors.white, // Texte sur fond marron
          onSecondary: Colors.white, // Texte sur fond vert
          onSurface: Colors.black, // Texte principal
          onError: Colors.white,
          brightness: Brightness.light,
        ),

        appBarTheme: AppBarTheme(
            backgroundColor:
                const Color.fromARGB(255, 131, 41, 41), // Marron foncé
            foregroundColor: Colors.white, // Texte blanc
            elevation: 3,
            shadowColor: Colors.grey),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD4A017), // Doré
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4E342E)),
          headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32)),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('fr', ''), // Français
        // autres locales...
      ],
      home: const MainScreen(),
    );
  }
}

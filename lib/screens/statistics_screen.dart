import 'package:flutter/material.dart';
import 'package:kakao_farmer/glob.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Statistiques"),
    );
  }
}

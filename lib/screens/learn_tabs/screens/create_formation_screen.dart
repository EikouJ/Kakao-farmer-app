import 'package:flutter/material.dart';

class CreateFormationScreen extends StatefulWidget {
  const CreateFormationScreen({super.key});

  @override
  State<CreateFormationScreen> createState() => _CreateFormationScreenState();
}

class _CreateFormationScreenState extends State<CreateFormationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une nouveau post"),
      ),
      body: Container(
        child: Text("Create Post Screen"),
      ),
    );
  }
}

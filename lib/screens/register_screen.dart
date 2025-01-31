import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kakao_farmer/glob.dart';
import 'package:kakao_farmer/screens/login_screen.dart';
import 'package:kakao_farmer/widgets/shadowed_container.dart';
import "package:http/http.dart" as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Import global main route for api
  final String apiHead = Glob.apiHead;

  // Form variables
  String name = "", email = "", password = "", cPassword = "";
  final _formKey = GlobalKey<FormState>();

  // For spinner management
  bool _isloading = false;

  // Implement logic of user registration
  Future<void> _registerLogic(
      String nameDt, String emailDt, String passwordDt) async {
    try {
      final response = await http.post(Uri.parse("$apiHead/auth/register"),
          headers: <String, String>{
            "Content-type": "application/json;charset=UTF-8"
          },
          body: jsonEncode(<String, String>{
            "name": nameDt,
            "email": emailDt,
            "password": passwordDt
          }));

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Votre compte a été créé avec succès")),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Un utilisateur avec ce nom, cet email ou ce numéro de téléphone existe déjà")),
        );
      } else {
        print(response.body);

        print("L'enregistrement a échoué : ${response.statusCode}");

        final data = json.decode(response.body);
        if (data["message"] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"])),
          );
        }
      }

      setState(() {
        _isloading = false;
      });
    } catch (e) {
      setState(() {
        _isloading = false;
      });

      print("Try Catch Error");
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur Reseau, veuillez reessayer")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: ShadowedContainer(
                    content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_alt_1,
                                color: Theme.of(context).primaryColor,
                                size: 40.0,
                              ),
                              Text(
                                "Inscription",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 25),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Entrez votre nom";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              name = value!;
                            },
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.grey,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Entrez votre email";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              email = value!;
                            },
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.password,
                                color: Colors.grey,
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Entrer votre mot de passe";
                              }
                              if (value.length < 8) {
                                return "8 caractères minimum requis";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              password = value;
                            },
                            onSaved: (value) {
                              password = value!;
                            },
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Confirmer le mot de passe',
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.password,
                                color: Colors.grey,
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.compareTo(password) != 0) {
                                return "La confirmation a échoué, veuillez réessayer";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              cPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  setState(() {
                                    _isloading = true;
                                  });
                                  _registerLogic(name, email, password);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              child: const Text("S'inscrire")),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()));
                              },
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              child: const Text("J'ai déjà un compte"))
                        ],
                      )),
                )),
              ),
            ),
            if (_isloading)
              Container(
                color: Colors.black54, // Fond semi-transparent
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 0, 0, 128),
                  ), // Spinner
                ),
              )
          ],
        ),
      ),
    );
  }
}

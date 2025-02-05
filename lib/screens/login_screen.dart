import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kakao_farmer/glob.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/screens/home_screen.dart';
import 'package:kakao_farmer/screens/register_screen.dart';
import 'package:kakao_farmer/widgets/shadowed_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Import global main route for api
  final String apiHead = Glob.apiHead;

  // For Hive
  late Box mainCache;

  // Form variables
  String identifier = "", password = "";

  // Error message
  String errorMsg = "";

  // For spinner management
  bool _isloading = false;

  final _formKey = GlobalKey<FormState>();

  // Initialize widget state
  @override
  void initState() {
    super.initState();
    mainCache = Hive.box(Glob.mainCache);
  }

  // Implement logic for login with identifier (username/email) and password
  Future<void> _loginLogic(String identifierDt, String passwordDt) async {
    try {
      final response = await http.post(Uri.parse("$apiHead/users/login"),
          headers: <String, String>{
            "Content-type": "application/json;charset=utf-8"
          },
          body: jsonEncode(<String, String>{
            "identifier": identifierDt,
            "password": passwordDt
          }));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data["detail"]);
        Glob.token = data["access_token"];
        Glob.userId = data["user_id"];
        Glob.userStatus = data["user_status"];

        mainCache.put("token", data["access_token"]);
        mainCache.put("user_id", data["user_id"]);
        mainCache.put("user_status", data["user_status"]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connexion réussie")),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Nom d'utlisateur ou mot de passe incorrect")),
        );
      } else {
        print(response.body);
        print("La connexion a échoué : ${response.statusCode}");

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
                    children: <Widget>[
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColor,
                            size: 40.0,
                          ),
                          Text(
                            "Connexion",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 25),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email ou nom d\'utilisateur',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.key,
                            color: Colors.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Entrez votre email ou nom d'utilisateur";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          identifier = value!;
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
                            return "Entrez votre mot de passe";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              setState(() {
                                _isloading = true;
                              });
                              _loginLogic(identifier, password);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Theme.of(context).primaryColor),
                          child: const Text("Se connecter")),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          child: const Text("Je n'ai pas de compte"))
                    ],
                  ),
                ),
              ),
            )),
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
    ));
  }
}

import "package:flutter/material.dart";
import "package:kakao_farmer/glob.dart";
import "package:kakao_farmer/screens/buy_sell_screen.dart";
import "package:kakao_farmer/screens/first_screen.dart";
import "package:kakao_farmer/screens/learning_screen.dart";
import "package:kakao_farmer/screens/login_screen.dart";
import "package:kakao_farmer/screens/products_screen.dart";
import "package:kakao_farmer/screens/profil_screen.dart";
import "package:kakao_farmer/screens/statistics_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _currentScreen = const Center(child: FirstScreen());

  void _logoutLogic() {
    Glob.token = null;
    Glob.user = null;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _updateScreen(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakao Farmer'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(100, 100, 0, 0),
                  items: [
                    PopupMenuItem<int>(
                      enabled: false,
                      child: Column(
                        children: [
                          Text(
                            'Profil',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                                'assets/avatar.png'), // Replace with your avatar image
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.edit,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                label: Text(
                                  'Modifier',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  _updateScreen(const ProfilScreen());
                                },
                              ),
                              TextButton.icon(
                                icon: Icon(Icons.logout,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                label: Text(
                                  'Déconnexion',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  _logoutLogic();
                                },
                              ),

                              /*IconButton(
                                icon: Icon(Icons.edit),
                                color: Theme.of(context).colorScheme.secondary,
                                tooltip: 'Modifier le Profil',
                                onPressed: () {
                                  _updateScreen(const ProfilScreen());
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.logout),
                                color: Theme.of(context).colorScheme.secondary,
                                tooltip: "Deconnexion",
                                onPressed: () {
                                  _logoutLogic();
                                },
                              ),*/
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ).then((value) {
                  switch (value) {
                    case 0:
                      _logoutLogic();
                      break;
                    default:
                      break;
                  }
                });
              })
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Accueil'),
              onTap: () {
                _updateScreen(const FirstScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.tv),
              title: Text('Formation'),
              onTap: () {
                _updateScreen(const LearningScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.production_quantity_limits),
              title: Text('Produits'),
              onTap: () {
                _updateScreen(const ProductsScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.sell),
              title: Text('Achats - Ventes'),
              onTap: () {
                _updateScreen(const BuySellScreen());
              },
            ),
          ],
        ),
      ),
      body: _currentScreen,
      /*bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_sharp),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: 'Statistiques',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // "Accueil" est sélectionné par défaut
        backgroundColor: Colors.white,
      ),*/
    );
  }
}

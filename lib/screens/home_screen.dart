import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:kakao_farmer/glob.dart";
import "package:kakao_farmer/screens/buy_sell_screen.dart";
import "package:kakao_farmer/screens/orders_screen.dart";
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

  // Pour Hive
  late Box mainCache;

  // Initialiser l'état
  @override
  void initState() {
    super.initState();
    mainCache = Hive.box(Glob.mainCache);

    // Récupérer le token et l'utilisateur depuis le cache
    Glob.token = mainCache.get("token");
    Glob.userId = mainCache.get("user_id");
    Glob.userStatus = mainCache.get("user_status");
  }

  void _logoutLogic() {
    Glob.token = null;
    Glob.userId = null;
    Glob.userStatus = null;

    // Supprimer le token et l'utilisateur du cache
    mainCache.delete("token");
    mainCache.delete("user_id");
    mainCache.delete("user_status");

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
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications),
              ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    '3', // Replace with the actual number of notifications
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
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
                                icon: Icon(Icons.shopping_cart,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                label: Text(
                                  'Commandes',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  _updateScreen(const OrdersScreen());
                                },
                              ),
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
                                  _showLogoutConfirmation(context);
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
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _logoutLogic(); // Exécuter la déconnexion
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }
}

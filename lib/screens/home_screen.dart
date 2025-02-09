import "dart:convert";

import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:kakao_farmer/glob.dart";
import "package:kakao_farmer/screens/buy_sell_screen.dart";
import "package:kakao_farmer/screens/notifications_screen.dart";
import "package:kakao_farmer/screens/orders_screen.dart";
import "package:kakao_farmer/screens/first_screen.dart";
import "package:kakao_farmer/screens/learning_screen.dart";
import "package:kakao_farmer/screens/login_screen.dart";
import "package:kakao_farmer/screens/products_screen.dart";
import "package:kakao_farmer/screens/profil_screen.dart";
import "package:kakao_farmer/screens/statistics_screen.dart";
import "package:web_socket_channel/io.dart";
import "package:web_socket_channel/web_socket_channel.dart";
import "package:http/http.dart" as http;
import "package:kakao_farmer/models/notification.dart" as ModelNotification;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _currentScreen = const Center(child: FirstScreen());

  // Importer la route principale globale pour l'API
  final String apiHead = Glob.apiHead;

  // Pour Hive
  late Box mainCache;

  WebSocketChannel? channel;

  int unreadNotifications = 0;

  // Initialiser l'état
  @override
  void initState() {
    super.initState();
    mainCache = Hive.box(Glob.mainCache);

    Glob.channel = IOWebSocketChannel.connect(Glob.wsUrl);
    channel = Glob.channel;

    // Récupérer le token et l'utilisateur depuis le cache
    Glob.token = mainCache.get("token");
    Glob.userId = mainCache.get("user_id");
    Glob.userStatus = mainCache.get("user_status");

    // Websocket authentication
    channel!.sink.add(jsonEncode({
      "type": "authenticate",
      "userId": Glob.userId,
      "status": Glob.userStatus
    }));

    channel!.stream.listen((message) {
      print("Main Notification received");
      _setUnreadNotificationsNb();
    });

    _setUnreadNotificationsNb();
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

  void _setUnreadNotificationsNb() async {
    final token = Glob.token;

    final response = await http.get(Uri.parse("$apiHead/notifications/"),
        headers: <String, String>{'Authorization': "Bearer $token"});

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<dynamic> notifs = body
          .where((notification) => notification["read_at"] == null)
          .toList();
      /*List<dynamic> notifs = body
          .where((notification) => notification["read_at"] == null)
          .toList();*/

      setState(() {
        unreadNotifications = notifs.length;
      });
    } else {
      throw Exception(
          'Failed to load notifications ${response.statusCode} : ${response.body}');
    }
  }

  void _updateScreen(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
    Navigator.pop(context); // Close the drawer
  }

  /*@override
  void dispose() {
    channel!.sink.close();
    super.dispose();
  }*/

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
                onPressed: () {
                  //_updateScreen(const NotificationsScreen());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  ).then((value) {
                    if (value != null) {}
                    _setUnreadNotificationsNb();
                  });
                },
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
                    unreadNotifications
                        .toString(), // Replace with the actual number of notifications
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
                              //_updateScreen(const ModelNotificationsScreen());
                              /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ModelNotificationsScreen()));*/
                              /*TextButton.icon(
                                icon: Icon(Icons.notifications,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                label: Text(
                                  'ModelNotifications',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ModelNotificationsScreen()));
                                },
                              ),*/
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
            /*ListTile(
              leading: Icon(Icons.sell),
              title: Text('Achats - Ventes'),
              onTap: () {
                _updateScreen(const BuySellScreen());
              },
            ),*/
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

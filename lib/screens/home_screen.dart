import "package:flutter/material.dart";
import "package:kakao_farmer/glob.dart";
import "package:kakao_farmer/screens/buy_sell_screen.dart";
import "package:kakao_farmer/screens/learning_screen.dart";
import "package:kakao_farmer/screens/login_screen.dart";
import "package:kakao_farmer/screens/profil_screen.dart";
import "package:kakao_farmer/screens/statistics_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _currentScreen = const Center(child: LearningScreen());

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
            IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(100, 100, 0, 0),
                    items: [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text('Déconnexion')
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
                leading: Icon(Icons.tv),
                title: Text('Formation'),
                onTap: () {
                  _updateScreen(const LearningScreen());
                },
              ),
              ListTile(
                leading: Icon(Icons.sell),
                title: Text('Achats - Ventes'),
                onTap: () {
                  _updateScreen(const BuySellScreen());
                },
              ),
              ListTile(
                leading: Icon(Icons.graphic_eq),
                title: Text('Statistiques'),
                onTap: () {
                  _updateScreen(const StatisticsScreen());
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profil'),
                onTap: () {
                  _updateScreen(const ProfilScreen());
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Déconnexion'),
                onTap: () {
                  _logoutLogic();
                },
              ),
            ],
          ),
        ),
        body: _currentScreen);
  }
}

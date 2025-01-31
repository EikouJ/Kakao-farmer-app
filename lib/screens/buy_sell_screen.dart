import 'package:flutter/material.dart';

class BuySellScreen extends StatefulWidget {
  const BuySellScreen({super.key});

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              children: [Text("BUY"), Text("SELL")],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 3,
                      offset: const Offset(2, 2))
                ]),
            child: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.attach_money_sharp), text: "Achats"),
                Tab(icon: Icon(Icons.sell_outlined), text: "Ventes")
              ],
            ),
          )
        ],
      ),
    );
  }
}

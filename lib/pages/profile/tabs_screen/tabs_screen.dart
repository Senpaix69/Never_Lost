import 'package:flutter/material.dart';
import 'package:neverlost/pages/profile/tabs_screen/login_screen.dart';
import 'package:neverlost/pages/profile/tabs_screen/register_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => TabsScreenState();
}

class TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  final tabs = <Widget>[
    const Text("Login"),
    const Text("Register"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: myAppBar(context),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: TabBarView(
          controller: _controller,
          children: const <Widget>[
            LoginScreen(),
            RegisterScreen(),
          ],
        ),
      ),
    );
  }

  AppBar myAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      leading: actions(context),
      bottom: TabBar(
        indicatorWeight: 2.0,
        labelPadding: const EdgeInsets.all(10.0),
        labelStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        indicatorColor: Colors.grey,
        controller: _controller,
        unselectedLabelColor: Colors.grey[400],
        labelColor: Colors.grey[200],
        tabs: tabs,
      ),
    );
  }

  Container actions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[800],
      ),
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:my_timetable/pages/profile/login_screen.dart';
import 'package:my_timetable/pages/profile/register_screen.dart';

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
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/profBg.jpg"),
              fit: BoxFit.fitWidth,
            ),
          ),
          height: double.infinity,
          width: double.infinity,
          child: TabBarView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            controller: _controller,
            children: const <Widget>[
              LoginScreen(),
              RegisterScreen(),
            ],
          ),
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
        indicatorWeight: 3.0,
        labelPadding: const EdgeInsets.all(10.0),
        labelStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        indicatorColor: Colors.lightBlue,
        controller: _controller,
        labelColor: Colors.white,
        tabs: tabs,
      ),
    );
  }

  Container actions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.lightBlue,
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

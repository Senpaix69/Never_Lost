import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:neverlost/menu_screen.dart';
import 'package:neverlost/pages/main_home.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZoomDrawer(
        showShadow: true,
        drawerShadowsBackgroundColor: Theme.of(context).primaryColorDark,
        borderRadius: 30.0,
        angle: -10,
        slideWidth: MediaQuery.of(context).size.width * 0.8,
        mainScreenTapClose: true,
        menuScreen: const MenuScreen(),
        mainScreen: const MyHomePage(),
      ),
    );
  }
}

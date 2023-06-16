import 'package:flutter/widgets.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:neverlost/menu_screen.dart';
import 'package:neverlost/pages/main_home.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final ZoomDrawerController _controller = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _controller,
      mainScreenTapClose: true,
      menuScreen: const MenuScreen(),
      mainScreen: const MyHomePage(),
    );
  }
}

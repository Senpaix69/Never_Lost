import 'package:flutter/material.dart';
import 'package:my_timetable/pages/second_home.dart';
import 'package:my_timetable/pages/timetable/timetable_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:my_timetable/utils.dart' show MyCustomScrollBehavior;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    const TimeTablePage(),
    const SecondHomePage(),
  ];

  final PageController _pageController = PageController(initialPage: 0);

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg-2.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          scrollBehavior: MyCustomScrollBehavior(),
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          height: 50,
          color: const Color.fromARGB(255, 33, 33, 33),
          animationDuration: const Duration(milliseconds: 500),
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.grey[900],
          items: const <Widget>[
            Icon(Icons.today, size: 30, color: Colors.white),
            Icon(Icons.topic, size: 30, color: Colors.white),
          ],
          index: _currentPageIndex,
          onTap: (index) {
            setState(() {
              _currentPageIndex = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            });
          },
        ),
      ),
    );
  }
}

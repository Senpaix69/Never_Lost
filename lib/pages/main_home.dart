import 'package:flutter/material.dart';
import 'package:neverlost/pages/profile/user_profile_page.dart';
import 'package:neverlost/pages/second_home.dart';
import 'package:neverlost/pages/timetable/timetable_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:neverlost/utils.dart' show MyCustomScrollBehavior;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _pages = [
    const SecondHomePage(),
    const TimeTablePage(),
    const UserProfile(),
  ];

  int _currentPageIndex = 1;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _navigateToPage(int value) {
    if (value != _currentPageIndex) {
      setState(() {
        if (_currentPageIndex + 1 == value || _currentPageIndex - 1 == value) {
          _pageController.animateToPage(
            value,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(value);
        }
        _currentPageIndex = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg4.jpg"),
          fit: BoxFit.fill,
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: GNav(
            selectedIndex: _currentPageIndex,
            haptic: true,
            gap: 8,
            color: Colors.white,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            activeColor: Colors.white,
            iconSize: 25,
            tabBackgroundColor: Colors.lightBlue.shade800,
            padding: const EdgeInsets.all(10),
            tabs: const <GButton>[
              GButton(
                icon: Icons.notes,
                text: "Notes",
              ),
              GButton(
                icon: Icons.calendar_today,
                text: "TimeTables",
              ),
              GButton(
                icon: Icons.person,
                text: "Profile",
              ),
            ],
            onTabChange: _navigateToPage,
          ),
        ),
      ),
    );
  }
}

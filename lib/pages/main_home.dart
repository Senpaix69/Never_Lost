import 'package:flutter/material.dart';
import 'package:my_timetable/pages/profile/user_profile_page.dart';
import 'package:my_timetable/pages/second_home.dart';
import 'package:my_timetable/pages/timetable/timetable_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_timetable/utils.dart' show MyCustomScrollBehavior;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final PageController _pageController;
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    const TimeTablePage(),
    const SecondHomePage(),
    const UserProfile(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
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
            backgroundColor: Colors.transparent,
            tabs: const <GButton>[
              GButton(
                icon: Icons.calendar_today,
                text: "TimeTables",
              ),
              GButton(
                icon: Icons.notes,
                text: "Notes",
              ),
              GButton(
                icon: Icons.person,
                text: "Profile",
              ),
            ],
            onTabChange: (value) => setState(
              () {
                if (value + 1 == _currentPageIndex ||
                    value - 1 == _currentPageIndex) {
                  _pageController.animateToPage(
                    value,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _pageController.jumpToPage(value);
                }
                _currentPageIndex = value;
              },
            ),
          ),
        ),
      ),
    );
  }
}

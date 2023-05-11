import 'package:flutter/material.dart';
import 'package:my_timetable/pages/second_home.dart';
import 'package:my_timetable/pages/timetable/timetable_page.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
          image: AssetImage("assets/bg4.jpg"),
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
        // bottomNavigationBar: CurvedNavigationBar(
        //   height: 50,
        //   color: Colors.black,
        //   animationDuration: const Duration(milliseconds: 400),
        //   backgroundColor: Colors.lightBlue,
        //   buttonBackgroundColor: Colors.black,
        //   items: const <Widget>[
        //     Icon(Icons.today, size: 30, color: Colors.white),
        //     Icon(Icons.topic, size: 30, color: Colors.white),
        //   ],
        //   index: _currentPageIndex,
        //   onTap: (index) {
        //     setState(() {
        //       _currentPageIndex = index;
        //       _pageController.animateToPage(
        //         index,
        //         duration: const Duration(milliseconds: 400),
        //         curve: Curves.easeInOut,
        //       );
        //     });
        //   },
        // ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
          padding: const EdgeInsets.symmetric(
            vertical: 6,
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
                _currentPageIndex = value;
                _pageController.animateToPage(
                  value,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

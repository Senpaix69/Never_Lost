import 'package:flutter/material.dart';
import 'package:my_timetable/pages/timetables_page.dart';
import 'package:my_timetable/pages/todo_page.dart';
import 'package:my_timetable/utils.dart' show MyCustomScrollBehavior;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    const TimeTablesPage(),
    const TodoList(),
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
    return Scaffold(
      body: PageView(
        scrollBehavior: MyCustomScrollBehavior(),
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        fixedColor: Colors.cyan,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timelapse),
            label: 'Time Table',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Todo List',
          ),
        ],
        currentIndex: _currentPageIndex,
        onTap: (index) {
          _currentPageIndex = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}

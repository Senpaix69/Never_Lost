import 'package:flutter/material.dart';
import 'package:my_timetable/pages/note/add_note_page.dart';
import 'package:my_timetable/pages/note/note_page.dart';
import 'package:my_timetable/pages/todo/todo_page.dart';
import 'package:my_timetable/utils.dart' show MyCustomScrollBehavior;
import 'package:my_timetable/widgets/animate_route.dart';
import 'package:my_timetable/widgets/bottom_sheet.dart';

class SecondHomePage extends StatefulWidget {
  const SecondHomePage({super.key});
  @override
  State<SecondHomePage> createState() => _SecondHomePageState();
}

class _SecondHomePageState extends State<SecondHomePage> {
  int _selectedIndex = 0;

  final _pages = [
    const Note(),
    const TodoList(),
  ];

  final PageController _pageController = PageController(initialPage: 0);

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void gotoPage(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => gotoPage(0),
                  icon: Icon(
                    _selectedIndex == 0
                        ? Icons.note_alt_rounded
                        : Icons.note_alt_outlined,
                  ),
                  iconSize: 30.0,
                  color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                ),
                IconButton(
                  onPressed: () => gotoPage(1),
                  icon: Icon(
                    _selectedIndex == 1
                        ? Icons.check_box_rounded
                        : Icons.check_box_outlined,
                  ),
                  iconSize: 30.0,
                  color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        scrollBehavior: MyCustomScrollBehavior(),
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedIndex == 0 ? _addNotePage : _showAddTodoBottomSheet,
        child: const Icon(
          Icons.add,
          size: 30.0,
        ),
      ),
    );
  }

  void _addNotePage() {
    Navigator.of(context).push(
      SlideRightRoute(
        page: const AddNote(),
      ),
    );
  }

  void _showAddTodoBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) => const MyBottomSheet(),
    );
  }
}

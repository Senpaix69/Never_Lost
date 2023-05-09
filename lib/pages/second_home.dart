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
    const NoteList(),
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
    bool selected = _selectedIndex == 0;
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
                leadingWidget(
                  selected: !selected,
                  icon: Icons.note,
                  page: 0,
                ),
                leadingWidget(selected: selected, page: 1),
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
        onPressed: selected ? _addNotePage : _showAddTodoBottomSheet,
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          size: 30.0,
          color: Colors.white,
        ),
      ),
    );
  }

  SizedBox leadingWidget({
    required bool selected,
    required int page,
    IconData icon = Icons.check,
  }) {
    return SizedBox(
      width: 30.0,
      height: 30.0,
      child: InkWell(
        onTap: () => gotoPage(page),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.0),
            shape: BoxShape.rectangle,
            color: !selected ? Colors.lightBlue : Colors.transparent,
            border: Border.all(
              color: !selected ? Colors.lightBlue : Colors.white,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20.0,
              color: Colors.white,
            ),
          ),
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

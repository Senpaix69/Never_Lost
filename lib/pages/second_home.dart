import 'package:flutter/material.dart';
import 'package:neverlost/pages/note/add_note_page.dart';
import 'package:neverlost/pages/note/note_page.dart';
import 'package:neverlost/pages/todo/todo_page.dart';
import 'package:neverlost/widgets/animate_route.dart';
import 'package:neverlost/widgets/bottom_sheet.dart';

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
    _selectedIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
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
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: selected ? _addNotePage : _showAddTodoBottomSheet,
            child: const Icon(
              Icons.add,
              size: 30.0,
              color: Colors.white,
            ),
          ),
          if (_selectedIndex == 1)
            const SizedBox(
              height: 10,
            ),
          if (_selectedIndex == 1)
            FloatingActionButton(
              onPressed: () => gotoPage(0),
              child: const Icon(
                Icons.keyboard_backspace_sharp,
                size: 28.0,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  SizedBox leadingWidget({
    required bool selected,
    required int page,
    IconData icon = Icons.check,
  }) {
    return SizedBox(
      width: 35.0,
      height: 35.0,
      child: InkWell(
        onTap: () => gotoPage(page),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.0),
            shape: BoxShape.rectangle,
            color: !selected
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            border: Border.all(
              width: 2.0,
              color: !selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 25.0,
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

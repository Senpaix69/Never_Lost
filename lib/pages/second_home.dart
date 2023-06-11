import 'package:flutter/material.dart';
import 'package:neverlost/pages/note/add_note_page.dart';
import 'package:neverlost/pages/note/note_page.dart';
import 'package:neverlost/pages/todo/todo_page.dart';
import 'package:neverlost/widgets/animate_route.dart';
import 'package:neverlost/widgets/bottom_sheet.dart';
import 'package:neverlost/widgets/styles.dart' show decorationFormField;

class SecondHomePage extends StatefulWidget {
  const SecondHomePage({super.key});
  @override
  State<SecondHomePage> createState() => _SecondHomePageState();
}

class _SecondHomePageState extends State<SecondHomePage> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController(initialPage: 0);
  late final TextEditingController _controller;
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
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
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
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 10.0,
              left: 10.0,
              right: 10.0,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    leadingWidget(
                      selected: !selected,
                      icon: Icons.note,
                      page: 0,
                    ),
                    leadingWidget(selected: selected, page: 1),
                  ],
                ),
                const SizedBox(
                  height: 12.0,
                ),
                TextField(
                  onChanged: (value) => setState(() {}),
                  controller: _controller,
                  decoration: decorationFormField(
                    Icons.search,
                    "Search...",
                    context,
                    suffixIcon:
                        _controller.text.isNotEmpty ? Icons.close : null,
                    callBack: () => setState(() => _controller.text = ""),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          NoteList(searchQ: _controller.text),
          TodoList(searchQ: _controller.text),
        ],
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
                ? Theme.of(context).primaryColorLight
                : Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              width: 2.0,
              color: !selected
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).primaryColor,
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

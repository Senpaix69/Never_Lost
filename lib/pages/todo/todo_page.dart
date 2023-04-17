import 'package:flutter/material.dart';
import 'package:my_timetable/widgets/bottom_sheet.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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

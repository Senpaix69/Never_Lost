import 'package:flutter/material.dart';
import 'package:my_timetable/utils.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: emptyWidget(
        icon: Icons.checklist_outlined,
        message: "Empty Todos",
      ),
    );
  }
}

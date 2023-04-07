import 'package:flutter/material.dart';
import 'package:my_timetable/pages/add_todo_page.dart';
import 'package:my_timetable/widgets/animate_route.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Todo List"),
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Icon(
              Icons.list,
              color: Colors.white,
              size: 60.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Needs To Implement",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            SlideRightRoute(
              page: const AddTodo(),
            )),
        backgroundColor: Colors.cyan[900],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

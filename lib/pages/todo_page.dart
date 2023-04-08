import 'package:flutter/material.dart';
import 'package:my_timetable/pages/add_todo_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/todo.dart';
import 'package:my_timetable/widgets/animate_route.dart';
import 'package:my_timetable/widgets/styles.dart' show myText;

class TodoList extends StatefulWidget {
  const TodoList({super.key});
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late final DatabaseService _database;

  @override
  void initState() {
    super.initState();
    _database = DatabaseService();
  }

  List<Todo> filterTodos({
    required List<Todo> todos,
    int completed = 0,
  }) {
    return todos.where((todo) => todo.complete == completed).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Todo List"),
        elevation: 0.0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: null,
        child: StreamBuilder(
          stream: _database.allTodos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.cyan,
                ),
              );
            }
            final todos = snapshot.data != null ? [...snapshot.data!] : [];
            if (todos.isEmpty) {
              return emptyTodos();
            }
            final completedTodos = filterTodos(
              todos: todos as List<Todo>,
              completed: 1,
            );
            final notCompletedTodos = filterTodos(todos: todos);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (notCompletedTodos.isNotEmpty)
                  Flexible(
                    child: myListBuilder(notCompletedTodos),
                  ),
                if (completedTodos.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: myText(text: "Completed:"),
                  ),
                  Flexible(
                    flex: 2,
                    child: myListBuilder(completedTodos),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: addTodoButton(context),
    );
  }

  ListView myListBuilder(List<Todo> todos) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        bool completed = todo.complete == 1;
        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          decoration: BoxDecoration(
            color: completed
                ? Colors.grey.withAlpha(50)
                : Colors.cyan.withAlpha(50),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            minVerticalPadding: 10.0,
            onTap: () => Navigator.push(
              context,
              SlideRightRoute(page: const AddTodo(), arguments: todo),
            ),
            title: SizedBox(
              height: 25.0,
              child: Text(
                todo.title,
                style: TextStyle(
                  color: completed ? Colors.grey[700] : Colors.cyan[600],
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  decoration: completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  todo.body.toString().split("\n").join(""),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    decorationThickness: 6.0,
                    color: completed ? Colors.grey[700] : Colors.grey[300],
                    fontSize: 14.0,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  todo.date,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            trailing: Checkbox(
              value: todo.complete != 0,
              onChanged: (value) async {
                await _database.updateTodo(
                    todo: todo.copyWith(complete: todo.complete == 0 ? 1 : 0));
              },
            ),
          ),
        );
      },
    );
  }

  Center emptyTodos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          Icon(
            Icons.work,
            size: 60.0,
            color: Colors.grey,
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Empty Todos",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton addTodoButton(BuildContext context) {
    return FloatingActionButton(
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
    );
  }
}

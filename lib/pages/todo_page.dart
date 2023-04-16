import 'package:flutter/material.dart';
import 'package:my_timetable/pages/add_todo_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/todo.dart';
import 'package:my_timetable/widgets/animate_route.dart'
    show SlideFromBottomTransition, SlideRightRoute;

class TodoList extends StatefulWidget {
  const TodoList({super.key});
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList>
    with SingleTickerProviderStateMixin {
  late final DatabaseService _database;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _database = DatabaseService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _animationController.forward();
  }

  List<Todo> sort({
    required List<Todo> todos,
  }) {
    List<Todo> sortedTodos = todos.toList();
    sortedTodos.sort((a, b) => (a.complete.compareTo(b.complete) != 0)
        ? a.complete.compareTo(b.complete)
        : a.date.compareTo(b.date));
    return sortedTodos;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Todo List"),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(SlideRightRoute(page: const AddTodo()));
              },
              icon: const Icon(
                Icons.add,
              ))
        ],
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
            return Container(
              decoration: null,
              height: double.infinity,
              width: double.infinity,
              child: myListBuilder(sort(todos: todos as List<Todo>)),
            );
          },
        ),
      ),
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
        return FadeTransition(
          opacity: _animation,
          child: SlideFromBottomTransition(
            animation: _animation,
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              decoration: BoxDecoration(
                color: completed
                    ? Colors.grey.withAlpha(50)
                    : Colors.brown.withAlpha(80),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                onTap: () => Navigator.push(
                  context,
                  SlideRightRoute(page: const AddTodo(), arguments: todo),
                ),
                title: SizedBox(
                  height: 25.0,
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      color: completed ? Colors.grey[700] : Colors.brown[300],
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
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      todo.date,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    value: todo.complete != 0,
                    onChanged: (value) async {
                      await _database.updateTodo(
                          todo: todo.copyWith(
                              complete: todo.complete == 0 ? 1 : 0));
                    },
                  ),
                ),
              ),
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
}

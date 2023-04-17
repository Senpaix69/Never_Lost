import 'package:flutter/material.dart';
import 'package:my_timetable/pages/note/add_note_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/todo.dart';
import 'package:my_timetable/utils.dart' show emptyWidget;
import 'package:my_timetable/widgets/animate_route.dart'
    show SlideFromBottomTransition, SlideRightRoute;

class Note extends StatefulWidget {
  const Note({super.key});
  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> with SingleTickerProviderStateMixin {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            SlideRightRoute(
              page: const AddNote(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          size: 30.0,
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
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
                  color: Colors.grey,
                ),
              );
            }
            final todos = snapshot.data != null ? [...snapshot.data!] : [];
            if (todos.isEmpty) {
              return emptyWidget(
                icon: Icons.library_books_outlined,
                message: "Empty Notes",
              );
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
                    : Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                onTap: () => Navigator.push(
                  context,
                  SlideRightRoute(page: const AddNote(), arguments: todo),
                ),
                title: SizedBox(
                  height: 25.0,
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      color: completed ? Colors.grey[700] : Colors.grey[300],
                      fontSize: 16.0,
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
}

import 'package:flutter/material.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/note_services/todo.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/utils.dart' show emptyWidget, getFormattedTime;
import 'package:neverlost/widgets/bottom_sheet.dart';
import 'package:neverlost/widgets/dialog_boxs.dart' show confirmDialogue;

class TodoList extends StatefulWidget {
  const TodoList({super.key});
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList>
    with SingleTickerProviderStateMixin {
  late final DatabaseService _database;
  late final TabController _controller;
  List<Todo> _todos = [];
  double _progress = 0.0;
  bool _needToRefresh = true;

  @override
  void initState() {
    super.initState();
    _database = DatabaseService();
    _controller = TabController(
      length: 2,
      vsync: this,
    );
  }

  Future<bool> deleteTodo(int id) async {
    bool confirmDel = await confirmDialogue(
      context: context,
      message: "Delete this todo?",
      title: "Delete Todo",
    );
    if (confirmDel) {
      await NotificationService.cancelScheduleNotification(id: id);
      await _database.deleteTodo(id: id);
      return true;
    }
    return false;
  }

  Future<void> handleCheckBox(Todo todo) async {
    if (!_needToRefresh) _needToRefresh = true;
    if (todo.complete == 0) {
      await NotificationService.cancelScheduleNotification(id: todo.id!);
    } else if (todo.date != null) {
      final time = DateTime.parse(todo.date!);
      final nowTime = DateTime.now();
      if (time.isAfter(nowTime)) {
        await NotificationService.scheduleNotification(
          scheduleDate: time,
          id: todo.id!,
          title: "Task Reminder",
          body: todo.text,
        );
        await _database.updateTodo(
          todo:
              todo.copyWith(complete: todo.complete == 1 ? 0 : 1, reminder: 0),
        );
        return;
      }
      await _database.updateTodo(
        todo: todo.copyWith(complete: todo.complete == 1 ? 0 : 1, reminder: 1),
      );
      return;
    }
    await _database.updateTodo(
      todo: todo.copyWith(complete: todo.complete == 1 ? 0 : 1),
    );
  }

  List<Todo> filteredTodosAsComplete({
    required List<Todo> todos,
    int complete = 0,
  }) {
    return todos.where((todo) => todo.complete == complete).toList();
  }

  Future<void> setProgress({required List<Todo> todos}) async {
    if (todos.isEmpty) {
      _progress = 1.0;
      return;
    }
    final completedTodos = todos.where((todo) => todo.complete == 1);
    final progress = completedTodos.length / todos.length;
    _progress = progress;

    if (_needToRefresh) {
      await Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {});
      });
      _needToRefresh = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 10.0,
          right: 10.0,
        ),
        decoration: null,
        child: StreamBuilder(
          stream: _database.allTodos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              );
            }
            final todos = snapshot.data!;
            _todos = todos;
            setProgress(todos: todos);
            if (todos.isEmpty) {
              return emptyWidget(
                icon: Icons.checklist_outlined,
                message: "Empty Todos",
              );
            }
            return TabBarView(
              controller: _controller,
              children: <Widget>[
                myGridBuilder(filteredTodosAsComplete(todos: todos)),
                myGridBuilder(
                  filteredTodosAsComplete(todos: todos, complete: 1),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar myAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      toolbarHeight: 0.0,
      bottom: PreferredSize(
        preferredSize: const Size(double.infinity, 100.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(11.0),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: _progress,
                      backgroundColor: Theme.of(context).cardColor,
                      color: Theme.of(context).indicatorColor,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Progress: ${(_progress * 100).toStringAsFixed(1)}%",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Total: ${_todos.length}",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              indicatorWeight: 2.0,
              labelPadding: const EdgeInsets.all(10.0),
              labelStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              controller: _controller,
              unselectedLabelColor: Colors.grey[300],
              labelColor: Colors.grey[200],
              indicatorColor: Theme.of(context).indicatorColor,
              tabs: [
                Text(
                  "Pending",
                  style: TextStyle(color: Theme.of(context).shadowColor),
                ),
                Text(
                  "Completed",
                  style: TextStyle(color: Theme.of(context).shadowColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container myHeading(String message) {
    return Container(
      margin: const EdgeInsets.all(7.0),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget myGridBuilder(List<Todo> todos) {
    if (todos.isEmpty) {
      return emptyWidget(
        icon: Icons.checklist_outlined,
        message: "Empty Todos",
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final timeSchedule = getFormattedTime(todo.date);
        bool isChecked = todo.complete != 0;
        return todoContainer(todo, isChecked, timeSchedule);
      },
    );
  }

  Widget todoContainer(Todo todo, bool isChecked, String? timeSchedule) {
    return GestureDetector(
      onTap: () => _showAddTodoBottomSheet(todo),
      onLongPress: () => deleteTodo(todo.id!),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isChecked
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).cardColor.withAlpha(180),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              todo.text,
              softWrap: true,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isChecked ? Theme.of(context).primaryColor : null,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                decorationThickness: 2.0,
                decorationColor: Theme.of(context).primaryColorDark,
                decoration: isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                margin: const EdgeInsets.all(8.0),
                width: 22.0,
                height: 22.0,
                child: InkWell(
                  onTap: () => handleCheckBox(todo),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      shape: BoxShape.rectangle,
                      color: isChecked
                          ? Theme.of(context).primaryColorDark
                          : Colors.transparent,
                      border: Border.all(
                        color: isChecked
                            ? Theme.of(context).primaryColorDark
                            : Colors.white,
                      ),
                    ),
                    child: isChecked
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 16.0,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              title: Text(
                timeSchedule ?? "Sched Not Set",
                style: TextStyle(
                  fontSize: 12.0,
                  color: todo.reminder == 1 && !isChecked
                      ? Colors.red
                      : Theme.of(context).indicatorColor,
                ),
              ),
              trailing: (todo.date != null && !isChecked && todo.reminder != 1)
                  ? Icon(
                      Icons.alarm_on_sharp,
                      color: Theme.of(context).indicatorColor,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTodoBottomSheet(Todo todo) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) => MyBottomSheet(
        todo: todo,
      ),
    );
  }
}

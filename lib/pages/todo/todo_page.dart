import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/note_services/todo.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/utils.dart' show emptyWidget, getFormattedTime;
import 'package:neverlost/widgets/bottom_sheet.dart';
import 'package:neverlost/widgets/dialog_boxs.dart' show confirmDialogue;

class TodoList extends StatefulWidget {
  final String searchQ;
  const TodoList({super.key, required this.searchQ});
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList>
    with SingleTickerProviderStateMixin {
  late final DatabaseService _database;
  late final TabController _controller;

  List<Todo> _todos = [];
  int _prevLen = 0;
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    if (_needToRefresh || _prevLen != _todos.length) {
      _prevLen = _todos.length;
      _needToRefresh = false;
      await Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {});
      });
    }
  }

  List<Todo> filterTodos(List<Todo> list) {
    final text = widget.searchQ.toLowerCase();
    if (text.isEmpty) {
      return list;
    }

    return list
        .where(
          (todo) => (todo.text.toLowerCase().contains(text)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: myAppBar(context),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.only(
            top: 10.0,
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
                  myGridBuilder(
                    filterTodos(filteredTodosAsComplete(todos: todos)),
                  ),
                  myGridBuilder(
                    filterTodos(
                        filteredTodosAsComplete(todos: todos, complete: 1)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar myAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0.0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 10.0),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GridView.builder(
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
      ),
    );
  }

  Widget todoContainer(Todo todo, bool isChecked, String? timeSchedule) {
    return GestureDetector(
      onTap: () => _showAddTodoBottomSheet(todo),
      onLongPress: () {
        HapticFeedback.vibrate();
        deleteTodo(todo.id!);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).cardColor.withAlpha(120),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                todo.text,
                softWrap: true,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onTap: () => handleCheckBox(todo),
              leading: Container(
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: isChecked
                      ? Theme.of(context).indicatorColor
                      : Colors.transparent,
                  border: Border.all(
                    color: Theme.of(context).indicatorColor,
                  ),
                ),
                child: isChecked
                    ? Center(
                        child: Icon(
                          Icons.check,
                          size: 16.0,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      )
                    : null,
              ),
              title: Text(
                timeSchedule ?? "Sched Not Set",
                style: TextStyle(
                  fontSize: 12.0,
                  color: todo.reminder == 1 && !isChecked
                      ? Colors.red
                      : Theme.of(context).shadowColor,
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

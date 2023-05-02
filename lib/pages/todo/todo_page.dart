import 'package:flutter/material.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note_services/todo.dart';
import 'package:my_timetable/services/notification_service.dart';
import 'package:my_timetable/utils.dart' show emptyWidget, getFormattedTime;
import 'package:my_timetable/widgets/animate_route.dart'
    show SlideFromBottomTransition;
import 'package:my_timetable/widgets/bottom_sheet.dart';
import 'package:my_timetable/widgets/dialog_boxs.dart' show confirmDialogue;

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> deleteTodo(int id) async {
    bool confirmDel =
        await confirmDialogue(context: context, message: "Delete this todo?");
    if (confirmDel) {
      await NotificationService.cancelScheduleNotification(id: id);
      await _database.deleteTodo(id: id);
    }
  }

  Future<void> handleCheckBox(Todo todo) async {
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

  void sortTodosAsComplete(List<Todo> todos) {
    todos.sort(
      (a, b) => a.complete.compareTo(b.complete),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
                  color: Colors.grey,
                ),
              );
            }
            final todos = snapshot.data!;
            if (todos.isEmpty) {
              return emptyWidget(
                icon: Icons.checklist_outlined,
                message: "Empty Todos",
              );
            }
            sortTodosAsComplete(todos);
            return Container(
              decoration: null,
              height: double.infinity,
              width: double.infinity,
              child: myListBuilder(todos),
            );
          },
        ),
      ),
    );
  }

  ListView myListBuilder(List<Todo> todos) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final timeSchedule = getFormattedTime(todo.date);
        return FadeTransition(
          opacity: _animation,
          child: SlideFromBottomTransition(
            animation: _animation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                key: ValueKey(todo.id!),
                onLongPress: () async => await deleteTodo(todo.id!),
                onTap: () => _showAddTodoBottomSheet(todo),
                leading: Checkbox(
                  value: todo.complete != 0,
                  onChanged: (value) => handleCheckBox(todo),
                ),
                title: Text(
                  todo.text,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: todo.complete == 1 ? Colors.grey : Colors.grey[200],
                    fontSize: 16.0,
                    decorationThickness: 6.0,
                    decoration:
                        todo.complete == 1 ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '${todo.reminder == 1 ? "Passed: " : "Reminder: "}${timeSchedule ?? "Not Set"}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: todo.reminder == 1 && todo.complete == 0
                        ? Colors.redAccent
                        : Colors.grey,
                  ),
                ),
                trailing: (todo.date != null &&
                        todo.complete != 1 &&
                        todo.reminder != 1)
                    ? const Icon(
                        Icons.alarm_on_sharp,
                        color: Colors.lightBlue,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
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

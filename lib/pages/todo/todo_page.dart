import 'package:flutter/material.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/note_services/todo.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/utils.dart' show emptyWidget, getFormattedTime;
import 'package:neverlost/widgets/animate_route.dart'
    show SlideFromBottomTransition;
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
      ((a, b) => a.complete.compareTo(b.complete)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            if (todos.isEmpty) {
              return emptyWidget(
                icon: Icons.checklist_outlined,
                message: "Empty Todos",
              );
            }
            sortTodosAsComplete(todos);
            return myListBuilder(todos);
          },
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

  ListView myListBuilder(List<Todo> todos) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final timeSchedule = getFormattedTime(todo.date);
        bool isChecked = todo.complete != 0;
        return FadeTransition(
          opacity: _animation,
          child: SlideFromBottomTransition(
            animation: _animation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: isChecked
                    ? Theme.of(context).focusColor
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: todoTile(
                todo,
                isChecked,
                timeSchedule,
              ),
            ),
          ),
        );
      },
    );
  }

  ListTile todoTile(Todo todo, bool isChecked, String? timeSchedule) {
    return ListTile(
      key: ValueKey(todo.id!),
      onLongPress: () async => await deleteTodo(todo.id!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      onTap: () => _showAddTodoBottomSheet(todo),
      leading: Container(
        margin: const EdgeInsets.all(8.0),
        width: 24.0,
        height: 24.0,
        child: InkWell(
          onTap: () => handleCheckBox(todo),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              shape: BoxShape.rectangle,
              color:
                  isChecked ? Theme.of(context).focusColor : Colors.transparent,
              border: Border.all(
                color: isChecked ? Theme.of(context).focusColor : Colors.white,
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
        todo.text,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color:
              isChecked ? Theme.of(context).colorScheme.inversePrimary : null,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          decorationThickness: 2.0,
          decoration: isChecked ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        '${todo.reminder == 1 ? "Passed: " : "Reminder: "}${timeSchedule ?? "Not Set"}',
        style: TextStyle(
          fontSize: 12.0,
          color: todo.reminder == 1 && !isChecked
              ? Colors.red
              : Theme.of(context).primaryColorDark,
        ),
      ),
      trailing: (todo.date != null && !isChecked && todo.reminder != 1)
          ? Icon(
              Icons.alarm_on_sharp,
              color: Theme.of(context).focusColor,
            )
          : null,
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

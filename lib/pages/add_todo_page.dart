import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/todo.dart';
import 'package:my_timetable/utils.dart' show GetArgument, textValidate;
import 'package:my_timetable/widgets/dialog_boxs.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({super.key});
  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  late final DatabaseService _database;
  late final TextEditingController _title;
  late final TextEditingController _body;
  Todo? isTodo;
  final _formKey = GlobalKey<FormState>();

  String _date() {
    final DateFormat formatter = DateFormat('EEEE MMMM d hh:mm a', 'en_US');
    return formatter.format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _database = DatabaseService();
    _title = TextEditingController();
    _body = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => setArgument());
    });
  }

  void setArgument() {
    final widgetTable = context.getArgument<Todo>();
    if (widgetTable != null) {
      _title.text = widgetTable.title;
      _body.text = widgetTable.body;
      isTodo = widgetTable;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> saveTodo() async {
    if (_formKey.currentState!.validate()) {
      final todo = Todo(
        title: _title.text,
        body: _body.text,
        date: isTodo != null ? isTodo!.date : _date(),
      );

      if (isTodo != null) {
        await _database.updateTodo(
          todo: todo.copyWith(
            id: isTodo!.id,
            complete: isTodo!.complete,
          ),
        );
      } else {
        await _database.insertTodo(todo: todo);
      }
      Future.delayed(
        const Duration(milliseconds: 100),
        () => Navigator.of(context).pop(),
      );
    }
  }

  Future<void> deleteTodo() async {
    bool isDel = await confirmDialogue(
        context: context, message: "Do you really want to delete this todo?");
    if (isDel && isTodo != null) {
      await _database.deleteTodo(id: isTodo!.id!);
      Future.delayed(
        const Duration(milliseconds: 100),
        () => Navigator.of(context).pop(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(isTodo != null ? "Edit Todo" : "Add Todo"),
        elevation: 0.0,
        actions: <Widget>[
          isTodo != null
              ? IconButton(
                  onPressed: () => deleteTodo(),
                  icon: const Icon(
                    Icons.delete,
                  ),
                )
              : const SizedBox(),
          IconButton(
            onPressed: () => saveTodo(),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          decoration: null,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        hintText: 'Title',
                      ),
                      controller: _title,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      validator: textValidate,
                    ),
                    Text(
                      isTodo != null ? isTodo!.date : _date(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        hintText: 'write todo here...',
                      ),
                      controller: _body,
                      validator: textValidate,
                      style: TextStyle(
                        fontSize: 15.0,
                        letterSpacing: 0.3,
                        color: Colors.grey[300],
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

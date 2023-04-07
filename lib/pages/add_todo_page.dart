import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({super.key});
  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  final _formKey = GlobalKey<FormState>();

  String _date() {
    final DateFormat formatter = DateFormat('EEEE MMMM d hh:mm a', 'en_US');
    return formatter.format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _body = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Add Todo"),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
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
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        hintText: 'Title',
                      ),
                      controller: _title,
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      _date(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Divider(
                      height: 20.0,
                      color: Colors.grey[900],
                    ),
                    TextFormField(
                      enableSuggestions: false,
                      autocorrect: false,
                      autofocus: true,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        hintText: 'write todo here...',
                      ),
                      controller: _body,
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note.dart';
import 'package:my_timetable/utils.dart' show GetArgument, textValidate;
import 'package:my_timetable/widgets/dialog_boxs.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});
  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late final DatabaseService _database;
  late final TextEditingController _title;
  late final TextEditingController _body;
  Note? _isNote;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

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
    final widgetTable = context.getArgument<Note>();
    if (widgetTable != null) {
      _title.text = widgetTable.title;
      _body.text = widgetTable.body;
      _isNote = widgetTable;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> saveNote() async {
    if (_formKey.currentState!.validate()) {
      final todo = Note(
        title: _title.text,
        body: _body.text,
        date: _isNote != null ? _isNote!.date : _date(),
      );

      if (_isNote != null) {
        await _database.updateNote(
          note: todo.copyWith(
            id: _isNote!.id,
          ),
        );
      } else {
        await _database.insertNote(note: todo);
      }
      Future.delayed(
        const Duration(milliseconds: 100),
        () => Navigator.of(context).pop(),
      );
    }
  }

  Future<void> deleteNote() async {
    bool isDel = await confirmDialogue(
        context: context, message: "Do you really want to delete this todo?");
    if (isDel && _isNote != null) {
      await _database.deleteNote(id: _isNote!.id!);
      Future.delayed(
        const Duration(milliseconds: 100),
        () => Navigator.of(context).pop(),
      );
    }
  }

  void backPage() async {
    if (_isEditing) {
      bool isChanges = await confirmDialogue(
        context: context,
        message: "Some changes have done do you want to save them?",
      );
      if (isChanges) {
        await saveNote();
        return;
      }
    }
    Future.delayed(
      const Duration(milliseconds: 50),
      () => Navigator.of(context).pop(),
    );
  }

  void checkNote(String value) {
    if (_isNote != null &&
        (_isNote!.title == _title.text && _isNote!.body == _body.text)) {
      if (_isEditing) setState(() => _isEditing = false);
      return;
    }
    if (_title.text.isNotEmpty || _body.text.isNotEmpty) {
      if (!_isEditing) setState(() => _isEditing = true);
      return;
    }
    if (_isEditing) setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => backPage(),
        ),
        backgroundColor: Colors.transparent,
        title: Text(_isNote != null ? "Edit Note" : "Add Note"),
        elevation: 0.0,
        actions: <Widget>[
          if (_isNote != null)
            IconButton(
              onPressed: () => deleteNote(),
              icon: const Icon(
                Icons.delete,
              ),
            ),
          if (_isEditing)
            IconButton(
              onPressed: () => saveNote(),
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
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
                      onChanged: checkNote,
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
                      _isNote != null ? _isNote!.date : _date(),
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
                      onChanged: checkNote,
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
                    const SizedBox(
                      height: 100,
                    ),
                    insertImage(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

Padding insertImage() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: DottedBorder(
      color: const Color.fromARGB(255, 76, 76, 76),
      strokeWidth: 2,
      borderType: BorderType.RRect,
      dashPattern: const [3, 4],
      radius: const Radius.circular(20.0),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Center(
          child: Text(
            "Insert Image",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    ),
  );
}

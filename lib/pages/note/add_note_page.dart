import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_timetable/pages/note/image_preview_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note_services/note.dart';
import 'package:my_timetable/utils.dart' show GetArgument, textValidate;
import 'package:my_timetable/widgets/dialog_boxs.dart' show confirmDialogue;
import 'package:path_provider/path_provider.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});
  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late final DatabaseService _database;
  late final TextEditingController _title;
  late final TextEditingController _body;
  List<String> _files = [];
  final FocusNode _focusTitle = FocusNode();
  final FocusNode _focusText = FocusNode();

  Note? _isNote;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  String _date() {
    final DateFormat formatter = DateFormat('EEEE MMMM d hh:mm a', 'en_US');
    return formatter.format(DateTime.now());
  }

  void addFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().toIso8601String()}_${file.name}';
      final copyPath = '${appDir.path}/$fileName';
      await File(file.path!).copy(copyPath);
      setState(
        () {
          if (_isNote != null) {
            _files = [..._isNote!.files, copyPath];
          } else {
            _files.add(copyPath);
          }

          _isEditing = true;
        },
      );
      if (_isNote != null) {
        await _database.updateNote(note: _isNote!.copyWith(files: _files));
        _isNote = _isNote!.copyWith(files: _files);
      }
    }
  }

  Future<void> deleteFile(String path, int index) async {
    bool del = await confirmDialogue(
        context: context, message: "Do you want to delete this file?");
    if (!del) return;
    setState(
      () {
        _files.removeAt(index);
        _isEditing = true;
      },
    );
    await File(path).delete();
    if (_isNote != null) {
      await _database.updateNote(note: _isNote!.copyWith(files: _files));
      _isNote = _isNote!.copyWith(files: _files);
    }
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
      _files = widgetTable.files;
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
    bool updateNote = _isNote != null;
    if (_formKey.currentState!.validate()) {
      final todo = Note(
        title: _title.text,
        body: _body.text,
        imp: updateNote ? _isNote!.imp : 0,
        date: updateNote ? _isNote!.date : _date(),
        category: updateNote ? _isNote!.category : "",
        files: updateNote ? _isNote!.files : _files,
      );

      if (updateNote) {
        await _database.updateNote(
          note: todo.copyWith(
            id: _isNote!.id,
          ),
        );
      } else {
        await _database.insertNote(note: todo);
      }
      _focusTitle.unfocus();
      _focusText.unfocus();
      setState(() => _isEditing = false);
    }
  }

  Future<void> deleteNote() async {
    bool isDel = await confirmDialogue(
        context: context, message: "Do you really want to delete this todo?");
    if (isDel && _isNote != null) {
      for (int i = 0; i < _files.length; i++) {
        await File(_files[i]).delete();
      }
      await _database.deleteNote(id: _isNote!.id!);
      goBack();
    }
  }

  void goBack() => Navigator.of(context).pop();

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
    goBack();
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
    return WillPopScope(
      onWillPop: () async => _files.isNotEmpty && _title.text.isEmpty,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: myAppBar(),
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
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
                      focusNode: _focusTitle,
                      onChanged: checkNote,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLines: null,
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
                      focusNode: _focusText,
                      onChanged: checkNote,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        hintText: 'write note here...',
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
                      height: 20.0,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _files.length,
                      itemBuilder: (BuildContext context, int index) {
                        final file = File(_files[index]);
                        final basename = file.path.split('/').last;
                        return Card(
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child:
                                    file.path.toLowerCase().endsWith('.png') ||
                                            file.path
                                                .toLowerCase()
                                                .endsWith('.jpg') ||
                                            file.path
                                                .toLowerCase()
                                                .endsWith('.jpeg')
                                        ? imagesTile(context, index, file)
                                        : files(basename, index, file),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InkWell imagesTile(BuildContext context, int index, File file) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(
            imagePaths: _files,
            currentIndex: index,
          ),
        ),
      ),
      onLongPress: () async => await deleteFile(file.path, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.file(
          file,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  ListTile files(String basename, int index, File file) {
    return ListTile(
      leading: Icon(
        Icons.file_open_rounded,
        color: Colors.grey[200],
      ),
      title: Text(basename),
      trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async => await deleteFile(file.path, index)),
    );
  }

  AppBar myAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => backPage(),
      ),
      backgroundColor: Colors.transparent,
      title: Text(_isNote != null ? "Edit Note" : "Add Note"),
      elevation: 0.0,
      actions: <Widget>[
        IconButton(
          onPressed: () => addFile(),
          icon: const Icon(Icons.attachment),
        ),
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
        if (!_isEditing)
          const SizedBox(
            width: 10,
          ),
      ],
    );
  }
}

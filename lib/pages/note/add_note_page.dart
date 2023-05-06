import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_timetable/services/database.dart';
import 'package:path/path.dart' as path show basename;
import 'package:my_timetable/pages/note/image_preview_page.dart';
import 'package:my_timetable/services/note_services/note.dart';
import 'package:my_timetable/utils.dart'
    show GetArgument, textValidate, showSnackBar, removeEmptyFilesAndImages;
import 'package:my_timetable/widgets/animate_route.dart' show FadeRoute;
import 'package:my_timetable/widgets/dialog_boxs.dart' show confirmDialogue;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:permission_handler/permission_handler.dart';

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
  List<String> _images = [];
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
    if (!await requestPermission()) {
      showMessage("Storage Permission Denied");
      return;
    }
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      final appDir = await getApplicationDocumentsDirectory();
      final newImages = <String>[];
      final newFiles = <String>[];
      for (final file in result.files) {
        final fileName = '${DateTime.now().toIso8601String()}_${file.name}';
        final copyPath = '${appDir.path}/$fileName';
        if (file.extension!.toLowerCase() == 'png' ||
            file.extension!.toLowerCase() == 'jpg' ||
            file.extension!.toLowerCase() == 'jpeg') {
          await File(file.path!).copy(copyPath);
          newImages.add(copyPath);
        } else if (file.extension!.toLowerCase() != 'mp4' &&
            file.extension!.toLowerCase() != 'mkv') {
          await File(file.path!).copy(copyPath);
          newFiles.add(copyPath);
        } else {
          showMessage("You can not select video file");
        }
      }
      setState(
        () {
          _images = [..._images, ...newImages];
          _files = [..._files, ...newFiles];
          _isEditing = true;
        },
      );
      if (_isNote != null) {
        await _database.updateNote(
          note: _isNote!.copyWith(
            images: _images,
            files: _files,
          ),
        );
        _isNote = _isNote!.copyWith(images: _images, files: _files);
      }
    }
  }

  void showMessage(String message) => showSnackBar(context, message);

  Future<bool> requestPermission() async {
    final status = await Permission.manageExternalStorage.status;
    if (status.isPermanentlyDenied || status.isDenied) {
      final res = await Permission.storage.request();
      if (res.isDenied) {
        return false;
      }
    }
    return true;
  }

  Future<void> downloadFile(File file, String basename) async {
    final externalDir = Directory("/storage/emulated/0/Download");
    if (externalDir.existsSync() && await requestPermission()) {
      final fileName = file.path.split('_').last;
      final newPath = '${externalDir.path}/$fileName';
      await file.copy(newPath);
      showMessage("Downloaded File Successfully");
    } else {
      showMessage("Permission Denied");
    }
  }

  Future<void> deleteFile(String path, int index, String type) async {
    bool del = await confirmDialogue(
      context: context,
      message: "Do you want to delete this file?",
      title: "Delete File",
    );
    if (!del) return;
    setState(
      () {
        type == "image" ? _images.removeAt(index) : _files.removeAt(index);
        _isEditing = true;
      },
    );
    final file = File(path);
    if (!file.existsSync()) {
      showMessage("Could not delete file");
      return;
    }
    file.delete();
    if (_isNote == null) return;
    if (type == "image") {
      await _database.updateNote(note: _isNote!.copyWith(images: _images));
      _isNote = _isNote!.copyWith(images: _images);
      return;
    }
    await _database.updateNote(note: _isNote!.copyWith(files: _files));
    _isNote = _isNote!.copyWith(files: _files);
  }

  Future<void> deleteAllFiles() async {
    for (int i = 0; i < _files.length; i++) {
      final file = File(_files[i]);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    for (int i = 0; i < _images.length; i++) {
      final file = File(_images[i]);
      if (file.existsSync()) {
        await file.delete();
      }
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
      _files = removeEmptyFilesAndImages(widgetTable.files);
      _images = removeEmptyFilesAndImages(widgetTable.images);
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
      final note = Note(
        title: _title.text,
        body: _body.text,
        imp: updateNote ? _isNote!.imp : 0,
        date: updateNote ? _isNote!.date : _date(),
        category: updateNote ? _isNote!.category : "",
        files: updateNote ? _isNote!.files : _files,
        images: updateNote ? _isNote!.images : _images,
      );
      if (updateNote) {
        await _database.updateNote(
          note: note.copyWith(
            id: _isNote!.id,
          ),
        );
      } else {
        await _database.insertNote(note: note);
      }
      _focusTitle.unfocus();
      _focusText.unfocus();
      setState(() => _isEditing = false);
    }
  }

  Future<void> deleteNote() async {
    bool isDel = await confirmDialogue(
      context: context,
      message: "Do you really want to delete this todo?",
      title: "Delete Note",
    );
    if (isDel && _isNote != null) {
      await deleteAllFiles();
      await _database.deleteNote(id: _isNote!.id!);
      goBack();
    }
  }

  void goBack() => Navigator.of(context).pop();

  void backPage() async {
    if (_isEditing) {
      bool isChanges = await confirmDialogue(
        title: "Unsaved changes",
        context: context,
        message: "Some changes have done do you want to save them?",
      );
      if (isChanges) {
        await saveNote();
        return;
      } else if (_isNote == null && (_files.isNotEmpty || _images.isNotEmpty)) {
        await deleteAllFiles();
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
      onWillPop: () async => !_isEditing,
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
                    imageBuilder(),
                    const Divider(
                      height: 20,
                    ),
                    filesBuilder(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget imageBuilder() {
    if (_images.isEmpty) {
      return const SizedBox();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _images.length,
      itemBuilder: (BuildContext context, int index) {
        final image = File(_images[index]);
        return Card(
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: imagesTile(context, index, image),
              ),
            ],
          ),
        );
      },
    );
  }

  InkWell imagesTile(BuildContext context, int index, File file) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        FadeRoute(
          page: ImagePreviewScreen(
            imagePaths: _images,
            currentIndex: index,
          ),
        ),
      ),
      onLongPress: () async => await deleteFile(file.path, index, "image"),
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

  Widget filesBuilder() {
    if (_files.isEmpty) {
      return const SizedBox();
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _files.length,
      separatorBuilder: (context, index) => const Divider(
        height: 10.0,
      ),
      itemBuilder: (context, index) {
        final file = File(_files[index]);
        return filesTile(path.basename(file.path).split('_').last, index, file);
      },
    );
  }

  ListTile filesTile(String basename, int index, File file) {
    return ListTile(
      key: ValueKey(index),
      minVerticalPadding: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Colors.lightBlue.withAlpha(90),
      leading: Icon(
        Icons.file_open_rounded,
        color: Colors.grey[200],
      ),
      title: Text(
        basename,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async =>
                  await deleteFile(file.path, index, "file")),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async => await downloadFile(file, basename),
          ),
        ],
      ),
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

import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:intl/intl.dart' show DateFormat;
import 'package:neverlost/pages/note/folder_page.dart';
import 'package:neverlost/pages/note/image_preview_page.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/widgets/animate_route.dart';
import 'package:neverlost/widgets/styles.dart' show mySheetIcon;
import 'package:open_file_plus/open_file_plus.dart' show OpenFile;
import 'package:neverlost/services/note_services/note.dart';
import 'package:neverlost/utils.dart'
    show
        GetArgument,
        deleteAllFiles,
        removeEmptyFilesAndImages,
        showSnackBar,
        textValidate;
import 'package:neverlost/widgets/dialog_boxs.dart' show confirmDialogue;
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
  Note? _tempNote;
  bool _isTempNote = false;
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
        } else if (file.extension!.toLowerCase() == 'docx' ||
            file.extension!.toLowerCase() == 'pdf') {
          await File(file.path!).copy(copyPath);
          newFiles.add(copyPath);
        } else {
          showMessage(
            "Invalid file type, you can only select {image, pdf, docx}",
          );
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

  Future<void> deleteFile(String path, int index, String type) async {
    bool del = await confirmDialogue(
      context: context,
      title: path.split('_').last,
      message: "Do you want to delete this file?",
    );
    if (!del) return;
    final file = File(path);
    if (!file.existsSync()) {
      showMessage("Could not delete file");
      return;
    }
    await file.delete();
    type == "image" ? _images.removeAt(index) : _files.removeAt(index);
    if (_isNote == null) {
      setState(() {});
      return;
    }
    if (type == "image") {
      await _database.updateNote(note: _isNote!.copyWith(images: _images));
      _isNote = _isNote!.copyWith(images: _images);
    } else {
      await _database.updateNote(note: _isNote!.copyWith(files: _files));
      _isNote = _isNote!.copyWith(files: _files);
    }
    _isEditing = true;
    hideBottomSheet();
    setState(() {});
  }

  void hideBottomSheet() => Navigator.of(context).pop();

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
        category: updateNote
            ? _isNote!.category
            : _isTempNote
                ? _tempNote!.category
                : "",
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
        _isNote = await _database.insertNote(note: note);
      }
      _focusTitle.unfocus();
      _focusText.unfocus();
      setState(() => _isEditing = false);
    }
  }

  Future<void> deleteNote() async {
    bool isDel = await confirmDialogue(
      context: context,
      message: "Do you really want to delete this note?",
      title: "Delete Note",
    );
    if (isDel && _isNote != null) {
      await deleteAllFiles(files: _files, images: _images);
      await _database.deleteNote(id: _isNote!.id!);
      if (_isTempNote) {
        await _database.deleteNote(id: _tempNote!.id!);
      }
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
        await deleteAllFiles(files: _files, images: _images);
      }
    }
    if (_isTempNote) {
      await _database.deleteNote(id: _tempNote!.id!);
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            focusNode: _focusTitle,
                            onChanged: checkNote,
                            enableSuggestions: false,
                            autocorrect: false,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Title',
                            ),
                            controller: _title,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            validator: textValidate,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          _isNote != null
                              ? _isNote!.category
                              : _isTempNote
                                  ? _tempNote!.category
                                  : "catagory",
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 12.0,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _isNote != null ? _isNote!.date : _date(),
                      style: const TextStyle(
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
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'write note here...',
                      ),
                      controller: _body,
                      validator: textValidate,
                      style: const TextStyle(
                        fontSize: 15.0,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    imageBuilder(),
                    const SizedBox(
                      height: 10.0,
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
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(
            imagePaths: _images,
            currentIndex: index,
          ),
        ),
      ),
      onLongPress: () => myBottomSheet(
        color1: const Color(0xFF0077B5),
        text1: "Share",
        icon1: Icons.share,
        callback1: () {},
        color2: const Color(0xFFFF0000),
        icon2: Icons.delete,
        text2: "Delete",
        callback2: () async => await deleteFile(file.path, index, "image"),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = File(_files[index]);
        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: 5.0,
          ),
          child: filesTile(file.path.split('_').last, index, file),
        );
      },
    );
  }

  ListTile filesTile(String basename, int index, File file) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      key: ValueKey(index),
      minVerticalPadding: 20,
      onTap: () => OpenFile.open(file.path),
      onLongPress: () => myBottomSheet(
        color1: const Color(0xFF0077B5),
        text1: "Share",
        icon1: Icons.share,
        callback1: () {},
        color2: const Color(0xFFFF0000),
        icon2: Icons.delete,
        text2: "Delete",
        callback2: () async => await deleteFile(file.path, index, "file"),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Theme.of(context).primaryColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Icon(
          Icons.file_open_rounded,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      title: Text(
        basename,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<dynamic> myBottomSheet({
    required String text1,
    required Color color1,
    required IconData icon1,
    required String text2,
    required Color color2,
    required IconData icon2,
    required VoidCallback callback1,
    required VoidCallback callback2,
  }) {
    HapticFeedback.vibrate();
    return showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 130.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              mySheetIcon(
                backgroundColor: color1,
                title: text1,
                context: context,
                icon: icon1,
                callback: () {
                  Navigator.of(context).pop();
                  callback1();
                },
              ),
              mySheetIcon(
                backgroundColor: color2,
                title: text2,
                context: context,
                icon: icon2,
                callback: () {
                  Navigator.of(context).pop();
                  callback2();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void setCatagory({required String catagory, required String stateNote}) {
    if (stateNote == "tempNote") {
      _tempNote = _tempNote!.copyWith(category: catagory);
    } else {
      _isNote = _isNote!.copyWith(category: catagory);
    }
    setState(() {});
  }

  void goToFolderPage({required Note note, required String stateNote}) =>
      Navigator.of(context).push(
        SlideRightRoute(
          page: FolderPage(
            callback: (value) => setCatagory(
              catagory: value,
              stateNote: stateNote,
            ),
          ),
          arguments: note,
        ),
      );

  AppBar myAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => backPage(),
      ),
      title: Text(
        _isNote != null
            ? _isEditing
                ? "Edit Note"
                : "Note"
            : "Add Note",
      ),
      elevation: 0.0,
      actions: <Widget>[
        IconButton(
          onPressed: () async {
            if (_isNote == null) {
              _tempNote ??= const Note(
                title: "temp",
                body: "temp",
                date: "temp",
              );
              if (!_isTempNote) {
                _tempNote = await _database.insertNote(note: _tempNote!);
                _isTempNote = true;
              }
              goToFolderPage(note: _tempNote!, stateNote: "tempNote");
              return;
            }
            goToFolderPage(note: _isNote!, stateNote: "note");
          },
          icon: const Icon(
            Icons.drive_file_move,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () => myBottomSheet(
            text1: "Camera",
            color1: Colors.blueAccent,
            icon1: Icons.camera,
            callback1: () {},
            text2: "Gallary",
            color2: Colors.pink,
            icon2: Icons.photo,
            callback2: addFile,
          ),
          icon: const Icon(
            Icons.attachment,
            color: Colors.white,
          ),
        ),
        if (_isNote != null)
          IconButton(
            onPressed: () => deleteNote(),
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        if (_isEditing)
          IconButton(
            onPressed: () => saveNote(),
            icon: const Icon(Icons.check, color: Colors.white),
          ),
        if (!_isEditing)
          const SizedBox(
            width: 10,
          ),
      ],
    );
  }
}

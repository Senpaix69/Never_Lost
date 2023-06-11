import 'package:flutter/material.dart';
import 'package:neverlost/pages/note/add_note_page.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:neverlost/pages/note/folder_page.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/note_services/note.dart';
import 'package:neverlost/utils.dart'
    show deleteAllFiles, deleteFolder, emptyWidget, removeEmptyFilesAndImages;
import 'package:neverlost/widgets/animate_route.dart'
    show SlideFromBottomTransition, SlideRightRoute;
import 'package:neverlost/widgets/dialog_boxs.dart' show confirmDialogue;
import 'package:neverlost/widgets/folder_button.dart';
import 'package:neverlost/widgets/styles.dart' show mySheetIcon;

class NoteList extends StatefulWidget {
  final String searchQ;
  const NoteList({
    super.key,
    required this.searchQ,
  });
  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList>
    with SingleTickerProviderStateMixin {
  late final DatabaseService _database;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _folderName = "";

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

  List<Note> sort({
    required List<Note> notes,
  }) {
    List<Note> sortedNotes = notes.toList();
    sortedNotes.sort((a, b) => b.date.compareTo(a.date));
    sortedNotes.sort((a, b) => b.imp.compareTo(a.imp));
    return sortedNotes;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Note> filterNotes(List<Note> list) {
    final text = widget.searchQ.toLowerCase();
    if (text.isEmpty && _folderName.isEmpty) {
      return list;
    }

    if (text.isNotEmpty) {
      return list
          .where(
            (note) => (note.title.toLowerCase().contains(text) ||
                (note.body.toLowerCase().contains(text) ||
                    (note.category.toLowerCase().contains(text)))),
          )
          .toList();
    }

    return list.where((note) => note.category == _folderName).toList();
  }

  Future<void> deleteNote({required Note note}) async {
    bool isDel = await confirmDialogue(
      context: context,
      message: "Do you really want to delete this note?",
      title: "Delete Note",
    );
    if (isDel) {
      await deleteAllFiles(files: note.files, images: note.images);
      await _database.deleteNote(id: note.id!);
    }
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
          height: double.infinity,
          padding: const EdgeInsets.only(top: 10.0),
          decoration: null,
          child: StreamBuilder(
            stream: _database.allNotes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }
              final notes = filterNotes(snapshot.data!);
              if (notes.isEmpty) {
                return emptyWidget(
                  icon: Icons.library_books_outlined,
                  message: "Empty Notes",
                );
              }
              return myListBuilder(notes);
            },
          ),
        ),
      ),
    );
  }

  void selectFolder({required String folder}) {
    if (_folderName != folder) {
      setState(() => _folderName = folder);
    }
  }

  void delFolder({required final folder}) async {
    bool del = await deleteFolder(folder, context);
    if (del) {
      await _database.removeFolder(id: folder.id!);
    }
  }

  AppBar myAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              folderBuilder(context),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _folderName.isEmpty ? "All Notes" : _folderName,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context).primaryColorLight,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              Navigator.of(context).push(SlideRightRoute(
                            page: const FolderPage(),
                          )),
                          icon: Icon(
                            Icons.folder_special_rounded,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                      ),
                      FolderButton(
                        activeFolder: true,
                        selectFolder: () {},
                        folderName: "Filter 🧻",
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget folderBuilder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            FolderButton(
              selectFolder: () => selectFolder(folder: ''),
              folderName: '',
              activeFolder: _folderName == '',
            ),
            StreamBuilder(
              stream: _database.allFolder,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                final folders = snapshot.data!;
                return SizedBox(
                  height: 40,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: folders.length,
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        return FolderButton(
                          selectFolder: () => selectFolder(folder: folder.name),
                          folderName: folder.name,
                          activeFolder: _folderName == folder.name,
                          deleteFolder: () => delFolder(folder: folder),
                        );
                      }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ListView myListBuilder(List<Note> notes) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return FadeTransition(
          opacity: _animation,
          child: SlideFromBottomTransition(
            animation: _animation,
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withAlpha(120),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                onLongPress: () => myBottomSheet(
                  important: note.imp,
                  moveToCallback: () {
                    Future.delayed(
                      const Duration(milliseconds: 200),
                      () => Navigator.of(context).push(
                        SlideRightRoute(
                          page: const FolderPage(),
                          arguments: note,
                        ),
                      ),
                    );
                  },
                  shareCallback: () {},
                  importantCallback: () async {
                    await _database.updateNote(
                      note: note.copyWith(imp: note.imp == 0 ? 1 : 0),
                    );
                  },
                  deleteCallback: () async => await deleteNote(note: note),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                key: ValueKey(note.id!),
                minVerticalPadding: 15,
                onTap: () => Navigator.push(
                  context,
                  SlideRightRoute(
                    page: const AddNote(),
                    arguments: note,
                  ),
                ),
                title: listTitle(note),
                subtitle: listSubTitle(note),
              ),
            ),
          ),
        );
      },
    );
  }

  Padding listSubTitle(Note note) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            note.body.toString().split("\n").join(" "),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14.0),
          ),
          const SizedBox(height: 6.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                note.date,
                style: const TextStyle(
                  fontSize: 10.0,
                ),
              ),
              Row(
                children: <Widget>[
                  if (removeEmptyFilesAndImages(note.files).isNotEmpty ||
                      removeEmptyFilesAndImages(note.images).isNotEmpty)
                    Icon(
                      Icons.attachment_outlined,
                      size: 20.0,
                      color: Theme.of(context).indicatorColor,
                    ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  if (note.imp != 0)
                    Icon(
                      Icons.star,
                      color: Theme.of(context).indicatorColor,
                      size: 20.0,
                    ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Row listTitle(Note note) {
    String title = note.title.split("\n").join(" ");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_folderName.isEmpty && note.category.isNotEmpty)
          Text(
            note.category,
            style: TextStyle(
              fontSize: 12.0,
              color: Theme.of(context).indicatorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Future<dynamic> myBottomSheet({
    int important = 0,
    required VoidCallback shareCallback,
    required VoidCallback moveToCallback,
    required VoidCallback importantCallback,
    required VoidCallback deleteCallback,
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
                backgroundColor: Colors.blueGrey,
                context: context,
                title: "Move To",
                icon: Icons.drive_file_move,
                callback: () {
                  Navigator.of(context).pop();
                  moveToCallback();
                },
              ),
              mySheetIcon(
                backgroundColor: Colors.amber,
                context: context,
                title: important == 1 ? "Not Imp" : "Important",
                icon: important == 1 ? Icons.star : Icons.star_border,
                callback: () {
                  Navigator.of(context).pop();
                  importantCallback();
                },
              ),
              mySheetIcon(
                backgroundColor: const Color(0xFF0077B5),
                context: context,
                title: "Share",
                icon: Icons.share,
                callback: () {
                  Navigator.of(context).pop();
                  shareCallback();
                },
              ),
              mySheetIcon(
                backgroundColor: const Color(0xFFFF0000),
                context: context,
                title: "Delete",
                icon: Icons.delete,
                callback: () {
                  Navigator.of(context).pop();
                  deleteCallback();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

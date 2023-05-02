import 'package:flutter/material.dart';
import 'package:my_timetable/pages/note/add_note_page.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:my_timetable/pages/note/folder_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note_services/note.dart';
import 'package:my_timetable/utils.dart' show emptyWidget, deleteFolder;
import 'package:my_timetable/widgets/animate_route.dart'
    show SlideFromBottomTransition, SlideRightRoute;

class NoteList extends StatefulWidget {
  const NoteList({super.key});
  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList>
    with SingleTickerProviderStateMixin {
  late final DatabaseService _database;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset _tapPosition = Offset.zero;
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
    if (_folderName.isEmpty) {
      return list;
    }
    return list.where((note) => note.category == _folderName).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: _folderName.isEmpty
                          ? MaterialStateColor.resolveWith(
                              (states) => Colors.blue,
                            )
                          : MaterialStateColor.resolveWith(
                              (states) => Colors.black.withAlpha(100),
                            ),
                    ),
                    child: Text(
                      "All",
                      style: TextStyle(
                        color: _folderName.isEmpty
                            ? Colors.white
                            : Colors.grey[200],
                        fontWeight: _folderName.isEmpty
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onPressed: () => setState(() => _folderName = ""),
                  ),
                ),
                StreamBuilder(
                  stream: _database.allFolder,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    final folders = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: folders.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: ElevatedButton(
                          onLongPress: () async {
                            final folder = folders[index];
                            bool del = await deleteFolder(folder, context);
                            if (del) {
                              await _database.removeFolder(id: folder.id!);
                            }
                          },
                          key: ValueKey(folders[index].id),
                          style: ButtonStyle(
                            backgroundColor: _folderName == folders[index].name
                                ? MaterialStateColor.resolveWith(
                                    (states) => Colors.blue,
                                  )
                                : MaterialStateColor.resolveWith(
                                    (states) => Colors.black.withAlpha(100),
                                  ),
                          ),
                          child: Text(
                            folders[index].name,
                            style: TextStyle(
                              color: _folderName == folders[index].name
                                  ? Colors.white
                                  : Colors.grey[200],
                              fontWeight: _folderName == folders[index].name
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          onPressed: () =>
                              setState(() => _folderName = folders[index].name),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(SlideRightRoute(
                      page: const FolderPage(),
                    )),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.black.withAlpha(100),
                      ),
                    ),
                    icon: Icon(
                      Icons.create_new_folder_sharp,
                      color: Colors.grey[300],
                    ),
                    label: Text(
                      "Add Folder",
                      style: TextStyle(
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10.0),
        decoration: null,
        child: StreamBuilder(
          stream: _database.allNotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
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
            return Container(
              decoration: null,
              height: double.infinity,
              width: double.infinity,
              child: myListBuilder(sort(notes: notes)),
            );
          },
        ),
      ),
    );
  }

  ListView myListBuilder(List<Note> notes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
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
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: GestureDetector(
                onTapDown: (details) {
                  _getTapPosition(details);
                },
                onLongPress: () {
                  HapticFeedback.vibrate();
                  _showContextMenu(context, note);
                },
                child: ListTile(
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
            style: TextStyle(fontSize: 14.0, color: Colors.grey[200]),
          ),
          const SizedBox(height: 6.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                note.date,
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.grey[300],
                ),
              ),
              if (note.imp != 0)
                const Icon(
                  Icons.star,
                  color: Colors.lightBlue,
                  size: 20.0,
                ),
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
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: Colors.grey[300],
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_folderName.isEmpty && note.category.isNotEmpty)
          Text(
            note.category,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  void _getTapPosition(TapDownDetails tapPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    setState(
      () => _tapPosition = renderBox.globalToLocal(tapPosition.globalPosition),
    );
  }

  void _showContextMenu(context, Note note) async {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();
    final result = await showMenu(
      color: Colors.black,
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          _tapPosition.dx + 10,
          _tapPosition.dy + 80,
          10,
          10,
        ),
        overlay!.paintBounds,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      constraints: const BoxConstraints(minWidth: 170.0, maxWidth: 170.0),
      items: [
        PopupMenuItem(
          value: "folders",
          child: Text(
            "Move To",
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
        ),
        PopupMenuItem(
          value: "important",
          child: Text(
            note.imp == 0 ? "Important" : "Not Important",
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
        ),
      ],
    );

    switch (result) {
      case "important":
        await _database.updateNote(
          note: note.copyWith(imp: note.imp == 0 ? 1 : 0),
        );
        break;
      case "folders":
        Navigator.of(context).push(SlideRightRoute(
          page: const FolderPage(),
          arguments: note,
        ));
        break;
      default:
    }
  }
}

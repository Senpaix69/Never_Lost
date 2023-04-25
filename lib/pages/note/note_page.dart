import 'package:flutter/material.dart';
import 'package:my_timetable/pages/note/add_note_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note_services/folder.dart';
import 'package:my_timetable/services/note_services/note.dart';
import 'package:my_timetable/utils.dart' show emptyWidget;
import 'package:my_timetable/widgets/add_folder.dart';
import 'package:my_timetable/widgets/animate_route.dart'
    show SlideFromBottomTransition, SlideRightRoute;
import 'package:my_timetable/widgets/dialog_boxs.dart';

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
  String _folderName = "";
  List<Folder> _folders = [];

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
    return sortedNotes;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> deleteFolder(int id) async {
    bool confirmDel =
        await confirmDialogue(context: context, message: "Delete this folder?");
    if (confirmDel) {
      await _database.removeFolder(id: id);
    }
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
                TextButton.icon(
                  onPressed: () async {
                    String? name = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddFolderDialog();
                      },
                    );
                    if (name != null) await _database.addFolder(name: name);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Folder"),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10),
                  child: TextButton(
                    onPressed: () => setState(() => _folderName = ""),
                    style: ButtonStyle(
                      backgroundColor: _folderName.isEmpty
                          ? MaterialStateColor.resolveWith(
                              (states) => Colors.grey,
                            )
                          : null,
                    ),
                    child: Text(
                      "All",
                      style: TextStyle(
                        color: _folderName.isEmpty ? Colors.white : Colors.grey,
                      ),
                    ),
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
                    _folders = folders;
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: folders.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 3),
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: _folderName == folders[index].name
                                ? MaterialStateColor.resolveWith(
                                    (states) => Colors.grey,
                                  )
                                : null,
                          ),
                          onLongPress: () async =>
                              await deleteFolder(folders[index].id!),
                          onPressed: () {
                            setState(() => _folderName = folders[index].name);
                          },
                          child: Text(
                            folders[index].name,
                            style: TextStyle(
                              color: _folderName == folders[index].name
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: null,
        child: StreamBuilder(
          stream: _database.allNotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.grey,
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
                color: Colors.grey.withAlpha(60),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                minVerticalPadding: 15.0,
                onTap: () => Navigator.push(
                  context,
                  SlideRightRoute(page: const AddNote(), arguments: note),
                ),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      note.title,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
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
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      note.body.toString().split("\n").join(""),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      note.date,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  initialValue: note.category.isEmpty ? note.category : null,
                  itemBuilder: (BuildContext context) {
                    return _folders.map((Folder item) {
                      return PopupMenuItem<String>(
                        value: item.name,
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: note.category == item.name
                                ? Colors.amber
                                : Colors.grey,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  child: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == note.category) {
                      await _database.updateNote(
                        note: note.copyWith(category: ""),
                      );
                    } else {
                      await _database.updateNote(
                        note: note.copyWith(category: value),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

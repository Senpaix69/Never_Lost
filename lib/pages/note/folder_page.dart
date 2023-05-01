import 'package:flutter/material.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note_services/folder.dart';
import 'package:my_timetable/services/note_services/note.dart';
import 'package:my_timetable/utils.dart' show GetArgument, deleteFolder;
import 'package:my_timetable/widgets/add_folder.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final DatabaseService _database = DatabaseService();
  Note? _note;
  List<Folder>? _folders;

  @override
  void initState() {
    super.initState();
    _database.catchAllFolders();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => setArgument());
    });
  }

  void setArgument() {
    final widgetTable = context.getArgument<Note>();
    if (widgetTable != null) {
      _note = widgetTable;
    }
  }

  void updateCategory(String value) async {
    if (_note == null) {
      return;
    }
    if (value == _note!.category) {
      await _database.updateNote(
        note: _note!.copyWith(category: ""),
      );
      _note = _note!.copyWith(category: "");
    } else {
      await _database.updateNote(
        note: _note!.copyWith(category: value),
      );
      _note = _note!.copyWith(category: value);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isNote = _note != null;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Folders"),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<List<Folder>>(
          stream: _database.allFolder,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
              );
            }
            _folders = snapshot.data!;
            return folderList(_folders!, isNote);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () async {
          String? name = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddFolderDialog(
                folders: _folders!.map((e) => e.name).toList(),
              );
            },
          );
          if (name != null) await _database.addFolder(name: name);
        },
        child: Icon(
          Icons.folder,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  ListView folderList(List<Folder> folders, bool isNote) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      shrinkWrap: true,
      itemCount: folders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10.0),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ListTile(
          key: ValueKey(folders[index].id),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          onTap: () => updateCategory(folders[index].name),
          tileColor: isNote
              ? _note!.category == folders[index].name
                  ? Colors.red.withAlpha(180)
                  : Colors.lightBlue.withAlpha(180)
              : Colors.lightBlue.withAlpha(180),
          title: Text(
            folders[index].name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: isNote
              ? _note!.category == folders[index].name
                  ? const Icon(
                      Icons.check,
                      color: Colors.amber,
                      size: 30.0,
                    )
                  : const SizedBox()
              : null,
          trailing: IconButton(
            onPressed: () async {
              final folder = folders[index];
              bool del = await deleteFolder(folder, context);
              if (del) {
                await _database.removeFolder(id: folder.id!);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}

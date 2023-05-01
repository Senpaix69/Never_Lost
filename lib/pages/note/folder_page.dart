import 'package:flutter/material.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note_services/folder.dart';
import 'package:my_timetable/services/note_services/note.dart';
import 'package:my_timetable/utils.dart' show GetArgument;
import 'package:my_timetable/widgets/add_folder.dart';
import 'package:my_timetable/widgets/dialog_boxs.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final DatabaseService _database = DatabaseService();
  Note? note;

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
      note = widgetTable;
    }
  }

  void updateCategory(String value) async {
    if (note == null) {
      return;
    }
    if (value == note!.category) {
      await _database.updateNote(
        note: note!.copyWith(category: ""),
      );
      note = note!.copyWith(category: "");
    } else {
      await _database.updateNote(
        note: note!.copyWith(category: value),
      );
      note = note!.copyWith(category: value);
    }
    setState(() {});
  }

  void deleteFolder(Folder folder) async {
    bool del = await confirmDialogue(
        context: context,
        message: "You sure want to delete ${folder.name} folder?");
    if (del) {
      await _database.removeFolder(id: folder.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNote = note != null;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            final folders = snapshot.data!;
            return folderList(folders, isNote);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? name = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddFolderDialog();
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
              ? note!.category == folders[index].name
                  ? Colors.red.withAlpha(180)
                  : Colors.blueAccent.withAlpha(180)
              : Colors.blueAccent.withAlpha(180),
          title: Text(
            folders[index].name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: isNote
              ? note!.category == folders[index].name
                  ? const Icon(
                      Icons.check,
                      color: Colors.amber,
                      size: 30.0,
                    )
                  : const SizedBox()
              : null,
          trailing: IconButton(
            onPressed: () => deleteFolder(folders[index]),
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}

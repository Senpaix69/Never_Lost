import 'package:flutter/material.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/note_services/folder.dart';
import 'package:neverlost/services/note_services/note.dart';
import 'package:neverlost/utils.dart'
    show GetArgument, deleteFolder, emptyWidget;
import 'package:neverlost/widgets/add_folder.dart';

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
      appBar: AppBar(
        title: const Text("Folders"),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
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
            if (_folders!.isEmpty) {
              return emptyWidget(icon: Icons.folder, message: "No Folders Yet");
            }
            return folderList(_folders!, isNote);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(
          Icons.folder,
          color: Colors.white,
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
          tileColor: _note?.category == folders[index].name
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).primaryColorLight,
          title: Text(
            folders[index].name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: _note?.category == folders[index].name
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).shadowColor,
            ),
          ),
          leading: isNote
              ? _note!.category == folders[index].name
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
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
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

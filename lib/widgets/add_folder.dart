import 'package:flutter/material.dart';
import 'package:my_timetable/widgets/styles.dart' show decorationFormField;

class AddFolderDialog extends StatefulWidget {
  const AddFolderDialog({Key? key}) : super(key: key);
  @override
  State<AddFolderDialog> createState() => _AddFolderDialogState();
}

class _AddFolderDialogState extends State<AddFolderDialog> {
  final TextEditingController _folderNameController = TextEditingController();
  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20.0,
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10.0,
      ),
      content: TextField(
        controller: _folderNameController,
        autofocus: true,
        decoration: decorationFormField(Icons.folder, "Enter Folder Name"),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final String folderName = _folderNameController.text.trim();
            if (folderName.isNotEmpty) {
              Navigator.of(context).pop(folderName);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

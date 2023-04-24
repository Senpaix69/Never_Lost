import 'package:flutter/material.dart';

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
      backgroundColor: Colors.grey[900],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10.0,
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10.0,
      ),
      content: TextField(
        controller: _folderNameController,
        decoration: const InputDecoration(hintText: 'Enter folder name'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final String folderName = _folderNameController.text.trim();
            if (folderName.isNotEmpty) {
              Navigator.of(context).pop(folderName);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
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

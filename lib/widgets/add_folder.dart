import 'package:flutter/material.dart';
import 'package:neverlost/widgets/styles.dart' show decorationFormField;

class AddFolderDialog extends StatefulWidget {
  final List<String> folders;
  const AddFolderDialog({Key? key, required this.folders}) : super(key: key);

  @override
  State<AddFolderDialog> createState() => _AddFolderDialogState();
}

class _AddFolderDialogState extends State<AddFolderDialog> {
  final TextEditingController _folderNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  String? folderValidate(String? value) {
    if (value!.isEmpty) {
      return 'Please enter a folder name';
    } else {
      final String valueLower = value.toLowerCase();
      for (int i = 0; i < widget.folders.length; i++) {
        final folderLower = widget.folders[i].toLowerCase();
        if (folderLower == valueLower) {
          return 'This folder already exists';
        }
      }
      return null;
    }
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
      content: Form(
        key: _formKey,
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: _folderNameController,
          autofocus: true,
          decoration: decorationFormField(Icons.folder, "Enter Folder Name"),
          validator: folderValidate,
        ),
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
            if (_formKey.currentState!.validate()) {
              final String folderName = _folderNameController.text.trim();
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

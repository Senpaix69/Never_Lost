import 'package:flutter/material.dart';

class FolderButton extends StatelessWidget {
  final String folderName;
  final VoidCallback selectFolder;
  final VoidCallback? deleteFolder;
  const FolderButton({
    super.key,
    required this.selectFolder,
    required this.folderName,
    this.deleteFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.resolveWith(
            (states) => RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          backgroundColor: folderName.isEmpty
              ? MaterialStateColor.resolveWith((states) => Colors.blue)
              : MaterialStateColor.resolveWith(
                  (states) => Colors.black.withAlpha(100),
                ),
        ),
        onLongPress: deleteFolder,
        onPressed: selectFolder,
        child: Text(
          folderName.isEmpty ? 'All' : folderName,
          style: TextStyle(
            color: folderName.isEmpty ? Colors.white : Colors.grey[200],
            fontWeight:
                folderName.isEmpty ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

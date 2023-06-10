import 'package:flutter/material.dart';

class FolderButton extends StatelessWidget {
  final String folderName;
  final String activeFolder;
  final VoidCallback selectFolder;
  final VoidCallback? deleteFolder;
  const FolderButton({
    super.key,
    required this.activeFolder,
    required this.selectFolder,
    required this.folderName,
    this.deleteFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.resolveWith(
            (states) => const EdgeInsets.symmetric(horizontal: 10.0),
          ),
          shape: MaterialStateProperty.resolveWith(
            (states) => RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          backgroundColor: folderName == activeFolder
              ? MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).primaryColor,
                )
              : MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).cardColor,
                ),
        ),
        onLongPress: deleteFolder,
        onPressed: selectFolder,
        child: Text(
          folderName.isEmpty ? 'All' : folderName,
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
            fontWeight: folderName == activeFolder
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

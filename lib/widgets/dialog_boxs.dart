import 'package:flutter/material.dart';

Future<void> errorDialogue({
  required BuildContext context,
  required String message,
  String? title,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title != null ? Text(title) : null,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.grey[900],
        content: Text(message),
        actions: <Widget>[
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      );
    },
  );
}

Future<bool> confirmDialogue({
  required BuildContext context,
  required String message,
  String? title,
}) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          backgroundColor: Colors.grey[900],
          content: Text(message),
          title: title != null ? Text(title) : null,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      }).then(
    (value) => value ?? false,
  );
}

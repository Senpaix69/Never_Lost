import 'package:flutter/material.dart';

Future<void> errorDialogue(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text("Error", style: TextStyle(color: Colors.white)),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 191, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      );
    },
  );
}

Future<bool> confirmDialogue(
    {required BuildContext context, required String message}) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text("Delete", style: TextStyle(color: Colors.white)),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 191, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Confirm'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        );
      }).then((value) => value ?? false);
}

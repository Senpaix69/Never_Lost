import 'package:flutter/material.dart';
import 'package:neverlost/contants/profile_contants/backup_contants.dart';
import 'package:neverlost/widgets/dialog_boxs.dart' show errorDialogue;

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isAgree = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                textMessageBold(
                  message: "Backup Confirmation",
                  size: 24,
                ),
                const Text(backupText),
                const SizedBox(height: 10.0),
                textMessageBold(
                  message: "1. Backup Content:",
                  size: 14.0,
                ),
                const Text(backupContent),
                const SizedBox(height: 10.0),
                textMessageBold(
                  message: "2. Previous Backup Removal:",
                  size: 14.0,
                ),
                const Text(previousBackupRemoval),
                const SizedBox(height: 10.0),
                textMessageBold(
                  message: "2. Backup File Security:",
                  size: 14.0,
                ),
                const Text(backupFileSecurity),
                const SizedBox(height: 10.0),
                textMessageBold(
                  message: "2. Backup Restoration:",
                  size: 14.0,
                ),
                const Text(backupRestoration),
                const SizedBox(height: 10.0),
                const Text(confirmBackup),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  leading: Checkbox(
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      value: _isAgree,
                      onChanged: (value) => setState(
                            () => _isAgree = value!,
                          )),
                  title: const Text("I agree to all the conditions"),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.lightBlue,
                        )),
                        child: textMessageBold(
                          message: "Cancel",
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isAgree) {
                            Navigator.of(context).pop(true);
                          } else {
                            errorDialogue(
                              context: context,
                              message: "Make sure you agree to the terms",
                              title: "Agree Terms",
                            );
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.red,
                        )),
                        child: textMessageBold(
                          message: "Backup Now",
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textMessageBold({
    required String message,
    required double size,
    Color? color,
  }) {
    return Text(
      message,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

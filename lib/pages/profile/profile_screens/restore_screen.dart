import 'package:flutter/material.dart';
import 'package:neverlost/contants/profile_contants/restore_contants.dart';
import 'package:neverlost/widgets/dialog_boxs.dart' show errorDialogue;

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});

  @override
  State<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  bool _isAgree = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                textMessageBold(
                  message: "Restore Confirmation",
                  size: 24,
                  align: true,
                ),
                const SizedBox(height: 30.0),
                const Text(restoreContent),
                const SizedBox(height: 10.0),
                textMessageBold(
                  message: "Please note the following:",
                  size: 16.0,
                ),
                const SizedBox(height: 10.0),
                const Text(noteRestore),
                const SizedBox(height: 10.0),
                const Text(confirmRestore),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  leading: Checkbox(
                      checkColor: Colors.black,
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
                          (states) => Colors.grey.shade800,
                        )),
                        child: textMessageBold(
                          padding: 3.0,
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
                          padding: 3.0,
                          message: "Restore Now",
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
    bool align = false,
    double? padding,
  }) {
    return Text(
      message,
      style: TextStyle(
        height: padding,
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      textAlign: align ? TextAlign.center : null,
    );
  }
}

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
                  color: Theme.of(context).shadowColor,
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
                  onTap: () => setState(() => _isAgree = !_isAgree),
                  leading: Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: _isAgree
                          ? Theme.of(context).indicatorColor
                          : Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).indicatorColor,
                      ),
                    ),
                    child: _isAgree
                        ? Center(
                            child: Icon(
                              Icons.check,
                              size: 16.0,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          )
                        : null,
                  ),
                  title: const Text("I agree to all the terms and conditions"),
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
                          (states) => Theme.of(context).primaryColorLight,
                        )),
                        child: textMessageBold(
                          padding: 3.3,
                          message: "Cancel",
                          size: 16,
                          color: Theme.of(context).shadowColor,
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
                              message:
                                  "Make sure you agree are agreed to the terms and conditions",
                              title: "Terms and Conditions",
                            );
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Theme.of(context).primaryColorDark,
                        )),
                        child: textMessageBold(
                          padding: 3.3,
                          message: "Restore Backup",
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

import 'package:flutter/material.dart';
import 'package:neverlost/contants/firebase_contants/firebase_contants.dart';
import 'package:neverlost/contants/profile_contants/backup_contants.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart'
    show calculateNoteSize, calculateSize, convertSizeUnit;
import 'package:neverlost/widgets/dialog_boxs.dart'
    show confirmDialogue, errorDialogue;

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isAgree = false;
  bool _timeTablesAgree = false;
  bool _selectAll = false;
  bool _todoAgree = false;
  bool _notesAgree = false;
  double _timetableSize = 0.0;
  double _todoSize = 0.0;
  double _noteSize = 0.0;
  double _backupSize = 0.0;

  void goBack(Map<String, bool> value) => Navigator.of(context).pop(value);

  void backup() async {
    if (_isAgree) {
      if (!_notesAgree && !_timeTablesAgree && !_todoAgree) {
        errorDialogue(
          context: context,
          message:
              "Please make sure you have selected at least one of the given categories to make backup!",
          title: "Select Catagories",
        );
        return;
      }
      final size = convertSizeUnit(size: _backupSize);
      if (await confirmDialogue(
          context: context,
          message: "Backup Size: $size\nAre you sure you wants to backup?",
          title: "Backup")) {
        goBack({
          timetableColumn: _timeTablesAgree,
          todoColumn: _todoAgree,
          noteColumn: _notesAgree,
        });
        return;
      }
    } else {
      errorDialogue(
        context: context,
        message: "Make sure you agree are agreed to the terms and conditions",
        title: "Terms and Conditions",
      );
    }
  }

  void setAll() {
    setState(() {
      if (!_selectAll) {
        _notesAgree = _noteSize > 0.0;
        _timeTablesAgree = _timetableSize > 0.0;
        _todoAgree = _todoSize > 0.0;
        _selectAll = _notesAgree || _timeTablesAgree || _todoAgree;
        _backupSize = _noteSize + _timetableSize + _todoSize;
      } else {
        _backupSize = 0.0;
        _notesAgree = false;
        _timeTablesAgree = false;
        _todoAgree = false;
        _selectAll = false;
      }
    });
  }

  void checkSelection() {
    setState(() {
      _selectAll = (_notesAgree || _noteSize == 0) &&
          (_timeTablesAgree || _timetableSize == 0) &&
          (_todoAgree || _todoSize == 0);
    });
  }

  void addBackup({
    required double size,
    required String name,
  }) {
    if (size == 0.0) {
      errorDialogue(
        context: context,
        title: "No $name Found",
        message: "You can not add this in your backup, add $name first.",
      );
      return;
    }
    bool value;
    if (name == 'Timetables') {
      _timeTablesAgree = !_timeTablesAgree;
      value = _timeTablesAgree;
    } else if (name == 'Todos') {
      _todoAgree = !_todoAgree;
      value = _todoAgree;
    } else {
      _notesAgree = !_notesAgree;
      value = _notesAgree;
    }
    checkSelection();
    if (value) {
      _backupSize += size;
      return;
    }
    _backupSize -= size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                textMessageBold(
                  message: "Backup Confirmation",
                  size: 24,
                  align: true,
                  color: Theme.of(context).shadowColor,
                ),
                const SizedBox(height: 30.0),
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
                  message: "3. Backup File Security:",
                  size: 14.0,
                ),
                const Text(backupFileSecurity),
                const SizedBox(height: 10.0),
                textMessageBold(
                  message: "4. Backup Restoration:",
                  size: 14.0,
                ),
                const Text(backupRestoration),
                const SizedBox(height: 10.0),
                const Text(confirmBackup),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorDark,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            textMessageBold(
                              message: "Backup Contents",
                              size: 16.0,
                            ),
                            ElevatedButton(
                              onPressed: setAll,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => Theme.of(context).cardColor,
                                ),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                              child: textMessageBold(
                                message:
                                    _selectAll ? "Unselect All" : "Select All",
                                size: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      myTile(
                        title: "Timetables Backup",
                        value: _timeTablesAgree,
                        subtitle: convertSizeUnit(
                          size: calculateSize(
                            list: _db.cachedTimeTables,
                            callback: (value) => _timetableSize = value,
                          ),
                        ),
                        valueCheckBox: () => addBackup(
                          size: _timetableSize,
                          name: "Timetables",
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      myTile(
                        title: "Todos Backup",
                        value: _todoAgree,
                        subtitle: convertSizeUnit(
                          size: calculateSize(
                            list: _db.cachedTodos,
                            callback: (value) => _todoSize = value,
                          ),
                        ),
                        valueCheckBox: () => addBackup(
                          size: _todoSize,
                          name: "Todos",
                        ),
                      ),
                      myTile(
                        title: "Notes Backup",
                        value: _notesAgree,
                        subtitle: convertSizeUnit(
                          size: calculateNoteSize(
                            notes: _db.cachedNotes,
                            callback: (value) => _noteSize = value,
                          ),
                        ),
                        valueCheckBox: () => addBackup(
                          size: _noteSize,
                          name: "Notes",
                        ),
                      ),
                    ],
                  ),
                ),
                myTile(
                  title: "I agree to all terms and conditions",
                  value: _isAgree,
                  valueCheckBox: () => setState(
                    () => _isAgree = !_isAgree,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(null),
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
                        onPressed: backup,
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Theme.of(context).primaryColorDark,
                        )),
                        child: textMessageBold(
                          padding: 3.3,
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

  ListTile myTile({
    required String title,
    required bool value,
    String? subtitle,
    required VoidCallback valueCheckBox,
  }) {
    return ListTile(
      onTap: valueCheckBox,
      leading: Container(
        width: 22.0,
        height: 22.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: value ? Theme.of(context).indicatorColor : Colors.transparent,
          border: Border.all(
            color: Theme.of(context).indicatorColor,
          ),
        ),
        child: value
            ? Center(
                child: Icon(
                  Icons.check,
                  size: 16.0,
                  color: Theme.of(context).primaryColorDark,
                ),
              )
            : null,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
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

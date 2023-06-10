import 'package:flutter/material.dart';
import 'package:neverlost/contants/firebase_contants/firebase_contants.dart';
import 'package:neverlost/contants/profile_contants/restore_contants.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart'
    show FirebaseService, convertSizeUnit;
import 'package:neverlost/widgets/dialog_boxs.dart'
    show confirmDialogue, errorDialogue;

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});

  @override
  State<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  final FirebaseService _firebase = FirebaseService.instance();
  bool _isAgree = false;
  bool _timeTablesAgree = false;
  bool _selectAll = false;
  bool _todoAgree = false;
  bool _notesAgree = false;
  Map<String, String>? _size;
  double _timetableSize = 0.0;
  double _todoSize = 0.0;
  double _noteSize = 0.0;
  double _restoreSize = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _size = await _firebase.restoreBackupSize;
      setArguments(data: _size);
    });
  }

  void setArguments({required Map<String, String>? data}) {
    if (data != null) {
      _size = data;
      _todoSize = double.parse(data[todoColumn]!.split(" ").first);
      _timetableSize = double.parse(data[timetableColumn]!.split(" ").first);
      _noteSize = double.parse(data[noteColumn]!.split(" ").first);
      setState(() {});
    }
  }

  void goBack(Map<String, bool> value) => Navigator.of(context).pop(value);

  void restore() async {
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
      final size = convertSizeUnit(size: _restoreSize);
      if (await confirmDialogue(
          context: context,
          message: "Restore Size: $size\nAre you sure you wants to backup?",
          title: "Restore")) {
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
        _restoreSize = _noteSize + _timetableSize + _todoSize;
      } else {
        _restoreSize = 0.0;
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
    if (name == timetableColumn) {
      _timeTablesAgree = !_timeTablesAgree;
      value = _timeTablesAgree;
    } else if (name == todoColumn) {
      _todoAgree = !_todoAgree;
      value = _todoAgree;
    } else {
      _notesAgree = !_notesAgree;
      value = _notesAgree;
    }
    checkSelection();
    if (value) {
      _restoreSize += size;
      return;
    }
    _restoreSize -= size;
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
                              message: "Restore Contents",
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
                        title: "Available Timetables",
                        value: _timeTablesAgree,
                        subtitle: _size != null
                            ? _size![timetableColumn]
                            : "0.0 bytes",
                        valueCheckBox: () => addBackup(
                          size: _timetableSize,
                          name: timetableColumn,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      myTile(
                        title: "Available Todos",
                        value: _todoAgree,
                        subtitle:
                            _size != null ? _size![todoColumn] : "0.0 bytes",
                        valueCheckBox: () => addBackup(
                          size: _todoSize,
                          name: todoColumn,
                        ),
                      ),
                      myTile(
                        title: "Available Notes",
                        value: _notesAgree,
                        subtitle:
                            _size != null ? _size![noteColumn] : "0.0 bytes",
                        valueCheckBox: () => addBackup(
                          size: _noteSize,
                          name: noteColumn,
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
                        onPressed: restore,
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

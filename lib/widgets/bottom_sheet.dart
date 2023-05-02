import 'package:flutter/material.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/note_services/todo.dart';
import 'package:my_timetable/services/notification_service.dart';
import 'package:my_timetable/utils.dart' show getFormattedTime;

class MyBottomSheet extends StatefulWidget {
  final Todo? todo;
  const MyBottomSheet({super.key, this.todo});
  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  late final DatabaseService _database;
  late final TextEditingController _textController;
  DateTime? _date;
  bool emptyText = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.text = widget.todo?.text ?? "";
    _date =
        widget.todo?.date != null ? DateTime.parse(widget.todo!.date!) : null;
    _database = DatabaseService();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void goBack() => Navigator.of(context).pop();

  Future<void> setSchedule(Todo todo) async {
    if (todo.date == null) {
      return;
    }
    await NotificationService.scheduleNotification(
      scheduleDate: _date!,
      id: todo.id!,
      title: "Task Reminder",
      body: todo.text,
    );
  }

  Future<void> saveTodo() async {
    bool isPassedReminder = _date?.isBefore(DateTime.now()) == true;
    Todo todo = Todo(
      text: _textController.text,
      date: _date?.toString(),
      reminder: isPassedReminder ? 1 : 0,
    );
    if (widget.todo != null) {
      await _database.updateTodo(
        todo: todo.copyWith(
          id: widget.todo!.id,
          complete: widget.todo!.complete,
        ),
      );
      if (_date == null || !isPassedReminder) {
        await NotificationService.cancelScheduleNotification(
          id: widget.todo!.id!,
        );
        await setSchedule(todo.copyWith(id: widget.todo!.id!));
      }
    } else {
      final res = await _database.insertTodo(todo: todo);
      if (_date != null && !isPassedReminder) {
        await setSchedule(res);
      }
    }
    goBack();
  }

  Future<void> saveDate(DateTime pickedDate) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(
          const Duration(minutes: 1),
        ),
      ),
    );
    if (pickedTime != null) {
      final DateTime pickedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _date = pickedDateTime;
      setState(() => emptyText = false);
    }
  }

  Future<void> pickDateAndTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );
    if (pickedDate != null) {
      await saveDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 15,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: myTextField(),
          ),
          const SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.alarm,
                    color: _date != null ? Colors.white : Colors.grey[300],
                  ),
                  label: Text(
                    _date == null
                        ? "Set reminder"
                        : getFormattedTime(_date.toString())!,
                    style: TextStyle(
                      fontSize: 16,
                      color: _date != null ? Colors.white : Colors.grey[300],
                    ),
                  ),
                  onPressed: _date == null
                      ? () async => await pickDateAndTime()
                      : () => handleReminder(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _date != null ? Colors.blue : Colors.grey[900],
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                ),
                InkWell(
                  onTap: emptyText ? null : () async => await saveTodo(),
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: emptyText ? Colors.grey : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleReminder() {
    setState(() {
      _date = null;
      if (_textController.text.isNotEmpty) emptyText = false;
    });
  }

  void handleChange(String value) {
    if (widget.todo != null && value == widget.todo!.text) {
      if (!emptyText) setState(() => emptyText = true);
      return;
    }
    if (value.isNotEmpty) {
      if (emptyText) setState(() => emptyText = false);
      return;
    }
    if (!emptyText) setState(() => emptyText = true);
  }

  TextField myTextField() {
    return TextField(
      onChanged: handleChange,
      autofocus: true,
      maxLines: null,
      controller: _textController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.trip_origin_outlined,
          color: emptyText ? Colors.grey : Colors.blue,
        ),
        contentPadding: EdgeInsets.zero,
        hintText: "Add Todo",
        hintStyle: TextStyle(
          color: Colors.grey[600],
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(
        fontSize: 17.0,
      ),
    );
  }
}

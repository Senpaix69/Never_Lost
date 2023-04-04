import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_time_picker.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/daytime.dart';
import 'package:my_timetable/services/subject.dart';
import 'package:my_timetable/utils.dart';
import 'package:my_timetable/widgets/daytime_list.dart';
import 'package:my_timetable/widgets/dialog_boxs.dart';
import 'package:my_timetable/widgets/styles.dart';

class AddSubject extends StatefulWidget {
  const AddSubject({super.key});
  @override
  State<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final List<DayTime> _days = <DayTime>[];

  late final DatabaseService _database;
  late final TextEditingController _professorName;
  late final TextEditingController _professorEmail;
  late final TextEditingController _startFacultyTime;
  late final TextEditingController _endFacultyTime;
  late final TextEditingController _startSlotTime;
  late final TextEditingController _facultyRoomNo;
  late final TextEditingController _facultyDay;
  late final TextEditingController _subjectName;
  late final TextEditingController _endSlotTime;
  late final TextEditingController _roomNo;
  late final TextEditingController _section;
  late final TextEditingController _day;
  bool _isSaving = false;

  @override
  void initState() {
    _professorEmail = TextEditingController();
    _startFacultyTime = TextEditingController();
    _endFacultyTime = TextEditingController();
    _professorName = TextEditingController();
    _startSlotTime = TextEditingController();
    _facultyRoomNo = TextEditingController();
    _endSlotTime = TextEditingController();
    _subjectName = TextEditingController();
    _facultyDay = TextEditingController();
    _section = TextEditingController();
    _roomNo = TextEditingController();
    _day = TextEditingController();
    _database = DatabaseService();
    _facultyDay.text = "Sunday";
    _day.text = "Sunday";
    super.initState();
  }

  @override
  void dispose() {
    _professorEmail.dispose();
    _startFacultyTime.dispose();
    _endFacultyTime.dispose();
    _facultyRoomNo.dispose();
    _professorName.dispose();
    _startSlotTime.dispose();
    _subjectName.dispose();
    _endSlotTime.dispose();
    _facultyDay.dispose();
    _section.dispose();
    _roomNo.dispose();
    _day.dispose();
    super.dispose();
  }

  void addDayTime() {
    if (_formKey2.currentState!.validate()) {
      setState(
        () => _days.add(
          DayTime(
            day: _day.text,
            roomNo: _roomNo.text,
            startTime: _startSlotTime.text,
            endTime: _endSlotTime.text,
          ),
        ),
      );
    }
  }

  void _showTimePicker({required TextEditingController controller}) {
    showMaterialTimePicker(
      context: context,
      selectedTime: TimeOfDay.now(),
      onChanged: (value) {
        setState(() {
          controller.text = value.format(context);
        });
      },
    );
  }

  Future<void> saveTimeTable() async {
    if (!_formKey.currentState!.validate()) {
      return;
    } else if (_days.isEmpty) {
      errorDialogue(context, "You need to enter timings");
      return;
    }
    setState(() => _isSaving = true);
    Subject sub = Subject(
      name: _subjectName.text,
      section: _section.text,
      professorName: _professorName.text,
    );
    await _database.insertTimeTable(daytimes: _days, subject: sub);
    setState(() => _isSaving = false);
    Future.delayed(
        const Duration(milliseconds: 100), () => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: myAppBar(),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        width: double.infinity,
        height: double.infinity,
        decoration: null,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        myText(text: "Subject Details"),
                        const SizedBox(
                          height: 10.0,
                        ),
                        formText(
                          prefix: Icons.subject,
                          hint: "Subject name",
                          controller: _subjectName,
                          validator: textValidate,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        formText(
                          prefix: Icons.pending,
                          hint: "Section",
                          controller: _section,
                          validator: textValidate,
                        ),
                        Divider(
                          height: 40.0,
                          color: Colors.cyan[900],
                        ),
                        myText(text: "Professor Details"),
                        const SizedBox(
                          height: 10.0,
                        ),
                        formText(
                          prefix: Icons.person,
                          hint: "Professor name",
                          controller: _professorName,
                          validator: textValidate,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        formText(
                          prefix: Icons.email,
                          hint: "Professor email (Optional)",
                          controller: _professorEmail,
                          validator: null,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Enter Office Timing (Optional)",
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        timingsField(
                          sTime: _startFacultyTime,
                          eTime: _endFacultyTime,
                          validation: false,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        roomAndDay(
                          day: _facultyDay,
                          room: _facultyRoomNo,
                          validation: false,
                        ),
                        Divider(
                          height: 40.0,
                          color: Colors.cyan[900],
                        ),
                      ],
                    ),
                  ),
                ),
                Form(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      myText(text: "Subject Timings *"),
                      const SizedBox(
                        height: 10.0,
                      ),
                      timingsField(sTime: _startSlotTime, eTime: _endSlotTime),
                      const SizedBox(
                        height: 10.0,
                      ),
                      roomAndDay(day: _day, room: _roomNo),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.cyan[900],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            addDayTime();
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Add Time",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withAlpha(40),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      headerContainer(
                        title: "Timings",
                        icon: Icons.calendar_month,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          children: <Widget>[
                            _days.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25.0),
                                    child: Center(
                                      child: Text(
                                        "Add Time First",
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          letterSpacing: 1.0,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : DayTimeList(
                                    callBack: (index) => setState(
                                      () => _days.removeAt(index),
                                    ),
                                    days: _days,
                                  ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row roomAndDay({
    required TextEditingController day,
    required TextEditingController room,
    bool validation = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: DropdownButtonFormField<String>(
            value: day.text,
            onChanged: (value) {
              setState(() {
                day.text = value!;
              });
            },
            dropdownColor: Colors.grey[700],
            style: const TextStyle(color: Colors.white),
            decoration: decorationFormField(Icons.weekend, "Select Day"),
            items: weekdays.map<DropdownMenuItem<String>>((weekday) {
              return DropdownMenuItem<String>(
                alignment: Alignment.center,
                value: weekday,
                child: Text(
                  weekday,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: formText(
            prefix: Icons.room,
            hint: "Room No",
            controller: room,
            validator: validation ? textValidate : null,
          ),
        ),
      ],
    );
  }

  Row timingsField({
    required TextEditingController sTime,
    required TextEditingController eTime,
    bool validation = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: formText(
            prefix: Icons.timer,
            hint: "1:00 AM",
            controller: sTime,
            validator: validation ? textValidate : null,
            onTap: () => _showTimePicker(controller: sTime),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: formText(
            prefix: Icons.timer,
            hint: "12:00 PM",
            controller: eTime,
            onTap: () => _showTimePicker(controller: eTime),
            validator: validation ? textValidate : null,
          ),
        ),
      ],
    );
  }

  TextFormField formText({
    required String hint,
    required IconData prefix,
    VoidCallback? onTap,
    required TextEditingController controller,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      enabled: !_isSaving,
      enableSuggestions: false,
      controller: controller,
      autocorrect: false,
      readOnly: onTap != null,
      onTap: onTap,
      cursorColor: Colors.amber[200],
      style: const TextStyle(color: Colors.white),
      decoration: decorationFormField(prefix, hint),
      validator: validator,
    );
  }

  AppBar myAppBar() {
    return AppBar(
      backgroundColor: Colors.cyan[900],
      title: const Text("Add Timetable"),
      actions: <Widget>[
        _isSaving
            ? Container(
                width: 55,
                padding: const EdgeInsets.all(14),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.amber,
                  ),
                ),
              )
            : IconButton(
                onPressed: () async {
                  await saveTimeTable();
                },
                icon: const Icon(Icons.check),
              ),
      ],
      elevation: 0.0,
    );
  }
}

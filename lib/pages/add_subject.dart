import 'package:flutter/material.dart';
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
  late final TextEditingController _subjectName;
  late final TextEditingController _startTime;
  late final TextEditingController _roomNo;
  late final TextEditingController _endTime;
  late final TextEditingController _day;
  bool _isSaving = false;

  @override
  void initState() {
    _professorName = TextEditingController();
    _subjectName = TextEditingController();
    _startTime = TextEditingController();
    _roomNo = TextEditingController();
    _endTime = TextEditingController();
    _day = TextEditingController();
    _database = DatabaseService();
    super.initState();
  }

  @override
  void dispose() {
    _professorName.dispose();
    _subjectName.dispose();
    _startTime.dispose();
    _endTime.dispose();
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
            startTime: _startTime.text,
            endTime: _endTime.text,
          ),
        ),
      );
    }
  }

  Future<void> saveTimeTable() async {
    if (_professorName.text.isEmpty || _subjectName.text.isEmpty) {
      errorDialogue(
          context, "Subject Name and Professor Name can not be empty");
      return;
    } else if (_days.isEmpty) {
      errorDialogue(context, "You need to enter timings");
      return;
    }
    setState(() => _isSaving = true);
    Subject sub = Subject(
      name: _subjectName.text,
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
      backgroundColor: Colors.grey[900],
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
                        myText(text: "Details"),
                        const SizedBox(
                          height: 10.0,
                        ),
                        formText(
                          prefix: Icons.person,
                          hint: "Enter Professor Name",
                          controller: _professorName,
                          validator: textValidate,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        formText(
                          prefix: Icons.subject,
                          hint: "Enter Subject Name",
                          controller: _subjectName,
                          validator: textValidate,
                        ),
                        const SizedBox(
                          height: 20.0,
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
                      myText(text: "Day and Time"),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: formText(
                              prefix: Icons.timer,
                              hint: "1:00 AM",
                              controller: _startTime,
                              validator: validateTime,
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: formText(
                              prefix: Icons.timer,
                              hint: "12:00 PM",
                              controller: _endTime,
                              validator: validateTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: formText(
                              prefix: Icons.weekend,
                              hint: "WeekDay",
                              controller: _day,
                              validator: dayValidate,
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: formText(
                              prefix: Icons.room,
                              hint: "Room No",
                              controller: _roomNo,
                              validator: roomValidate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(200),
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
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      headerContainer(
                        title: "Timings",
                        icon: Icons.calendar_month,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Column(
                          children: <Widget>[
                            _days.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
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

  TextFormField formText({
    required String hint,
    required IconData prefix,
    required TextEditingController controller,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      enabled: !_isSaving,
      enableSuggestions: false,
      controller: controller,
      autocorrect: false,
      cursorColor: Colors.amber[200],
      style: const TextStyle(color: Colors.white),
      decoration: decorationFormField(prefix, hint),
      validator: validator,
    );
  }

  AppBar myAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[850],
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

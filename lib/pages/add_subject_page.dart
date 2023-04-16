import 'package:flutter/material.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/daytime.dart';
import 'package:my_timetable/services/notification_service.dart';
import 'package:my_timetable/services/professor.dart';
import 'package:my_timetable/services/subject.dart';
import 'package:my_timetable/services/timeTable.dart';
import 'package:my_timetable/utils.dart'
    show GetArgument, textValidate, weekdays;
import 'package:my_timetable/widgets/daytime_list.dart';
import 'package:my_timetable/widgets/dialog_boxs.dart';
import 'package:my_timetable/widgets/styles.dart';

class AddSubject extends StatefulWidget {
  const AddSubject({super.key});
  @override
  State<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  TimeTable? _timeTable;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  List<DayTime> _days = <DayTime>[];
  double _height = 0.0;
  bool _editing = false;

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

  @override
  void initState() {
    super.initState();
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
    _facultyDay.text = "Monday";
    _day.text = "Monday";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        setArgument();
        _height = 0.0;
      });
    });
  }

  void setArgument() {
    final widgetTable = context.getArgument<TimeTable>();
    if (widgetTable != null) {
      _timeTable = widgetTable;
      _subjectName.text = widgetTable.subject.name;
      _section.text = widgetTable.subject.section;
      _professorName.text = widgetTable.professor.name;
      _professorEmail.text = widgetTable.professor.email!;
      _facultyDay.text = widgetTable.professor.weekDay!;
      _facultyRoomNo.text = widgetTable.professor.office!;
      _startFacultyTime.text = widgetTable.professor.startTime!;
      _endFacultyTime.text = widgetTable.professor.endTime!;
      _days = [...widgetTable.dayTime];
    }
  }

  @override
  void dispose() async {
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
        () {
          _days.add(
            DayTime(
              day: _day.text,
              roomNo: _roomNo.text,
              startTime: _startSlotTime.text,
              endTime: _endSlotTime.text,
            ),
          );
          _editing = true;
        },
      );
    }
  }

  void _showTimePicker({
    required TextEditingController controller,
    required String? stime,
  }) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    final timeFor = controller.text.split(":");
    final hour =
        controller.text.isNotEmpty ? int.parse(timeFor[0]) : currentTime.hour;
    final minute = controller.text.isNotEmpty
        ? int.parse(timeFor[1].split(" ")[0])
        : currentTime.minute;

    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    ).then((pickedTime) {
      if (pickedTime != null) {
        controller.text = pickedTime.format(context);
      }
    });
  }

  void _toggleHeight() {
    setState(() {
      _height = _height == 0 ? 208 : 0;
    });
  }

  void backPage() async {
    if (_editing) {
      bool isChanges = await confirmDialogue(
        context: context,
        message: "Some changes have done do you want to save them?",
      );
      if (isChanges) {
        await saveTimeTable();
        return;
      }
    }
    Future.delayed(
      const Duration(milliseconds: 50),
      () => Navigator.of(context).pop(),
    );
  }

  Future<void> deleteTimeTable() async {
    bool isDel = await confirmDialogue(
        context: context,
        message: "Do you really want to delete this timetable?");
    if (isDel && _timeTable != null) {
      await _database.deleteTimeTable(id: _timeTable!.subject.id!);
      Future.delayed(
          const Duration(milliseconds: 100), () => Navigator.of(context).pop());
    }
  }

  Future<void> saveTimeTable() async {
    if (!_formKey.currentState!.validate()) {
      return;
    } else if (_days.isEmpty) {
      errorDialogue(context, "You need to enter timings");
      return;
    }
    Subject sub = Subject(
      name: _subjectName.text,
      section: _section.text,
    );
    Professor professor = Professor(
      name: _professorName.text,
      email: _professorEmail.text,
      office: _facultyRoomNo.text,
      weekDay: _facultyDay.text,
      startTime: _startFacultyTime.text,
      endTime: _endFacultyTime.text,
    );
    if (_timeTable != null) {
      for (int i = 0; i < _timeTable!.dayTime.length; i++) {
        await NotificationService.cancelScheduleNotification(
            id: _timeTable!.dayTime[i].id!);
      }
      await _database.updateTimeTable(
        subject: sub.copyWith(
          id: _timeTable!.subject.id!,
          sched: 0,
        ),
        professor: professor.copyWith(
          profId: _timeTable!.professor.profId!,
          subId: _timeTable!.subject.id!,
        ),
        dayTimes: _days,
      );
    } else {
      await _database.insertTimeTable(
        daytimes: _days,
        subject: sub,
        professor: professor,
      );
    }
    Future.delayed(
      const Duration(milliseconds: 200),
      () => Navigator.of(context).pop(),
    );
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
                          color: Colors.brown[600],
                        ),
                        myText(text: "Professor Details"),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Stack(children: <Widget>[
                          formText(
                            prefix: Icons.person,
                            hint: "Professor name",
                            controller: _professorName,
                            validator: textValidate,
                          ),
                          Positioned(
                            right: 6.0,
                            child: IconButton(
                              onPressed: _toggleHeight,
                              icon: Icon(
                                _height > 0
                                    ? Icons.swipe_up_sharp
                                    : Icons.swipe_down_sharp,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ]),
                        professorDetails(),
                        Divider(
                          height: 40.0,
                          color: Colors.brown[600],
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
                          color: Colors.brown,
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
                    color: Colors.brown.withAlpha(80),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      headerContainer(
                        title: "Timings",
                        icon: Icons.calendar_month,
                        onClick: null,
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
                                    callBack: (index) => setState(() {
                                      _days.removeAt(index);
                                      _editing = true;
                                    }),
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

  AnimatedContainer professorDetails() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 330),
      height: _height,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "Optional Details",
              style: TextStyle(
                color: Colors.grey[200],
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            formText(
              prefix: Icons.email,
              hint: "Professor email",
              controller: _professorEmail,
              validator: null,
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
          ],
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
            iconSize: 0.0,
            value: day.text,
            onChanged: (value) => day.text = value!,
            dropdownColor: Colors.cyan[900],
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
            hint: "Start Time",
            controller: sTime,
            validator: validation ? textValidate : null,
            onTap: () => _showTimePicker(controller: sTime, stime: null),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: formText(
            prefix: Icons.timer,
            hint: "End Time",
            controller: eTime,
            onTap: () => _showTimePicker(controller: eTime, stime: sTime.text),
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
      enableSuggestions: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      autocorrect: false,
      readOnly: onTap != null,
      onTap: onTap,
      onChanged: (value) {
        if (!_editing) {
          setState(
            () => _editing = true,
          );
        }
      },
      cursorColor: Colors.cyan[200],
      style: const TextStyle(color: Colors.white),
      decoration: decorationFormField(prefix, hint),
      validator: validator,
    );
  }

  AppBar myAppBar() {
    bool isEditing = _timeTable != null;
    return AppBar(
      automaticallyImplyLeading: false, // disable the default back button
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => backPage(),
      ),
      backgroundColor: Colors.black,
      title: Text(isEditing ? "Edit TimeTable" : "Add Timetable"),
      actions: <Widget>[
        if (isEditing)
          Padding(
            padding: EdgeInsets.only(right: _editing ? 0.0 : 8.0),
            child: IconButton(
              onPressed: () async {
                await deleteTimeTable();
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        if (_editing)
          IconButton(
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

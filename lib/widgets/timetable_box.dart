import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_timetable/pages/add_subject_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/services/daytime.dart';
import 'package:my_timetable/utils.dart' show weekdays;
import 'package:my_timetable/widgets/animate_route.dart'
    show SlideRightRoute, SlideFromBottomTransition;
import 'package:my_timetable/widgets/daytime_list.dart';
import 'package:my_timetable/services/notification_service.dart';
import 'package:my_timetable/widgets/styles.dart' show headerContainer;

typedef CallbackAction<T> = void Function(T);

class TimeTableBox extends StatefulWidget {
  final dynamic timeTable;
  final String currentDay;
  final CallbackAction<int> callback;
  const TimeTableBox({
    Key? key,
    required this.timeTable,
    required this.callback,
    required this.currentDay,
  }) : super(key: key);

  @override
  State<TimeTableBox> createState() => _TimeTableBoxState();
}

class _TimeTableBoxState extends State<TimeTableBox>
    with SingleTickerProviderStateMixin {
  double _height = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<DayTime> _filteredDays = [];
  late final DatabaseService _service;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _height = 0);
    });
    _service = DatabaseService();
    _filteredDays = widget.timeTable.dayTime
        .where((day) => day.day == widget.currentDay)
        .toList();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _animationController.forward();
  }

  void _toggleHeight() {
    setState(() => _height = _height == 0 ? 120 : 0);
  }

  void editTimeTable() {
    Navigator.push(
      context,
      SlideRightRoute(
        page: const AddSubject(),
        arguments: widget.timeTable,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.cyan[900],
        showCloseIcon: true,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void setSchedule() async {
    for (int i = 0; i < _filteredDays.length; i++) {
      final day = _filteredDays[i];

      final startTime = DateFormat.jm().parse(day.startTime);
      final targetWeekday = weekdays.indexOf(day.day) + 1;
      final today = DateTime.now();
      final todayWeekday = today.weekday;
      final scheduleDate = DateTime(
        today.year,
        today.month,
        today.day + (targetWeekday - todayWeekday) % 7,
        startTime.hour,
        startTime.minute,
      ).subtract(const Duration(minutes: 10));

      await NotificationService.showScheduleNotification(
        id: day.id!,
        title: widget.timeTable.subject.name,
        body: "Your class is being held in room: ${day.roomNo} after 10 mins",
        scheduleDate: scheduleDate,
      );
    }
    await _service.updateSubject(
      subject: widget.timeTable.subject.copyWith(sched: 1),
    );
    showSnackBar('The reminder has been set daily');
  }

  void cancelSchedule(List<DayTime> list) async {
    for (int i = 0; i < list.length; i++) {
      final day = list[i];
      await NotificationService.cancelScheduleNotification(id: day.id!);
    }
  }

  void menuCheck(String value) async {
    if (value == 'edit') {
      editTimeTable();
    } else if (value == 'delete') {
      cancelSchedule(widget.timeTable.dayTime);
      widget.callback(widget.timeTable.subject.id);
    } else if (value == 'reminder') {
      setSchedule();
    } else if (value == 'cancelReminder') {
      cancelSchedule(_filteredDays);
      await _service.updateSubject(
        subject: widget.timeTable.subject.copyWith(sched: 0),
      );
      showSnackBar('The reminder has been removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.timeTable.subject;
    final professor = widget.timeTable.professor;

    return FadeTransition(
      opacity: _animation,
      child: SlideFromBottomTransition(
        animation: _animation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.cyan.withAlpha(40),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              headerContainer(
                title: subject.name,
                icon: Icons.edit_note,
                onClick: menuCheck,
                reminder: widget.timeTable.subject.sched != 0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        detailsProf(
                            text: "Professor",
                            detail: professor.name,
                            head: true),
                        SizedBox(
                          height: 30,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.topCenter,
                            onPressed: () => _toggleHeight(),
                            icon: Icon(
                              _height > 0
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 25.0,
                            ),
                          ),
                        )
                      ],
                    ),
                    detailsProf(
                        text: "Section", detail: subject.section, head: true),
                    const SizedBox(
                      height: 8.0,
                    ),
                    AnimatedContainer(
                      height: _height,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.ease,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: Colors.cyan.withAlpha(25),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              detailsProf(
                                  text: "Email", detail: professor.email),
                              const SizedBox(
                                height: 8.0,
                              ),
                              detailsProf(
                                  text: "Office", detail: professor.office),
                              const SizedBox(
                                height: 8.0,
                              ),
                              detailsProf(
                                  text: "Available", detail: professor.weekDay),
                              const SizedBox(
                                height: 8.0,
                              ),
                              detailsProf(
                                  text: "Timings",
                                  detail:
                                      '${professor.startTime} - ${professor.endTime}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 8.0,
                      color: Colors.cyan[900],
                      thickness: 1.0,
                    )
                  ],
                ),
              ),
              DayTimeList(
                days: _filteredDays,
                callBack: null,
                currentDay: widget.currentDay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  dynamic detailsProf(
      {required String text, required String detail, bool head = false}) {
    bool changeColor = text == "Professor" || text == "Section";
    return Column(
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: "$text: ",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.5,
              fontWeight: head ? FontWeight.bold : FontWeight.normal,
              color: changeColor ? Colors.cyan[400] : Colors.blueGrey[200],
            ),
            children: <TextSpan>[
              TextSpan(
                text: detail.isEmpty ? "not provided" : detail,
                style: TextStyle(
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

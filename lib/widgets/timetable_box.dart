import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neverlost/pages/timetable/add_subject_page.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/timetable_services/daytime.dart';
import 'package:neverlost/services/timetable_services/timetable.dart';
import 'package:neverlost/utils.dart' show showSnackBar, getDate;
import 'package:neverlost/widgets/animate_route.dart'
    show SlideRightRoute, SlideFromBottomTransition;
import 'package:neverlost/widgets/daytime_list.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/widgets/styles.dart' show headerContainer;

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
    setState(() => _height = _height == 0 ? 150 : 0);
  }

  void editTimeTable() {
    Navigator.push(
      context,
      SlideRightRoute(
        page: const AddSubject(),
        arguments: widget.timeTable as TimeTable,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showUpdate(String message) {
    showSnackBar(
      context,
      message,
    );
  }

  void setSchedule(List<DayTime> list) async {
    for (int i = 0; i < list.length; i++) {
      final day = list[i];
      final date = getDate(day.day);
      final startTime = DateFormat.jm().parse(day.startTime);
      final scheduleDate = DateTime(
        date['year']!,
        date['month']!,
        date['day']!,
        startTime.hour,
        startTime.minute,
      ).subtract(
        const Duration(minutes: 10),
      );

      await NotificationService.weeklyNotification(
        id: day.id!,
        title: widget.timeTable.subject.name,
        body: "Your class is in room: ${day.roomNo} after 10 minutes",
        scheduleDate: scheduleDate,
      );
    }
    await _service.updateSubject(
      subject: widget.timeTable.subject.copyWith(sched: 1),
    );
    showUpdate(
      'Weekly reminders for ${widget.timeTable.subject.name} has been set',
    );
  }

  Future cancelSchedule(List<DayTime> list) async {
    for (int i = 0; i < list.length; i++) {
      final day = list[i];
      await NotificationService.cancelScheduleNotification(id: day.id!);
    }
  }

  void menuCheck(String value) async {
    final timeTable = widget.timeTable;
    if (value == 'edit') {
      editTimeTable();
    } else if (value == 'delete') {
      await cancelSchedule(timeTable.dayTime);
      widget.callback(timeTable.subject.id);
    } else if (value == 'reminder') {
      setSchedule(timeTable.dayTime);
      _service.updateSubjectOfTimeTable(
        newSubject: timeTable.subject.copyWith(sched: 1),
      );
    } else if (value == 'cancelReminder') {
      cancelSchedule(timeTable.dayTime);
      await _service.updateSubject(
        subject: timeTable.subject.copyWith(sched: 0),
      );
      _service.updateSubjectOfTimeTable(
        newSubject: timeTable.subject.copyWith(sched: 0),
      );
      showUpdate(
          'The reminders for ${timeTable.subject.name} has been removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.timeTable.subject;
    final professor = widget.timeTable.professor;
    _filteredDays = widget.timeTable.dayTime
        .where((day) => day.day == widget.currentDay)
        .toList();
    return FadeTransition(
      opacity: _animation,
      child: SlideFromBottomTransition(
        animation: _animation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          padding: const EdgeInsets.only(bottom: 6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              headerContainer(
                context: context,
                title: subject.name,
                icon: Icons.edit_note,
                onClick: menuCheck,
                reminder: widget.timeTable.subject.sched != 0,
                color: Colors.white,
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
                          head: true,
                        ),
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
                              size: 25.0,
                              color: Theme.of(context).indicatorColor,
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
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white.withAlpha(10),
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
                      color: Colors.white.withAlpha(20),
                      thickness: 1.0,
                    )
                  ],
                ),
              ),
              DayTimeList(
                days: _filteredDays,
                callBack: null,
                reminder: subject.sched != 0,
                currentDay: widget.currentDay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  dynamic detailsProf({
    required String text,
    required String detail,
    bool head = false,
  }) {
    return Column(
      children: <Widget>[
        RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          text: TextSpan(
            text: "$text: ",
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 0.5,
              fontWeight: head ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).indicatorColor,
            ),
            children: <TextSpan>[
              TextSpan(
                text: detail.isEmpty ? "not provided" : detail,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_timetable/pages/add_subject_page.dart';
import 'package:my_timetable/widgets/animate_route.dart';
import 'package:my_timetable/widgets/daytime_list.dart';
import 'package:my_timetable/widgets/styles.dart' show headerContainer;

class TimeTableBox extends StatefulWidget {
  final dynamic timeTable;
  final String currentDay;
  const TimeTableBox({
    Key? key,
    required this.timeTable,
    required this.currentDay,
  }) : super(key: key);

  @override
  State<TimeTableBox> createState() => _TimeTableBoxState();
}

class _TimeTableBoxState extends State<TimeTableBox> {
  double _height = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _height = 0);
    });
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
  Widget build(BuildContext context) {
    final subject = widget.timeTable.subject;
    final professor = widget.timeTable.professor;
    final dayTimes = widget.timeTable.dayTime;

    return Container(
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
            onClick: editTimeTable,
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
                    detailsProf(text: "Professor", detail: professor.name),
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
                AnimatedContainer(
                  height: _height,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.cyan.withAlpha(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          detailsProf(text: "Email", detail: professor.email),
                          detailsProf(text: "Office", detail: professor.office),
                          detailsProf(
                              text: "Available", detail: professor.weekDay),
                          detailsProf(
                              text: "Timings",
                              detail:
                                  '${professor.startTime} - ${professor.endTime}'),
                        ],
                      ),
                    ),
                  ),
                ),
                detailsProf(text: "Section", detail: subject.section),
                const SizedBox(
                  height: 20.0,
                ),
                Divider(
                  height: 0.0,
                  color: Colors.cyan[900],
                  thickness: 2.0,
                )
              ],
            ),
          ),
          DayTimeList(
            days: dayTimes,
            callBack: null,
            currentDay: widget.currentDay,
          ),
        ],
      ),
    );
  }

  dynamic detailsProf({required String text, required String detail}) {
    bool changeColor = text == "Professor" || text == "Section";
    return detail.isNotEmpty
        ? Column(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  text: "$text: ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        changeColor ? Colors.cyan[400] : Colors.blueGrey[200],
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: detail,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
            ],
          )
        : const SizedBox(
            height: 0,
          );
  }
}

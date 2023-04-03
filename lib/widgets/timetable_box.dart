import 'package:flutter/material.dart';
import 'package:my_timetable/widgets/daytime_list.dart';
import 'package:my_timetable/widgets/styles.dart' show headerContainer;

class TimeTableBox extends StatelessWidget {
  final dynamic timeTable;
  final String currentDay;

  const TimeTableBox({
    Key? key,
    required this.timeTable,
    required this.currentDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subject = timeTable.subject;
    final dayTimes = timeTable.dayTime;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          headerContainer(
            title: subject.name,
            icon: Icons.edit,
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              "Professor: ${subject.professorName}",
              style: TextStyle(
                color: Colors.grey[200],
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DayTimeList(
            days: dayTimes,
            callBack: null,
            currentDay: currentDay,
          ),
        ],
      ),
    );
  }
}

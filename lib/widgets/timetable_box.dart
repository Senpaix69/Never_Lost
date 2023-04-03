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
            icon: Icons.edit_note,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Professor: ${subject.professorName}",
                  style: TextStyle(
                    color: Colors.grey[200],
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  "Section: ${subject.section}",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Divider(
                  height: 0.0,
                  color: Colors.grey[800],
                  thickness: 2.0,
                )
              ],
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

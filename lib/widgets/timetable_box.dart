import 'package:flutter/material.dart';

class TimeTableBox extends StatelessWidget {
  final dynamic timeTable;

  const TimeTableBox({
    Key? key,
    required this.timeTable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subject = timeTable.subject;
    final dayTimes = timeTable.dayTime;

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.name,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            subject.professorName,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Day/Times:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: dayTimes.length,
            itemBuilder: (context, index) {
              final dayTime = dayTimes[index];
              return Text(dayTime.toString());
            },
          ),
        ],
      ),
    );
  }
}

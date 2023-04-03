import 'package:flutter/material.dart';
import 'package:my_timetable/services/daytime.dart';
import 'package:my_timetable/services/subject.dart';

@immutable
class TimeTable {
  final Subject subject;
  final List<DayTime> dayTime;

  const TimeTable({
    required this.subject,
    required this.dayTime,
  });

  TimeTable copyWith({
    Subject? subject,
    List<DayTime>? dayTime,
  }) {
    return TimeTable(
      subject: subject ?? this.subject,
      dayTime: dayTime ?? this.dayTime,
    );
  }

  @override
  String toString() {
    return 'Subject: $subject, DayTimes: ${dayTime.map((dt) => dt.toString()).toList()}';
  }
}

import 'package:flutter/foundation.dart';
import 'package:my_timetable/services/daytime.dart';
import 'package:my_timetable/services/professor.dart';
import 'package:my_timetable/services/subject.dart';

@immutable
class TimeTable {
  final Subject subject;
  final Professor professor;
  final List<DayTime> dayTime;

  const TimeTable({
    required this.subject,
    required this.professor,
    required this.dayTime,
  });

  TimeTable copyWith({
    Subject? subject,
    Professor? professor,
    List<DayTime>? dayTime,
  }) {
    return TimeTable(
      subject: subject ?? this.subject,
      professor: professor ?? this.professor,
      dayTime: dayTime ?? this.dayTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimeTable &&
        other.subject == subject &&
        other.professor == professor &&
        listEquals(other.dayTime, dayTime);
  }

  @override
  int get hashCode => subject.hashCode ^ professor.hashCode ^ dayTime.hashCode;

  @override
  String toString() {
    return 'Subject: $subject, Professor: $professor, DayTimes: ${dayTime.map((dt) => dt.toString()).toList()}';
  }
}

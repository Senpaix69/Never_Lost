import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:neverlost/contants/database_contants.dart/database_constants.dart';
import 'package:neverlost/services/timetable_services/daytime.dart';
import 'package:neverlost/services/timetable_services/professor.dart';
import 'package:neverlost/services/timetable_services/subject.dart';

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

  factory TimeTable.fromMap(Map<String, dynamic> map) {
    final sub = Subject.fromMap(map[subTable]);
    final prof = Professor.fromMap(map[professorTable]);
    final dayTimes = (map[dayTimeTable] as List<dynamic>?)
            ?.map(
              (daytime) => DayTime.fromMap(daytime as Map<String, Object?>),
            )
            .toList() ??
        [];

    return TimeTable(
      subject: sub,
      professor: prof,
      dayTime: dayTimes,
    );
  }

  Map<String, Object?> toMap() {
    return {
      subTable: subject.toMap(),
      dayTimeTable: dayTime.map((dayTime) => dayTime.toMap()).toList(),
      professorTable: professor.toMap(),
    };
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
    return '\nSubject: ${subject.toString()}, \nProfessor: ${professor.toString()}, \nDayTimes: ${dayTime.map((dt) => dt.toString()).toList()}';
  }
}

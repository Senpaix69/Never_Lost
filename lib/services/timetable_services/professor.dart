import 'package:my_timetable/services/constants.dart';
import 'package:flutter/material.dart';

@immutable
class Professor {
  final String name;
  final int? subId;
  final int? profId;
  final String? email;
  final String? office;
  final String? weekDay;
  final String? startTime;
  final String? endTime;

  const Professor({
    required this.name,
    this.subId,
    this.profId,
    this.office,
    this.weekDay,
    this.email,
    this.startTime,
    this.endTime,
  });

  Professor copyWith({
    int? subId,
    int? profId,
    String? name,
    String? office,
    String? email,
    String? weekDay,
    String? startTime,
    String? endTime,
  }) {
    return Professor(
      subId: subId ?? this.subId,
      profId: profId ?? this.profId,
      name: name ?? this.name,
      office: office ?? this.office,
      email: email ?? this.email,
      weekDay: weekDay ?? this.weekDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, Object?> toMap() {
    return {
      subIdColumn: subId,
      professorIdColumn: profId,
      professorNameColumn: name,
      professorEmailColumn: email,
      professorOfficeColumn: office,
      professorDayColumn: weekDay,
      professorStartTimeColumn: startTime,
      professorEndTimeColumn: endTime,
    };
  }

  factory Professor.fromMap(Map<String, Object?> map) {
    return Professor(
      name: map[professorNameColumn] as String,
      subId: map[subIdColumn] as int?,
      profId: map[professorIdColumn] as int?,
      email: map[professorEmailColumn] as String?,
      office: map[professorOfficeColumn] as String?,
      weekDay: map[professorDayColumn] as String?,
      startTime: map[professorStartTimeColumn] as String?,
      endTime: map[professorEndTimeColumn] as String?,
    );
  }

  @override
  int get hashCode =>
      name.hashCode ^
      office.hashCode ^
      subId.hashCode ^
      profId.hashCode ^
      weekDay.hashCode ^
      email.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Professor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          office == other.office &&
          weekDay == other.weekDay &&
          email == other.email &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  String toString() =>
      'Professor(id: $profId, name: $name, email: $email, office: $office, weekDay: $weekDay, startTime: $startTime, endTime: $endTime)';
}

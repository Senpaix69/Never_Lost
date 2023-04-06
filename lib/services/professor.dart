import 'package:my_timetable/constants/services.dart';
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

  Map<String, dynamic> toMap() {
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

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      name: map[professorNameColumn],
      subId: map[subIdColumn],
      profId: map[professorIdColumn],
      email: map[professorEmailColumn],
      office: map[professorOfficeColumn],
      weekDay: map[professorDayColumn],
      startTime: map[professorStartTimeColumn],
      endTime: map[professorEndTimeColumn],
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
      'Professor(name: $name, email: $email, office: $office, weekDay: $weekDay, startTime: $startTime, endTime: $endTime)';
}

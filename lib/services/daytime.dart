import 'package:flutter/material.dart';
import 'package:my_timetable/constants/services.dart';

@immutable
class DayTime {
  final int? subId;
  final String day;
  final String startTime;
  final String endTime;
  final String roomNo;

  const DayTime({
    this.subId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.roomNo,
  });

  Map<String, dynamic> toMap() {
    return {
      dayColumn: day,
      subIdColumn: subId,
      startTimeColumn: startTime,
      endTimeColumn: endTime,
      roomNoColumn: roomNo,
    };
  }

  DayTime copyWith({
    int? subId,
    String? day,
    String? startTime,
    String? endTime,
    String? roomNo,
  }) {
    return DayTime(
      subId: subId ?? this.subId,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomNo: roomNo ?? this.roomNo,
    );
  }

  factory DayTime.fromMap(Map<String, dynamic> map) {
    return DayTime(
      day: map[dayColumn],
      subId: map[subIdColumn],
      startTime: map[startTimeColumn],
      endTime: map[endTimeColumn],
      roomNo: map[roomNoColumn],
    );
  }

  @override
  String toString() {
    return '$startTime-$endTime';
  }
}

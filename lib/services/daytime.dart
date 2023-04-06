import 'package:flutter/material.dart';
import 'package:my_timetable/constants/services.dart';

@immutable
class DayTime {
  final int? subId;
  final int? id;
  final String day;
  final bool nextSlot;
  final bool currentSlot;
  final String startTime;
  final String endTime;
  final String roomNo;

  const DayTime({
    this.subId,
    this.id,
    this.nextSlot = false,
    this.currentSlot = false,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.roomNo,
  });

  Map<String, dynamic> toMap() {
    return {
      dayColumn: day,
      subIdColumn: subId,
      dayTimeIdColumn: id,
      startTimeColumn: startTime,
      endTimeColumn: endTime,
      roomNoColumn: roomNo,
    };
  }

  DayTime copyWith({
    int? subId,
    int? id,
    bool? nextSlot,
    bool? currentSlot,
    String? day,
    String? startTime,
    String? endTime,
    String? roomNo,
  }) {
    return DayTime(
      subId: subId ?? this.subId,
      id: id ?? this.id,
      day: day ?? this.day,
      nextSlot: nextSlot ?? this.nextSlot,
      currentSlot: currentSlot ?? this.currentSlot,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomNo: roomNo ?? this.roomNo,
    );
  }

  factory DayTime.fromMap(Map<String, dynamic> map) {
    return DayTime(
      day: map[dayColumn],
      subId: map[subIdColumn],
      id: map[dayTimeIdColumn],
      startTime: map[startTimeColumn],
      endTime: map[endTimeColumn],
      roomNo: map[roomNoColumn],
    );
  }

  @override
  String toString() {
    return 'Time: $startTime-$endTime, NextSlot: $nextSlot, CurrentSlot: $currentSlot';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayTime &&
          runtimeType == other.runtimeType &&
          subId == other.subId &&
          id == other.id &&
          day == other.day &&
          nextSlot == other.nextSlot &&
          currentSlot == other.currentSlot &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          roomNo == other.roomNo;

  @override
  int get hashCode =>
      subId.hashCode ^
      id.hashCode ^
      day.hashCode ^
      nextSlot.hashCode ^
      currentSlot.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      roomNo.hashCode;
}

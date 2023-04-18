import 'package:flutter/material.dart';
import 'package:my_timetable/services/constants.dart';

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

  Map<String, Object?> toMap() {
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

  factory DayTime.fromMap(Map<String, Object?> map) {
    return DayTime(
      day: map[dayColumn] as String,
      subId: map[subIdColumn] as int?,
      id: map[dayTimeIdColumn] as int?,
      startTime: map[startTimeColumn] as String,
      endTime: map[endTimeColumn] as String,
      roomNo: map[roomNoColumn] as String,
    );
  }

  @override
  String toString() {
    return 'ID: $id, Time: $startTime-$endTime, NextSlot: $nextSlot, CurrentSlot: $currentSlot';
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

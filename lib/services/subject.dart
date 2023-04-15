import 'package:flutter/material.dart';
import 'package:my_timetable/constants/services.dart';

@immutable
class Subject {
  final int? id;
  final String name;
  final String section;
  final int sched;

  const Subject({
    this.id,
    this.sched = 0,
    required this.section,
    required this.name,
  });

  Subject copyWith({
    int? id,
    int? sched,
    String? name,
    String? roomNo,
    String? section,
    String? professorName,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      sched: sched ?? this.sched,
      section: section ?? this.section,
    );
  }

  Map<String, Object?> toMap() {
    return {
      subIdColumn: id,
      subNameColumn: name,
      subSchedColumn: sched,
      subSectionColumn: section,
    };
  }

  factory Subject.fromMap(Map<String, Object?> map) {
    return Subject(
      id: map[subIdColumn] as int?,
      section: map[subSectionColumn] as String,
      sched: map[subSchedColumn] as int,
      name: map[subNameColumn] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sched == other.sched &&
          section == other.section;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ section.hashCode ^ sched.hashCode;

  @override
  String toString() {
    return 'Subject: $name, id: $id, section: $section, name: $name, sched: $sched';
  }
}

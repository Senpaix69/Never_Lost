import 'package:flutter/material.dart';
import 'package:my_timetable/constants/services.dart';

@immutable
class Subject {
  final int? id;
  final String name;
  final String section;

  const Subject({
    this.id,
    required this.section,
    required this.name,
  });

  Subject copyWith({
    int? id,
    String? name,
    String? roomNo,
    String? section,
    String? professorName,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      section: section ?? this.section,
    );
  }

  Map<String, Object?> toMap() {
    return {
      subIdColumn: id,
      subNameColumn: name,
      subSectionColumn: section,
    };
  }

  factory Subject.fromMap(Map<String, Object?> map) {
    return Subject(
      id: map[subIdColumn] as int?,
      section: map[subSectionColumn] as String,
      name: map[subNameColumn] as String,
    );
  }

  @override
  String toString() {
    return 'Subject: $name, id: $id, section: $section, name: $name';
  }
}

import 'package:flutter/material.dart';
import 'package:my_timetable/constants/services.dart';

@immutable
class Subject {
  final int? id;
  final String name;
  final String professorName;
  final String section;

  const Subject({
    this.id,
    required this.section,
    required this.name,
    required this.professorName,
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
      professorName: professorName ?? this.professorName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      subIdColumn: id,
      subNameColumn: name,
      subSectionColumn: section,
      subProfessorNameColumn: professorName,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map[subIdColumn],
      section: map[subSectionColumn],
      name: map[subNameColumn],
      professorName: map[subProfessorNameColumn],
    );
  }

  @override
  String toString() {
    return 'Subject, id: $id, section: $section, name: $name, professorName: $professorName';
  }
}

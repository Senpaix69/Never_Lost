import 'package:flutter/material.dart';
import 'package:my_timetable/constants/services.dart';

@immutable
class Subject {
  final int? id;
  final String name;
  final String professorName;

  const Subject({
    this.id,
    required this.name,
    required this.professorName,
  });

  Subject copyWith({
    int? id,
    String? name,
    String? roomNo,
    String? professorName,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      professorName: professorName ?? this.professorName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      subIdColumn: id,
      subNameColumn: name,
      subProfessorNameColumn: professorName,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map[subIdColumn],
      name: map[subNameColumn],
      professorName: map[subProfessorNameColumn],
    );
  }

  @override
  String toString() {
    return 'Subject, id: $id, name: $name, professorName: $professorName';
  }
}

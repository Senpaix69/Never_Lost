import 'package:flutter/material.dart' show immutable;
import 'package:neverlost/contants/database_contants.dart/database_constants.dart';

@immutable
class Todo {
  final int? id;
  final String text;
  final String? date;
  final int complete;
  final int reminder;

  const Todo({
    this.id,
    this.date,
    this.complete = 0,
    this.reminder = 0,
    required this.text,
  });

  Todo copyWith({
    int? id,
    String? text,
    String? date,
    int? complete,
    int? reminder,
  }) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      date: date ?? this.date,
      complete: complete ?? this.complete,
      reminder: reminder ?? this.reminder,
    );
  }

  Map<String, Object?> toMap() {
    return {
      todoIdColumn: id,
      todoTextColumn: text,
      todoDateColumn: date,
      todoCompleteColumn: complete,
      todoReminderColumn: reminder,
    };
  }

  factory Todo.fromMap(Map<String, Object?> map) {
    return Todo(
      id: map[todoIdColumn] as int?,
      text: map[todoTextColumn] as String,
      date: map[todoDateColumn] as String?,
      complete: map[todoCompleteColumn] as int,
      reminder: map[todoReminderColumn] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          date == other.date &&
          complete == other.complete &&
          reminder == other.reminder;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      date.hashCode ^
      complete.hashCode ^
      reminder.hashCode;

  @override
  String toString() {
    return 'Todo: {id: $id, text: $text, date: $date, complete: $complete, reminder: $reminder}';
  }
}

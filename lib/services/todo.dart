import 'package:flutter/material.dart';
import 'package:my_timetable/constants/services.dart';

@immutable
class Todo {
  final int? id;
  final String title;
  final String body;
  final String date;
  final int complete;

  const Todo({
    this.complete = 0,
    this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  Map<String, Object?> toMap() {
    return {
      todoIdColumn: id,
      todoTitleColumn: title,
      todoBodyColumn: body,
      todoDateColumn: date,
      todoCompleteColumn: complete,
    };
  }

  factory Todo.fromMap(Map<String, Object?> map) {
    return Todo(
      id: map[todoIdColumn] as int?,
      title: map[todoTitleColumn] as String,
      body: map[todoBodyColumn] as String,
      date: map[todoDateColumn] as String,
      complete: map[todoCompleteColumn] as int,
    );
  }

  Todo copyWith({
    int? id,
    String? title,
    String? body,
    String? date,
    int? complete,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      complete: complete ?? this.complete,
    );
  }

  @override
  String toString() {
    return "Todo: {id: $id, title: $title, body: $body, date: $date, complete: $complete}";
  }
}

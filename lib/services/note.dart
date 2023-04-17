import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:my_timetable/constants/services.dart';

@immutable
class Note {
  final int? id;
  final String title;
  final String body;
  final String date;
  final List<String>? images;

  const Note({
    this.id,
    this.images,
    required this.title,
    required this.body,
    required this.date,
  });

  Map<String, Object?> toMap() {
    return {
      noteIdColumn: id,
      noteTitleColumn: title,
      noteBodyColumn: body,
      noteDateColumn: date,
      noteImagesColumn: json.encode(images),
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map[noteIdColumn] as int?,
      title: map[noteTitleColumn] as String,
      body: map[noteBodyColumn] as String,
      date: map[noteDateColumn] as String,
      images: List<String>.from(
        json.decode(map[noteImagesColumn] as String),
      ),
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? body,
    String? date,
    List<String>? images,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      images: images ?? this.images,
    );
  }

  @override
  String toString() {
    return "Todo: {id: $id, title: $title, body: $body, date: $date, images: [${json.encode(images)}]\n";
  }
}

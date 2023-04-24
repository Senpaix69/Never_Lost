import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_timetable/services/constants.dart';

@immutable
class Note {
  final int? id;
  final String title;
  final String body;
  final String date;
  final String category;
  final List<String> images;

  const Note({
    this.id,
    required this.title,
    required this.body,
    required this.date,
    this.category = "",
    this.images = const [],
  });

  Map<String, Object?> toMap() {
    return {
      noteIdColumn: id,
      noteTitleColumn: title,
      noteBodyColumn: body,
      noteDateColumn: date,
      noteCategoryColumn: category,
      noteImagesColumn: json.encode(images),
    };
  }

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: map[noteIdColumn] as int?,
      title: map[noteTitleColumn] as String,
      body: map[noteBodyColumn] as String,
      date: map[noteDateColumn] as String,
      category: map[noteCategoryColumn] as String,
      images: List<String>.from(
        json.decode(
          map[noteImagesColumn] as String,
        ) as Iterable<dynamic>,
      ),
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? body,
    String? date,
    String? category,
    List<String>? images,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      category: category ?? this.category,
      images: images ?? this.images,
    );
  }

  @override
  String toString() {
    return "Todo: {id: $id, title: $title, body: $body, date: $date, category: $category, images: [${json.encode(images)}]\n";
  }
}

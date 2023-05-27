import 'package:flutter/material.dart' show immutable;
import 'package:neverlost/contants/database_contants.dart/database_constants.dart';

@immutable
class Folder {
  final int? id;
  final String name;

  const Folder({
    this.id,
    required this.name,
  });

  Map<String, Object?> toMap() {
    return {
      folderIdColumn: id,
      folderNameColumn: name,
    };
  }

  factory Folder.fromMap(Map<String, Object?> map) {
    return Folder(
      id: map[folderIdColumn] as int?,
      name: map[folderNameColumn] as String,
    );
  }

  Folder copyWith({
    int? id,
    String? name,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return "Folder: {id: $id, name: $name";
  }
}

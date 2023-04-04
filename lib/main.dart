import 'package:flutter/material.dart';
import 'package:my_timetable/constants/routes.dart';
import 'package:my_timetable/pages/add_subject.dart';
import 'package:my_timetable/pages/my_home.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Never Lost",
      home: const MyHome(),
      routes: {
        home: (context) => const MyHome(),
        addSubject: (context) => const AddSubject(),
      },
    ),
  );
}

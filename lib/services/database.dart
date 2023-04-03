import 'package:my_timetable/constants/services.dart';
import 'package:my_timetable/services/daytime.dart';
import 'package:my_timetable/services/subject.dart';
import 'package:my_timetable/services/timeTable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  List<TimeTable> _cachedTimeTables = [];
  late final StreamController<List<TimeTable>> _timeTableController;
  Stream<List<TimeTable>> get allTimeTable => _timeTableController.stream;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    _timeTableController =
        StreamController<List<TimeTable>>.broadcast(onListen: () {
      _timeTableController.sink.add(_cachedTimeTables);
    });
  }

  Future<Database> open() async {
    if (_database != null) {
      return _database!;
    }
    await _initDatabase();
    return _database!;
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'subject.db');

    final db = await openDatabase(path);
    // await db.execute("DROP TABLE IF EXISTS $subTable");
    // await db.execute("DROP TABLE IF EXISTS $dayTimeTable");
    await db.execute(createSubTable);
    await db.execute(createDayTimeTable);
    _catchAllTimeTables();
    _database = db;
  }

  Future<void> _catchAllTimeTables() async {
    final allTimeTables = await getTimeTableStream();
    _cachedTimeTables = allTimeTables.toList();
    _timeTableController.add(_cachedTimeTables);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> insertTimeTable({
    required Subject subject,
    required List<DayTime> daytimes,
  }) async {
    int id = await insertSubject(subject: subject);
    final myList = await insertDayTime(daytimes: daytimes, subId: id);
    final TimeTable newTime = TimeTable(subject: subject, dayTime: myList);
    if (id > 0) {
      _cachedTimeTables.add(newTime);
      _timeTableController.add(_cachedTimeTables);
    }
  }

  Future<int> insertSubject({required Subject subject}) async {
    final db = await open();
    final id = await db.insert(subTable, subject.toMap());
    return id;
  }

  Future<List<DayTime>> insertDayTime({
    required List<DayTime> daytimes,
    required int subId,
  }) async {
    final db = await open();
    List<DayTime> myList = [];
    for (DayTime day in daytimes) {
      myList.add(day.copyWith(subId: subId));
      await db.insert(dayTimeTable, myList.last.toMap());
    }
    return myList;
  }

  Future<void> updateTimeTable({
    required Subject subject,
    required List<DayTime> dayTimes,
  }) async {
    await deleteTimeTable(id: subject.id!);
    await insertTimeTable(subject: subject, daytimes: dayTimes);
  }

  Future<void> deleteTimeTable({required int id}) async {
    final db = await open();
    final deleteSubjectResult = await db.delete(
      subTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteSubjectResult == 0) {
      return;
    }
    _cachedTimeTables.removeWhere((s) => s.subject.id == id);
    _timeTableController.add(_cachedTimeTables);
  }

  Future<Iterable<TimeTable>> getTimeTableStream() async {
    if (_cachedTimeTables.isNotEmpty) {
      return _cachedTimeTables;
    }
    final db = await open();
    final dayTimes = await db.query(dayTimeTable);
    final subjectIds = dayTimes.map((dt) => dt[subIdColumn] as int).toSet();
    final subjects = <Subject>[];
    for (final id in subjectIds) {
      final sub = await db.query(
        subTable,
        where: '$subIdColumn = ?',
        whereArgs: [id],
      );
      if (sub.isNotEmpty) {
        subjects.add(Subject.fromMap(sub.first));
      }
    }
    _cachedTimeTables = subjects.map((sub) {
      final timeSlots = dayTimes
          .where((dt) => dt[subIdColumn] == sub.id)
          .map((dt) => DayTime.fromMap(dt))
          .toList();
      return TimeTable(subject: sub, dayTime: timeSlots);
    }).toList();
    return _cachedTimeTables;
  }
}

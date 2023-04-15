import 'package:my_timetable/constants/services.dart';
import 'package:my_timetable/services/daytime.dart';
import 'package:my_timetable/services/professor.dart';
import 'package:my_timetable/services/subject.dart';
import 'package:my_timetable/services/timeTable.dart';
import 'package:my_timetable/services/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  List<TimeTable> _cachedTimeTables = [];
  late final StreamController<List<TimeTable>> _timeTableController;
  Stream<List<TimeTable>> get allTimeTable => _timeTableController.stream;

  List<Todo> _cachedTodos = [];
  late final StreamController<List<Todo>> _todosController;
  Stream<List<Todo>> get allTodos => _todosController.stream;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    _timeTableController =
        StreamController<List<TimeTable>>.broadcast(onListen: () {
      _timeTableController.sink.add(_cachedTimeTables);
    });
    _todosController = StreamController<List<Todo>>.broadcast(onListen: () {
      _todosController.sink.add(_cachedTodos);
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
    // await db.execute("DROP TABLE IF EXISTS $professorTable");
    // await db.execute("DROP TABLE IF EXISTS $todoTable");
    await db.execute(createSubTable);
    await db.execute(createDayTimeTable);
    await db.execute(createProfessorTable);
    await db.execute(createTodoTable);
    await db.execute('PRAGMA foreign_keys = ON;');
    _catchAllTimeTables();
    _catchAllTodos();
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
    required Professor professor,
    required List<DayTime> daytimes,
  }) async {
    final sub = await insertSubject(subject: subject);
    if (sub.id != null && sub.id! > 0) {
      final myList = await insertDayTime(daytimes: daytimes, subId: sub.id!);
      final prof = await insertProfessor(professor: professor, subId: sub.id!);
      final newTime = TimeTable(subject: sub, professor: prof, dayTime: myList);
      _cachedTimeTables.add(newTime);
      _timeTableController.add(_cachedTimeTables);
    }
  }

  Future<Subject> insertSubject({required Subject subject}) async {
    final db = await open();
    final id = await db.insert(subTable, subject.toMap());
    return subject.copyWith(id: id);
  }

  Future<void> updateSubject({required Subject subject}) async {
    final db = await open();
    await db.update(
      subTable,
      subject.toMap(),
      where: "$subIdColumn = ?",
      whereArgs: [subject.id],
    );
  }

  Future<Professor> insertProfessor({
    required Professor professor,
    required int subId,
  }) async {
    final db = await open();
    final id = await db.insert(
        professorTable, professor.copyWith(subId: subId).toMap());
    return professor.copyWith(
      profId: id,
      subId: subId,
    );
  }

  Future<void> updateProfessor({required Professor prof}) async {
    final db = await open();
    await db.update(
      professorTable,
      prof.toMap(),
      where: "$professorIdColumn = ?",
      whereArgs: [prof.profId],
    );
  }

  Future<List<DayTime>> insertDayTime({
    required List<DayTime> daytimes,
    required int subId,
  }) async {
    final db = await open();
    List<DayTime> myList = [];
    for (DayTime day in daytimes) {
      final DayTime daytime = day.copyWith(subId: subId);
      int id = await db.insert(dayTimeTable, daytime.toMap());
      myList.add(
        daytime.copyWith(id: id),
      );
    }
    return myList;
  }

  Future<List<DayTime>> updateDayTime({
    required List<DayTime> daytimes,
    required int subId,
  }) async {
    final db = await open();

    await db.delete(
      dayTimeTable,
      where: "$subIdColumn = ?",
      whereArgs: [subId],
    );
    return await insertDayTime(daytimes: daytimes, subId: subId);
  }

  Future<void> updateTimeTable({
    required Subject subject,
    required Professor professor,
    required List<DayTime> dayTimes,
  }) async {
    await updateSubject(subject: subject);
    await updateProfessor(prof: professor);
    List<DayTime> daytimes =
        await updateDayTime(daytimes: dayTimes, subId: subject.id!);
    final newTime =
        TimeTable(subject: subject, professor: professor, dayTime: daytimes);
    _cachedTimeTables.removeWhere((s) => s.subject.id == subject.id);
    _cachedTimeTables.add(newTime);
    _timeTableController.add(_cachedTimeTables);
  }

  Future<void> deleteTimeTable({required int id}) async {
    final db = await open();
    final deleteSubjectResult = await db.delete(
      subTable,
      where: '$subIdColumn = ?',
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
    final profs = <Professor>[];
    for (final id in subjectIds) {
      final sub = await db.query(
        subTable,
        where: '$subIdColumn = ?',
        whereArgs: [id],
      );
      final prof = await db.query(
        professorTable,
        where: '$subIdColumn = ?',
        whereArgs: [id],
      );
      if (sub.isNotEmpty) {
        subjects.add(Subject.fromMap(sub.first));
      }
      if (prof.isNotEmpty) {
        profs.add(Professor.fromMap(prof.first));
      }
    }
    _cachedTimeTables = subjects.map((sub) {
      final timeSlots = dayTimes
          .where((dt) => dt[subIdColumn] == sub.id)
          .map((dt) => DayTime.fromMap(dt))
          .toList();
      final prof = profs.firstWhere((prof) => prof.subId == sub.id);
      return TimeTable(subject: sub, professor: prof, dayTime: timeSlots);
    }).toList();
    return _cachedTimeTables;
  }

  Future<Iterable<Todo>> getTodosStream() async {
    if (_cachedTodos.isNotEmpty) {
      return _cachedTodos;
    }
    final db = await open();
    final todos = await db.query(todoTable);
    _cachedTodos = todos.map((todoMap) => Todo.fromMap(todoMap)).toList();
    return _cachedTodos;
  }

  Future<Todo> insertTodo({required Todo todo}) async {
    final db = await open();
    final id = await db.insert(todoTable, todo.toMap());
    final toDo = todo.copyWith(id: id);
    _cachedTodos.add(toDo);
    _todosController.add(_cachedTodos);
    return toDo;
  }

  Future<void> updateTodo({required Todo todo}) async {
    final db = await open();
    final updatedRows = await db.update(
      todoTable,
      todo.toMap(),
      where: "$todoIdColumn = ?",
      whereArgs: [todo.id],
    );
    if (updatedRows == 0) {
      return;
    }
    final index = _cachedTodos.indexWhere((t) => t.id == todo.id);
    if (index >= 0) {
      _cachedTodos[index] = todo;
      _todosController.add(_cachedTodos);
    }
  }

  Future<int> deleteTodo({required int id}) async {
    final db = await open();
    final changes =
        await db.delete(todoTable, where: "$todoIdColumn = ?", whereArgs: [id]);
    _cachedTodos.removeWhere((ele) => ele.id == id);
    _todosController.add(_cachedTodos);
    return changes;
  }

  Future<void> _catchAllTodos() async {
    final todos = await getTodosStream();
    _cachedTodos = todos.toList();
    _todosController.add(_cachedTodos);
  }
}

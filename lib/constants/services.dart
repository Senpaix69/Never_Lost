// !Subject Constants
const subTable = "subject";
const subIdColumn = "sub_id";
const subNameColumn = "sub_name";
const subSectionColumn = 'sub_section';
const createSubTable = '''
CREATE TABLE IF NOT EXISTS "$subTable" (
  "$subIdColumn" INTEGER NOT NULL,
  "$subNameColumn" TEXT NOT NULL, 
  "$subSectionColumn" TEXT NOT NULL,
  PRIMARY KEY("$subIdColumn" AUTOINCREMENT)
  );
''';

// !DayTime Constants
const dayTimeTable = 'dayTime';
const dayTimeIdColumn = 'id';
const dayColumn = 'day';
const startTimeColumn = 'start_time';
const endTimeColumn = 'end_time';
const roomNoColumn = 'room_no';
const createDayTimeTable = '''
CREATE TABLE IF NOT EXISTS "$dayTimeTable" (
	  "$dayTimeIdColumn"	INTEGER NOT NULL,
	  "$subIdColumn"	INTEGER NOT NULL,
	  "$dayColumn"	TEXT NOT NULL,
    "$startTimeColumn" TEXT NOT NULL,
    "$endTimeColumn" TEXT NOT NULL,
	  "$roomNoColumn"	TEXT NOT NULL DEFAULT 0,
    FOREIGN KEY("$subIdColumn") REFERENCES "$subTable"("$subIdColumn") ON DELETE CASCADE,
	  PRIMARY KEY("$dayTimeIdColumn" AUTOINCREMENT)
);''';

// !Professor Constants
const professorTable = 'professor';
const professorIdColumn = 'prof_id';
const professorNameColumn = 'prof_name';
const professorEmailColumn = 'prof_email';
const professorOfficeColumn = 'prof_office';
const professorDayColumn = 'prof_weekDay';
const professorStartTimeColumn = 'prof_startTime';
const professorEndTimeColumn = 'prof_endTime';
const createProfessorTable = '''
CREATE TABLE IF NOT EXISTS "$professorTable" (
	  "$professorIdColumn"	INTEGER NOT NULL,
	  "$subIdColumn"	INTEGER NOT NULL,
	  "$professorNameColumn"	TEXT NOT NULL,
    "$professorEmailColumn" TEXT NULL,
    "$professorStartTimeColumn" TEXT NULL,
    "$professorEndTimeColumn" TEXT NULL,
    "$professorDayColumn" TEXT NULL,
	  "$professorOfficeColumn"	TEXT NULL,
    FOREIGN KEY("$subIdColumn") REFERENCES "$subTable"("$subIdColumn") ON DELETE CASCADE,
	  PRIMARY KEY("$professorIdColumn" AUTOINCREMENT)
);''';

// Todo Constants
const todoTable = 'todo';
const todoIdColumn = 'todo_id';
const todoTitleColumn = 'todo_title';
const todoBodyColumn = 'todo_body';
const todoDateColumn = 'todo_date';
const todoCompleteColumn = 'todo_complete';
const createTodoTable = '''
CREATE TABLE IF NOT EXISTS "$todoTable" (
  "$todoIdColumn" INTEGER NOT NULL,
  "$todoTitleColumn" TEXT NOT NULL,
  "$todoBodyColumn" TEXT NOT NULL,
  "$todoDateColumn" TEXT NOT NULL,
  "$todoCompleteColumn" INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY("$todoIdColumn" AUTOINCREMENT)
);''';

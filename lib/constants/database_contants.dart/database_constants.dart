// ! TableNames
const tables = [
  {
    'name': noteTable,
    'createStatement': createNoteTable,
  },
  {
    'name': subTable,
    'createStatement': createSubTable,
  },
  {
    'name': dayTimeTable,
    'createStatement': createDayTimeTable,
  },
  {
    'name': todoTable,
    'createStatement': createTodoTable,
  },
  {
    'name': professorTable,
    'createStatement': createProfessorTable,
  },
  {
    'name': folderTable,
    'createStatement': createFolderTable,
  },
];

// !Subject Constants
const subTable = "subject";
const subIdColumn = "sub_id";
const subNameColumn = "sub_name";
const subSchedColumn = 'sched';
const subSectionColumn = 'sub_section';
const createSubTable = '''
CREATE TABLE IF NOT EXISTS "$subTable" (
  "$subIdColumn" INTEGER NOT NULL,
  "$subNameColumn" TEXT NOT NULL,
  "$subSectionColumn" TEXT NOT NULL,
	"$subSchedColumn"	INTEGER NOT NULL DEFAULT 0,
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

//! Note Constants
const noteTable = 'note';
const noteIdColumn = 'note_id';
const noteTitleColumn = 'note_title';
const noteBodyColumn = 'note_body';
const noteCategoryColumn = 'note_category';
const noteDateColumn = 'note_date';
const noteFilesColumn = 'note_files';
const noteImagesColumn = 'note_images';
const noteImpColumn = 'note_imp';
const createNoteTable = '''
CREATE TABLE IF NOT EXISTS "$noteTable" (
  "$noteIdColumn" INTEGER NOT NULL,
  "$noteTitleColumn" TEXT NOT NULL,
  "$noteBodyColumn" TEXT NOT NULL,
  "$noteImpColumn" INTEGER NOT NULL DEFAULT 0,
  "$noteCategoryColumn" TEXT,
  "$noteDateColumn" TEXT NOT NULL,
  "$noteFilesColumn" TEXT NOT NULL,
  "$noteImagesColumn" TEXT NOT NULL,
  PRIMARY KEY("$noteIdColumn" AUTOINCREMENT)
);''';

//! Todo Constants
const todoTable = 'todo';
const todoIdColumn = 'todo_id';
const todoTextColumn = 'todo_text';
const todoDateColumn = 'todo_date';
const todoCompleteColumn = 'todo_complete';
const todoReminderColumn = 'todo_reminder';
const createTodoTable = '''
CREATE TABLE IF NOT EXISTS "$todoTable" (
  "$todoIdColumn" INTEGER NOT NULL,
  "$todoTextColumn" TEXT NOT NULL,
  "$todoDateColumn" TEXT NULL,
  "$todoCompleteColumn" INTEGER DEFAULT 0,
  "$todoReminderColumn" INTEGER DEFAULT 0,
  PRIMARY KEY("$todoIdColumn" AUTOINCREMENT)
);''';

//! Folder Constants
const folderTable = 'folder';
const folderIdColumn = 'folder_id';
const folderNameColumn = 'folder_name';
const createFolderTable = '''
CREATE TABLE IF NOT EXISTS "$folderTable" (
  "$folderIdColumn" INTEGER NOT NULL,
  "$folderNameColumn" TEXT NOT NULL,
  PRIMARY KEY("$folderIdColumn" AUTOINCREMENT)
);''';

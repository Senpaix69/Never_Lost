// Subject Constants
const subTable = "subject";
const subIdColumn = "sub_id";
const subNameColumn = "sub_name";
const subSectionColumn = 'sub_section';
const subProfessorNameColumn = "sub_professorName";
const createSubTable = '''
CREATE TABLE IF NOT EXISTS "subject" (
  "sub_id" INTEGER NOT NULL,
  "sub_name" TEXT NOT NULL, 
  "sub_section" TEXT NOT NULL,
  "sub_professorName" TEXT NOT NULL,
  PRIMARY KEY("sub_id" AUTOINCREMENT)
  );
''';

// DayTime Constants
const dayTimeTable = 'dayTime';
const dayColumn = 'day';
const startTimeColumn = 'start_time';
const endTimeColumn = 'end_time';
const roomNoColumn = 'room_no';
const createDayTimeTable = '''
CREATE TABLE IF NOT EXISTS "dayTime" (
	  "id"	INTEGER NOT NULL,
	  "sub_id"	INTEGER NOT NULL,
	  "day"	TEXT NOT NULL,
    "start_time" TEXT NOT NULL,
    "end_time" TEXT NOT NULL,
	  "room_no"	INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY("sub_id") REFERENCES "subject"("sub_id"),
	  PRIMARY KEY("id" AUTOINCREMENT)
);''';

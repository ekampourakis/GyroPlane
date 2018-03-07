// *** COMMENT CODE *** //
// *** ADD PLAYBACK *** //

Table LogTable;

boolean LogInitialized = false;
boolean LogSaved;
int FrameCount = 0;

void InitLog() {
  LogTable = new Table();
  LogTable.addColumn("Frame");
  LogTable.addColumn("X");
  LogTable.addColumn("Y");
  LogTable.addColumn("Z");
  LogTable.addColumn("W");
  LogTable.addColumn("Timestamp");
  LogInitialized = true;
  LogSaved = false;
  FrameCount = 0;
}

void EndLog() {
  if (!LogSaved) { SaveLog("TempLog.csv"); }   
  LogInitialized = false;
}

void SaveLog(String Filename) {
  saveTable(LogTable, Filename);
  LogSaved = true;
  LogInitialized = false;
}

void Log(float[] Quaternions) {
  if (!LogInitialized) { InitLog(); }
  TableRow newRow = LogTable.addRow();
  newRow.setInt("Frame", FrameCount++);
  newRow.setFloat("X", Quaternions[0]);
  newRow.setFloat("Y", Quaternions[0]);
  newRow.setFloat("Z", Quaternions[0]);
  newRow.setFloat("W", Quaternions[0]);
  newRow.setLong("Timestamp", millis());
}
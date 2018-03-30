private boolean StreamInitialized = false;

long LastRealtimeFrame = 0;
long RealtimeFrameDelay = 0;

int CurrentStreamFrame = 0;

int TotalStreamFrames = 0;

Table StreamTable;

boolean RequiresPlayback = false;

float[] StreamQuat = new float[4];

int PlaybackDelay = 1;

void InitializeStream(File selection) {
  if (selection != null) {
    // Load table from file 
    StreamTable = loadTable(selection.getAbsolutePath());
    TotalStreamFrames = StreamTable.getRowCount() - 1;
    StreamInitialized = true;
    PlayerVisible = true;
  }
}

void CloseStream() {
  if (StreamInitialized) { StreamInitialized = false; }
}

void TempInit() {
  //InitializeStream("log.csv");
}

void DoPlayback() {
  // here create a select mode block
  // for now just call realtime
  Realtime();
  if (RequiresPlayback) {
    rotate(toRotate[0], -toRotate[1], toRotate[3], toRotate[2]);
  }
}

boolean NextFrame() { return ForwardFrames(1); }

void PreviousFrame() { BackwardFrames(1); }

long GetFrameDelay(int Frame) {
  if (TotalStreamFrames > Frame + 1) { return (StreamTable.getRow(Frame + 2).getLong(5) - StreamTable.getRow(Frame + 1).getLong(5)); }
  return 0;
}

void Realtime() {
  if (millis() > LastRealtimeFrame + RealtimeFrameDelay) {
    if (NextFrame()) {
      LastRealtimeFrame = millis();
      RealtimeFrameDelay = GetFrameDelay(CurrentStreamFrame++); //maybe its frame + 1 to check but lets see
    } 
  }
}

boolean ForwardFrames(int Frames) {
  if (StreamInitialized) {
    if (TotalStreamFrames > CurrentStreamFrame + Frames) {
      TableRow TmpRow = StreamTable.getRow(CurrentStreamFrame + Frames + 1);
      Quat.set(TmpRow.getFloat(1), TmpRow.getFloat(2), TmpRow.getFloat(3), TmpRow.getFloat(4));
      toRotate = Tra.multiply(Off.multiply(Quat)).toAxisAngle();
      RequiresPlayback = true;
      return true;
    }
  }
  return false;  
}

void BackwardFrames(int Frames) {
  // check if previous frame {Frames} exists
  // if it does call 
}
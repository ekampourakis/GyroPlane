private boolean StreamInitialized = false;

long LastRealtimeFrame = 0;
long RealtimeFrameDelay = 0;

int CurrentStreamFrame = 0;

private int TotalStreamFrames;

Table StreamTable;

boolean RequiresPlayback = false;

float[] StreamQuat = new float[4];

int PlaybackDelay = 1;

void InitializeStream(String PlaybackFile) {
  if (!StreamInitialized) {
    // Load table from file 
    // TotalStreamFrames = something;
    StreamTable = loadTable(PlaybackFile);
    TotalStreamFrames = StreamTable.getRowCount() - 1;
    StreamInitialized = true;
  }
}

void CloseStream() {
  if (StreamInitialized) { StreamInitialized = false; }
}

void DoPlayback() {
  InitializeStream("data/Test.log");
  // here create a select mode block
  // for now just call realtime
  Realtime();
  if (RequiresPlayback) {
    rotate(StreamQuat[0], -StreamQuat[1], StreamQuat[3], StreamQuat[2]);
  }
}

int StreamFrames() { return TotalStreamFrames; }

boolean NextFrame() { return ForwardFrames(1); }

void PreviousFrame() { BackwardFrames(1); }

long GetFrameDelay(int Frame) {
  if (StreamFrames() > Frame + 1) { return (StreamTable.getRow(Frame + 2).getLong("Timestamp") - StreamTable.getRow(Frame + 1).getLong("Timestamp")); }
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
    if (StreamFrames() > CurrentStreamFrame + Frames) {
      TableRow TmpRow = StreamTable.getRow(CurrentStreamFrame + Frames + 1);
      StreamQuat[0] = TmpRow.getFloat("X");
      StreamQuat[1] = TmpRow.getFloat("Y");
      StreamQuat[2] = TmpRow.getFloat("Z");
      StreamQuat[3] = TmpRow.getFloat("W");
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
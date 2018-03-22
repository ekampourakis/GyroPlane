int PlaybackPercent = 0;
boolean PlayerVisible = false;

RoundButton CloseButton, FirstButton, PreviousButton, NextButton, PlayButton, HalfButton, QuarterButton;

void InitializePlayer() {
  CloseButton = new RoundButton(width - 30, 10, 20, "X");
  int StartLoc = (width - 230) / 2;
  FirstButton = new RoundButton(StartLoc, height - 40, 30, "|<");
  FirstButton.SetOffset(5);
  PreviousButton = new RoundButton(StartLoc + 40, height - 40, 30, "<");
  PreviousButton.SetOffset(5);
  NextButton = new RoundButton(StartLoc + 80, height - 40, 30, ">");
  NextButton.SetOffset(5);
  PlayButton = new RoundButton(StartLoc + 120, height - 40, 30, "|>");
  PlayButton.SetOffset(5);
  HalfButton = new RoundButton(StartLoc + 160, height - 40, 30, "½");
  HalfButton.SetOffset(5);
  QuarterButton = new RoundButton(StartLoc + 200, height - 40, 30, "¼");
  QuarterButton.SetOffset(5);
}

void DrawPlayer() {
  // Draw close button
  CloseButton.Draw();
  // Draw timebar
  DrawTimeBar();
  // Draw frame counter
  DrawTimeInfo();
}


void DrawTimeInfo() {
  
}

void DrawTimeBar() {
  stroke(255); // White
  // Draw white line
  fill(255); // White
  noStroke();
  rect(20, height - 60, width - 40, 10, 5);
  // Fill played line
  fill(128); // Gray
  float EndLoc = 20 + ((width - 40) * PlaybackPercent / 1000);
  rect(20, height - 60, EndLoc - 20, 10, 5);
  // Draw slider dot
  stroke(0);
  fill(255, 255, 255); // White
  ellipse(EndLoc, height - 55, 20, 20);
  noStroke();
  // Draw buttons
  DrawTimeBarButtons();
}

void PlaybackBarHandler() {
  // Handle click and or slide
  if (mouseX >= 20 && mouseX <= width - 20 && mouseY >= height - 60 && mouseY <= height - 50) {
    PlaybackPercent = int(map(mouseX, 10, width - 20, 0, 1000));
  }
}

void PlayerCloseHandler() {
  if (CloseButton.MouseOver()) {
    PlayerVisible = false;
  }
}

int FrameToBarValue(int CurrentFrame, int MaxFrames) {
  return int(map(CurrentFrame, 0, MaxFrames, 0, 1000));
}

void DrawTimeBarButtons() {
  FirstButton.Draw(); 
  PreviousButton.Draw();  
  NextButton.Draw();
  PlayButton.Draw();
  HalfButton.Draw();
  QuarterButton.Draw();
}

void PlaybackButtonsHandler() {
  if (FirstButton.MouseOver()) {
    CurrentStreamFrame = 0;
    // And also pause it
  } else if (PreviousButton.MouseOver()) {
    
  } else if (NextButton.MouseOver()) {
    
  } else if (PlayButton.MouseOver()) {
    
  } else if (HalfButton.MouseOver()) {
    PlaybackDelay = 2;
  } else if (QuarterButton.MouseOver()) {
    PlaybackDelay = 4;
  }
}
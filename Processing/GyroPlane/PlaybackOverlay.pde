int PlaybackPercent = 0;

void DrawTimeBar() {
  stroke(255, 255, 255);
  // Draw white line
  fill(255, 255, 255, 32); // White
  noStroke();
  rect(10, height - 20, width - 20, 10, 5);
  // Fill played line
  fill(0, 0, 0, 192); // Dark gray
  float EndLoc = 10 + ((width - 20) * PlaybackPercent / 1000);
  rect(10, height - 20, EndLoc, 10, 5);
  // Draw slider dot
  fill(255, 255, 255); // Red
  ellipse(EndLoc, height - 15, 20, 20);
  // Draw buttons
  DrawPlaybackButtons();
}

void PlaybackBarHandler() {
  // Handle click and or slide
  if (mouseX >= 10 && mouseX <= width - 20 && mouseY >= height - 20 && mouseY <= height - 10) {
    PlaybackPercent = int(map(mouseX, 10, width - 20, 0, 1000));
  }
}

int FrameToBarValue(int CurrentFrame, int MaxFrames) {
  return int(map(CurrentFrame, 0, MaxFrames, 0, 1000));
}

void DrawPlaybackButtons() {
  // Draw first frame button
  // Draw previous frame button
  // Draw next frame button  
  // Draw realtime play/pause button
  // Draw half speed play/pause button
  // Draw quarter speed play/pause button
}
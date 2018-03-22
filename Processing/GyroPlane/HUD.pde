void DrawHUD() {
  
  // Display refresh rate indicator at the top right corner
  // To reduce flickering update indicator at certain frequency
  if (millis() - LastFrequencyUpdate > (1000 / IndicatorFPS)) {
    LastFrequency = Frequency;
    LastFrequencyUpdate = millis();
  }
  textSize(16);
  textAlign(RIGHT);
  if (millis() - LastPacket > DisconnectedInterval) {
    fill(255, 0, 0); // Red
    text("Connection lost", width - 400, 0, 400, 20);
    // Connection lost thus we need to be recalibrate
    Calibrated = false;
    Connected = false;
  } else {
    fill(255, 255, 0); // Yellow
    text(LastFrequency + " Hz", width - 400, 0, 400, 20);
    // Refresh rate is greater than zero so we are connected
    Connected = true;
  }
  
  // If module connected and level then consider it calibrated
  if (!Calibrated) {
    if (abs(Quat.x) < CalibrationSensitivity && abs(Quat.y) < CalibrationSensitivity && Connected) {
      Calibrated = true;
    }
  }
  
  // Display calibration indicators at the top left corner
  textAlign(LEFT);
  if (Calibrated) {   
    fill(0, 255, 0); // Green
    text("Calibrated", 2, 0, 150, 20); 
  } else {
    fill(255, 0, 0); // Red
    String Dots = "";
    if (millis() - LastDot > DotDelay) {
      if (DotAmount < MaxDots) {
        DotAmount++;
      } else {
        DotAmount = 0;
      }
      LastDot = millis();
    }
    for (int Index = 0; Index < DotAmount; Index++) {
      Dots += ".";
    }
    if (Connected) {
      text("Calibrating" + Dots, 2, 0, 150, 20);
    } else {
      text("Connecting" + Dots, 2, 0, 150, 20);
    }
  }

  // Display latest quaternions at the bottom left corner
  textAlign(LEFT);
  fill(255, 16, 32); // Red
  text("X: " + Quat.x, 2, height - 80, 200, 20);
  fill(16, 255, 16); // Green
  text("Y: " + Quat.y, 2, height - 60, 200, 20);
  fill(16, 128, 255); // Blue
  text("Z: " + Quat.z, 2, height - 40, 200, 20);
  fill(255); // White
  text("W: " + Quat.w, 2, height - 20, 200, 20);
  
  // Display latest gravity vectors at the bottome left corner
  fill(255); // White
  text("Gravity", 200, height - 80, 200, 20);
  fill(255, 16, 32); // Red
  text("X: " + -Gravity[0], 200, height - 60, 200, 20);
  fill(16, 255, 16); // Green
  text("Y: " + Gravity[2], 200, height - 40, 200, 20);
  fill(16, 128, 255); // Blue
  text("Z: " + Gravity[1], 200, height - 20, 200, 20);
  
  // Display latest Euler angles at the bottome left corner
  fill(255); // White
  text("Euler", 400, height - 80, 200, 20);
  fill(255, 16, 32); // Red
  text("X: " + Euler[0], 400, height - 60, 200, 20);
  fill(16, 255, 16); // Green
  text("Y: " + Euler[1], 400, height - 40, 200, 20);
  fill(16, 128, 255); // Blue
  text("Z: " + Euler[2], 400, height - 20, 200, 20);
  
  // Display latest yaw/pitch/roll angles
  fill(255); // White
  text("Yaw/Pitch/Roll", 600, height - 80, 200, 20);
  fill(16, 255, 16); // Green
  text("Y: " + ypr[0], 600, height - 60, 200, 20);
  fill(255, 16, 32); // Red
  text("P: " + ypr[2], 600, height - 40, 200, 20);
  fill(16, 128, 255); // Blue
  text("R: " + ypr[1], 600, height - 20, 200, 20);
  
  // Display angle offsets
  fill(255); // White
  text("Offsets", 800, height - 80, 200, 20);
  fill(16, 255, 16); // Green
  //text("Y: " + YawOffset, 800, height - 60, 200, 20);
  text("Angle: " + int(int((Gravity[1] >= 0 ? 0 : 180)) + degrees(asin(Gravity[2]))), 800, height - 60, 200, 20);
  
  // Display logging information
  fill(255); // White
  text("Logging", 900, height - 80, 200, 20);
  if (Logging) {
    fill(16, 255, 16); // Green
  } else {
    fill(255, 16, 32); // Red
  }
  text(Logging ? "Capturing" : "Stopped", 900, height - 60, 200, 20);
  fill(255); // White
  text("Frames: " + FrameCount, 900, height - 40, 200, 20);
}

void DrawButtons() {
  
  // Draw open playback button
  fill(255, 255, 0); // Yellow
  rect(width - 180 - 10, height - 40 - 10, 180, 40, 15);
  fill(0); // Black
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Playback", width - 180 - 10, height - 40 - 10, 180, 40);

  // Draw hide HUD button
  fill(255, 255, 0); // Yellow
  rect(width - 180 - 10, height - 90 - 10, 180, 40, 15);
  fill(0); // Black
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Hide HUD", width - 180 - 10, height - 90 - 10, 180, 40);
  
  // Draw show/hide axes button
  fill(255, 255, 0); // Yellow
  rect(width - 180 - 10, height - 140 - 10, 180, 40, 15);
  fill(0); // Black
  textAlign(CENTER, CENTER);
  textSize(16);
  text(ShowAxes ? "Hide Axes" : "Show Axes", width - 180 - 10, height - 140 - 10, 180, 40);
  
  // Draw logging button
  fill(255, 255, 0); // Yellow
  rect(width - 180 - 10, height - 190 - 10, 180, 40, 15);
  fill(0); // Black
  textAlign(CENTER, CENTER);
  textSize(16);
  text(Logging ? "Stop Log" : "Start Log", width - 180 - 10, height - 190 - 10, 180, 40);
  
  // Draw save log button
  fill(255, 255, 0); // Yellow
  rect(width - 180 - 10, height - 240 - 10, 180, 40, 15);
  fill(0); // Black
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Export Log", width - 180 - 10, height - 240 - 10, 180, 40);
}

void DrawAxes(int Length, boolean Negative) {
  strokeWeight(2);
  stroke(255, 0, 0); // Red
  line(Negative ? -Length : 0, 0, 0, Length, 0, 0);
  strokeWeight(0.5);
  stroke(0);
  fill(255, 0, 0);
  pushMatrix();
  translate(Length, 0, 0);
  rotateZ(PI/2);
  DrawCylinder(0, 6, 8, 8);
  popMatrix();  
  strokeWeight(2);
  stroke(0, 255, 0); // Green
  line(0, Negative ? -Length : 0, 0, 0, Length, 0);
  strokeWeight(0.5);
  stroke(0);
  fill(0, 255, 0);
  pushMatrix();
  translate(0, Length, 0);
  rotateX(PI);
  DrawCylinder(0, 6, 8, 8);
  popMatrix();
  strokeWeight(2);
  stroke(0, 0, 255); // Blue
  line(0, 0, Negative ? -Length : 0, 0, 0, Length);
  strokeWeight(0.5);
  stroke(0);
  fill(0, 0, 255);
  pushMatrix();
  translate(0, 0, Length);
  rotateX(-PI/2);
  DrawCylinder(0, 6, 8, 8);
  popMatrix();
}
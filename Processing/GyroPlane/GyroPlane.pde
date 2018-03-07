void setup() {
  
  // Initialize window and graphics
  size(1280, 800, P3D);
  
  // Initialize ToxicLib graphics
  gfx = new ToxiclibsSupport(this);
  
  // Setup lights and anti-aliasing
  lights(); 
  smooth();
  
  // Print serial ports for debugging clarity
  print("Available ports: ");
  println(Serial.list());
  
  // Connect to serial port
  port = new Serial(this, "COM7", 115200);
  
}

void mouseClicked() { 
  
  // If mouse coordinates are inside button's bounds
  if (mouseX > (width - 180 - 10) && mouseX < (width - 10) && mouseY > (height - 40 - 10) && mouseY < (height - 10)) {
    if (mouseButton == LEFT) {
      // On left click set the yaw offset
      YawOffset = ypr[0];      
    } else if (mouseButton == RIGHT) {
      // On right click zero the offset
      YawOffset = 0;
    }
  } else if (mouseX > (width - 180 - 10) && mouseX < (width - 10) && mouseY > (height - 90 - 10) && mouseY < (height - 60)) {
    ShowHUD = false;
  } else if (mouseX > (width - 180 - 10) && mouseX < (width - 10) && mouseY > (height - 140 - 10) && mouseY < (height - 110)) {
    ShowAxes = !ShowAxes;
  } else if (mouseX > (width - 180 - 10) && mouseX < (width - 10) && mouseY > (height - 190 - 10) && mouseY < (height - 160)) {
    Logging = !Logging;
  } else if (mouseX > (width - 180 - 10) && mouseX < (width - 10) && mouseY > (height - 240 - 10) && mouseY < (height - 210)) {
    SaveLog("Logs/GyroLog - " + CurrentStamp() + ".csv");
  } else {
    ShowHUD = true;
  }  
  
}

void draw() {
    
  // Black canvas
  background(0);
  
  if (ShowHUD) {
    // Draw the indicators
    DrawHUD();
    
    // Draw the buttons
    DrawButtons();
  }
  
  // Push new transformation matrix on the stack for centering viewport
  pushMatrix();
  
  // Set the center of the screen as coordinates origin
  translate(width / 2, height / 2); 
    
  // ToxicLibs direct angle/axis rotation from quaternion (NO gimbal lock!)
  // Axis order [1, 3, 2] and inversion [-1, +1, +1] is a consequence of
  // different coordinate system orientation assumptions
  float[] axis = Quat.toAxisAngle();
  rotate(axis[0], -axis[1], axis[3], axis[2]);
  // Add yaw offset to the rotation
  // *** WARNING ***
  // Adding yaw offset when using ToxicLibs direct axis rotation 
  // zeros the yaw location but breaks the pitch and roll rotation
  rotateY(YawOffset);
  
  if (ShowAxes) {
    // Draw the system axes with negative values
    DrawAxes(300, true);
  }
  
  // *** FIX IT IF YOU CAN ***
  // Yaw works ok
  //rotateY(-ypr[0] + YawOffset);
  // Those functions return values ranging [-PI/2, PI/2] thus blocking the full rotation
  // Gimbal lock and other weird things
  //rotateZ(-ypr[1]); 
  //rotateX(-ypr[2]);
  
  // Draw the plane after rotation
  // Can be replaced with other shapes and objects
  DrawPlane();
  
  // Pop the viewport transformation matrix from the stack
  popMatrix();
  
}
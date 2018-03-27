import peasy.PeasyCam;

PeasyCam cam;

void setup() {
  
  // Initialize window and graphics
  size(1440, 800, P3D);
  
  // Initialize ToxicLib graphics
  gfx = new ToxiclibsSupport(this);
  
  // Setup lights and anti-aliasing
  lights(); 
  smooth();
  
  // Print serial ports for debugging clarity
  print("Available ports: ");
  println(Serial.list());
  
  // Connect to serial port
  port = new Serial(this, "COM5", 115200);
  
  cam = new PeasyCam(this, width / 2, height / 2, 0, 250 * m);
  cam.setMaximumDistance(500 * m);
  
  InitializePlayer();
  
}

boolean Offset = false;

float of = 0;

void keyPressed() {
  Offset = true;
  //Off.set(Quat.getConjugate());
  of += PI/2;
  Tra = Quaternion.createFromAxisAngle(Vec3D.Z_AXIS, of);
  
}

void mouseClicked() { 
  
  // If mouse coordinates are inside button's bounds
  if (mouseX > (width - 180 - 10) && mouseX < (width - 10) && mouseY > (height - 40 - 10) && mouseY < (height - 10)) {
    PlayerVisible = true;
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
  
  // Handle player handlers
  PlaybackBarHandler();
  PlayerCloseHandler();
  PlaybackButtonsHandler();
}

void draw() {
    
  // Black canvas
  background(0);
  
  if (!PlayerVisible) {
    // If not doing playback
    cam.beginHUD();

    if (ShowHUD) {
      // Draw the indicators
      DrawHUD();
      
      // Draw the buttons
      DrawButtons();
    }
    cam.endHUD();
    // Push new transformation matrix on the stack for centering viewport
    pushMatrix();
    
    // Set the center of the screen as coordinates origin
    translate(width / 2, height / 2); 
    
    // ToxicLibs direct angle/axis rotation from quaternion (NO gimbal lock!)
    // Axis order [1, 3, 2] and inversion [-1, +1, +1] is a consequence of
    // different coordinate system orientation assumptions
    
    float[] axis = Tra.multiply(Off.multiply(Quat)).toAxisAngle();
    rotate(axis[0], -axis[1], axis[3], axis[2]);
  
    if (PlaybackActive) {
      DoPlayback();
    }
    
    if (ShowAxes && !PlaybackActive) {
      // Draw the system axes with negative values
      DrawAxes(115 * m, true);
    }
    
    // Draw the plane after rotation
    // Can be replaced with other shapes and objects
    DrawPlane();
    
    // Pop the viewport transformation matrix from the stack
    popMatrix();
  } else {
    DrawPlayer();
  }
  
}
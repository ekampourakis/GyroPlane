void DrawPlane() {
  // Set outline color
  stroke(0); // Black
  
  // Draw main body in red
  fill(255, 0, 0);
  box(10 * m, 10 * m, 200 * m);
  
  // Draw front-facing tip in blue
  fill(0, 0, 255);
  pushMatrix();
  translate(0, 0, -120 * m);
  rotateX(PI/2);
  DrawCylinder(0, 10 * m, 20 * m, 16);
  popMatrix();
  
  // Draw wings and tail fin in green
  fill(0, 255, 0);
  beginShape(TRIANGLES);
  vertex(-100 * m,  2 * m, 30 * m); vertex(0,  2 * m, -80 * m); vertex(100 * m,  2 * m, 30 * m);  // wing top layer
  vertex(-100 * m, -2 * m, 30 * m); vertex(0, -2 * m, -80 * m); vertex(100 * m, -2 * m, 30 * m);  // wing bottom layer
  vertex(-2 * m, 0, 98 * m); vertex(-2 * m, -30 * m, 98 * m); vertex(-2 * m, 0, 70 * m);  // tail left layer
  vertex( 2 * m, 0, 98 * m); vertex( 2 * m, -30 * m, 98 * m); vertex( 2 * m, 0, 70 * m);  // tail right layer
  endShape();
  beginShape(QUADS);
  vertex(-100 * m, 2 * m, 30 * m); vertex(-100 * m, -2 * m, 30 * m); vertex(0, -2 * m, -80 * m); vertex(0, 2 * m, -80 * m);
  vertex( 100 * m, 2 * m, 30 * m); vertex( 100 * m, -2 * m, 30 * m); vertex(0, -2 * m, -80 * m); vertex(0, 2 * m, -80 * m);
  vertex(-100 * m, 2 * m, 30 * m); vertex(-100 * m, -2 * m, 30 * m); vertex(100 * m, -2 * m,  30 * m); vertex(100 * m, 2 * m,  30 * m);
  vertex(-2 * m, 0, 98 * m); vertex(2 * m, 0, 98 * m); vertex(2 * m, -30 * m, 98 * m); vertex(-2 * m, -30 * m, 98 * m);
  vertex(-2 * m, 0, 98 * m); vertex(2 * m, 0, 98 * m); vertex(2 * m, 0, 70 * m); vertex(-2 * m, 0, 70 * m);
  vertex(-2 * m, -30 * m, 98 * m); vertex(2 * m, -30 * m, 98 * m); vertex(2 * m, 0, 70 * m); vertex(-2 * m, 0, 70 * m);
  endShape(); 
}

void DrawCylinder(float topRadius, float bottomRadius, float tall, int sides) {
  float angle = 0;
  float angleIncrement = TWO_PI / sides;
  beginShape(QUAD_STRIP);
  for (int i = 0; i < sides + 1; ++i) {
    vertex(topRadius*cos(angle), 0, topRadius*sin(angle));
    vertex(bottomRadius*cos(angle), tall, bottomRadius*sin(angle));
    angle += angleIncrement;
  }
  endShape();
  
  // If it is not a cone, draw the circular top cap
  if (topRadius != 0) {
    angle = 0;
    beginShape(TRIANGLE_FAN);
    
    // Center point
    vertex(0, 0, 0);
    for (int i = 0; i < sides + 1; i++) {
      vertex(topRadius * cos(angle), 0, topRadius * sin(angle));
      angle += angleIncrement;
    }
    endShape();
  }
  
  // If it is not a cone, draw the circular bottom cap
  if (bottomRadius != 0) {
    angle = 0;
    beginShape(TRIANGLE_FAN);
    
    // Center point
    vertex(0, tall, 0);
    for (int i = 0; i < sides + 1; i++) {
      vertex(bottomRadius * cos(angle), tall, bottomRadius * sin(angle));
      angle += angleIncrement;
    }
    endShape();
  }
}
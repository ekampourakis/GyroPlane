void DrawReference() {
  // Push new transformation matrix to the stack
  pushMatrix();
  // Set the bottom left corner as origin
  translate(150, height - 250);
  // Get the rotation values made by the camera
  float[] CameraAngles = cam.getRotations();
  // Rotate to counter camera rotations
  rotateX(CameraAngles[0]);
  rotateY(CameraAngles[1]);
  rotateZ(CameraAngles[2]);
  // Draw positive angles
  DrawAxes(150, false);
  // Pop the transformation matrix and return back to the old origin
  popMatrix();
}
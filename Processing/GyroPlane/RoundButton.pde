class RoundButton { 
  
  float StartX, StartY, Dimension; 
  String InsideText;
  
  int BackR = 255, BackG = 255, BackB = 255;
  int TextR = 0, TextG = 0, TextB = 0;
  
  int TextOffset = 2;
  
  RoundButton (float X, float Y, float Size, String Text) {  
    StartX = X;
    StartY = Y;
    Dimension = Size;
    InsideText = Text;
  } 
  
  void SetBackgroundColor(int R, int G, int B) {
    BackR = R;
    BackG = G;
    BackB = B;
  }
  
  void SetTextColor(int R, int G, int B) {
    TextR = R;
    TextG = G;
    TextB = B;
  }
  
  void SetOffset(int Offset) {
    TextOffset = Offset;
  }
  
  void SetText(String Text) {
    InsideText = Text; 
  }
  
  boolean MouseOver() {
    return (mouseX >= StartX && mouseX <= StartX + Dimension && mouseY >= StartY && mouseY <= StartY + Dimension);
  }
  
  void Draw() {
    textAlign(CENTER, CENTER);
    textSize(16);  
    fill(BackR, BackG, BackB);
    ellipse(StartX + (Dimension / 2), StartY + (Dimension / 2), Dimension, Dimension);
    fill(TextR, TextG, TextB);
    text(InsideText, StartX, StartY - TextOffset, Dimension, Dimension + TextOffset);
    if (MouseOver()) {
      fill(0, 0, 0, 128);
      ellipse(StartX + (Dimension / 2), StartY + (Dimension / 2), Dimension, Dimension);
    }
  }

}
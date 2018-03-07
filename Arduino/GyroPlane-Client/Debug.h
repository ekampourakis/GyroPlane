// The LED pin
#define LED_PIN A1

void InitDebug() {
  // Set LED pin as output and turn it off
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
}

// Time keeping variable for capping LED blinking frequency
unsigned long lastBlink = 0;
// Last LED blnk state 
bool blinkState = false;

void ActivityBlink() {
  if (millis() - lastBlink > 50) {
    // Alternate LED state with a maximum frequency cap
    blinkState = !blinkState;
    lastBlink = millis();
    digitalWrite(LED_PIN, blinkState);
  }
}

void LEDOn() { digitalWrite(LED_PIN, HIGH); }

void LEDOff() { digitalWrite(LED_PIN, LOW); }

void LongBlink(int Loops = 1, int Delay = 1000) {
  // Repeat 'Loops' times
  for (int Index = 0; Index < Loops; Index++) {
    // Blink LED with delay
    LEDOn(); 
    delay(Delay);
    LEDOff(); 
    delay(Delay);
  }
}

void ShortBlink(int Loops = 1, int Delay = 200) {
  // Repeat 'Loops' times
  for (int Index = 0; Index < Loops; Index++) {
    // Blink LED with delay
    LEDOn();
    delay(Delay);
    LEDOff();
    delay(Delay);
  }
}


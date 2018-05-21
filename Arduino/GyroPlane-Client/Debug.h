#include "FastLED.h"

// How many debug LEDs on the module
#define LEDCount 1

// The DIN pin of the debug LEDs
#define LEDPin 4

// The maximum brightness of the debug LEDs
#define LEDBrightness 255

// Different state colors
#define StatusOK CRGB(0, 255, 64)
#define BufferFull CRGB(0, 0, 255)
#define TransmissionError CRGB(255, 0, 192)
#define Error CRGB::Red
#define Loading CRGB::Orange

// The blinking frequency of the debug LED indicating different statuses in Hz
#define BlinkingFrequency 10

// Time keeping variable for capping LED blinking frequency
unsigned long lastBlink = 0;

// Last LED blink state 
bool blinkState = false;

// Debug LEDs
CRGB leds[LEDCount];

void InitDebug() {
  
  // Initialize the debug LEDs
  FastLED.addLeds<NEOPIXEL, LEDPin>(leds, LEDCount);

  // Set the LEDs brightness
  FastLED.setBrightness(LEDBrightness);

  // Set the LEDs to black
  // This will not send the data to the LEDs
  leds[0] = CRGB::Black;

  // Send data to the LEDs
  // This needs to be called after changing the LEDs
  FastLED.show();
  
}

// Turn LEDs on to the specified color
void LEDOn(CRGB Color) {   

  // Set the color
  leds[0] = Color;

  // Send data to the LEDs
  FastLED.show(); 
  
}

// Turn LEDs off
void LEDOff() {   

  // Set the color to black
  leds[0] = CRGB::Black;

  // Send data to the LEDs
  FastLED.show(); 
  
}

// Blink to indicate activity asynchronously
// May be called more than once
void ActivityBlink(CRGB Color) {

  // If enough time has passed from the last blink
  if (millis() - lastBlink > (1 / BlinkingFrequency)) {
    
    // Alternate LEDs on or off state
    blinkState = !blinkState;

    // Set the timestamp of the last blink variable
    lastBlink = millis();

    // Turn LEDs on or off depending on the current state
    if (blinkState) { LEDOn(Color); } else { LEDOff(); }
    
  }
  
}

// A simple blink function to blink the LEDs
// This function will block execution of code till it's finished
void Blink(CRGB Color, int Loops = 1, int Delay = 200) {
  
  // Repeat 'Loops' times
  for (int Index = 0; Index < Loops; Index++) {
    
    // Turn LEDs on to specified color
    LEDOn(Color);

    // Wait with LED on
    delay(Delay);

    // Turn LEDs off
    LEDOff();

    // Wait with LED off
    delay(Delay);
    
  }
  
}

// Blinking pattern to indicate successful module initialization
void InitPattern() {
  
  // Shift through all available colors quickly
  for (int Hue = 0; Hue < 255; Hue++) {
    
    // Set LEDs to HSV color with full saturation and value
    leds[0] = CHSV(Hue, 255, 255);

    // Send data to LEDs
    FastLED.show();

    // Wait some time
    delay(3);
    
  }
  
}


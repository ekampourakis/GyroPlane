#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

RF24 radio(A8, A9); // CE, CSN

// Address of this module
const byte Address[6] = "HOST0";

void InitRadio() {
  // Initialize the radio module
  radio.begin();
  // Listen as 'HOST0'
  radio.openReadingPipe(1, Address);
  // Set radio power to maximum
  radio.setPALevel(RF24_PA_MAX);
  // Start listening for packets
  radio.startListening();
}

// Received radio data container
byte RX[18] = {0};

void setup() {
  // Begin serial at rate specified by Processing
  Serial.begin(115200);
  // Initialize the radio
  InitRadio();
}

void loop() {
  // If there are radio data available
  if (radio.available()) {
    // Receive 18 bytes of data
    radio.read(&RX, sizeof(RX));
    // Forward those bytes to Processing
    Serial.write(RX, 18);
    // Wait for transmission to complete
    Serial.flush();
  }
}

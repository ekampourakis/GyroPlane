#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

RF24 radio(7, 8); // CE, CSN

// Address of the host module
const byte Address[6] = {"HOST0"};

void InitRadio() {
  // Initialize the radio module
  radio.begin();
  // Write to 'HOST0'
  radio.openWritingPipe(Address);
  // Set radio power to maximum
  radio.setPALevel(RF24_PA_MAX);
  // Stop listening so we can write
  radio.stopListening();
}

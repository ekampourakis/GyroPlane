#include "Debug.h" 
#include "MPU.h"
#include "Radio.h"
#include "Circular_Queue.h"

const uint8_t  QUEUE_SIZE = 70;

void setup() {
  // Initialize debug functions
  InitDebug();
  // Initialize the radio
  InitRadio();
  // Initialize the sensor
  InitMPU();
  Serial.begin(115200);
  MD_CirQueue Q(QUEUE_SIZE, sizeof(GyroPlanePacket));
}

unsigned long lastTX = 0;

void loop() {
    // If programming failed don't try to do anything
    if (!dmpReady) return;

    // Wait for MPU interrupt or for extra available packet(s)
    while (!mpuInterrupt && fifoCount < packetSize) {
      // Put more code here to run while waiting for data
    }

    // Reset interrupt flag
    mpuInterrupt = false;
    
    // Get INT_STATUS byte from the MPU
    mpuIntStatus = mpu.getIntStatus();

    // Get current FIFO buffer count
    fifoCount = mpu.getFIFOCount();

    // Check for overflow
    if ((mpuIntStatus & 0x10) || fifoCount == 1024) {
        // Reset so we can continue cleanly
        mpu.resetFIFO();
    }
    
    // Otherwise, check for DMP data ready interrupt
    else if (mpuIntStatus & 0x02) {
        // Wait for correct available data length
        while (fifoCount < packetSize) fifoCount = mpu.getFIFOCount();

        // Read a packet from the FIFO buffer
        mpu.getFIFOBytes(fifoBuffer, packetSize);
        
        // Track FIFO count here in case there are more than 1 packets available
        // This lets us immediately read more without waiting for an interrupt
        fifoCount -= packetSize;
    
        // Put quaternion values in GyroPlane packet format
        GyroPlanePacket[2] = fifoBuffer[0];
        GyroPlanePacket[3] = fifoBuffer[1];
        GyroPlanePacket[4] = fifoBuffer[4];
        GyroPlanePacket[5] = fifoBuffer[5];
        GyroPlanePacket[6] = fifoBuffer[8];
        GyroPlanePacket[7] = fifoBuffer[9];
        GyroPlanePacket[8] = fifoBuffer[12];
        GyroPlanePacket[9] = fifoBuffer[13];

        // Bit shift to split 32bit unsigned long into 4 bytes
        // Will overflow every ~40 minutes and is precise to about 4uS
        unsigned long Time = micros();
        GyroPlanePacket[10] = Time & 255;
        GyroPlanePacket[11] = (Time >> 8) & 255;
        GyroPlanePacket[12] = (Time >> 16) & 255;
        GyroPlanePacket[13] = (Time >> 24) & 255;
        
        // Create temporary byte array to store the data for transmission
        byte RX[18];
        // Transfer all to temporary byte array for loss protection
        for (int i = 0; i < 18; i++) { RX[i] = GyroPlanePacket[i]; }

        // Increment packetCount that loops at 0xFF on purpose
        GyroPlanePacket[15]++;
        
        // Transmit the 18 byte container via radio
        bool t = radio.writeBlocking(&RX, sizeof(RX), 1);

        
        

        // Blink LED to indicate activity
        ActivityBlink();
        Serial.print(t);
        Serial.print("\t");
        Serial.println((micros() - lastTX));
        lastTX = micros();
    }
}

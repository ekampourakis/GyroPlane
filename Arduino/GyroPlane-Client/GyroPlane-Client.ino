#include "Debug.h" 
#include "MPU.h"
#include "Radio.h"
#include "Circular_Queue.h"

// The size of the circular buffer
// After 65 the buffer overflows with current 18 byte packet size
#define CircularBufferSize 50

// The circular buffer in which we store the remaining packets
MD_CirQueue Q(CircularBufferSize, sizeof(GyroPlanePacket));

// The transmission status of the latest packet
bool LastTX = false;

void setup() {
  
  // Initialize debug functions
  InitDebug();
  
  // Initialize the radio
  InitRadio();
  
  // Initialize the sensor
  InitMPU();
  
  // Initialize the circular buffer
  Q.begin();
  Q.setFullOverwrite(true);

  // Indicate that initialization was successful
  InitPattern();
  
}

void loop() {
    // If programming failed don't try to do anything
    if (!dmpReady) { return; }

    // Wait for MPU interrupt or for extra available packet(s)
    while (!mpuInterrupt && fifoCount < packetSize) {
      // Put code here to run while waiting for data
      
      // If buffer is not empty try to transmit remaining data
      if (!Q.isEmpty()) {
        
        byte TX[18];
        // Fetch data from the buffer without removing it from the queue
        Q.peek((uint8_t *) & TX);
        
        // Wait for transmission to happen
        LastTX = radio.writeBlocking(&TX, sizeof(TX), 1);
        
        // If transmission is successful
        if (LastTX) { 
          // Remove the packet from the queue
          Q.pop((uint8_t *) & TX); 
        }
        
      }
      
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

        // Include precise clock in the packet
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

        // Push the RX in the circular transmission buffer
        Q.push((uint8_t *) & RX);
        
    }

    // Blink LEDs to appropriate color to indicate activity
    ActivityBlink(LastTX ? StatusOK : Q.isFull() ? BufferFull : TransmissionError);
    
}

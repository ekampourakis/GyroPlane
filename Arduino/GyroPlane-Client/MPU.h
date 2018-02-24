#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"
#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    #include "Wire.h"
#endif

// MPU interrupt pin. Use pin 2 on Nano and most boards
#define INTERRUPT_PIN 2

// Create the sensor
MPU6050 mpu;

// MPU initialization state
bool dmpReady = false;
// Holds actual interrupt status byte from the MPU
uint8_t mpuIntStatus;
// Return status after each module operation (0 = success, !0 = error)
uint8_t devStatus;
// Expected DMP packet size (default is 42 bytes)
uint16_t packetSize;
// Count of all bytes currently in FIFO buffer
uint16_t fifoCount;
// FIFO storage buffer
uint8_t fifoBuffer[64];

// Time keeping variable for capping LED blinking frequency
unsigned long lastBlink = 0;
// Last LED blnk state 
bool blinkState = false;

// Quaternion container [w, x, y, z]
Quaternion q;

// Packet structure for GyroPlane demo
uint8_t GyroPlanePacket[14] = {'$', 0x02, 0,0, 0,0, 0,0, 0,0, 0x00, 0x00, '\r', '\n'};

// Indicates whether MPU interrupt pin has gone high
volatile bool mpuInterrupt = false;
void dmpDataReady() { mpuInterrupt = true; }

void InitMPU() {

  // Library stuff
  #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
      Wire.begin();
      Wire.setClock(400000);
  #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
      Fastwire::setup(400, true);
  #endif

  // Initialize the sensor
  mpu.initialize();

  // Set sensor interrupt pin to input
  pinMode(INTERRUPT_PIN, INPUT);
  
  // Blink slowly until sensor is initialized
  while (!mpu.testConnection()) {
    LongBlink();
  }
  devStatus = mpu.dmpInitialize();
  
  // Supply your own gyro offsets here, scaled for min sensitivity
  mpu.setXGyroOffset(220);
  mpu.setYGyroOffset(76);
  mpu.setZGyroOffset(-85);
  mpu.setZAccelOffset(1788); // 1688 factory default for my test chip
  
  // Make sure it worked (returns 0 if so)
  if (devStatus == 0) {
    
    // Turn on the DMP, now that it's ready
    mpu.setDMPEnabled(true);
    
    // Enable interrupt detection
    attachInterrupt(digitalPinToInterrupt(INTERRUPT_PIN), dmpDataReady, RISING);
    mpuIntStatus = mpu.getIntStatus();
    
    // Set our DMP Ready flag so the main loop() function knows it's okay to use it
    dmpReady = true;
    
    // Get expected DMP packet size for later comparison
    packetSize = mpu.dmpGetFIFOPacketSize();
    
  } else {
    
    // Blink continuously because sensor failed
    while (true) {
      ShortBlink(1, 50);
    }
    
  }
  
  // Blinking pattern to indicate successful MPU initialization
  LongBlink(1, 600);
  ShortBlink(2, 150);
  
}
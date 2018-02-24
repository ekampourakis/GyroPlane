import processing.serial.*;
import processing.opengl.*;
import toxi.geom.*;
import toxi.processing.*;

// Constants
int IndicatorFPS = 10;
float CalibrationSensitivity = 0.015;
int DisconnectedInterval = 500;
float m = 3.0; // Graphics size multiplier

// Declarations
ToxiclibsSupport gfx;
Serial port; 
Quaternion Quat = new Quaternion(1, 0, 0, 0);

// Variables
float[] Gravity = new float[3];
float[] Euler = new float[3];
float[] ypr = new float[3];
boolean Calibrated = false;
boolean Connected = false;
float YawOffset = 0.0;

// HUD variables
boolean ShowHUD = true;
boolean ShowAxes = false;

// Text animation variables
int DotAmount = 0;
long LastDot = 0;
int DotDelay = 100;
int MaxDots = 10;

// Serial variables
// GyroPlane byte sequence format
// { '$' , 0x02 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0x00 , 0x00 , '\r' , '\n' }
char[] GyroPacket = new char[14];
// Current packet byte position
int serialCount = 0;
// Synchronization flag
boolean Synced = false;
// The quaternion data. 'q' used for code simplification
float[] q = new float[4];
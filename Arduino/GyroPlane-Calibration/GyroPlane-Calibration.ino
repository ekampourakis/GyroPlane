/* ============================================

Put the MPU6050 on a flat and horizontal surface, and leave it operating for 5-10 minutes so its temperature gets stabilized.
Run this program.  A "----- done -----" line will indicate that it has done its best.
With the current accuracy-related constants (NFast = 1000, NSlow = 10000), it will take a few minutes to get there.
Along the way, it will generate a dozen or so lines of output, showing that for each of the 6 desired offsets, it is 
  * first, trying to find two estimates, one too low and one too high, and
  * then, closing in until the bracket can't be made smaller.
The line just above the "done" line will look something like
[567,567] --> [-1,2]  [-2223,-2223] --> [0,1] [1131,1132] --> [16374,16404] [155,156] --> [-1,1]  [-25,-24] --> [0,3] [5,6] --> [0,4]
As will have been shown in interspersed header lines, the six groups making up this line describe the optimum offsets for the 
X acceleration, Y acceleration, Z acceleration, X gyro, Y gyro, and Z gyro, respectively.  
In the sample shown just above, the trial showed that +567 was the best offset for the X acceleration, 
-2223 was best for Y acceleration, and so on.

=============================================== */

// I2Cdev and MPU6050 must be installed as libraries, or else the .cpp/.h files
// for both classes must be in the include path of your project
#include "I2Cdev.h"
#include "MPU6050.h"

// Arduino Wire library is required if I2Cdev I2CDEV_ARDUINO_WIRE implementation
// is used in I2Cdev.h
#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
	#include "Wire.h"
#endif

MPU6050 accelgyro;

const char LBRACKET = '[';
const char RBRACKET = ']';
const char COMMA    = ',';
const char BLANK    = ' ';
const char PERIOD   = '.';

const int iAx = 0;
const int iAy = 1;
const int iAz = 2;
const int iGx = 3;
const int iGy = 4;
const int iGz = 5;

const int usDelay = 3150;   // empirical, to hold sampling to 200 Hz
const int NFast =  1000;    // the bigger, the better (but slower)
const int NSlow = 10000;    // ..
const int LinesBetweenHeaders = 5;

int LowValue[6];
int HighValue[6];
int Smoothed[6];
int LowOffset[6];
int HighOffset[6];
int Target[6];
int LinesOut;
int N;
      
void ForceHeader() { LinesOut = 99; }
    
void GetSmoothed() {
	int16_t RawValue[6];
	int i;
	long Sums[6];
	for (i = iAx; i <= iGz; i++) { Sums[i] = 0; }
	for (i = 1; i <= N; i++) {
		accelgyro.getMotion6(&RawValue[iAx], &RawValue[iAy], &RawValue[iAz], 
								&RawValue[iGx], &RawValue[iGy], &RawValue[iGz]);
		if ((i % 500) == 0)
		Serial.print(PERIOD);
		delayMicroseconds(usDelay);
		for (int j = iAx; j <= iGz; j++)
		Sums[j] = Sums[j] + RawValue[j];
	}
	for (i = iAx; i <= iGz; i++) { Smoothed[i] = (Sums[i] + N/2) / N ; }
}

void Initialize() {
	// join I2C bus (I2Cdev library doesn't do this automatically)
	#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
		Wire.begin();
	#elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
		Fastwire::setup(400, true);
	#endif
	Serial.begin(9600);
	// initialize device
	Serial.println("Initializing I2C devices...");
	accelgyro.initialize();
	// verify connection
	Serial.println("Testing device connections...");
	Serial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");
}

void SetOffsets(int TheOffsets[6]) {
	accelgyro.setXAccelOffset(TheOffsets[iAx]);
	accelgyro.setYAccelOffset(TheOffsets[iAy]);
	accelgyro.setZAccelOffset(TheOffsets[iAz]);
	accelgyro.setXGyroOffset(TheOffsets[iGx]);
	accelgyro.setYGyroOffset(TheOffsets[iGy]);
	accelgyro.setZGyroOffset(TheOffsets[iGz]);
}

void ShowProgress() {
	// show header
	if (LinesOut >= LinesBetweenHeaders) {
		Serial.println("\tXAccel\t\t\tYAccel\t\t\t\tZAccel\t\t\tXGyro\t\t\tYGyro\t\t\tZGyro");
		LinesOut = 0;
	}
	Serial.print(BLANK);
	for (int i = iAx; i <= iGz; i++) { 
		Serial.print(LBRACKET);
		Serial.print(LowOffset[i]),
		Serial.print(COMMA);
		Serial.print(HighOffset[i]);
		Serial.print("] --> [");
		Serial.print(LowValue[i]);
		Serial.print(COMMA);
		Serial.print(HighValue[i]);
		if (i == iGz) { 
			Serial.println(RBRACKET); 
		} else { 
			Serial.print("]\t"); 
		}
	}
	LinesOut++;
}

void PullBracketsIn() {
	boolean AllBracketsNarrow;
	boolean StillWorking;
	int NewOffset[6];
	Serial.println("\nclosing in:");
	AllBracketsNarrow = false;
	ForceHeader();
	StillWorking = true;
	while (StillWorking) { 
		StillWorking = false;
		if (AllBracketsNarrow && (N == NFast)) { 
			SetAveraging(NSlow); 
		} else { 
			AllBracketsNarrow = true; 
		}
		for (int i = iAx; i <= iGz; i++) { 
			if (HighOffset[i] <= (LowOffset[i]+1)) {
				NewOffset[i] = LowOffset[i];
			} else {
				StillWorking = true;
				NewOffset[i] = (LowOffset[i] + HighOffset[i]) / 2;
				if (HighOffset[i] > (LowOffset[i] + 10)) { 
					AllBracketsNarrow = false; 
				}
			}
		}
		SetOffsets(NewOffset);
		GetSmoothed();
		for (int i = iAx; i <= iGz; i++) {
			if (Smoothed[i] > Target[i]) {
				HighOffset[i] = NewOffset[i];
				HighValue[i] = Smoothed[i];
			} else {
				LowOffset[i] = NewOffset[i];
				LowValue[i] = Smoothed[i];
			}
		}
		ShowProgress();
	}
}

void PullBracketsOut() {
	boolean Done = false;
	int NextLowOffset[6];
	int NextHighOffset[6];
	Serial.println("expanding:");
	ForceHeader();
	while (!Done) {
		Done = true;
		SetOffsets(LowOffset);
		GetSmoothed();
		for (int i = iAx; i <= iGz; i++) {
			LowValue[i] = Smoothed[i];
			if (LowValue[i] >= Target[i]) { 
				Done = false;
				NextLowOffset[i] = LowOffset[i] - 1000;
			} else {
				NextLowOffset[i] = LowOffset[i];
			}
		}
		SetOffsets(HighOffset);
		GetSmoothed();
		for (int i = iAx; i <= iGz; i++) {
			HighValue[i] = Smoothed[i];
			if (HighValue[i] <= Target[i]) {
				Done = false;
				NextHighOffset[i] = HighOffset[i] + 1000;
			} else {
				NextHighOffset[i] = HighOffset[i];
			}
		}
		ShowProgress();
		for (int i = iAx; i <= iGz; i++) {
			LowOffset[i] = NextLowOffset[i];
			HighOffset[i] = NextHighOffset[i];
		}
	}
}

void SetAveraging(int NewN) {
	N = NewN;
	Serial.print("averaging ");
	Serial.print(N);
	Serial.println(" readings each time");
}

void setup() {
	Initialize();

	// Set targets and initial guesses
	for (int i = iAx; i <= iGz; i++) {
		Target[i] = 0; // must fix for ZAccel 
		HighOffset[i] = 0;
		LowOffset[i] = 0;
	}

	Target[iAz] = 16384;
	SetAveraging(NFast);

	PullBracketsOut();
	PullBracketsIn();

	Serial.println("-------------- done --------------");
}
 
void loop() { }
// Refresh frequency
float Frequency;
// Previous refresh frequency
float LastFrequency;
// Last frequency update time
long LastFrequencyUpdate = 0;
// Last received packet time
long LastPacket;

void serialEvent(Serial Port) {
  // When module is turned on before running meaningless errors occur thus use try to ignore them
  try {
    // While there are bytes in the incoming buffer
    while (Port.available() > 0) {
      
      // Read next available byte
      int RX = Port.read(); 
      // If bytes as not in sync and last received byte is not the alignation byte '$' quit
      if (!Synced && RX != '$') { return; }
      
      // Suppose we are in sync
      Synced = true;
    
      // If the format of the currently receiving byte sequence is not right
      if ((serialCount == 1 && RX != 2) || (serialCount == 12 && RX != '\r') || (serialCount == 13 && RX != '\n'))  {
        // Reset the byte receiving procedure and quit because we lost sync
        serialCount = 0;
        Synced = false;
        return;
      }
      // If we have received some bytes or the current byte is the alignation byte
      if (serialCount > 0 || RX == '$') {
        
        // Store current byte and increment the received byte counter
        GyroPacket[serialCount++] = (char)RX;
        
        // If we successfully received all 14 required bytes
        if (serialCount == 14) {
          
          // Restart received byte counter
          serialCount = 0;
          
          // Decode quaternion from data packets
          // The raw received data come in 16bit containers with data stored in 2s complement.
          // Left shift 8 places the first 8bit container in the 16bit variable to make them the MSB
          // Bitwise or the remaining 8 LSB bits from the second packet with the 8 LSB of the 16bit variable
          // Despite the 16bits, the useful range is [-16384, +16383]. 
          // So divide with 16384.0f to map the values further.
          q[0] = ((GyroPacket[2] << 8) | GyroPacket[3]) / 16384.0f;
          q[1] = ((GyroPacket[4] << 8) | GyroPacket[5]) / 16384.0f;
          q[2] = ((GyroPacket[6] << 8) | GyroPacket[7]) / 16384.0f;
          q[3] = ((GyroPacket[8] << 8) | GyroPacket[9]) / 16384.0f;
          for (int i = 0; i < 4; i++) if (q[i] >= 2) q[i] = -4 + q[i];
          
          // Set our Toxilibs quaternion to new data
          Quat.set(q[0], q[1], q[2], q[3]);
          
          // If we are logging data, log received data
          if (Logging) { Log(q); }
          
          // Calculate the receive frequency
          Frequency = 1000 / (millis() - LastPacket);
          LastPacket = millis();
     
          // Calculate gravity vectors
          Gravity[0] = 2 * (q[1] * q[3] - q[0] * q[2]);
          Gravity[1] = 2 * (q[0] * q[1] + q[2] * q[3]);
          Gravity[2] = q[0] * q[0] - q[1] * q[1] - q[2] * q[2] + q[3] * q[3];
          
          // Calculate Euler angles
          Euler[0] = atan2(2 * q[1] * q[2] - 2 * q[0] * q[3], 2 * q[0] * q[0] + 2 * q[1] * q[1] - 1);
          Euler[1] = -asin(2 * q[1] * q[3] + 2 * q[0] * q[2]);
          Euler[2] = atan2(2 * q[2] * q[3] - 2 * q[0] * q[1], 2 * q[0] * q[0] + 2 * q[3] * q[3] - 1);
          
          // Calculate yaw/pitch/roll angles
          ypr[0] = atan2(2 * q[1] * q[2] - 2 * q[0] * q[3], 2 * q[0] * q[0] + 2 * q[1] * q[1] - 1);
          ypr[1] = atan(Gravity[0] / sqrt(Gravity[1] * Gravity[1] + Gravity[2] * Gravity[2]));
          ypr[2] = atan(Gravity[1] / sqrt(Gravity[0] * Gravity[0] + Gravity[2] * Gravity[2]));
          
        }
      }
    } 
  } catch(RuntimeException e) {
    // Print that something happened but ignore it
    println("Runtime exception occured. Continuing...");
  }
}
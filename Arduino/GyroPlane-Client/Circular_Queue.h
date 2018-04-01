#pragma once
#include <Arduino.h>

class MD_CirQueue {
  
public:

  MD_CirQueue(uint8_t itmQty, uint16_t itmSize) : _itmQty(itmQty), _itmSize(itmSize), _itmCount(0), _overwrite(false) {
    uint16_t size = sizeof(uint8_t) * _itmQty * _itmSize;
    _itmData = (uint8_t *)malloc(size);
    clear();
  }

  ~MD_CirQueue() { free(_itmData); }
  
  void begin(void) {};

  inline void clear() { _idxPut = _idxTake = _itmCount = 0; };

  bool push(uint8_t* itm) {  
    if (isFull()) {
      if (_overwrite) { pop(_itmData + (_idxTake * _itmSize)); } // pop it into itself ...
      else { return(false); }     
    }
    // Save item and adjust the tail pointer
    memcpy(_itmData + (_itmSize * _idxPut), itm, _itmSize);
    _idxPut++;
    _itmCount++;
    if (_idxPut == _itmQty) { _idxPut = 0; }
    return(true);    
  }

  uint8_t *pop(uint8_t* itm) {
    if (isEmpty()) { return(NULL); }
    // Copy data from the buffer
    memcpy(itm, _itmData + (_itmSize * _idxTake), _itmSize);
    _idxTake++;
    _itmCount--;
    // If head has reached last item, wrap it back around to the start
    if (_idxTake == _itmQty) { _idxTake = 0; }
    return (itm);   
  }

  uint8_t *peek(uint8_t* itm) {
     if (isEmpty()) { return(NULL); };
     // Copy data from the buffer
     memcpy(itm, _itmData + (_itmSize * _idxTake), _itmSize);
     return (itm);
  }

  inline void setFullOverwrite(bool b) { _overwrite = b; };

  inline bool isEmpty(void) { return(_itmCount == 0); };

  inline bool isFull() { return (_itmCount != 0 && _itmCount == _itmQty); };

private:

  uint8_t   _itmQty;    /// number of items in the queue
  uint16_t  _itmSize;   /// size in bytes for each item
  uint8_t*  _itmData;   /// pointer to allocated memory buffer
  
  uint8_t   _itmCount;  /// number of items in the queue
  uint8_t   _idxPut;    /// array index where the next push will occur
  uint8_t   _idxTake;   /// array index where next pop will occur
  bool      _overwrite; /// when true, overwrite oldest object if push() and isFull()
  
};

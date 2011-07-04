/*
  SoundSensor.h - Library for reading temperature and humidity from external sensor.
  Created by Espen Nygård, June 29, 2011.
  Released into the public domain.
*/
#ifndef SoundSensor_h
#define SoundSensor_h

#include "WProgram.h"

class SoundSensor
{
 private:
    int _analogPin;
	
  public:
    SoundSensor(int);
	void calcAverage(int samples);
    String readRaw();
	String getAverage();
	String getMax();
	String getMin();
	


};

#endif


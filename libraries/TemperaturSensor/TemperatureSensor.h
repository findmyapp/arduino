/*
  TemperatureSensor.h - Library for reading temperature and humidity from external sensor.
  Created by Espen Nygård, June 29, 2011.
  Released into the public domain.
*/
#ifndef TemperatureSensor_h
#define TemperatureSensor_h

#include "WProgram.h"
//#include <inttypes.h>

class TemperatureSensor
{
 private:
    int _dataPin;
	int _clockPin;
	int getData16SHT();
  	void sendCommandSHT(int);
	void waitForResultSHT();
	void skipCrcSHT();
	
  public:
    TemperatureSensor(int, int);
    float readTemperature();
    float readHumidity();
	int temperatureCommand;
	int humidityCommand;
	int ack;  // track acknowledgment for errors
	int val;  
	float temperature;          
	float humidity;
 
	
};

#endif


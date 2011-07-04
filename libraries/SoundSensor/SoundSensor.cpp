/*
  SoundSensor.cpp - Library for reading temperature and humidity from external sensor.
  Created by Espen Nygård, June 29, 2011.
  Released into the public domain.
*/

#include "WProgram.h"
#include "SoundSensor.h"

int maxSamples = 20;
int max = 0;
int min = 1023;
int counter = 0;
int average = 0;
int sum = 0;
int value = 0;

SoundSensor::SoundSensor(int analogPin)
{
	pinMode(analogPin, INPUT);
	_analogPin = analogPin;
}

String SoundSensor::readRaw(){
	// read the raw sound data
	return String(analogRead(_analogPin));
}

void SoundSensor::calcAverage(int samples){
	// read the average sound level over x ms. Max 50 samples.
	max = analogRead(_analogPin);
	min = max;
	counter = 1;
	average = max;
	sum = max;
	
	if (samples > maxSamples){samples = maxSamples;}
	
	for(counter; counter < samples ; counter++){
		value = analogRead(_analogPin);
		delay(10);
		if (value > max) {
			max = value;
		}
		if (value < min) {
			min = value;
		}
		
		sum = sum + value;
	}
	average = sum/counter;
	
	//array[0] = min;
	//array[1] = max;
	//array[2] = average; //average;
	//Serial.println("GET /findmyapp/location/"+location+"/noise/push?raw_min="+min+"&raw_max="+max+"&raw_average="+average+" HTTP/1.0");
	//return "GET /findmyapp/location/"+location+"/noise/push?raw_min="+min+"&raw_max="+max+"&raw_average="+average+" HTTP/1.0";
}
String SoundSensor::getAverage(){
	return String(average);
}
String SoundSensor::getMax(){
	return String(max);
}
String SoundSensor::getMin(){
	return String(min);
}

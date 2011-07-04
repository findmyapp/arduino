/*
  TemperatureSensor.cpp - Library for reading temperature and humidity from external sensor.
  Created by Espen Nygård, June 29, 2011.
  Released into the public domain.
*/

#include "WProgram.h"
#include "TemperatureSensor.h"

//class TemperatureSensor
//{
TemperatureSensor::TemperatureSensor(int dataPin, int clockPin)
{
	pinMode(dataPin, OUTPUT);
	pinMode(clockPin, OUTPUT);
	_dataPin = dataPin;
	_clockPin = clockPin;
	temperatureCommand  = B00000011;  // command used to read temperature
	humidityCommand = B00000101;  // command used to read humidity
}

float TemperatureSensor::readTemperature(){
	// read the temperature and convert it to centigrades
	sendCommandSHT(temperatureCommand);
	waitForResultSHT();
	val = getData16SHT();
	skipCrcSHT();
	temperature = (float)val * 0.01 - 40;
	return temperature;
}
float TemperatureSensor::readHumidity(){
	// read the humidity
	sendCommandSHT(humidityCommand);
	waitForResultSHT();
	val = getData16SHT();
	skipCrcSHT();
	humidity = -4.0 + 0.0405 * val + -0.0000028 * val * val;
	return humidity;
}

// send a command to the SHTx sensor
void TemperatureSensor::sendCommandSHT(int command) {
	int ack;

	// transmission start
	pinMode(_dataPin, OUTPUT);
	pinMode(_clockPin, OUTPUT);
	digitalWrite(_dataPin, HIGH);
	digitalWrite(_clockPin, HIGH);
	digitalWrite(_dataPin, LOW);
	digitalWrite(_clockPin, LOW);
	digitalWrite(_clockPin, HIGH);
	digitalWrite(_dataPin, HIGH);
	digitalWrite(_clockPin, LOW);
  
	// shift out the command (the 3 MSB are address and must be 000, the last 5 bits are the command)
	shiftOut(_dataPin, _clockPin, MSBFIRST, command);
  
	// verify we get the right ACK
	digitalWrite(_clockPin, HIGH);
	pinMode(_dataPin, INPUT);
	ack = digitalRead(_dataPin);
	if (ack != LOW)
		Serial.println("ACK error 0");
	digitalWrite(_clockPin, LOW);
	ack = digitalRead(_dataPin);
	if (ack != HIGH)
		Serial.println("ACK error 1");
}

// wait for the SHTx answer
void TemperatureSensor::waitForResultSHT() {
	int ack;

	pinMode(_dataPin, INPUT);
	for (int i=0; i<100; ++i) {
		delay(20);
		ack = digitalRead(_dataPin);
		if (ack == LOW)
			break;
	}
	if (ack == HIGH)
		Serial.println("ACK error 2");
}

	// get data from the SHTx sensor
int TemperatureSensor::getData16SHT() {
	int val;

	// get the MSB (most significant bits)
	pinMode(_dataPin, INPUT);
	pinMode(_clockPin, OUTPUT);
	val = shiftIn(_dataPin, _clockPin, MSBFIRST); //shiftIn(_dataPin, _clockPin, MSBFIRST, 8, 3);
	val *= 256; // this is equivalent to val << 8;
  
	// send the required ACK
	pinMode(_dataPin, OUTPUT);
	digitalWrite(_dataPin, HIGH);
	digitalWrite(_dataPin, LOW);
	digitalWrite(_clockPin, HIGH);
	digitalWrite(_clockPin, LOW);
  
	// get the LSB (less significant bits)
	pinMode(_dataPin, INPUT);
	val |= shiftIn(_dataPin, _clockPin, MSBFIRST); //shiftIn(_dataPin, _clockPin, MSBFIRST, 8, 3);
	return val;
	}

// skip CRC data from the SHTx sensor
void TemperatureSensor::skipCrcSHT() {
	pinMode(_dataPin, OUTPUT);
	pinMode(_clockPin, OUTPUT);
	digitalWrite(_dataPin, HIGH);
	digitalWrite(_clockPin, HIGH);
	digitalWrite(_clockPin, LOW);
}




#ifndef __CREDENTIALS_H__
#define __CREDENTIALS_H__

// Wifi parameters
//char passphrase[] = "FokusBank"; // WIFI password
//char ssid[] = "supersilje2"; // WIFI SSID

//connection paramters
//int port = 80; // Port to connect to
//const char* url = "findmyapp.net"; // URL to sens POST requests to

//Sending paramteres - timings are not guaranteed, but should be considered as minimum delay 
//int sendDelay = 3000; //delay between sensor readings (90 sek per sensor)
// Delays are in ms
unsigned long sendDelay[] = {30000,30000,30000,180000}; //   TEMPERATURE, HUMIDITY, BEERTAP, NOISE,
//unsigned long sendDelay[] = {580000,580000,580000,100}; //   TEMPERATURE, HUMIDITY, BEERTAP, NOISE,

//location parameters
int location = 1; //the location where the Arduino is placed

//pin parameters
int tempClockPin = 9; // clock pin for temperature sensor
int tempDataPin = 8; // data pin for temperature sensor
int soundSensorPin = 0; // analog pin used to read from the micrphone




#endif

#ifndef __CREDENTIALS_H__
#define __CREDENTIALS_H__

// Wifi parameters
char passphrase[] = "findmyapp"; // WIFI password
char ssid[] = "esn"; // WIFI SSID

//connection paramters
int port = 80; // Port to connect to
const char* url = "findmyapp.net"; // URL to sens POST requests to

//Sensor paramteres
int sendDelay = 30000; //delay between sensor readings (90 sek per sensor)

//location parameters
int location = 1; //the location where the Arduino is placed

//pin parameters
int tempClockPin = 9; // clock pin for temperature sensor
int tempDataPin = 8; // data pin for temperature sensor
int soundSensorPin = 0; // analog pin used to read from the micrphone




#endif

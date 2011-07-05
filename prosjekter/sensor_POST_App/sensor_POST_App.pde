#include "WiFly.h"
#include "Credentials.h"
#include <TemperatureSensor.h>
#include <SoundSensor.h>

TemperatureSensor temperatureSensor(8,9);
SoundSensor soundSensor(0);

Client client("findmyapp.net", 80);
int* soundData;
String raw_min;
String raw_max;
String raw_average;
String rq;
String location = "Strossa";
float tempValue;
float humValue;

boolean temperatureSent = false;
boolean humiditySent = false;
boolean noiseSent = false;
int sendDelay = 2000;

void setup() {
  Serial.begin(115200);
  Serial.println("gogogo");

  WiFly.begin(); 
  
  if (!WiFly.join(ssid, passphrase)) {
    Serial.println("Association failed.");
    while (1) {
      // Hang on failure.
    }
  }   
  WiFly.configure(WIFLY_BAUD, 38400);
  
  sendEchoData();
}

int count = 0;

void loop() {
  
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
    count++;
    if (count > 80) {
      count = 0;
      Serial.println();
    }
  }
  /*
  if (!client.connected()) {
    delay(sendDelay);
    if (temperatureSent == false){
      sendTemperatureData();
      temperatureSent = true;
    } else if (humiditySent == false){
      sendHumidityData();
      humiditySent = true;
    } else if (noiseSent == false){
      sendNoiseData();
      noiseSent = true;
    } else {
      temperatureSent = false;
      humiditySent = false;
      noiseSent = false;    
    }
    
  }
*/

}

void sendNoiseData(){
  soundSensor.calcAverage(50);
  raw_min = soundSensor.getMin();
  raw_max = soundSensor.getMax();
  raw_average = soundSensor.getAverage();
  ////Serial.println(raw_min);  //Serial.println(raw_max);  //Serial.println(raw_average);
  //Serial.println("connecting...");
  
  if (client.connect()) {
    //Serial.println("connected");
    client.print("GET "); 
    client.print("/findmyapp/location/");
    client.print(location);
    client.print("/noise/push?raw_min=");
    client.print(raw_min);
    client.print("&raw_max=");
    client.print(raw_max);
    client.print("&raw_average=");
    client.print(raw_average);
    client.print(" HTTP/1.0");
    client.println();
    client.println("Accept: text/html,application/xhtml+xml,application/xml");
    client.println();
  } else {
    //Serial.println("connection failed");
  }
}

void sendTemperatureData(){
  tempValue = temperatureSensor.readTemperature();
  //Serial.println("connecting...");
  
  if (client.connect()) {
    //Serial.println("connected");
    client.print("GET "); 
    client.print("/findmyapp/location/");
    client.print(location);
    client.print("/temperature/push?value=");
    client.print(tempValue);
    client.print(" HTTP/1.0");
    client.println();
    client.println("Accept: text/html,application/xhtml+xml,application/xml");
    client.println();
  } else {
    //Serial.println("connection failed");
  }
}

void sendHumidityData(){
  humValue = temperatureSensor.readHumidity();
  //Serial.println("connecting...");
  
  if (client.connect()) {
    //Serial.println("connected");
    client.print("GET "); 
    client.print("/findmyapp/location/");
    client.print(location); 
    client.print("/humidity/push?value=");
    client.print(humValue);
    client.print(" HTTP/1.0");
    client.println();
    client.println("Accept: text/html,application/xhtml+xml,application/xml");
    client.println();
  } else {
    //Serial.println("connection failed");
  }
}

void sendEchoData(){
  Serial.println("connecting...");
  
  if (client.connect()) {
    Serial.println("connected");
    client.print("POST "); 
    client.print("/findmyapp/echo/");
    client.print(" HTTP/1.0");
    client.println();
    client.println("Content-Type: application/json");
    client.println("Accept: application/json");
    client.print("Content-Length: ");
    client.print(5001);
    client.println();
    client.println();
    client.print("[1000");
    for(int i = 1001; i < 1999; i++){
      client.print(",");
      client.print(i);     
    }
    client.print("]");
    client.println("[500,400,800,,5,6,7]");
    client.println();
  } else {
    Serial.println("connection failed");
  }
}


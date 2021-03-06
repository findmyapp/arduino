#include "WiFly.h"
#include "Properties.h"
#include <TemperatureSensor.h>
#include <SoundSensor.h>

TemperatureSensor temperatureSensor(tempDataPin,tempClockPin);
SoundSensor soundSensor(soundSensorPin);

Client client(url, port);

float tempValue;
float humValue;

boolean temperatureSent = false;
boolean humiditySent = false;
boolean noiseSent = false;


void setup() {
  Serial.begin(115200);

  WiFly.begin(); 
  
  if (!WiFly.join(ssid, passphrase)) {
    //Serial.println("Association failed.");
    while (1) {
      // Hang on failure.
    }
  }   
  WiFly.configure(WIFLY_BAUD, 38400);
  //delay(2000); //connect time
}

int count = 0;

void loop() {
  
  if (client.available()) {
    char c = client.read();
    //Serial.print(c);
    count++;
    if (count > 80) {
      count = 0;
      //Serial.println();
    }
  }
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

}
void sendTemperatureData(){
  tempValue = temperatureSensor.readTemperature();
  //Serial.println("connecting...");
  
 if (client.connect()) {
    //Serial.println("connected");
    client.print("POST "); 
    client.print("/findmyapp/location/");
    client.print(location);
    client.print("/temperature");
    client.print(" HTTP/1.0");
    client.println();
    client.println("Content-Type: application/json");
    client.println("Accept: application/json");
    client.println("Content-Length: 50");
    client.println();
    client.print("{\"location\":");
    client.print(location);
    client.print(", \"value\":");
    client.print(tempValue);
    client.println("}");
    client.println();
  }
}

void sendHumidityData(){
  humValue = temperatureSensor.readHumidity();
  //Serial.println("connecting...");
  
 if (client.connect()) {
    //Serial.println("connected");
    client.print("POST "); 
    client.print("/findmyapp/location/");
    client.print(location);
    client.print("/humidity");
    client.print(" HTTP/1.0");
    client.println();
    client.println("Content-Type: application/json");
    client.println("Accept: application/json");
    client.println("Content-Length: 50");
    client.println();
    client.print("{\"location\":");
    client.print(location);
    client.print(", \"value\":");
    client.print(humValue);
    client.println("}");
    client.println();
  }
}

void sendNoiseData(){
  //Serial.println("connecting...");
  
  if (client.connect()) {
    //Serial.println("connected");
    client.print("POST "); 
    client.print("/findmyapp/location/");
    client.print(location);
    client.print("/noise");
    client.print(" HTTP/1.0");
    client.println();
    client.println("Content-Type: application/json");
    client.println("Accept: application/json");
    client.print("Content-Length: ");
    client.print(10000);
    client.println();
    client.println();
    client.print("[");
    client.print((soundSensor.readRaw()));
    for(int i = 10001; i < 10999; i++){
      client.print(",");
      //client.print(i);     
      client.print((soundSensor.readRaw()));
    }
    client.println("]");
    client.println();
  }
}


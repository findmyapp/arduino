#include "WiFly.h"
#include "Properties.h"
#include <TemperatureSensor.h>
#include <SoundSensor.h>

TemperatureSensor temperatureSensor(tempDataPin,tempClockPin);
SoundSensor soundSensor(soundSensorPin);

Client client(url, port);

float tempValue;
float humValue;
unsigned int sentCounter = 0;

unsigned long timeOutCounter = 0;
unsigned int timeOut = 10000;

boolean temperatureSent = false;
boolean humiditySent = false;
boolean noiseSent = false;



void setup() {
  Serial.begin(115200);
  Serial.println("Arduino start");

  WiFly.begin(); 
  
  Serial.println("trying to connect");
  if (!WiFly.join(ssid, passphrase)) {
    Serial.println("Association failed.");
    while (1) {
      // Hang on failure.
    }
  }   
  Serial.println("connected to network");
  //WiFly.configure(WIFLY_BAUD, 38400);
  Serial.println("Baud ok");
  //delay(2000); //connect time
}

int count = 0;

void loop() {
  //Serial.println("loop");
  //if (client.available()) {
    //Serial.println("available");
    //char c = client.read();
    //Serial.print(c);
    //count++;
    //if (count > 80) {
    //  count = 0;
   //   Serial.println();
    //}
 / }
  
  
  /*
  if (!client.connected()) {
    Serial.println("start delay");
    delay(sendDelay);
    Serial.println("End delay");
    if (temperatureSent == false){
      Serial.println("temp:send");
      sendTemperatureData();
      temperatureSent = true;
      Serial.println("temp:sent");
    } else if (humiditySent == false){
      Serial.println("hum:send");
      sendHumidityData();   
      humiditySent = true;
      Serial.println("hum:sent");
    } else if (noiseSent == false){
      Serial.println("noise:send");
      sendNoiseData();
      noiseSent = true;
      Serial.println("noise:sent");
    } else {
      temperatureSent = false;
      humiditySent = false;
      noiseSent = false; 
      Serial.println("reset bool flags");   
    }
    
  }
  */
  if (!client.connected()) {
    //client.flush();
    //Serial.flush();
    //client.stop();
    //client.flush();
   
    if (millis() > timeOutCounter){
      Serial.println("### new data ###");
      client.flush();
      client.stop();
      sendTemperatureData();
      Serial.println("### end data ###");
    }
    
    //delay(50);
  } else {
    //client.stop();
  }

}
void sendTemperatureData(){
  
  Serial.println("temp:connecting...");
  
 if (client.connect()) {
    timeOutCounter = millis() + timeOut;
    tempValue = temperatureSensor.readTemperature();
    sentCounter = sentCounter +1 ;
    Serial.println("temp:connected...");
    
    client.print("POST "); 
    client.print("/findmyapp/locations/");
    client.print(sentCounter);
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
    client.flush();
    Serial.println("temp:request sent");
  } else {
    //
    //client.stop();
  }
}
void sendAuthTemperatureData(){
  tempValue = temperatureSensor.readTemperature();
  Serial.println("temp:connecting...");
  
 if (client.connect()) {
    Serial.println("temp:connected...");
    client.print("POST "); 
    client.print("/findmyapp/locations/");
    client.print(location);
    client.print("/temperature");
    client.print(" HTTP/1.0");
    client.println();
    client.println("Content-Type: application/json");
    client.println("Accept: application/json");
    client.println("Autorization: Basic YXJkdWlubzpGMzJnSWstTDc=");
    client.println("Content-Length: 50");
    client.println();
    client.print("{\"location\":");
    client.print(location);
    client.print(", \"value\":");
    client.print(tempValue);
    client.println("}");
    client.println();
    client.flush();
    client.stop();
    Serial.println("temp:request sent");
  }
}

void sendHumidityData(){
  humValue = temperatureSensor.readHumidity();
  Serial.println("hum:connecting...");
  
 if (client.connect()) {
    Serial.println("hum:connected...");
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
    Serial.println("hum:request sent");
  }
}

void sendNoiseData(){
  Serial.println("noise:connecting...");
  
  if (client.connect()) {
    Serial.println("noise:connected");
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
    Serial.println("noise:request sent");
  }
}


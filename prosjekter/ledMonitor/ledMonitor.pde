/*

conf wifly with this:

1. enter command mode: $$$

set wlan auth 3
set wlan join 1
set wlan passphrase FokusBank
set wlan ssid supersilje
set com remote 0
set dns name findmyapp.net
set ip address 0
set ip remote 80
set com idle 5
set uart baud 115200

 */

#include "WiFly.h" // We use this for the preinstantiated SpiSerial object.
#include <TemperatureSensor.h>
#include <SoundSensor.h>
#include "properties.h"

SoundSensor soundSensor(soundSensorPin);
TemperatureSensor temperatureSensor(tempDataPin,tempClockPin);

int closed = 0;
int opened = 0;
int cmd = 0;
byte lastByte;


boolean canCmd = true;
boolean canOpen = false;
boolean canSend = false;

unsigned int aliveCounter;

unsigned long timeout = 60000; //180000;
unsigned long timeoutCounter = 0;

//queueing
enum {
  TEMPERATURE,
  HUMIDITY,
  BEERTAP,  
  NOISE,
} SensorType;

//priority queue 
int sendQueue[] = {TEMPERATURE, HUMIDITY, BEERTAP, NOISE}; //array of size 5
unsigned long timestampLastSent[] = {0,0,0,0}; //array of size 5
unsigned long currentMillis;
unsigned long lastMillis;

void setup() {
  Serial.begin(115200);
  recoverWiFlyClient();
}


void loop() {
  while(SpiSerial.available() > 0) {
    byte input = SpiSerial.read();
    checkForOpenClose(input);
    Serial.print(input, BYTE);
    timeoutCounter = millis() + timeout;    
  }

  if(canSend == true){
      aliveCounter++;
      handleSending();
      canSend = false;
      timeoutCounter = millis() + timeout;
  } else {
    if (canCmd || canOpen){

        openCmd();
        openConnection();
    
    }
    
    if(millis()>timeoutCounter){
      Serial.println("<--> reset <-->");
      recoverWiFlyClient();
    }
  }  
}

void checkForOpenClose(byte input){
  if (input == '*' && opened == 0 && closed == 0){
    closed = 1;
    opened = 1;
    cmd = 0;
  } else if(input == 'O' && opened == 1 && lastByte == '*' ){
    opened = 2; 
    closed = 0;
    cmd = 0;
  } else if(input == 'P' && opened == 2  && lastByte == 'O' ){
    opened = 3;
   closed = 0; 
   cmd = 0;
  } else if(input == 'E' && opened == 3 && lastByte == 'P' ){
    opened = 4;
   closed = 0; 
   cmd = 0;
  } else if(input == 'N' && opened == 4  && lastByte == 'E' ){
    opened = 5;
    closed = 0; 
    cmd = 0;
  } else if(input == '*' && opened == 5 && lastByte == 'N' ){
    opened = 0;
    closed = 0; 
    cmd = 0;
    canCmd = false;
    canOpen = false;
    canSend = true;
    //Serial.println("received *OPEN*");
  } else if(input == 'C' && closed == 1  && lastByte == '*' ){
    opened = 0; 
    closed = 2;
    cmd = 0;
  } else if(input == 'L' && closed == 2  && lastByte == 'C' ){
    opened = 0;
   closed = 3; 
   cmd = 0;
  } else if(input == 'O' && closed == 3 && lastByte == 'L' ){
    opened = 0;
   closed = 4; 
   cmd = 0;
  } else if(input == 'S' && closed == 4 && lastByte == 'O' ){
    opened = 0;
    closed = 5; 
    cmd = 0;
  } else if(input == '*' && closed == 5 && lastByte == 'S' ){
    opened = 0;
    closed = 0; 
    cmd = 0;
    canCmd = true;
    canOpen = false;
    canSend = false;
    //Serial.println("received *CLOSE*");
  }else if(input == 'C' && cmd == 0){
    cmd = 1;
  } else if(input == 'M' && cmd == 1  && lastByte == 'C' ){
    cmd = 2;
  } else if(input == 'D' && cmd == 2 && lastByte == 'M' ){
    opened = 0;
    closed = 0; 
    cmd = 0;
    canCmd = false;
    canOpen = true;
    canSend = false;
    //Serial.println("received CMD");
  }
  lastByte = input;
}


void recoverWiFlyClient(){
  digitalWrite(4, HIGH);
  delay(1000);
  digitalWrite(4, LOW);
  delay(1000); 
  timeoutCounter = millis() + timeout;
  canCmd = true;
  canOpen = false;
  canSend = false;
  timestampLastSent[TEMPERATURE]=0;
  timestampLastSent[HUMIDITY]=0;
  timestampLastSent[BEERTAP]=0;
  timestampLastSent[NOISE]=0;
  SpiSerial.begin(115200);
  delay(5000); 
}

void openConnection(){
  if (canOpen == true){
    canOpen = false;
    Serial.println("sending open");
    SpiSerial.print("open\r");  
    timeoutCounter = millis() + timeout;
  }
}

void openCmd(){
  if (canCmd == true){
    canCmd = false;
    Serial.println("sending $$$");
    SpiSerial.print("$$$");
    timeoutCounter = millis() + timeout;
  }
}

void handleSending(){
  
  //Serial.println(findNextToSend());
  Serial.println(); 
  Serial.println("INFO: Sending request to server"); 
  Serial.println(); 
  handleSendingData();  

  
}


void handleSendingData(){
  SpiSerial.print("POST "); 
  SpiSerial.print("/findmyapp/locations/");
  SpiSerial.print(location);
  SpiSerial.print("/temperature");
  SpiSerial.print(" HTTP/1.0");
  SpiSerial.println();
  SpiSerial.println("Content-Type: application/json");
  SpiSerial.println("Accept: application/json");
  SpiSerial.println("Authorization: Basic c2Vuc29yOkYzMmdJay1MNw==");
  SpiSerial.println("Content-Length: 5");
  SpiSerial.println();
  SpiSerial.println(temperatureSensor.readTemperature());
  SpiSerial.println();
 
}



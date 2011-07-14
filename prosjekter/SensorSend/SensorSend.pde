#include "WiFly.h"
#include "properties.h"

boolean wifiEnabled;
Client client(url, port);

unsigned int locationCounter = 1;
boolean succeeded = false;
unsigned int crashCounter = 0;

// State Management
enum {
  STATE_ASSOCIATING_WIFLY,
  STATE_STANDBY,
  STATE_INIT_CLIENT,  
  STATE_CONNECTING,
  STATE_CONNECTING_ERROR,  
  STATE_SENDING,
  STATE_AWAITING_REPLY,
  STATE_REPLY_TIMEOUT_ERROR,
  STATE_CONNECTION_FAILED,  
  STATE_DATA_SENT,
  STATE_SENDING_ERROR,
  STATE_SENDING_TEMPERATURE,
  STATE_SENDING_HUMIDITY,
  STATE_SENDING_NOISE,
  STATE_SENDING_BEERTAP
  
} ArduinoState;

// INITIAL STATE
int state;

enum {
  TEMPERATURE,
  HUMIDITY,
  BEERTAP,  
  NOISE,
} SensorType;

// number of sensors
unsigned int numberOfTypes = 4;

// last data sent
int lastSentType;
int nextToSendType = TEMPERATURE;

boolean dialerState = true;
long lastDialerToggle = 0;
int dialedNumberAcc = 0;
int awaitingReplyTimeout;
boolean awaitingReplySoundOn;
int awaitingReplyCount;
long startDialingTStamp;
long silenceStartedTStamp;

void setup() {
  pinMode(5, OUTPUT);   //sets the reset notification pin for communication with the arduino 2.
  digitalWrite(5, LOW);  
  Serial.begin(115200);
  state = STATE_ASSOCIATING_WIFLY; 
}

void loop() {
  switch(state) {
    case STATE_ASSOCIATING_WIFLY:       state = handleAssociatingWifly();      break;
    case STATE_INIT_CLIENT:             state = handleInitClient();            break;
    case STATE_CONNECTING:              state = handleConnecting();            break;
    case STATE_CONNECTING_ERROR:        state = handleConnectingError();       break;
    case STATE_STANDBY:                 state = handleStandby();               break;
    case STATE_SENDING:                 state = handleSending();               break;
    case STATE_AWAITING_REPLY:          state = handleAwaitingReply();         break;
    case STATE_REPLY_TIMEOUT_ERROR:     state = handleReplyTimeoutError();     break;
    case STATE_CONNECTION_FAILED:       state = handleConnectionFailedError(); break;
    case STATE_DATA_SENT:               state = handleDataSent();              break;
    case STATE_SENDING_ERROR:           state = handleSendingError();          break;
    case STATE_SENDING_TEMPERATURE:     state = handleSendingTemperature();    break;
    case STATE_SENDING_HUMIDITY:        state = handleSendingHumidity();       break;
    case STATE_SENDING_NOISE:           state = handleSendingNoise();          break;
    case STATE_SENDING_BEERTAP:         state = handleSendingBeertap();        break;
  }

}

int handleAssociatingWifly() {
  Serial.println("Wifly, begin!");
  WiFly.begin();
  
  
  if(tryConnectWiFly()) {
    handleWiFlySuccess(3);
  }
  else {
    handleWiFlyFailure(3);
  }
  return STATE_STANDBY;
}

boolean tryConnectWiFly() {
  Serial.println("join network!");
  return WiFly.join(ssid, passphrase);
}



int handleInitClient() {
  Serial.print("Client init...");
  if(!wifiEnabled) {
    Serial.println("trying to reconnect...");
    if(tryConnectWiFly()) {
      handleWiFlySuccess(2);
    }
    else {
      handleWiFlyFailure(2);
    }
  }
  if(wifiEnabled) {
    return STATE_CONNECTING;
  }
  else {
    delay(1000); // for better user experience?
    return STATE_CONNECTION_FAILED;
  }
}


int handleConnecting() {
  Serial.println("connecting...");
  if(!client.connected()){
    if (!client.connect()) {
      Serial.println("connection failed");
      return STATE_CONNECTING_ERROR;
    } 
  } else{
    client.flush();
  }
  return STATE_SENDING;
}

int handleAwaitingReply() {
  
  if(awaitingReplyTimeout <= 0) {
      if(succeeded) {
          client.flush();
          client.stop();
          Serial.println("STATE_DATA_SENT");
          return STATE_DATA_SENT;
      } else {
          return STATE_REPLY_TIMEOUT_ERROR;
      }
  }

  if (client.available()) {
    succeeded = true; // assuming getting something from server is succeeding   
    char c = client.read();
    Serial.print(c);
    awaitingReplyTimeout++;
  }
  
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
    if(!succeeded) {
      Serial.println("STATE_SENDING_ERROR");
      return STATE_SENDING_ERROR;
    }
    Serial.println("STATE_DATA_SENT");
    return STATE_DATA_SENT;
  }
  awaitingReplyTimeout--;
  delayMicroseconds(1000);
  
  return STATE_AWAITING_REPLY;
}

int handleSendingError() {
  Serial.println("Sending error");
  delay(200);
  return STATE_STANDBY; 
}

int handleReplyTimeoutError() {
  Serial.println("handleReplyTimeoutError");
  delay(200);
  return STATE_STANDBY;
}

int handleConnectionFailedError() {
  Serial.println("handleConnectionFailedError");
  if (crashCounter >= 20){   
    //resetWifly();
    //return STATE_ASSOCIATING_WIFLY; //STATE_STANDBY; //return STATE_CONNECTING_ERROR;
    return STATE_STANDBY;
  }else if (crashCounter >= 5){
    //try to set client to normal state
    recoverWiFlyClient();
    return STATE_STANDBY;
  } else {
   
    crashCounter++;
    return STATE_STANDBY;
  }
}

int handleConnectingError() {
  Serial.println("handleConnectingError");
  if (crashCounter >= 20){   
    //resetWifly();
    //return STATE_ASSOCIATING_WIFLY; //STATE_STANDBY; //return STATE_CONNECTING_ERROR;
    return STATE_STANDBY;
  }else if (crashCounter >= 5){
    //try to set client to normal state
    recoverWiFlyClient();
    return STATE_STANDBY;
  } else {
   
    crashCounter++;
    return STATE_STANDBY;
  }

}

///////////////////////////////////
// Handle sending

int handleSending() {
  Serial.println(nextToSendType);
  
  nextToSendType = (nextToSendType + 1) % 4;
  switch(nextToSendType) {
  case TEMPERATURE:         return STATE_SENDING_TEMPERATURE;    
  case HUMIDITY:            return STATE_SENDING_HUMIDITY;    
  case NOISE:               return STATE_SENDING_NOISE;    
  case BEERTAP:             return STATE_SENDING_BEERTAP;    
  }
}

int handleSendingTemperature(){
  Serial.println("sending temperature data");
  client.print("POST "); 
  client.print("/findmyapp/locations/");
  client.print(1);
  client.print("/temperature");
  client.print(" HTTP/1.0");
  client.println();
  client.println("Content-Type: application/json");
  client.println("Accept: application/json");
  client.println("Content-Length: 50");
  client.println();
  client.print("{\"location\":");
  client.print(1);
  client.print(", \"value\":");
  client.print(locationCounter);
  client.println("}");
  client.println();
  client.flush();
  Serial.println("sent!");
  awaitingReplyTimeout = 5000;
  awaitingReplySoundOn = false;
  awaitingReplyCount = 0;
  succeeded = false;
  lastSentType = TEMPERATURE;
  return STATE_AWAITING_REPLY;
}

int handleSendingHumidity(){
 Serial.println("sending humidity data");
  client.print("POST "); 
  client.print("/findmyapp/locations/");
  client.print(1);
  client.print("/temperature");
  client.print(" HTTP/1.0");
  client.println();
  client.println("Content-Type: application/json");
  client.println("Accept: application/json");
  client.println("Content-Length: 50");
  client.println();
  client.print("{\"location\":");
  client.print(1);
  client.print(", \"value\":");
  client.print(locationCounter);
  client.println("}");
  client.println();
  client.flush();
  Serial.println("sent!");
  awaitingReplyTimeout = 5000;
  awaitingReplySoundOn = false;
  awaitingReplyCount = 0;
  succeeded = false;
  lastSentType = HUMIDITY;
  return STATE_AWAITING_REPLY; 
}

int handleSendingNoise(){
  Serial.println("sending Noise data");
  client.print("POST "); 
  client.print("/findmyapp/locations/");
  client.print(1);
  client.print("/temperature");
  client.print(" HTTP/1.0");
  client.println();
  client.println("Content-Type: application/json");
  client.println("Accept: application/json");
  client.println("Content-Length: 50");
  client.println();
  client.print("{\"location\":");
  client.print(1);
  client.print(", \"value\":");
  client.print(locationCounter);
  client.println("}");
  client.println();
  client.flush();
  Serial.println("sent!");
  awaitingReplyTimeout = 5000;
  awaitingReplySoundOn = false;
  awaitingReplyCount = 0;
  succeeded = false;
  lastSentType = NOISE;
  return STATE_AWAITING_REPLY;
}

int handleSendingBeertap(){
  Serial.println("sending Beertap data");
  client.print("POST "); 
  client.print("/findmyapp/locations/");
  client.print(1);
  client.print("/temperature");
  client.print(" HTTP/1.0");
  client.println();
  client.println("Content-Type: application/json");
  client.println("Accept: application/json");
  client.println("Content-Length: 50");
  client.println();
  client.print("{\"location\":");
  client.print(1);
  client.print(", \"value\":");
  client.print(locationCounter);
  client.println("}");
  client.println();
  client.flush();
  Serial.println("sent!");
  awaitingReplyTimeout = 5000;
  awaitingReplySoundOn = false;
  awaitingReplyCount = 0;
  succeeded = false;
  lastSentType = BEERTAP;
  return STATE_AWAITING_REPLY;
}

///////////////////////////////////
// Event Handlers

void handleWiFlyFailure(int alertLevel) {
  wifiEnabled = false;

  if(alertLevel > 0) {
    Serial.println("Wifi association failed. (Alert level 0)");  
  }
}

void handleWiFlySuccess(int alertLevel) {
  wifiEnabled = true;

  if(alertLevel > 0) {
    Serial.println("Wifi association succeeded! (Alert level 0)");
  }
}

int handleDataSent(){
  Serial.println("Data transfered");
  locationCounter++;
  return STATE_STANDBY;
}

int handleStandby(){
  delay(200);
  Serial.println("Starting new transfer");
  return STATE_INIT_CLIENT;
}


/////////////////////////////////////////
// reset code


void resetWifly() {
  //Serial.println("##### RESETTING  POWER ####");
  //delay(500);
  //digitalWrite(5, HIGH);  
  return;
}

void recoverWiFlyClient(){
  WiFly.begin();
  WiFly.join(ssid, passphrase);
  crashCounter = 0;
}


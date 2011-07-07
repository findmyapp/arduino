#include "WiFly.h"
#include "Credentials.h"
#include <BeerCounter.h>

Client client("findmyapp.net", 80);
BeerCounter beerCounter(2,13);
int location = 1;
int beerTapNumber = 1;
boolean beerCountSent = false;
int sendDelay = 10000;
int numberOfBeers = 0;

void setup() {
  
    //init interrupt on pin 2.
  attachInterrupt(0,notifyBeerTapped, RISING);
  
   WiFly.begin();
   Serial.begin(9600);
  
  if (!WiFly.join(ssid, passphrase)) {
    Serial.println("Association failed.");
    while (1) {
      // Hang on failure.
    }
  }
    
     Serial.println("connecting...");

  if (client.connect()) {
    Serial.println("connected");
    //client.println("GET /search?q=arduino HTTP/1.0");
    //client.println();
  } else {
    Serial.println("connection failed");
  }
  
}

void loop() {
  
  
  //Serial.print("loop beer counter: ");
  //Serial.println(numberOfBeers);
  //numberOfBeers = beerCounter.getTheNumberOfBeers();
 // Serial.println("Skål!");
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }
  //Serial.println("loop");
  
  //if(numberOfBeers >= 10) {
   // Serial.println("10 beers!");
    if (!client.connected()) {
      client.connect();
      Serial.println("test");
    }
      delay(sendDelay);
      numberOfBeers = beerCounter.getTheNumberOfBeers();
      beerCounter.reset(); 
      sendBeerCountData(numberOfBeers);
         
    
  //}

  
}
 
void sendBeerCountData(int numBeers){
  
  //Serial.print("connecting..");
  //Serial.println(client.connected());
  if (client.connected()) {
    //Serial.println("connected");
    client.print("POST "); 
    client.print("/findmyapp/echo");
    //client.print(location);
    //client.print("/temperature");
    //client.print(beerTapNumber);
    client.print(" HTTP/1.0");
    client.println();
    client.println("Accept: text/html,application/xhtml+xml,application/xml");
    client.println();
    client.print("[");
    client.print(numBeers);
    client.println("]");
    client.println();
    //Serial.println("Sent!");
  } else {
    Serial.println("connection failed");
  }
}
  
 void notifyBeerTapped(){
   beerCounter.beerTapped();
   Serial.print("number of beers tapped: ");
   Serial.println(beerCounter.getTheNumberOfBeers());
 }

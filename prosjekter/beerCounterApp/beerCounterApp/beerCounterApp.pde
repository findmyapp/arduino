#include "WiFly.h"
#include "Credentials.h"
#include <BeerCounter.h>

Client client("findmyapp.net", 80);
BeerCounter beerCounter(2,13);
String location = "Strossa";
int beerTapNumber = 1;
boolean beerCountSent = false;
int sendDelay = 2000;
int numberOfBeers = 0;

void setup() {
  
  beerCounter.setup();
  attachInterrupt(0, beerTapped, RISING);
}

void loop() {
  
  numberOfBeers = beerCounter.getTheNumberOfBeers();
  //numberOfBeers = beerCounter.getTheNumberOfBeers();
 // Serial.println("Skål!");
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }
  
  if(numberOfBeers >= 10) {
    Serial.println("10 beers!");
    if (!client.connected()) {
      Serial.println("test");
      delay(sendDelay);
      sendBeerCountData();
      beerCounter.reset();    
    }
  }

  
}
 
void sendBeerCountData(){
  
  Serial.println("connecting..");
  
  if (client.connect()) {
    Serial.println("connected");
    client.print("GET "); 
    client.print("/findmyapp/location/");
    client.print(location);
    client.print("/beertap/push?tapnr=");
    client.print(beerTapNumber);
    client.print(" HTTP/1.0");
    client.println();
    client.println("Accept: text/html,application/xhtml+xml,application/xml");
    client.println();
  } else {
    //Serial.println("connection failed");
  }
}
  
void beerTapped(){
  numberOfBeers =  beerCounter.getTheNumberOfBeers();
}

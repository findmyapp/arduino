/*
	BeerCounter.cpp - Library for counting beers.
	Created by Kristin Astebol, July 4th, 2011.
*/

#include "WProgram.h"
#include "BeerCounter.h"

// class BeerCounter
// (the LED-"functionality" can be taken out of the code when it's not necessary anymore)
BeerCounter::BeerCounter(int buttonPinDigital, int ledPinDigital)
{

 /* based on code
 by Tom Igoe*/

 // setup 
 // button works the same way as the optocoupler (either on or off/high or low)
 
buttonPin = buttonPinDigital;  // for example 2
ledPin = ledPinDigital;  // normally 13

buttonPushCounter = 0;   // counter for the number of button presses
buttonState = 0;         // current state of the button
lastButtonState = 0;     // previous state of the button

}
void BeerCounter::setup() {
// initialize the button pin as a input:
  pinMode(buttonPin, INPUT);
  // initialize the LED as an output:
  pinMode(ledPin, OUTPUT);
  // initialize serial communication:
  Serial.begin(9600);
}

void BeerCounter::reset() {
	setButtonPushCounter(0);
}

void BeerCounter::setButtonPushCounter(int value)
{
	buttonPushCounter = value;
}

int BeerCounter::getButtonPushCounter() 
{
	return buttonPushCounter;
}
  
int BeerCounter::getTheNumberOfBeers() {
	// get the current numbers of sold beers (the total)
	


  // read the pushbutton input pin:
  buttonState = digitalRead(buttonPin);

  // compare the buttonState to its previous state
  if (buttonState != lastButtonState) {
    // if the state has changed, increment the counter
    if (buttonState == HIGH) {
      // if the current state is HIGH then the button
      // wend from off to on:
      buttonPushCounter++;
      Serial.println("on");
      Serial.print("the number of beers:  ");
      Serial.println(buttonPushCounter, DEC);
    } 
    else {
      // if the current state is LOW then the button
      // wend from on to off:
      Serial.println("off"); 
    }
  }
  // save the current state as the last state, 
  //for next time through the loop
  lastButtonState = buttonState;

  
  // turns on the LED every four button pushes by 
  // checking the modulo of the button push counter.
  // the modulo function gives you the remainder of 
  // the division of two numbers:
  if (buttonPushCounter % 4 == 0) {
    digitalWrite(ledPin, HIGH);
  } else {
   digitalWrite(ledPin, LOW);
  }
  return buttonPushCounter;
}
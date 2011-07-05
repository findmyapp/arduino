/*
	BeerCounter.h - Library for counting beers.
	Created by Kristin Astebol, July 4th, 2011.
*/

#ifndef BeerCounter_h
#define BeerCounter_h

class BeerCounter 
{
private:
	 int  buttonPin; 
	 int ledPin;

	int buttonPushCounter;  	
	int buttonState;         
	int lastButtonState;

public:
	BeerCounter(int,int);
	void setup();
	void reset();
	int getTheNumberOfBeers();
	int getButtonPushCounter();
	void setButtonPushCounter(int);
	
};

#endif

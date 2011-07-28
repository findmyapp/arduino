/*

  SoftSparkLCD.cpp - An trimmed down software serial interface for
  controlling a Sparkfun serial LCD.  Based on the SoftwareSerial
  library by David A. Mellis.
  
  Provides options specific to the serial lcd sold by Sparkfun.com
  
  Changes 2010 C. A. Church
  
  -----
  
  SoftwareSerial.cpp - Software serial library
  Copyright (c) 2006 David A. Mellis.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

/******************************************************************************
 * Includes
 ******************************************************************************/

#include "WConstants.h"
#include "SparkSoftLCD.h"

/******************************************************************************
 * Definitions
 ******************************************************************************/

#define SETUP_CMD	124
#define DISP_CMD	254

/******************************************************************************
 * Constructors
 ******************************************************************************/

SparkSoftLCD::SparkSoftLCD(uint8_t transmitPin)
{
  _transmitPin = transmitPin;
  _baudRate = 0;
  _width    = 16;
}

SparkSoftLCD::SparkSoftLCD(uint8_t transmitPin, uint8_t width)
{
  _transmitPin = transmitPin;
  _baudRate = 0;
  _width    = width;
}

/******************************************************************************
 * User API
 ******************************************************************************/

void SparkSoftLCD::begin(long speed)
{
  _baudRate = speed;
  _bitPeriod = 1000000 / _baudRate;

  digitalWrite(_transmitPin, HIGH);
  delayMicroseconds( _bitPeriod); // if we were low this establishes the end
}


void SparkSoftLCD::print(uint8_t b)
{
  if (_baudRate == 0)
    return;
    
  int bitDelay = _bitPeriod - clockCyclesToMicroseconds(50); // a digitalWrite is about 50 cycles
  byte mask;

  digitalWrite(_transmitPin, LOW);
  delayMicroseconds(bitDelay);

  for (mask = 0x01; mask; mask <<= 1) {
    if (b & mask){ // choose bit
      digitalWrite(_transmitPin,HIGH); // send 1
    }
    else{
      digitalWrite(_transmitPin,LOW); // send 1
    }
    delayMicroseconds(bitDelay);
  }

  digitalWrite(_transmitPin, HIGH);
  delayMicroseconds(bitDelay);
}

void SparkSoftLCD::print(char *s)
{

  
 while(*s)
 	 print(*s++);
  
}

void SparkSoftLCD::print(char c)
{
  print((uint8_t) c);
}

void SparkSoftLCD::print(int n)
{
  print((long) n);
}

void SparkSoftLCD::print(unsigned int n)
{
  print((unsigned long) n);
}

void SparkSoftLCD::print(long n)
{
  if (n < 0) {
    print('-');
    n = -n;
  }
  printNumber(n, 10);
}

void SparkSoftLCD::print(float n, uint8_t p)
{

  if (n < 0) {
    print('-');
    n = -n;
  }

  printNumber( (unsigned int) n, 10 );
  
  unsigned int r = (int) n;
  
  if( ! p ) {
  	  return;
  }
  
  print('.');
  
  while(p--) {
  	  n -= r;
  	  n *= 10;
  	  r = int(n);
  	  printNumber(n, 10);
  }
 
}

void SparkSoftLCD::print(unsigned long n)
{
  printNumber(n, 10);
}

void SparkSoftLCD::print(long n, int base)
{
  if (base == 0)
    print((char) n);
  else if (base == 10)
    print(n);
  else
    printNumber(n, base);
}


/*  
 
  Removed println() methods
  
*/


/*

  New public methods - SparkSoftLCD

*/
 
void SparkSoftLCD::backlight( uint8_t value ) 
{

  value = value > 29 ? 29 : value;
  value += 128;
  
  print((uint8_t) SETUP_CMD);
  print(value);
  
}

void SparkSoftLCD::sendControl( uint8_t code )
{
	
 print( (uint8_t) DISP_CMD);
 print(code);
}

void SparkSoftLCD::clear()
{
  sendControl( (uint8_t) 0x01 );
}

void SparkSoftLCD::moveCursor( bool which )
{

  if( which == true ) { 
  	  sendControl( (uint8_t) 0x14 );
  }
  else {
  	  sendControl( (uint8_t) 0x10 );
  }
}

void SparkSoftLCD::scroll( bool which )
{

  if( which == true ) { 
  	  sendControl( (uint8_t) 0x1C );
  }
  else {
  	  sendControl( (uint8_t) 0x18 );
  }
}

    
void SparkSoftLCD::cursorTo( uint8_t line, uint8_t pos ) 
{

   pos--;
   uint8_t lenAdd = 4;
   
   	// add 4 to position for 20-char displays
   if( _width == 20 ) 
   	   lenAdd = 4;
   
   
   switch(line) {
   	   case 1:
   	   	 break;
	   case 2:
		 pos += 64;
		 break;
	   case 3:
		 pos += 20;
		 break;
	   case 4:
		 pos += 84;
		 break;	 
	   default:
	 	 return;
   }
  
   
   pos += 128;   
   
   sendControl( pos );
   
}


void SparkSoftLCD::cursor( uint8_t type )
{
	
   switch(type) {
   	   
   	case 0:
   		sendControl( (uint8_t) 0x0C );
   		break;
   		
   	case 1:
   		sendControl( (uint8_t) 0x0E );
   		break;
   		
   	case 2:
   		sendControl( (uint8_t) 0x0D );
   		break;
   }
}


void SparkSoftLCD::enable( bool on )
{
	
   if( on == true ) {
	cursor(0);
   }
   else {
   	sendControl( (uint8_t) 0x08 );
   }
}


/* 

	Private methods
 
*/
 

void SparkSoftLCD::printNumber(unsigned long n, uint8_t base)
{
  unsigned char buf[sizeof(char) * sizeof(long)];  
  unsigned long i = 0;

  if (n == 0) {
    print('0');
    return;
  } 

  while (n > 0) {
    buf[i++] = n % base;
    n /= base;
  }

  for (; i > 0; i--)
    print((char) (buf[i - 1] < 10 ? '0' + buf[i - 1] : 'A' + buf[i - 1] - 10));
}

/* // char[][] = char[line][character number on the specified line] */
/*char[][] SparkSoftLCD::createSubstringsFromText(String text, int numberOfLines) {
    int index =0;
    int textLength = text.length();
    char charArray[textLength];
    text.toCharArray(charArray,textLength);
    char textArraySplit[numberOfLines][16];
    for(int i =0; i<numberOfLines; i++) {
      for(int j=0;j<16; j++) {
        index = i*16 + j;
        if( index <= textLength){
        textArraySplit[i][j] = charArray[index];
        }else {
        textArraySplit[i][j] = " ";
        }  
       }
    }
    return textArraySplit;
 } */
 


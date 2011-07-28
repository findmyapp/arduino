/*

  SparkSoftLCD - A trimmed down software serial interface for
  controlling a Sparkfun serial LCD.  Based on the SoftwareSerial
  library by David A. Mellis.
  
  Provides options specific to the serial lcd sold by Sparkfun.com
  
      http://www.sparkfun.com/commerce/product_info.php?products_id=9395
  
  Changes 2010 C. A. Church
  
  -----
  
  SoftwareSerial.h - Software serial library
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

#ifndef SparkSoftLCD_h
#define SparkSoftLCD_h

#include <inttypes.h>

class SparkSoftLCD
{
  private:
    uint8_t _transmitPin;
    long _baudRate;
    int _bitPeriod;
    uint8_t _width;
    void printNumber(unsigned long, uint8_t);
  public:
    SparkSoftLCD(uint8_t);
    SparkSoftLCD(uint8_t, uint8_t);
    void begin(long);
    void print(char);
    void print(char[]);
    void print(uint8_t);
    void print(int);
    void print(unsigned int);
    void print(long);
    void print(unsigned long);
    void print(long, int);
    void print(float, uint8_t);
    void backlight(uint8_t);
    void sendControl(uint8_t);
    void clear(void);
    void moveCursor(bool);
    void cursorTo(uint8_t, uint8_t);
    void cursor(uint8_t);
    void enable(bool);
    void scroll(bool);
    //char[][] createSubstringsFromText(String, int);
};

#endif


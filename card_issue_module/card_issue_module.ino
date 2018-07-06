/*

The circuit:
LCD to arduino:
 * LCD RS pin to digital pin 4
 * LCD Enable pin to digital pin 5
 * LCD D4 pin to digital pin 6
 * LCD D5 pin to digital pin 7
 * LCD D6 pin to digital pin 8
 * LCD D7 pin to digital pin 9
 * LCD R/W pin to ground
 * LCD VSS pin to ground
 * LCD 16 pin to ground
 * LCD VCC pin to 5V
 * LCD LED+ pin to 5V via 560Ω resistor
 * 10K variable resistor between Vcc and gnd. middle pin to VEE or Vo or pin 3 on lcd

Card reader module:
 * pin2 to data0
 * pin3 to data1

*/

#include <LiquidCrystal.h>
#include <Wiegand.h>

// initialize the library by associating any needed LCD interface pin
// with the arduino pin number it is connected to
const int rs = 4, en = 5, d4 = 6, d5 = 7, d6 = 8, d7 = 9;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);
WIEGAND cardReader;

void setup() {
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  cardReader.begin(2,3);
  Serial.begin(9600);
}

void loop() {
  if (cardReader.available()) {
    unsigned long cardNumber = cardReader.getCode();
    char cardNumberHex[100]="";
    snprintf(cardNumberHex, sizeof(cardNumberHex), "%lX", cardNumber);
    // set the cursor to column 0, line 0
    // (note: counting begins with 0 line 1 is the second row)
    lcd.setCursor(0, 0);
    lcd.print(cardNumberHex);
    Serial.println(cardNumberHex);
  }
}

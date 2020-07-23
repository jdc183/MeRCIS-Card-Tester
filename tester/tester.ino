#include <SPI.h>
#include "definitions.h"


float received;
uint16_t out;
uint16_t sense;
float tx;
String rx;
SPISettings DAC_SETTINGS = SPISettings(1000000, MSBFIRST, SPI_MODE0);
SPISettings ADC_SETTINGS = SPISettings(125000, MSBFIRST, SPI_MODE0);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  SPI.begin();
  pinMode(13,OUTPUT);
  pinMode(ADC_PIN,OUTPUT);
  pinMode(DAC_PIN,OUTPUT);
  pinMode(LDAC_PIN,OUTPUT);
  pinMode(H_EN,OUTPUT);
  pinMode(H_POS,OUTPUT);
  pinMode(H_NEG,OUTPUT);

  pinMode(SC1_PIN,INPUT);
  pinMode(SC2_PIN,INPUT);
  pinMode(SC3_PIN,INPUT);
  
  digitalWrite(H_POS,HIGH);
  digitalWrite(H_NEG,LOW);
  digitalWrite(LDAC_PIN,LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
//  digitalWrite(13,LOW);//turn off led
  while (Serial.available()<2);//Wait for incoming serial data
//  digitalWrite(13,HIGH);//turn on led

  rx = Serial.readStringUntil('\n');//get received data
  received = rx.toFloat();  //convert it to a float
  
  if(received > 0.001){ //If its greater than zero
    digitalWrite(H_EN,HIGH);//Close the hbridge forward
    digitalWrite(H_POS,HIGH);
    digitalWrite(H_NEG,LOW);
  }
  else if(received < -0.001){//If its less than zero
    digitalWrite(H_EN,HIGH); //Reverse the hbridge
    digitalWrite(H_POS,LOW);
    digitalWrite(H_NEG,HIGH);
  }
  else{//otherwise
    digitalWrite(H_EN,LOW);//Open the hbridge
    
  }
  out = abs(received / 3.3 * 4095.0); //16bit int to write to dac
  DAC_write(out);  //Write this to the DAC
  delay(1);
  sense = ADC_read();  //Read the value from the ADC
  tx = float(sense) / 5397 * 3.3;  //Map it to a float
//  printBin(sense);
//  Serial.print('\t');
//  Serial.print(sense);
//  Serial.print('\t');
  Serial.print(String(tx,4));  //Send it back to the computer
  Serial.print('\n');
  
}

/* ************************ */
/* SPI functions */
/* ************************ */

/*  read a 12-bit value from the MCP3201 ADC  */
uint16_t ADC_read() {
    SPI.beginTransaction(ADC_SETTINGS);
    digitalWrite(ADC_PIN, LOW);
    uint16_t ret1(SPI.transfer16(0x0000)); 
    digitalWrite(ADC_PIN, HIGH);
    SPI.endTransaction();
    return ret1 & 0b0001111111111111;
}

/*  write a 12-bit value to the MCP4921 DAC  */
void DAC_write(uint16_t to_dac) {       
    byte dataMSB = highByte(to_dac);
    byte dataLSB = lowByte(to_dac);
    
    dataMSB &= 0b00001111;
    dataMSB = dataMSB | DAC_SELECT | INPUT_BUF | GAIN_SELECT | PWR_DOWN;
    
    SPI.beginTransaction(DAC_SETTINGS);
    noInterrupts();
    digitalWrite(DAC_PIN, LOW);
    SPI.transfer(dataMSB);
    SPI.transfer(dataLSB);
    digitalWrite(DAC_PIN, HIGH);
    interrupts();
    SPI.endTransaction();
}

/* initialize the SPI bus */
void SPI_init() {
  // trying new SPI.begin() call per Arduino Due documentation
  SPI.begin();  // Auto into mode1?  I don't think this line is necessary
  
    DAC_write((uint16_t)0);
}

void printBin(uint16_t c){
  for (int bits = 15; bits > -1; bits--) {
    // Compare bits 7-0 in byte
    if (c & (0b0000000000000001 << bits)) {
      Serial.print("1");
    }
    else {
      Serial.print("0");
    }
  }
}

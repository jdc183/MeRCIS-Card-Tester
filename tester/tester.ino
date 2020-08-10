#include <SPI.h>
#include "definitions.h"


float received;
uint16_t out;
uint16_t sense;
float tx;
String rx;
byte arr[3072];
uint16_t a, b;
int n;
#define ADC_SETTINGS  SPISettings(2000000, MSBFIRST, SPI_MODE0)

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
  while (Serial.available()<1);//Wait for incoming serial data
//  digitalWrite(13,HIGH);//turn on led

  rx = Serial.readStringUntil('\n');//get recieved data
  if (rx.indexOf("r") >= 0){
    digitalWrite(H_POS,HIGH);
    digitalWrite(H_NEG,LOW);
    digitalWrite(LDAC_PIN,LOW);
    for(int i = 0; i/3 < 1024; i+=3){
      if(i/3<683 && i/3>341){
        a = DADC_RW(4095);
        b = DADC_RW(4095);
      }
      else {
        a = DADC_RW(0);
        b = DADC_RW(0);
      }
      arr[i]   = a>>4;
      arr[i+1] = a<<4 | b>>8;
      arr[i+2] = b;
    }
    n = 0;
    for (int i = 0; i/3 < 1024; i+=3){
      a = (uint16_t)arr[i] <<4 | arr[i+1] >>4;
      b = ((uint16_t) arr[i+1] & 0x000F) <<8 | arr[i+2];
      Serial.print(n);
      Serial.print(",");
      n++;
      Serial.println(String(float(a) / 5397 * 2 * 3.3,4));
      Serial.print(n);
      Serial.print(",");
      n++;
      Serial.println(String(float(b) / 5397 * 2 * 3.3,4));
    }
    Serial.println('r');
  }
  else{
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
    //DAC_write(out);  //Write this to the DAC
    DADC_RW(out);
    delay(1);
    //sense = ADC_read();  //Read the value from the ADC
    sense = DADC_RW(out);
    tx = float(sense) / 5397 * 2 * 3.3;  //Map it to a float
  //  printBin(sense);
  //  Serial.print('\t');
  //  Serial.print(sense);
  //  Serial.print('\t');
    Serial.print(String(tx,4));  //Send it back to the computer
    Serial.print('\n');
  }
  
}

uint16_t DADC_RW(uint16_t to_dac){
  SPI.beginTransaction(ADC_SETTINGS);
  to_dac &= 0x0FFF;
  to_dac |= 0x3000;
  digitalWrite(DAC_PIN, LOW);
  digitalWrite(ADC_PIN, LOW);
  noInterrupts();
  uint16_t from_adc(SPI.transfer16(to_dac));
  interrupts();
  digitalWrite(DAC_PIN, HIGH);
  digitalWrite(ADC_PIN, HIGH);
  return (from_adc>>1) & 0x0FFF;
  SPI.endTransaction();
}

///* ************************ */
///* SPI functions */
///* ************************ */
//
///*  read a 12-bit value from the MCP3201 ADC  */
//uint16_t ADC_read() {
//    SPI.beginTransaction(ADC_SETTINGS);
//    digitalWrite(ADC_PIN, LOW);
//    uint16_t ret1(SPI.transfer16(0x0000)); 
//    digitalWrite(ADC_PIN, HIGH);
//    SPI.endTransaction();
//    return ret1 & 0b0001111111111111;
//}
//
///*  write a 12-bit value to the MCP4921 DAC  */
//void DAC_write(uint16_t to_dac) {       
//    byte dataMSB = highByte(to_dac);
//    byte dataLSB = lowByte(to_dac);
//    
//    dataMSB &= 0b00001111;
//    dataMSB = dataMSB | DAC_SELECT | INPUT_BUF | GAIN_SELECT | PWR_DOWN;
//    
//    SPI.beginTransaction(DAC_SETTINGS);
//    noInterrupts();
//    digitalWrite(DAC_PIN, LOW);
//    SPI.transfer(dataMSB);
//    SPI.transfer(dataLSB);
//    digitalWrite(DAC_PIN, HIGH);
//    interrupts();
//    SPI.endTransaction();
//}
//
///* initialize the SPI bus */
//void SPI_init() {
//  // trying new SPI.begin() call per Arduino Due documentation
//  SPI.begin();  // Auto into mode1?  I don't think this line is necessary
//    DAC_write((uint16_t)0);
//}
//
//void printBin(uint16_t c){
//  for (int bits = 15; bits > -1; bits--) {
//    // Compare bits 7-0 in byte
//    if (c & (0b0000000000000001 << bits)) {
//      Serial.print("1");
//    }
//    else {
//      Serial.print("0");
//    }
//  }
//}

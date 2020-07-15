#include <SPI.h>
#include "definitions.h"


float received;
uint16_t out;
uint16_t sense;
float tx;
String rx;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  SPI.begin();
  pinMode(13,OUTPUT);
  pinMode(ADC_PIN,OUTPUT);
  pinMode(DAC_PIN,OUTPUT);
  pinMode(H_EN,OUTPUT);
  pinMode(H_POS,OUTPUT);
  pinMode(H_NEG,OUTPUT);

  pinMode(SC1_PIN,INPUT);
  pinMode(SC2_PIN,INPUT);
  pinMode(SC3_PIN,INPUT);
  
  digitalWrite(H_POS,HIGH);
  digitalWrite(H_NEG,LOW);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(13,LOW);//turn off led
  while (Serial.available()<2);//Wait for incoming serial data
  digitalWrite(13,HIGH);//turn on led

  rx = Serial.readStringUntil('\n');//get recieved data
  received = rx.toFloat();  //convert it to a float
  if(received > 0.001){
    digitalWrite(H_EN,HIGH);
  }
  else{
    digitalWrite(H_EN,LOW);
  }
  out = received / 3.3 * 4095.0; //16bit int to write to dac
  DAC_write(out);  //Write this to the DAC
  sense = ADC_read();  //Read the value from the ADC
  tx = float(sense) / 4095.0 * 3.3;  //Map it to a float
  Serial.print(String(tx,4));  //Send it back to the computer
  Serial.print('\n');
  
}

/* ************************ */
/* SPI functions */
/* ************************ */

/*  read a 12-bit value from the MCP3201 ADC  */
uint16_t ADC_read() {
    digitalWrite(ADC_PIN, LOW);
    uint16_t ret1(SPI.transfer16(0x0000)); 
    digitalWrite(ADC_PIN, HIGH);
    return ret1;
}

/*  write a 12-bit value to the MCP4921 DAC  */
void DAC_write(uint16_t to_dac) {       
    byte dataMSB = highByte(to_dac);
    byte dataLSB = lowByte(to_dac);
    
    dataMSB &= 0b00001111;
    dataMSB = dataMSB | DAC_SELECT | INPUT_BUF | GAIN_SELECT | PWR_DOWN;
    
    digitalWrite(DAC_PIN, LOW);
    SPI.transfer(dataMSB);
    SPI.transfer(dataLSB);
    digitalWrite(DAC_PIN, HIGH);
}

/* initialize the SPI bus */
void SPI_init() {
  // trying new SPI.begin() call per Arduino Due documentation
  SPI.begin();  // Auto into mode1
  SPI.setBitOrder(MSBFIRST);
    DAC_write((uint16_t)0);
}

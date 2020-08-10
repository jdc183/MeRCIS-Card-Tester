float received;
int out;
int sense;
float sent;
String rx;
float arr[2048];

//byte received;
//byte sensed;
//uint8_t out;
//uint8_t in;

void setup() {
  // put your setup code here, to run once:
  analogWriteResolution(12);
  analogReadResolution(13);
  Serial.begin(115200);
//  Serial.bufferUntil('\n');
  pinMode(13,OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(13,LOW);
  while (Serial.available()<2);
//  Serial.flush();
//  digitalWrite(13,HIGH);
//  delay(10);
  rx = Serial.readStringUntil('\n');
  if (rx.indexOf("r") >= 0){
    for(int i = 0; i< 2048; i++){
      if(i <= 684 || i > 1366){
        digitalWrite(13,HIGH);
        analogWrite(A22,0);
        digitalWrite(13,LOW);
        arr[i] = float(analogRead(A20)) * 3.3 / 8192.0;
      }
      else{
        digitalWrite(13,HIGH);
        analogWrite(A22,4095);
        digitalWrite(13,LOW);
        arr[i] = float(analogRead(A20)) * 3.3 / 8192.0;
        
      }
    }
    for (int i = 0; i<2048; i++){
      Serial.print(i);
      Serial.print(",");
      Serial.println(arr[i]);
    }
    Serial.println('r');
  }
  else{
    received = rx.toFloat();
    out = int(received / 3.3 * 4095.0);
    analogWrite(A22, out);
    sense = analogRead(A20);
    sent = float(sense) / 8192.0 * 3.3;
    Serial.print(String(sent,4));
    Serial.print('\n');
  }
}

//void serialEvent(){
//  received = Serial.parseFloat();
//  out = int(received / 3.3 * 4095.0);
//  analogWrite(A22, out);
//  sense = analogRead(A0);
//  sent = float(sense) / 4095.0 * 3.3;
//  Serial.println(sent);
//  received = Serial.read();
//
//}

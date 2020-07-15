float received;
int out;
int sense;
float sent;
String rx;

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
  digitalWrite(13,HIGH);
//  delay(10);
  rx = Serial.readStringUntil('\n');
  received = rx.toFloat();
//  received = Serial.parseFloat();
  out = int(received / 3.3 * 4095.0);
  analogWrite(A22, out);
//  delay(10);
  sense = analogRead(A20);
  sent = float(sense) / 8192.0 * 3.3;
  Serial.print(String(sent,4));
  Serial.print('\n');
//  received = Serial.read();
  
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

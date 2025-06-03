String data;
int count = 0;
void setup() {
  Serial.begin(9600);
  delay(500);

}

void loop() {
  while(Serial.available() == 0){
    delay(100);
  }
  count = 0;
  data = Serial.readStringUntil("\r\n");
  data.trim();
  for(int i=0; i<data.length();i++){
    if(data.charAt(i)==',') count++;
  }
  if(count == 6) Serial.println(data);  //ensures that we have 7 data before sendind
  //Serial.println(count);
  //Serial.print(data);
  delay(100);
}

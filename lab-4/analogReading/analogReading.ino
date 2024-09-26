#define VX_PIN 0
#define VY_PIN 26
#define BUTTON_PIN 33
#define SWITCH_PIN 32

void setup() {
  // initialize serial communication at 115200 bits per second:
  Serial.begin(115200);

  //set the resolution to 12 bits (0-4095)
  analogReadResolution(12);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(SWITCH_PIN, INPUT_PULLUP);
}

void loop() {

  // read the analog / millivolts value for pin 2:
  int vYanalog = analogRead(VY_PIN);
  int vXanalog = analogRead(VX_PIN);
  int buttonAnalog = !digitalRead(BUTTON_PIN);
  int switchAnalog = !digitalRead(SWITCH_PIN);

  // print out the values you read:
  Serial.printf("%d,%d,%d,%d\n", vYanalog, vXanalog, buttonAnalog, switchAnalog);

  delay(100);  // delay in between reads for clear read from serial
}

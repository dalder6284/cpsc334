#include <Stepper.h>
#include <ESP32Servo.h>

const int stepsPerRevolution = 2048;  // change this to fit the number of steps per revolution

// ULN2003 Motor Driver Pins
#define IN1 19
#define IN2 18
#define IN3 5
#define IN4 17

#define SERVO 2

// initialize the stepper library
Stepper myStepper(stepsPerRevolution, IN1, IN3, IN2, IN4);
Servo servo1;

int pos = 0;


void setup() {
  // set the speed at 5 rpm
  myStepper.setSpeed(5);
  servo1.attach(SERVO);
  servo1.write(pos);
  // initialize the serial port
  Serial.begin(115200);
}

void loop() {
  // step one revolution in one direction:
  Serial.println("clockwise");
  myStepper.step(stepsPerRevolution);

  pos += 10;
  if (pos > 180) {
    pos = 0;
  }
  servo1.write(pos);
  
}
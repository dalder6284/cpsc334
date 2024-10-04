#include "DacESP32.h"
#include "math.h"

#define VX_PIN 27
#define VY_PIN 33
#define FREEZE 34 // Green
#define QUEUE 35 // Red
#define POP 32 // Blue
#define SWITCH_PIN 14

#define THIRD 0
#define FIFTH 2
#define STACK_SIZE 64

#define PREVIEW 1

DacESP32 dac1(DAC_CHANNEL_1);

int freezeState;
int fPressed = 0;
int frozen = 0;

int popState;
int pPressed = 0;

int queueState;
int qPressed = 0;

int vYanalog;
int vXanalog;
int freq = 330;
int oFreq;
int interval;
float plus = 0;

int stack[STACK_SIZE];
int stackTop = -1;

int mary[] = {
  660, 588, 524, 588, 660, 660, 660,
  588, 588, 588,
  660, 784, 784,
  660, 588, 524, 588, 660, 660, 660, 660,
  588, 588, 660, 588, 524
};

int push(int value) {
  if(stackTop < STACK_SIZE - 1) {
    stack[++stackTop] = value;
    return 0;
  } else {
    return 1;
  }
}

int pop() {
  if (stackTop >= 0) {
    int value = stack[stackTop--];
    return value;
  } else {
    return freq;
  }
}


void setup() {
  Serial.begin(9600);

  pinMode(QUEUE, INPUT_PULLUP);
  pinMode(POP, INPUT_PULLUP);
  pinMode(FREEZE, INPUT_PULLUP);
  pinMode(SWITCH_PIN, INPUT_PULLUP);
  analogReadResolution(12);

  if (PREVIEW) 
  {
    int marySize = sizeof(mary) / sizeof(mary[0]);  
    for (int i = 0; i < marySize && i < STACK_SIZE; i++) {
      stack[i] = mary[marySize - i - 1];
      stackTop++;
    }
  }
}

void loop() {

  // Switch acts as a muting button
  if (!digitalRead(SWITCH_PIN)) {
    dac1.outputCW(1);
  } else {
    
    vYanalog = analogRead(VY_PIN);
    freq = map(vYanalog, 0, 4095, 300, 1600);

    vXanalog = analogRead(VX_PIN);
    interval = map(vXanalog, 0, 4095, 0, 2);

 
    plus = 0;

    if(digitalRead(QUEUE)) {
      plus += 2.0;;
    }

    if (digitalRead(POP)) {
      plus += 1.0;
    }

    if (digitalRead(FREEZE)) {
      plus *= 3;
    }

    if (interval == THIRD) {
      oFreq = freq * pow(2.0, (4.0 + plus) / 12.0);
    } else if (interval == FIFTH) {
      oFreq = freq * pow(2.0, (7.0 + plus)/ 12.0);
    } else {
      oFreq = freq * pow(2.0, plus / 12.0);
    }

    dac1.outputCW(int(oFreq));
  }

  // queueState = digitalRead(QUEUE);
  // if (queueState == LOW && !qPressed) {
  //   qPressed = 1;
  // } else if (queueState == HIGH){
  //   qPressed = 0;
  // }

  // popState = digitalRead(POP);
  // if (popState == LOW && !pPressed) {
  //   pPressed = 1;
  // } else if (popState == HIGH){
  //   pPressed = 0;
  // }

}
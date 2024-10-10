#include "DacESP32.h"
#include "math.h"

#define VX_PIN 27
#define VY_PIN 33
#define FREEZE 18 // Green
#define QUEUE 21 // Blue
#define POP 5 // Black
#define SWITCH_PIN 14

#define THIRD 0
#define FIFTH 2
#define STACK_SIZE 64

#define PREVIEW 1

DacESP32 dac1(DAC_CHANNEL_1);

int freezeState = HIGH;
int lastFreezeState = HIGH;
int fPressed = false;

int popState = HIGH;
int lastPopState = HIGH;
int pPressed = false;

int queueState = HIGH;
int lastQueueState = HIGH;
int qPressed = false;

bool frozen = false;

int vYanalog;
int vXanalog;
int freq = 330;
int oFreq;
int interval;
float plus = 0;

int stack[STACK_SIZE];
int stackTop = -1;

int mary[] = {
  660, 660, 660, 588, 524, 588, 660, 660, 660,
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

  freezeState = digitalRead(FREEZE);
  Serial.print(freezeState);

  if (freezeState == LOW && lastFreezeState == HIGH) {
    fPressed = true;
  }

  if (fPressed) {
    frozen = !frozen;
    fPressed = false;
  }

  popState = digitalRead(POP);
  Serial.print(",");
  Serial.print(popState);

  if (popState == LOW && lastPopState == HIGH) {
    pPressed = true;
  }

  if (pPressed) {
    frozen = true;
    freq = pop();
    pPressed = false;
  }

  queueState = digitalRead(QUEUE);
  Serial.print(",");
  Serial.println(queueState);

  if (queueState == LOW && lastQueueState == HIGH) {
    qPressed = true;
  }

  if (qPressed) {
    push(oFreq);
    qPressed = false;
  }

  // Switch acts as a muting button
  if (!digitalRead(SWITCH_PIN)) {
    dac1.outputCW(1);
  } else {
    
    if (!frozen) {
      vYanalog = analogRead(VY_PIN);
      freq = map(vYanalog, 0, 4095, 200, 600);
    }

    vXanalog = analogRead(VX_PIN);
    interval = map(vXanalog, 0, 4095, 0, 2);


    if (interval == THIRD) {
      oFreq = freq * pow(2.0, (4.0 + plus) / 12.0);
    } else if (interval == FIFTH) {
      oFreq = freq * pow(2.0, (7.0 + plus)/ 12.0);
    } else {
      oFreq = freq * pow(2.0, plus / 12.0);
    }

    dac1.outputCW(int(oFreq));
  }

  lastFreezeState = freezeState;
  lastPopState = popState;
  lastQueueState = queueState;

}
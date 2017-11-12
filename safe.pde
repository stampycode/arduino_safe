
#include "pitches.h"

#define LOCKPIN 12
 //PWM on 3,5,6,9,10,11
#define BUZZPIN 11

#define WAIT 100

#define KP_R1 2
#define KP_C4 3
#define KP_C3 4
#define KP_C2 5
#define KP_R4 6
#define KP_C1 7
#define KP_R3 8
#define KP_R2 9

char curr = 0;
char key = 0;
char prev = 0;
int len = 24;
char inp[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
char set[] = {'6','5','4','3','2','1',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
uint16_t i = 0;

void buzz() {
  tone(BUZZPIN, NOTE_C7);
}
void nobuzz() {
  noTone(BUZZPIN);
}

void setup() {
  pinMode(LOCKPIN, OUTPUT);
  pinMode(BUZZPIN, OUTPUT);

  pinMode(KP_R1, OUTPUT);
  pinMode(KP_R2, OUTPUT);
  pinMode(KP_R3, OUTPUT);
  pinMode(KP_R4, OUTPUT);
  pinMode(KP_C1, INPUT_PULLUP);
  pinMode(KP_C2, INPUT_PULLUP);
  pinMode(KP_C3, INPUT_PULLUP);
  pinMode(KP_C4, INPUT_PULLUP);

  tone(BUZZPIN, NOTE_C7); delay(100);
  tone(BUZZPIN, NOTE_D7); delay(100);
  tone(BUZZPIN, NOTE_E7); delay(100);
  tone(BUZZPIN, NOTE_D7); delay(100);
  tone(BUZZPIN, NOTE_C7); delay(100);
}

int KP_R[] = {KP_R1, KP_R2, KP_R3, KP_R4};
int KP_C[] = {KP_C1, KP_C2, KP_C3, KP_C4};
int c, r;
char KP[] = {
  '1', '2', '3', 'A',
  '4', '5', '6', 'B',
  '7', '8', '9', 'C',
  '*', '0', '#', 'D'
};
char readKey() {
    for(r=0; r<4; ++r) {
      for(c=0; c<4; ++c) {
        digitalWrite(KP_R[c], r==c ? LOW : HIGH);
      }
      for(c=0; c<4; ++c) {
        if(!digitalRead(KP_C[c])) {
          return KP[(r * 4) + c];
        }
      }
    }
    return 0;
}

void reset() {
  curr = 0;
  for(i=0; i<len; ++i) {
    inp[i] = 0;
  }
}

void loop() {
  // switch off buzzer
  nobuzz();

  key = readKey();
  if(key == 0 || key == prev) {
    // set prev to null if key released
    if(prev != key) {
      delay(WAIT);
    }
    prev = key;
    return;
  }

  if(key == '#') {
    reset();
    delay(WAIT);
    return;
  }

  if(key == '*') {
    for(i=0; i<len; ++i) {
      if(inp[i] != set[i]) {
        // wrong code

        tone(BUZZPIN, NOTE_A5); delay(300);
        tone(BUZZPIN, NOTE_E5); delay(300);
        tone(BUZZPIN, NOTE_CS5); delay(300);
        reset();
        return;
      }
    }
    // unlocked
    reset();
    digitalWrite(LOCKPIN, HIGH);
    tone(BUZZPIN, NOTE_C6); delay(100);
    tone(BUZZPIN, NOTE_D6); delay(100);
    tone(BUZZPIN, NOTE_E6); delay(100);
    tone(BUZZPIN, NOTE_F6); delay(100);
    tone(BUZZPIN, NOTE_G6); delay(100);
    tone(BUZZPIN, NOTE_A7); delay(100);
    tone(BUZZPIN, NOTE_B7); delay(100);
    tone(BUZZPIN, NOTE_C7); delay(100);
    noTone(BUZZPIN);
    delay(1000);
    digitalWrite(LOCKPIN, LOW);
    return;
  }

  // 0-9a-d keypressed
  if(curr < len) {
    inp[curr] = key;
    ++curr;
  }
  buzz();
  delay(WAIT);

  prev = key;
}

#include <stdio.h>
#include "hardware.h"

long bouncer_state;
u_int8_t signals[] = {0b00000001, 0b00000001, 0b00000000, 0b00000010, 0b00000011, 0b00000000, 0b00000000, 0b00000001, 0b00000011, 0b00000011, 0b00000001, 0b00000010, 0b00000010, 0b00000000};
int sig_len = 14;
int sig_idx = 0;

// Lets emulate the bouncer
const uint8_t DEBOUNCED_STATE = 0b00000001;
const uint8_t UNSTABLE_STATE = 0b00000010;
const uint8_t CHANGED_STATE = 0b00000100;

void setStateFlag(const uint8_t flag) {
    bouncer_state |= flag;
}

void unsetStateFlag(const uint8_t flag) {
    bouncer_state &= ~flag;
}

void toggleStateFlag(const uint8_t flag) {
    bouncer_state ^= flag;
}

long getStateFlag(const uint8_t flag) {
    return ((bouncer_state & flag) != 0);
}  
void changeState(){
    toggleStateFlag(DEBOUNCED_STATE);
    setStateFlag(CHANGED_STATE);
}

long digitalRead(){
        long val = signals[sig_idx];
        sig_idx++;
	return val;
}

long changed() {return getStateFlag(CHANGED_STATE);}

long readCurrentState() {return digitalRead();}

void bouncer_begin(){
   bouncer_state = 0;
   if (readCurrentState()){
      setStateFlag(DEBOUNCED_STATE | UNSTABLE_STATE);
   } 
}

long bouncer_update(){
   unsetStateFlag(CHANGED_STATE);
   
   long currentState = readCurrentState();

   if (((currentState & UNSTABLE_STATE) !=0) != getStateFlag(UNSTABLE_STATE)){
      toggleStateFlag(UNSTABLE_STATE);
   }else{
      if (((currentState & DEBOUNCED_STATE) !=0) != getStateFlag(DEBOUNCED_STATE)){
          changeState();
      }
   }
   return changed();
}

int bouncer_read() {
    return getStateFlag(DEBOUNCED_STATE);
}

int main() {

  char datastring[] = {'\0','\0','\0','\0','\0','\0','\0','\0','\0','\0'};
  int index = 0;

  bouncer_begin();
  while(sig_idx < sig_len){
      if(bouncer_update()){
          if(bouncer_read() == 0){
              datastring[index] = '1';
              datastring[index+1] = ',';
              index = index + 2;   
          }
      }
  }
  
  acfa_exit();
  return 0; 
}

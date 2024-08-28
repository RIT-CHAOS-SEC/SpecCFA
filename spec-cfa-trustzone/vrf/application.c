#include "stm32l5xx_hal.h"
#include "application.h"
#include "math.h"

#if APP_SEL == MOUSE
// Mouse buttons
#define MOUSE_SWITCH 2      // switch to turn on and off mouse control
#define MOUSE_LEFT_BTN 5
#define MOUSE_RIGHT_BTN 3

#define MOUSE_X_AXIS_INPT 'x'
#define MOUSE_Y_AXIS_INPT 'y'

#define MOUSE_SENSITIVITY 10
#define JOYSTICK_DEADZONE 1

#define LOOP_DELAY 5

// Operation modes for readMouseButton function
#define INPUT_LOW_MODE 1
#define INPUT_HIGH_MODE 2
#define INPUT_CHANGED_MODE 3


// Ported mouse.cpp
#define MOUSE_LEFT 1
#define MOUSE_RIGHT 2
#define MOUSE_MIDDLE 4
#define MOUSE_ALL (MOUSE_LEFT | MOUSE_RIGHT | MOUSE_MIDDLE)

#define bool    uint8_t
#define true    1
#define false   0

uint8_t _buttons;
//================================================================================
//================================================================================
//  Mouse

/* This function is for limiting the input value for x and y
 * axis to -127 <= x/y <= 127 since this is the allowed value
 * range for a USB HID device.
 */
signed char limit_xy(int const xy)
{
  SECURE_new_log_entry();
  if     (xy < -127) return -127;
  else if(xy >  127) return 127;
  else               return xy;
}

void mouseBegin(void) 
{
      SECURE_new_log_entry();
}

void mouseEnd(void) 
{
      SECURE_new_log_entry();
}

void mouseMove(int x, int y, signed char wheel)
{
      SECURE_new_log_entry();
    uint8_t m[4];
    m[0] = _buttons;
    m[1] = limit_xy(x);
    m[2] = limit_xy(y);
    m[3] = wheel;
    //HID().SendReport(1,m,4);
}

void mouseClick(uint8_t b)
{
      SECURE_new_log_entry();
    _buttons = b;
    mouseMove(0,0,0);
    _buttons = 0;
    mouseMove(0,0,0);
}
void mouseButtons(uint8_t b)
{
      SECURE_new_log_entry();
    if (b != _buttons)
    {
        _buttons = b;
        mouseMove(0,0,0);
    }
}

void mousePress(uint8_t b) 
{
      SECURE_new_log_entry();
    mouseButtons(_buttons | b);
}

void mouseRelease(uint8_t b)
{
      SECURE_new_log_entry();
    mouseButtons(_buttons & ~b);
}

bool mouseIsPressed(uint8_t b)
{
      SECURE_new_log_entry();
    if ((b & _buttons) > 0) 
        return true;
    return false;
}

bool mouseActive = false;    // whether or not to control the mouse
bool lastSwitchState = true; // previous switch state
bool lastMouseRightState = true;
bool lastMouseLeftState = true;

int mockReads[200] = {95, -39, -39, -10, -100, 119, 43, 15, 67, 129, 98, -30, 26, 90, -154, -109, -182, -103, -114, -111, 14, -119, -148, -46, -67, -162, -1, -198, 116, -82, 4, -158, 60, 73, 77, -74, 180, -128, -134, -3, 195, -31, 123, -33, 0, 150, 42, 125, 27, -164, -38, -99, -162, 112, 70, -21, 134, -123, 72, 184, 81, -169, -147, 146, -3, -143, 173, 13, 90, 189, -99, -40, -69, -65, 80, -34, -82, -196, -68, -75, 200, -144, 163, 96, 14, 38, -140, 31, 94, 54, 87, 173, -75, -199, -74, -8, 95, -185, -34, 62, -1, -120, -124, -164, -2, 51, 116, -86, -135, 114, 179, 21, 173, -39, -40, -28, -1, -73, -1, 192, -76, -141, -91, -160, 139, 43, -132, 38, -68, -168, 87, 9, 66, 50, -84, -146, -56, -104, -114, -45, -7, 43, 161, 58, -65, -7, -66, -54, 129, 55, 101, 28, -103, 46, 121, 188, -83, 147, 174, -195, -54, -169, 76, 31, 194, -104, -112, 53, 159, 35, -172, 184, -175, -56, -148, 192, 132, -87, 124, -160, -22, -163, -172, -139, 36, -125, -71, -99, -139, -81, 167, 40, 50, 45, -94, -20, -111, 21, 11, -55};

/*void setup() {
  pinMode(MOUSE_SWITCH, INPUT);       // the switch pin
  pinMode(MOUSE_LEFT_BTN, INPUT);
  pinMode(MOUSE_RIGHT_BTN, INPUT);
  pinMode(LED_BUILTIN, OUTPUT);
}*/
int indx = 0;
int analogRead(char axis){
      SECURE_new_log_entry();
    int readings;
    if(axis == 'x'){
        readings = mockReads[indx];
    }else if(axis == 'y'){
        readings = mockReads[indx];
    }
    indx += 1;
    return readings;
}

int map(int reading, int min, int max, int min_sen, int max_sen){
      SECURE_new_log_entry();
    return (reading - min) * (max_sen - min_sen) / (max - min) + min_sen;
}

void handleMouse() {
      SECURE_new_log_entry();
  int xReading = analogRead(MOUSE_X_AXIS_INPT);
  int yReading = analogRead(MOUSE_Y_AXIS_INPT);

  // map the reading from the analog input range to the output range:
  int mouseX = map(xReading, 0, 1024, -MOUSE_SENSITIVITY, MOUSE_SENSITIVITY);
  int mouseY = map(yReading, 0, 1024, MOUSE_SENSITIVITY, -MOUSE_SENSITIVITY);

  // if joystick moved out of the deadzone, move the mouse
  if (mouseX > JOYSTICK_DEADZONE || mouseX < -JOYSTICK_DEADZONE || mouseY < -JOYSTICK_DEADZONE || mouseY > JOYSTICK_DEADZONE)
  {
    mouseMove(mouseX, mouseY, 0);
  }
}

bool digitalRead(int button){
      SECURE_new_log_entry();
    return !lastSwitchState;
}

/**
 * Has folloving operation modes:
 * 1. INPUT_LOW_MODE - returns true when btn state changes from HIGH to LOW
 * 2. INPUT_HIGH_MODE - returns true when btn state changes from LOW to HIGH
 * 3. INPUT_CHANGED_MODE - return true when btn state changes from HIGH to LOW or from LOW to HIGH
 */
bool readMouseButton(int button, bool lastState, unsigned char mode) {
      SECURE_new_log_entry();
  bool ret = false;
  bool state = digitalRead(button);
  if (state != lastState) {
    if ((mode == INPUT_LOW_MODE && state == false) || (mode == INPUT_HIGH_MODE && state == true) || mode == INPUT_CHANGED_MODE) {
      ret = true;
    }
  }
  lastState = state;
  return ret;
}

void application() {
      SECURE_new_log_entry();
  for(int i=0; i<100; i++){
    // check if mouse in ON/OFF
    if (readMouseButton(MOUSE_SWITCH, lastSwitchState, INPUT_LOW_MODE)) {
      if (mouseActive) {
        mouseEnd();
        mouseActive = false;
      } else {
        mouseBegin();
        mouseActive = true;
      }
    }
    //digitalWrite(LED_BUILTIN, mouseActive);

    if (mouseActive) {
      handleMouse();

      // check left mouse btn
      if (readMouseButton(MOUSE_LEFT_BTN, lastMouseLeftState, INPUT_CHANGED_MODE)) {
        if (lastMouseLeftState == false && !mouseIsPressed(MOUSE_LEFT_BTN)) {
          mousePress(MOUSE_LEFT);
        } else if (lastMouseLeftState == true && mouseIsPressed(MOUSE_LEFT_BTN))
          mouseRelease(MOUSE_LEFT);
        }
      }

      // check right mouse btn
      if (readMouseButton(MOUSE_RIGHT_BTN, lastMouseRightState, INPUT_HIGH_MODE)) {
        mousePress(MOUSE_RIGHT);
        mouseRelease(MOUSE_RIGHT);
    } 
  
    for(int j=0; j < LOOP_DELAY; j++){}
  }

}
#endif

// #include "stdio.h"
#if APP_SEL == GPS
// #include <ctype.h>
#include <stdlib.h>
// #include <string.h>

//Lets fake another library

// get_position, f_get_position, get_datetime, crack_datetime stats
#define _GPS_MAX_FIELD_SIZE 15
#define _GPRMCterm "GPRMC"
#define _GPGGAterm "GPGGA"
#define _GNRMCterm "GNRMC"
#define _GNGGAterm "GNGGA"
#define GPS_INVALID_ANGLE 999999999

enum {GPS_SENTENCE_GPGGA,  GPS_SENTENCE_GPRMC, GPS_SENTENCE_OTHER};
static const float GPS_INVALID_F_ANGLE, GPS_INVALID_F_ALTITUDE, GPS_INVALID_F_SPEED;
int encodedCharCount = 0; 
uint8_t parity =0;
int isChecksumTerm = 0;
uint8_t curSentenceType = GPS_SENTENCE_OTHER;
uint8_t curTermNumber = 0;
uint8_t curTermOffset = 0;
char term[_GPS_MAX_FIELD_SIZE] = {'\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0','\0'};
int sentenceHasFix = 0;
int passedChecksumCount = 0;
int sentencesWithFixCount = 0;
int failedChecksumCount = 0;

int mystrcmp(char * s1, char * s2) {
    SECURE_new_log_entry();
    int res = 0;
    int first = 1;
    for(int i = 0; i < _GPS_MAX_FIELD_SIZE; i++) {
      if (first == 1 && s1[i] > s2[i]) {
        res = 1;
        first = 0;
      }
      else if (first == 1 && s1[i] < s2[i]) {
        res = 1;
        first = 0;
      }
    }
    return res;
}

int isdigit(int c)
{
    SECURE_new_log_entry();
    return (unsigned)c - '0' < 10;
}

int fromHex(char a){
    SECURE_new_log_entry();
    if (a >= 'A' && a <= 'F'){
        return a - 'A' + 10;
    }else if (a >= 'a' && a <= 'f'){
        return a - 'a' + 10;
    }else{
        return a - '0';
    }
}

// mock functions
int validDate = 0;
int upDate = 0;
uint32_t dateValue = 0;
void date_commit(){
    SECURE_new_log_entry();
    validDate = 1;
    upDate = 1;
}

int32_t timeVal = 0;
int validTime = 0;
int updateTime = 0;
void time_commit(){
    SECURE_new_log_entry();
    validTime = 1;
    updateTime = 1;
}


float lat = 0;
float lng = 0;
int rawNewLatDataNegative = 0;
int rawNewLongDataNegative = 0;
int validLoc = 0;
int updateLoc = 0;
void location_commit(){
    SECURE_new_log_entry();
    validLoc = 0;
    updateLoc = 0;
}

float speedVal = 0;
int validSpeed = 0;
int updateSpeed = 0;
void speed_commit(){
    SECURE_new_log_entry();
    validSpeed = 1;
    updateSpeed = 1;
}

float degrees = 0.0;
int validDeg = 0;
int updateDeg = 0;
void course_commit(){
    SECURE_new_log_entry();
    validDeg = 1;
    updateDeg = 1;
}

float height = 0.0;
int validAlt = 0;
int updateAlt = 0;
void altitude_commit(){
    SECURE_new_log_entry();
    validAlt = 1;
    updateAlt = 1;
}

int validSat = 0;
int updateSat = 0;
int satCount = 0;
void satellites_commit(){
    SECURE_new_log_entry();
    validSat = 1;
    updateSat = 1;
}

float hdopVal = 0.0;
int validHDop = 0;
int updateHDop = 0;
void hdop_commit(){
    SECURE_new_log_entry();
    validHDop = 1;
    updateHDop = 1;
}

float parseDegrees(char *term)
{
  SECURE_new_log_entry();
  uint32_t leftOfDecimal = (uint32_t)atol(term);
  uint16_t minutes = (uint16_t)(leftOfDecimal % 100);
  uint32_t multiplier = 10000000UL;
  uint32_t tenMillionthsOfMinutes = minutes * multiplier;

  int16_t deg = (int16_t)(leftOfDecimal / 100);

  while (isdigit(*term))
    ++term;

  if (*term == '.')
    while (isdigit(*++term))
    {
      multiplier /= 10;
      tenMillionthsOfMinutes += (*term - '0') * multiplier;
    }

  deg += ((5 * tenMillionthsOfMinutes + 1) / 3)/1000000000.0f;
  return (float) deg;
}

int32_t parseDecimal(char *term){
    SECURE_new_log_entry();
    int negative = *term == '-';
    if (negative) ++term;
    int32_t ret = 100 * (int32_t)atol(term);
    while (isdigit(*term)) ++term;
    if (*term == '.' && isdigit(term[1])){
        ret += 10 * (term[1] - '0');
        if (isdigit(term[2]))
            ret += term[2] - '0';
    }
    return negative ? -ret : ret;
}

void time_setTime(char *term){
    SECURE_new_log_entry();
    timeVal = parseDecimal(term);
}

void location_setLatitude(char *term)
{
    SECURE_new_log_entry();
   lat = parseDegrees(term);
}

void location_setLongitude(char *term)
{
    SECURE_new_log_entry();
   lng = parseDegrees(term);
}

void speed_set(char *term){
    SECURE_new_log_entry();
    speedVal = parseDecimal(term);
}

void course_set(char *term){
    SECURE_new_log_entry();
    degrees = parseDecimal(term);
}

void satellites_set(char *term){
    SECURE_new_log_entry();
    satCount ++;
}

void date_setDate(char *term){
    SECURE_new_log_entry();
    dateValue = atol(term);
}

void hdop_set(char *term){
    SECURE_new_log_entry();
    hdopVal = parseDecimal(term);
}

void altitude_set(char *term){
    SECURE_new_log_entry();
    height = parseDecimal(term);
}

int endOfTermHandler(){
    SECURE_new_log_entry();
    if(isChecksumTerm){
        unsigned char checksum = 16 * fromHex(term[0]) + fromHex(term[1]);
        if (checksum == parity){
            passedChecksumCount++;
            if (sentenceHasFix){
                ++sentencesWithFixCount;
            }
            switch(curSentenceType){
                case GPS_SENTENCE_GPRMC:
                    date_commit();
                    time_commit();
                    if(sentenceHasFix){
                        location_commit();
                        speed_commit();
                        course_commit();
                    }
                    break;
                case GPS_SENTENCE_GPGGA:
                    time_commit();
                    if(sentenceHasFix){
                        location_commit();
                        altitude_commit();
                    }
                    satellites_commit();
                    hdop_commit();
                    break;
               }
            return 1;
        }else{
            ++failedChecksumCount;  
        }
        // return 0;
    }
    if (curTermNumber == 0){
        if(!mystrcmp(term, _GPRMCterm) || !mystrcmp(term, _GNRMCterm)){
            curSentenceType = GPS_SENTENCE_GPRMC;
        }else if (!mystrcmp(term, _GPGGAterm) || !mystrcmp(term, _GNGGAterm)){
            curSentenceType = GPS_SENTENCE_GPGGA;
        }else{
            curSentenceType = GPS_SENTENCE_OTHER;
        }
        // return 0;
    }
    if (curSentenceType != GPS_SENTENCE_OTHER && term[0]){
        switch(curSentenceType){
            case GPS_SENTENCE_GPRMC:
                switch(curTermNumber){
                    case 1:
                        time_setTime(term);
                        break;
                    case 2:
                        sentenceHasFix = term[0] == 'A';
                        break;
                    case 3:
                        location_setLatitude(term);
                        break;
                    case 4:
                        rawNewLatDataNegative = term[0] == 'S';
                        break;
                    case 5:
                        location_setLongitude(term);
                        break;
                    case 6:
                        rawNewLongDataNegative = term[0] == 'W';
                        break;
                    case 7:
                        speed_set(term);
                        break;
                    case 8:
                        course_set(term);
                        break;
                    case 9:
                        date_setDate(term);
                        break;
                }
                break;
            case GPS_SENTENCE_GPGGA:
                switch(curTermNumber){
                    case 1:
                        time_setTime(term);
                        break;
                    case 2:
                        location_setLatitude(term);
                        break;
                    case 3:
                        rawNewLatDataNegative = term[0] == 'S';
                        break;
                    case 4:
                        location_setLongitude(term);
                        break;
                    case 5:
                        rawNewLongDataNegative = term[0] == 'W';
                        break;
                    case 6:
                        sentenceHasFix = term[0] > 0;
                        break;
                    case 7:
                        satellites_set(term);
                        break;
                    case 8:
                        hdop_set(term);
                        break;
                    case 9:
                        altitude_set(term);
                        break;
                }
                break;
            }
        }
    return 0;
}


int gps_encode(char c) {
    SECURE_new_log_entry();
    SECURE_record_output_data(c);
    ++encodedCharCount;

    switch(c){
        case ',':
            parity ^= (uint8_t)c;
            SECURE_record_output_data('1');
        case '\r':
            SECURE_record_output_data('2');
        case '\n':
            SECURE_record_output_data('3');
        case '*':
            {
            SECURE_record_output_data('4');
            int isValidSentence = 0;
            if (curTermOffset < 15){
                term[curTermOffset] = 0;
                isValidSentence = endOfTermHandler();
            }
            ++curTermNumber;
            curTermOffset = 0;
            isChecksumTerm = (int)c == '*';
            return isValidSentence;
            break;
            }
        case '$':
            SECURE_record_output_data('5');
            curTermNumber = curTermOffset = 0;
            parity = 0;
            curSentenceType = GPS_SENTENCE_OTHER;
            isChecksumTerm = 0;
            sentenceHasFix = 0;
            return 0;
        default:
            SECURE_record_output_data('6');
            if (curTermOffset < _GPS_MAX_FIELD_SIZE-1){
                term[curTermOffset++] = c;
            }
            if (!isChecksumTerm){
                parity ^= c;
            }
            return 0;
    }
    return 0;
}

void get_position(long *latitude, long *longitude){
    SECURE_new_log_entry();
    if (latitude) *latitude = lat;
    if (longitude) *longitude = lng;
}

void f_get_position(float *flat, float *flng){
    SECURE_new_log_entry();
    long tempLat, tempLong;
    get_position(&tempLat, &tempLong);
    *flat = tempLat == GPS_INVALID_ANGLE ? GPS_INVALID_F_ANGLE : (tempLat / 1000000.0f);
    *flng = tempLong == GPS_INVALID_ANGLE ? GPS_INVALID_F_ANGLE : (tempLong / 1000000.0f);
}

void get_datetime(unsigned long *date, unsigned long *time){
    SECURE_new_log_entry();
    if(date) *date = dateValue;
    if(time) *time = timeVal;
}

void crack_datetime(int* year, unsigned char* month, unsigned char* day, unsigned char* hour, unsigned char* minute, unsigned char* second, unsigned char* hundredths){
    SECURE_new_log_entry();
    unsigned long tempDate, tempTime;
    get_datetime(&tempDate, &tempTime);
    if (year) {
        *year = tempDate % 100;
        *year += *year > 80 ? 1900 : 2000;
    } 
    if (month) *month = (tempDate / 100) % 100;
    if (day) *day = tempDate / 10000;
    if (hour) *hour = tempTime / 1000000;
    if (minute) *minute = (tempTime / 10000) % 100;
    if (second) *second = (tempTime / 100) % 100;
    if (hundredths) *hundredths = tempTime % 100;
}

void stats(unsigned long* chars, unsigned short* sentences, unsigned short* failed){
    SECURE_new_log_entry();
    if (chars) *chars = encodedCharCount;
    if (sentences) *sentences = passedChecksumCount;
    if (failed) *failed = failedChecksumCount;
} 

// __attribute ((naked)) void my_aeabi_i2d(){
//     SECURE_new_log_entry();
//     __asm__ volatile("teq   r0, #0");
//     __asm__ volatile("itteq");
//     __asm__ volatile("moveq r1, #0");
//     __asm__ volatile("bxeq  lr");
//     __asm__ volatile("bx    lr");
// }

void gpsdump()
{
  SECURE_new_log_entry();

  long lat, lon;
  float flat, flon;
  unsigned long date, time, chars;
  int year;
  unsigned char month, day, hour, minute, second, hundredths;
  unsigned short sentences, failed;

  get_position(&lat, &lon);
  f_get_position(&flat, &flon);
  get_datetime(&date, &time);
  crack_datetime(&year, &month, &day, &hour, &minute, &second, &hundredths);
  stats(&chars, &sentences, &failed);
}


#define BUFFER_LEN    46
const char input_buffer[BUFFER_LEN] = 
{'$', 'G', 'P', 'R', 'M', 'C', '\n', '1', '0', '.', '2', '3', ',', 'A',',', '-', '2', '4', ',', 'N', ',',
'5', '4', ',', 'W', ',', '1', '5', '.', '4', '3',',', '9', '9', '.', '9', ',', '1', '2', '3', '4', '*', '3',
'4', '\n'}; // $GPRMC\n10.23,A,-24,N,54,W,15.43,99.9,1234*34\n$GPGGA\n10.23,-9,S,13,E,1,Doesnt matter,12.34,56.78*12\n\0};

volatile uint32_t lt, ln;
volatile uint32_t d, t, c;
volatile int y;
volatile char m, da, h, mi, s, hu;
volatile unsigned short se, f;

void application(){
    SECURE_new_log_entry();
    for (int buffer_index = 0; buffer_index < BUFFER_LEN; buffer_index++){
        gps_encode(input_buffer[buffer_index]);
    }

    gpsdump();
}

#endif

#if APP_SEL == GEIGER
uint32_t bouncer_state;
#define sig_len 14
uint8_t signals[sig_len] = {0b00000001, 0b00000001, 0b00000000, 0b00000010, 0b00000011, 0b00000000, 0b00000000, 0b00000001, 0b00000011, 0b00000011, 0b00000001, 0b00000010, 0b00000010, 0b00000000};
int sig_idx = 0;

// Lets emulate the bouncer
const uint8_t DEBOUNCED_STATE = 0b00000001;
const uint8_t UNSTABLE_STATE = 0b00000010;
const uint8_t CHANGED_STATE = 0b00000100;

void setStateFlag(const uint8_t flag) {
    SECURE_new_log_entry();
    bouncer_state |= flag;
}

void unsetStateFlag(const uint8_t flag) {
    SECURE_new_log_entry();
    bouncer_state &= ~flag;
}

void toggleStateFlag(const uint8_t flag) {
    SECURE_new_log_entry();
    bouncer_state ^= flag;
}

uint32_t getStateFlag(const uint8_t flag) {
    SECURE_new_log_entry();
    return ((bouncer_state & flag) != 0);
}  
void changeState(){
    toggleStateFlag(DEBOUNCED_STATE);
    setStateFlag(CHANGED_STATE);
}

uint32_t digitalRead(){
    SECURE_new_log_entry();
    uint32_t val = signals[sig_idx];
    sig_idx++;
    return val;
}

uint32_t changed() {
    SECURE_new_log_entry();
    return getStateFlag(CHANGED_STATE);
}

uint32_t readCurrentState() {
    SECURE_new_log_entry();
    return digitalRead();
}

void bouncer_begin(){
    SECURE_new_log_entry();
   bouncer_state = 0;
   if (readCurrentState()){
      setStateFlag(DEBOUNCED_STATE | UNSTABLE_STATE);
   } 
}

uint32_t bouncer_update(){
    SECURE_new_log_entry();
   unsetStateFlag(CHANGED_STATE);
   
   uint32_t currentState = readCurrentState();

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

uint8_t datastring[10] = {'\0','\0','\0','\0','\0','\0','\0','\0','\0','\0'};
void application() {
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
}
#endif

#if APP_SEL == BASIC

uint32_t start_time = 0;
uint32_t end_time = 0;
uint32_t nsc_time = 0;
uint32_t test = 0;
void application(){
    test = 1;
    start_time = HAL_GetTick();
    for(int i=0; i<100; i++);
    end_time = HAL_GetTick();
    nsc_time += end_time - start_time;
    SECURE_record_output_data(test);
    SECURE_record_output_data(nsc_time);
}

#endif

/******************* SYRINGE APP *********************/

#if APP_SEL == SYRINGE
enum{PUSH,PULL};
int steps;

extern __IO uint32_t uwTick;
void delay(uint32_t us){
    SECURE_new_log_entry();
    for(int i=0; i<us; i++);
}

uint8_t maxinputpointer = 2;
char input[2] = "+\n";

char getserialinput(uint8_t inputserialpointer)
{
    SECURE_new_log_entry();
    if (inputserialpointer < maxinputpointer)
    {
        return input[inputserialpointer];
    }
    return 0;
}


// Bolus size
uint16_t mLBolus =  5;
void run_syringe()
{
    //SECURE_new_log_entry();
    /* -- Global variables -- */
    // Input related variables
    volatile uint8_t inputserialpointer = -1;
    uint16_t inputStrLen = 0;
    char inputStr[10]; //input string storage

    // Steps per ml
    int ustepsPerML = (MICROSTEPS_PER_STEP * STEPS_PER_REVOLUTION * SYRINGE_BARREL_LENGTH_MM) / (SYRINGE_VOLUME_ML * THREADED_ROD_PITCH);

    //int ustepsPerML = 10;
    int inner = 0;
    int outer = 0;
    steps = 0;

    while(outer < 1)
    {
       char c = getserialinput(inputserialpointer);
       inputserialpointer++;
       // hex to char reader
       while (inner < 10)
       {
   
           if(c == '\n') // Custom EOF
           {
       
               break;
           }
   
           if(c == 0)
           {
       
               outer = 10;
               break;
           }
   
           inputStr[inputStrLen++] = c;
           c = getserialinput(inputserialpointer);
           inputserialpointer++;
   
           inner += 1;
       }
       inputStr[inputStrLen++] = '\0';
       steps = mLBolus * ustepsPerML;
       // SECURE_record_output_data(mLBolus);
       // SECURE_record_output_data(ustepsPerML);
       // SECURE_record_output_data(steps);
    
        for(int i=0; i < steps; i++)
        {
            if(inputStr[0] == '+' || inputStr[0] == '-')    
            {   
                // write 0xff to port
                sensor = 0xff;
                delay(SPEED_MICROSECONDS_DELAY);
            }
            // write 0x00 to port
            sensor = 0x00;
            delay(SPEED_MICROSECONDS_DELAY);
        }
        // delay(SPEED_MICROSECONDS_DELAY);
        inputStrLen = 0;
        outer += 1;
    }
}

void application()
{
    //SECURE_new_log_entry();
    // for(int i=0; i<TOTAL_INJECTIONS; i++){
    run_syringe();
    // }
}
#endif

#if APP_SEL == TEMP
int temp;
int humidity;
uint8_t data[5] = {0,0,0,0,0};
uint8_t valid_reading = 0;

extern __IO uint32_t uwTick;
void delay(uint32_t us){
    SECURE_new_log_entry();
    // uint32_t start = uwTick;
    // while(uwTick - start < us);
    for(int i=0; i<us; i++);
}

// uint8_t sim_sensor = 1;
// counter += (sim_sensor) >> 8;
// sim_sensor++;
// sim_sensor = (sim_sensor >> 1);
uint8_t counter = 0;

void read_data(){

    // pull signal high & delay
    GPIOA->BRR = (uint32_t)GPIO_PIN_8;
    delay(250);

    /// pull signal low for 20us
    GPIOA->BSRR = (uint32_t)GPIO_PIN_8;
    delay(20);

    // pull signal high for 40us
    GPIOA->BRR = (uint32_t)GPIO_PIN_8;
    delay(40);

    //read timings
    int j = 0;
    int i;
    for(i=0; i<MAX_READINGS; i++){

        counter += (GPIOA->IDR & GPIO_PIN_8) >> 8;

        // ignore first 3 transitions
        if ((i >= 4) && ( (i & 0x01) == 0x00)) {
    
            // shove each bit into the storage bytes
            data[j >> 3] <<= 1;
            if (counter > 6){
        
                data[j >> 3] |= 1;
            }
    
            j++;
        }

    }

    // SECURE_record_output_data(i);

    // check we read 40 bits and that the checksum matches
    if ((j >= 40) && (data[4] == ((data[0] + data[1] + data[2] + data[3]) & 0xFF)) ) {

        valid_reading = 1;
    } else {

        valid_reading = 0;
    }
}

uint16_t get_temperature(){
    read_data();

    uint16_t t = data[2];
    t |= (data[3] << 8);
    return t;
}

uint16_t get_humidity(){
    read_data();

    uint16_t h = data[0];
    h |= (data[1] << 8);
    return h;
}


void application(){
    // Get sensor readings
    temp = get_temperature();
    // temp = (get_temperature() >> 1);
    // temp += (get_temperature() >> 1);

    // humidity = (get_humidity() >> 1);
    // humidity += (get_humidity() >> 1);

    // uint32_t output = (temp << 32) | humidity;
    // SECURE_record_output_data(output);
}
#endif // TEMP

#if APP_SEL == ULT

#define MAX_DURATION    1000
extern __IO uint32_t uwTick;

void delay(uint32_t us){
    SECURE_new_log_entry();
    // uint32_t start = uwTick;
    // while(uwTick - start < us);
    for(int i=0; i<us; i++);
}

uint32_t pulseIn(void){
    SECURE_new_log_entry();
    uint32_t duration = 0;

    for(int i=0; i < MAX_DURATION; i++){
        duration += (GPIOA->IDR & GPIO_PIN_8) >> 8;
    } 

    return duration;
 }

uint32_t getUltrasonicReading(void){
    //SECURE_new_log_entry();
    // Set as output and Set signal low for 2us
    GPIOA->BSRR = (uint32_t)GPIO_PIN_8;
    
    delay(2);

    // Set signal high for 5 us
    GPIOA->BRR = (uint32_t)GPIO_PIN_8;

    delay(5);

    // Set signal low
    GPIOA->BSRR = (uint32_t)GPIO_PIN_8;

    // Set as input and read for duration
    uint32_t duration = pulseIn();

    return duration;
}

void application(){
    //SECURE_new_log_entry();
    uint32_t ult_vec = 0;
    // for(int i=0; i<MAX_READINGS; i++){
    //     ult_vec += getUltrasonicReading()/MAX_READINGS;
    // }
    
    ult_vec = getUltrasonicReading();

    SECURE_record_output_data(ult_vec);

}
#endif
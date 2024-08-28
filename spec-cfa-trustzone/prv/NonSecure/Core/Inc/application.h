#ifndef __APPLICATION_H
#define __APPLICATION_H


#define BASIC			0
#define SYRINGE			1
#define TEMP			2
#define ULT				3
#define GEIGER			4
#define GPS				5
#define MOUSE			6
#define APP_SEL 		ULT

#include "stdint.h"

#if APP_SEL == BASIC
void func();
#endif

#if APP_SEL == ATTACK

#define ULT_PIN         0x02
#define MAX_DURATION    1000

#define P2OUT		sensor
#define P2IN		sensor
#define P2DIR		sensor
#define TOTAL_READINGS  6
#define cr              '\r'

char waitForPassword();
void read_data(char * entry);
void delay(uint32_t us);
uint32_t pulseIn(void);
uint32_t getUltrasonicReading(void);
#endif

#if APP_SEL == SYRINGE

uint16_t sensor = 0xa5;

// Syringe pump
/* -- Constants -- */
#define SYRINGE_VOLUME_ML 50.0
#define SYRINGE_BARREL_LENGTH_MM 8.0

#define THREADED_ROD_PITCH 1.25
#define STEPS_PER_REVOLUTION 4.0
#define MICROSTEPS_PER_STEP 16.0

#define SPEED_MICROSECONDS_DELAY 100
#define TIME_BETWEEN_INJECTIONS  1000
#define TOTAL_INJECTIONS		 3

#define false  0
#define true   1

#define LED_OUT_PIN 0

void delay(uint32_t);
char getserialinput(uint8_t);
#endif // Syringe

#if APP_SEL == TEMP
uint16_t sensor = 0xa5;

#define TEMP_PIN		0x02
#define MAX_READINGS	83
#define P2OUT		sensor
#define P2IN		sensor

void delay(uint32_t us);
void read_data();
uint16_t get_temperature();
uint16_t get_humidity();

#endif // TMP

#if APP_SEL == ULT
#define ULT_PIN         0x02
#define MAX_DURATION    1000

#define P2OUT		sensor
#define P2IN		sensor
#define P2DIR		sensor

void delay(uint32_t us);
uint32_t pulseIn(void);
uint32_t getUltrasonicReading(void);

#endif//ult

void application();

#endif /* __APPLICATION_H */

/*===========================================================================*/
/* Copyright (C) 2001 Authors                                                */
/*                                                                           */
/* This source file may be used and distributed without restriction provided */
/* that this copyright statement is not removed from the file and that any   */
/* derivative work contains the original copyright notice and the associated */
/* disclaimer.                                                               */
/*                                                                           */
/* This source file is free software; you can redistribute it and/or modify  */
/* it under the terms of the GNU Lesser General Public License as published  */
/* by the Free Software Foundation; either version 2.1 of the License, or    */
/* (at your option) any later version.                                       */
/*                                                                           */
/* This source is distributed in the hope that it will be useful, but WITHOUT*/
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     */
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public       */
/* License for more details.                                                 */
/*                                                                           */
/* You should have received a copy of the GNU Lesser General Public License  */
/* along with this source; if not, write to the Free Software Foundation,    */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA        */
/*                                                                           */
/*===========================================================================*/
/*                          OMSP_SYSTEM HEADER FILE                          */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 19 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:47:15 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/

#include <in430.h>

//=============================================================================
// STATUS REGISTER BITS
//=============================================================================

// Flags
#define C             (0x0001)
#define Z             (0x0002)
#define N             (0x0004)
#define V             (0x0100)
#define GIE           (0x0008)
#define CPUOFF        (0x0010)
#define OSCOFF        (0x0020)
#define SCG0          (0x0040)
#define SCG1          (0x0080)

// Low Power Modes coded with Bits 4-7 in SR
#define LPM0_bits     (CPUOFF)
#define LPM1_bits     (SCG0+CPUOFF)
#define LPM2_bits     (SCG1+CPUOFF)
#define LPM3_bits     (SCG1+SCG0+CPUOFF)
#define LPM4_bits     (SCG1+SCG0+OSCOFF+CPUOFF)

#define LPM0          _BIS_SR(LPM0_bits)       // Enter Low Power Mode 0
#define LPM0_EXIT     _BIC_SR_IRQ(LPM0_bits)   // Exit  Low Power Mode 0
#define LPM1          _BIS_SR(LPM1_bits)       // Enter Low Power Mode 1
#define LPM1_EXIT     _BIC_SR_IRQ(LPM1_bits)   // Exit  Low Power Mode 1
#define LPM2          _BIS_SR(LPM2_bits)       // Enter Low Power Mode 2
#define LPM2_EXIT     _BIC_SR_IRQ(LPM2_bits)   // Exit  Low Power Mode 2
#define LPM3          _BIS_SR(LPM3_bits)       // Enter Low Power Mode 3
#define LPM3_EXIT     _BIC_SR_IRQ(LPM3_bits)   // Exit  Low Power Mode 3
#define LPM4          _BIS_SR(LPM4_bits)       // Enter Low Power Mode 4
#define LPM4_EXIT     _BIC_SR_IRQ(LPM4_bits)   // Exit  Low Power Mode 4


//=============================================================================
// PERIPHERALS REGISTER DEFINITIONS
//=============================================================================

//----------------------------------------------------------
// SPECIAL FUNCTION REGISTERS
//----------------------------------------------------------
#define  IE1_set_wdtie()   __asm__ __volatile__ ("bis.b #0x01, &0x0000")
//#define  IE1         (*(volatile unsigned char *) 0x0000)
#define  IFG1        (*(volatile unsigned char *) 0x0002)

#define  CPU_ID_LO   (*(volatile unsigned char *) 0x0004)
#define  CPU_ID_HI   (*(volatile unsigned char *) 0x0006)


//----------------------------------------------------------
// GPIOs
//----------------------------------------------------------
#define  P1IN        (*(volatile unsigned char *) 0x0020)
#define  P1OUT       (*(volatile unsigned char *) 0x0021)
#define  P1DIR       (*(volatile unsigned char *) 0x0022)
#define  P1IFG       (*(volatile unsigned char *) 0x0023)
#define  P1IES       (*(volatile unsigned char *) 0x0024)
#define  P1IE        (*(volatile unsigned char *) 0x0025)
#define  P1SEL       (*(volatile unsigned char *) 0x0026)

#define  P2IN        (*(volatile unsigned char *) 0x0028)
#define  P2OUT       (*(volatile unsigned char *) 0x0029)
#define  P2DIR       (*(volatile unsigned char *) 0x002A)
#define  P2IFG       (*(volatile unsigned char *) 0x002B)
#define  P2IES       (*(volatile unsigned char *) 0x002C)
#define  P2IE        (*(volatile unsigned char *) 0x002D)
#define  P2SEL       (*(volatile unsigned char *) 0x002E)

#define  P3IN        (*(volatile unsigned char *) 0x0018)
#define  P3OUT       (*(volatile unsigned char *) 0x0019)
#define  P3DIR       (*(volatile unsigned char *) 0x001A)
#define  P3SEL       (*(volatile unsigned char *) 0x001B)

#define  P4IN        (*(volatile unsigned char *) 0x001C)
#define  P4OUT       (*(volatile unsigned char *) 0x001D)
#define  P4DIR       (*(volatile unsigned char *) 0x001E)
#define  P4SEL       (*(volatile unsigned char *) 0x001F)

#define  P5IN        (*(volatile unsigned char *) 0x0030)
#define  P5OUT       (*(volatile unsigned char *) 0x0031)
#define  P5DIR       (*(volatile unsigned char *) 0x0032)
#define  P5SEL       (*(volatile unsigned char *) 0x0033)

#define  P6IN        (*(volatile unsigned char *) 0x0034)
#define  P6OUT       (*(volatile unsigned char *) 0x0035)
#define  P6DIR       (*(volatile unsigned char *) 0x0036)
#define  P6SEL       (*(volatile unsigned char *) 0x0037)


//----------------------------------------------------------
// BASIC CLOCK MODULE
//----------------------------------------------------------
#define  DCOCTL      (*(volatile unsigned char *) 0x0056)
#define  BCSCTL1     (*(volatile unsigned char *) 0x0057)
#define  BCSCTL2     (*(volatile unsigned char *) 0x0058)


//----------------------------------------------------------
// WATCHDOG TIMER
//----------------------------------------------------------

// Addresses
#define  WDTCTL      (*(volatile unsigned int  *) 0x0120)

// Bit masks
#define  WDTIS0      (0x0001)
#define  WDTIS1      (0x0002)
#define  WDTSSEL     (0x0004)
#define  WDTCNTCL    (0x0008)
#define  WDTTMSEL    (0x0010)
#define  WDTNMI      (0x0020)
#define  WDTNMIES    (0x0040)
#define  WDTHOLD     (0x0080)
#define  WDTPW       (0x5A00)


//----------------------------------------------------------
// HARDWARE MULTIPLIER
//----------------------------------------------------------
#define  OP1_MPY     (*(volatile unsigned int  *) 0x0130)
#define  OP1_MPYS    (*(volatile unsigned int  *) 0x0132)
#define  OP1_MAC     (*(volatile unsigned int  *) 0x0134)
#define  OP1_MACS    (*(volatile unsigned int  *) 0x0136)
#define  OP2         (*(volatile unsigned int  *) 0x0138)

#define  RESLO       (*(volatile unsigned int  *) 0x013A)
#define  RESHI       (*(volatile unsigned int  *) 0x013C)
#define  SUMEXT      (*(volatile unsigned int  *) 0x013E)


//----------------------------------------------------------
// TIMER A
//----------------------------------------------------------
#define  TACTL       (*(volatile unsigned int  *) 0x0160)
#define  TAR         (*(volatile unsigned int  *) 0x0170)
#define  TACCTL0     (*(volatile unsigned int  *) 0x0162)
#define  TACCR0      (*(volatile unsigned int  *) 0x0172)
#define  TACCTL1     (*(volatile unsigned int  *) 0x0164)
#define  TACCR1      (*(volatile unsigned int  *) 0x0174)
#define  TACCTL2     (*(volatile unsigned int  *) 0x0166)
#define  TACCR2      (*(volatile unsigned int  *) 0x0176)
#define  TAIV        (*(volatile unsigned int  *) 0x012E)

// Alternate register names
#define CCTL0        TACCTL0
#define CCTL1        TACCTL1
#define CCR0         TACCR0
#define CCR1         TACCR1

// Bit-masks
#define TASSEL1             (0x0200)  /* Timer A clock source select 1 */
#define TASSEL0             (0x0100)  /* Timer A clock source select 0 */
#define ID1                 (0x0080)  /* Timer A clock input divider 1 */
#define ID0                 (0x0040)  /* Timer A clock input divider 0 */
#define MC1                 (0x0020)  /* Timer A mode control 1 */
#define MC0                 (0x0010)  /* Timer A mode control 0 */
#define TACLR               (0x0004)  /* Timer A counter clear */
#define TAIE                (0x0002)  /* Timer A counter interrupt enable */
#define TAIFG               (0x0001)  /* Timer A counter interrupt flag */

#define MC_0                (0x0000)  /* Timer A mode control: 0 - Stop */
#define MC_1                (0x0010)  /* Timer A mode control: 1 - Up to CCR0 */
#define MC_2                (0x0020)  /* Timer A mode control: 2 - Continous up */
#define MC_3                (0x0030)  /* Timer A mode control: 3 - Up/Down */
#define ID_0                (0x0000)  /* Timer A input divider: 0 - /1 */
#define ID_1                (0x0040)  /* Timer A input divider: 1 - /2 */
#define ID_2                (0x0080)  /* Timer A input divider: 2 - /4 */
#define ID_3                (0x00C0)  /* Timer A input divider: 3 - /8 */
#define TASSEL_0            (0x0000)  /* Timer A clock source select: 0 - TACLK */
#define TASSEL_1            (0x0100)  /* Timer A clock source select: 1 - ACLK  */
#define TASSEL_2            (0x0200)  /* Timer A clock source select: 2 - SMCLK */
#define TASSEL_3            (0x0300)  /* Timer A clock source select: 3 - INCLK */

#define CM1                 (0x8000)  /* Capture mode 1 */
#define CM0                 (0x4000)  /* Capture mode 0 */
#define CCIS1               (0x2000)  /* Capture input select 1 */
#define CCIS0               (0x1000)  /* Capture input select 0 */
#define SCS                 (0x0800)  /* Capture sychronize */
#define SCCI                (0x0400)  /* Latched capture signal (read) */
#define CAP                 (0x0100)  /* Capture mode: 1 /Compare mode : 0 */
#define OUTMOD2             (0x0080)  /* Output mode 2 */
#define OUTMOD1             (0x0040)  /* Output mode 1 */
#define OUTMOD0             (0x0020)  /* Output mode 0 */
#define CCIE                (0x0010)  /* Capture/compare interrupt enable */
#define CCI                 (0x0008)  /* Capture input signal (read) */
#define OUT                 (0x0004)  /* PWM Output signal if output mode 0 */
#define COV                 (0x0002)  /* Capture/compare overflow flag */
#define CCIFG               (0x0001)  /* Capture/compare interrupt flag */


//=============================================================================
// INTERRUPT VECTORS
//=============================================================================
#define interrupt(x) void __attribute__((interrupt (x)))
#define wakeup  __attribute__((wakeup))
#define eint()  __eint()
#define dint()  __dint()

// Vector definition for RedHat/TI toolchain
#ifdef PFX_MSP430_ELF
   #define RESET_VECTOR        ("reset")   // Vector 15  (0xFFFE) - Reset              -  [Highest Priority]
   #define NMI_VECTOR          (15)        // Vector 14  (0xFFFC) - Non-maskable       -                   -
   #define FLUSH_VECTOR        (14)        // Vector 13  (0xFFFA) -           -
   #define TIMERA0_VECTOR      (14)        // Vector 12  (0xFFF8) - New Timer A         
   #define UNUSED_11_VECTOR    (12)        // Vector 11  (0xFFF6) -                    -
   #define WDT_VECTOR          (11)        // Vector 10  (0xFFF4) - Watchdog Timer     -
   #define UNUSED_09_VECTOR    (10)        // Vector  9  (0xFFF2) - Unused, Former Timer A CC0        -
   #define TIMERA1_VECTOR      (9)         // Vector  8  (0xFFF0) - Timer A CC1-2, TA  -
   #define UNUSED_07_VECTOR    (8)         // Vector  7  (0xFFEE) -                    -
   #define UNUSED_06_VECTOR    (7)         // Vector  6  (0xFFEC) -                    -
   #define UNUSED_05_VECTOR    (6)         // Vector  5  (0xFFEA) -                    -
   #define UNUSED_04_VECTOR    (5)         // Vector  4  (0xFFE8) -                    -
   #define UNUSED_03_VECTOR    (4)         // Vector  3  (0xFFE6) -                    -
   #define PORT1_VECTOR        (3)         // Vector  2  (0xFFE4) - Port 1             -
   #define UNUSED_01_VECTOR    (2)         // Vector  1  (0xFFE2) -                    -
   #define UNUSED_00_VECTOR    (1)         // Vector  0  (0xFFE0) -                    -  [Lowest Priority]

// Vector definition for MSPGCC toolchain
#else
   #define RESET_VECTOR        (0x001E)    // Vector 15  (0xFFFE) - Reset              -  [Highest Priority]
   #define NMI_VECTOR          (0x001C)    // Vector 14  (0xFFFC) - Non-maskable       -
   #define FLUSH_VECTOR        (0x001A)    // Vector 12  (0xFFF8) - New Timer A0        
   #define TIMERA0_VECTOR      (0x001A)    // Vector 13  (0xFFFA) - Flush                   -           -
   #define UNUSED_11_VECTOR    (0x0016)    // Vector 11  (0xFFF6) -                    -
   #define WDT_VECTOR          (0x0014)    // Vector 10  (0xFFF4) - Watchdog Timer     -
   #define UNUSED_09_VECTOR    (0x0012)    // Vector  9  (0xFFF2) - Unused, Former Timer A CC0        -
   #define TIMERA1_VECTOR      (0x0010)    // Vector  8  (0xFFF0) - Timer A CC1-2, TA  -
   #define UNUSED_07_VECTOR    (0x000E)    // Vector  7  (0xFFEE) -                    -
   #define UNUSED_06_VECTOR    (0x000C)    // Vector  6  (0xFFEC) -                    -
   #define UNUSED_05_VECTOR    (0x000A)    // Vector  5  (0xFFEA) -                    -
   #define UNUSED_04_VECTOR    (0x0008)    // Vector  4  (0xFFE8) -                    -
   #define UNUSED_03_VECTOR    (0x0006)    // Vector  3  (0xFFE6) -                    -
   #define PORT1_VECTOR        (0x0004)    // Vector  2  (0xFFE4) - Port 1             -
   #define UNUSED_01_VECTOR    (0x0002)    // Vector  1  (0xFFE2) -                    -
   #define UNUSED_00_VECTOR    (0x0000)    // Vector  0  (0xFFE0) -                    -  [Lowest Priority]
#endif

//=============================================================================
// SPEC-CFA Parameters
//=============================================================================

// Metadata Addresses
#define SPECCFA_METADATA_BASE_ADDR      0x0400
//#define SPECCFA_TOTAL_BLOCKS_ADDR       SPECCFA_METADATA_BASE_ADDR   // 0x0400
//#define SPECCFA_BLOCK_MIN_ADDR          SPECCFA_TOTAL_BLOCKS_ADDR+2  // 0x0402
//#define SPECCFA_BLOCK_MAX_ADDR          SPECCFA_BLOCK_MIN_ADDR+2     // 0x0404
//#define SPECCFA_METADATA_SIZE           6

// For validating spec-cfa correctness
#define GEIGER             0
#define TEST_APP       GEIGER

// Block 1 Data 
#define BLOCK1_ADDR      SPECCFA_METADATA_BASE_ADDR// + SPECCFA_METADATA_SIZE
#define BLOCK1_ID        1
#define BLOCK1_LEN       1
#define BLOCK1_SRC1      0xe08a
#define BLOCK1_DEST1     0xe07e
// #define BLOCK1_SRC2      0xe08a
// #define BLOCK1_DEST2     0xe07e
// #define BLOCK1_SRC3      0xe08a
// #define BLOCK1_DEST3     0xe07e
// #define BLOCK1_SRC4      0xe08a
// #define BLOCK1_DEST4     0xe07e
// #define BLOCK1_SRC5      0xe08a
// #define BLOCK1_DEST5     0xe07e
// #define BLOCK1_SRC6      0xe08a
// #define BLOCK1_DEST6     0xe07e
// #define BLOCK1_SRC7      0xe08a
// #define BLOCK1_DEST7     0xe07e
// #define BLOCK1_SRC8      0xe08a
// #define BLOCK1_DEST8     0xe07e
// #define BLOCK1_SRC9      0xe08a
// #define BLOCK1_DEST9     0xe07e
// #define BLOCK1_SRC10     0xe08a
// #define BLOCK1_DEST10    0xe07e
// #define BLOCK1_SRC11     0xe08a
// #define BLOCK1_DEST11    0xe07e
// #define BLOCK1_SRC12     0xe08a
// #define BLOCK1_DEST12    0xe07e
// #define BLOCK1_SRC13     0xe08a
// #define BLOCK1_DEST13    0xe07e
// #define BLOCK1_SRC14     0xe08a
// #define BLOCK1_DEST14    0xe07e
// #define BLOCK1_SRC15     0xe08a
// #define BLOCK1_DEST15    0xe07e
// #define BLOCK1_SRC16     0xe08a
// #define BLOCK1_DEST16    0xe07e
// #define BLOCK1_SRC17     0xe08a
// #define BLOCK1_DEST17    0xe07e
// #define BLOCK1_SRC18     0xe08a
// #define BLOCK1_DEST18    0xe07e
// #define BLOCK1_SRC19     0xe08a
// #define BLOCK1_DEST19    0xe07e
// #define BLOCK1_SRC20     0xe08a
// #define BLOCK1_DEST20    0xe07e
/**/

// Block 2 Data

#define BLOCK2_ADDR     BLOCK1_ADDR + 2 + BLOCK1_LEN*4 // 4 bytes per transition
#define BLOCK2_ID       2
#define BLOCK2_LEN      7
#define BLOCK2_SRC1     0xe180
#define BLOCK2_DEST1    0xe0f6
#define BLOCK2_SRC2     0xe106
#define BLOCK2_DEST2    0xe108
#define BLOCK2_SRC3     0xe110
#define BLOCK2_DEST3    0xe176 
#define BLOCK2_SRC4     0xe180
#define BLOCK2_DEST4    0xe0f6
#define BLOCK2_SRC5     0xe106
#define BLOCK2_DEST5    0xe108
#define BLOCK2_SRC6     0xe110
#define BLOCK2_DEST6    0xe112 
#define BLOCK2_SRC7     0xe146
#define BLOCK2_DEST7    0xe148  
/*#define BLOCK2_SRC5     0xe27a
#define BLOCK2_DEST5    0xe27c 
#define BLOCK2_SRC6     0xe284
#define BLOCK2_DEST6    0xe168  
#define BLOCK2_SRC7     0xe18c
#define BLOCK2_DEST7    0xe196  
#define BLOCK2_SRC8     0xe19a
#define BLOCK2_DEST8    0xe288 
#define BLOCK2_SRC9     0xe28a 
#define BLOCK2_DEST9    0xe290 
#define BLOCK2_SRC10     0xe294
#define BLOCK2_DEST10    0xe13c  
#define BLOCK2_SRC11     0xe166
#define BLOCK2_DEST11    0xe298 
#define BLOCK2_SRC12     0xe298 
#define BLOCK2_DEST12    0xe2d2 
#define BLOCK2_SRC13     0xe2d2 
#define BLOCK2_DEST13    0xe1ea 
#define BLOCK2_SRC14     0xe1f4
#define BLOCK2_DEST14    0xe168 
#define BLOCK2_SRC15     0xe18c 
#define BLOCK2_DEST15    0xe18e 
#define BLOCK2_SRC16     0xe190
#define BLOCK2_DEST16    0xe192  
#define BLOCK2_SRC17     0xe19a
#define BLOCK2_DEST17    0xe1f8 
#define BLOCK2_SRC18     0xe1fa
#define BLOCK2_DEST18    0xe2d6 
#define BLOCK2_SRC19     0xe2e2
#define BLOCK2_DEST19    0xe07c  
#define BLOCK2_SRC20     0xe07e
#define BLOCK2_DEST20    0xe080  
#define BLOCK2_SRC21     0xe082 
#define BLOCK2_DEST21    0xe0b4 
/**/


// Block 3 Data

#define BLOCK3_ADDR     BLOCK2_ADDR + 2 + BLOCK2_LEN*4 // 4 bytes per transition
#define BLOCK3_ID       3
#define BLOCK3_LEN      2
#define BLOCK3_SRC1     0xe106
#define BLOCK3_DEST1    0xe176
#define BLOCK3_SRC2     0xe180
#define BLOCK3_DEST2    0xe0f6
// #define BLOCK3_SRC3     0xe106
// #define BLOCK3_DEST3    0xe176
// #define BLOCK3_SRC4     0xe180
// #define BLOCK3_DEST4    0xe0f6
// #define BLOCK3_SRC5     0xe106
// #define BLOCK3_DEST5    0xe176
// #define BLOCK3_SRC6     0xe180
// #define BLOCK3_DEST6    0xe0f6
// #define BLOCK3_SRC7     0xe106
// #define BLOCK3_DEST7    0xe176
// #define BLOCK3_SRC8     0xe180
// #define BLOCK3_DEST8    0xe0f6
/*#define BLOCK3_SRC3     0xe08c
#define BLOCK3_DEST3    0xe124
#define BLOCK3_SRC4     0xe148
#define BLOCK3_DEST4    0xe08e
#define BLOCK3_SRC5     0xe0a4
#define BLOCK3_DEST5    0xe0c4
/*#define BLOCK3_SRC6     0xe202
#define BLOCK3_DEST6    0xe1b6
#define BLOCK3_SRC7     0xe1e8
#define BLOCK3_DEST7    0xe206
#define BLOCK3_SRC8     0xe208
#define BLOCK3_DEST8    0xe254
/**/

// Block 4 Data

#define BLOCK4_ADDR     BLOCK3_ADDR + 2 + BLOCK3_LEN*4 // 4 bytes per transition
#define BLOCK4_ID       4
#define BLOCK4_LEN      7
#define BLOCK4_SRC1     0xe180
#define BLOCK4_DEST1    0xe182
#define BLOCK4_SRC2     0xe188
#define BLOCK4_DEST2    0xe18a 
#define BLOCK4_SRC3     0xe1b4
#define BLOCK4_DEST3    0xe1bc
#define BLOCK4_SRC4     0xe1c6
#define BLOCK4_DEST4    0xe1d4 
#define BLOCK4_SRC5     0xe1f6
#define BLOCK4_DEST5    0xe05e
#define BLOCK4_SRC6     0xe062
#define BLOCK4_DEST6    0xe22a
#define BLOCK4_SRC7     0xe22a
#define BLOCK4_DEST7    0xe22e
/*#define BLOCK4_SRC8     0xe0f8
#define BLOCK4_DEST8    0xe1b2
#define BLOCK4_SRC9     0xe1b4
#define BLOCK4_DEST9    0xe2d2
#define BLOCK4_SRC10     0xe2d2
#define BLOCK4_DEST10    0xe1ea
#define BLOCK4_SRC11     0xe1f4
#define BLOCK4_DEST11    0xe168 
#define BLOCK4_SRC12     0xe18c
#define BLOCK4_DEST12    0xe196
#define BLOCK4_SRC13     0xe19a
#define BLOCK4_DEST13    0xe1f8 
#define BLOCK4_SRC14     0xe1fa
#define BLOCK4_DEST14    0xe2d6
#define BLOCK4_SRC15     0xe2e2
#define BLOCK4_DEST15    0xe07c
#define BLOCK4_SRC16     0xe07e
#define BLOCK4_DEST16    0xe084
#define BLOCK4_SRC17     0xe084
#define BLOCK4_DEST17    0xe2e4
#define BLOCK4_SRC18     0xe2ee
#define BLOCK4_DEST18    0xe168
#define BLOCK4_SRC19     0xe18c
#define BLOCK4_DEST19    0xe18e
#define BLOCK4_SRC20     0xe190
#define BLOCK4_DEST20    0xe192 
#define BLOCK4_SRC21     0xe19a
#define BLOCK4_DEST21    0xe2f2 
#define BLOCK4_SRC22     0xe2f6
#define BLOCK4_DEST22    0xe088 
#define BLOCK4_SRC23     0xe08a
#define BLOCK4_DEST23    0xe08c
/**/

// Block 5 Data

#define BLOCK5_ADDR     BLOCK4_ADDR + 2 + BLOCK4_LEN*4 // 4 bytes per transition
#define BLOCK5_ID       5
#define BLOCK5_LEN      3
#define BLOCK5_SRC1     0xe106
#define BLOCK5_DEST1    0xe108
#define BLOCK5_SRC2     0xe110
#define BLOCK5_DEST2    0xe112
#define BLOCK5_SRC3     0xe146
#define BLOCK5_DEST3    0xe172
/*#define BLOCK5_SRC4     0xe078
#define BLOCK5_DEST4    0xe07e
/*#define BLOCK5_SRC5     0xe284
#define BLOCK5_DEST5    0xe168
#define BLOCK5_SRC6     0xe18c 
#define BLOCK5_DEST6    0xe18e 
#define BLOCK5_SRC7     0xe190 
#define BLOCK5_DEST7    0xe192 
#define BLOCK5_SRC8     0xe19a
#define BLOCK5_DEST8    0xe288
#define BLOCK5_SRC9     0xe28a
#define BLOCK5_DEST9    0xe290
#define BLOCK5_SRC10    0xe294
#define BLOCK5_DEST10    0xe13c
#define BLOCK5_SRC11     0xe166 
#define BLOCK5_DEST11    0xe298
#define BLOCK5_SRC12     0xe298 
#define BLOCK5_DEST12    0xe2d2 
#define BLOCK5_SRC13     0xe2d2
#define BLOCK5_DEST13    0xe1ea
#define BLOCK5_SRC14     0xe1f4
#define BLOCK5_DEST14    0xe168
#define BLOCK5_SRC15     0xe18c
#define BLOCK5_DEST15    0xe18e
#define BLOCK5_SRC16     0xe190 
#define BLOCK5_DEST16    0xe192 
#define BLOCK5_SRC17     0xe19a
#define BLOCK5_DEST17    0xe1f8 
#define BLOCK5_SRC18     0xe1fa
#define BLOCK5_DEST18    0xe2d6
#define BLOCK5_SRC19     0xe2e2
#define BLOCK5_DEST19    0xe07c
#define BLOCK5_SRC20     0xe07e
#define BLOCK5_DEST20    0xe080
#define BLOCK5_SRC21     0xe082
#define BLOCK5_DEST21    0xe0b4 
/**/

// Block 6 Data

#define BLOCK6_ADDR     BLOCK5_ADDR + 2 + BLOCK5_LEN*4 // 4 bytes per transition
#define BLOCK6_ID       6
#define BLOCK6_LEN      4
#define BLOCK6_SRC1     0xe08a
#define BLOCK6_DEST1    0xe08c
#define BLOCK6_SRC2     0xe090
#define BLOCK6_DEST2    0xe0f0
#define BLOCK6_SRC3     0xe0f4
#define BLOCK6_DEST3    0xe17a
#define BLOCK6_SRC4     0xe180
#define BLOCK6_DEST4    0xe0f6
/*#define BLOCK6_SRC5     0xe166
#define BLOCK6_DEST5    0xe1aa
#define BLOCK6_SRC6     0xe1ae
#define BLOCK6_DEST6    0xe0ce
#define BLOCK6_SRC7     0xe0f8
#define BLOCK6_DEST7    0xe1b2
#define BLOCK6_SRC8     0xe1b4
#define BLOCK6_DEST8    0xe2d2
#define BLOCK6_SRC9     0xe2d2
#define BLOCK6_DEST9    0xe1ea
#define BLOCK6_SRC10     0xe1f4
#define BLOCK6_DEST10    0xe168
#define BLOCK6_SRC11     0xe18c
#define BLOCK6_DEST11    0xe196 
#define BLOCK6_SRC12     0xe19a
#define BLOCK6_DEST12    0xe1f8
#define BLOCK6_SRC13     0xe1fa
#define BLOCK6_DEST13    0xe2d6
#define BLOCK6_SRC14     0xe2e2
#define BLOCK6_DEST14    0xe07c
#define BLOCK6_SRC15     0xe07e
#define BLOCK6_DEST15    0xe084
#define BLOCK6_SRC16     0xe084
#define BLOCK6_DEST16    0xe2e4
#define BLOCK6_SRC17     0xe2ee
#define BLOCK6_DEST17    0xe168
/**/

// Block 7 Data

#define BLOCK7_ADDR     BLOCK6_ADDR + 2 + BLOCK6_LEN*4 // 4 bytes per transition
#define BLOCK7_ID       7
#define BLOCK7_LEN      4
#define BLOCK7_SRC1     0xe08a
#define BLOCK7_DEST1    0xe08c
#define BLOCK7_SRC2     0xe090
#define BLOCK7_DEST2    0xe0d6
#define BLOCK7_SRC3     0xe0ec
#define BLOCK7_DEST3    0xe06c
#define BLOCK7_SRC4     0xe07c
#define BLOCK7_DEST4    0xe082
/*#define BLOCK7_SRC5     0xe27a 
#define BLOCK7_DEST5    0xe27c
#define BLOCK7_SRC6     0xe284
#define BLOCK7_DEST6    0xe168
#define BLOCK7_SRC7     0xe18c
#define BLOCK7_DEST7    0xe18e
#define BLOCK7_SRC8     0xe190
#define BLOCK7_DEST8    0xe192
/*#define BLOCK7_SRC9     0xf446
#define BLOCK7_DEST9    0xf438 
#define BLOCK7_SRC10     0xf446
#define BLOCK7_DEST10    0xf438 
#define BLOCK7_SRC11     0xf446
#define BLOCK7_DEST11    0xf438 
#define BLOCK7_SRC12     0xf446
#define BLOCK7_DEST12    0xf438 
#define BLOCK7_SRC13     0xf446
#define BLOCK7_DEST13    0xf438 
#define BLOCK7_SRC14     0xf446
#define BLOCK7_DEST14    0xf438 
#define BLOCK7_SRC15     0xf446
#define BLOCK7_DEST15    0xf438 
#define BLOCK7_SRC16     0xf446
#define BLOCK7_DEST16    0xf438
#define BLOCK7_SRC17     0xf446
#define BLOCK7_DEST17    0xf438 
#define BLOCK7_SRC18     0xf446
#define BLOCK7_DEST18    0xf438 
#define BLOCK7_SRC19     0xf446
#define BLOCK7_DEST19    0xf438 
/**/

// Block 8 Data

#define BLOCK8_ADDR     BLOCK7_ADDR + 2 + BLOCK7_LEN*4 // 4 bytes per transition
#define BLOCK8_ID       8
#define BLOCK8_LEN      4
#define BLOCK8_SRC1     0xe08a
#define BLOCK8_DEST1    0xe08c
#define BLOCK8_SRC2     0xe090
#define BLOCK8_DEST2    0xe0bc
#define BLOCK8_SRC3     0xe0d2
#define BLOCK8_DEST3    0xe06c
#define BLOCK8_SRC4     0xe07c
#define BLOCK8_DEST4    0xe082
/*#define BLOCK8_SRC5     0xe284
#define BLOCK8_DEST5    0xe168
#define BLOCK8_SRC6     0xe18c
#define BLOCK8_DEST6    0xe196
/*#define BLOCK8_SRC7     0xe18c
#define BLOCK8_DEST7    0xe196
#define BLOCK8_SRC8     0xe19a
#define BLOCK8_DEST8    0xe288
#define BLOCK8_SRC9     0xe28a
#define BLOCK8_DEST9    0xe290
#define BLOCK8_SRC10     0xe294
#define BLOCK8_DEST10    0xe13c
#define BLOCK8_SRC11     0xe166
#define BLOCK8_DEST11    0xe298
#define BLOCK8_SRC12     0xe298
#define BLOCK8_DEST12    0xe2d2
#define BLOCK8_SRC13     0xe2d2
#define BLOCK8_DEST13    0xe1ea
#define BLOCK8_SRC14     0xe1f4
#define BLOCK8_DEST14    0xe168
#define BLOCK8_SRC15     0xe18c
#define BLOCK8_DEST15    0xe18e
#define BLOCK8_SRC16     0xe190
#define BLOCK8_DEST16    0xe192
#define BLOCK8_SRC17     0xe19a
#define BLOCK8_DEST17    0xe1f8
#define BLOCK8_SRC18     0xe1fa
#define BLOCK8_DEST18    0xe2d6
#define BLOCK8_SRC19     0xe2e2
#define BLOCK8_DEST19    0xe07c
#define BLOCK8_SRC20     0xe07e
#define BLOCK8_DEST20    0xe080
#define BLOCK8_SRC21     0xe082
#define BLOCK8_DEST21    0xe0b4
/**/

// Block 9 Data
/*
#define BLOCK9_ADDR     BLOCK8_ADDR + 2 + BLOCK8_LEN*4 // 4 bytes per transition
#define BLOCK9_ID       9
#define BLOCK9_LEN      4
#define BLOCK9_SRC1     0xe202
#define BLOCK9_DEST1    0xe1b6 
#define BLOCK9_SRC2     0xe1b8 
#define BLOCK9_DEST2    0xe206 
#define BLOCK9_SRC3     0xe208 
#define BLOCK9_DEST3    0xe254 
#define BLOCK9_SRC4     0xe276 
#define BLOCK9_DEST4    0xe280 
/*#define BLOCK9_SRC5     0xe146 
#define BLOCK9_DEST5    0xe0a6 
#define BLOCK9_SRC6     0xe180 
#define BLOCK9_DEST6    0xe0cc 
*/

// Block 10 Data
/*
#define BLOCK10_ADDR     BLOCK9_ADDR + 2 + BLOCK9_LEN*4 // 4 bytes per transition
#define BLOCK10_ID       10
#define BLOCK10_LEN      3
#define BLOCK10_SRC1     0xe190 
#define BLOCK10_DEST1    0xe192 
#define BLOCK10_SRC2     0xe19a 
#define BLOCK10_DEST2    0xe1f8 
#define BLOCK10_SRC3     0xe1fa  
#define BLOCK10_DEST3    0xe2d6 
/*#define BLOCK10_SRC4     0xe108 
#define BLOCK10_DEST4    0xe068 
#define BLOCK10_SRC5     0xe146 
#define BLOCK10_DEST5    0xe148 
*/

// Block 11 Data
/*
#define BLOCK11_ADDR     BLOCK10_ADDR + 2 + BLOCK10_LEN*4 // 4 bytes per transition
#define BLOCK11_ID       11
#define BLOCK11_LEN      3
#define BLOCK11_SRC1     0x284 
#define BLOCK11_DEST1    0xe168 
#define BLOCK11_SRC2     0xe18c 
#define BLOCK11_DEST2    0xe196 
#define BLOCK11_SRC3     0xe19a 
#define BLOCK11_DEST3    0xe288 
#define BLOCK11_SRC4     0xe078 
#define BLOCK11_DEST4    0xe07e 
#define BLOCK11_SRC5     0xe078 
#define BLOCK11_DEST5    0xe07e 
*/

// Block 12 Data
/*
#define BLOCK12_ADDR     BLOCK11_ADDR + 2 + BLOCK11_LEN*4 // 4 bytes per transition
#define BLOCK12_ID       12
#define BLOCK12_LEN      4
#define BLOCK12_SRC1     0xe052 
#define BLOCK12_DEST1    0xe0dc 
#define BLOCK12_SRC2     0xe108 
#define BLOCK12_DEST2    0xe068 
#define BLOCK12_SRC3     0xe078 
#define BLOCK12_DEST3    0xe07e 
#define BLOCK12_SRC4     0xe086 
#define BLOCK12_DEST4    0xe07a 
*/

// Block 13 Data
/*
#define BLOCK13_ADDR     BLOCK12_ADDR + 2 + BLOCK12_LEN*4 // 4 bytes per transition
#define BLOCK13_ID       13
#define BLOCK13_LEN      4 
#define BLOCK13_SRC1     0xe086 
#define BLOCK13_DEST1    0xe07a 
#define BLOCK13_SRC2     0xe086 
#define BLOCK13_DEST2    0xe088 
#define BLOCK13_SRC3     0xe08c 
#define BLOCK13_DEST3    0xe10c 
#define BLOCK13_SRC4     0xe120 
#define BLOCK13_DEST4    0xe068 
*/

// Block 14 Data
/*
#define BLOCK14_ADDR     BLOCK13_ADDR + 2 + BLOCK13_LEN*4 // 4 bytes per transition
#define BLOCK14_ID       14
#define BLOCK14_LEN      4 
#define BLOCK14_SRC1     0xe086 
#define BLOCK14_DEST1    0xe088 
#define BLOCK14_SRC2     0xe08c 
#define BLOCK14_DEST2    0xe10c 
#define BLOCK14_SRC3     0xe120 
#define BLOCK14_DEST3    0xe068 
#define BLOCK14_SRC4     0xe078 
#define BLOCK14_DEST4    0xe07e
*/


// Metadata Values
#define SPECCFA_TOTAL_BLOCKS            7
#define SPECCFA_BLOCK_MIN               BLOCK1_ADDR
#define SPECCFA_BLOCK_MAX               BLOCK8_ADDR + 2 + BLOCK8_LEN*4 // 4 bytes per transition

//=============================================================================

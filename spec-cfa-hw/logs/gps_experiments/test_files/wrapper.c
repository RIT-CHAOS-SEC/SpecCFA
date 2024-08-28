#include <string.h>
#include "hardware.h"

// Watchdog timer
#define WDTCTL_              0x0120    /* Watchdog Timer Control */
#define WDTHOLD             (0x0080)
#define WDTPW               (0x5A00)

// KEY
#define KEY_ADDR 0x6A00
#define KEY_SIZE 32 // in bytes

// METADATA
#define CHAL_BASE       0x180 //180-19f
#define CHAL_SIZE       32 // in bytes
#define METADATA_ADDR   CHAL_BASE+CHAL_SIZE
#define ERMIN_ADDR      METADATA_ADDR //1a0-1
#define ERMAX_ADDR      ERMIN_ADDR+2  //1a2-3
#define CLOGP_ADDR      ERMAX_ADDR+2  //1a4-5
#define METADATA_SIZE   6

// CFLog
#define LOG_BASE        0x1b0 //CHAL_BASE + CHAL_SIZE + METADATA_SIZE+4 //0x1a6
#define LOG_SIZE        256 // in bytes
// #define LOG_SIZE        512 
// #define LOG_SIZE        1024
// #define LOG_SIZE        2048

// Set ER_MIN/MAX based on setting
#define PMEM_MIN  0xE000
#define PMEM_MAX  &acfa_exit

#define ER_MIN  PMEM_MIN
#define ER_MAX  PMEM_MAX

// Timmer settings
#define TIMER_1MS 125 
#define MAX_TIME  0xffff
#define ACFA_TIME MAX_TIME // 50*TIMER_1MS // Time in ms -- note vivado sim is 4x faster

// Communication
#define DELAY     100
#define UART_TIMEOUT   0x167FFE
#define ACK       'a'

// DUMMY DATA TO TEST COMMUNICATION ONLY
#define RESP_ADDR 0xb00
#define KEY_ALT_ADDR 0xb20
#define CHAL_XS 0xb40
#define PRV_AUTH 0xb60
#define VRF_AUTH 0xb80

// Attested Program memory range
#define ATTEST_DATA_ADDR   0xe000
// #define ATTEST_SIZE        0x1fff //8kb
// #define ATTEST_SIZE        0x0fff //4kb
// #define ATTEST_SIZE        0x07ff //2kb
#define ATTEST_SIZE        0x03ff //1kb

// Protocol variables in SData
#define NEW_CHAL_ADDR         0xba4
#define TMP_16_BUFF           0xbc4
#define LOG_BASE_XS   0xca6

// TCB version
#define NOT_SIM   0
#define SIM   1
#define IS_SIM  SIM
//

/**********     Function Definitions      *********/
__attribute__ ((section (".tcb.lib"))) void my_memset(uint8_t* ptr, int len, uint8_t val);
void my_memcpy(uint8_t* dst, uint8_t* src, int size);
int secure_memcmp(const uint8_t* s1, const uint8_t* s2, int size);
void tcb();
void tcb_attest();
void tcb_wait();
void Hacl_HMAC_SHA2_256_hmac_exit();
void tcb_exit();
void recvBuffer(uint8_t * rx_data, uint16_t size);
void sendCFLog(uint16_t size);
void sendBuffer(uint8_t * tx_data, uint16_t size);
void echo_tx_rx(uint8_t * data, uint16_t size);
void echo_rx_tx(uint8_t * data, uint16_t size);
// EXTERNAL FUNCTIONS
extern void acfa_exit();
#if IS_SIM == NOT_SIM
extern void hmac(uint8_t *mac, uint8_t *key, uint32_t keylen, uint8_t *data, uint32_t datalen);
#else
#define hmac my_hmac
void my_hmac(uint8_t *mac, uint8_t *key, uint32_t keylen, uint8_t *data, uint32_t datalen);
#endif

/**********  CORE TCB    *********/
#pragma vector=FLUSH_VECTOR
__interrupt __attribute__ ((section (".tcb.call")))
void tcb_entry(){
    // __asm__ volatile("push    r11" "\n\t");
    // __asm__ volatile("push    r4" "\n\t");
    // __asm__ volatile("mov    r1,    r4" "\n\t");

    
    // Call TCB Body:
    tcb();

    // Release registers
    // __asm__ volatile("pop    r4" "\n\t");
    __asm__ volatile("pop    r12" "\n\t");
    __asm__ volatile("pop    r13" "\n\t");
    __asm__ volatile("pop    r14" "\n\t");
    __asm__ volatile("pop    r15" "\n\t");

    __asm__ volatile("br #__tcb_leave" "\n\t");
}

__attribute__ ((section (".fini9"), naked)) void acfa_exit(){
    __asm__ volatile("br #__stop_progExec__" "\n\t");
}

__attribute__ ((section (".tcb.body"))) void tcb() {

    /********** SETUP ON ENTRY **********/
    // Switch off the WTD
    uint32_t* wdt = (uint32_t*)(WDTCTL_);
    *wdt = WDTPW | WDTHOLD;

    // Configure Timer A0 for timeout
    CCTL0 = CCIE;                            // CCR0 interrupt enabled
    CCR0  = ACFA_TIME;                     // Set based on time
    TACTL = TASSEL_2 + MC_1 + ID_3;          // SMCLK, contmode

    // Pause Timer
    TACTL &= ~MC_1;
    
    //Clear timer
    TAR = 0x00;

    // Init UART
    UART_BAUD = BAUD;                   
    UART_CTL  = UART_EN;

    P3DIR |= 0xff;

    #if IS_SIM == NOT_SIM
    // // /********** TCB ATTEST **********/
    // Save current value of r5 and r6:
    __asm__ volatile("push    r5" "\n\t");
    __asm__ volatile("push    r6" "\n\t");

    // Save return address
    __asm__ volatile("mov    #0x0012,   r6" "\n\t");
    __asm__ volatile("mov    #0x500,   r5" "\n\t");
    __asm__ volatile("mov    r0,        @(r5)" "\n\t");
    __asm__ volatile("add    r6,        @(r5)" "\n\t");

    // Save the original value of the Stack Pointer (R1):
    __asm__ volatile("mov    r1,    r5" "\n\t");

    // Set the stack pointer to the base of the exclusive stack:
    __asm__ volatile("mov    #0x1704,     r1" "\n\t");

    // tcb_attest(); // monitored by VRASED
    
    tcb_attest();

    // Copy retrieve the original stack pointer value:
    __asm__ volatile("mov    r5,    r1" "\n\t");

    // // Restore original r5,r6 values:
    __asm__ volatile("pop   r6" "\n\t");
    __asm__ volatile("pop   r5" "\n\t");
    #endif

    #if IS_SIM == SIM
    tcb_attest();

    *((uint16_t*)(ERMIN_ADDR)) = ER_MIN;
    P1OUT = *((uint8_t*)(ERMIN_ADDR));
    P1OUT = *((uint8_t*)(ERMIN_ADDR+1));
    *((uint16_t*)(ERMAX_ADDR)) = ER_MAX;
    P1OUT = *((uint8_t*)(ERMAX_ADDR));
    P1OUT = *((uint8_t*)(ERMAX_ADDR+1));

    // Set speccfa_metadata
    //*((uint16_t*)(SPECCFA_TOTAL_BLOCKS_ADDR)) = SPECCFA_TOTAL_BLOCKS;
    //*((uint16_t*)(SPECCFA_BLOCK_MIN_ADDR)) = SPECCFA_BLOCK_MIN;
    //*((uint16_t*)(SPECCFA_BLOCK_MAX_ADDR)) = SPECCFA_BLOCK_MAX;
    
    // BLOCK 1
    //uint16_t * block1 = (uint16_t *)(BLOCK1_ADDR);
    *((uint16_t *)(BLOCK1_ADDR)) = (BLOCK1_ID << 8) | BLOCK1_LEN;
    *((uint16_t *)(BLOCK1_ADDR+2)) = BLOCK1_SRC1;
    *((uint16_t *)(BLOCK1_ADDR+4)) = BLOCK1_DEST1;
    *((uint16_t *)(BLOCK1_ADDR+6)) = BLOCK1_SRC2;
    *((uint16_t *)(BLOCK1_ADDR+8)) = BLOCK1_DEST2;
    *((uint16_t *)(BLOCK1_ADDR+10)) = BLOCK1_SRC3;
    *((uint16_t *)(BLOCK1_ADDR+12)) = BLOCK1_DEST3;
    *((uint16_t *)(BLOCK1_ADDR+14)) = BLOCK1_SRC4;
    *((uint16_t *)(BLOCK1_ADDR+16)) = BLOCK1_DEST4;
    /**((uint16_t *)(BLOCK1_ADDR+18)) = BLOCK1_SRC5;
    *((uint16_t *)(BLOCK1_ADDR+20)) = BLOCK1_DEST5;
    *((uint16_t *)(BLOCK1_ADDR+22)) = BLOCK1_SRC6;
    *((uint16_t *)(BLOCK1_ADDR+24)) = BLOCK1_DEST6;
    *((uint16_t *)(BLOCK1_ADDR+26)) = BLOCK1_SRC7;
    *((uint16_t *)(BLOCK1_ADDR+28)) = BLOCK1_DEST7;
    *((uint16_t *)(BLOCK1_ADDR+30)) = BLOCK1_SRC8;
    *((uint16_t *)(BLOCK1_ADDR+32)) = BLOCK1_DEST8;
    *((uint16_t *)(BLOCK1_ADDR+34)) = BLOCK1_SRC9;
    *((uint16_t *)(BLOCK1_ADDR+36)) = BLOCK1_DEST9;
    *((uint16_t *)(BLOCK1_ADDR+38)) = BLOCK1_SRC10;
    *((uint16_t *)(BLOCK1_ADDR+40)) = BLOCK1_DEST10;
    *((uint16_t *)(BLOCK1_ADDR+42)) = BLOCK1_SRC11;
    *((uint16_t *)(BLOCK1_ADDR+44)) = BLOCK1_DEST11;
    *((uint16_t *)(BLOCK1_ADDR+46)) = BLOCK1_SRC12;
    *((uint16_t *)(BLOCK1_ADDR+48)) = BLOCK1_DEST12;
    *((uint16_t *)(BLOCK1_ADDR+50)) = BLOCK1_SRC13;
    *((uint16_t *)(BLOCK1_ADDR+52)) = BLOCK1_DEST13;
    *((uint16_t *)(BLOCK1_ADDR+54)) = BLOCK1_SRC14;
    *((uint16_t *)(BLOCK1_ADDR+56)) = BLOCK1_DEST14;
    *((uint16_t *)(BLOCK1_ADDR+58)) = BLOCK1_SRC15;
    *((uint16_t *)(BLOCK1_ADDR+60)) = BLOCK1_DEST15;
    *((uint16_t *)(BLOCK1_ADDR+62)) = BLOCK1_SRC16;
    *((uint16_t *)(BLOCK1_ADDR+64)) = BLOCK1_DEST16;
    *((uint16_t *)(BLOCK1_ADDR+66)) = BLOCK1_SRC17;
    *((uint16_t *)(BLOCK1_ADDR+68)) = BLOCK1_DEST17;
    *((uint16_t *)(BLOCK1_ADDR+70)) = BLOCK1_SRC18;
    *((uint16_t *)(BLOCK1_ADDR+72)) = BLOCK1_DEST18;
    *((uint16_t *)(BLOCK1_ADDR+74)) = BLOCK1_SRC19;
    *((uint16_t *)(BLOCK1_ADDR+76)) = BLOCK1_DEST19;
    *((uint16_t *)(BLOCK1_ADDR+78)) = BLOCK1_SRC20;
    *((uint16_t *)(BLOCK1_ADDR+80)) = BLOCK1_DEST20;
    */
    

    // // // uint16_t * block2 = (uint16_t *)(BLOCK2_ADDR);
    *((uint16_t *)(BLOCK2_ADDR)) = (BLOCK2_ID << 8) | BLOCK2_LEN;
    *((uint16_t *)(BLOCK2_ADDR+2)) = BLOCK2_SRC1;
    *((uint16_t *)(BLOCK2_ADDR+4)) = BLOCK2_DEST1;
    *((uint16_t *)(BLOCK2_ADDR+6)) = BLOCK2_SRC2;
    *((uint16_t *)(BLOCK2_ADDR+8)) = BLOCK2_DEST2;
    *((uint16_t *)(BLOCK2_ADDR+10)) = BLOCK2_SRC3;
    *((uint16_t *)(BLOCK2_ADDR+12)) = BLOCK2_DEST3;
    *((uint16_t *)(BLOCK2_ADDR+14)) = BLOCK2_SRC4;
    *((uint16_t *)(BLOCK2_ADDR+16)) = BLOCK2_DEST4;
    /*((uint16_t *)(BLOCK2_ADDR+18)) = BLOCK2_SRC5;
    *((uint16_t *)(BLOCK2_ADDR+20)) = BLOCK2_DEST5;
    *((uint16_t *)(BLOCK2_ADDR+22)) = BLOCK2_SRC6;
    *((uint16_t *)(BLOCK2_ADDR+24)) = BLOCK2_DEST6;
    */

    *((uint16_t *)(BLOCK3_ADDR)) = (BLOCK3_ID << 8) | BLOCK3_LEN;
    *((uint16_t *)(BLOCK3_ADDR+2)) = BLOCK3_SRC1;
    *((uint16_t *)(BLOCK3_ADDR+4)) = BLOCK3_DEST1;
    *((uint16_t *)(BLOCK3_ADDR+6)) = BLOCK3_SRC2;
    *((uint16_t *)(BLOCK3_ADDR+8)) = BLOCK3_DEST2;
    *((uint16_t *)(BLOCK3_ADDR+10)) = BLOCK3_SRC3;
    *((uint16_t *)(BLOCK3_ADDR+12)) = BLOCK3_DEST3;
    *((uint16_t *)(BLOCK3_ADDR+14)) = BLOCK3_SRC4;
    *((uint16_t *)(BLOCK3_ADDR+16)) = BLOCK3_DEST4;
    /*((uint16_t *)(BLOCK3_ADDR+18)) = BLOCK3_SRC5;
    *((uint16_t *)(BLOCK3_ADDR+20)) = BLOCK3_DEST5;
    *((uint16_t *)(BLOCK3_ADDR+22)) = BLOCK3_SRC6;
    *((uint16_t *)(BLOCK3_ADDR+24)) = BLOCK3_DEST6;
    */

    *((uint16_t *)(BLOCK4_ADDR)) = (BLOCK4_ID << 8) | BLOCK4_LEN;
    *((uint16_t *)(BLOCK4_ADDR+2)) = BLOCK4_SRC1;
    *((uint16_t *)(BLOCK4_ADDR+4)) = BLOCK4_DEST1;
    *((uint16_t *)(BLOCK4_ADDR+6)) = BLOCK4_SRC2;
    *((uint16_t *)(BLOCK4_ADDR+8)) = BLOCK4_DEST2;
    *((uint16_t *)(BLOCK4_ADDR+10)) = BLOCK4_SRC3;
    *((uint16_t *)(BLOCK4_ADDR+12)) = BLOCK4_DEST3;
    *((uint16_t *)(BLOCK4_ADDR+14)) = BLOCK4_SRC4;
    *((uint16_t *)(BLOCK4_ADDR+16)) = BLOCK4_DEST4;
    *((uint16_t *)(BLOCK4_ADDR+18)) = BLOCK4_SRC5;
    *((uint16_t *)(BLOCK4_ADDR+20)) = BLOCK4_DEST5;
    *((uint16_t *)(BLOCK4_ADDR+22)) = BLOCK4_SRC6;
    *((uint16_t *)(BLOCK4_ADDR+24)) = BLOCK4_DEST6;
    *((uint16_t *)(BLOCK4_ADDR+26)) = BLOCK4_SRC7;
    *((uint16_t *)(BLOCK4_ADDR+28)) = BLOCK4_DEST7;
    *((uint16_t *)(BLOCK4_ADDR+30)) = BLOCK4_SRC8;
    *((uint16_t *)(BLOCK4_ADDR+32)) = BLOCK4_DEST8;
    *((uint16_t *)(BLOCK4_ADDR+34)) = BLOCK4_SRC9;
    *((uint16_t *)(BLOCK4_ADDR+36)) = BLOCK4_DEST9;
    /*((uint16_t *)(BLOCK4_ADDR+38)) = BLOCK4_SRC10;
    *((uint16_t *)(BLOCK4_ADDR+40)) = BLOCK4_DEST10;
    /**/

    *((uint16_t *)(BLOCK5_ADDR)) = (BLOCK5_ID << 8) | BLOCK5_LEN;
    *((uint16_t *)(BLOCK5_ADDR+2)) = BLOCK5_SRC1;
    *((uint16_t *)(BLOCK5_ADDR+4)) = BLOCK5_DEST1;
    *((uint16_t *)(BLOCK5_ADDR+6)) = BLOCK5_SRC2;
    *((uint16_t *)(BLOCK5_ADDR+8)) = BLOCK5_DEST2;
    *((uint16_t *)(BLOCK5_ADDR+10)) = BLOCK5_SRC3;
    *((uint16_t *)(BLOCK5_ADDR+12)) = BLOCK5_DEST3;
    *((uint16_t *)(BLOCK5_ADDR+14)) = BLOCK5_SRC4;
    *((uint16_t *)(BLOCK5_ADDR+16)) = BLOCK5_DEST4;
    /**((uint16_t *)(BLOCK5_ADDR+18)) = BLOCK5_SRC5;
    *((uint16_t *)(BLOCK5_ADDR+20)) = BLOCK5_DEST5;
    *((uint16_t *)(BLOCK5_ADDR+22)) = BLOCK5_SRC6;
    *((uint16_t *)(BLOCK5_ADDR+24)) = BLOCK5_DEST6;
    */


    *((uint16_t *)(BLOCK6_ADDR)) = (BLOCK6_ID << 8) | BLOCK6_LEN;
    *((uint16_t *)(BLOCK6_ADDR+2)) = BLOCK6_SRC1;
    *((uint16_t *)(BLOCK6_ADDR+4)) = BLOCK6_DEST1;
    *((uint16_t *)(BLOCK6_ADDR+6)) = BLOCK6_SRC2;
    *((uint16_t *)(BLOCK6_ADDR+8)) = BLOCK6_DEST2;
    *((uint16_t *)(BLOCK6_ADDR+10)) = BLOCK6_SRC3;
    *((uint16_t *)(BLOCK6_ADDR+12)) = BLOCK6_DEST3;
    *((uint16_t *)(BLOCK6_ADDR+14)) = BLOCK6_SRC4;
    *((uint16_t *)(BLOCK6_ADDR+16)) = BLOCK6_DEST4;
    *((uint16_t *)(BLOCK6_ADDR+18)) = BLOCK6_SRC5;
    *((uint16_t *)(BLOCK6_ADDR+20)) = BLOCK6_DEST5;
    *((uint16_t *)(BLOCK6_ADDR+22)) = BLOCK6_SRC6;
    *((uint16_t *)(BLOCK6_ADDR+24)) = BLOCK6_DEST6;
    *((uint16_t *)(BLOCK6_ADDR+26)) = BLOCK6_SRC7;
    *((uint16_t *)(BLOCK6_ADDR+28)) = BLOCK6_DEST7;
    *((uint16_t *)(BLOCK6_ADDR+30)) = BLOCK6_SRC8;
    *((uint16_t *)(BLOCK6_ADDR+32)) = BLOCK6_DEST8;
    *((uint16_t *)(BLOCK6_ADDR+34)) = BLOCK6_SRC9;
    *((uint16_t *)(BLOCK6_ADDR+36)) = BLOCK6_DEST9;
    *((uint16_t *)(BLOCK6_ADDR+38)) = BLOCK6_SRC10;
    *((uint16_t *)(BLOCK6_ADDR+40)) = BLOCK6_DEST10;
    /**/

    *((uint16_t *)(BLOCK7_ADDR)) = (BLOCK7_ID << 8) | BLOCK7_LEN;
    *((uint16_t *)(BLOCK7_ADDR+2)) = BLOCK7_SRC1;
    *((uint16_t *)(BLOCK7_ADDR+4)) = BLOCK7_DEST1;
    *((uint16_t *)(BLOCK7_ADDR+6)) = BLOCK7_SRC2;
    *((uint16_t *)(BLOCK7_ADDR+8)) = BLOCK7_DEST2;
    *((uint16_t *)(BLOCK7_ADDR+10)) = BLOCK7_SRC3;
    *((uint16_t *)(BLOCK7_ADDR+12)) = BLOCK7_DEST3;
    *((uint16_t *)(BLOCK7_ADDR+14)) = BLOCK7_SRC4;
    *((uint16_t *)(BLOCK7_ADDR+16)) = BLOCK7_DEST4;
    *((uint16_t *)(BLOCK7_ADDR+18)) = BLOCK7_SRC5;
    *((uint16_t *)(BLOCK7_ADDR+20)) = BLOCK7_DEST5;
    *((uint16_t *)(BLOCK7_ADDR+22)) = BLOCK7_SRC6;
    *((uint16_t *)(BLOCK7_ADDR+24)) = BLOCK7_DEST6;
    *((uint16_t *)(BLOCK7_ADDR+26)) = BLOCK7_SRC7;
    *((uint16_t *)(BLOCK7_ADDR+28)) = BLOCK7_DEST7;
    *((uint16_t *)(BLOCK7_ADDR+30)) = BLOCK7_SRC8;
    *((uint16_t *)(BLOCK7_ADDR+32)) = BLOCK7_DEST8;
    *((uint16_t *)(BLOCK7_ADDR+34)) = BLOCK7_SRC9;
    *((uint16_t *)(BLOCK7_ADDR+36)) = BLOCK7_DEST9;
    *((uint16_t *)(BLOCK7_ADDR+38)) = BLOCK7_SRC10;
    *((uint16_t *)(BLOCK7_ADDR+40)) = BLOCK7_DEST10;
    *((uint16_t *)(BLOCK7_ADDR+42)) = BLOCK7_SRC11;
    *((uint16_t *)(BLOCK7_ADDR+44)) = BLOCK7_DEST11;
    *((uint16_t *)(BLOCK7_ADDR+46)) = BLOCK7_SRC12;
    *((uint16_t *)(BLOCK7_ADDR+48)) = BLOCK7_DEST12;
    *((uint16_t *)(BLOCK7_ADDR+50)) = BLOCK7_SRC13;
    *((uint16_t *)(BLOCK7_ADDR+52)) = BLOCK7_DEST13;
    *((uint16_t *)(BLOCK7_ADDR+54)) = BLOCK7_SRC14;
    *((uint16_t *)(BLOCK7_ADDR+56)) = BLOCK7_DEST14;
    *((uint16_t *)(BLOCK7_ADDR+58)) = BLOCK7_SRC15;
    *((uint16_t *)(BLOCK7_ADDR+60)) = BLOCK7_DEST15;
    *((uint16_t *)(BLOCK7_ADDR+62)) = BLOCK7_SRC16;
    *((uint16_t *)(BLOCK7_ADDR+64)) = BLOCK7_DEST16;
    *((uint16_t *)(BLOCK7_ADDR+66)) = BLOCK7_SRC17;
    *((uint16_t *)(BLOCK7_ADDR+68)) = BLOCK7_DEST17;
    *((uint16_t *)(BLOCK7_ADDR+70)) = BLOCK7_SRC18;
    *((uint16_t *)(BLOCK7_ADDR+72)) = BLOCK7_DEST18;
    *((uint16_t *)(BLOCK7_ADDR+74)) = BLOCK7_SRC19;
    *((uint16_t *)(BLOCK7_ADDR+76)) = BLOCK7_DEST19;
    /**/

    
    *((uint16_t *)(BLOCK8_ADDR)) = (BLOCK8_ID << 8) | BLOCK8_LEN;
    *((uint16_t *)(BLOCK8_ADDR+2)) = BLOCK8_SRC1;
    *((uint16_t *)(BLOCK8_ADDR+4)) = BLOCK8_DEST1;
    *((uint16_t *)(BLOCK8_ADDR+6)) = BLOCK8_SRC2;
    *((uint16_t *)(BLOCK8_ADDR+8)) = BLOCK8_DEST2;
    *((uint16_t *)(BLOCK8_ADDR+10)) = BLOCK8_SRC3;
    *((uint16_t *)(BLOCK8_ADDR+12)) = BLOCK8_DEST3;
    *((uint16_t *)(BLOCK8_ADDR+14)) = BLOCK8_SRC4;
    *((uint16_t *)(BLOCK8_ADDR+16)) = BLOCK8_DEST4;
    *((uint16_t *)(BLOCK8_ADDR+18)) = BLOCK8_SRC5;
    *((uint16_t *)(BLOCK8_ADDR+20)) = BLOCK8_DEST5;
    *((uint16_t *)(BLOCK8_ADDR+22)) = BLOCK8_SRC6;
    *((uint16_t *)(BLOCK8_ADDR+24)) = BLOCK8_DEST6;
    *((uint16_t *)(BLOCK8_ADDR+26)) = BLOCK8_SRC7;
    *((uint16_t *)(BLOCK8_ADDR+28)) = BLOCK8_DEST7;
    /**/

/*
    *((uint16_t *)(BLOCK9_ADDR)) = (BLOCK9_ID << 8) | BLOCK9_LEN;
    *((uint16_t *)(BLOCK9_ADDR+2)) = BLOCK9_SRC1;
    *((uint16_t *)(BLOCK9_ADDR+4)) = BLOCK9_DEST1;
    *((uint16_t *)(BLOCK9_ADDR+6)) = BLOCK9_SRC2;
    *((uint16_t *)(BLOCK9_ADDR+8)) = BLOCK9_DEST2;
    *((uint16_t *)(BLOCK9_ADDR+10)) = BLOCK9_SRC3;
    *((uint16_t *)(BLOCK9_ADDR+12)) = BLOCK9_DEST3;
    *((uint16_t *)(BLOCK9_ADDR+14)) = BLOCK9_SRC4;
    *((uint16_t *)(BLOCK9_ADDR+16)) = BLOCK9_DEST4;
    /**((uint16_t *)(BLOCK9_ADDR+18)) = BLOCK9_SRC5;
    *((uint16_t *)(BLOCK9_ADDR+20)) = BLOCK9_DEST5;
    *((uint16_t *)(BLOCK9_ADDR+22)) = BLOCK9_SRC6;
    *((uint16_t *)(BLOCK9_ADDR+24)) = BLOCK9_DEST6;
    */
    
    /*
    *((uint16_t *)(BLOCK10_ADDR)) = (BLOCK10_ID << 8) | BLOCK10_LEN;
    *((uint16_t *)(BLOCK10_ADDR+2)) = BLOCK10_SRC1;
    *((uint16_t *)(BLOCK10_ADDR+4)) = BLOCK10_DEST1;
    *((uint16_t *)(BLOCK10_ADDR+6)) = BLOCK10_SRC2;
    *((uint16_t *)(BLOCK10_ADDR+8)) = BLOCK10_DEST2;
    *((uint16_t *)(BLOCK10_ADDR+10)) = BLOCK10_SRC3;
    *((uint16_t *)(BLOCK10_ADDR+12)) = BLOCK10_DEST3;
    /**((uint16_t *)(BLOCK10_ADDR+14)) = BLOCK10_SRC4;
    *((uint16_t *)(BLOCK10_ADDR+16)) = BLOCK10_DEST4;
    *((uint16_t *)(BLOCK10_ADDR+18)) = BLOCK10_SRC5;
    *((uint16_t *)(BLOCK10_ADDR+20)) = BLOCK10_DEST5;
    */
    
    /**((uint16_t *)(BLOCK11_ADDR)) = (BLOCK11_ID << 8) | BLOCK11_LEN;
    *((uint16_t *)(BLOCK11_ADDR+2)) = BLOCK11_SRC1;
    *((uint16_t *)(BLOCK11_ADDR+4)) = BLOCK11_DEST1;
    *((uint16_t *)(BLOCK11_ADDR+6)) = BLOCK11_SRC2;
    *((uint16_t *)(BLOCK11_ADDR+8)) = BLOCK11_DEST2;
    *((uint16_t *)(BLOCK11_ADDR+10)) = BLOCK11_SRC3;
    *((uint16_t *)(BLOCK11_ADDR+12)) = BLOCK11_DEST3;
    *((uint16_t *)(BLOCK11_ADDR+14)) = BLOCK11_SRC4;
    *((uint16_t *)(BLOCK11_ADDR+16)) = BLOCK11_DEST4;
    *((uint16_t *)(BLOCK11_ADDR+18)) = BLOCK11_SRC5;
    *((uint16_t *)(BLOCK11_ADDR+20)) = BLOCK11_DEST5;
    */
    
    /**((uint16_t *)(BLOCK12_ADDR)) = (BLOCK12_ID << 8) | BLOCK12_LEN;
    *((uint16_t *)(BLOCK12_ADDR+2)) = BLOCK12_SRC1;
    *((uint16_t *)(BLOCK12_ADDR+4)) = BLOCK12_DEST1;
    *((uint16_t *)(BLOCK12_ADDR+6)) = BLOCK12_SRC2;
    *((uint16_t *)(BLOCK12_ADDR+8)) = BLOCK12_DEST2;
    *((uint16_t *)(BLOCK12_ADDR+10)) = BLOCK12_SRC3;
    *((uint16_t *)(BLOCK12_ADDR+12)) = BLOCK12_DEST3;
    *((uint16_t *)(BLOCK12_ADDR+14)) = BLOCK12_SRC4;
    *((uint16_t *)(BLOCK12_ADDR+16)) = BLOCK12_DEST4;
    */

    /**((uint16_t *)(BLOCK13_ADDR)) = (BLOCK13_ID << 8) | BLOCK13_LEN;
    *((uint16_t *)(BLOCK13_ADDR+2)) = BLOCK13_SRC1;
    *((uint16_t *)(BLOCK13_ADDR+4)) = BLOCK13_DEST1;
    *((uint16_t *)(BLOCK13_ADDR+6)) = BLOCK13_SRC2;
    *((uint16_t *)(BLOCK13_ADDR+8)) = BLOCK13_DEST2;
    *((uint16_t *)(BLOCK13_ADDR+10)) = BLOCK13_SRC3;
    *((uint16_t *)(BLOCK13_ADDR+12)) = BLOCK13_DEST3;
    *((uint16_t *)(BLOCK13_ADDR+14)) = BLOCK13_SRC4;
    *((uint16_t *)(BLOCK13_ADDR+16)) = BLOCK13_DEST4;
    */
    
    /**((uint16_t *)(BLOCK14_ADDR)) = (BLOCK14_ID << 8) | BLOCK14_LEN;
    *((uint16_t *)(BLOCK14_ADDR+2)) = BLOCK14_SRC1;
    *((uint16_t *)(BLOCK14_ADDR+4)) = BLOCK14_DEST1;
    *((uint16_t *)(BLOCK14_ADDR+6)) = BLOCK14_SRC2;
    *((uint16_t *)(BLOCK14_ADDR+8)) = BLOCK14_DEST2;
    *((uint16_t *)(BLOCK14_ADDR+10)) = BLOCK14_SRC3;
    *((uint16_t *)(BLOCK14_ADDR+12)) = BLOCK14_DEST3;
    *((uint16_t *)(BLOCK14_ADDR+14)) = BLOCK14_SRC4;
    *((uint16_t *)(BLOCK14_ADDR+16)) = BLOCK14_DEST4;
    */
    #endif

    // Resume Timer on exit
    TACTL |= MC_1; 
    
    return;
}

// TCB_ATTEST
__attribute__ ((section (".tcb.attest"))) void tcb_attest()
{
 
    #if IS_SIM == SIM
    uint8_t * cflog = (uint8_t * )(LOG_BASE);
    unsigned int i;
    for(i=0; i<LOG_SIZE; i++){
        P1OUT = cflog[i];
    }

    #else
    // graph sdtata addrs for each obj
    uint8_t * response = (uint8_t*)(RESP_ADDR);
    uint8_t * key = (uint8_t*)(KEY_ADDR);
    uint8_t * metadata = (uint8_t*)(METADATA_ADDR);

    /********** TCB WAIT ************/
    uint8_t readyByte = ACK;

    echo_tx_rx(&readyByte, 1);
    if(readyByte == ACK){
        my_memcpy((uint8_t*)(LOG_BASE_XS), (uint8_t*)(LOG_BASE), LOG_SIZE);

        my_memcpy((uint8_t*)(CHAL_XS), (uint8_t*)(CHAL_BASE), CHAL_SIZE);

        hmac(response, key, (uint32_t) KEY_SIZE, (uint8_t*)(ATTEST_DATA_ADDR), (uint32_t) ATTEST_SIZE);

        hmac(response, response, (uint32_t) KEY_SIZE, (uint8_t*)(CHAL_XS), (uint32_t) CHAL_SIZE);

        hmac(response, response, (uint32_t) KEY_SIZE, metadata, (uint32_t) METADATA_SIZE);

        hmac(response, response, (uint32_t) KEY_SIZE, (uint8_t*)(LOG_BASE_XS), (uint32_t) *((uint16_t*)(CLOGP_ADDR))*2);

        tcb_wait();
    }

    // restore return address
    __asm__ volatile("mov    #0x500,   r6" "\n\t");
    __asm__ volatile("mov    @(r6),     r6" "\n\t");

    // postamble -- check LST, add all insts before "ret"
    __asm__ volatile("incd  r1" "\n\t");
    // __asm__ volatile("pop   r11" "\n\t");
    #endif

    // safe exit
    __asm__ volatile( "br      #__mac_leave" "\n\t");
}

__attribute__ ((section (".do_mac.leave"))) __attribute__((naked)) void Hacl_HMAC_SHA2_256_hmac_exit() 
{
  __asm__ volatile("ret" "\n\t");
}

// TCB WAIT
__attribute__ ((section (".tcb.wait"))) void tcb_wait(){
    uint8_t * response = (uint8_t*)(RESP_ADDR);
    uint8_t * key = (uint8_t*)(KEY_ADDR);
    uint8_t * challenge = (uint8_t*)(CHAL_BASE);
    uint8_t * metadata = (uint8_t*)(METADATA_ADDR);
    uint8_t * cflog = (uint8_t*)(LOG_BASE_XS);

    // receive data
    uint8_t * recv_new_chal = (uint8_t*)(NEW_CHAL_ADDR);
    uint8_t * recv_auth = (uint8_t*)(VRF_AUTH);
    
    uint8_t app = 10;
    uint8_t * buffer_8_to_16 = (uint8_t*)(TMP_16_BUFF);

    unsigned int i;
    
    //// send H, METADATA, CFLog (2)
    // H
    sendBuffer(response, KEY_SIZE);
    P3OUT++;
    // metadata
    sendBuffer(metadata, METADATA_SIZE);
    P3OUT++;
    // cflog
    sendBuffer(cflog, *((uint16_t*)(CLOGP_ADDR))*2);      
    
    P3OUT++;
    //// Receive app, chal', AER_min, AER_max, Auth to Prv (6)
    // app
    echo_rx_tx(&app, 1);

    P3OUT++;
    //chal'
    echo_rx_tx(recv_new_chal, KEY_SIZE);

    P3OUT++;
    // AER_min
    echo_rx_tx(buffer_8_to_16, 2);

    *((uint16_t*)(ERMIN_ADDR)) = (buffer_8_to_16[0] << 8) | buffer_8_to_16[1];
    P3OUT++;

    // AER_max
    echo_rx_tx(buffer_8_to_16, 2);

    *((uint16_t*)(ERMAX_ADDR)) = (buffer_8_to_16[0] << 8) | (buffer_8_to_16[1]);

    //auth
    echo_rx_tx(recv_auth, KEY_SIZE);

    P3OUT++;
    // Authenticate & produce 'out'
    uint8_t out = 0x00;
    for(i=0; i<KEY_SIZE; i++){
        if(recv_new_chal[i] > challenge[i]){
            out = 0x01;
            break;
        } else if(recv_new_chal[i] < challenge[i]){
            out = 0x00;
            break;
        }
    }
    P3OUT++;
    // check auth token
    uint8_t * auth =  (uint8_t*)(PRV_AUTH);

    hmac(auth, key, (uint32_t) KEY_SIZE, recv_new_chal, (uint32_t) KEY_SIZE);

    buffer_8_to_16[0] = (uint8_t) (*((uint16_t*)(ERMIN_ADDR)) >> 8);
    buffer_8_to_16[1] = (uint8_t) (*((uint16_t*)(ERMIN_ADDR)) & 0x00ff);
    P3OUT++;
    hmac(auth, auth, (uint32_t) KEY_SIZE, buffer_8_to_16, (uint32_t) 2);

    buffer_8_to_16[0] = (uint8_t) (*((uint16_t*)(ERMAX_ADDR)) >> 8);
    buffer_8_to_16[1] = (uint8_t) (*((uint16_t*)(ERMAX_ADDR)) & 0x00ff);
    P3OUT++;
    hmac(auth, auth, (uint32_t) KEY_SIZE, buffer_8_to_16, (uint32_t) 2);

    P3OUT++;
    hmac(auth, auth, (uint32_t) KEY_SIZE, &app, (uint32_t) 1);

    sendBuffer(auth, KEY_SIZE);
    recvBuffer(auth, KEY_SIZE);
    P3OUT++;
    
    out ^= secure_memcmp(auth, recv_auth, KEY_SIZE);
    P3OUT++;

    sendBuffer(&out, 1);
    recvBuffer(&out, 1);
    P3OUT++;
    if(out == 0){
        // inauthentic vrf -- re-enter tcb_wait
        P2OUT = 0x55;
    } else {
        P2OUT = 0x0f;
        if(app == 1){
            // vrf approved --> resume exec
           P2OUT |= 0xf0;
        } else {
            // vrf does not approve --> tcb_heal
           P2OUT |= 0x50;
           // "Shut Down"
           _BIS_SR(CPUOFF);

           // "Reset"
           //((void(*)(void))(*(uint16_t*)(0xFFFE)))();
        }
    }
    P3OUT++;

    //DEBUG: print old chal on vrf side
    sendBuffer((uint8_t * )(CHAL_BASE), CHAL_SIZE);

    // Update challenge
    my_memcpy((uint8_t * )(CHAL_BASE), (uint8_t * )(NEW_CHAL_ADDR), CHAL_SIZE);

    //DEBUG: print new chal on vrf side
    sendBuffer((uint8_t * )(CHAL_BASE), CHAL_SIZE);
    // recvBuffer((uint8_t * )(CHAL_BASE), CHAL_SIZE);

    //DEBUG: print first 16 bytes of attested memory
    sendBuffer((uint8_t * )(ATTEST_DATA_ADDR), 16);
}

__attribute__ ((section (".tcb.leave"), naked)) void tcb_exit() {
    __asm__ volatile("reti" "\n\t");
}

 /**********  UTILITY    *********/
#if IS_SIM == SIM
__attribute__ ((section (".tcb.wait"))) void my_hmac(uint8_t *mac, uint8_t *key, uint32_t keylen, uint8_t *data, uint32_t datalen){
    unsigned int i;
    unsigned int j;
    for(i=0; i<keylen; i++){
        mac[i] = key[i] | data[i];
    }
}
#endif

__attribute__ ((section (".tcb.lib"))) void my_memset(uint8_t* ptr, int len, uint8_t val) {
  int i=0;
  for(i=0; i<len; i++) ptr[i] = val;
}

__attribute__ ((section (".tcb.lib"))) void my_memcpy(uint8_t* dst, uint8_t* src, int size) {
  int i=0;
  for(i=0; i<size; i++) dst[i] = src[i];
}

__attribute__ ((section (".tcb.lib"))) int secure_memcmp(const uint8_t* s1, const uint8_t* s2, int size) {
    int res = 0;
    int first = 1;
    for(int i = 0; i < size; i++) {
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

/************ UART COMS ************/
__attribute__ ((section (".tcb.wait"))) void recvBuffer(uint8_t * rx_data, uint16_t size){
    P3OUT ^= 0x40;
    unsigned int i=0, j;
    unsigned long time = 0;
    while(i < size && time != UART_TIMEOUT){
        
        #if IS_SIM == NOT_SIM
        // wait while rx buffer is empty         // implementation only
        while((UART_STAT & UART_RX_PND) != UART_RX_PND && time != UART_TIMEOUT){
            time++;
        }
        UART_STAT |= UART_RX_PND;
        #endif

        if(time == UART_TIMEOUT){
            break;
        } else {
            rx_data[i] = UART_RXD;
            
            #if IS_SIM == NOT_SIM
            // implementation only
            for(j=0; j<DELAY; j++)
            {} // wait for buffer to clear before reading next char
            #endif
            
            i++;
        }
    }
    P3OUT ^= 0x40;
}

__attribute__ ((section (".tcb.wait"))) void sendBuffer(uint8_t * tx_data, uint16_t size){

    P3OUT ^= 0x20;
    unsigned int i, j;
    for(i=0; i<size; i++){
        #if IS_SIM == NOT_SIM
        // delay until tx buffer is empty // implementation only
        while(UART_STAT & UART_TX_FULL);
        #endif

        UART_TXD = tx_data[i];
        
        #if IS_SIM == NOT_SIM
        // only implementation
        for(j=0; j<DELAY; j++)
        {} // wait for buffer to clear before sending next char
        #endif

    }
    P3OUT ^= 0x20;
}

__attribute__ ((section (".tcb.wait"))) void echo_rx_tx(uint8_t * data, uint16_t size){

    unsigned int i=0, j;
    unsigned long time = 0;
    uint8_t byte;
    uint8_t cleared = 0;
    // RX ALL BYTES
    while(i < size){
        
        #if IS_SIM == NOT_SIM
        // wait for rx buffer or timeout // only on implementation
        while((UART_STAT & UART_RX_PND) != UART_RX_PND && time != UART_TIMEOUT){
            time++;
        }
        UART_STAT |= UART_RX_PND;
        #endif

        if(time != UART_TIMEOUT)
        {
            // P5OUT = SET_GREEN;
            byte = UART_RXD;
            
            #if IS_SIM == NOT_SIM
            // only for implementation
            for(j=0; j<DELAY; j++)
            {} // wait for buffer to clear before reading next char
            #endif

            if(byte != ACK && cleared != 1){
                cleared = 1; // while data overflowed ACK's, ignore data
            }

            if(cleared){
                data[i] = byte;
            }

            i++;

        } else {
            i = 0;
        }
        time = 0;
    }

    // TX ALL BYTES
    for(i=0; i<size; i++){
        
        #if IS_SIM == NOT_SIM
        // delay until tx buffer is empty // only for implementation
        while(UART_STAT & UART_TX_FULL);
        #endif

        UART_TXD = data[i];

        #if IS_SIM == NOT_SIM
        // only for implementation
        for(j=0; j<DELAY; j++)
        {} // wait for buffer to clear before sending next char
        #endif
    }
}

__attribute__ ((section (".tcb.wait"))) void echo_tx_rx(uint8_t * data, uint16_t size){

    unsigned long i=0, j;
    unsigned long time;
    unsigned char delivered = 0;
    while(!delivered){
        // TX ALL BYTES
        for(i=0; i<size; i++){
            #if IS_SIM == NOT_SIM
            // delay until tx buffer is empty // only for implementation
            while(UART_STAT & UART_TX_FULL);
            #endif

            UART_TXD = data[i];

            #if IS_SIM == NOT_SIM
            // only for implementation
            for(j=0; j<DELAY; j++)
            {} // wait for buffer to clear before sending next char
            #endif
        }

        // RX ALL BYTES
        i = 0;
        time = 0;
        while(i < size){
            #if IS_SIM == NOT_SIM
            // wait for rx buffer or timeout // only for implementation
            while((UART_STAT & UART_RX_PND) != UART_RX_PND && time != UART_TIMEOUT){
                time++;
            }
            UART_STAT |= UART_RX_PND;
            #endif

            if(time != UART_TIMEOUT)
            {
                data[i] = UART_RXD;
                
                #if IS_SIM == NOT_SIM
                // only for implementation
                for(j=0; j<DELAY; j++)
                {} // wait for buffer to clear before sending next char
                #endif

                i++;
                delivered = 1;
            } else {
                delivered = 0;
                break;
            }
        }
    }
}

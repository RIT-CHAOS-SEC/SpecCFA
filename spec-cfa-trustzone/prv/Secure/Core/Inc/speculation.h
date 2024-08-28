/*
 * speculation.h
 *
 *  Created on: Aug 21, 2023
 */

#include "stdint.h"
#include "cfa_engine.h"

#ifndef INC_SPECULATION_H_
#define INC_SPECULATION_H_

/*** MASKS ***/
#define BLOCK0_MASK	0x01
#define BLOCK1_MASK	0x02
#define BLOCK2_MASK	0x04
#define BLOCK3_MASK	0x08
#define BLOCK4_MASK	0x10
#define BLOCK5_MASK	0x20
#define BLOCK6_MASK	0x40
#define BLOCK7_MASK	0x80

/*** IDS ***/
#define BLOCK0_ID	0x11110000
#define BLOCK1_ID	0x11110001
#define BLOCK2_ID	0x11110002
#define BLOCK3_ID	0x11110003
#define BLOCK4_ID	0x11110004
#define BLOCK5_ID	0x11110005
#define BLOCK6_ID	0x11110006
#define BLOCK7_ID	0x11110007

/*** FUNCS ***/
void SPECCFA_process_log_entry(uint32_t, CFA_REPORT *);
void SPECCFA_speculate(uint32_t);
void SPECCFA_detect_path(uint32_t, uint32_t *, uint8_t, uint8_t);
void SPECCFA_detect_paths(uint32_t);
void SPECCFA_reset();

#endif /* INC_SPECULATION_H_ */

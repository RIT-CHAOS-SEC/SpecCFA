/*
 * speculation.c
 *
 *  Created on: Aug 21, 2023
 */

#include "speculation.h"
#include "cfa_engine.h"

//#define SPECULATE
#define TOTAL_BLOCKS	8
#define BLOCK0_SIZE		6
uint32_t path0[BLOCK0_SIZE] = {
		0x8040344,
		0x80402b4,
		0x8040354,
		0x804045e,
		0x80404c8,
		0x80404fe
};
#if TOTAL_BLOCKS >= 2
#define BLOCK1_SIZE		5
uint32_t path1[BLOCK1_SIZE] = {
		0x80404bc,
		0x80403c8,
		0x8040260,
		0x80403da,
		0x8040364
};
#endif
#if TOTAL_BLOCKS >= 3
#define BLOCK2_SIZE		4
uint32_t path2[BLOCK2_SIZE] = {
		0x8040310,
		0x8040370,
		0x80403e2,
		0x80402b4
};
#endif
#if TOTAL_BLOCKS >= 4
#define BLOCK3_SIZE		5
uint32_t path3[BLOCK3_SIZE] = {
		0x8040404,
		0x804040a,
		0x804028c,
		0x804041a,
		0x8040452
};
#endif
#if TOTAL_BLOCKS >= 5
#define BLOCK4_SIZE		3
uint32_t path4[BLOCK4_SIZE] = {
		0x8040380,
		0x8040364,
		0x8040310};
#endif
#if TOTAL_BLOCKS >= 6
#define BLOCK5_SIZE		4
uint32_t path5[BLOCK5_SIZE] = {
		0x8040370,
		0x8040392,
		0x8040398,
		0x8040238
};
#endif
#if TOTAL_BLOCKS >= 7
#define BLOCK6_SIZE		4
uint32_t path6[BLOCK6_SIZE] = {
		0x80403ae,
		0x80403ae,
		0x80404ba,
		0x80404fe};
#endif
#if TOTAL_BLOCKS >= 8
#define BLOCK7_SIZE		2
uint32_t path7[BLOCK7_SIZE] = {
		0x804050a,
		0xfefffffe
};
#endif

uint8_t block_sizes[TOTAL_BLOCKS] = {  BLOCK0_SIZE
									 #if TOTAL_BLOCKS >= 2
									 , BLOCK1_SIZE
									 #endif
									#if TOTAL_BLOCKS >= 3
									 , BLOCK2_SIZE
									#endif
									#if TOTAL_BLOCKS >= 4
									 , BLOCK3_SIZE
									#endif
									#if TOTAL_BLOCKS >= 5
									 , BLOCK4_SIZE
									#endif
									#if TOTAL_BLOCKS >= 6
									 , BLOCK5_SIZE
									#endif
									#if TOTAL_BLOCKS >= 7
									 , BLOCK6_SIZE
									#endif
									#if TOTAL_BLOCKS >= 8
									 , BLOCK7_SIZE
									#endif
									 };


uint32_t * path_base_addrs[TOTAL_BLOCKS] = { path0
											#if TOTAL_BLOCKS >= 2
											, path1
											#endif
											#if TOTAL_BLOCKS >= 3
											, path2
											#endif
											#if TOTAL_BLOCKS >= 4
											, path3
											#endif
											#if TOTAL_BLOCKS >= 5
											, path4
											#endif
											#if TOTAL_BLOCKS >= 6
											, path5
											#endif
											#if TOTAL_BLOCKS >= 7
											, path6
											#endif
											#if TOTAL_BLOCKS >= 8
											, path7
											#endif
											};

uint8_t spec_monitor_count[TOTAL_BLOCKS];

/********************************/

uint8_t spec_monitor = 0x00;
uint8_t spec_detect = 0x00;


uint32_t log_entry;
uint8_t repeat_detect = 0;
uint32_t repeat_count = 0xffff0002;
uint32_t prev_value = 0;
uint32_t prev_addr = 0;
uint32_t active_addr = 0;
int tmp;
signed int increment;

int random_init;

void init_spec(){
	SPECCFA_reset();
}

void SPECCFA_reset(){
	spec_monitor = 0x00;
	spec_detect = 0x00;
	for(int i=0; i<TOTAL_BLOCKS; i++){
		spec_monitor_count[i] = 0;
	}
	repeat_detect = 0;
	repeat_count = 0xffff0002;

	prev_value = 0;
	prev_addr = 0;
	active_addr = 0;
}


void SPECCFA_process_log_entry(uint32_t addr, CFA_REPORT * report_secure){
	#ifdef SPECULATE
	SPECCFA_detect_paths(addr);
	if(spec_detect == 0){
		// no sub-path detect, so append log normally
		report_secure->num_CF_Log_size++;
		report_secure->CFLog[report_secure->num_CF_Log_size] = addr;

		if(spec_monitor == 0){
			repeat_detect = 0;
			repeat_count = 0xffff0002;
//			prev_value = log_entry;
//			prev_addr = report_secure->num_CF_Log_size;
		}
	} else{
		SPECCFA_speculate(addr);
		if(log_entry == BLOCK1_ID){
			tmp = spec_detect;
		}
		active_addr = report_secure->num_CF_Log_size+increment;
		// if not repeating and no repeat detected, log subpath normally, set prev_value
		if (repeat_detect == 0 && ((prev_value != log_entry) || (prev_addr+1 != active_addr))){
			report_secure->num_CF_Log_size += increment;
			report_secure->CFLog[report_secure->num_CF_Log_size] = log_entry;
			prev_value = log_entry;
			prev_addr = active_addr;
		}
		// if not repeating but repeat is detected, this is the first instance. Set repeat_detect and log the ctr.
		else if(repeat_detect == 0 && prev_value == log_entry && prev_addr+1 == active_addr){
			repeat_detect = 1;
			report_secure->num_CF_Log_size += increment;
			prev_addr++; // move prev_addr from first ID to CTR
			report_secure->CFLog[report_secure->num_CF_Log_size] = repeat_count;
		}
		// if repeating and repeat is continuing, increment the counter, increment and log counter
		else if(repeat_detect == 1 && prev_value == log_entry && prev_addr+1 == active_addr){
			repeat_count++;
			report_secure->num_CF_Log_size += increment-1;
			report_secure->CFLog[report_secure->num_CF_Log_size] = repeat_count;
		}
		// if repeat_detect and a different subpath has occurred, reset repeat signals and log current sub-path
		else {
			repeat_detect = 0;
			repeat_count = 0xffff0002;
			report_secure->num_CF_Log_size += increment;
			report_secure->CFLog[report_secure->num_CF_Log_size] = log_entry;
			prev_value = log_entry;
			prev_addr = active_addr;
		}
	}
	#else
	report_secure->num_CF_Log_size++;
	report_secure->CFLog[report_secure->num_CF_Log_size] = addr;
	#endif
	return;
}

void SPECCFA_speculate(uint32_t addr){
	if((spec_detect & BLOCK0_MASK) == BLOCK0_MASK){
		spec_detect &= ~BLOCK0_MASK;
		increment = 2-BLOCK0_SIZE; // get -(blocksize-2) without mult
		log_entry = BLOCK0_ID;
	}
	#if TOTAL_BLOCKS >= 2
	else if((spec_detect & BLOCK1_MASK) == BLOCK1_MASK){
		spec_detect &= ~BLOCK1_MASK;
		increment = 2-BLOCK1_SIZE;
		log_entry = BLOCK1_ID;
	}
	#endif
	#if TOTAL_BLOCKS >= 3
	else if((spec_detect & BLOCK2_MASK) == BLOCK2_MASK){
		spec_detect &= ~BLOCK2_MASK;
		increment = 2-BLOCK2_SIZE;
		log_entry = BLOCK2_ID;
	}
	#endif
	#if TOTAL_BLOCKS >= 4
	else if((spec_detect & BLOCK3_MASK) == BLOCK3_MASK){
		spec_detect &= ~BLOCK3_MASK;
		increment = 2-BLOCK3_SIZE;
		log_entry = BLOCK3_ID;
	}
	#endif
	#if TOTAL_BLOCKS >= 5
	else if((spec_detect & BLOCK4_MASK) == BLOCK4_MASK){
		spec_detect &= ~BLOCK4_MASK;
		increment = 2-BLOCK4_SIZE;
		log_entry = BLOCK4_ID;
	}
	#endif
	#if TOTAL_BLOCKS >= 6
	else if((spec_detect & BLOCK5_MASK) == BLOCK5_MASK){
		spec_detect &= ~BLOCK5_MASK;
		increment = 2-BLOCK5_SIZE;
		log_entry = BLOCK5_ID;
	}
	#endif
	#if TOTAL_BLOCKS >= 7
	else if((spec_detect & BLOCK6_MASK) == BLOCK6_MASK){
		spec_detect &= ~BLOCK6_MASK;
		increment = 2-BLOCK6_SIZE;
		log_entry = BLOCK6_ID;
	}
	#endif
	#if TOTAL_BLOCKS >= 8
	else if((spec_detect & BLOCK7_MASK) == BLOCK7_MASK){
		spec_detect &= ~BLOCK7_MASK;
		increment = 2-BLOCK7_SIZE;
		log_entry = BLOCK7_ID;
	}
	#endif
}

void SPECCFA_detect_path(uint32_t value, uint32_t * path, uint8_t block_num, uint8_t size){
	uint8_t mask = (0x01 << block_num);

	uint32_t next_in_path = path[spec_monitor_count[block_num]];

	if(value == next_in_path){

		// If match, increment the count and set the bit in monitor
		spec_monitor_count[block_num]++;
		spec_monitor |= mask;

		// If the count equals the subpath size, the entire subpath occurred in the log
		if(spec_monitor_count[block_num] == size){
			// Turn on detect bit, reset everything
			spec_detect = mask;
			spec_monitor = 0;
			for(int i=0; i<TOTAL_BLOCKS; i++){
				spec_monitor_count[i] = 0;
			}
		}

	}  else if((spec_monitor & mask) == mask){
		// Reaches here if value != to the next subpath entry.

		// If current log entry is the first entry in sub-path, must reset counter to 1 and stay in monitor mode
		if(value == path[0]){
			spec_monitor_count[block_num] = 1;
		}
		// Otherwise, set counter to 0 and clear from monitor
		else{
			spec_monitor &= ~mask;
			spec_monitor_count[block_num] = 0;
		}

	}
}

void SPECCFA_detect_paths(uint32_t addr){
	for(int i=0; i<TOTAL_BLOCKS; i++){
		SPECCFA_detect_path(addr, path_base_addrs[i], i, block_sizes[i]);
	}
}

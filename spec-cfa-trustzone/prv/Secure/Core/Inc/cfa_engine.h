/*
 * cfa_engine.h
 *
 *  Created on: Dec 4, 2022
 */

#ifndef INC_CFA_ENGINE_H_
#define INC_CFA_ENGINE_H_

#include <stdlib.h>
#include "secure_nsc.h"
#include "stm32l5xx.h"
#include "stm32l5xx_hal.h"
#include "cmsis_gcc.h"
#include "main.h"
#include "stm32l5xx_hal.h"

#if defined ( __ICCARM__ )
#  define CMSE_NS_CALL  __cmse_nonsecure_call
#  define CMSE_NS_ENTRY __cmse_nonsecure_entry
#else
#  define CMSE_NS_CALL  __attribute((cmse_nonsecure_call))
#  define CMSE_NS_ENTRY __attribute((cmse_nonsecure_entry))
#endif

/* typedef for non-secure callback functions */
typedef funcptr funcptr_NS;

// LIMITS
//#define TOTAL_KB			7936
//#define KBYTE				1024

#define MAX_LOG_SIZE_BYTES	256
#define MAX_CF_LOG_SIZE 	(uint16_t)(MAX_LOG_SIZE_BYTES/4) //32 bits (4 bytes) per index

// GENERAL
#define CONTINUE_LOOP		1
#define EXIT_LOOP			0
#define TRUE (char) 		1
#define FALSE (char) 		0
#define INITIALIZED 		0xEE

// REQUESTS
#define challenge_REQUEST 1

// IDENTIFIERS
#define COMMAND_SIZE  		4
#define INIT_ATTESTATION 	"aaaa"
#define ACCEPTED_REPORT 	"VVVV"
#define HEAL_REQUEST 		"hhhh"
#define CONTINUE_REQUEST    "CCCC"
#define BEGGINING_OF_REPORT 	"REPO"
#define BEGGINING_OF_CHALLANGE 	"CHAL"
#define BEGGINING_OF_COMMAND 	"COMD"

#define INIT_ATTESTATION_CHAR 	'i'
#define HEAL_CHAR 				'h'
#define CONTINUE_CHAR 			'c'
#define ACCEPT_REPORT_CHAR 		'v'


// REPORT STRUCT IDENTIFIERS
#define PARTIAL_REPORT      'P'
#define FINAL_REPORT      	'F'

// STATUS
#define WAITING_PARTIAL	(char) 	4
#define ERROR	 		(char) 	3
#define COMPLETE 		(char) 	2
#define ACTIVE 			(char)	1
#define INACTIVE 		(char) 	0

// ERRORS
#define SUCCESS										(char) 0
#define ERROR_NO_APP_NAME_SPACE 					(char) 1
#define ERROR_NO_APP_MEMORY_SPACE 					(char) 2
#define ERROR_MEMORY_ALLOCATION 					(char) 3
#define ERROR_REPORT_MEMORY 						(char) 4
#define ERROR_CFA_ENGINE_NOT_INITIALIZED 			(char) 5
#define ERROR_CFA_ENGINE_ALREADY_INITIALIZED 		(char) 6
#define ERROR_NO_FUNCTION_REGISTERED 				(char) 7
#define ERROR_ATTESTATION_INSTANCE_ALREADY_ACTIVE 	(char) 8
#define ERROR_MAX_NUMBER_APP_REGISTERED 			(char) 9
#define ERROR_CFA_ENGINE_CONF_NOT_ALLOCATED			(char) 10

// Attestation Parameters
#define KEY_SIZE	64
#define CHAL_SIZE	64

// Secure / NonSecure world memory boundaries
// Update by inspecting objdump output
#define SECURE_FLASH_START				0x0c000200
#define SECURE_FLASH_END				0x0c009e6e
#define SECURE_FLASH_SIZE				SECURE_FLASH_END-SECURE_FLASH_START+2

#define NSC_FLASH_START				0x0c03e000
#define NSC_FLASH_END				0x0c03e05e
#define NSC_FLASH_SIZE				NSC_FLASH_END-NSC_FLASH_START+2

// Update by inspecting objdump output
#define NONSECURE_FLASH_START			0x080401f8
#define	NONSECURE_FLASH_END				0x08040d54
#define ENDS_IN_WORD					1
#define	NONSECURE_FLASH_SIZE			NONSECURE_FLASH_END-NONSECURE_FLASH_START+2+ENDS_IN_WORD*2

#define NONSECURE_APP_FLASH_START		'NA'
#define	NONSECURE_APP_FLASH_END			'NA'

#define HASH_SIZE_BYTES			32
#define SIGNATURE_SIZE_BYTES	64

#define CFLOG_RAM 1
#define CFLOG_FLASH 2
#define CFLOG_TYPE CFLOG_RAM

// TYPEDEFs
typedef long unsigned int hash;
typedef unsigned int CFA_ENTRY;

typedef struct CFA_ENGINE_APP_CONFIG{
	funcptr_NS  		app_start_address;
}CFA_ENGINE_APP_CONFIG;

typedef struct CFA_REPORT{
		uint8_t     signature[SIGNATURE_SIZE_BYTES];
		uint16_t	isFinal;
		uint8_t 	mem_hash [HASH_SIZE_BYTES];
		uint16_t	num_CF_Log_size;
		uint32_t 	CFLog[MAX_CF_LOG_SIZE];
		uint16_t	number_of_logs_sent; // init = 0
}CFA_REPORT;

typedef struct CFA_ENGINE_CONFIG{
	CFA_ENGINE_APP_CONFIG 	iac;
	flag 				attestation_status;
	uint16_t 			log_counter;// init = 0
	uint8_t				challenge[CHAL_SIZE];
	flag 				challenge_renewed;
	flag				initialized;
	uint8_t 			hash_key[KEY_SIZE];
}CFA_ENGINE_CONFIG;

typedef struct VRF_RESPONSE{
	// Data sent back from Verifier
	uint8_t new_challenge[CHAL_SIZE];
	uint8_t verify_result;
	uint8_t signature[SIGNATURE_SIZE_BYTES];
}VRF_RESPONSE;

// PUBLIC FUNCTIONS
void CFA_ENGINE_new_log_entry(uint32_t value);
void CFA_ENGINE_run_attestation();
void CFA_ENGINE_initialize(); // Initial setup of attestation variables
void CFA_ENGINE_register_callback(); // Register the function to be attested
void CFA_ENGINE_start();
void CFA_time_interrupt_handler();
void _run_application();
void _send_report_message();
void record_output_data(uint32_t);
void speccfa_detect_paths(uint32_t);
void speccfa_speculate(uint32_t);

// GLOBAL VARIABLES

#endif /* INC_CFA_ENGINE_H_ */

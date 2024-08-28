/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    Secure/Src/secure_nsc.c
  * @author  MCD Application Team
  * @brief   This file contains the non-secure callable APIs (secure world)
  ******************************************************************************
    * @attention
  *
  * Copyright (c) 2022 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* USER CODE BEGIN Non_Secure_CallLib */
/* Includes ------------------------------------------------------------------*/
#include "secure_nsc.h"
#include "cfa_engine.h"

/** @addtogroup STM32L5xx_HAL_Examples
  * @{
  */

/** @addtogroup Templates
  * @{
  */



/* Global variables ----------------------------------------------------------*/
void *pSecureFaultCallback = NULL;   /* Pointer to secure fault callback in Non-secure */
void *pSecureErrorCallback = NULL;   /* Pointer to secure error callback in Non-secure */
void *pAttestationFunctionCallback = NULL;
/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Secure registration of non-secure callback.
  * @param  CallbackId  callback identifier
  * @param  func        pointer to non-secure function
  * @retval None
  */

CMSE_NS_ENTRY void SECURE_RegisterCallback(SECURE_CallbackIDTypeDef CallbackId, void *func){
  if(func != NULL)
  {
    switch(CallbackId)
    {
      case SECURE_FAULT_CB_ID:           /* SecureFault Interrupt occurred */
			pSecureFaultCallback = func;
			break;
      case GTZC_ERROR_CB_ID:             /* GTZC Interrupt occurred */
			pSecureErrorCallback = func;
			break;
      case ATTESTATION_APP_ID:
			pAttestationFunctionCallback = func;
			CFA_ENGINE_register_callback();
			break;
      default:
        break;
    }
  }
}

CMSE_NS_ENTRY void SECURE_RunCallback(){
	CFA_ENGINE_run_attestation(0x23FA);
	return;
}

CMSE_NS_ENTRY void SECURE_Initialize_CFA_engine(){
	CFA_ENGINE_initialize();
	return;
}

CMSE_NS_ENTRY void SECURE_Initialize_Attestation(){
	CFA_ENGINE_initialize();
	return;
}

CMSE_NS_ENTRY __attribute ((naked)) void SECURE_log_ret(){
	__asm__ volatile("push	{r0, r1, r2, r3, r7, r12}");
	__asm__ volatile("sub	sp, sp, #24");
	__asm__ volatile("add	r7, sp, #0");
	__asm__ volatile("push	{r7, lr}");
	__asm__ volatile("sub	sp, sp, #8");
	__asm__ volatile("add	r7, sp, #0");

	uint32_t inst_addr;
	asm("mov %0, lr" : "=r"(inst_addr));
	CFA_ENGINE_new_log_entry(inst_addr);

	__asm__ volatile("nop");
	__asm__ volatile("adds	r7, r7, #8");
	__asm__ volatile("mov	sp, r7");
	__asm__ volatile("pop	{r7, lr}");
	__asm__ volatile("mov	r0, lr");
	__asm__ volatile("mov	r1, lr");
	__asm__ volatile("mov	r2, lr");
	__asm__ volatile("mov	r3, lr");
	__asm__ volatile("vmov.f32	s0, #1.0e+0");
	__asm__ volatile("vmov.f32	s1, #1.0e+0");
	__asm__ volatile("vmov.f32	s2, #1.0e+0");
	__asm__ volatile("vmov.f32	s3, #1.0e+0");
	__asm__ volatile("vmov.f32	s4, #1.0e+0");
	__asm__ volatile("vmov.f32	s5, #1.0e+0");
	__asm__ volatile("vmov.f32	s6, #1.0e+0");
	__asm__ volatile("vmov.f32	s7, #1.0e+0");
	__asm__ volatile("vmov.f32	s8, #1.0e+0");
	__asm__ volatile("vmov.f32	s9, #1.0e+0");
	__asm__ volatile("vmov.f32	s10, #1.0e+0");
	__asm__ volatile("vmov.f32	s11, #1.0e+0");
	__asm__ volatile("vmov.f32	s12, #1.0e+0");
	__asm__ volatile("vmov.f32	s13, #1.0e+0");
	__asm__ volatile("vmov.f32	s14, #1.0e+0");
	__asm__ volatile("vmov.f32	s15, #1.0e+0");
	__asm__ volatile("msr	APSR_nzcvqg, lr");
	__asm__ volatile("push	{r4}");
	__asm__ volatile("vmrs	ip, fpscr");
	__asm__ volatile("movw	r4, #65376");
	__asm__ volatile("movt	r4, #4095");
	__asm__ volatile("and	ip, r4");
	__asm__ volatile("vmsr	fpscr, ip");
	__asm__ volatile("pop	{r4}");
	__asm__ volatile("mov	ip, lr");
	__asm__ volatile("adds	r7, r7, #24");
	__asm__ volatile("mov	sp, r7");
	__asm__ volatile("pop	{r0, r1, r2, r3, r7, r12}");
	__asm__ volatile("bics	lr, #1");
	__asm__ volatile("bxns	lr");
}

CMSE_NS_ENTRY __attribute ((naked)) void SECURE_log_call(uint32_t addr){
	__asm__ volatile("push	{r0, r1, r2, r3, r7, r10}");
	__asm__ volatile("sub	sp, sp, #24");
	__asm__ volatile("add	r7, sp, #0");
	__asm__ volatile("push	{r7, lr}");
	__asm__ volatile("sub	sp, sp, #8");
	__asm__ volatile("add	r7, sp, #0");
	__asm__ volatile("sub	r0, r10, #1");
	__asm__ volatile("bl	CFA_ENGINE_new_log_entry");
	__asm__ volatile("nop");
	__asm__ volatile("adds	r7, r7, #8");
	__asm__ volatile("mov	sp, r7");
	__asm__ volatile("pop	{r7, lr}");
	__asm__ volatile("mov	r0, lr");
	__asm__ volatile("mov	r1, lr");
	__asm__ volatile("mov	r2, lr");
	__asm__ volatile("mov	r3, lr");
	__asm__ volatile("vmov.f32	s0, #1.0e+0");
	__asm__ volatile("vmov.f32	s1, #1.0e+0");
	__asm__ volatile("vmov.f32	s2, #1.0e+0");
	__asm__ volatile("vmov.f32	s3, #1.0e+0");
	__asm__ volatile("vmov.f32	s4, #1.0e+0");
	__asm__ volatile("vmov.f32	s5, #1.0e+0");
	__asm__ volatile("vmov.f32	s6, #1.0e+0");
	__asm__ volatile("vmov.f32	s7, #1.0e+0");
	__asm__ volatile("vmov.f32	s8, #1.0e+0");
	__asm__ volatile("vmov.f32	s9, #1.0e+0");
	__asm__ volatile("vmov.f32	s10, #1.0e+0");
	__asm__ volatile("vmov.f32	s11, #1.0e+0");
	__asm__ volatile("vmov.f32	s12, #1.0e+0");
	__asm__ volatile("vmov.f32	s13, #1.0e+0");
	__asm__ volatile("vmov.f32	s14, #1.0e+0");
	__asm__ volatile("vmov.f32	s15, #1.0e+0");
	__asm__ volatile("msr	APSR_nzcvqg, lr");
	__asm__ volatile("vmrs	ip, fpscr");
	__asm__ volatile("movw	r4, #65376");
	__asm__ volatile("movt	r4, #4095");
	__asm__ volatile("and	ip, r4");
	__asm__ volatile("vmsr	fpscr, ip");
	__asm__ volatile("mov	ip, lr");
	__asm__ volatile("adds	r7, r7, #24");
	__asm__ volatile("mov	sp, r7");
	__asm__ volatile("pop	{r0, r1, r2, r3, r7, r10}");
	__asm__ volatile("bics	r10, #1");
	__asm__ volatile("bxns	r10");
}


CMSE_NS_ENTRY __attribute ((naked)) void SECURE_log_cond_br(){;
	__asm__ volatile("push	{r0, r1, r2, r3, r7, r12}");
	__asm__ volatile("sub	sp, sp, #24");
	__asm__ volatile("add	r7, sp, #0");
	__asm__ volatile("push	{r7, lr}");
	__asm__ volatile("sub	sp, sp, #8");
	__asm__ volatile("add	r7, sp, #0");

	uint32_t inst_addr;
	asm("mov %0, lr" : "=r"(inst_addr));
	inst_addr -= 4;
	CFA_ENGINE_new_log_entry(inst_addr);

	__asm__ volatile("nop");
	__asm__ volatile("adds	r7, r7, #8");
	__asm__ volatile("mov	sp, r7");
	__asm__ volatile("pop	{r7, lr}");
	__asm__ volatile("mov	r0, lr");
	__asm__ volatile("mov	r1, lr");
	__asm__ volatile("mov	r2, lr");
	__asm__ volatile("mov	r3, lr");
	__asm__ volatile("vmov.f32	s0, #1.0e+0");
	__asm__ volatile("vmov.f32	s1, #1.0e+0");
	__asm__ volatile("vmov.f32	s2, #1.0e+0");
	__asm__ volatile("vmov.f32	s3, #1.0e+0");
	__asm__ volatile("vmov.f32	s4, #1.0e+0");
	__asm__ volatile("vmov.f32	s5, #1.0e+0");
	__asm__ volatile("vmov.f32	s6, #1.0e+0");
	__asm__ volatile("vmov.f32	s7, #1.0e+0");
	__asm__ volatile("vmov.f32	s8, #1.0e+0");
	__asm__ volatile("vmov.f32	s9, #1.0e+0");
	__asm__ volatile("vmov.f32	s10, #1.0e+0");
	__asm__ volatile("vmov.f32	s11, #1.0e+0");
	__asm__ volatile("vmov.f32	s12, #1.0e+0");
	__asm__ volatile("vmov.f32	s13, #1.0e+0");
	__asm__ volatile("vmov.f32	s14, #1.0e+0");
	__asm__ volatile("vmov.f32	s15, #1.0e+0");
	__asm__ volatile("msr	APSR_nzcvqg, lr");
	__asm__ volatile("push	{r4}");
	__asm__ volatile("vmrs	ip, fpscr");
	__asm__ volatile("movw	r4, #65376");
	__asm__ volatile("movt	r4, #4095");
	__asm__ volatile("and	ip, r4");
	__asm__ volatile("vmsr	fpscr, ip");
	__asm__ volatile("pop	{r4}");
	__asm__ volatile("mov	ip, lr");
	__asm__ volatile("adds	r7, r7, #24");
	__asm__ volatile("mov	sp, r7");
	__asm__ volatile("pop	{r0, r1, r2, r3, r7, r12}");
	__asm__ volatile("bics	lr, #1");
	__asm__ volatile("bxns	lr");
}

CMSE_NS_ENTRY void  SECURE_run_attestation_wait_mode(){
	CFA_ENGINE_start();
	return;
};

CMSE_NS_ENTRY void SECURE_record_output_data(uint32_t value){
	record_output_data(value);
	return;
};

/**
  * @}
  */

/**
  * @}
  */
/* USER CODE END Non_Secure_CallLib */


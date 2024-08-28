/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    Secure_nsclib/secure_nsc.h
  * @author  MCD Application Team
  * @brief   Header for secure non-secure callable APIs list
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

/* USER CODE BEGIN Non_Secure_CallLib_h */
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef SECURE_NSC_H
#define SECURE_NSC_H

/* Includes ------------------------------------------------------------------*/
#include <stdint.h>
typedef char flag;
/* Exported types ------------------------------------------------------------*/
/**
  * @brief  non-secure callback ID enumeration definition
  */
typedef enum
{
  SECURE_FAULT_CB_ID     = 0x00U, /*!< System secure fault callback ID */
  GTZC_ERROR_CB_ID       = 0x01U,  /*!< GTZC secure error callback ID */
  ATTESTATION_APP_ID     = 0x02U  /*!< GTZC secure error callback ID */
} SECURE_CallbackIDTypeDef;


/* Exported constants --------------------------------------------------------*/
/* Exported macro ------------------------------------------------------------*/
/* Exported functions ------------------------------------------------------- */
void SECURE_RegisterCallback(SECURE_CallbackIDTypeDef, void *);
void SECURE_RunCallback();
void SECURE_Initialize_CFA_engine();
void SECURE_Initialize_Attestation();
void SECURE_log_ret();
void SECURE_log_cond_br();
void SECURE_log_call(uint32_t);
void SECURE_record_output_data(uint32_t);
void SECURE_run_attestation_wait_mode(); // temp
#endif /* SECURE_NSC_H */
/* USER CODE END Non_Secure_CallLib_h */


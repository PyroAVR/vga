#include "MKL46Z4.h"
#include <stdint.h>
#ifndef __CONSTANTS_H__
#define __CONSTANTS_H__

/* C System Definitions */
#define FALSE      (0)
#define TRUE       (1)

#define MAX_STRING (79)

/* DAC */
#define DAC_DATH_0V   0x00u
#define DAC_DATL_0V   0x00u
/*---------------------------------------------------------------------*/
/* DAC_C0:  DAC control register 0                                   */
/* 1-->7:DACEN=DAC enabled                                             */
/* 1-->6:DACRFS=DAC reference select VDDA                              */
/* 0-->5:DACTRGSEL=DAC trigger select (X)                              */
/* 0-->4:DACSWTRG=DAC software trigger (X)                             */
/* 0-->3:LPEN=DAC low power control:high power                         */
/* 0-->2:(reserved):read-only:0                                        */
/* 0-->1:DACBTIEN=DAC buffer read pointer top flag interrupt enable    */
/* 0-->0:DACBBIEN=DAC buffer read pointer bottom flag interrupt enable */
#define DAC_C0_ENABLE  (DAC_C0_DACEN_MASK | DAC_C0_DACRFS_MASK)
/*----------------------------------------*/
/* DAC_C1:  DAC control register 1      */
/* 0-->  7:DMAEN=DMA disabled             */
/* 0-->6-3:(reserved)                     */
/* 0-->  2:DACBFMD=DAC buffer mode normal */
/* 0-->  1:(reserved)                     */
/* 0-->  0:DACBFEN=DAC buffer disabled    */
#define DAC_C1_BUFFER_DISABLED  (0x00u)
/*-------------------------------------------------------------*/
/* PORTx_PCRn                                                  */
/*     -->31-25:(reserved):read-only:0                         */
/*    1-->   24:ISF=interrupt status flag (write 1 to clear)   */
/*     -->23-20:(reserved):read-only:0                         */
/* 0000-->19-16:IRQC=interrupt configuration (IRQ/DMA diabled) */
/*     -->15-11:(reserved):read-only:0                         */
/*  ???-->10- 8:MUX=pin mux control                            */
/*     -->    7:(reserved):read-only:0                         */
/*    ?-->    6:DSE=drive strengh enable                       */
/*     -->    5:(reserved):read-only:0                         */
/*    0-->    4:PFE=passive filter enable                      */
/*     -->    3:(reserved):read-only:0                         */
/*    0-->    2:SRE=slew rate enable                           */
/*    0-->    1:PE=pull enable                                 */
/*    x-->    0:PS=pull select                                 */
/* Port E */
#define PTE30_MUX_DAC0_OUT (0u << PORT_PCR_MUX_SHIFT)
#define SET_PTE30_DAC0_OUT (PORT_PCR_ISF_MASK | PTE30_MUX_DAC0_OUT)
/*-------------------------------------------------------*/
/* SIM_SOPT2                                             */
/*   -->31-28:(reserved):read-only:0                     */
/*   -->27-26:UART0SRC=UART0 clock source select         */
/* 01-->25-24:TPMSRC=TPM clock source select (MCGFLLCLK) */
/*   -->23-19:(reserved):read-only:0                     */
/*   -->   18:USBSRC=USB clock source select             */
/*   -->   17:(reserved):read-only:0                     */
/*  1-->   16:PLLFLLSEL=PLL/FLL clock select (MCGFLLCLK) */
/*   -->15- 8:(reserved):read-only:0                     */
/*   --> 7- 5:CLKOUTSEL=CLKOUT select                    */
/*   -->    4:RTCCLKOUTSEL=RTC clock out select          */
/*   --> 3- 0:(reserved):read-only:0                     */
#define SIM_SOPT2_TPMSRC_MCGPLLCLK (1u << SIM_SOPT2_TPMSRC_SHIFT)
#define SIM_SOPT2_TPM_MCGPLLCLK_DIV2 (SIM_SOPT2_TPMSRC_MCGPLLCLK | \
                                            SIM_SOPT2_PLLFLLSEL_MASK)
/*------------------------------------------------------------------*/
/* TPMx_CONF:  Configuration (recommended to use default values     */
/*     -->31-28:(reserved):read-only:0                              */
/* 0000-->27-24:TRGSEL=trigger select (external pin EXTRG_IN)       */
/*     -->23-19:(reserved):read-only:0                              */
/*    0-->   18:CROT=counter reload on trigger                      */
/*    0-->   17:CSOO=counter stop on overflow                       */
/*    0-->   16:CSOT=counter stop on trigger                        */
/*     -->15-10:(reserved):read-only:0                              */
/*    0-->    9:GTBEEN=global time base enable                      */
/*     -->    8:(reserved):read-only:0                              */
/*   00-->  7-6:DBGMODE=debug mode (paused in debug)                */
/*    0-->    5:DOZEEN=doze enable                                  */
/*     -->  4-0:(reserved):read-only:0                              */
/* 15- 0:COUNT=counter value (writing any value will clear counter) */
#define TPM_CONF_DEFAULT (0u)
/*------------------------------------------------------------------*/
/* TPMx_CNT:  Counter                                               */
/* 31-16:(reserved):read-only:0                                     */
/* 15- 0:COUNT=counter value (writing any value will clear counter) */
#define TPM_CNT_INIT (0u)
/*------------------------------------------------------------------------*/
/* TPMx_MOD:  Modulo                                                      */
/* 31-16:(reserved):read-only:0                                           */
/* 15- 0:MOD=modulo value (recommended to clear TPMx_CNT before changing) */
/* Period = 3 MHz / 50 Hz */
#define TPM_MOD_PWM_PERIOD_20ms  (60000u)
/*------------------------------------------------------------------*/
/* TPMx_CnSC:  Channel n Status and Control                         */
/* 0-->31-8:(reserved):read-only:0                                  */
/* 0-->   7:CHF=channel flag                                        */
/*              set on channel event                                */
/*              write 1 to clear                                    */
/* 0-->   6:CHIE=channel interrupt enable                           */
/* 1-->   5:MSB=channel mode select B (see selection table below)   */
/* 0-->   4:MSA=channel mode select A (see selection table below)   */
/* 1-->   3:ELSB=edge or level select B (see selection table below) */
/* 0-->   2:ELSA=edge or level select A (see selection table below) */
/* 0-->   1:(reserved):read-only:0                                  */
/* 0-->   0:DMA=DMA enable                                          */
#define TPM_CnSC_PWMH (TPM_CnSC_MSB_MASK | TPM_CnSC_ELSB_MASK)
/*--------------------------------------------------------*/
/* TPMx_CnV:  Channel n Value                             */
/* 31-16:(reserved):read-only:0                           */
/* 15- 0:MOD (all bytes must be written at the same time) */
/*--------------------------------------------------------------*/
/* TPMx_SC:  Status and Control                                 */
/*    -->31-9:(reserved):read-only:0                            */
/*   0-->   8:DMA=DMA enable                                    */
/*    -->   7:TOF=timer overflow flag                           */
/*   0-->   6:TOIE=timer overflow interrupt enable              */
/*   0-->   5:CPWMS=center-aligned PWM select (edge align)      */
/*  01--> 4-3:CMOD=clock mode selection (count each TPMx clock) */
/* 100--> 2-0:PS=prescale factor selection                      */
/*    -->        can be written only when counter is disabled   */

#define TPM_SC_CLK_DIV16 ((TPM_SC_CMOD_CLK << TPM_SC_CMOD_SHIFT) | \
                          TPM_SC_PS_DIV16)
#define TPM_CnV_PWM_DUTY_2ms (6000u)
#define TPM_CnV_PWM_DUTY_1ms (3000u)
/*- -----*/

/* VGA */
//set TPMx to reset counter on TPM1 ovf
#define TPM_CONF_TRG_TPM1 (0x09040000u)

//Prescaler values for sync signals
#define TPM_SC_PS_VSYNC  (0x4u)
#define TPM_SC_PS_HSYNC  (0x0u)

//Wave periods (# of CCR clocks) for sync signals
#define TPM_MOD_PWM_PERIOD_VSYNC (50049u)
#define TPM_MOD_PWM_PERIOD_HSYNC (1525u)

//Duty time (# of CCR clocks) for sync signals
#define TPM_CNT_PWM_PERIOD_VSYNC (954u)
#define TPM_CNT_PWM_PERIOD_HSYNC (183u)

//Status & control (prescaling
#define TPM_SC_CMOD_CLK (1u)
#define TPM_SC_PS_DIV16 (0x4u)

#define TPM_SC_HSYNC    (~TPM_SC_CPWMS_MASK | TPM_SC_TOIE_MASK | \
                         (01 << TPM_SC_CMOD_SHIFT) | TPM_SC_PS_HSYNC)

#define TPM_SC_VSYNC    (~TPM_SC_CPWMS_MASK | ~TPM_SC_TOIE_MASK | \
                         (01 << TPM_SC_CMOD_SHIFT) | TPM_SC_PS_VSYNC)



#define PTE31_MUX_TPM0_CH4_OUT (3u << PORT_PCR_MUX_SHIFT)
#define SET_PTE31_TPM0_CH4_OUT (PORT_PCR_ISF_MASK | \
                                PTE31_MUX_TPM0_CH4_OUT)

#define PTA13_MUX_TPM1_CH0_OUT (3u << PORT_PCR_MUX_SHIFT)
#define SET_PTA13_TPM1_CH0_OUT (PORT_PCR_ISF_MASK | \
                                PTA13_MUX_TPM1_CH0_OUT)


#define TPM_CnSC_VSYNC (TPM_CnSC_MSB_MASK | (~TPM_CnSC_MSA_MASK) \
                        TPM_CnSC_ELSB_MASK | TPM_CnSC_ELSA_MASK | \
                        TPM_CnSC_CHIE_MASK)
#define TPM_CnSC_HSYNC (TPM_CnSC_MSB_MASK | (~TPM_CnSC_MSA_MASK) \
                        TPM_CnSC_ELSB_MASK | TPM_CnSC_ELSA_MASK | \
                        (~TPM_CnSC_CHIE_MASK))

#endif

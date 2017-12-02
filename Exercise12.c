/*********************************************************************/
/* <Your program description here>                                   */
/* Name:  <Your name here>                                           */
/* Date:  <Date completed>                                           */
/* Class:  CMPE 250                                                  */
/* Section:  <Your section here>                                     */
/*-------------------------------------------------------------------*/
/* Template:  R. W. Melton                                           */
/*            November 3, 2017                                       */
/*********************************************************************/
#include "Exercise12.h"
int main (void) {
  __asm("CPSID   I");  /* mask interrupts */
  /* Perform all device initialization here */
  /* Before unmasking interrupts            */
  init_tpm0();
  __asm("CPSIE   I");  /* unmask interrupts */
  

  for (;;) { 
  } 

} /* main */

void init_dac0()    {
    SIM->SCGC6           |= SIM_SCGC6_DAC0_MASK;
    SIM->SCGC5           |= SIM_SCGC5_PORTE_MASK;
    PORTE->PCR[30]        = SET_PTE30_DAC0_OUT;     //ALT1
    DAC0->C1              = DAC_C1_BUFFER_DISABLED;
    DAC0->C0              = DAC_C0_ENABLE;
    DAC0->DAT[0].DATL     = DAC_DATL_0V;
    DAC0->DAT[0].DATH     = DAC_DATH_0V;

}


void init_tpm0()    {
    //Clock TPM0
    SIM->SCGC6             |= SIM_SCGC6_TPM0_MASK;
    SIM->SCGC6             |= SIM_SCGC6_TPM0_MASK;

    //Configure outputs
    SIM->SCGC5             |= SIM_SCGC5_PORTE_MASK;
    SIM->SCGC5             |= SIM_SCGC5_PORTA_MASK;

    PORTE->PCR[31]          = SET_PTE31_TPM0_CH4_OUT;
    PORTA->PCR[13]          = SET_PTA13_TPM1_CH0_OUT;

    //Select 48 MHz clock for TPM
    SIM->SOPT2             &= ~SIM_SOPT2_TPMSRC_MASK;
    SIM->SOPT2             |= SIM_SOPT2_TPM_MCGPLLCLK_DIV2;
    
    //Configure TPM0_CH4 (HSync)
    TPM0->CONF              = TPM_CONF_TRG_TPM1;
    TPM0->CNT               = TPM_CNT_INIT;
    TPM0->MOD               = TPM_MOD_PWM_PERIOD_20ms;

    TPM0->CONTROLS[4].CnSC  = TPM_CnSC_PWMH;
    TPM0->CONTROLS[4].CnV   = TPM_CnV_PWM_DUTY_2ms;
    TPM0->SC                = TPM_SC_CLK_DIV16;


}


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
#include "Exercise11.h"
#define print(x) PutStringSB(x, sizeof(x))
#define scan (x, s) GetStringSB(x, s)
#define isnum(x)    ((x >= '0') && (x <= '9'))
int main (void) {
  uint8_t scan_buf[80];
  __asm("CPSID   I");  /* mask interrupts */
  /* Perform all device initialization here */
  /* Before unmasking interrupts            */
  init_rxtx();
  init_dac0();
  init_tpm0();
  __asm("CPSIE   I");  /* unmask interrupts */
  

  for (;;) { 
    TPM0->CONTROLS[4].CnV;
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
    //Config PORTE
    SIM->SCGC5             |= SIM_SCGC5_PORTE_MASK;
    PORTE->PCR[31]          = SET_PTE31_TPM0_CH4_OUT;
    PORTE->PCR[30]          = SET_PTE30_TPM0_CH3_OUT;
    SIM->SOPT2             &= ~SIM_SOPT2_TPMSRC_MASK;
    SIM->SOPT2             |= SIM_SOPT2_TPM_MCGPLLCLK_DIV2;
    TPM0->CONF              = TPM_CONF_DEFAULT;
    TPM0->CNT               = TPM_CNT_INIT;
    TPM0->MOD               = TPM_MOD_PWM_PERIOD_20ms;

    TPM0->CONTROLS[4].CnSC  = TPM_CnSC_PWMH;
    TPM0->CONTROLS[4].CnV   = TPM_CnV_PWM_DUTY_2ms;
    TPM0->SC                = TPM_SC_CLK_DIV16;

}

uint32_t atoi(char *s)  {
  uint32_t res = 0;
  char *ptr = s;
  int  count;
  for(count = 0; isnum(*(ptr++)); count++);   //a Melton-level loop
  //for(int mul = 1; 
  return res;
}

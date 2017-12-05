#include "Startup.h"

void init_dac0()    {
    SIM->SCGC6           |= SIM_SCGC6_DAC0_MASK;
    SIM->SCGC5           |= SIM_SCGC5_PORTE_MASK;
    PORTE->PCR[30]        = SET_PTE30_DAC0_OUT;     //ALT1
    DAC0->C1              = DAC_C1_BUFFER_DISABLED;
    DAC0->C0              = DAC_C0_ENABLE;
    DAC0->DAT[0].DATL     = DAC_DATL_0V;
    DAC0->DAT[0].DATH     = DAC_DATH_0V;

}

/**
* Initialize TPM 0, TPM 1 to output HSync and VSync.
*/
void init_sync_signals()    {
    //Clock TPM0
    SIM->SCGC6             |= SIM_SCGC6_TPM0_MASK;
    SIM->SCGC6             |= SIM_SCGC6_TPM1_MASK;

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
    TPM0->MOD               = TPM_MOD_PWM_PERIOD_HSYNC;

    TPM0->CONTROLS[4].CnSC  = TPM_CnSC_HSYNC;
    TPM0->CONTROLS[4].CnV   = TPM_CNT_PWM_PERIOD_HSYNC;
    TPM0->SC                = TPM_SC_HSYNC;

    //Configure TPM1_CH0 (VSync)
    TPM1->CONF              = TPM_CONF_DEFAULT;
    TPM1->CNT               = TPM_CNT_INIT;
    TPM1->MOD               = TPM_MOD_PWM_PERIOD_VSYNC;

    TPM1->CONTROLS[1].CnSC  = TPM_CnSC_VSYNC; 
    TPM1->CONTROLS[1].CnV   = TPM_CNT_PWM_PERIOD_VSYNC;
    TPM1->SC                = TPM_SC_VSYNC;


}

void init_pit_hblank()  {
    __asm("cpsid    i");
    SIM->SCGC6             |= SIM_SCGC6_PIT_MASK;
    
    PIT->MCR                = PIT_MCR_MDIS_MASK | PIT_MCR_FRZ_MASK;

    NVIC->ICPR[0]          |= (0 << 22);   //clear pending IRQ
    NVIC->IP[5]            |= (3 << 22);   //see TRM
    NVIC->ISER[0]          |= (1 << 22);    //enable this IRQ 
    
    PIT->CHANNEL[0].LDVAL   = PIT_LDVAL_HBLANK;
    PIT->CHANNEL[0].TCTRL  |= PIT_TCTRL_TIE_MASK | (0 << PIT_TCTRL_TEN_SHIFT); //disable pit
    PIT->CHANNEL[0].TFLG   |= PIT_TFLG_TIF_MASK; //w1c
    PIT->MCR                = PIT_MCR_FRZ_MASK;
    __asm("cpsie    i");
    bp_poll();

}

/**
*	Initialize gpio ports for color output
*/
void init_gpio(){
		// Enable clock for Port E
		SIM->SCGC5 						 |= SIM_SCGC5_PORTE_MASK;
	
		// Configure Pin Connections (16-23)
		PORTE->PCR[16]			    = SET_PTE_16TO23_GPIO;
		PORTE->PCR[17]			    = SET_PTE_16TO23_GPIO;
		PORTE->PCR[18]			    = SET_PTE_16TO23_GPIO;
		PORTE->PCR[19]			    = SET_PTE_16TO23_GPIO;
		PORTE->PCR[20]			    = SET_PTE_16TO23_GPIO;
		PORTE->PCR[21]			    = SET_PTE_16TO23_GPIO;
		PORTE->PCR[22]			    = SET_PTE_16TO23_GPIO;
		PORTE->PCR[23]			    = SET_PTE_16TO23_GPIO;
		
		// Data Direction (16-23)
		FPTE->PDDR							= COLOR_PORTE_MASK;
	
		// Initialize outputs to zero
		FPTE->PDOR = 0;
}



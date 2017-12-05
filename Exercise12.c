#include "Constants.h"
#include "Exercise12.h"
#include "Startup.h"
/**
 * Main Program.
 * Initializes the system for VGA video output.
 * Prequisites: CMSIS startup completed, 48MHz Core clock.
 */


//global vars
color screen_color;

extern uint16_t line_ctr;

int main (void) {
    line_ctr = 0;	
    __asm("CPSID   I");
    init_sync_signals();
    //init_tpm2_hblank();
	init_gpio();
    __asm("CPSIE   I");
    //init_pit_hblank();  //after CPSIE due to manual manipulation
		//16 to 23
		FPTE->PDOR = 0x00400000;

    screen_color.r = 7;
    screen_color.g = 7;
    screen_color.b = 3;
    
loop:
		//bp_poll();
		//fp_poll();
    goto loop;
}


//#pragma interrupt_handler pit_isr //gcc

// void hblank_isr(void) __irq {
//     TPM2->STATUS = 0xFFFFFFFF; 
//     FPTE->PDOR = 0xFFFFFFFF;
// 		__asm("cpsid i");
//     FPTE->PDOR = 0x00000000;
// 		__asm("cpsie i");
// 
// }
// 
// void pit_isr(void)  __irq {
//     FPTE->PDOR = 0x00FF0000;
//     PIT->CHANNEL[0].TFLG = PIT_TFLG_TIF_MASK; 
//     FPTE->PDOR = 0x00000000;
// }

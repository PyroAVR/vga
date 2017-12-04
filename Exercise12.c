#include "Constants.h"
#include "Exercise12.h"
#include "Startup.h"
/**
 * Main Program.
 * Initializes the system for VGA video output.
 * Prequisites: CMSIS startup completed, 48MHz Core clock.
 */

int main (void) {
    __asm("CPSID   I");
    init_sync_signals();
		init_gpio();
		
    __asm("CPSIE   I");
		//16 to 23
		//FPTE->PDOR = 0x00450000;

	
    
loop:
		//bp_poll();
		fp_poll();
    goto loop;
}


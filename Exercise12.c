#include "Constants.h"
/**
 * Main Program.
 * Initializes the system for VGA video output.
 * Prequisites: CMSIS startup completed, 48MHz Core clock.
 */

int main (void) {
    __asm("CPSID   I");
    init_tpm0();
    __asm("CPSIE   I");

loop:


    goto loop;
}


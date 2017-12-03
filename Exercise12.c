#include "Constants.h"
#include "Startup.h"
/**
 * Main Program.
 * Initializes the system for VGA video output.
 * Prequisites: CMSIS startup completed, 48MHz Core clock.
 */

int main (void) {
    __asm("CPSID   I");
    init_sync_signals();
    __asm("CPSIE   I");

loop:


    goto loop;
}


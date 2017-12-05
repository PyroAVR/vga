#include "Constants.h"
#include "Exercise12.h"
#ifndef __STARTUP_H__
#define __STARTUP_H__
/* C function declarations */
														
//parameterize these
//void init_dac0(void);
void init_sync_signals(void);
void init_gpio(void);
void init_pit_hblank(void);
void init_tpm2_hblank(void);
#endif

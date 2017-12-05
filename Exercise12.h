#ifndef __EXERCISE12_H__
#define __EXERCISE12_H__
void wait(void);
void fp_poll(void);
void bp_poll(void);

void pit_isr(void) __irq ;
void hblank_isr(void) __irq ;
#endif

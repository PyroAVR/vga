#ifndef __EXERCISE12_H__
#define __EXERCISE12_H__
void wait(uint32_t time);
void fp_poll(void);
void bp_poll(void);

void pit_isr(void) __irq ;
void hblank_isr(void) __irq ;


typedef struct  {
    int r:3;
    int g:3;
    int b:2;
} color;
#endif

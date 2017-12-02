            TTL Program Title for Listing Header Goes Here
;****************************************************************
;Descriptive comment header goes here.
;(What does the program do?)
;Name:  <Your name here>
;Date:  <Date completed here>
;Class:  CMPE-250
;Section:  <Your lab section, day, and time here>
;---------------------------------------------------------------
;Keil Template for KL46 Assembly with Keil C startup
;R. W. Melton
;November 13, 2017
;****************************************************************
;Assembler directives
            THUMB
            GBLL  MIXED_ASM_C
MIXED_ASM_C SETL  {TRUE}
            OPT   64  ;Turn on listing macro expansions
;****************************************************************
;Include files
            GET  MKL46Z4.s     ;Included by start.s
            OPT  1   ;Turn on listing
;****************************************************************
;EQUates
TPM_CnV_PWM_DUTY_2ms    equ 6000
TPM_CnV_PWM_DUTY_1ms    equ 2200
pwm_2ms     equ     TPM_CnV_PWM_DUTY_2ms
pwm_1ms     equ     TPM_CnV_PWM_DUTY_1ms
dac0_steps  equ     4096    ;guessing!
servo_positions\
            equ     5
;****************************************************************
;MACROs
;****************************************************************
            import  InitQueue
            import  init_uart0
            export  TxQueue
            export  RxQueue
            export  dac0_table_0
            export  pwm_duty_table_0
            export  init_rxtx
;Program
;C source will contain main ()
;Only subroutines and ISRs in this assembly source
            AREA    MyCode,CODE,READONLY
;>>>>> begin subroutine code <<<<<
init_rxtx   proc    {r0-r14}, {}
            push {r0-r2, lr}
            ldr  r2, =500
            ldr  r1, =TxQueue
            ldr  r0, =txq
            bl   InitQueue
            ldr  r1, =RxQueue
            ldr  r0, =rxq 
            bl   InitQueue
            bl   init_uart0
            pop  {r0-r2, pc}
            endp


;>>>>>   end subroutine code <<<<<
            ALIGN
;**********************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;>>>>> begin constants here <<<<<
dac0_table_0
dac0_table
            dcw (((dac0_steps - 1) * 1) / (servo_positions * 2))
            dcw (((dac0_steps - 1) * 3) / (servo_positions * 2))
            dcw (((dac0_steps - 1) * 5) / (servo_positions * 2))
            dcw (((dac0_steps - 1) * 7) / (servo_positions * 2))
            dcw (((dac0_steps - 1) * 9) / (servo_positions * 2))

pwm_duty_table_0
pwm_duty_table
            dcw pwm_2ms
            dcw ((3*(pwm_2ms-pwm_1ms)/4) + pwm_1ms)
            dcw (((pwm_2ms-pwm_1ms)/2) + pwm_1ms)
            dcw (((pwm_2ms-pwm_1ms)/4) + pwm_1ms)
            dcw pwm_1ms

;>>>>>   end constants here <<<<<
;**********************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
;>>>>> begin variables here <<<<<
TxQueue     space   18
            align
RxQueue     space   18
            align
txq         space   500
rxq         space   500
            align
;>>>>>   end variables here <<<<<
            END

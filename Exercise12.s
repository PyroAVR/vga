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
            export wait
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
            
;Program
;C source will contain main ()
;Only subroutines and ISRs in this assembly source
            AREA    MyCode,CODE,READONLY
;>>>>> begin subroutine code <<<<<
wait        proc {r0-r14}, {}
            push {r0, lr}
            movs r0, #00
waitloop    cmp r0, #0
            beq waitdone
            subs r0, r0, #1
            b    waitloop
waitdone    pop  {r0, pc}
            endp
;>>>>>   end subroutine code <<<<<
            ALIGN
;**********************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;>>>>> begin constants here <<<<<
;>>>>>   end constants here <<<<<
;**********************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
;>>>>> begin variables here <<<<<
;>>>>>   end variables here <<<<<
            END

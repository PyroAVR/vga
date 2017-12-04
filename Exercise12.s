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
			export bp_poll
			export fp_poll
;****************************************************************
;EQUates
TPM_CnV_PWM_DUTY_2ms    equ 6000
TPM_CnV_PWM_DUTY_1ms    equ 2200
pwm_2ms     equ     TPM_CnV_PWM_DUTY_2ms
pwm_1ms     equ     TPM_CnV_PWM_DUTY_1ms
dac0_steps  equ     4096    ;guessing!
servo_positions\
            equ     5
				
frontporch	equ		1481	; 1494 (1525 - 30) but polling is slow :(
backporch	equ 	253		; 275
;****************************************************************
;MACROs
;****************************************************************
            
;Program
;C source will contain main ()
;Only subroutines and ISRs in this assembly source
            AREA    MyCode,CODE,READONLY
;>>>>> begin subroutine code <<<<<
;============================================================
;Name		: wait
;Description: Waits for specified time
;============================================================
wait        proc {r0-r14}, {}
            push {r0, lr}
            movs r0, #80
waitloop    cmp r0, #0
            beq waitdone
            subs r0, r0, #1
            b    waitloop
waitdone    pop  {r0, pc}
            endp

;============================================================
;Name		: fp_poll
;Description: polls for the front porch CCR time
;============================================================
fp_poll		proc 	{r0-r14}, {}
			cpsid	i
			push 	{r0-r3, lr}
			movs	r2, #0xFF
			lsls	r2, r2, #16
			
			ldr		r0, =TPM0_BASE
			ldr		r3, =frontporch			
notfp		ldr		r1, [r0, #TPM_CNT_OFFSET]
			cmp		r1, r3
			blo		notfp
			ldr		r0, =FGPIOE_PDOR
			ldr		r1, [r0, #0]
			orrs	r1, r1, r2
			str		r1, [r0, #0]
			
			bl		wait
			
			bics	r1, r1, r2
			str		r1, [r0, #0]
			cpsie	i
			pop		{r0-r3, pc}
			endp
				
;============================================================
;Name		: bp_poll
;Description: polls for the back porch CCR time
;============================================================
bp_poll		proc 	{r0-r14}, {}
			cpsid	i
			push 	{r0-r3, lr}
			movs	r2, #0xFF
			lsls	r2, r2, #16
			
			ldr		r0, =TPM0_BASE
notbp		ldr		r1, [r0, #TPM_CNT_OFFSET]
			ldr 	r3, =backporch
			cmp		r1, r3
			blo		notbp
			adds	r3, r3, #128
			cmp 	r1, r3
			bhi		notbp
			
			ldr		r0, =FGPIOE_PDOR
			ldr		r1, [r0, #0]
			orrs	r1, r1, r2
			str		r1, [r0, #0]
			
			bl		wait
			
			bics	r1, r1, r2
			str		r1, [r0, #0]
			cpsie	i
			pop		{r0-r3, pc}
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

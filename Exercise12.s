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
            export line_isr
;****************************************************************
;EQUates
				
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
			push 	{r0-r7, lr}
			ldr     r7, =PIT_CH0_BASE
            ldr     r6, =(PIT_TCTRL_TEN_MASK :OR: PIT_TCTRL_TIE_MASK)
			
			ldr		r0, =TPM0_BASE
notbp		ldr		r1, [r0, #TPM_CNT_OFFSET]
			ldr 	r3, =backporch
			cmp		r1, r3
			blo		notbp
			adds	r3, r3, #128
			cmp 	r1, r3
			bhi		notbp
			
            str     r6, [r7, #PIT_TCTRL_OFFSET]
			cpsie	i
			pop		{r0-r7, pc}
			endp

line_isr    proc{r0-r14}, {}
            push {lr}
            
            pop  {pc}
            endp



; init_pit        proc    {r0-r14}, {}
; ; Initialize PIT for 0.01 s interrupt
; ; inputs             : none
; ; outputs            : none
; ; modified registers : none
;             ;why is the pit so weird
;             push {r0-r3, lr}
;             ; clock PIT
;             ldr  r0, =SIM_SCGC6
;             ldr  r1, =SIM_SCGC6_PIT_MASK
;             ldr  r2, [r0, #0]           ;current scgc
;             orrs r2, r2, r1
;             str  r2, [r0, #0]           ;read-modify-write
;             ;Disable PIT timer 0??
;             
;             ; Set priority
;             ldr  r0, =PIT_IPR
;             movs r1, #3					;couldn't find the NVIC_IPR_PIT_MASK def.
; 			lsls r1, r1, #22			;using formula from sub-family ref.
;             ldr  r2, [r0, #0]           
;             bics r2, r2, r1				;0 -> highest priority
;             str  r2, [r0, #0]
;             ;PIT Module Control Register setup
;             ldr  r0, =PIT_BASE
;             ldr  r1, =PIT_MCR_EN_FRZ
;             str  r1, [r0, #PIT_MCR_OFFSET]
;             ;PIT load value
;             ldr  r0, =PIT_CH0_BASE
; ;            ldr  r1, =PIT_LDVAL_HBLANK
;             str  r1, [r0, #PIT_LDVAL_OFFSET]
;             ;PIT ch0 send interrupts
;             movs r1, #PIT_TCTRL_CH_IE
;             str  r1, [r0, #PIT_TCTRL_OFFSET]
;             ; NVIC setup
;             ldr  r0, =NVIC_ISER
;             ldr  r1, =PIT_IRQ_MASK
;             str  r1, [r0, #0]           ;unmask irq for pit
;             ; Clear PIT Channel 0 interrupt
;             ldr  r0, =PIT_CH0_BASE
;             ldr  r1, =PIT_TFLG_TIF_MASK
;             str  r1, [r0, #PIT_TFLG_OFFSET]
; 
;             pop  {r0-r3, pc}
;             endp


; pit_isr     proc   {r0-r14} 
;             cpsid i
; 			ldr r0, =RunStopWatch
;             cmp r0, #0
;             beq pit_done
;             ldr r0, =time_counter
;             ldr r1, [r0, #0]
;             adds r1, r1, #1
;             str r1, [r0, #0]
; 
; pit_done    ldr r0, =NVIC_ISER
; 			;clear interrupts or something
; 			ldr  r0, =PIT_CH0_BASE
;             ldr  r1, =PIT_TFLG_TIF_MASK
;             str  r1, [r0, #PIT_TFLG_OFFSET]
; 			;return
; 			cpsie i
;             bx  lr
; 			endp
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

            TTL uart0_driver.s
;****************************************************************
; Serial driver on uart0
; interrupt service routine, specifically
;****************************************************************
            THUMB
            OPT    64  ;Turn on listing macro expansions
            GET    ../Constants.s
            ;Include files
            GET  ../MKL46Z4.s     ;Included by start.s
            OPT  1   ;Turn on listing
;****************************************************************
;EQUates:

;****************************************************************
            AREA    text,CODE,READONLY
            IMPORT  divu
            EXPORT  init_uart0
            EXPORT  putchar
            EXPORT  getchar
            EXPORT  uart0_isr
            IMPORT  TxQueue
            IMPORT  RxQueue         ;queue symbols
            IMPORT  Enqueue
            IMPORT  Dequeue

init_uart0  proc    {r0-r14}, {}
; Initialize UART0 for interrupt I/O
; note: queue structures MUST be initiallized BEFORE calling this method!
; inputs             : none
; outputs            : none
; modified register  : none
            push {r0-r2, lr}
            ;set clock speeds
            ldr  r0, =SIM_SOPT2
            ldr  r1, =SIM_SOPT2_UART0SRC_MASK
            ldr  r2, [r0, #0]               ;pull current values
            bics r2, r2, r1                 ;clear w/ mask
            ldr  r1, =SIM_SOPT2_UART0_MCGPLLCLK_DIV2    ;get pll bits
            orrs r2, r2, r1                 ;or new state in
            str  r2, [r0, #0]               ;push new options
            ;clear UART0 flags
            ldr  r0, =SIM_SOPT5             ;get base addr
            ldr  r1, =SIM_SOPT5_UART0_EXTERN_MASK_CLEAR ;get mask
            ldr  r2, [r0, #0]               ;get current values
            bics r2, r2, r1                 ;clear only uart0 bits
            str  r2, [r0, #0]               ;store cleared values
            ;pass clock to uart0
            ldr  r0, =SIM_SCGC4             ;get base addr
            ldr  r1, =SIM_SCGC4_UART0_MASK  ;mask
            ldr  r2, [r0, #0]               ;get value
            orrs r2, r2, r1                 ;apply mask
            str  r2, [r0, #0]                ;push
            ;enable portA clock
            ldr  r0, =SIM_SCGC5              ;get base addr
            ldr  r1, =SIM_SCGC5_PORTA_MASK   ;get mask
            ldr  r2, [r0, #0]                ;get current value
            orrs r2, r2, r1                  ;apply mask
            str  r2, [r0, #0]                ;p u s h
            ;set rx and tx pins
            ldr  r0, =PORTA_PCR1             ;get address
            ldr  r1, =PORT_PCR_SET_PTA1_UART0_RX ;get mask
            str  r1, [r0, #0]                ;load current value
            ldr  r0, =PORTA_PCR2             ;get address
            ldr  r1, =PORT_PCR_SET_PTA2_UART0_TX ;get bitval to set
            str  r1, [r0, #0]                ;push value
            ;disable uart0 rxtx
            ldr  r0, =UART0_BASE            ;load base addr
            movs r1, #UART0_C2_T_R          ;get mask
            ldrb r2, [r0, #UART0_C2_OFFSET] ;load current c2 value
            bics r2, r2, r1                 ;apply mask w/clear
            strb r2, [r0, #UART0_C2_OFFSET] ;set changes
            ;NVIC SETUP
			;set UART0 priority
            ldr  r0, =UART0_IPR
            ldr  r2, =NVIC_IPR_UART0_PRI_3
            ldrb r3, [r0, #0]               ;load UART0 Interrupt Something Register
            orrs r3, r3, r2
            str  r3, [r0, #0]               ;set bits, blah
            ;clear interrupts for uart0
            ldr  r0, =NVIC_ICPR
            ldr  r1, =NVIC_ICPR_UART0_MASK  ;uhhh
            str  r1, [r0, #0]               ;I guess we're doing a w1c
            ;unmask uart0 (only!)
            ldr  r0, =NVIC_ISER
            ldr  r1, =NVIC_ISER_UART0_MASK
            str  r1, [r0, #0]
            ;BACK TO UART0 SETUP
            ldr  r0, =UART0_BASE            ;load base addr
            ;Set 9600 baud rate
            movs r1, #UART0_BDH_9600        ;get high byte
            strb r1, [r0, #UART0_BDH_OFFSET];send to control point
            movs r1, #UART0_BDL_9600        ;get low byte
            strb r1, [r0, #UART0_BDL_OFFSET]
            ;set 8n1 config
            movs r1, #UART0_C1_8N1          ;get 8n1 mask
            strb r1, [r0, #UART0_C1_OFFSET] ;store to control point
            ;set no txinv
            movs r1, #UART0_C3_NO_TXINV     ;get notxinv mask
            strb r1, [r0, #UART0_C3_OFFSET] ;store to control point
            ;something something OSR
            movs r1, #UART0_C4_NO_MATCH_OSR_16  ;get mask
            strb r1, [r0, #UART0_C4_OFFSET]     ;store to control point
            ;disable DMA
            movs r1, #UART0_C5_NO_DMA_SSR_SYNC  ;get mask
            strb r1, [r0, #UART0_C5_OFFSET]
            ;clear flags
            movs r1, #UART0_S1_CLEAR_FLAGS      ;get mask (likely all 1)
            strb r1, [r0, #UART0_S1_OFFSET]     ;push to status register
            ;set no rxinv
            movs r1, #UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS  ;WHY?!
            strb r1, [r0, #UART0_S2_OFFSET]
            ;enable IO rxirq
            ldr  r0, =UART0_C2
            movs r1, #UART0_C2_T_RI
            strb r1, [r0, #0]
            ;screaming.  there is only screaming.
            pop {r0-r2, pc}
            endp

putchar     proc {r1-r14}, {}
; put char from r0 onto the TxQueue
; inputs             : r0: char
; outputs            : none
; modified registers : none
            push {r1,r2, lr}
            ldr  r1, =TxQueue
pc_loop     cpsid i
            bl   Enqueue
            cpsie i
            bcs  pc_loop
            ldr  r1, =UART0_C2
            ;enable interrupt
            movs r2, #UART0_C2_TI_RI
            strb r2, [r1, #0]
            pop  {r1,r2, pc}
            endp

getchar     proc {r1-r14}, {}
; place on r0 a char from the RxQueue
; inputs             : none
; outputs            : r0: char
; modified registers : r0
            push {r1, lr}
			ldr  r1, =RxQueue
gc_loop     cpsid i
            bl   Dequeue
            cpsie i
            bcs  gc_loop
            pop  {r1, pc}
            endp

uart0_isr   proc {r0-r14}, {}
; interrupt service routine for uart0.  handles rx and tx requests.
; inputs             : none
; outputs            : none
; modified registers : none
			push {lr}
            cpsid i         ;mask interrupts
            ldr  r0, =UART0_C2
            ldr  r1, =UART0_C2_TIE_MASK
            ldrb r2, [r0, #0]
            ands r2, r2, r1
            cmp  r2, #0
            beq  not_tx
            ldr  r0, =UART0_S1
            ldr  r1, =UART0_S1_TDRE_MASK
            ldr  r2, [r0, #0]
            ands r2, r2, r1
            cmp  r2, #0
            beq  not_tx
            ;at this point, the interrupt is enabled and active
            ldr  r1, =TxQueue
            bl   Dequeue
			bcs  clear_txirq
            ;write to uart
            ldr  r1, =UART0_D
            strb r0, [r1, #0]
            b    isr_done

clear_txirq 
            ldr  r0, =UART0_C2
            movs r1, #UART0_C2_T_RI
            strb r1, [r0, #0]
            b    isr_done

not_tx      ldr  r0, =UART0_BASE
            movs r1, #UART0_S1_RDRF_MASK
            ldrb r2, [r0, #UART0_S1_OFFSET]
            ands r2, r2, r1
            ;cmp  r2, #0
            beq  isr_done
            ldr  r0, =UART0_BASE
            ldrb r0, [r0, #UART0_D_OFFSET]
            ldr  r1, =RxQueue
            bl   Enqueue

isr_done    cpsie i
			pop  {pc}
            endp
            end

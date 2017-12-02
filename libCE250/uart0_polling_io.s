            TTL uart0_polling_io
;****************************************************************
; Commonly used functions for CMPE-250, Assembly Language Programming
; Polling I/O operations for UART0
; Author(s): Andy Meyer
; REQUIREMENTS:
;  Imports Constants.s and MKL46Z4.s for hardware specific address macros
;Assembler directives
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
            EXPORT  getchar
            EXPORT  putchar

init_uart0  proc {r0-r14},{}
; Initialize UART 0 for POLLING
; inputs             : null
; calls              : none
; outputs            : null
; modified registers : none
; wow, this sure is a ton of setup
            push{r0-r2}
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
            ;finally, enable UART0
            movs r1, #UART0_C2_T_R          ;load enable mask
            strb r1, [r0, #UART0_C2_OFFSET]
            pop{r0-r2}
            bx   lr
            endp

getchar     proc {r1-r14},{}
; Get a character from uart0
; inputs             : null
; outputs            : char received, on r0
; modified registers : r0
            push {r1-r3, lr}
            ldr  r1, =UART0_BASE            ;base addr of uart0
            movs r3, #UART0_S1_RDRF_MASK    ;ready-to-read bit
gc_loop     ldrb r2, [r1, #UART0_S1_OFFSET] ;read byte (bit, really)
            ands r2, r2, r3                 ;status = mask?
            beq  gc_loop                    ;loop if not ready
            ldrb r0, [r1, #UART0_D_OFFSET]  ;read char into r0
            pop  {r1-r3, pc}
            endp

putchar     proc {r0-r14},{}
; Send a chararcter to uart0
; inputs             : char to send, on r0
; calls              : none
; outputs            : none
; modified registers : none
            push {r1-r3, lr}
            ldr  r1, =UART0_BASE            ;base addr of uart0
            movs r3, #UART0_S1_TDRE_MASK    ;ready-to-write bit
pc_loop     ldrb r2, [r1, #UART0_S1_OFFSET] ;read byte (bit, really)
            ands r2, r2, r3                 ;status = mask?
            beq  pc_loop                    ;loop if not ready
            strb r0, [r1, #UART0_D_OFFSET]  ;read char into r0
            pop  {r1-r3, pc}
            endp
			end

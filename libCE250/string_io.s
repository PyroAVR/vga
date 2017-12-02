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
            IMPORT  putchar
            IMPORT  getchar
            EXPORT  GetStringSB
            EXPORT  PutStringSB
GetStringSB proc {r0-r14}, {}
; Get a string from uart0 with a limited length (strncpy)
; inputs             : read into address in r0, max length in r1
; calls              : getchar
; outputs            : string read in *r0
; modified registers : none
            push {r0-r2, lr}                   ;INCL. R3 W/ESC CODES
            movs r2, r0         ;getchar returns on r0, need to move address
            adds r1, r1, r2     ;r1 points to end addr of string (no counter)
gsb_loop    
            bl   getchar
            ;if the buffer is full, don't print anything
            cmp  r1, r2
            bls  no_echo
            bl   putchar
            b    buf_ok
no_echo		subs r2, r2, #1
            ; check for control chars
buf_ok
            ; if there's a delete left on r0, decrement r2
            cmp  r0, #DEL
            bne  not_del
            subs r2, r2, #1
            b    gsb_loop
not_del		cmp  r0, #CR        ;early termination on enter
            beq  gsb_done
            cmp  r0, #0x1F
            bls  gsb_loop
            strb r0, [r2, #0]
            adds r2, r2, #1     ;increment r2 to point to next char
            b    gsb_loop
            
gsb_done
            movs r0, #CR
            bl   putchar
            movs r0, #LF
            bl   putchar
            movs r0, #0
            strb r0, [r2, #0]   ;null terminator
            pop  {r0-r2, pc}
            endp


PutStringSB proc {r0-r14}, {}
; write a string to uart0 with a limited length (strncpy)
; inputs             : read address in r0, max length in r1
; calls              : putchar
; outputs            : none
; modified registers : none
            push {r0-r2, lr}
            movs r2, r0     ;putchar expects input on r0, need to move address
            adds r1, r1, r2 ;r1 points to end of string (avoiding counter again)
psb_loop    cmp  r1, r2
            beq  psb_done
            ldrb r0, [r2, #0]
            cmp  r0, #0     ;if next char is null, exit
            beq  psb_done
            bl   putchar
            adds r2, r2, #1 ;increment r2 to point to next char
            b    psb_loop
psb_done
            pop  {r0-r2, pc}
            endp
            end

            TTL libCE250
;****************************************************************
; Commonly used functions for CMPE-250, Assembly Language Programming
; Author(s): Andy Meyer
; REQUIREMENTS:
;  Imports Constants.s and MKL46Z4.s for hardware specific address macros
;Assembler directives
            THUMB
            OPT    64  ;Turn on listing macro expansions
            GET    Constants.s
;Include files
            GET  MKL46Z4.s     ;Included by start.s
            OPT  1   ;Turn on listing
;****************************************************************
;EQUates:

;****************************************************************
            AREA    text,CODE,READONLY
            IMPORT  init_uart0
            IMPORT  getchar
            IMPORT  putchar
            IMPORT  GetStringSB
            IMPORT  PutStringSB
            EXPORT  divu
            EXPORT  PutNumU
            EXPORT  PutNumUB
            EXPORT  PutNumHex
            export  GetHexMulti
            export  strlen
            export  PutHexMulti
            export  validhex
            export  hex2nib
            export  hex2byte
            export  toUpper


;>>>>> begin subroutine code <<<<<
PutNumUB    proc    {r1-r14}, {}
; Write a byte value to uart0 in ascii format
; inputs             : r0: number to encode and write
; outputs            : none
; modified registers : none
            push {r0-r2,lr}
            ;pushing r0 avoids swapping r0 and r2 a second time
            ;after calling PutNumU.
            movs r1, #0xFF
            movs r2, r0
            ands r2, r2, r1
            eors r0, r0, r2
            eors r2, r0, r2
            eors r0, r0, r2
            bl   PutNumU
            pop  {r0-r2,pc}
            endp
PutNumHex   proc {r1-r14}, {}
;Writes a hexadecimal number from r0 to uart 0 in ASCII format
; inputs             : r0: number to write
; outputs            : none
; modified registers : none
            push {r1-r3,lr}
;             push {r0}
;             ;print '0x'
;             movs r0, #'0'
;             bl   putchar
;             movs r0, #'x'
;             bl   putchar
;             pop  {r0}
            ldr  r1, =0xF0000000    ;nibble mask
pnh_loop    movs r2, r0
            ands r2, r2, r1         ;apply mask
            ;shift to lsb
            ;in order to do this, look at the mask in r1, determine how many times it would need to be shifted
            ;to procuce 15, shift r1 left that many times, then shift r2 right that many times
            ;ideally, multiply everything by four since we're looking at nibbles exclusively.
            ;counter in r3
       
            movs r3, #0
getsh_loop  cmp  r1, #15
            beq  found_lsb
            adds r3, r3, #4 ;shift by 4 => add 4
            lsrs r1, r1, #4
            b    getsh_loop
found_lsb   lsls r1, r1, r3 ;restore r1
            lsrs r2, r2, r3 ;move r2 to lsb
            ;r2 is ready for comparison!
at_lsb      cmp  r2, #9
            bhi  to_af              ;if the number is [10-15], add 97
            adds r2, r2, #'0'       ;else add 48
            b    send_digit
            
to_af       subs r2, r2, #10
            adds r2, r2, #'a'
send_digit
            eors r2, r2, r0
            eors r0, r2, r0
            eors r2, r2, r0         ;swap r0, r2 (value of r0 preserved in r2
            bl   putchar
            movs r0, r2             ;r2 value unneeded now, restore r0
            lsrs r1, r1, #4
            cmp  r1, #0             ;once the mask has been shifted out
            bne  pnh_loop           ;the loop ends
            pop  {r1-r3,pc}
            endp

PutNumU     proc {r0-r14}, {}
; write a decimal number to uart0 in utf-8 representation
; inputs             : num to write in r0
; calls              : putchar, divu
; outputs            : none
; modified registers : none
            push {r0-r3, lr}
            ;in the case of zero, skip everything because it's simple
            cmp  r0, #0
            bne  not_zero
            movs r0, #'0'
            bl   putchar
            b    pnu_done
        
not_zero
            movs r1, #1
            lsls r1, r1, #31    ;r1 = 2*31
pwr_loop    cmp  r0, r1
            bhs  get_log
            lsrs r1, r1, #1     ;shift r1 down by one
            b    pwr_loop 
get_log     lsls r1, r1, #1 ;reverse, reverse! (loop runs 1 time too many)
            ;r1 now has the smallest power of two greater than or equal to
            ;the number given on r0.  Now, acquire the exponent of that power
            ;which again requires a stupid amount of iteration but whatever
            movs r2, #0 ;r2 is the loop counter, will be the result of log2(r1)
log_loop    cmp  r1, #2
            beq pwr_done
            lsrs r1, r1, #1
            adds r2, r2, #1
            b    log_loop
pwr_done    ;r2 = log2(r1)
            ldr  r3, =bin2dec_lut
            lsls r2, r2, #2      ;r2 is a power of 4, can now do reg. rel. ldr
            ldr  r3, [r3, r2]    ;r3 = bin2dec_lut[r2]
            ;now the greatest power of ten less than r0 is in r3.  Divide!
            ;print the quotient, loop w/remainder, done when quotient < 10 (can just print)
            movs r1, r0
pnu_err 	movs r0, r3			;divu setup
            movs r3, r1         ;save the original in case of error!
pnu_loop    cmp  r1, #10
            blo  pnu_div_done
            bl   divu           ;r0 r r1 = r1 // r0
            cmp  r0, #10
            blo  pnu_ok
            movs r1, r3         ;restore original number
            lsrs r2, r2, #2
            adds r2, r2, #1
            lsls r2, r2, #2
            ldr  r3, =bin2dec_lut
            ldr  r3, [r3, r2]   ;next power up the table
            b    pnu_err 
            ;if the quotient is greater than or equal to ten, the initial 
            ;divisor is wrong.  I don't know why this happens, but we're gonna
            ;correct for it by increasing the power by one and trying again.

pnu_ok      ;divide the divisor by ten, and divide again with the remainder
            adds r0, r0, #48    ;ascii 0
            bl   putchar
            ;printed the quotient, now divide the original divisor (in r3)
            ;by ten
            movs r2, r1         ;save the remainder
            movs r1, r3         ;move the divisor back into r1 (to be dividend)
            movs r0, #10
            bl   divu
            movs r3, r0         ;copy new divisor to r3
            ;r0 already has the quotient (new divisor), move remainder to r1
            movs r1, r2         ;restore remainder
            b    pnu_loop       ;divide!
            
pnu_div_done
            movs r0, r1
            adds r0, r0, #48    ;ascii 0
            bl   putchar
pnu_done
            pop  {r0-r3, pc}
            endp

strlen      proc    {r1-r14}, {}
; get the length of a null-terminated string in memory
; inputs             : r0: address of string
; outputs            : r1: length of string in bytes
; modified registers : r1
            push {r2, lr}
            movs r1, #0
strlen_loop ldrb r2, [r0, r1]
            cmp  r2, #0
            beq  strlen_done
            adds r1, r1, #1
            b    strlen_loop
strlen_done pop  {r2, pc}
            endp

GetHexMulti proc    {r2-r14}, {}
; Get a string of n words from the console
; inputs             : r0: memory address to write to
;                      r1: number of words to read
; outputs            : C flag set if error
; modified registers : none
            push {r0-r7, lr}
            movs r2, r0                 ;need r0 for getchar
            ldr  r3, =__stack           ;temporary memory
            movs r0, #0
            movs r6, #0
			lsls r1, r1, #2             ;8n bytes
            push {r1}                   ;preserve initial number of bytes
            adds r1, r1, #1             ;include null terminator
            movs r0, r3
            bl   GetStringSB
            bl   validhex
            bcs  ghm_inval              ;if invalid input, break
            bl   strlen
            subs r1, r1, #1             ;exclude null terminator from strlen
            movs r6, r1
            subs r6, r6, #1
            ;lsrs r6, r1, #1             ;bytes of input
            pop  {r7}                   ;retrieve original number of bytes
            subs r7, r7, r1             ;r7 <= number of bytes to EXTEND BY
            adds r6, r6, r7
            cmp  r0, #0
            beq  ghm_inval              ;invalid if no input
;-------------------------------------------------------------------------------
; r0: buffer location
; r1: bytes of input (# of nibbles)
; r6: bytes of input (# of bytes + zeroext)
; r2: output location
; r3: buffer location
; r4: byte buffer
ghm_loop    subs r1, r1, #1
            ldrb r0, [r3, r1]
            bl   hex2nib
            lsls r4, r0, #4
            adds r1, r1, #1
            ldrb r0, [r3, r1]
            bl   hex2nib
            orrs r4, r4, r0
            strb r4, [r2, r6]
            subs r1, r1, #2
            subs r6, r6, #1
            cmp  r1, #0
            bge  ghm_loop
            ;now, everything is in memory and supposedly the correct location
            ;perform the zeroext...
            movs r0, #0
ghm_zext    strb r0, [r2, r6]
            subs r6, r6, #1
            cmp  r6, #0
            bge  ghm_zext
            ;clear c flag
            ldr  r7, =APSR_C_MASK
            mrs  r6, apsr
            bics r6, r6, r7
            msr  apsr, r6
            b    ghm_done

ghm_inval
            ;set c flag
            ;ldr  r7, =APSR_C_MASK
            ;mrs r6, apsr
            ;orrs r6, r6, r7
            ;msr  apsr, r6
			pop {r1}
ghm_done
            pop  {r0-r7, pc}
            endp
            

            

hex2nib     proc {r1-r14}, {}
; ASCII hex -> nibble
            push {lr}

            bl   toUpper
            cmp  r0, #'0'
            blo  h2n_inval
            cmp  r0, #'9'
            bhi  h2n_alpha
            subs r0, r0, #'0'
            b    h2n_done

h2n_alpha   cmp  r0, #'A'
            blo  h2n_inval
            cmp  r0, #'F'
            bhi  h2n_inval
            subs r0, r0, #('A' - 10)
            b    h2n_done
h2n_inval
            ;set C flag on invalid
            push {r0, r1}
            mrs  r0, apsr
            ldr  r1, =APSR_C_MASK
            orrs r0, r0, r1
            msr  apsr, r0
            pop  {r0, r1}
            pop  {pc}       ;I don't like this
h2n_done
            push {r0, r1}
            mrs  r0, apsr
            ldr  r1, =APSR_C_MASK
            bics r0, r0, r1
            msr  apsr, r0
            pop  {r0, r1}
            pop  {pc}
            endp

hex2byte    proc {r2-r14}, {}
; inputs             : address on r0
; outputs            : byte on r1
; modified registers : none
            push {r0,r2,lr}
            ldrb r0, [r0, #0]
            movs r2, r0
            movs r3, #0xf       ;low nibble mask
            ands r2, r2, r3    
            ;lower nibble selected
            bl   toUpper
            cmp  r2, #'0'
            blo  hex_inval
            cmp  r2, #'9'
            bhi  ck_hi1
            ;checking 0-9
            subs r2, r2, #'0'
ck_hi1      cmp  r2, #'A'
            blo  hex_inval
            cmp  r2, #'F'
            bhi  hex_inval
            subs r2, r2, #'A'
            ;one nibble on r2
            ;now, repeat procedure, shift, or bits together for full byte
            lsls r3, r3, #4 ;move four bits over (high nibble)
            ands r0, r0, r3 ;mask
            lsrs r0, r0, #4 ;move to low nibble
            bl   toUpper
            cmp  r0, #'0'
            blo  hex_inval
            cmp  r0, #'9'
            bhi  ck_hi2
            ;checking 0-9
            subs r0, r0, #'0'
ck_hi2      cmp  r0, #'A'
            blo  hex_inval
            cmp  r0, #'F'
            bhi  hex_inval
            subs r0, r0, #'A'
            lsls r2, r0, #4
            movs r1, r2
hex_inval   
            pop  {r0,r2,pc}
            endp

PutHexMulti proc    {r2-r14}, {}
; Write an n-bit word to the console
; inputs             : r0: address of multipres. number
;                      r1: number of words in number
; outputs            : none
; modified registers : none
            push {r1,r2,lr}
            ;lots of PutNumHex
			lsls r1, r1, #2		;multiply by four, move by words, not bytes
            subs r1, r1, #4
            adds r1, r1, r0     ;r1 is now the end pointer
            movs r2, r0
phm_loop    ldr  r0, [r2, #0]   ;loop takes advantage of msb-first ordering
            bl   PutNumHex
			adds r2, r2, #4
			movs r0, r2			;restore pointer
            cmp  r2, r1
            bls  phm_loop
            pop  {r1,r2,pc}
            endp


toUpper     proc    {r1-r14}, {}
; Convert ASCII char on r0 to uppercase, also on r0.
; inputs             : r0: mixed case ASCII char
; ouputs             : r0: uppercase ASCII char
; modified registers : r0: uppercase ASCII char
            push{lr}
            cmp r0, #'a'
            blo no_op
            cmp r0, #'z'
            bhi no_op
            subs r0, r0, #32
no_op       pop  {pc}
            endp

validhex    proc    {r1-r14},{}
; determine if a string is a valid hex string
; inputs             : r0: address of string
; outputs            : C flag clear if ok, set if invalid
; modified registers : none
            push {r1, r2, lr}
            ;loop counter on r2
            movs r2, #0
            ldrb r1, [r0, #0]
vhex_loop   cmp  r1, #'9'
            bhi  check_alpha
            cmp  r1, #'0'
            blo  invalid_hex
			;r0 is [0-9], so this is valid
			b    repeat_vhex
            ;char must be [a-fA-F] to be valid now
check_alpha eors r0, r0, r1
            eors r1, r0, r1
            eors r0, r0, r1 ;swap
            bl   toUpper
            eors r0, r0, r1
            eors r1, r0, r1
            eors r0, r0, r1 ;swap
            cmp  r1, #'A'
            blo  invalid_hex
            cmp  r1, #'F'
            bhi  invalid_hex
repeat_vhex adds r2, r2, #1
            ldrb r1, [r0, r2]
            cmp  r1, #0
            beq  str_compl
            b    vhex_loop
str_compl
            ;clear the C flag
            mrs  r1, apsr
            ldr  r2, =APSR_C_MASK
            bics r1, r1, r2
            msr  apsr, r1
            b    valhex_done

invalid_hex ;set C flag
            mrs  r1, apsr
            ldr  r2, =APSR_C_MASK
            orrs r1, r1, r2
            msr  apsr, r1

valhex_done pop  {r1, r2, pc}
            endp
divu		proc {r2-r14}, {}
; slow integer division
; inputs             : divisor in r0, dividend in r1
; calls              : none
; outputs            : quotient in r0, remainder in r1
; modified registers : r0, r1
            push {r2, lr}
            cmp r0, #0		; don't divide by zero
            beq e_divu_0
            cmp r0, #1		; do nothing if dividing by one
            beq e_divu_1
            cmp r0, r1		; if r0 is greater, no can do
            bhi e_divu_g
            movs r2, #0		; zero-out r2
divu_loop
            subs r1, r1, r0
            adds r2, r2, #1
            cmp  r1, r0
            bhs divu_loop	; repeat ad-infinitum
; what's this?
; flip r0 and r1 by xor
; SUB FROM R1
            ;eors r0, r0, r1
            ;eors r1, r0, r1
            ;eors r0, r0, r1
            movs r0, r2			; r0 = quotient
            b    divu_done
e_divu_0
            movs r2, #0xF
            lsls r2, r2, #31
            adds r2, r2, r2	; set C flag
            b    divu_done
e_divu_1
            movs r0, r1		;move dividend into quotient
            ;clear C flag
            msr  apsr, r1
            ldr  r2, =0x20000000
            bics r1, r1, r2
            mrs  r1, apsr
            movs r1, #0		;no remainder
            b    divu_done
e_divu_g	;move dividend to remainder, set quotient to 0
            movs r0, #0
            push {r1}
            ;clear C flag
            msr  apsr, r1
            ldr  r2, =0x20000000
            bics r1, r1, r2
            mrs  r1, apsr
            pop  {r1}
divu_done	
            pop  {r2}
            pop  {pc}
            endp
            ALIGN
;****************************************************************
;Constants
            AREA    bss,DATA,READONLY
;>>>>> begin constants here <<<<<
teststr		dcb		"hello world"		;a true classic
len_teststr equ     .-teststr
input_pr    dcb     "Enter a string:",CR, LF,'>', 0
strlen_pr   dcb     "Length:", 0 
; log lookup table.
; index into the table is the desired power of two (idx = log2(n)),
; value at that index is the largest power of ten less than n.
bin2dec_lut dcd     1, 1, 1, 1, 10, 10, 10, 100, 100, 100, 1000, 1000, 1000,\
                    10000, 10000, 10000, 100000, 100000, 100000, 1000000,\
                    1000000, 1000000, 1000000, 10000000, 10000000, 10000000,\
                    100000000, 100000000, 100000000, 1000000000, 1000000000
;>>>>>   end constants here <<<<<
            ALIGN

;****************************************************************
;Variables
            AREA    data,DATA,READWRITE
;>>>>> begin variables here <<<<<
input_buf   SPACE  80
            align
__stack
;>>>>>   end variables here <<<<<
            ALIGN
            END

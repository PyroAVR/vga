;****************************************************************
; queue operations
;****************************************************************
            GET         MKL46Z4.s
            AREA text,CODE,READONLY
            EXPORT      InitQueue
            EXPORT      Dequeue
            EXPORT      Enqueue
            EXPORT      in_ptr
            EXPORT      out_ptr
            EXPORT      buf_start
            EXPORT      buf_past 
            EXPORT      buf_size 
            EXPORT      num_enqd 


InitQueue   proc {r0-r14}, {}
; Initialize a queue
; inputs             :  r0: buffer address
;                       r1: record address
;                       r2: buffer capacity
; outputs            :  none
; modified registers :  none
; note that since there isn't a 'heap' of any kind,
; the buffer capacity and address need to be carefully selected.
            push {r0,r1,r3,lr}
            ;first step, init the record
            str  r0, [r1, #in_ptr]
            str  r0, [r1, #out_ptr]
            str  r0, [r1, #buf_start]
            strb r2, [r1, #buf_size]
            movs r3, #0
            strb r3, [r1, #num_enqd]
            adds r3, r0, r2             ;get buf_past
            adds r3, r3, #1             ;go past buffer by one
            str  r3, [r1, #buf_past]
            pop  {r0,r1,r3, pc}
            endp

Dequeue     proc {r1-r14}, {}
; Dequeue a byte from a character queue at the address in r1
; inputs             : r1: queue record
; outputs            : r0: byte dequeued, if applicable
;                       C: set if dequeue fails
; modified registers : apsr
            push {r2,r3,lr}
            ;don't touch r0 unless write is possible.
            ;step one: check if there are bytes available
            ldrb r2, [r1, #num_enqd]
            cmp  r2, #0
            beq  buf_empty
            ;data is available, load it
            ldr  r0, [r1, #out_ptr]     ;index into the buffer
            ldrb r0, [r0, #0]           ;fetch from the buffer
            
            ;update num_enqd
            subs r2, r2, #1
            strb r2, [r1, #num_enqd]

            ;update out pointer
            ldr  r3, [r1, #out_ptr]
            adds r3, r3, #1
            ;if we've past the end of the queue, wrap
            ldr  r2, [r1, #buf_past]
            cmp  r2, r3
            bne  out_ptr_ok
            ;do the wrap
            ldr  r3, [r1, #buf_start]
out_ptr_ok  ;no need to wrap         
            str  r3, [r1, #out_ptr]

            ;clear the C flag
            mrs  r2, apsr
            ldr  r3, =APSR_C_MASK
            bics r2, r2, r3
            msr  apsr, r2
            b    deq_done
buf_empty
            ;set the C flag
            mrs  r2, apsr
            ldr  r3, =APSR_C_MASK
            ands r2, r2, r3
            msr  apsr, r2
deq_done    pop  {r2,r3,pc}
            endp

Enqueue     proc {r1-r14}, {}
; Enqueue a byte into the queue address in r1
; inputs             : r1: address of queue
;                      r0: byte to enqueue
; outputs            :  C: set if enqueue fails
; modified registers : apsr
            push {r0,r2-r4,lr}
            ;step zero: load all the info needed
            ; buf_start, buf_size, num_enqd, in_ptr
            ;step one: check if the queue is not full
            ldrb r2, [r1, #num_enqd]
            ldrb r3, [r1, #buf_size]
            cmp  r2, r3
            beq  buf_full
            ;space is available!
            ldr  r4, [r1, #in_ptr]
            strb r0, [r4, #0]       ;store that byte
            movs r0, #0
            strb r0, [r4, #1]		;super secret
            ;update num_enqd
            adds r2, r2, #1
            strb r2, [r1, #num_enqd]
            
            ;update in_ptr
            adds r4, r4, #1
            ldr  r3, [r1, #buf_past]
            cmp  r3, r4
            bne  in_ptr_ok
            ldr  r4, [r1, #buf_start]
in_ptr_ok   ;no need to wrap
            str  r4, [r1, #in_ptr]

            
            ;clear the C flag
            mrs  r2, apsr
            ldr  r3, =APSR_C_MASK
            bics r2, r2, r3
            msr  apsr, r2
            b    enq_done
buf_full
            ;set the C flag
            mrs  r2, apsr
            ldr  r3, =APSR_C_MASK
            ands r2, r2, r3
            msr  apsr, r2
            ;set the C flag
enq_done    pop  {r0,r2-r4,pc}
            endp

            AREA    MyData,DATA,READWRITE
;>>>>> begin variables here <<<<<
;++++++++++++++++++++++
; QUEUE RECORD (STRUCT)
; InPointer         (4)
; OutPointer        (4)
; BufferStart       (4)
; BufferPast        (4)
; BufferSize        (1)
; NumberEnqueued    (1)
;++++++++++++++++++++++
; yeah, yeah, equates don't go here, but I like my code organized
; like a normal oop language :)
; offsets into the record for each item
in_ptr      equ     0
out_ptr     equ     4
buf_start   equ     8
buf_past    equ     12
buf_size    equ     16
num_enqd    equ     17
;QUEUE ITEMS ARE BYTES
			ALIGN
;>>>>>   end variables here <<<<<
            ALIGN
            END

.data 

state: .word 0 # indica lo stato del programma

overflowError: .word 3 # errore di overflow
overflowErrorMsg: .string "errore di overflow"

INT32_MIN: .word -2147483648
INT32_MAX: .word 2147483647

.text

test:
    li a1, -2
    li a2, 669
    
    jal Addition
    
    lw t0, state
    lw t1, overflowError
    bne t0, t1 success
    
    la a0, overflowErrorMsg
    li a7, 4
    ecall
    j end
    
    success:
        mv a0, a0
        li a7 1
        ecall
    end:
        li a7 10
        ecall
    


# Function: Addition
#     a0: risultato dell'addizione
#     a1(a), a2(b): addendi
Addition:
    # t0 = INT32_MIN
    # t1 = INT32_MAX
               
    bgtz a2, positive_b_Addition
    
    lw t0, INT32_MIN
    sub t0, t0, a2
    blt a1, t0 overflow_error_Addition
    j add_operation
    
    positive_b_Addition:
        lw t1, INT32_MAX
        sub t1, t1, a2
        blt t1, a1 overflow_error_Addition
    add_operation:
        add a0, a1, a2
        ret

    overflow_error_Addition:
        la t2, state
        lw t3, overflowError
        sw t3, 0(t2)
        mv a0, zero
        ret
# End
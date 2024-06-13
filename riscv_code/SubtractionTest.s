.data

state: .word 0 # indica lo stato del programma

overflowError: .word 3 # errore di overflow
overflowErrorMsg: .string "errore di overflow"

INT32_MIN: .word -2147483648
INT32_MAX: .word 2147483647

.text

test:
    li a1, -214
    li a2, 2
    
    jal Subtraction
    
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



# Function: Subtraction
#     a0: risultato della sottrazione
#     a1(a): minuendo
#     a2(b): sottraendo
Subtraction:
    # t0 = INT32_MIN
    # t1 = INT32_MAX
    
    bgtz a2, positive_b_Subtraction
    
    lw t1, INT32_MAX
    add t1, t1, a2
    blt t1, a1 overflow_error_Subtraction
    j sub_operation
    
    positive_b_Subtraction:
        lw t0, INT32_MIN
        add t0, t0, a2
        blt a1, t0 overflow_error_Subtraction
    sub_operation:
        sub a0, a1, a2
        ret
        
    overflow_error_Subtraction:
        la t2, state
        lw t3, overflowError
        sw t3, 0(t2)
        mv a0, zero 
        ret
# End
        
    
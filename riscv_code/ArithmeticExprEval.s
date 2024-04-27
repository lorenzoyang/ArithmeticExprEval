.data

# Espressione aritmetica >>>

input: .string "1+2"

# <<<

# Tipi di errore >>>

state: .word 0 # indica lo stato del programma, 0 = nessun errore
syntaxError: .word 1 # errore di sintassi
divisionByZeroError: .word 2 # divisione per lo zero
overflowError: .word 3 # errore di overflow
parenthesesError: .word 4 # errore di parentesi

# <<<

# Messaggi di errore >>>

syntaxErrorMsg: .string "errore di sintassi"
divisionByZeroErrorMsg: .string "divisione per lo zero"
overflowErrorMsg: .string "errore di overflow"
parenthesesErrorMsg: .string "errore di prentesi"

# <<<

# Costanti >>>

INT32_MIN: .word -2147483648
INT32_MAX: .word 2147483647

# <<<

.text

main:        
    
    
    
    
# Operazioni aritmetiche >>>

# Function: Addition
#     a0: risultato dell'addizione
#     a1(a), a2(b): addendi
Addition:
    # t0 = INT32_MIN
    # t1 = INT32_MAX
    
    addi sp, sp, -4
    sw ra, 0(sp)
        
    bgtz a2, positive_b_Addition
    
    lw t0, INT32_MIN
    sub t0, t0, a2 # t0 = INT32_MIN - b
    blt a1, t0 overflow_error_Addition
    j add_operation
    
    positive_b_Addition:
        lw t1, INT32_MAX
        sub t1, t1, a2 # t1 = INT32_MAX - b
        blt t1, a1 overflow_error_Addition
    add_operation:
        add a0, a1, a2
        j end_Addition

    overflow_error_Addition:
        la t2, state
        lw t3, overflowError
        sw t3, 0(t2)
        mv a0, zero 
    end_Addition:
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End



# Function: Subtraction
#     a0: risultato della sottrazione
#     a1(a): minuendo
#     a2(b): sottraendo
Subtraction:
    # t0 = INT32_MIN
    # t1 = INT32_MAX
    
    addi sp, sp, -4
    sw ra, 0(sp)
    
    bgtz a2, positive_b_Subtraction
    
    lw t1, INT32_MAX
    add t1, t1, a2 # t1 = t1 + b
    blt t1, a1 overflow_error_Subtraction # t1 < a
    j sub_operation
    
    positive_b_Subtraction:
        lw t0, INT32_MIN
        add t0, t0, a2 # t0 = t0 + b
        blt a1, t0 overflow_error_Subtraction
    sub_operation:
        sub a0, a1, a2
        j end_Subtraction
        
    overflow_error_Subtraction:
        la t2, state
        lw t3, overflowError
        sw t3, 0(t2)
        mv a0, zero 
    end_Subtraction:
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End


    
Multiplication:
    
Division:
        
# <<<
    
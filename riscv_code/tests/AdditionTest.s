.data 

overflowError: .word 3 # errore di overflow
overflowErrorMsg: .string "errore di overflow"

INT32_MIN: .word -2147483648
INT32_MAX: .word 2147483647

.text

test:
    li a1, 2147483647
    li a2, 669
    mv a3, zero
    
    jal Addition
    
    mv a0, a0
    li a7 1
    ecall
    
    li a0, 10 # 10 = '\n'
    li a7, 11
    ecall
        
    lw t0, overflowError
    bne a3, t0 end
    
    la a0, overflowErrorMsg
    li a7, 4
    ecall
    end:
        li a7 10
        ecall
    

Addition:
# Esegue un'addizione sicura tra due interi con controllo dell'overflow.
# a0 (return): La somma di a e b se non si verifica un overflow, altrimenti 0.
# a1: Primo intero (a)
# a2: Secondo intero (b)
# a3: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)

    # t0 = INT32_MIN
    # t1 = INT32_MAX
    
    # restituire il risultato dell'addizione anche nel caso di overflow
    add a0, a1, a2
               
    bgtz a2, positive_b_Addition
    
    lw t0, INT32_MIN
    sub t0, t0, a2
    blt a1, t0 overflow_error_Addition
    ret
    
    positive_b_Addition:
        lw t1, INT32_MAX
        sub t1, t1, a2
        blt t1, a1 overflow_error_Addition
        ret
        
    overflow_error_Addition:
        lw a3, overflowError
        ret

# End

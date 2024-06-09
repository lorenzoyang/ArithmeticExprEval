.data

state: .word 0 # indica lo stato del programma

divisionByZeroError: .word 2 # divisione per lo zero
divisionByZeroErrorMsg: .string "divisione per lo zero"

.text

test:
    li a1, 321
    li a2, 2
    
    jal Division
    
    lw t0, state
    lw t1, divisionByZeroError
    bne t0, t1 success
    
    la a0, divisionByZeroErrorMsg
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



# Function: Division
#     L'implementazione dell'algoritmo di Restoring-Division
#     a0: risultato della divisione
#     a1(a): dividendo
#     a2(b): divisore
Division:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    beqz a2 division_by_zero_error
    
    # a1: registro Dividendo
    # a2: registro Divisore
    # t0: registro Accumulatore
    # t1: registro Contatore
    
    # inizializzazione:
    # a1, a2 gia' inizializzati
    mv t0, zero
    li t1, 32 # numero di bit
    
    RestoreDivision_loop:
        # l'operazione left-shift di 1: considerando t0 e a1 come un solo registro da 64 bit

        # spostamento dell'Accumulatore
        slli t0, t0, 1
        # il bit piu' significativo del a1 (Dividendo)
        slt t2, a1, zero
        or t0, t0, t2
        # spostamento del Dividendo
        slli a1, a1, 1
        
        sub t0, t0, a2
        bltz t0 accumulatore_negativo
        
        ori a1, a1, 1 # l'ultimo bit del Dividendo = 1
        j next_RestoreDivision_loop
        
        accumulatore_negativo:
            andi a1, a1, 0xFFFFFFFE # l'ultimo bit del Dividendo = 0
            add t0, t0, a2
        
        next_RestoreDivision_loop:
            addi t1, t1, -1 # decremento il contatore 
            bnez t1, RestoreDivision_loop
        
        # il quoziente salvato nel registro Dividendo, 
        # il resto nell'Accumulatore (non ci serve)
        mv a0, a1
        j end_Division
    
    division_by_zero_error:
        la t3, state
        lw t4, divisionByZeroError
        sw t4, 0(t3)
        mv a0, zero
        
    end_Division:
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End
.data

divisionByZeroError: .word 2 # divisione per lo zero
divisionByZeroErrorMsg: .string "divisione per lo zero"

.text

test:
    li a1, 3
    li a2, 2
    mv a3, zero
    
    jal Division
    
    mv a0, a0
    li a7 1
    ecall
    
    li a0, 10 # 10 = '\n'
    li a7, 11
    ecall
    
    lw t0, divisionByZeroError
    bne a3, t0 end
    
    la a0, divisionByZeroErrorMsg
    li a7, 4
    ecall
    end:
        li a7 10
        ecall


Division:
# L'implementazione dell'algoritmo di Restoring-Division. Esegue una divisione sicura tra due interi con controllo della divisione per zero.
# a0 (return): Il quoziente di a e b se b non ? zero, altrimenti 0.
# a1: a Primo intero (dividendo).
# a2: b Secondo intero (divisore).
# a3: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)

    beqz a2 division_by_zero_error
    
    # a1: registro Dividendo
    # a2: registro Divisore
    # t0: registro Accumulatore (A)
    # t1: registro Contatore
    
    # inizializzazione:
    # a1, a2 gia' inizializzati
    mv t0, zero
    li t1, 32 # numero di bit
    
    RestoreDivision_loop:
        # spostamento logico a sinistra di 1: considerando t0 e a1 come un registro da 64 bit

        slli t0, t0, 1 # spostamento di A
        slt t2, a1, zero # il bit piu' significativo di a1 (Dividendo)
        or t0, t0, t2
        slli a1, a1, 1 # spostamento del Dividendo
        
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
        # il resto salvato in A (non ci serve)
        mv a0, a1
        ret
    
    division_by_zero_error:
        lw a3, divisionByZeroError
        mv a0, zero
        ret

# End
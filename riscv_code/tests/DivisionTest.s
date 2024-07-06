.data

divisionByZeroError: .word 2 # divisione per lo zero
overflowErrorDivision: .word 3 # overflow durante la divisione
divisionByZeroErrorMsg: .string "divisione per lo zero"
overflowErrorDivisionMsg: .string "overflow nella divisione"

.text

test:
    li a1, -2147483648
    li a2, 0
    mv a3, zero
    
    jal Division
    
    mv a0, a0
    li a7 1
    ecall
    
    li a0, 10 # 10 = '\n'
    li a7, 11
    ecall
    
    lw t0, divisionByZeroError
    beq a3, t0 case_division_by_zero_error
    
    lw t0, overflowErrorDivision
    beq a3, t0 case_overflow_error_division
    
    case_division_by_zero_error:
        la a0, divisionByZeroErrorMsg
        li a7, 4
        ecall
        j end
    case_overflow_error_division:
        la a0, overflowErrorDivisionMsg
        li a7, 4
        ecall
    end:
        li a7 10
        ecall


Division:
# Implementazione dell'algoritmo di Restoring-Division. Esegue una divisione sicura tra due interi con controllo della divisione per zero.
# a0 (return): Quoziente di a e b se b non e' zero, altrimenti 0.
# a1: Primo intero (dividendo), registro Dividendo
# a2: Secondo intero (divisore), registro Divisore
# a3: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
    # t0: registro Accumulatore (A)
    # t1: registro Contatore
    # t6: registro che decide il segno del risultato: 0/2 => positivo, 1 => negativo
    
    beqz a2 division_by_zero_error
    
    # Inizializzazione:
    # a1, a2 gia' inizializzati
    mv t0, zero
    li t1, 32    # il numero di bit
    mv t6, zero
    
    bltz a1 negative_dividend
    bltz a2 negative_divisor
    j RestoreDivision_loop
    negative_dividend:
        addi t6, t6, 1
        neg a1, a1
        bltz a2 negative_divisor
        j RestoreDivision_loop
    negative_divisor:
        addi t6, t6, 1
        neg a2, a2
    RestoreDivision_loop:
        # Spostamento logico a sinistra di 1: considerando t0 e a1 come un unico registro da 64 bit
        slli t0, t0, 1    # spostamento di A
        slt t2, a1, zero    # il bit piu' significativo di a1 (Dividendo)
        or t0, t0, t2
        slli a1, a1, 1    # spostamento del Dividendo
        sub t0, t0, a2
        bltz t0 accumulatore_negativo
        ori a1, a1, 1    # l'ultimo bit del Dividendo = 1
        j next_RestoreDivision_loop
        accumulatore_negativo:
            andi a1, a1, 0xFFFFFFFE    # l'ultimo bit del Dividendo = 0
            add t0, t0, a2
        next_RestoreDivision_loop:
            addi t1, t1, -1    # decrementa il contatore 
            bnez t1, RestoreDivision_loop
        # Quoziente salvato nel registro Dividendo, 
        # Resto salvato in A (non ci serve)
        mv a0, a1  
        li t3, 1
        beq t6, t3 set_negative_sign
        
        # Ora se il risultato e' negativo vuol dire che e' avvenuto un overflow
        # In una divisione del tipo INT32_MIN/-1
        bltz a0, overflow_error_division
        
        ret
        set_negative_sign:
            neg a0, a0
            ret
    division_by_zero_error:
        lw a3, divisionByZeroError
        mv a0, zero
        ret
    overflow_error_division:
        lw a3, overflowErrorDivision
        ret

# End
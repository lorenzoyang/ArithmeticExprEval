.data

# Espressione aritmetica >>>

input: .string "1+2"

# <<<

# Tipi di errore >>>

state: .word 0 # indica lo stato del programma, 0 => nessun errore
syntaxError: .word 1 # errore di sintassi
divisionByZeroError: .word 2 # errore di divisione per zero
overflowError: .word 3 # errore di overflow
parenthesesError: .word 4 # errore di parentesi

# <<<

# Messaggi di errore >>>

syntaxErrorMsg: .string "errore di sintassi"
divisionByZeroErrorMsg: .string "errore di divisione per zero"
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


    
# Function: Multiplication
#     L'implementazione dell'algortimo di Booth
#     a0: risultato della moltiplicazione
#     a1: moltiplicando
#     a2: moltiplicatore
Multiplication:
    # a1: registro Moltiplicando (M) (rimane costante)
    # a2: registro Moltiplicatore (Q)
    # t0: registro Accumulatore (A)
    # t1: registro Q_-1 (solo l'ultimo bit, usato come il bit della posizione -1 di Q)
    # t2: registro contatore (contiene il numero di bit del moltiplicatore)
    # t3: complemento a due del moltiplicando
    # t4: registro Q_0 (l'ultimo bit di Q)
    # il prodotto della moltiplicazione e' formata da 64 bit, si considerano solo gli ultimi 32 bit
    
    # inizializzazione:
    # a1(M), a2(Q) gia' inizializzati
    mv t0, zero
    mv t1, zero
    li t2, 32
    neg t3, a1
    # t4(Q_0) inizializzato nel loop seguente
    
    Booth_loop:
        andi t4, a2, 1 # Q_0
        beq t4, t1 shift # Q_0 == Q_-1
        beq t4, zero addM # Q_0 == 0 => Q_-1 == 1
        j subM # Q_0 == 1 => Q_-1 == 0
        
        addM:
            add t0, t0, a1
            j shift
        
        subM:
            add t0, t0, t3
            j shift
    
        shift:
            mv t1, t4 # Q_-1 riceve il valore di Q_0
            srli a2, a2, 1 # spostamento logico per 1 
                 
            # il primo bit di Q e' sicuramente 0
            andi t5, t0, 1 # t5 = LSB di A
            slli t5, t5, 31 # l'ultimo bit di A diventa MSB di t5
            or a2, a2, t5
            
            # spostamento aritmetico a destra per A
            srai t0, t0, 1
        
            addi t2, t2, -1 # decremento il contatore
        
            bnez t2, Booth_loop
            
            # controllo dell'Overflow
            srai t5, t0, 31 # il segno di A
            srai t6, a2, 31 # il segno di Q (moltiplicatore)
            bne t5, t6 overflow_error_Multiplication
            
            mv a0, a2 # gli ultimi 32 bit del prodotto si trovano in Q
            ret

    overflow_error_Multiplication:
        la t5, state
        lw t6, overflowError
        sw t6, 0(t5)
        mv a0, zero
        ret    
# End



# Function: Division
#     L'implementazione dell'algoritmo di Restoring-Division
#     a0: risultato della divisione
#     a1(a): dividendo
#     a2(b): divisore
Division:
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
        la t3, state
        lw t4, divisionByZeroError
        sw t4, 0(t3)
        mv a0, zero
        ret
# End


        
# <<<
    
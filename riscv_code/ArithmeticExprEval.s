.data

# Espressione aritmetica >>>
input: .string "21232"
# <<<

# Tipi di errore >>>
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
    la a1, input
    mv a2, zero
    
    jal String2Int
    
    mv a0, a0
    li a7, 1
    ecall
    
    li a0, 10 # 10 = '\n'
    li a7, 11
    ecall
    
    mv a0, a2
    li a7, 1
    ecall
# End

Eval:
# Valuta un'espressione aritmetica.
# a0 (return): Il risultato dell'espressione
# a1: L'indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
    mv a3, zero # a3: numero di parentesi aperte
    jal Evaluate # richiamare la funzione principale (ricorsiva)
    beqz a3 end_Eval
    # parentheses_error
    lw a2, parenthesesError
    mv a0, zero
    end_Eval:
        # a0 e' uguale a a0 della funzione di supporto Evaluate
        ret
# End

Evaluate:
# Funzione principale per la valutazione delle espressioni.
# a0 (return): Il risultato della valutazione dell'espressione
# a1: L'indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
# a3: Contatore delle parentesi aperte
    
# End

String2Int:
# Converte una stringa in un intero.
# a0 (return): L'intero convertito dalla stringa
# a1: L'indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
    addi sp, sp, -16
    sw ra, 0(sp)
    # si usano i registri che iniziano con s perche' questi valori non devono essere modificati dopo una richiamata di un'altra funzione
    # registro s0 per salvare il risultato finale
    mv s0, zero
    li s1, 48 # 48 = '0'
    li s2, 57 # 57 = '9'
    loop_String2Int:
        lb s3, 0(a1) # s3 = carattere attuale
        blt s3, s1 end_String2Int
        bgt s3, s2 end_String2Int
        sub s3, s3, s1 # s3 = carattere attuale - '0' (char -> int)
        
        # richiamare Multiplication
        sw a1, 4(sp)
        sw a2, 8(sp)
        sw a3, 12(sp)
        mv a1, s0
        li a2, 10
        jal Multiplication
        mv s0, a0
        add s0, s0, s3
        lw a1, 4(sp)
        lw a2, 8(sp)
        lw a3, 12(sp)
        
        bltz s0, overflow_error_String2Int
        addi a1, a1, 1 # passo al prossimo carattere
        j loop_String2Int
    overflow_error_String2Int:
        lw a2, overflowError
    end_String2Int:
        mv a0, s0 # salvare il risultato finale nel registro a0
        lw ra, 0(sp)
        addi sp, sp, 16
        ret
# End

SkipSpaces:
# Salta gli spazi bianchi nell'espressione.
# a1: L'indirizzo (puntatore) dell'espressione aritmetica (input)
    li t0, 32 # 32 = ' ' in ASCII
    loop_SkipSpaces:
        lb t1, 0(a1)
        beq t0, t1 skip
        j end_SkipSpaces
    skip:
        addi a1, a1, 1
        j loop_SkipSpaces
    end_SkipSpaces:
        ret
# End

ReadOperand:
# Legge un operando dall'espressione.
# a0 (return): Il carattere dell'operando letto.
# a1: L'indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
# a3: Contatore delle parentesi aperte
    addi sp, sp -4
    sw ra, 0(sp)
    jal SkipSpaces  # a1 = l'indirizzo dell'espressione aritmetica (input)

    li t0, 40 # 40 = parentesi aperta
    li t1, 48 # 48 = '0'
    li t2, 57 # 57 = '9'
    
    lb t3, 0(a1) # t3 = carattere attuale
    beq t3, t0 parentheses
    blt t3, t1 syntax_error_ReadOperand
    bgt t3, t2 syntax_error_ReadOperand
    j end_ReadOperand
    parentheses:
        addi a3, a3, 1
        addi a1, a1, 1 # passo al prossimo carattere
        j end_ReadOperand
    syntax_error_ReadOperand:
        lw a2, syntaxError
    end_ReadOperand:
        mv a0, t3 # restituire il carattere letto
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End

ReadOperator:
# Legge un operatore dall'espressione.
# a0 (return): Il carattere dell'operatore letto.
# a1: L'indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
    addi sp, sp -4
    sw ra, 0(sp)
    jal SkipSpaces  # a1 = indirizzo dell'espressione matematica (input)
    
    li t0, 43 # 43 = +
    li t1, 45 # 45 = -
    li t2, 42 # 42 = *
    li t3, 47 # 47 = /
    
    lb t4, 0(a1) # t4 = carattere attuale
    beq t4, t0 end_ReadOperator
    beq t4, t1 end_ReadOperator
    beq t4, t2 end_ReadOperator
    beq t4, t3 end_ReadOperator
    # gestione dell'errore
    lw a2, syntaxError
    end_ReadOperator:
        addi a1, a1, 1 # passo al prossimo carattere
        mv a0, t4 # restituire il carattere letto
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End
    
# Operazioni aritmetiche >>>
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

Subtraction:
# Esegue una sottrazione sicura tra due interi con controllo dell'overflow.
# a0 (return): La differenza tra a e b
# a1: Primo intero (a)
# a2: Secondo intero (b)
# a3: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
    # t0 = INT32_MIN
    # t1 = INT32_MAX
    # restituire il risultato della sottrazione anche nel caso di overflow
    sub a0, a1, a2
    
    bgtz a2, positive_b_Subtraction
    lw t1, INT32_MAX
    add t1, t1, a2
    blt t1, a1 overflow_error_Subtraction
    ret
    positive_b_Subtraction:
        lw t0, INT32_MIN
        add t0, t0, a2
        blt a1, t0 overflow_error_Subtraction
        ret
    overflow_error_Subtraction:
        lw a3, overflowError
        ret
# End

Multiplication:
# L'implementazione dell'algoritmo di Booth. Esegue una moltiplicazione sicura tra due interi con controllo dell'overflow.
# a0 (return): Il prodotto di a e b
# a1: Primo intero (a), registro Moltiplicando (M) (rimane costante)
# a2: Secondo intero (b), registro Moltiplicatore (Q)
# a3: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
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
            # salvo il risultato ne registro a0
            mv a0, a2 # gli ultimi 32 bit del prodotto si trovano in Q
            
            # controllo dell'Overflow
            # due casi di controllo
            bnez t0 overflow_error_Multiplication
            srai t5, t0, 31 # il segno di A
            srai t6, a2, 31 # il segno di Q (moltiplicatore)
            bne t5, t6 overflow_error_Multiplication
            ret
    overflow_error_Multiplication:
        lw a3, overflowError
        ret
# End

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
# <<<
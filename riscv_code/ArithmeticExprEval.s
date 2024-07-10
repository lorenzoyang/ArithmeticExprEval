.data
# Espressioni aritmetiche >>>
# ((1+2)*(3*2))-(1+(1024/3))
# ((00000-2)*(1024+1024)) / 2
# 1+(1+(1+(1+(1+(1+(1+0))))))
# 2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(1024*1024)))))))))))
# 2147483647+0
# 2147483647+1
# (0-2147483647)-1
# (0-2147483647)-2

input: .string ""

# <<<

# Tipi di errore >>>
syntaxError: .word 1                  # Errore di sintassi
syntaxErrorOperand: .word 11          # Errore di operando
syntaxErrorOperator: .word 12         # Errore di operatore
divisionByZeroError: .word 2          # Errore di divisione per zero
overflowErrorAddition: .word 31       # Errore di overflow nell'addizione
overflowErrorSubtraction: .word 32    # Errore di overflow nella sottrazione
overflowErrorMul: .word 33            # Errore di overflow nella moltiplicazione
overflowErrorDiv: .word 34            # Errore di overflow nella divisione
overflowErrorString2Int: .word 35     # Errore di overflow nella conversione
parenthesesError: .word 4             # Errore di parentesi
# <<<

# Messaggi di errore >>>
syntaxErrorMsg: .string                 "Espressione non valida!"
syntaxErrorOperandMsg: .string          "Espressione non valida: deve esserci un operando valido in posizione "
syntaxErrorOperatorMsg: .string         "Espressione non valida: deve esserci un operatore valido in posizione "
divisionByZeroErrorMsg: .string         "Divisione per 0 !"
overflowErrorAdditionMsg: .string       "Overflow! (durante l'operazione di addizione)"
overflowErrorSubtractionMsg: .string    "Overflow! (durante l'operazione di sottrazione)"
overflowErrorMulMsg: .string            "Overflow! (durante l'operazione di moltiplicazione)"
overflowErrorDivMsg: .string            "Overflow! (durante l'operazione di divisione)"
overflowErrorString2IntMsg: .string     "Overflow! (durante la conversione di una stringa in numero)"
parenthesesErrorMsg: .string            "Parentesi non bilanciate"
# <<<

# Costanti >>>
INT32_MIN: .word -2147483648
INT32_MAX: .word 2147483647
# <<<

# Altre variabili >>>
# Posizione dell'eventuale errore
error_location: .word 0    # stampato solo in caso di errore di sintassi dell'operando o dell'operatore
# <<<

.text
Main:
    # Preparo gli argomenti per richiamare la funzione Eval
    la a1, input    # l'indirizzo della stringa (espressione aritmetica)
    jal Eval
    
    # Switch case per la gestione dell'errore
    
    beq a2, zero case_no_error
    
    lw t0, syntaxError
    beq a2, t0 case_syntax_error
    
    lw t0 syntaxErrorOperand
    beq a2, t0 case_syntax_error_operand
    
    lw t0 syntaxErrorOperator
    beq a2, t0 case_syntax_error_operator
    
    lw t0, divisionByZeroError
    beq a2, t0 case_division_by_zero_error
    
    lw t0, overflowErrorAddition
    beq a2, t0 case_overflow_error_addition
    
    lw t0, overflowErrorSubtraction
    beq a2, t0 case_overflow_error_subtraction
    
    lw t0, overflowErrorMul
    beq a2, t0 case_overflow_error_mul
    
    lw t0, overflowErrorDiv
    beq a2, t0 case_overflow_error_division
    
    lw t0, overflowErrorString2Int
    beq a2, t0 case_overflow_error_string2int
    
    lw t0, parenthesesError
    beq a2, t0 case_parentheses_error
    
    j end_Main
    
    case_no_error:
        mv a0, a0
        li a7, 1
        ecall
        j end_Main
    case_syntax_error:
        la a0, syntaxErrorMsg
        li a7, 4
        ecall
        j end_Main
    case_syntax_error_operand:
        la a0, syntaxErrorOperandMsg
        li a7, 4
        ecall
        lw a0, error_location    # stampare la posizione di errore
        li a7, 1
        ecall
        j end_Main
    case_syntax_error_operator:
        la a0, syntaxErrorOperatorMsg
        li a7, 4
        ecall
        lw a0, error_location    # stampare la posizione di errore
        li a7, 1
        ecall
        j end_Main
    case_division_by_zero_error:
        la a0, divisionByZeroErrorMsg
        li a7, 4
        ecall
        j end_Main
    case_overflow_error_addition:
        la a0, overflowErrorAdditionMsg
        li a7, 4
        ecall
        j end_Main
    case_overflow_error_subtraction:
        la a0, overflowErrorSubtractionMsg
        li a7, 4
        ecall
        j end_Main
    case_overflow_error_mul:
        la a0, overflowErrorMulMsg
        li a7, 4
        ecall
        j end_Main
    case_overflow_error_division:
        la a0, overflowErrorDivMsg
        li a7, 4
        ecall
        j end_Main
    case_overflow_error_string2int:
        la a0, overflowErrorString2IntMsg
        li a7, 4
        ecall
        j end_Main
    case_parentheses_error:
        la a0, parenthesesErrorMsg
        li a7, 4
        ecall
    end_Main:
        li a7, 10
        ecall
# End

Eval:
# Valuta un'espressione aritmetica.
# a0 (return): Risultato dell'espressione
# a1: Indirizzo (puntatore) dell'espressione aritmetica (input)
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a1, 4(sp) # salvare l'indirizzo originale
    
    # Preparo gli argomenti per richiamare la funzione ricorsiva di implementazione
    # a1 rimane lo stesso
    mv a2, zero    # a2: Tipo di errore che verra' impostato in caso di errore (0 => nessun errore)
    mv a3, zero    # a3: numero di parentesi aperte
    jal Evaluate    # richiamare la funzione principale (ricorsiva)
    
    lw t0, 4(sp)    # riprendere l'indirizzo iniziale
    sub t0, a1, t0    # t0 = a1(l'indirizzo modificato) - t0(l'indirizzo iniziale)
    addi t0, t0, 1
    la t1, error_location
    sw t0, 0(t1)
    
    beqz a3 end_Eval # se a3 e' 0 vuol dire che le parentesi sono bilanciate
    # Gestione dell'errore di parentesi
    lw a2, parenthesesError
    mv a0, zero
    
    end_Eval:
        lw ra, 0(sp)
        addi, sp, sp, 8
        # Il valore di ritorno e' salvato in a0 da Evaluate
        ret
# End

Evaluate:
# Funzione (ricorsiva) principale per la valutazione delle espressioni.
# Attenzione: gli argomenti dei seguenti parametri
#     sono condivisi con le funzioni di supporto seguenti:
#         String2Int, SkipSpaces, ReadOperand, ReadOperator
#     Gli argomenti sono quindi passati "per riferimento"
# a0 (return): Risultato della valutazione dell'espressione
# a1: Indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato in caso di errore (0 => nessun errore)
# a3: Contatore delle parentesi aperte
    # s0: left (operando sinistro)
    # s1: right (operando destro)
    # s2: op (operatore)
    # s3: c (char) variabile locale per ricevere l'output della funzione di lettura
    # (Registri da preservare: ra, s0, s1, s2, s3)
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    
    # Inizializzazione delle variabili locali
    mv s0, zero
    mv s1, zero
    mv s2, zero
    mv s3, zero
    
    # Lettura del primo operando
    jal ReadOperand
    bnez a2, end_Evaluate    # controllo dell'eventuale errore
    mv s3, a0    # c = ReadOperand(...)
    li t0, 40    # 40 = parentesi aperta
    beq s3, t0 recursive_call_left
    
    jal String2Int
    bnez a2, end_Evaluate    # controllo dell'eventuale errore
    mv s0, a0    # left = String2Int(...)
    j read_operator
    
    recursive_call_left:
        jal Evaluate
        bnez a2, end_Evaluate    # controllo dell'eventuale errore
        mv s0, a0    # left = Evaluate(...)
        
    read_operator:
        jal ReadOperator
        bnez a2, end_Evaluate    # controllo dell'eventuale errore
        mv s2, a0    # op (operatore) = ReadOperator(...)
        
    # Lettura del secondo operando
    jal ReadOperand
    bnez a2, end_Evaluate    # controllo dell'eventuale errore
    mv s3, a0    # c = ReadOperand(...)
    li t0, 40    # 40 = parentesi aperta
    beq s3, t0 recursive_call_right
    
    jal String2Int
    bnez a2, end_Evaluate    # controllo dell'eventuale errore
    mv s1, a0    # right = String2Int(...)
    j final_phase
    
    recursive_call_right:
        jal Evaluate
        bnez a2, end_Evaluate    # controllo dell'eventuale errore
        mv s1, a0    # right = Evaluate(...)
        
    final_phase:
        jal SkipSpaces
        # Controllo della chiusura delle parentesi
        lb t0, 0(a1)    # carattere attuale
        li t1, 41    # 41 = parentesi chiusa
        beq t0, t1 close_parentheses
        
        # Se non e' una parentesi chiusa, controllo eventuali errori di sintassi
        bnez t0, syntax_error_Evaluate # se t0 != NULL (0)
        j calculate_result 
               
    close_parentheses:
        addi a3, a3, -1
        bltz a3, parentheses_error_Evaluate
        addi a1, a1, 1
        j calculate_result
        
    syntax_error_Evaluate:
        lw a2, syntaxError
        j end_Evaluate
        
    parentheses_error_Evaluate:
        lw a2, parenthesesError
        j end_Evaluate
        
    calculate_result:
        addi sp, sp, -12
        sw a1, 0(sp)
        sw a2, 4(sp)
        sw a3, 8(sp)
        # Preparazione degli argomenti per la richiamata
        mv a1, s0
        mv a2, s1
        mv a3, zero
        
        # switch case
        li t1, 43 # 43 = +
        beq s2, t1 case_addition
        li t1, 45 # 45 = -
        beq s2, t1 case_subtraction
        li t1, 42 # 42 = *
        beq s2, t1 case_mul
        li t1, 47 # 47 = /
        beq s2, t1 case_division
        
        restore_arguments:
            # Salvataggio di eventuali errori generati dalle operazioni aritmetiche
            mv t0, a3
            lw a1, 0(sp)
            lw a2, 4(sp)
            lw a3, 8(sp)
            addi sp, sp, 12 
            beqz a2 save_error    # (0 => a2 non contiene nessun errore)
            j end_Evaluate
            save_error:
                mv a2, t0
                
    end_Evaluate:
        mv a0, a0 # risultato da restituire
        lw ra, 0(sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        addi, sp, sp, 20
        ret
        
    case_addition:
        jal Addition
        j restore_arguments
    case_subtraction:
        jal Subtraction
        j restore_arguments
    case_mul:
        jal Mul
        j restore_arguments
    case_division:
        jal Div
        j restore_arguments
# End

String2Int:
# Converte una stringa in un intero.
# a0 (return): Intero convertito dalla stringa
# a1: Indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
    # I registri da preservare: ra, s0, s1, s2, s3
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    # Si utilizzano i registri che iniziano con 's' perche' questi registri non devono essere modificati dopo una richiamata di un'altra funzione
    # Registro s0 per salvare il risultato finale
    
    mv s0, zero
    li s1, 48    # 48 = '0'
    li s2, 57    # 57 = '9'
    
    loop_String2Int:
        lb s3, 0(a1)    # s3 = carattere attuale
        blt s3, s1 end_String2Int # Se il carattere e' minore di '0', termina la conversione
        bgt s3, s2 end_String2Int # Se il carattere e' maggiore di '9', termina la conversione
        sub s3, s3, s1    # Converte il carattere da ASCII a valore numerico ('char' -> int)
        
        # Richiamare Mul
        addi sp, sp, -12
        sw a1, 0(sp)
        sw a2, 4(sp)
        sw a3, 8(sp)
        mv a1, s0
        li a2, 10
        jal Mul
        mv s0, a0
        add s0, s0, s3
        lw a1, 0(sp)
        lw a2, 4(sp)
        lw a3, 8(sp)
        addi sp, sp, 12
        
        addi a1, a1, 1    # puntatore punta al prossimo carattere dell'espressione
         
        bltz s0, overflow_error_String2Int       
        j loop_String2Int
        
    overflow_error_String2Int:
        lw a2, overflowErrorString2Int    # imposta il tipo di errore di overflow
    
    end_String2Int:
        mv a0, s0    # salvare il risultato finale nel registro a0
        lw ra, 0(sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        addi sp, sp, 20
        ret
# End

SkipSpaces:
# Salta gli spazi bianchi nell'espressione.
# a0: void, non restituisce nulla
# a1: Indirizzo (puntatore) dell'espressione aritmetica (input)
    li t0, 32    # 32 = ' ' in ASCII
    
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
# a0 (return): Carattere dell'operando letto.
# a1: Indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
# a3: Contatore delle parentesi aperte
    addi sp, sp -4
    sw ra, 0(sp)
    jal SkipSpaces    # a1 = l'indirizzo dell'espressione aritmetica (input)

    li t0, 40    # 40 = parentesi aperta
    li t1, 48    # 48 = '0'
    li t2, 57    # 57 = '9'
    
    lb t3, 0(a1)    # t3 = carattere attuale
    beq t3, t0 parentheses
    blt t3, t1 syntax_error_ReadOperand
    bgt t3, t2 syntax_error_ReadOperand
    j end_ReadOperand
    
    parentheses:
        addi a3, a3, 1
        addi a1, a1, 1    # passa al prossimo carattere
        j end_ReadOperand
        
    syntax_error_ReadOperand:
        lw a2, syntaxErrorOperand
        
    end_ReadOperand:
        mv a0, t3    # restituisce il carattere letto
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End

ReadOperator:
# Legge un operatore dall'espressione.
# a0 (return): Carattere dell'operatore letto.
# a1: Indirizzo (puntatore) dell'espressione aritmetica (input)
# a2: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
    addi sp, sp -4
    sw ra, 0(sp)
    jal SkipSpaces    # a1 = l'indirizzo dell'espressione aritmetica (input)
    
    li t0, 43    # 43 = +
    li t1, 45    # 45 = -
    li t2, 42    # 42 = *
    li t3, 47    # 47 = /
    
    lb t4, 0(a1)    # t4 = carattere attuale
    beq t4, t0 next_then_end
    beq t4, t1 next_then_end
    beq t4, t2 next_then_end
    beq t4, t3 next_then_end
    
    # Gestione dell'errore
    lw a2, syntaxErrorOperator
    j end_ReadOperator
    
    next_then_end:
        addi a1, a1, 1    # passa al prossimo carattere
    end_ReadOperator:
        mv a0, t4    # restituisce il carattere letto
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End
    
# Operazioni aritmetiche >>>
Addition:
# Esegue un'addizione sicura tra due interi con controllo dell'overflow.
# a0 (return): Somma di a e b
# a1: Primo intero (a)
# a2: Secondo intero (b)
# a3: Tipo di errore che verra' impostato se si verifica un errore (0 => nessun errore)
    # t0 = INT32_MIN
    # t1 = INT32_MAX
    
    # Restituisce il risultato dell'addizione anche nel caso di overflow (debug)
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
        lw a3, overflowErrorAddition
        ret
# End

Subtraction:
# Esegue una sottrazione sicura tra due interi con controllo dell'overflow.
# a0 (return): Differenza tra a e b
# a1: Primo intero (a)
# a2: Secondo intero (b)
# a3: Tipo di errore che verra' impostato in caso di errore (0 => nessun errore)
    # t0 = INT32_MIN
    # t1 = INT32_MAX
    
    # Restituisce il risultato della sottrazione anche nel caso di overflow (debug)
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
        lw a3, overflowErrorSubtraction
        ret
# End

Mul:
# Implementazione dell'algoritmo di Booth. Esegue una moltiplicazione sicura tra due interi con controllo dell'overflow.
# a0 (return): Prodotto di a e b
# a1: Primo intero, registro Moltiplicando (M) (rimane costante)
# a2: Secondo intero, registro Moltiplicatore (Q)
# a3: Tipo di errore che verra' impostato in caso di errore (0 => nessun errore)
    # t0: registro Accumulatore (A)
    # t1: registro Q_-1 (solo l'ultimo bit, usato come il bit della posizione -1 di Q)
    # t2: registro contatore (contiene il numero di bit del moltiplicatore)
    # t3: complemento a due del moltiplicando
    # t4: registro Q_0 (l'ultimo bit di Q)
    # Il prodotto della moltiplicazione e' composto da 64 bit, si considerano solo gli ultimi 32 bit
    
    # Inizializzazione:
    # a1(M), a2(Q) gia' inizializzati
    mv t0, zero
    mv t1, zero
    li t2, 32
    neg t3, a1
    # t4(Q_0) inizializzato nel loop seguente
    
    # Controllo dei casi particolari di overflow: INT32_MIN * -1
    lw t5, INT32_MIN
    beq a1, t5 check_multiplier
    beq a2, t5 check_multiplier
    j Booth_loop
    
    check_multiplier:
        li t6, -1
        beq a1, t6 overflow_error_Mul
        beq a2, t6 overflow_error_Mul
    
    Booth_loop:
        andi t4, a2, 1       # Q_0
        beq t4, t1 shift     # Q_0 == Q_-1
        beq t4, zero addM    # Q_0 == 0 => Q_-1 == 1
        j subM               # Q_0 == 1 => Q_-1 == 0
        addM:
            add t0, t0, a1
            j shift
        subM:
            add t0, t0, t3
            j shift
        shift:
            mv t1, t4    # Q_-1 riceve il valore di Q_0
            srli a2, a2, 1    # spostamento logico a destra di 1 
            # Il primo bit di Q e' sicuramente 0
            andi t5, t0, 1    # t5 = il bit meno significativo di A
            slli t5, t5, 31    # l'ultimo bit di A diventa il bit piu' significativo di t5
            or a2, a2, t5
            # Spostamento aritmetico a destra per A
            srai t0, t0, 1
            addi t2, t2, -1    # decrementa il contatore
            bnez t2, Booth_loop
            # Salvo il risultato nel registro a0
            mv a0, a2    # gli ultimi 32 bit del prodotto si trovano in Q
            
            # Controllo dell'overflow
            # Due casi di overflow
            li t5, 0xFFFFFFFF    # 32 volte 1
            beqz t0 all_zeros
            beq t0, t5 all_ones
            j overflow_error_Mul
            all_zeros:
                bgez a0 end_Mul
                j overflow_error_Mul
            all_ones:
                bltz a0 end_Mul
            overflow_error_Mul:
                lw a3, overflowErrorMul
            end_Mul:
                ret
# End

Div:
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
        bltz a0, overflow_error_Division
        
        ret
        set_negative_sign:
            neg a0, a0
            ret
    division_by_zero_error:
        lw a3, divisionByZeroError
        mv a0, zero
        ret
    overflow_error_Division:
        lw a3, overflowErrorDiv
        ret
# End
# <<<
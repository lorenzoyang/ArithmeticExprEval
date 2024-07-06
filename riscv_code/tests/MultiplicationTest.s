.data

overflowError: .word 3 # errore di overflow
overflowErrorMsg: .string "errore di overflow"

.text

test:
    li a1, -2147483648
    li a2, -1
    mv a3, zero
    
    jal Multiplication
    
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


Multiplication:
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
        beq a1, t6 overflow_error_Multiplication
        beq a2, t6 overflow_error_Multiplication
    
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
            j overflow_error_Multiplication
            all_zeros:
                bgez a0 end_Multiplication
                j overflow_error_Multiplication
            all_ones:
                bltz a0 end_Multiplication
            overflow_error_Multiplication:
                lw a3, overflowErrorMultiplication
            end_Multiplication:
                ret

# End
.data

overflowError: .word 3 # errore di overflow
overflowErrorMsg: .string "errore di overflow"

.text

test:
    li a1, 1073741823
    li a2, 3
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

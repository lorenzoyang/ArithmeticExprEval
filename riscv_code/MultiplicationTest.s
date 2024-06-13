.data

state: .word 0 # indica lo stato del programma

overflowError: .word 3 # errore di overflow
overflowErrorMsg: .string "errore di overflow"

.text

test:
    li a1, -2
    li a2, 214
    
    jal Multiplication
    
    lw t0, state
    lw t1, overflowError
    bne t0, t1 success
    
    la a0, overflowErrorMsg
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
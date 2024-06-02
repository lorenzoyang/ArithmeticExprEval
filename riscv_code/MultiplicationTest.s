.data

state: .word 0 # indica lo stato del programma

overflowError: .word 3 # errore di overflow
overflowErrorMsg: .string "errore di overflow"

.text

test:
    li a1, -1
    li a2, 2147483647
    
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
#     a0: risultato della moltiplicazione
#     a1: moltiplicando
#     a2: moltiplicatore
Multiplication:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # a1: rimane come il registro Moltiplicando (M) (rimane costante)
    # a2: registro Moltiplicatore (Q)
    # t0: registro Accumulatore
    # t1: registro Q_-1 (si usa il suo ultimo bit, come il bit della posizione -1 di Q)
    # t2: registro contatore (contiene il numero dei bit del moltiplicatore)
    # t3: complemento a due del moltiplicando
    # t4: l'ultimo bit del Q (Q_0)
    # il risultato sara' formato dai bit del Q e dell'Accumulatore
    
    #inizializzazione:
    # a1(M), a2(Q) gia' inizializzati
    mv t0, zero
    mv t1, zero # si usa il suo ultimo bit
    li t2, 32 # il numero di bit del moltiplicatore
    neg t3, a1 # t3 = -M
    # t4(Q_0) inizializzato nel loop
    
    Booth_loop:
        andi t4, a2, 1 # Q_0
        
        beq t4, t1 shift # Q_0 == Q_-1
        
        beq t4, zero addM # Q_0 == 0 => Q_-1 == 1
        
        j subM
        
        addM:
            add t0, t0, a1
            j shift
        
        subM:
            add t0, t0, t3
            j shift
    
        shift:
            mv t1, t4 # Q_-1 diventa Q_0
            srli a2, a2, 1 # spostamento logico di 1
        
            # il primo bit del Q e' sicuramente 0
            andi t5, t0, 1 # t5 = LSB dell'Accumulatore
            slli t5, t5, 31 # l'ultimo bit dell'Accumulatore diventa MSB del t5
        
            or a2, a2, t5 # alla fine
        
            # Spostamento aritmetico a destra per Accumulatore
            srai t0, t0, 1
        
            addi t2, t2, -1
        
            bnez t2, Booth_loop
            
            mv a0, a2 # il prodotto da 32 bit si trova nel Q
            beqz t0 end_Multiplication
            
            # Overflow Error
            la t5, state
            lw t6, overflowError
            sw t6, 0(t5)
            mv a0, zero 
            
    end_Multiplication:
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End
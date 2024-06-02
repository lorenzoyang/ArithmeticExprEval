.data

state: .word 0 # indica lo stato del programma

divisionByZeroError: .word 2 # divisione per lo zero
divisionByZeroErrorMsg: .string "divisione per lo zero"

.text

test:
    li a1, 10
    li a2, 2
    jal Division



# Function: Division
#     a0: risultato della divisione
#     a1(a): dividendo
#     a2(b): divisore
Division:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    beqz a2 division_by_zero_error
    
     
    
    
    division_by_zero_error:
        
    end_Division:
        lw ra, 0(sp)
        addi sp, sp, 4
        ret
# End
.data
functiekeuze:
    .word 3          # Kies hier de functie: 1, 2, of 3

array: 
    .word 7, 7, 8, 4, 5, 6, 7

.text
.globl _start

_start:
    la t0, functiekeuze
    lw t0, 0(t0)

    li t1, 1
    beq t0, t1, oef1        # keuze == 1 -> oef 1

    li t1, 2
    beq t0, t1, oef2        # keuze == 2 -> oef2

    li t1, 3
    beq t0, t1, oef3        # keuze == 3 -> oef3

    beq x0, x0, exit        # Bij andere keuze sluiten we af


oef1:
    la t0, array        # t0 = adres van array
    lw t1, 0(t0)        # t1 = a 
    lw t2, 4(t0)        # t2 = b
    lw t3, 8(t0)        # t3 = c
    lw t4, 12(t0)       # t4 = d
    lw t5, 16(t0)       # t5 = e

    sub t1, t1, t2      # t1 = a-b
    sub t3, t3, t4      # t3 = c-d
    add t3, t3, t5      # t3 = (c-d) + e
    add t1, t1, t3      # t1 = (a-b) + (c-d) + e

    beq x0, x0, exit    # spring naar exit


oef2:
    la t0, array        # t0 = adres van array        
    lw t1, 20(t0)       # t1 = A[5]
    lw t2, 16(t0)       # t2 = A[4]

    add t1, t1, t2      # t1 = A[5] + A[4]
    srli t1, t1, 2      # t1 >> 2
    sw t1, 24(t0)       # A[6] == t1
    
    beq x0, x0, exit    # spring naar exit


oef3:
    la t0, array        # t0 = basisadres
    li t1, 0            # t1 = i
    li t2, 7            # t2 = k

whileloop:
    slli t3, t1, 2          # offset van adres berekenen t3 = i * 4
    add t3, t0, t3          # adress save[i]
    lw t4, 0(t3)            # t4 heeft waarde van save[i]
    bne t4, t2, exit_while  # save[i] != k --> Exit
    addi t1, t1, 1          # t1 = i + 1
    beq x0, x0, whileloop   # terug naar begin

exit_while:
    beq x0, x0, exit     # spring naar exit 


#algemene exit + printen
exit:
    mv a1, t1
    li a0, 34           # Printen in hexa
    ecall
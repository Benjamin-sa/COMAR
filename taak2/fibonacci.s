
.text
.globl _start

_start:
    li a0, 10           # n = 10 (pas aan naar wens)
    
    # Roep fibonacci functie aan
    jal ra, fibonacci
    
    li a7, 1            # ecall 1 = print integer
    ecall
    
    # Exit programma
    li a7, 10           # syscall voor exit
    ecall

fibonacci:
    # Controleer basis gevallen
    li t0, 1    
    mv t0, a0           # t0 = n (counter)
    li t1, 0            # t1 = F(n-2), start met F(0) = 0
    li t2, 1            # t2 = F(n-1), start met F(1) = 1
    li t3, 2            # t3 = i, start bij 2
    
fib_loop:
    bgt t3, t0, fib_done    # Als i > n, klaar
    
    add t4, t1, t2      # t4 = F(i-2) + F(i-1)
    
    mv t1, t2           # F(n-2) = oude F(n-1)
    mv t2, t4           # F(n-1) = nieuwe F(n)
    
    addi t3, t3, 1
    j fib_loop
    
fib_done:
    mv a0, t2           # Resultaat in a0
    ret
    ²

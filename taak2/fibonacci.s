# Fibonacci berekening in RISC-V
# Berekent het n-de Fibonacci getal
# F(0) = 0, F(1) = 1, F(n) = F(n-1) + F(n-2)

.text
.globl _start

_start:
    li a0, 10           # n = 10 (pas aan naar wens)
    
    # Roep fibonacci functie aan
    jal ra, fibonacci
    
    # Resultaat staat nu in a0
    # Print het resultaat
    # a0 bevat al het resultaat (Fibonacci getal)
    li a7, 1            # syscall 1 = print integer
    ecall
    
    # Exit programma
    li a7, 10           # syscall voor exit
    ecall

# Fibonacci functie (iteratief - zonder stack)
# Input: a0 = n
# Output: a0 = F(n)
fibonacci:
    # Controleer basis gevallen
    li t0, 1
    ble a0, t0, fib_base_case   # Als n <= 1, return n
    
    # Initialiseer variabelen voor iteratieve berekening
    mv t0, a0           # t0 = n (counter)
    li t1, 0            # t1 = F(n-2), start met F(0) = 0
    li t2, 1            # t2 = F(n-1), start met F(1) = 1
    li t3, 2            # t3 = iterator (start bij 2)
    
fib_loop:
    bgt t3, t0, fib_done    # Als i > n, klaar
    
    # Bereken F(i) = F(i-1) + F(i-2)
    add t4, t1, t2      # t4 = F(i-2) + F(i-1)
    
    # Shift waarden: F(i-2) = F(i-1), F(i-1) = F(i)
    mv t1, t2           # F(n-2) = oude F(n-1)
    mv t2, t4           # F(n-1) = nieuwe F(n)
    
    # Increment iterator
    addi t3, t3, 1
    j fib_loop
    
fib_done:
    mv a0, t2           # Resultaat in a0
    ret
    
fib_base_case:
    # Voor n <= 1, return n zelf
    # a0 bevat al n, dus niets te doen
    ret

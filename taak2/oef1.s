.data
lab:
    .byte 'p'
    .byte 'a'
    .byte 'n'
    .byte 'n'
    .byte 'e'
    .byte 'k'
    .byte 'o'
    .byte 'e'
    .byte 'k'
    .byte 0

.text
.globl _start

_start:
    # Print de originele string
    la a0, lab
    jal print_string
    
    # Print newline
    li a0, 10
    li a1, 11
    ecall
    
    # Bereken lengte en keer string om
    la t0, lab      # begin adres van string
    li t1, 0        # waarde van i 
    lb t3, 0(t0)    # begin waarde van string
    li t4, 0        # waarde n voor wissel

whileloop:
    beq t3, x0, wissel
    add t2, t1, t0
    lb  t3, 0(t2)
    addi t1, t1, 1
    beq x0, x0, whileloop

wissel:
    addi t1, t1, -1     # t1 = lengte - 1
    li t4, 0            # t4 = start index
    
loop_swap:
    bge t4, t1, print_reversed  # als start >= end, klaar met omdraaien
    
    # Wissel string[t4] met string[t1]
    add t5, t0, t4      # adres van string[t4]
    add t6, t0, t1      # adres van string[t1]
    
    lb s0, 0(t5)        # laad string[t4]
    lb s1, 0(t6)        # laad string[t1]
    
    sb s1, 0(t5)        # sla string[t1] op in string[t4]
    sb s0, 0(t6)        # sla string[t4] op in string[t1]
    
    addi t4, t4, 1      # start++
    addi t1, t1, -1     # end--
    beq x0, x0, loop_swap

print_reversed:
    # Print de omgekeerde string
    la a0, lab
    jal print_string
    
    # Print newline
    li a0, 10
    li a1, 11
    ecall
    
    # Exit
    li a1, 10
    ecall

# Functie om een string uit te printen
print_string:
    mv t0, a0           # bewaar string adres
print_loop:
    lb a0, 0(t0)        # laad karakter
    beq a0, x0, print_end  # als null, stop
    li a1, 11           # syscall voor print character
    ecall
    addi t0, t0, 1      # volgende karakter
    beq x0, x0, print_loop
print_end:
    ret

    




    

    
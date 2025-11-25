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
    la t0, lab
    jal print_string
    
    # Bereken lengte van string
    la t0, lab          # begin adres van string
    li t1, 0            # teller voor lengte

lengte_berekenen:
    add t2, t0, t1      # adres van huidig karakter
    lb t3, 0(t2)        # laad karakter
    beq t3, x0, print_omgekeerd  # als null, start omgekeerd printen
    addi t1, t1, 1      # lengte++
    j lengte_berekenen

print_omgekeerd:
    # Print de omgekeerde string (van einde naar begin)
    addi t1, t1, -1     # t1 = laatste index (lengte - 1)
    la t0, lab          # begin adres van string

print_omgekeerd_loop:
    blt t1, x0, end_program  # als index < 0, klaar
    
    add t2, t0, t1      # adres van karakter op positie t1
    lb a1, 0(t2)        # laad karakter in a1
    li a0, 11           # syscall ID = print character
    ecall
    
    addi t1, t1, -1     # ga naar vorig karakter
    j print_omgekeerd_loop

end_program:
    ecall
    # Exit
    li a0, 10           # syscall ID = exit
    ecall


print_string:
print_loop:
    lb a1, 0(t0)        # laad karakter in a1
    beq a1, x0, print_end  # als null, stop
    li a0, 11           # syscall ID = print character
    ecall
    addi t0, t0, 1      # volgende karakter (bytes!)
    j print_loop

print_end:
    ret 

    




    

    
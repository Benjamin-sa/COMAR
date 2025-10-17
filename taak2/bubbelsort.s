.data
    lengte: .word 10
    array: .word 2, 4, 8, 5, 1, 9, 2, 8, 9, 25

.text
.globl _start

_start:
    # probeer lengte te laden
    la t0, lengte           
    lw t1, 0(t0)            
    la t2, array            # hier start de array
    
    # print originele array
    li t3, 0
print_origineel:
    bge t3, t1, klaar_print_origineel
    lw a0, 0(t2)
    li a7, 1
    ecall
    addi t2, t2, 4
    addi t3, t3, 1
    j print_origineel
    
klaar_print_origineel:
    # reset alles voor sorting
    la t2, array
    
    # probeer bubble sort te doen
    # ik denk dat ik veel lussen nodig heb
    li t3, 0                # outer counter misschien?
    
outer_lus:
    # check of we klaar zijn
    bge t3, t1, klaar_met_sorteren
    
    # reset voor inner loop
    la t2, array
    li t4, 0                # inner counter
    
inner_lus:
    # volgens mij lengte - 1?
    addi t5, t1, -1
    bge t4, t5, klaar_inner_lus
    
    # vergelijk twee naast elkaar
    lw t6, 0(t2)            # eerste getal
    lw a1, 4(t2)            # tweede getal (gebruik a1 want dat werkte eerder)
    
    # als eerste > tweede, dan wissel
    bgt t6, a1, doe_wissel
    j niet_wisselen
    
doe_wissel:
    # wissel ze om
    sw a1, 0(t2)            # zet tweede op eerste plek
    sw t6, 4(t2)            # zet eerste op tweede plek
    
niet_wisselen:
    # ga naar volgende positie
    addi t2, t2, 4
    addi t4, t4, 1
    j inner_lus
    
klaar_inner_lus:
    # volgende outer loop
    addi t3, t3, 1
    j outer_lus
    
klaar_met_sorteren:
    # print gesorteerde array
    la t2, array
    li t3, 0
    
print_gesorteerd:
    bge t3, t1, klaar_print_gesorteerd
    lw a0, 0(t2)
    li a7, 1
    ecall
    addi t2, t2, 4
    addi t3, t3, 1
    j print_gesorteerd
    
klaar_print_gesorteerd:
    # bereken mediaan
    # array is gesorteerd dus gewoon midden pakken
    la t2, array
    
    # is het even of oneven? check met... hoe doe je dat ook alweer
    # probeer met modulo ofzo
    li t3, 2
    rem t4, t1, t3          # t4 = lengte % 2
    
    # als t4 = 0 dan even, anders oneven
    beqz t4, even_aantal
    
oneven_aantal:
    # oneven: pak gewoon het midden
    # midden = lengte / 2
    div t5, t1, t3          # t5 = lengte / 2
    # vermenigvuldig met 4 voor byte offset
    li t6, 4
    mul t5, t5, t6
    add t2, t2, t5          # ga naar midden
    lw a0, 0(t2)
    li a7, 1
    ecall
    j einde
    
even_aantal:
    # even: pak twee middelste en middel ze
    # midden1 = (lengte/2) - 1
    # midden2 = lengte/2
    div t5, t1, t3          # t5 = lengte / 2
    addi t5, t5, -1         # t5 = (lengte/2) - 1
    # keer 4 voor bytes
    li t6, 4
    mul t5, t5, t6
    add t2, t2, t5
    
    lw t3, 0(t2)            # eerste middelste
    lw t4, 4(t2)            # tweede middelste
    add t3, t3, t4          # tel ze op
    # deel door 2
    li t5, 2
    div a0, t3, t5          # a0 = gemiddelde
    li a7, 1
    ecall
    
einde:
    # stop het programma
    li a7, 10
    ecall
       
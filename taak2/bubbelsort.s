.data
    lengte: .word 101
    array: .word 1036, 783, 710, 939, 21, 332, 675, 1398, 1337, 28, 633, 1317, 863, 873, 1094, 886, 1171, 393, 142, 111, 638, 919, 211, 1355, 998, 1131, 821, 930, 195, 276, 704, 330, 337, 160, 133, 1199, 1250, 471, 500, 107, 1466, 774, 644, 1198, 1, 668, 45, 370, 531, 440, 928, 989, 1191, 1310, 13, 1323, 254, 1168, 853, 77, 855, 831, 969, 1435, 716, 861, 239, 1239, 644, 304, 909, 1271, 523, 1360, 183, 917, 1094, 479, 1084, 765, 74, 1438, 1021, 1100, 1494, 600, 1401, 560, 217, 1422, 1383, 505, 1371, 549, 766, 1396, 471, 14, 132, 1082, 400

.text
.globl _start

_start:
    la t0, lengte           
    lw t1, 0(t0)            # t1 = aantal elementen
    la t2, array            # t2 = basis adres
    
    # Print originele array
    li t3, 0                # teller
print_origineel:
    bge t3, t1, klaar_print_origineel
    lw a0, 0(t2)
    li a7, 1
    ecall
    addi t2, t2, 4
    addi t3, t3, 1
    j print_origineel
    
klaar_print_origineel:
    la t2, array
    
    li t3, 0                # i (buitenste lus)
    
outer_lus:
    bge t3, t1, klaar_met_sorteren
    
    la t2, array
    li t4, 0                # j (binnenste lus)
    
inner_lus:
    addi t5, t1, -1         # laatste index
    bge t4, t5, klaar_inner_lus
    
    # Vergelijk array[j] en array[j+1]
    lw t6, 0(t2)            # array[j]
    lw a1, 4(t2)            # array[j+1]
    
    # Als array[j] > array[j+1], wissel
    blt a1, t6, doe_wissel
    j niet_wisselen
    
doe_wissel:
    sw a1, 0(t2)            # Wissel elementen
    sw t6, 4(t2)
    
niet_wisselen:
    addi t2, t2, 4          # Volgende positie
    addi t4, t4, 1
    j inner_lus
    
klaar_inner_lus:
    addi t3, t3, 1          # i++
    j outer_lus
    
klaar_met_sorteren:
    # Print gesorteerde array
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
    # Bereken mediaan
    la t2, array            # reset naar begin
    la t0, lengte
    lw t1, 0(t0)            # Laad lengte opnieuw
    
    # Controleer of lengte even of oneven is
    andi t3, t1, 1          # t3 = lengte & 1 (geeft 1 als oneven, 0 als even)
    
    bnez t3, oneven_mediaan # Als oneven, spring naar oneven_mediaan
    
even_mediaan:
    # even aantal: gemiddelde van twee middelste elementen
    srli t4, t1, 1          # t4 = lengte / 2
    addi t4, t4, -1         # t4 = (lengte / 2) - 1 (index eerste middelste)
    slli t4, t4, 2          # t4 = index * 4 (byte offset)
    add t2, t2, t4          # t2 = adres van eerste middelste element
    
    lw t5, 0(t2)            # t5 = array[lengte/2 - 1]
    lw t6, 4(t2)            # t6 = array[lengte/2]
    add t5, t5, t6          # t5 = som van twee middelste elementen
    srli a0, t5, 1          # a0 = gemiddelde (som / 2)
    j print_mediaan
    
oneven_mediaan:
    # oneven aantal: middelste element
    srli t4, t1, 1          # t4 = lengte / 2 (middelste index)
    slli t4, t4, 2          # t4 = index * 4 (byte offset)
    add t2, t2, t4          # t2 = adres van middelste element
    lw a0, 0(t2)            # a0 = mediaan waarde

print_mediaan:
    # Print mediaan waarde
    li a7, 1
    ecall
    
einde:
    li a7, 10
    ecall
       
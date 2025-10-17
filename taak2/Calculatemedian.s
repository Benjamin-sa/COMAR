.data
    lengte: .word 101
    array: .word 1036, 783, 710, 939, 21, 332, 675, 1398, 1337, 28, 633, 1317, 863, 873, 1094, 886, 1171, 393, 142, 111, 638, 919, 211, 1355, 998, 1131, 821, 930, 195, 276, 704, 330, 337, 160, 133, 1199, 1250, 471, 500, 107, 1466, 774, 644, 1198, 1, 668, 45, 370, 531, 440, 928, 989, 1191, 1310, 13, 1323, 254, 1168, 853, 77, 855, 831, 969, 1435, 716, 861, 239, 1239, 644, 304, 909, 1271, 523, 1360, 183, 917, 1094, 479, 1084, 765, 74, 1438, 1021, 1100, 1494, 600, 1401, 560, 217, 1422, 1383, 505, 1371, 549, 766, 1396, 471, 14, 132, 1082, 400

.text
.globl _start

_start:
    la t0, lengte           # t0 = adres van lengte variabele
    lw t1, 0(t0)            # t1 = lengte van array (aantal elementen)
    la t2, array            # t2 = basis adres van array
    
    # Print originele array 
    li t3, 0                # t3 = teller
print_origineel_lus:
    bge t3, t1, print_origineel_klaar
    lw a0, 0(t2)            # Laad array element
    li a7, 1                # Print integer
    ecall
    addi t2, t2, 4          # Volgende element
    addi t3, t3, 1          # Verhoog teller
    j print_origineel_lus
    
print_origineel_klaar:
    la t2, array            # Reset naar begin van array

    addi t3, t1, -1         # t3 = lengte - 1 (teller voor buitenste lus)
    
buitenste_lus:
    blez t3, einde_buitenste_lus    # Als t3 <= 0, dan klaar met sorteren
    li t5, 0                         # t5 = verwisseld-vlag (0 = niet verwisseld)
    la t2, array                     # Zet t2 terug naar begin van array
    mv t4, t3                        # t4 = teller voor binnenste lus
    
binnenste_lus:
    lw t6, 0(t2)            # t6 = array[j] (huidig element)
    lw a1, 4(t2)            # a1 = array[j+1] (volgend element)
    ble t6, a1, geen_wissel # Als array[j] <= array[j+1], geen wissel nodig
    
    # Wissel de twee elementen om
    sw a1, 0(t2)            # Zet array[j+1] op positie j
    sw t6, 4(t2)            # Zet array[j] op positie j+1
    li t5, 1                # Zet verwisseld-vlag op 1
    
geen_wissel:
    addi t2, t2, 4          # Ga naar volgend element (+ 4 bytes)
    addi t4, t4, -1         # Verminder binnenste teller
    bnez t4, binnenste_lus  # Herhaal binnenste lus als t4 != 0
    
    beqz t5, einde_buitenste_lus    # Als geen wissels, array is gesorteerd
    addi t3, t3, -1                  # Verminder buitenste teller
    j buitenste_lus                  # Herhaal buitenste lus
    
einde_buitenste_lus:

    # Print gesorteerde array (alleen integers)
    la t2, array            # Reset naar begin van array
    la t0, lengte
    lw t1, 0(t0)            # t1 = lengte
    li t3, 0                # t3 = teller
    
print_lus:
    bge t3, t1, print_klaar
    lw a0, 0(t2)            # Laad array element
    li a7, 1                # Print integer
    ecall
    addi t2, t2, 4          # Volgende element
    addi t3, t3, 1          # Verhoog teller
    j print_lus
    
print_klaar:

    # ====== BEREKEN MEDIAAN ======
    la t2, array            # Reset naar begin van array
    la t0, lengte
    lw t1, 0(t0)            # Laad lengte opnieuw
    
    # Controleer of lengte even of oneven is
    andi t3, t1, 1          # t3 = lengte & 1 (geeft 1 als oneven, 0 als even)
    
    bnez t3, oneven_mediaan # Als oneven, spring naar oneven_mediaan
    
even_mediaan:
    # EVEN aantal: gemiddelde van twee middelste elementen
    srli t4, t1, 1          # t4 = lengte / 2
    addi t4, t4, -1         # t4 = (lengte / 2) - 1 (index eerste middelste)
    slli t4, t4, 2          # t4 = index * 4 (byte offset)
    add t2, t2, t4          # t2 = adres van eerste middelste element
    
    lw t5, 0(t2)            # t5 = array[lengte/2 - 1]
    lw t6, 4(t2)            # t6 = array[lengte/2]
    add t5, t5, t6          # t5 = som van twee middelste elementen
    srli a1, t5, 1          # a1 = gemiddelde (som / 2)
    j print_mediaan
    
oneven_mediaan:
    # ONEVEN aantal: middelste element
    srli t4, t1, 1          # t4 = lengte / 2 (middelste index)
    slli t4, t4, 2          # t4 = index * 4 (byte offset)
    add t2, t2, t4          # t2 = adres van middelste element
    lw a0, 0(t2)            # a1 = mediaan waarde

print_mediaan:
    # Print mediaan waarde (alleen integer)
    lw a0, 0(t2)            # Laad mediaan waarde
    li a7, 1                # Print integer
    ecall
    
    # Programma afsluiten
    li a7, 10               # Exit syscall
    ecall

# =============================================================================
# RISC-V Matrix Multiplication: O = I × W (OPTIMIZED VERSION)
# KU Leuven - Computer Architecture Assignment
# =============================================================================


.text
.globl _start

_start:
    # =========================================================================
    # INITIALIZATION SECTION
    # =========================================================================
    
    # --- START CYCLE COUNTER ---
    addi    x27, x0, 1          # x27 = 1 → Cycle counter HIGH (measurement begins)
    
    # --- Initialize base addresses ---
    # Note: Adjust these values to match your testbench memory map
    addi    x20, x0, 0          # x20 = 0x000 = Base address of Matrix I
    addi    x21, x0, 80         # x21 = 0x050 = Base address of Matrix W (after 80 bytes of I)
    addi    x22, x0, 140        # x22 = 0x08C = Base address of Matrix O (after 60 bytes of W)
    
    # --- Initialize constants (avoid recalculating in loops) ---
    addi    x15, x0, 20         # x15 = 20 (I row stride: 5 elements × 4 bytes)
    addi    x16, x0, 12         # x16 = 12 (W/O row stride: 3 elements × 4 bytes)
    addi    x17, x0, 4          # x17 = 4  (element size in bytes)
    addi    x18, x0, 5          # x18 = 5  (inner loop limit: common dimension)
    addi    x19, x0, 3          # x19 = 3  (middle loop limit: W columns)
    addi    x26, x0, 4          # x26 = 4  (outer loop limit: I rows)
    
    # --- Initialize loop indices ---
    addi    x25, x0, 0          # b = 0 (outer loop index)
    
    # --- Calculate initial row bases ---
    add     x12, x20, x0        # x12 = I_base + b×20 = I_base (initially b=0)
    add     x13, x22, x0        # x13 = O_base + b×12 = O_base (initially b=0)

# =============================================================================
# OUTER LOOP: for (b = 0; b < 4; b++) - rows of Matrix I / Matrix O
# =============================================================================
outer_loop:
    addi    x24, x0, 0          # k = 0 (reset middle loop index)
    addi    x14, x0, 0          # Reset W/O column offset (k×4 = 0)

# =============================================================================
# MIDDLE LOOP: for (k = 0; k < 3; k++) - columns of Matrix W / Matrix O
# =============================================================================
middle_loop:
    addi    x5, x0, 0           # sum = 0 (reset accumulator)
    addi    x23, x0, 0          # c = 0 (reset inner loop index)
    add     x9, x12, x0         # x9 = I row base (start of row b in I)
    addi    x28, x0, 0          # Reset W row offset (c×12 = 0)

# =============================================================================
# INNER LOOP: for (c = 0; c < 5; c++) - dot product calculation
# =============================================================================
inner_loop:
    # --- Calculate W[c][k] address ---
    # W_addr = x21 + c×12 + k×4 = x21 + x28 + x14
    add     x10, x21, x28       # x10 = W_base + row_offset(c×12)
    add     x10, x10, x14       # x10 = W[c][k] address
    
    # --- Load matrix elements ---
    lw      x6, 0(x9)           # x6 = I[b][c] (load from current I pointer)
    lw      x7, 0(x10)          # x7 = W[c][k] (load from calculated W address)
    
    # --- Update pointers/offsets for next iteration (fills load-use delay) ---
    add     x9, x9, x17         # x9 += 4 (advance I pointer to next column)
    add     x28, x28, x16       # x28 += 12 (advance W row offset to next row)
    addi    x23, x23, 1         # c++ (increment inner loop counter)
    
    # --- Multiply and accumulate (after loads complete) ---
    mul     x8, x6, x7          # x8 = I[b][c] × W[c][k]
    add     x5, x5, x8          # sum += product
    
    # --- Inner loop branch ---
    blt     x23, x18, inner_loop # if c < 5, continue inner loop

# =============================================================================
# STORE RESULT & MIDDLE LOOP CONTROL
# =============================================================================
    # --- Store O[b][k] = sum ---
    # O_addr = x22 + b×12 + k×4 = x13 + x14
    add     x11, x13, x14       # x11 = O row base + column offset
    sw      x5, 0(x11)          # O[b][k] = sum
    
    # --- Middle loop control: k++ ---
    add     x14, x14, x17       # x14 += 4 (advance column offset)
    addi    x24, x24, 1         # k++
    blt     x24, x19, middle_loop # if k < 3, continue middle loop

# =============================================================================
# OUTER LOOP CONTROL: b++
# =============================================================================
    # --- Update row bases for next iteration ---
    add     x12, x12, x15       # x12 += 20 (advance I row base)
    add     x13, x13, x16       # x13 += 12 (advance O row base)
    addi    x25, x25, 1         # b++
    blt     x25, x26, outer_loop # if b < 4, continue outer loop

# =============================================================================
# PROGRAM COMPLETE
# =============================================================================
    # --- STOP CYCLE COUNTER ---
    addi    x27, x0, 0          # x27 = 0 → Cycle counter LOW (measurement ends)

done:
    beq     x0, x0, done        # Infinite loop (processor halt)

# =============================================================================
# END OF PROGRAM
# =============================================================================

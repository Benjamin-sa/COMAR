# =============================================================================
# RISC-V Matrix Multiplication: O = I × W
# KU Leuven - Computer Architecture Assignment
# =============================================================================

.text
.globl _start

_start:
    # =========================================================================
    # INITIALIZATION
    # =========================================================================
    
    # Start cycle counter - SET x27 = 1 (HIGH)
    addi    x27, x0, 1          # x27 = 1 (cycle counting begins)
    
    # Initialize base addresses (placeholder values - adjust for your memory map)
    addi    x20, x0, 0x000      # x20 = base address of Matrix I
    addi    x21, x0, 0x050      # x21 = base address of Matrix W (after I: 80 bytes)
    addi    x22, x0, 0x08C      # x22 = base address of Matrix O (after W: 60 bytes)
    
    # Initialize outer loop counter
    addi    x25, x0, 0          # b = 0 (outer loop index)

# =============================================================================
# OUTER LOOP: for (b = 0; b < 4; b++) - iterates over rows of I
# =============================================================================
outer_loop:
    # Calculate row offset for Matrix I: b × 20 (5 elements × 4 bytes)
    # Using repeated addition: x12 = b × 20
    addi    x12, x0, 0          # x12 = 0 (I row offset accumulator)
    addi    x1, x0, 0           # x1 = counter for multiplication
    addi    x2, x0, 20          # x2 = 20 (bytes per row in I)
    
calc_i_row_offset:
    beq     x1, x25, calc_i_row_done    # if counter == b, done
    add     x12, x12, x2        # x12 += 20
    addi    x1, x1, 1           # counter++
    beq     x0, x0, calc_i_row_offset   # unconditional jump (BEQ with same reg)
    
calc_i_row_done:
    # Calculate row offset for Matrix O: b × 12 (3 elements × 4 bytes)
    addi    x11, x0, 0          # x11 = 0 (O row offset)
    addi    x1, x0, 0           # x1 = counter
    addi    x2, x0, 12          # x2 = 12 (bytes per row in O)
    
calc_o_row_offset:
    beq     x1, x25, calc_o_row_done    # if counter == b, done
    add     x11, x11, x2        # x11 += 12
    addi    x1, x1, 1           # counter++
    beq     x0, x0, calc_o_row_offset   # unconditional jump
    
calc_o_row_done:
    # Initialize middle loop counter
    addi    x24, x0, 0          # k = 0 (middle loop index)

# =============================================================================
# MIDDLE LOOP: for (k = 0; k < 3; k++) - iterates over columns of W
# =============================================================================
middle_loop:
    # Calculate column offset for W and O: k × 4
    addi    x14, x0, 0          # x14 = 0 (column offset)
    addi    x1, x0, 0           # x1 = counter
    addi    x2, x0, 4           # x2 = 4 (bytes per element)
    
calc_col_offset:
    beq     x1, x24, calc_col_done      # if counter == k, done
    add     x14, x14, x2        # x14 += 4
    addi    x1, x1, 1           # counter++
    beq     x0, x0, calc_col_offset     # unconditional jump
    
calc_col_done:
    # Initialize sum accumulator
    addi    x5, x0, 0           # sum = 0
    
    # Initialize inner loop counter
    addi    x23, x0, 0          # c = 0 (inner loop index)

# =============================================================================
# INNER LOOP: for (c = 0; c < 5; c++) - dot product accumulation
# =============================================================================
inner_loop:
    # -------------------------------------------------------------------------
    # Calculate address of I[b][c]
    # I_addr = x20 + b×20 + c×4 = x20 + x12 + (c×4)
    # -------------------------------------------------------------------------
    
    # Calculate c × 4 (column offset in I row)
    addi    x9, x0, 0           # x9 = 0
    addi    x1, x0, 0           # counter
    addi    x2, x0, 4           # increment
    
calc_c_offset_i:
    beq     x1, x23, calc_c_offset_i_done
    add     x9, x9, x2          # x9 += 4
    addi    x1, x1, 1
    beq     x0, x0, calc_c_offset_i
    
calc_c_offset_i_done:
    # I_addr = x20 + x12 + x9
    add     x9, x20, x12        # x9 = base + row_offset
    add     x9, x9, x9          # Now add column offset - WRONG, need temp
    
    # Recalculate properly
    addi    x9, x0, 0           # Reset x9
    addi    x1, x0, 0           # counter
    addi    x2, x0, 4           # increment
    
calc_c_offset_i_v2:
    beq     x1, x23, calc_c_offset_i_done_v2
    add     x9, x9, x2          # x9 = c × 4
    addi    x1, x1, 1
    beq     x0, x0, calc_c_offset_i_v2
    
calc_c_offset_i_done_v2:
    add     x6, x20, x12        # x6 = I_base + row_offset
    add     x6, x6, x9          # x6 = I[b][c] address
    
    # -------------------------------------------------------------------------
    # Calculate address of W[c][k]
    # W_addr = x21 + c×12 + k×4 = x21 + (c×12) + x14
    # -------------------------------------------------------------------------
    
    # Calculate c × 12 (row offset in W)
    addi    x13, x0, 0          # x13 = 0
    addi    x1, x0, 0           # counter
    addi    x2, x0, 12          # increment (3 columns × 4 bytes)
    
calc_w_row_offset:
    beq     x1, x23, calc_w_row_done
    add     x13, x13, x2        # x13 += 12
    addi    x1, x1, 1
    beq     x0, x0, calc_w_row_offset
    
calc_w_row_done:
    add     x7, x21, x13        # x7 = W_base + row_offset
    add     x7, x7, x14         # x7 = W[c][k] address
    
    # -------------------------------------------------------------------------
    # Load I[b][c] and W[c][k], multiply, accumulate
    # -------------------------------------------------------------------------
    lw      x6, 0(x6)           # x6 = I[b][c] value
    lw      x7, 0(x7)           # x7 = W[c][k] value
    
    # Pipeline optimization: independent instruction between load and use
    # (The MUL will still use x6, x7 but loads complete in MEM stage)
    
    mul     x8, x6, x7          # x8 = I[b][c] × W[c][k]
    add     x5, x5, x8          # sum += x8
    
    # -------------------------------------------------------------------------
    # Inner loop control: c++, check c < 5
    # -------------------------------------------------------------------------
    addi    x23, x23, 1         # c++
    addi    x15, x0, 5          # x15 = 5 (loop limit)
    blt     x23, x15, inner_loop # if c < 5, continue inner loop

# =============================================================================
# STORE RESULT: O[b][k] = sum
# =============================================================================
    # Calculate O[b][k] address = x22 + b×12 + k×4 = x22 + x11 + x14
    add     x10, x22, x11       # x10 = O_base + row_offset
    add     x10, x10, x14       # x10 = O[b][k] address
    sw      x5, 0(x10)          # Store sum to O[b][k]
    
    # -------------------------------------------------------------------------
    # Middle loop control: k++, check k < 3
    # -------------------------------------------------------------------------
    addi    x24, x24, 1         # k++
    addi    x15, x0, 3          # x15 = 3 (loop limit)
    blt     x24, x15, middle_loop # if k < 3, continue middle loop

# =============================================================================
# OUTER LOOP CONTROL: b++, check b < 4
# =============================================================================
    addi    x25, x25, 1         # b++
    addi    x15, x0, 4          # x15 = 4 (loop limit)
    blt     x25, x15, outer_loop # if b < 4, continue outer loop

# =============================================================================
# PROGRAM COMPLETE
# =============================================================================
    # Stop cycle counter - SET x27 = 0 (LOW)
    addi    x27, x0, 0          # x27 = 0 (cycle counting ends)
    
done:
    beq     x0, x0, done        # Infinite loop (halt)

# =============================================================================
# END OF PROGRAM
# =============================================================================

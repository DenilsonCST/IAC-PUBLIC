###########################################################################
# Upper bound constants for static memory reservation
###########################################################################
.equ CONST_DIMENSION 4
.equ CONST_BUFFER_SIZE 1024
.equ CONST_MAX_VOCAB_TOKENS 100
.equ CONST_MAX_INPUT_TOKENS 10

###########################################################################
# System call constants
###########################################################################
.equ CONST_SYSCALL_PRINT_INT 1
.equ CONST_SYSCALL_PRINT_STRING 4
.equ CONST_SYSCALL_PRINT_CHAR 11
.equ CONST_SYSCALL_EXIT 10
.equ CONST_SYSCALL_EXIT2 93
.equ CONST_SYSCALL_OPEN 1024
.equ CONST_SYSCALL_CLOSE 57
.equ CONST_SYSCALL_READ 63
.equ CONST_SYSCALL_WRITE 64

###########################################################################
# ASCII character constants
###########################################################################
.equ CONST_CHAR_EOF 0
.equ CONST_CHAR_SPACE 32
.equ CONST_CHAR_NEWLINE 10
.equ CONST_CHAR_HYPHEN 45
.equ CONST_CHAR_ZERO 48

.data
###########################################################################
# Data section with static memory reservations.
# Feel free to add more if needed.
###########################################################################
VOCABULARY_FILENAME:     .string "vocab.txt"
EMBEDDINGS_FILENAME:     .string "embeddings.txt"
INPUT_FILENAME:          .string "input.txt"

W_Q_FILENAME:            .string "W_Q.txt"
W_K_FILENAME:            .string "W_K.txt"
W_V_FILENAME:            .string "W_V.txt"

VOCAB_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the vocabulary file
INPUT_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the input file
MATRIX_BUFFER:           .zero CONST_BUFFER_SIZE                              # Contents of a matrix file (used for W_Q, W_K, W_V, and embeddings)

INPUT_INDICES_VECTOR:    .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of input token indices (#inputs x 4 bytes)
SCORES_VECTOR:           .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of scores (#tokens x 4 bytes)

INPUT_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the input
VOCAB_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the vocabulary

VOCAB_EMBEDDINGS_MATRIX: .zero (CONST_MAX_VOCAB_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
INPUT_EMBEDDINGS_MATRIX: .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
W_Q_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_Q matrix (dimension x dimension x 4 bytes)
W_K_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_K matrix (dimension x dimension x 4 bytes)
W_V_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_V matrix (dimension x dimension x 4 bytes)
Q_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Q matrix (#tokens x dimension x 4 bytes)
K_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # K matrix (#tokens x dimension x 4 bytes)
V_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # V matrix (#tokens x dimension x 4 bytes)

.text
main:
    ###########################################################################
    # Read vocabulary
    ###########################################################################
    la a0, VOCABULARY_FILENAME
    la a1, VOCAB_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Read input
    ###########################################################################
    la a0, INPUT_FILENAME
    la a1, INPUT_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Read W_Q matrix
    ###########################################################################
    la a0, W_Q_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Parse W_Q matrix from buffer
    ###########################################################################
    la a0, W_Q_MATRIX
    la a1, MATRIX_BUFFER
    jal parse_matrix_buffer

    ###########################################################################
    # Read W_K matrix
    ###########################################################################
    la a0, W_K_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Parse W_K matrix from buffer
    ###########################################################################
    la a0, W_K_MATRIX
    la a1, MATRIX_BUFFER
    jal parse_matrix_buffer

    ###########################################################################
    # Read W_V matrix
    ###########################################################################
    la a0, W_V_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
    la a0, W_V_MATRIX
    la a1, MATRIX_BUFFER
    jal parse_matrix_buffer

    ###########################################################################
    # Read embeddings matrix
    ###########################################################################
    la a0, EMBEDDINGS_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal read_file

    ###########################################################################
    # Parse vocabulary embeddings matrix from buffer
    ###########################################################################
    la a0, VOCAB_EMBEDDINGS_MATRIX
    la a1, MATRIX_BUFFER
    jal parse_matrix_buffer
    la t0, VOCAB_TOTAL_TOKENS
    sw a1, 0(t0)

    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    la a0, INPUT_INDICES_VECTOR
    la a2, INPUT_BUFFER
    la a3, VOCAB_BUFFER
    jal tokens_to_indices
    la t0, INPUT_TOTAL_TOKENS
    sw a1, 0(t0)

    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    la a0, INPUT_EMBEDDINGS_MATRIX
    la a1, VOCAB_EMBEDDINGS_MATRIX
    la a2, INPUT_INDICES_VECTOR
    lw a3, INPUT_TOTAL_TOKENS
    jal build_input_embeddings_matrix

    ###########################################################################
    # Build matrix Q
    ###########################################################################
    la a0, Q_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX
    lw a2, INPUT_TOTAL_TOKENS
    li a3, CONST_DIMENSION
    la a4, W_Q_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal matrix_multiply

    ###########################################################################
    # Build matrix K
    ###########################################################################
    la a0, K_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX
    lw a2, INPUT_TOTAL_TOKENS
    li a3, CONST_DIMENSION
    la a4, W_K_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal matrix_multiply

    ###########################################################################
    # Build matrix V
    ###########################################################################
    la a0, V_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX
    lw a2, INPUT_TOTAL_TOKENS
    li a3, CONST_DIMENSION
    la a4, W_V_MATRIX
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal matrix_multiply

    ###########################################################################
    # Compute scores for the last input token
    ###########################################################################
    la a0, SCORES_VECTOR
    la a1, Q_MATRIX
    la a2, K_MATRIX
    lw a3, INPUT_TOTAL_TOKENS
    li a4, CONST_DIMENSION
    addi a5, a3, -1
    jal compute_scores

    ###########################################################################
    # Get the highest score index using argmax
    ###########################################################################
    la a1, SCORES_VECTOR
    lw a2, INPUT_TOTAL_TOKENS
    jal argmax
    mv s0, a1

    ###########################################################################
    # Select chosen vector in V using the index from argmax
    ###########################################################################
    la a1, V_MATRIX
    lw a2, INPUT_TOTAL_TOKENS
    li a3, CONST_DIMENSION
    mv a4, s0
    jal select_vector_in_matrix
    mv s1, a0

    ###########################################################################
    # Pick the next token in the vocabulary with the highest score
    ###########################################################################
    mv a0, s1
    la a1, VOCAB_EMBEDDINGS_MATRIX
    lw a2, VOCAB_TOTAL_TOKENS
    jal decide_next_token
    mv s2, a0
    la a0, VOCAB_BUFFER
    mv a1, s2
    jal get_token_address
    jal print_predicted_token

    ###########################################################################
    # Terminate program successfully
    ###########################################################################
    li a0, 0
    j exit_with_code                                # Exit with code 0

# Read from a text file into a buffer.
# (in)     a0: filename address (char*)
# (in/out) a1: destination buffer
# (in)     a2: maximum number of bytes to read

read_file:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    mv s0, a1                                      # destination buffer
    mv s1, a2                                      # max bytes
    li a1, 0                                       # flags: read-only
    li a2, 0                                       # mode unused
    li a7, CONST_SYSCALL_OPEN
    ecall
    mv s2, a0                                      # file descriptor
    mv a0, s2
    mv a1, s0
    mv a2, s1
    li a7, CONST_SYSCALL_READ
    ecall
    add t0, s0, a0                                 # null-terminate after bytes read
    sb zero, 0(t0)
    mv a0, s2
    li a7, CONST_SYSCALL_CLOSE
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    ret

# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)

parse_matrix_buffer:
    mv t0, a0                                      # output int pointer
    mv t1, a1                                      # char pointer
    li t2, 0                                       # current number
    li t3, 1                                       # sign
    li t4, 0                                       # reading number flag
    li t5, 0                                       # rows
    li t6, 0                                       # cols in current row
parse_matrix_loop:
    lbu a2, 0(t1)
    beq a2, zero, parse_matrix_eof
    li a3, CONST_CHAR_HYPHEN
    beq a2, a3, parse_matrix_hyphen
    li a3, CONST_CHAR_SPACE
    beq a2, a3, parse_matrix_separator
    li a3, CONST_CHAR_NEWLINE
    beq a2, a3, parse_matrix_newline
    li a3, CONST_CHAR_ZERO
    sub a2, a2, a3
    li a3, 10
    mul t2, t2, a3
    add t2, t2, a2
    li t4, 1
    addi t1, t1, 1
    j parse_matrix_loop
parse_matrix_hyphen:
    li t3, -1
    addi t1, t1, 1
    j parse_matrix_loop
parse_matrix_separator:
    beq t4, zero, parse_matrix_skip_separator
    mul t2, t2, t3
    sw t2, 0(t0)
    addi t0, t0, 4
    addi t6, t6, 1
    li t2, 0
    li t3, 1
    li t4, 0
parse_matrix_skip_separator:
    addi t1, t1, 1
    j parse_matrix_loop
parse_matrix_newline:
    beq t4, zero, parse_matrix_count_row
    mul t2, t2, t3
    sw t2, 0(t0)
    addi t0, t0, 4
    addi t6, t6, 1
    li t2, 0
    li t3, 1
    li t4, 0
parse_matrix_count_row:
    beq t6, zero, parse_matrix_skip_newline
    addi t5, t5, 1
    li t6, 0
parse_matrix_skip_newline:
    addi t1, t1, 1
    j parse_matrix_loop
parse_matrix_eof:
    beq t4, zero, parse_matrix_eof_no_number
    mul t2, t2, t3
    sw t2, 0(t0)
    addi t6, t6, 1
parse_matrix_eof_no_number:
    beq t6, zero, parse_matrix_done
    addi t5, t5, 1
parse_matrix_done:
    mv a1, t5                                      # number of rows
    ret

# Converts the input tokens into their corresponding indices in the vocabulary.
# (in/out) a0: address of input indices vector to fill (int*)
# (out)    a1: size of input indices vector (number of tokens in input)
# (in)     a2: address to input buffer
# (in)     a3: address to vocabulary buffer

tokens_to_indices:
    addi sp, sp, -20                               # Allocate 20 bytes on the stack
    sw ra, 0(sp)                                   # Save return address
    sw s0, 4(sp)                                   # Save s0 register
    sw s1, 8(sp)                                   # Save s1 register
    sw s2, 12(sp)                                  # Save s2 register
    sw s3, 16(sp)                                  # Save s3 register
    mv s0, a0                                      # s0 = output vector pointer
    mv s1, a2                                      # s1 = input token pointer
    mv s2, a3                                      # s2 = vocab buffer base
    li s3, 0                                       # s3 = input token count (initialize to 0)

tokens_outer:
    lbu t1, 0(s1)                                  # Load current character from input string
    beq t1, zero, tokens_done                      # If character is '\0', exit loop
    li t2, CONST_CHAR_NEWLINE                      # Load newline character constant into t2
    beq t1, t2, tokens_skip_input_sep              # If it's a newline, skip it
    li t2, CONST_CHAR_SPACE                        # Load space character constant into t2
    beq t1, t2, tokens_skip_input_sep              # If it's a space, skip it
    mv a0, s1                                      # Argument 1 for function: current input token address
    mv a1, s2                                      # Argument 2 for function: vocab start address
    jal find_token_index                           # Call find_token_index function
    sw a0, 0(s0)                                   # Store returned index into output vector
    addi s0, s0, 4                                 # Advance output vector pointer by 4 bytes
    addi s3, s3, 1                                 # Increment input token count

tokens_advance_input:
    lbu t1, 0(s1)                                  # Load current character from input
    beq t1, zero, tokens_outer                     # If '\0', return to outer loop
    li t2, CONST_CHAR_NEWLINE                      # Load newline constant
    beq t1, t2, tokens_outer                       # If newline, return to outer loop
    li t2, CONST_CHAR_SPACE                        # Load space constant
    beq t1, t2, tokens_outer                       # If space, return to outer loop
    addi s1, s1, 1                                 # Move to next character in input string
    j tokens_advance_input                         # Repeat advancement loop

tokens_skip_input_sep:
    addi s1, s1, 1                                 # Advance input pointer past separator
    j tokens_outer                                 # Go back to outer loop

tokens_done:
    mv a1, s3                                      # Move total token count to a1 (return value)
    lw ra, 0(sp)                                   # Restore return address
    lw s0, 4(sp)                                   # Restore s0 register
    lw s1, 8(sp)                                   # Restore s1 register
    lw s2, 12(sp)                                  # Restore s2 register
    lw s3, 16(sp)                                  # Restore s3 register
    addi sp, sp, 20                                # Deallocate stack space
    ret                                            # Return to caller

# a0: token address, a1: vocab buffer -> a0: index
find_token_index:
    mv t0, a0                                      # t0 = target token pointer
    mv t1, a1                                      # t1 = vocab buffer pointer
    li t2, 0                                       # t2 = current vocab index counter (starts at 0)
find_token_index_loop:
    lbu t3, 0(t1)                                  # Load first char of current vocab entry
    beq t3, zero, find_token_not_found             # If end of vocab buffer ('\0'), token not found
    mv t4, t0                                      # t4 = temporary pointer for token scan
    mv t5, t1                                      # t5 = temporary pointer for vocab scan
find_token_cmp:
    lbu a2, 0(t4)                                  # Load char from target token
    lbu a3, 0(t5)                                  # Load char from vocab entry
    li a4, CONST_CHAR_NEWLINE                      # Load newline constant
    beq a2, a4, find_token_input_end               # If token char is newline, check if word matched
    li a4, CONST_CHAR_SPACE                        # Load space constant
    beq a2, a4, find_token_input_end               # If token char is space, check if word matched
    beq a2, zero, find_token_input_end             # If token char is '\0', check if word matched
    bne a2, a3, find_token_next_vocab              # If characters don't match, move to next vocab entry
    addi t4, t4, 1                                 # Move to next character in target token
    addi t5, t5, 1                                 # Move to next character in vocab entry
    j find_token_cmp                               # Repeat character comparison

find_token_input_end:
    li a4, CONST_CHAR_NEWLINE                      # Load newline constant
    beq a3, a4, find_token_found                   # If vocab char is newline, complete match found
    beq a3, zero, find_token_found                 # If vocab char is '\0', complete match found
    j find_token_next_vocab                        # Otherwise, it's a partial match; try next entry

find_token_next_vocab:
    lbu a2, 0(t1)                                  # Load current char from vocab pointer t1
    beq a2, zero, find_token_not_found             # If '\0', we reached the end of vocab without match
    li a4, CONST_CHAR_NEWLINE                      # Load newline constant
    beq a2, a4, find_token_advance_line           # If newline, advance index counter
    addi t1, t1, 1                                 # Move vocab pointer forward by 1 byte
    j find_token_next_vocab                        # Keep searching for end of line

find_token_advance_line:
    addi t1, t1, 1                                 # Step past the newline character
    addi t2, t2, 1                                 # Increment vocab index counter
    j find_token_index_loop                        # Start matching next entry

find_token_found:
    mv a0, t2                                      # Set a0 to matched vocab index
    ret                                            # Return index

find_token_not_found:
    li a0, -1                                      # Set a0 to -1 (error flag)
    ret                                            # Return -1

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the vocabulary embeddings matrix (int*)
# (in)     a2: address of the input indices array (int*)
# (in)     a3: number of tokens in the input (int)

build_input_embeddings_matrix:
    li t0, 0                                       # t0 = outer loop counter (row index i = 0)
build_input_embeddings_outer:
    beq t0, a3, build_input_embeddings_done       # If all input tokens processed, exit loop
    lw t1, 0(a2)                                   # Load vocab index from input array
    li t2, CONST_DIMENSION                         # t2 = embedding dimensions
    mul t3, t1, t2                                 # t3 = element offset (index * dimension)
    slli t3, t3, 2                                 # t3 = byte offset (multiply by 4 for int size)
    add t4, a1, t3                                 # t4 = exact source row address in vocab matrix
    li t5, 0                                       # t5 = inner loop counter (dimension index = 0)
build_input_embeddings_inner:
    beq t5, t2, build_input_embeddings_next        # If row copy finished, go to next token
    lw t6, 0(t4)                                   # Load integer value from source embedding row
    sw t6, 0(a0)                                   # Store integer value into destination matrix
    addi t4, t4, 4                                 # Advance source row pointer by 4 bytes
    addi a0, a0, 4                                 # Advance destination matrix pointer by 4 bytes
    addi t5, t5, 1                                 # Increment dimension index
    j build_input_embeddings_inner                 # Repeat inner loop

build_input_embeddings_next:
    addi a2, a2, 4                                 # Advance input indices pointer to next token
    addi t0, t0, 1                                 # Increment outer loop counter
    j build_input_embeddings_outer                 # Repeat outer loop

build_input_embeddings_done:
    ret                                            # Return to caller

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the first matrix (int*)
# (in)     a2: #rows of the first matrix (int)
# (in)     a3: #columns of the first matrix (int)
# (in)     a4: address of the second matrix (int*)
# (in)     a5: #rows of the second matrix (int)
# (in)     a6: #columns of the second matrix (int)

matrix_multiply:
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    mv s0, a0                                      # output base
    mv s1, a1                                      # A base
    mv s2, a4                                      # B base
    li s3, 0                                       # i
mm_i_loop:
    beq s3, a2, mm_done
    li s4, 0                                       # j
mm_j_loop:
    beq s4, a6, mm_next_i
    li s5, 0                                       # k
    li s6, 0                                       # sum
mm_k_loop:
    beq s5, a3, mm_store
    mul t0, s3, a3
    add t0, t0, s5
    slli t0, t0, 2
    add t0, s1, t0
    lw t1, 0(t0)
    mul t2, s5, a6
    add t2, t2, s4
    slli t2, t2, 2
    add t2, s2, t2
    lw t3, 0(t2)
    mul t4, t1, t3
    add s6, s6, t4
    addi s5, s5, 1
    j mm_k_loop
mm_store:
    mul t0, s3, a6
    add t0, t0, s4
    slli t0, t0, 2
    add t0, s0, t0
    sw s6, 0(t0)
    addi s4, s4, 1
    j mm_j_loop
mm_next_i:
    addi s3, s3, 1
    j mm_i_loop
mm_done:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    addi sp, sp, 28
    ret

# (in/out) a0: address of the output scores vector to fill (int*)
# (in)     a1: address of Q matrix (int*)
# (in)     a2: address of K matrix (int*)
# (in)     a3: #rows of Q and K (int)
# (in)     a4: #columns of Q and K (int)
# (in)     a5: target token index for which we want to compute the score (int)

compute_scores:
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    mv s0, a0                                      # scores base
    mv s1, a1                                      # Q base
    mv s2, a2                                      # K base
    mv s3, a3                                      # rows
    mv s4, a4                                      # cols
    mv s5, a5                                      # target row
    mul t0, s5, s4
    slli t0, t0, 2
    add t0, s1, t0                                 # Q[target]
    li t1, 0                                       # i
compute_scores_loop:
    beq t1, s3, compute_scores_done
    mv a1, t0
    mul t2, t1, s4
    slli t2, t2, 2
    add a2, s2, t2                                 # K[i]
    mv a3, s4
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t1, 4(sp)
    jal dot
    lw t0, 0(sp)
    lw t1, 4(sp)
    addi sp, sp, 8
    slli t3, t1, 2
    add t3, s0, t3
    sw a1, 0(t3)
    addi t1, t1, 1
    j compute_scores_loop
compute_scores_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    ret

# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row

select_vector_in_matrix:
    mul t0, a4, a3
    slli t0, t0, 2
    add a0, a1, t0
    ret

# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)

decide_next_token:
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    mv s0, a0                                      # target vector
    mv s1, a1                                      # vocab embeddings
    mv s2, a2                                      # vocab size
    li s3, 0                                       # index
    li s4, 0                                       # best index
    li s5, -2147483648                             # best score

decide_loop:
    beq s3, s2, decide_done
    mv a1, s0
    li t0, CONST_DIMENSION
    mul t1, s3, t0
    slli t1, t1, 2
    add a2, s1, t1
    mv a3, t0
    jal dot
    ble a1, s5, decide_next
    mv s5, a1
    mv s4, s3
decide_next:
    addi s3, s3, 1
    j decide_loop
decide_done:
    mv a0, s4
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    ret

# a0: vocab buffer, a1: token index -> a0: address of token
gel_token_address_unused:
    ret
get_token_address:
    mv t0, a0
    mv t1, a1
    li t2, 0
get_token_address_loop:
    beq t2, t1, get_token_address_found
    lbu t3, 0(t0)
    beq t3, zero, get_token_address_found
    li t4, CONST_CHAR_NEWLINE
    beq t3, t4, get_token_address_next
    addi t0, t0, 1
    j get_token_address_loop
get_token_address_next:
    addi t0, t0, 1
    addi t2, t2, 1
    j get_token_address_loop
get_token_address_found:
    mv a0, t0
    ret

#############################################################################################################
# Dot product and argmax helper functions.
#############################################################################################################

# (in)  a1: address of first vector (int*)
# (in)  a2: address of second vector (int*)
# (in)  a3: length of the vectors (int)
# (out) a0: status code (0 for success, non-zero for error)
# (out) a1: dot product result (int)
dot:
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the result and the loop index.
    mv t0, zero                                     # t0 will hold the result (dot product)
    mv t1, zero                                     # t1 will be our loop index
    # Let's see first if SIZE < 1, and jump to dot_end if that's the case.
    slti t2, a3, 1                                  # t2 = (SIZE < 1)
    beq t2, zero, dot_loop                          # If SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # Set a0 to 50 to indicate an error (invalid size)
    j dot_end                                       # If SIZE < 1, jump to dot_end
dot_loop:
    beq t1, a3, dot_end_loop                        # If t1 == SIZE, we are done
    lw t2, 0(a1)                                    # Load A[t1] into t2
    lw t3, 0(a2)                                    # Load B[t1] into t3
    mul t4, t2, t3                                  # t4 = A[t1] * B[t1]
    # Check if the multiplication of A[t1] and B[t1] overflows
    mulh t5, t2, t3                                 # t5 = high 32 bits of A[t1] * B[t1] (signed)
    srai t6, t4, 31                                 # t6 = sign extension of low 32 bits (0 or -1)
    bne t5, t6, overflow                            # Overflow if high bits != sign extension of low bits
    mv t6, t0                                       # Store the current result in t6 for overflow checking
    add t0, t0, t4                                  # t0 += A[t1] * B[t1]
    # Check if the previous addition caused an overflow
    # Careful: adding negative numbers will correctly result in a negative number, so we need to check for overflow in both directions.
    bgt t6, zero, check_positive_overflow           # If previous result was positive, check for positive overflow
    blt t6, zero, check_negative_overflow           # If previous result was negative, check for negative overflow
    j dot_continue_loop
check_positive_overflow:
    blt t4, zero, dot_continue_loop                 # If we added a negative number, we can't have a positive overflow
    blt t0, zero, overflow                          # If t0 < 0 after adding a positive number, we have an overflow
    j dot_continue_loop
check_negative_overflow:
    bgt t4, zero, dot_continue_loop                 # If we added a positive number, we can't have a negative overflow
    bgt t0, zero, overflow                          # If t0 > 0 after adding a negative number, we have an overflow
    j dot_continue_loop
dot_continue_loop:
    addi a1, a1, 4                                  # Move to the next element in A
    addi a2, a2, 4                                  # Move to the next element in B
    addi t1, t1, 1                                  # t1++
    j dot_loop                                      # Repeat the loop
dot_end_loop:
    li a0, 0                                        # Set a0 to 0 to indicate success
    mv a1, t0                                       # Move the result into a1 for return
    j dot_end                                       # Jump to the end of the function
overflow:
    li a0, 200                                      # Set a0 to 200 to indicate an overflow error
    j dot_end                                       # Jump to the end of the function
dot_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # Return to the caller

# (in)  a1: pointer to int array
# (in)  a2: array length
# (out) a0: status code
# (out) a1: index of the largest element
argmax:
    # Get the index of the maximum value in A, which is of size SIZE.
    # The result will be stored in a0.
    # If here's a draw, return the smallest index among the maximum values.
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the max value and the index of the max value.
    lw t0, 0(a1)                                    # t0 will hold the max value
    mv t1, zero                                     # t1 will hold the index of the max value
    mv t2, zero                                     # t2 will be our loop index
    # Error checking first: if SIZE < 1, we should return 50 to indicate an error.
    slti t3, a2, 1                                  # t3 = (SIZE < 1)
    beq t3, zero, argmax_loop                       # if SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # set a0 to 50 to indicate an error (invalid size)
    j argmax_end                                    # if SIZE < 1, jump to argmax_end
argmax_loop:
    # The actual loop logic.
    beq t2, a2, argmax_end_loop                     # if t2 == SIZE, we are done
    lw t3, 0(a1)                                    # load A[t2] into t3
    ble t3, t0, argmax_next                         # if A[t2] <= max_value, skip to next
    mv t0, t3                                       # max_value = A[t2]
    mv t1, t2                                       # index_of_max = t2
argmax_next:
    addi a1, a1, 4                                  # move to the next element in A
    addi t2, t2, 1                                  # t2++
    j argmax_loop                                   # repeat the loop
argmax_end_loop:
    mv a1, t1                                       # move the index of the max value into a1 for return
    li a0, 0                                        # set a0 to 0 to indicate success
argmax_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # return to the caller

exit_with_code:
    li a7, CONST_SYSCALL_EXIT2
    ecall

#############################################################################################################
# Helper functions for printing and debugging.
#############################################################################################################

.data
PRINT_HEADER_VOCABULARY:    .string "=== Vocabulary ==="
PRINT_HEADER_INPUT:         .string "=== Input ==="
PRINT_HEADER_INPUT_INDICES: .string "=== Input Indices ==="
PRINT_HEADER_MATRIX:        .string "=== Matrix ==="
PRINT_HEADER_SCORES:        .string "=== Scores ==="
PRINT_HEADER_NEXT_TOKEN:    .string "=== Decision ==="
PRINT_VECTOR_LB:            .string "[ "
PRINT_VECTOR_RB:            .string "]"

.text
# Prints a null-terminated string followed by a newline.
# (in) a0: buffer to print (char*)
println:
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    ret

# Prints the vocabulary buffer.
# (in) a0: address of the vocabulary buffer (char*)
print_vocabulary:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_VOCABULARY
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input buffer as a string.
# (in) a0: address of the input buffer (char*)
print_input:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_INPUT
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input indices vector.
# (in) a0: address of the input indices vector (int*)
# (in) a1: size of the input indices vector (int)
print_indices:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    la a0, PRINT_HEADER_INPUT_INDICES
    jal println
    mv a0, s0
    mv a1, s1
    jal print_vector
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

print_scores:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, PRINT_HEADER_SCORES
    jal println
    la a0, SCORES_VECTOR
    lw a1, INPUT_TOTAL_TOKENS
    jal print_vector
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# a0: address of matrix to print (int*)
# a1: number of rows
# a2: number of columns
print_matrix:
    addi sp, sp, -24
    sw ra, 0(sp)                                    # return address
    sw s0, 4(sp)                                    # matrix pointer
    sw s1, 8(sp)                                    # row index
    sw s2, 12(sp)                                   # col index
    sw s3, 16(sp)                                   # number of rows
    sw s4, 20(sp)                                   # number of columns
    mv s0, a0                                       # s0 = pointer to matrix
    mv s3, a1                                       # s3 = number of rows
    mv s4, a2                                       # s4 = number of columns
    li s1, 0                                        # s1 = current row index
    la a0, PRINT_HEADER_MATRIX
    jal println
print_matrix_row_loop:
    beq s1, s3, print_matrix_done
    li s2, 0
print_matrix_col_loop:
    beq s2, s4, print_matrix_next_row
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    addi s0, s0, 4
    addi s2, s2, 1
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    j print_matrix_col_loop
print_matrix_next_row:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_matrix_row_loop
print_matrix_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

# a0: address of vector to print (int*)
# a1: number of elements (int)
print_vector:
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    mv s0, a0                                       # s0 = pointer to vector
    mv s1, a1                                       # s1 = number of elements
    la a0, PRINT_VECTOR_LB                          # Print "[ "
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
print_vector_loop:
    beq s1, zero, print_vector_done
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 4
    addi s1, s1, -1
    j print_vector_loop
print_vector_done:
    la a0, PRINT_VECTOR_RB                          # Print "]"
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    ret

# (in) a0: address of the predicted token (char*)
print_predicted_token:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_NEXT_TOKEN
    jal println
    # s0 = start of target token, print it char by char until newline or null
print_predicted_token_char:
    lb t0, 0(s0)
    beq t0, zero, print_predicted_token_nl          # null terminator
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, print_predicted_token_nl            # newline terminator
    mv a0, t0
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 1
    j print_predicted_token_char
print_predicted_token_nl:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

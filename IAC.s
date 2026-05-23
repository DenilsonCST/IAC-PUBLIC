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
.equ CONST_CHAR_NINE 57

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
    jal ra, read_file

###########################################################################
# Read input
###########################################################################
    la a0, INPUT_FILENAME
    la a1, INPUT_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file

###########################################################################
# Read W_Q matrix
###########################################################################
    la a0, W_Q_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file

###########################################################################
# Parse W_Q matrix from buffer
###########################################################################
    la a0, W_Q_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer

###########################################################################
# Read W_K matrix
###########################################################################
    la a0, W_K_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file

###########################################################################
# Parse W_K matrix from buffer
###########################################################################
    la a0, W_K_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer

###########################################################################
# Read W_V matrix
###########################################################################
    la a0, W_V_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file

<<<<<<< HEAD
###########################################################################
# Parse W_V matrix from buffer
###########################################################################
    la a0, W_V_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer

###########################################################################
# Read embeddings matrix
###########################################################################
    la a0, EMBEDDINGS_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file

###########################################################################
# Parse vocabulary embeddings matrix from buffer
###########################################################################
    la a0, VOCAB_EMBEDDINGS_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer
    la t0, VOCAB_TOTAL_TOKENS
    sw a1, 0(t0)

###########################################################################
# Convert input tokens to indices
###########################################################################
    la a0, INPUT_INDICES_VECTOR
    la a2, INPUT_BUFFER
    la a3, VOCAB_BUFFER
    jal ra, tokens_to_indices
    la t0, INPUT_TOTAL_TOKENS
    sw a1, 0(t0)

###########################################################################
# Build input embeddings matrix
###########################################################################
    la a0, INPUT_EMBEDDINGS_MATRIX
    la a1, VOCAB_EMBEDDINGS_MATRIX
    la a2, INPUT_INDICES_VECTOR
    lw a3, INPUT_TOTAL_TOKENS
    jal ra, build_input_embeddings_matrix

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
    jal ra, matrix_multiply

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
    jal ra, matrix_multiply

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
    jal ra, matrix_multiply

###########################################################################
# Compute scores for the last input token
###########################################################################
    la a0, SCORES_VECTOR

    ###########################################################################
    # Read W_K matrix
    ###########################################################################
    # TODO
	la a0, W_K_FILENAME
	la a1, MATRIX_BUFFER
	li a2, CONST_BUFFER_SIZE
	jal ra, read_file

    ###########################################################################
    # Parse W_K matrix from buffer
    ###########################################################################
    
	la a0, W_K_MATRIX
	la a1, MATRIX_BUFFER
	jal ra, parse_matrix_buffer

	#The section below is only for verification

	mv t0, a1

	la a0, W_K_MATRIX
	mv a1, t0
	li a2, CONST_DIMENSION
	jal ra, print_matrix

    ###########################################################################
    # Read W_V matrix
    ###########################################################################
    # TODO
	la a0, W_V_FILENAME
	la a1, MATRIX_BUFFER
	li a2, CONST_BUFFER_SIZE
	jal ra, read_file

	la a0, W_V_MATRIX        # a0 = address of the matrix where W_V will be stored
    la a1, MATRIX_BUFFER     # a1 = address of the buffer containing the W_V file contents
    jal ra, parse_matrix_buffer # convert the text buffer into an integer matrix

	# The section below is only for verification

    mv t0, a1                # save the number of rows returned by parse_matrix_buffer

    la a0, W_V_MATRIX        # a0 = address of the W_V matrix to print
    mv a1, t0                # a1 = number of rows
    li a2, CONST_DIMENSION   # a2 = number of columns
    jal ra, print_matrix     # print W_V matrix for verification

    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
    la a0, W_V_MATRIX
	la a1, MATRIX_BUFFER
	jal ra, parse_matrix_buffer

	#The section below is only for verification

	mv t0, a1

	la a0, W_V_MATRIX
	mv a1, t0
	li a2, CONST_DIMENSION
	jal ra, print_matrix

    ###########################################################################
    # Read embeddings matrix
    ###########################################################################
    # TODO
	la a0, EMBEDDINGS_FILENAME # a0 = address of the embeddings filename
    la a1, MATRIX_BUFFER       # a1 = address of the buffer where file contents will be stored
    li a2, CONST_BUFFER_SIZE   # a2 = maximum number of bytes to read
    jal ra, read_file          # read embeddings.txt into MATRIX_BUFFER

    ###########################################################################
    # Parse vocabulary embeddings matrix from buffer
    ###########################################################################
    la a0, VOCAB_EMBEDDINGS_MATRIX
	la a1, MATRIX_BUFFER
	jal ra, parse_matrix_buffer

	#The section below is only for verification

	mv t0, a1

	la a0, VOCAB_EMBEDDINGS_MATRIX
	mv a1, t0
	li a2, CONST_DIMENSION
	jal ra, print_matrix

    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    # TODO
	la a0, INPUT_INDICES_VECTOR # a0 = address of the output vector for token indices
    la a2, INPUT_BUFFER         # a2 = address of the input text buffer
    la a3, VOCAB_BUFFER         # a3 = address of the vocabulary text buffer
    jal ra, tokens_to_indices   # convert each input word into its vocabulary index

    la t0, INPUT_TOTAL_TOKENS   # t0 = address where the number of input tokens is stored
    sw a1, 0(t0)                # save the number of input tokens returned in a1

    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    # TODO
	la a0, INPUT_EMBEDDINGS_MATRIX # a0 = output matrix for input embeddings
    la a1, VOCAB_EMBEDDINGS_MATRIX # a1 = full vocabulary embeddings matrix
    la a2, INPUT_INDICES_VECTOR    # a2 = vector with the indices of the input tokens
    lw a3, INPUT_TOTAL_TOKENS      # a3 = number of input tokens
    jal ra, build_input_embeddings_matrix # copy the embeddings of the input tokens

    ###########################################################################
    # Build matrix Q
    ###########################################################################
    # TODO
	la a0, Q_MATRIX                # a0 = output matrix Q
    la a1, INPUT_EMBEDDINGS_MATRIX # a1 = input embeddings matrix E
    la a0, Q_MATRIX                  # return matrix 
    la a1, INPUT_EMBEDDINGS_MATRIX   # Matriz E

    la t0, INPUT_TOTAL_TOKENS      # load address of input token count
    lw a2, 0(t0)                   # a2 = number of rows of E

    li a3, CONST_DIMENSION         # a3 = number of columns of E
    la a4, W_Q_MATRIX              # a4 = address of W_Q matrix
    li a5, CONST_DIMENSION         # a5 = number of rows of W_Q
    li a6, CONST_DIMENSION         # a6 = number of columns of W_Q

    jal ra, matrix_multiply        # Q = E * W_Q

    ###########################################################################
    # Build matrix K
    ###########################################################################
    # TODO
	la a0, K_MATRIX                # a0 = output matrix K
    la a1, INPUT_EMBEDDINGS_MATRIX # a1 = input embeddings matrix E

    la t0, INPUT_TOTAL_TOKENS      # load address of input token count
    lw a2, 0(t0)                   # a2 = number of rows of E

    li a3, CONST_DIMENSION         # a3 = number of columns of E
    la a4, W_K_MATRIX              # a4 = address of W_K matrix
    li a5, CONST_DIMENSION         # a5 = number of rows of W_K
    li a6, CONST_DIMENSION         # a6 = number of columns of W_K

	jal ra, matrix_multiply        # K = E * W_K

    ###########################################################################
    # Build matrix V
    ###########################################################################
    # TODO
	la a0, V_MATRIX                # a0 = output matrix V
    la a1, INPUT_EMBEDDINGS_MATRIX # a1 = input embeddings matrix E

	la t0, INPUT_TOTAL_TOKENS      # load address of input token count
    lw a2, 0(t0)                   # a2 = number of rows of E

    li a3, CONST_DIMENSION         # a3 = number of columns of E
    la a4, W_V_MATRIX              # a4 = address of W_V matrix
    li a5, CONST_DIMENSION         # a5 = number of rows of W_V
    li a6, CONST_DIMENSION         # a6 = number of columns of W_V

    jal ra, matrix_multiply        # V = E * W_V


    ###########################################################################
    # Compute scores for the last input token
    ###########################################################################
    # TODO
	la a0, SCORES_VECTOR
>>>>>>> 27e77e558e552c952d1a4fb18e8eb869312616f8
    la a1, Q_MATRIX
    la a2, K_MATRIX
    lw a3, INPUT_TOTAL_TOKENS
    li a4, CONST_DIMENSION
    addi a5, a3, -1
    jal ra, compute_scores

###########################################################################
# Get the highest score index using argmax
###########################################################################
    la a1, SCORES_VECTOR
    lw a2, INPUT_TOTAL_TOKENS
    jal ra, argmax

###########################################################################
# Select chosen vector in V using the index from argmax
###########################################################################
    mv a4, a1
    la a1, V_MATRIX
    lw a2, INPUT_TOTAL_TOKENS
    li a3, CONST_DIMENSION
    jal ra, select_vector_in_matrix

###########################################################################
# Pick the next token in the vocabulary with the highest score
###########################################################################
    la a1, VOCAB_EMBEDDINGS_MATRIX
    lw a2, VOCAB_TOTAL_TOKENS
    jal ra, decide_next_token

    mv a1, a0
    la a0, VOCAB_BUFFER
    jal ra, get_vocab_token_address
    jal ra, print_predicted_token

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
    sw ra, 12(sp)
    sw a1, 8(sp)
    sw a2, 4(sp)

    li a1, 0
    li a7, CONST_SYSCALL_OPEN
    ecall
    sw a0, 0(sp)

    lw a0, 0(sp)
    lw a1, 8(sp)
    lw a2, 4(sp)
    li a7, CONST_SYSCALL_READ
    ecall

    lw t0, 8(sp)
    add t0, t0, a0
    sb zero, 0(t0)

    lw a0, 0(sp)
    li a7, CONST_SYSCALL_CLOSE
    ecall

    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)
parse_matrix_buffer:
    li t0, 0                                       # current number
    li t1, 0                                       # row count
    li t2, 1                                       # sign
    li t5, 0                                       # currently reading a number
    li t6, 0                                       # current row has at least one number

parse_matrix_loop:
    lb t3, 0(a1)
    beq t3, zero, parse_matrix_eof

    li t4, CONST_CHAR_HYPHEN
    beq t3, t4, parse_matrix_negative

    li t4, CONST_CHAR_SPACE
    beq t3, t4, parse_matrix_space

    li t4, CONST_CHAR_NEWLINE
    beq t3, t4, parse_matrix_newline

    li t4, CONST_CHAR_ZERO
    blt t3, t4, parse_matrix_next

    li t4, CONST_CHAR_NINE
    bgt t3, t4, parse_matrix_next

    li t4, 10
    mul t0, t0, t4
    li t4, CONST_CHAR_ZERO
    sub t3, t3, t4
    add t0, t0, t3
    li t5, 1
    li t6, 1
    j parse_matrix_next

parse_matrix_negative:
    li t2, -1
    j parse_matrix_next

parse_matrix_space:
    beq t5, zero, parse_matrix_next
    jal zero, parse_matrix_save_number

parse_matrix_newline:
    beq t5, zero, parse_matrix_count_row
    mul t0, t0, t2
    sw t0, 0(a0)
    addi a0, a0, 4
    li t0, 0
    li t2, 1
    li t5, 0
    j parse_matrix_count_row

parse_matrix_count_row:
    beq t6, zero, parse_matrix_next
    addi t1, t1, 1
    li t6, 0
    j parse_matrix_next

parse_matrix_save_number:
    mul t0, t0, t2
    sw t0, 0(a0)
    addi a0, a0, 4
    li t0, 0
    li t2, 1
    li t5, 0
    j parse_matrix_next

parse_matrix_next:
    addi a1, a1, 1
    j parse_matrix_loop

parse_matrix_eof:
    beq t5, zero, parse_matrix_eof_count
    mul t0, t0, t2
    sw t0, 0(a0)
    li t6, 1

parse_matrix_eof_count:
    beq t6, zero, parse_matrix_done
    addi t1, t1, 1

parse_matrix_done:
    mv a1, t1
    ret

# Converts the input tokens into their corresponding indices in the vocabulary.
# (in/out) a0: address of input indices vector to fill (int*)
# (out)    a1: size of input indices vector (number of tokens in input)
# (in)     a2: address to input buffer
# (in)     a3: address to vocabulary buffer
tokens_to_indices:
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    mv s0, a0
    mv s1, a2
    mv s2, a3
    li s3, 0
tokens_next_input:
    lb t0, 0(s1)
    beq t0, zero, tokens_done
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, tokens_skip_input_delim
    li t1, CONST_CHAR_SPACE
    beq t0, t1, tokens_skip_input_delim
    li t1, 13
    beq t0, t1, tokens_skip_input_delim
    mv s4, s1
    mv s5, s1
tokens_find_input_end:
    lb t0, 0(s5)
    beq t0, zero, tokens_search_vocab
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, tokens_search_vocab
    li t1, CONST_CHAR_SPACE
    beq t0, t1, tokens_search_vocab
    li t1, 13
    beq t0, t1, tokens_search_vocab
    addi s5, s5, 1
    j tokens_find_input_end
tokens_search_vocab:
    mv s6, s2
    li s7, 0
tokens_vocab_loop:
    lb t0, 0(s6)
    beq t0, zero, tokens_store_missing
    mv s8, s6
    mv s9, s4
    mv s10, s8
tokens_compare_loop:
    beq s9, s5, tokens_check_vocab_end
    lb t0, 0(s9)
    lb t1, 0(s10)
    bne t0, t1, tokens_vocab_no_match
    addi s9, s9, 1
    addi s10, s10, 1
    j tokens_compare_loop

tokens_check_vocab_end:
    lb t1, 0(s10)
    beq t1, zero, tokens_store_found
    li t0, CONST_CHAR_NEWLINE
    beq t1, t0, tokens_store_found
    li t0, CONST_CHAR_SPACE
    beq t1, t0, tokens_store_found
    li t0, 13
    beq t1, t0, tokens_store_found

tokens_vocab_no_match:
    lb t0, 0(s6)
    beq t0, zero, tokens_store_missing
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, tokens_next_vocab
    addi s6, s6, 1
    j tokens_vocab_no_match

tokens_next_vocab:
    addi s6, s6, 1
    addi s7, s7, 1
    j tokens_vocab_loop

tokens_store_found:
    sw s7, 0(s0)
    addi s0, s0, 4
    addi s3, s3, 1
    mv s1, s5
    j tokens_next_input

tokens_store_missing:
    li t0, -1
    sw t0, 0(s0)
    addi s0, s0, 4
    addi s3, s3, 1
    mv s1, s5
    j tokens_next_input

tokens_skip_input_delim:
    addi s1, s1, 1
    j tokens_next_input

tokens_done:
    mv a1, s3
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48
    ret

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the vocabulary embeddings matrix (int*)
# (in)     a2: address of the input indices array (int*)
# (in)     a3: number of tokens in the input (int)
build_input_embeddings_matrix:
    li t0, 0

build_embeddings_row_loop:
    beq t0, a3, build_embeddings_done
    lw t1, 0(a2)
    li t2, CONST_DIMENSION
    mul t1, t1, t2
    slli t1, t1, 2
    add t1, a1, t1
    li t2, 0

build_embeddings_col_loop:
    li t3, CONST_DIMENSION
    beq t2, t3, build_embeddings_next_row
    lw t4, 0(t1)
    sw t4, 0(a0)
    addi t1, t1, 4
    addi a0, a0, 4
    addi t2, t2, 1
    j build_embeddings_col_loop

build_embeddings_next_row:
    addi a2, a2, 4
    addi t0, t0, 1
    j build_embeddings_row_loop

build_embeddings_done:
    ret

# (in/out) a0: address of the output matrix to fill (int*)
# (in)     a1: address of the first matrix (int*)
# (in)     a2: #rows of the first matrix (int)
# (in)     a3: #columns of the first matrix (int)
# (in)     a4: address of the second matrix (int*)
# (in)     a5: #rows of the second matrix (int)
# (in)     a6: #columns of the second matrix (int)
matrix_multiply:
    addi sp, sp, -32
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)

    mv s0, a0                                      # output matrix
    mv s1, a1                                      # first matrix
    mv s2, a3                                      # columns of first matrix
    mv s3, a4                                      # second matrix
    mv s4, a6                                      # columns of second matrix
    li s5, 0                                       # row index i

matrix_multiply_row_loop:
    beq s5, a2, matrix_multiply_done
    li s6, 0                                       # column index j

matrix_multiply_col_loop:
    beq s6, s4, matrix_multiply_next_row
    li s7, 0                                       # k index
    li t0, 0                                       # sum

matrix_multiply_k_loop:
    beq s7, s2, matrix_multiply_store

    mul t1, s5, s2                                 # A[i][k]
    add t1, t1, s7
    slli t1, t1, 2
    add t1, s1, t1
    lw t2, 0(t1)

    mul t3, s7, s4                                 # B[k][j]
    add t3, t3, s6
    slli t3, t3, 2
    add t3, s3, t3
    lw t4, 0(t3)

    mul t5, t2, t4
    add t0, t0, t5
    addi s7, s7, 1
    j matrix_multiply_k_loop

matrix_multiply_store:
    mul t1, s5, s4                                 # output[i][j]
    add t1, t1, s6
    slli t1, t1, 2
    add t1, s0, t1
    sw t0, 0(t1)

    addi s6, s6, 1
    j matrix_multiply_col_loop

matrix_multiply_next_row:
    addi s5, s5, 1
    j matrix_multiply_row_loop

matrix_multiply_done:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    addi sp, sp, 32
    ret

# (in/out) a0: address of the output scores vector to fill (int*)
# (in)     a1: address of Q matrix (int*)
# (in)     a2: address of K matrix (int*)
# (in)     a3: #rows of Q and K (int)
# (in)     a4: #columns of Q and K (int)
# (in)     a5: target token index for which we want to compute the score (int)
compute_scores:
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)
    sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
    sw s4, 4(sp)
    sw s5, 0(sp)

    mv s0, a0                                      # scores vector
    mv s2, a2                                      # K matrix
    mv s3, a3                                      # number of rows
    mv s4, a4                                      # number of columns
    li s5, 0                                       # row index

    mul t0, a5, a4
    slli t0, t0, 2
    add s1, a1, t0                                 # Q[target]

compute_scores_loop:
    beq s5, s3, compute_scores_done

    mul t0, s5, s4
    slli t0, t0, 2
    add a2, s2, t0                                 # K[row]
    mv a1, s1
    mv a3, s4
    jal ra, dot

    slli t0, s5, 2
    add t0, s0, t0
    sw a1, 0(t0)

    addi s5, s5, 1
    j compute_scores_loop

compute_scores_done:
    lw ra, 24(sp)
    lw s0, 20(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    lw s4, 4(sp)
    lw s5, 0(sp)
    addi sp, sp, 28
    ret

# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
select_vector_in_matrix:
    bge a4, a2, select_vector_error
    mul t0, a4, a3
    slli t0, t0, 2
    add a0, a1, t0
    ret

select_vector_error:
    li a0, 50
    j exit_with_code

# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)
decide_next_token:
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)
    sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
    sw s4, 4(sp)
    sw s5, 0(sp)

    mv s0, a0                                      # target vector
    mv s1, a1                                      # current vocab vector
    mv s2, a2                                      # vocabulary size
    li s3, 0                                       # current index
    li s5, 0                                       # best index

    ble s2, zero, decide_next_token_done

    mv a1, s0
    mv a2, s1
    li a3, CONST_DIMENSION
    jal ra, dot
    mv s4, a1                                      # best score
    addi s3, s3, 1
    addi s1, s1, 16

decide_next_token_loop:
    beq s3, s2, decide_next_token_done

    mv a1, s0
    mv a2, s1
    li a3, CONST_DIMENSION
    jal ra, dot

    ble a1, s4, decide_next_token_next
    mv s4, a1
    mv s5, s3

decide_next_token_next:
    addi s3, s3, 1
    addi s1, s1, 16
    j decide_next_token_loop

decide_next_token_done:
    mv a0, s5
    lw ra, 24(sp)
    lw s0, 20(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    lw s4, 4(sp)
    lw s5, 0(sp)
    addi sp, sp, 28
    ret

# (in)  a0: vocabulary buffer address (char*)
# (in)  a1: token index
# (out) a0: address of token at index
get_vocab_token_address:
    mv t0, a0
    li t1, 0

get_vocab_token_loop:
    beq t1, a1, get_vocab_token_done
    lb t2, 0(t0)
    beq t2, zero, get_vocab_token_done
    li t3, CONST_CHAR_NEWLINE
    beq t2, t3, get_vocab_token_next
    addi t0, t0, 1
    j get_vocab_token_loop

get_vocab_token_next:
    addi t0, t0, 1
    addi t1, t1, 1
    j get_vocab_token_loop

get_vocab_token_done:
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
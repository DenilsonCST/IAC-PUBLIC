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
    la a0, VOCABULARY_FILENAME  # Pointer to filename
    la a1, VOCAB_BUFFER        # Pointer to buffer address
    li a2, CONST_BUFFER_SIZE   # Maximum number of bytes to read
    jal ra, read_file        # Calls read_file
    
    la a0, VOCAB_BUFFER
    jal ra, print_vocabulary
  
    ###########################################################################
    # Read input
    ###########################################################################
    # TODO
    la a0, INPUT_FILENAME  # Pointer to filename
    la a1, INPUT_BUFFER        # Pointer to buffer address
    li a2, CONST_BUFFER_SIZE               # Maximum number of bytes to read
    jal ra, read_file        # Calls read_file
    
    la a0, INPUT_BUFFER
    jal ra, print_input
    

    ###########################################################################
    # Read W_Q matrix
    ###########################################################################
    # TODO
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

	# The section below is only for verification

	mv t0, a1

	la a0, W_Q_MATRIX
	mv a1, t0
	li a2, CONST_DIMENSION
	jal ra, print_matrix
    

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

	# The section below is only for verification

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


    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
	la a0, W_V_MATRIX
	la a1, MATRIX_BUFFER
	jal ra, parse_matrix_buffer

	# The section below is only for verification

	mv t0, a1

	la a0, W_V_MATRIX
	mv a1, t0
	li a2, CONST_DIMENSION
	jal ra, print_matrix

    ###########################################################################
    # Read embeddings matrix
    ###########################################################################
    # TODO
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

    la t1, VOCAB_TOTAL_TOKENS
    sw a1, 0(t1)                   
    # ==================================================================

    mv t0, a1 

    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    la a0, INPUT_INDICES_VECTOR
    la a2, INPUT_BUFFER
    la a3, VOCAB_BUFFER
    jal ra, tokens_to_indices
    la t0, INPUT_TOTAL_TOKENS
    sw a1, 0(t0)

	# Testing section
	la a0, INPUT_INDICES_VECTOR
	lw a1, INPUT_TOTAL_TOKENS
	jal ra, print_indices
	

    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    la a0, INPUT_EMBEDDINGS_MATRIX
    la a1, VOCAB_EMBEDDINGS_MATRIX
    la a2, INPUT_INDICES_VECTOR
    lw a3, INPUT_TOTAL_TOKENS
    jal ra, build_input_embeddings_matrix

	# Testing section
	la a0, INPUT_EMBEDDINGS_MATRIX
	lw a1, INPUT_TOTAL_TOKENS
	li a2, CONST_DIMENSION
	jal ra, print_matrix

    ###########################################################################
    # Build matrix Q
    ###########################################################################
    la a0, Q_MATRIX                   # Return matrix 
    la a1, INPUT_EMBEDDINGS_MATRIX   # Matrix E

    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)                    # a2 = n (E rows)

    li a3, CONST_DIMENSION          # a3 = 4 
    la a4, W_Q_MATRIX               # Matrix B
    li a5, CONST_DIMENSION          # a5 = 4 (W_Q rows)
    li a6, CONST_DIMENSION          # a6 = 4 (W_Q cols)

    jal ra, matrix_multiply         # Multiply

    ###########################################################################
    # Build matrix K
    ###########################################################################
    la a0, K_MATRIX
    la a1, INPUT_EMBEDDINGS_MATRIX


    la t0 , INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

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


    la t0 , INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

    li a3, CONST_DIMENSION
    la a4, W_V_MATRIX
    li a5, CONST_DIMENSION 
    li a6, CONST_DIMENSION

    jal ra, matrix_multiply

    ###########################################################################
    # Compute scores for the last input token
    ###########################################################################
    la a0, SCORES_VECTOR
    la a1, Q_MATRIX
    la a2, K_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a3, 0(t0)    # a3 = n (number of tokens)

    li a4, CONST_DIMENSION # a4 = 4 

    addi a5, a3, -1        # a5 = n - 1 

    jal ra, compute_scores

	# Testing section 
	la a0, SCORES_VECTOR
	lw a1, INPUT_TOTAL_TOKENS
	jal ra, print_vector



    ###########################################################################
    # Get the highest score index using argmax
    ###########################################################################
    la a1, SCORES_VECTOR

    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

    jal ra, argmax


    ###########################################################################
    # Select chosen vector in V using the index from argmax
    ###########################################################################
    mv a4, a1               # Move a1 to a4 because a4 is the expected argument of s_v_in_m 

    la a1, V_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

    li a3, CONST_DIMENSION

    jal ra, select_vector_in_matrix

	# Testing
	# a0 contains the address of the selected vector
	mv a1, a0
	li a2, CONST_DIMENSION
	jal ra, print_vector


    ###########################################################################
    # Pick the next token in the vocabulary with the highest score
    ###########################################################################
    
    la a1, VOCAB_EMBEDDINGS_MATRIX

    la t0, VOCAB_TOTAL_TOKENS
    lw a2, 0(t0)

    jal ra, decide_next_token

	# Testing
	# a0 = predicted token index 

    # Convert index -> address in VOCAB_BUFFER
 	addi sp, sp, -8
    sw ra, 0(sp)                    # Save return address
    sw s0, 4(sp)                    # Save s0

    mv s0, a0                      # s0 = predicted token index
    la a0, VOCAB_BUFFER             # a0 = beginning of VOCAB_BUFFER
	

find_vocab_addr:
    beq s0, zero, found_vocab_addr  # If index = 0, already at the correct word
    lb t0, 0(a0)                    # Reads current buffer character
    addi a0, a0, 1                  # Advances pointer
    li t1, CONST_CHAR_NEWLINE
    bne t0, t1, find_vocab_addr     # If not '\n', continue advancing
    addi s0, s0, -1                 # Found '\n': decrement remaining word counter
    j find_vocab_addr

found_vocab_addr:
    # a0 now points to the beginning of the correct word in VOCAB_BUFFER
    jal ra, print_predicted_token   # Prints the predicted token

    lw ra, 0(sp)                    # Restore return address
    lw s0, 4(sp)                    # Restore s0
    addi sp, sp, 8


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
    addi sp, sp, -20
    sw ra, 16(sp)    #save the return address
    sw a0, 12(sp)    
    sw a1, 8(sp) 
    sw a2, 4(sp)  
    
    #Abertura do ficheiro(open)
    lw a0, 12(sp)
    li a1, 0
    li a7, CONST_SYSCALL_OPEN
    ecall
    sw a0, 0(sp)  #save file descriptor in stack
    
    #Leitura do ficheiro(read)
    lw a0, 0(sp)  # restore fd
    lw a1, 8(sp)   # take out the buffer address
    lw a2, 4(sp)
    li a7, CONST_SYSCALL_READ
    ecall
    
    #Fecho do ficheiro (close)
    lw a0, 0(sp)
    li a7, CONST_SYSCALL_CLOSE
    ecall 
    
    lw ra, 16(sp)
    addi sp, sp, 20
    
    jr ra # return to caller
    
# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)

parse_matrix_buffer:
    addi sp, sp, -4
    sw ra, 0(sp)

    li t0, 0          # Current number being built
    li t1, 0          # Number of matrix rows 
    li t2, 1          # Sign flag (+1 or -1)
    li t5, 0          # Flag: number currently being parsed

parse_matrix_buffer_loop:
    lb t3, 0(a1)      # Read from text buffer 

    li t4, CONST_CHAR_EOF
    beq t3, t4, eof_save

    li t4, CONST_CHAR_HYPHEN
    beq t3, t4, change_sign

    li t4, CONST_CHAR_SPACE
    beq t3, t4, save_number_space

    li t4, CONST_CHAR_NEWLINE
    beq t3, t4, save_number_newline

    li t4, CONST_CHAR_ZERO
    blt t3, t4, next_character

    li t4, CONST_CHAR_NINE
    bgt t3, t4, next_character

    # number = number * 10 + digit
    li t4, 10
    mul t0, t0, t4

    li t4, CONST_CHAR_ZERO
    sub t3, t3, t4

    add t0, t0, t3

    li t5, 1          # A valid digit was parsed

    j next_character

next_character:
    addi a1, a1, 1    # Advance text pointer 
    j parse_matrix_buffer_loop

change_sign:
    li t2, -1
    addi a1, a1, 1    # Advance text pointer 
    j parse_matrix_buffer_loop

save_number_space:
    beq t5, zero, skip_space

    # Apply sign and store number
    mul t0, t0, t2
    sw t0, 0(a0)      # Store into matrix destination 

    addi a0, a0, 4    # Advance matrix destination pointer
    addi t1, t1, 1    # Increment parsed elements counter

    # Reset parser state
    li t0, 0
    li t2, 1
    li t5, 0

skip_space:
    addi a1, a1, 1    # Advance text pointer 
    j parse_matrix_buffer_loop

save_number_newline:
    beq t5, zero, skip_newline

    # Apply sign and store number
    mul t0, t0, t2
    sw t0, 0(a0)      # Store into matrix destination 

    addi a0, a0, 4    # Advance matrix destination pointer 
    addi t1, t1, 1    # Increment parsed elements counter

    # Reset parser state
    li t0, 0
    li t2, 1
    li t5, 0

skip_newline:
    addi a1, a1, 1    # Advance text pointer 
    j parse_matrix_buffer_loop

eof_save:
    # Save last pending number if it exists
    beq t5, zero, end_parse

    mul t0, t0, t2
    sw t0, 0(a0)      # Store into matrix destination
    addi t1, t1, 1    # Increment parsed elements counter

end_parse:
    srli t1, t1, 2    # Convert total parsed elements into matrix rows (elements / 4 columns)

    
    mv a1, t1       # Return number of rows in a0  

    lw ra, 0(sp)
    addi sp, sp, 4

    jr ra


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
li t0, 0                  # t0 = i = 0

    mm_loop_i:
        bge t0, a2, mm_end           # if i >= rows_A, the program ends 
        li t1, 0                  # t1 = j = 0

        mm_loop_j:
            bge t1, a6, mm_next_i        # Se j >= cols_B, avança para o próximo i
            li t2, 0                  # t2 = sum = 0
            li t3, 0                  # t3 = k = 0

            mm_loop_k:
                
                bge t3, a3, mm_store_result  

                mul t4, t0, a3            
                add t4, t4, t3            
                slli t4, t4, 2            
                add t4, a1, t4            
                lw t5, 0(t4)              # t5 = A[i][k]

                mul t6, t3, a6            
                add t6, t6, t1            
                slli t6, t6, 2            
                add t6, a4, t6            
                lw t4, 0(t6)              # t4 = B[k][j]

                mul t6, t5, t4            # t6 = A[i][k] * B[k][j]
                add t2, t2, t6            # sum (t2) += t6

                addi t3, t3, 1            # k++
            j mm_loop_k                  

    mm_store_result:
        mul t4, t0, a6            # t4 = i * cols_B
        add t4, t4, t1            
        slli t4, t4, 2            
        add t4, a0, t4            
        sw t2, 0(t4)              

        addi t1, t1, 1            # j++ 
        j mm_loop_j                  # loop_j with next col

    mm_next_i:
        addi t0, t0, 1            # i++
        j mm_loop_i                  

    mm_end:
        ret                       # Retorna da função


# (in/out) a0: address of the output scores vector to fill (int*)
# (in)     a1: address of Q matrix (int*)
# (in)     a2: address of K matrix (int*)
# (in)     a3: #rows of Q and K (int)
# (in)     a4: #columns of Q and K (int)
# (in)     a5: target token index for which we want to compute the score (int)


compute_scores:
    addi sp, sp, -32          # 32 bytes on stack
    sw ra, 28(sp)             # return address 
    sw s0, 24(sp)              
    sw s1, 20(sp)              
    sw s2, 16(sp)             
    sw s3, 12(sp)             # s3 keeps the numbver of lines (a3)
    sw s4, 8(sp)              # s4 keeps the numeber of cols (a4)
    sw s5, 4(sp)              # (j = 0)

    mv s0, a0                 
    mv s2, a2                 
    mv s3, a3                 # s3 = n
    mv s4, a4                 # s4 = d_k
    li s5, 0                  # s5 = j = 0 

    mul t0, a5, a4            # t0 = target_index * cols
    slli t0, t0, 2            # t0 = t0 * 4 (bytes conversor)
    add s1, a1, t0            # s1 = Q_target 

cs_loop_j:
    bge s5, s3, cs_end_loop      

    mul t0, s5, s4            # t0 = j * cols
    slli t0, t0, 2            # t0 = t0 * 4 (bytres conversor)
    add a1, s2, t0            

  
    mv a0, s1                
    mv a2, s4                 

    jal dot                   # dot(Q_target, K[j], cols). Returns a0

   
  
    slli t0, s5, 2            # t0 = j * 4
    add t0, s0, t0            # t0 = scores[j] address
    sw a0, 0(t0)              

  
    addi s5, s5, 1            # j++
    j cs_loop_j                  

cs_end_loop:

    lw ra, 28(sp)             
    lw s0, 24(sp)             
    lw s1, 20(sp)             
    lw s2, 16(sp)             
    lw s3, 12(sp)            
    lw s4, 8(sp)             
    lw s5, 4(sp)              
    addi sp, sp, 32          
    ret                       # Returns to compute_scores first call

# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
select_vector_in_matrix:
    # TODO
	bge a4, a2, exit_with_code  #if a4 > a2, exit
	
	li t0, 4
	mul t0, a3, t0  #t0 = cols bytes number 
	mul t0, a4, t0  #t0 = offset 

	add a0, a1, t0  
	
	jr ra 


# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)

decide_next_token:
	mv t0, a0
	mv t1, a1
	mv t2, a2

	addi sp, sp, -40
	sw ra, 36(sp)
	sw a0, 32(sp)
	sw a1, 28(sp)
	sw a2, 24(sp)
	sw a3, 20(sp)
	sw s2, 16(sp)
	sw s3, 12(sp)
	sw s4, 8(sp)
	sw s5, 4(sp)
	sw s6, 0(sp)

	mv s6, t1
	li s2, 0  # s2 = index
	li s3, 0x80000000 # s3 = max
	mv s4, t2 # s4 = number of tokens in vocabulary

loop:
	bge s2, s4, end_decide # if index > #tokens , branch

	mv a1, t0  # a1 = address of first vector
	mv a2, s6 # a2 = address of second vector
	li a3, 4  # a3 = lenght of the vectors

	jal ra, dot

	bne a0, zero, next # if dot returned error, skip

	bgt a1, s3, save # if result > max, save

	j next

save: 
	mv s3, a1  # save the number as max 
	mv s5, s2  # save the index

next:
	addi s2, s2, 1
	addi s6, s6, 16
	j loop

end_decide:
	lw ra, 36(sp)
	lw a0, 32(sp)
	lw a1, 28(sp)
	lw a2, 24(sp)
	lw a3, 20(sp)
	lw s2, 16(sp)
	lw s3, 12(sp)
	lw s4, 8(sp)

	mv a0, s5   #save the index 

	lw s5, 4(sp)
	lw s6, 0(sp)
	addi sp,sp, 40

	jr ra




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

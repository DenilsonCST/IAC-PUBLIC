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
    la a0, VOCABULARY_FILENAME  # Ponteiro para o nome do ficheiro
    la a1, VOCAB_BUFFER        # Ponteiro para o enderço do buffer
    li a2, CONST_BUFFER_SIZE   # numero maximo de bytes a ler
    jal ra, read_file        #chama o read file
    
    la a0, VOCAB_BUFFER
    jal ra, print_vocabulary
  
    ###########################################################################
    # Read input
    ###########################################################################
    # TODO
    la a0, INPUT_FILENAME  # Ponteiro para o nome do ficheiro
    la a1, INPUT_BUFFER        # Ponteiro para o enderço do buffer
    li a2, CONST_BUFFER_SIZE               # numero maximo de bytes a ler
    jal ra, read_file        #chama o read file
    
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

	#A parte de baixo é só para verificação

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
# Parse W_V matrix from buffer
###########################################################################
    la a0, W_V_MATRIX        # a0 = address of the matrix where W_V will be stored
    la a1, MATRIX_BUFFER     # a1 = address of the buffer containing the W_V file contents
    jal ra, parse_matrix_buffer # convert the text buffer into an integer matrix

    # The code below is only for checking/debugging

    mv t0, a1                # save the number of rows returned by parse_matrix_buffer

    la a0, W_V_MATRIX        # a0 = address of the W_V matrix to print
    mv a1, t0                # a1 = number of rows
    li a2, CONST_DIMENSION   # a2 = number of columns
    jal ra, print_matrix     # print W_V matrix for verification

###########################################################################
# Read embeddings matrix
###########################################################################
    la a0, EMBEDDINGS_FILENAME # a0 = address of the embeddings filename
    la a1, MATRIX_BUFFER       # a1 = address of the buffer where file contents will be stored
    li a2, CONST_BUFFER_SIZE   # a2 = maximum number of bytes to read
    jal ra, read_file          # read embeddings.txt into MATRIX_BUFFER

###########################################################################
# Convert input tokens to indices
###########################################################################
    la a0, INPUT_INDICES_VECTOR # a0 = address of the output vector for token indices
    la a2, INPUT_BUFFER         # a2 = address of the input text buffer
    la a3, VOCAB_BUFFER         # a3 = address of the vocabulary text buffer
    jal ra, tokens_to_indices   # convert each input word into its vocabulary index

    la t0, INPUT_TOTAL_TOKENS   # t0 = address where the number of input tokens is stored
    sw a1, 0(t0)                # save the number of input tokens returned in a1

###########################################################################
# Build input embeddings matrix
###########################################################################
    la a0, INPUT_EMBEDDINGS_MATRIX # a0 = output matrix for input embeddings
    la a1, VOCAB_EMBEDDINGS_MATRIX # a1 = full vocabulary embeddings matrix
    la a2, INPUT_INDICES_VECTOR    # a2 = vector with the indices of the input tokens
    lw a3, INPUT_TOTAL_TOKENS      # a3 = number of input tokens
    jal ra, build_input_embeddings_matrix # copy the embeddings of the input tokens

###########################################################################
# Build matrix Q
###########################################################################
    la a0, Q_MATRIX                # a0 = output matrix Q
    la a1, INPUT_EMBEDDINGS_MATRIX # a1 = input embeddings matrix E

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
    la a0, SCORES_VECTOR
    la a1, Q_MATRIX
    la a2, K_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a3, 0(t0)    # a3 = n (number of tokens)

    li a4, CONST_DIMENSION # a4 = 4 

    addi a5, a3, -1        # a5 = n - 1 

    jal ra, compute_scores

	#parte de teste 
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
    mv a4, a1               # Move a1 to a4 because a4 is the expected arg of s_v_in_m 

    la a1, V_MATRIX
    
    la t0, INPUT_TOTAL_TOKENS
    lw a2, 0(t0)

    li a3, CONST_DIMENSION

    jal ra, select_vector_in_matrix

	#teste
	# a0 contém o endereço do vetor selecionado
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

	#teste
	# a0 = índice do token previsto 

    # Converter índice -> endereço no VOCAB_BUFFER
 	addi sp, sp, -8
    sw ra, 0(sp)                    # guardar endereço de retorno
    sw s0, 4(sp)                    # guardar s0

    mv s0, a0                       # s0 = índice do token previsto
    la a0, VOCAB_BUFFER             # a0 = início do VOCAB_BUFFER

find_vocab_addr:
    beq s0, zero, found_vocab_addr  # se índice = 0, já estamos na palavra certa
    lb t0, 0(a0)                    # lê caractere atual do buffer
    addi a0, a0, 1                  # avança ponteiro
    li t1, CONST_CHAR_NEWLINE
    bne t0, t1, find_vocab_addr     # se não é '\n', continua a avançar
    addi s0, s0, -1                 # encontrou '\n': decrementa contador de palavras restantes
    j find_vocab_addr

found_vocab_addr:
    # a0 aponta agora para o início da palavra correta no VOCAB_BUFFER
    jal ra, print_predicted_token   # imprime o token previsto

    lw ra, 0(sp)                    # restaurar endereço de retorno
    lw s0, 4(sp)                    # restaurar s0
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
    sw ra, 16(sp)    #guardo na stack o endereço de retorno
    sw a0, 12(sp)    
    sw a1, 8(sp) 
    sw a2, 4(sp)  
    
    #Abertura do ficheiro(open)
    lw a0, 12(sp)
    li a1, 0
    li a7, CONST_SYSCALL_OPEN
    ecall
    sw a0, 0(sp)  #salvo o file descriptor na stack
    
    #Leitura do ficheiro(read)
    lw a0, 0(sp)  # restauro o fd
    lw a1, 8(sp)   #tiro o endereço do buffer
    lw a2, 4(sp)
    li a7, CONST_SYSCALL_READ
    ecall
    
    #Fecho do ficheiro (close)
    lw a0, 0(sp)
    li a7, CONST_SYSCALL_CLOSE
    ecall 
    
    lw ra, 16(sp)
    addi sp, sp, 20
    
    jr ra #retorna para o chamador 
    
# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (in/out) a0: address of the matrix to fill (int*)
# (out)    a1: number of rows in the matrix (int)
# (in)     a1: address of the buffer containing the matrix data (char*)

parse_matrix_buffer:
	addi sp, sp, -4
	sw ra, 0(sp)

	li t0, 0 #  numero
	li t1, 0 # numero de linhas
	li t2, 1 # flag

parse_matrix_buffer_loop:
	lb t3, 0(a1) # carater atual

	li t4, CONST_CHAR_EOF
	beq t3, t4, end_parse  #se carater = EOF, branch to end

	li t4, CONST_CHAR_HYPHEN  # t4 = -
	beq t3, t4, change_flag # se carater = -, branch to change flag

	li t4, CONST_CHAR_SPACE
	beq t3, t4, save_number  #se carater = espaço, branch to save_number

	li t4, CONST_CHAR_NEWLINE
	beq t3, t4, new_line

	li t4, CONST_CHAR_ZERO
	blt t3, t4, next_caracter

	li t4, CONST_CHAR_NINE
	bgt t3, t4, next_caracter

	li t4, 10  
	mul t0, t0, t4 # numero * 10
	li t4, CONST_CHAR_ZERO
	sub t3,t3, t4  #change ASCII to digit number
	add t0, t0, t3 # numero = numero * 10 + digito

	j next_caracter

next_caracter:
	addi a1, a1, 1  #buffer++
	j parse_matrix_buffer_loop

change_flag:
	li t4, -1
	mul t2, t2, t4 #flag = -1
	j next_caracter

save_number:
	mul t0, t0, t2 # coloca o numero a positivo/negativo
	sw t0, 0(a0)  # save the number 
	addi a0, a0, 4
	addi a1, a1, 1  #buffer++
	mv t0, x0 # reinicializa o numero
	li t2, 1  # Flag = 1
	j parse_matrix_buffer_loop

new_line:
	addi t1, t1, 1
	j save_number

end_parse:
	mv a1, t1

	lw ra, 0(sp)
	addi sp, sp, 4

	jr ra	


# Converts the input words into their corresponding indices in the vocabulary.
# (in/out) a0: address of the vector where the indices will be stored
# (out)    a1: number of words/tokens found in the input
# (in)     a2: address of the input buffer
# (in)     a3: address of the vocabulary buffer
tokens_to_indices:
    addi sp, sp, -48        # reserve space on the stack
    sw ra, 0(sp)            # save return address
    sw s0, 4(sp)            # save the s registers used by this function
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

    mv s0, a0               # s0 points to the output indices vector
    mv s1, a2               # s1 points to the current position in the input buffer
    mv s2, a3               # s2 points to the beginning of the vocabulary buffer
    li s3, 0                # s3 counts how many input tokens were processed

tokens_next_input:
    lb t0, 0(s1)            # load the current input character
    beq t0, zero, tokens_done   # if null terminator is reached, finish

    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, tokens_skip_input_delim # skip newline characters

    li t1, CONST_CHAR_SPACE
    beq t0, t1, tokens_skip_input_delim # skip spaces

    li t1, 13
    beq t0, t1, tokens_skip_input_delim # skip carriage return characters

    mv s4, s1               # s4 stores the start address of the current input token
    mv s5, s1               # s5 will move until the end of the current input token

tokens_find_input_end:
    lb t0, 0(s5)            # load character while scanning the current input token
    beq t0, zero, tokens_search_vocab   # token ends at null terminator
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, tokens_search_vocab     # token ends at newline
    li t1, CONST_CHAR_SPACE
    beq t0, t1, tokens_search_vocab     # token ends at space
    li t1, 13
    beq t0, t1, tokens_search_vocab     # token ends at carriage return

    addi s5, s5, 1          # move to the next character
    j tokens_find_input_end

tokens_search_vocab:
    mv s6, s2               # s6 points to the current vocabulary token
    li s7, 0                # s7 stores the index of the current vocabulary token

tokens_vocab_loop:
    lb t0, 0(s6)            # load character from the vocabulary buffer
    beq t0, zero, tokens_store_missing  # end of vocabulary: token was not found

    mv s8, s6               # s8 stores the start of the current vocabulary token
    mv s9, s4               # s9 points to the current input token
    mv s10, s8              # s10 points to the current vocabulary token

tokens_compare_loop:
    beq s9, s5, tokens_check_vocab_end  # input token ended; check vocab token ended too

    lb t0, 0(s9)            # load character from the input token
    lb t1, 0(s10)           # load character from the vocabulary token
    bne t0, t1, tokens_vocab_no_match   # different characters mean no match

    addi s9, s9, 1          # move to next input character
    addi s10, s10, 1        # move to next vocabulary character
    j tokens_compare_loop

tokens_check_vocab_end:
    lb t1, 0(s10)           # load the character after the matched vocab part
    beq t1, zero, tokens_store_found    # vocab token also ended: match found
    li t0, CONST_CHAR_NEWLINE
    beq t1, t0, tokens_store_found      # vocab token ended at newline: match found
    li t0, CONST_CHAR_SPACE
    beq t1, t0, tokens_store_found      # vocab token ended at space: match found
    li t0, 13
    beq t1, t0, tokens_store_found      # vocab token ended at carriage return: match found

tokens_vocab_no_match:
    lb t0, 0(s6)            # scan until the end of the current vocabulary token
    beq t0, zero, tokens_store_missing
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, tokens_next_vocab
    addi s6, s6, 1
    j tokens_vocab_no_match

tokens_next_vocab:
    addi s6, s6, 1          # move to the next vocabulary token
    addi s7, s7, 1          # increment the vocabulary index
    j tokens_vocab_loop

tokens_store_found:
    sw s7, 0(s0)            # store the found vocabulary index
    addi s0, s0, 4          # move to the next output vector position
    addi s3, s3, 1          # count one more processed input token
    mv s1, s5               # continue input scan from the end of the current token
    j tokens_next_input

tokens_store_missing:
    li t0, -1               # use -1 when the token is not found
    sw t0, 0(s0)            # store -1 in the indices vector
    addi s0, s0, 4          # move to the next output vector position
    addi s3, s3, 1          # count one more processed input token
    mv s1, s5               # continue input scan after the current token
    j tokens_next_input

tokens_skip_input_delim:
    addi s1, s1, 1          # skip the delimiter character
    j tokens_next_input

tokens_done:
    mv a1, s3               # return the number of input tokens in a1

    lw ra, 0(sp)            # restore return address
    lw s0, 4(sp)            # restore saved registers
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
    addi sp, sp, 48         # release stack space
    ret


# Builds the input embeddings matrix.
# For each input token index, copies the corresponding row from the vocabulary embeddings matrix.
# (in/out) a0: address of the input embeddings matrix
# (in)     a1: address of the vocabulary embeddings matrix
# (in)     a2: address of the input indices vector
# (in)     a3: number of input tokens
build_input_embeddings_matrix:
    li t0, 0                # t0 is the current input row/token index

build_embeddings_row_loop:
    beq t0, a3, build_embeddings_done   # if all input tokens were processed, finish

    lw t1, 0(a2)            # load the vocabulary index of the current input token
    li t2, CONST_DIMENSION  # t2 = embedding dimension
    mul t1, t1, t2          # index * dimension gives the row offset in integers
    slli t1, t1, 2          # multiply by 4 because each integer has 4 bytes
    add t1, a1, t1          # t1 now points to the corresponding vocab embedding row

    li t2, 0                # t2 is the current column index

build_embeddings_col_loop:
    li t3, CONST_DIMENSION
    beq t2, t3, build_embeddings_next_row # if all columns were copied, go to next row

    lw t4, 0(t1)            # load one value from the vocabulary embedding row
    sw t4, 0(a0)            # store it in the input embeddings matrix

    addi t1, t1, 4          # move to the next value in the vocab embedding row
    addi a0, a0, 4          # move to the next output matrix position
    addi t2, t2, 1          # next column
    j build_embeddings_col_loop

build_embeddings_next_row:
    addi a2, a2, 4          # move to the next input token index
    addi t0, t0, 1          # move to the next input row/token
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
	mv a2, s6 # a2 = address of second vector 
	li a3, 4  # a3 = lenght of the vectors  
	li s2, 0  # s2 = index 
	li s3, 0x80000000 # s3 = max 
	mv s4, t2 # s4 = number of tokens in vocabulary 
do:
	mv a1,t0  # a1 = address of first vector
	jal ra, dot 
	j save

loop:
	mv a2, s6
	li a3, 4
	mv a1,t0  # a1 = address of first vector
	bge s2, s4, end_decide # if index > #tokens , branch
	jal ra, dot 
	bgt a1, s3, save # if a1 > max, save
	j next 

save: 
	mv s3, a1  # save the number as max 
	mv s5, s2  # save the index
	j next

next:
	addi s2, s2, 1
	addi s6, s6, 16
	mv a2, s6 
	j loop

end_decide:
	lw ra, 36(sp)
	lw a1, 28(sp)
	lw a2, 24(sp)
	lw a3, 20(sp)
	lw s2, 16(sp)
	lw s3, 12(sp)
	lw s4, 8(sp)
	lw s6, 0(sp)
	mv a0, s5   #save the index 

	lw s5, 4(sp)
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

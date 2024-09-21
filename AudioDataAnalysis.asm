# JMSSIM003
# question2.asm -- ead in a wave file, and then find the
# maximum and minimum amplitude (highest and lowest values) in the audio data
#   Register used:
#       $s0 -- holds most current max value
#       $s1 -- holds most current min value 
#       $s3 -- index

.data
Prompt1:      .asciiz "Enter a wave file name:\n"
Prompt2:      .asciiz "Enter the file size (in bytes):\n"
OutputMessage:  .asciiz "Information about the wave file:\n"
Separator:      .asciiz "================================\n"
FilePath:     .space 1024      # Allocate space for file path (64 bytes)
FileSize:     .word 0        # Space for file size (4 bytes)
buffer:       .space 2048    # Allocate space for the buffer (adjust size as needed)
newline:      .asciiz "\n"
msg1:         .asciiz "Maximum amplitude: "
msg2:         .asciiz "Minimum amplitude: "

.text
main:
    # PRINT PROMPT1
    la $a0, Prompt1
    li $v0, 4
    syscall

    # READ FILE PATH
    la $a0, FilePath
    li $a1, 63  # space for file path, leaving room for null terminator
    li $v0, 8
    syscall

    # PRINT PROMPT2
    la $a0, Prompt2
    li $v0, 4
    syscall

    # READ FILE SIZE
    la $a0, FileSize
    li $v0, 5
    syscall
    sw $v0, FileSize

    # PRINT OUTPUT MESSAGE 
    la $a0, OutputMessage
    li $v0, 4
    syscall

    # PRINT SEPARATOR
    la $a0, Separator
    li $v0, 4
    syscall

    # REMOVE THE NEWLINE CHARACTER
    la $t0, FilePath

loop:
    lb $t1, 0($t0)
    beqz $t1, done
    li $t2, 10
    beq $t1, $t2, remove_newline
    addi $t0, $t0, 1
    j loop

remove_newline:
    sb $zero, 0($t0)
done:
    # Open the file
    li $v0, 13
    la $a0, FilePath
    li $a1, 0  # Read-only mode
    li $a2, 0  # No flags
    syscall
    move $s0, $v0  # Save file descriptor in $s0


    # Move file size into register 
    lw $s1, FileSize   # $s1 = file size 

    ##  Allocate a buffer based on file size ##
    li $v0, 9   # syscall for sbrk
    lw $a0, FileSize       # size to allocate 
    syscall 

    # move allocated memory address into a buffer 
    move $a1, $v0   # $a1 = buffer address


    # Read the file into the buffer 
    li $v0, 14      # syscall for reading 
    move $a0, $s0
            # buffer address loaded  
    lw $a2, FileSize   # Number of bytes to read
    syscall
    

    # Close the file
    li $v0, 16
    move $a0, $s0
    syscall

    # GRAB THE FIRST 2 VALUES TO BEGIN YOUR LOOP
    move $t0, $a1 
    addi $t0, $t0, 44  # Skip header (adjust if header size is different)

   # Initialize max and min values
   li $s0, -32768
   li $s1, 32767

find_max_min:
    li $s3, 2        # Size of each value (2 bytes)
    move $t0, $a1 
    addi $t0, $t0, 44  # Skip header (adjust if header size is different)
    lw $a2, FileSize  # Load file size

    addi $a2,$a2,-44 

find_loop:
    blez $a2, end    # If file size <= 0, end loop

    lbu $t1, 0($t0)
    lbu $t2, 1($t0)
    sll $t2, $t2, 8
    or $t1, $t1, $t2
    # Sign extedn the value from 16-bit to 32-bits
            sll $t1, $t1, 16    # shift left by 16 bits 
            sra $t1, $t1, 16    # arithmetic shift by 16 bits 

    # Check if $t1 > $s0
    bgt $t1, $s0, update_max
    # Check if $t1 < $s1
    blt $t1, $s1, update_min

    addi $t0, $t0, 2
    subu $a2, $a2, $s3   # Decrease file size

    j find_loop

update_max:
    move $s0, $t1
    j find_loop

update_min:
    move $s1, $t1
    j find_loop

end:
    # PRINT MESSAGE 1 THEN Maximum
    la $a0, msg1
    li $v0, 4
    syscall

    move $a0, $s0
    li $v0, 1
    syscall

    # PRINT NEWLINE
    la $a0, newline
    li $v0, 4
    syscall

    # PRINT MESSAGE 2 THEN MINIMUM
    la $a0, msg2
    li $v0, 4
    syscall

    move $a0, $s1
    li $v0, 1
    syscall

    # PRINT NEWLINE
    la $a0, newline
    li $v0, 4
    syscall

    # EXIT
    li $v0, 10
    syscall

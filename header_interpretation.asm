        .data
FilePath:   .space 64
Prompt1:     .asciiz "Enter a wave file name:\n"
Prompt2:    .asciiz "Enter the file size (in bytes):\n"
OutputMessage:  .asciiz "Information about the wave file:\n"
Separator:      .asciiz "================================\n"
FileSize:   .word 0

filename:  .asciiz "q1_t1_in.wav"   # Path to the WAV file
buffer:    .space 44              # Buffer to hold the header (44 bytes)
msg:       .asciiz "Number of channels: "
msg2:	.asciiz "Sample rate: "
msg3:	.asciiz "Byte rate: "
msg4:	.asciiz "Bits per sample: "
newline:   .asciiz "\n"

        .text
        .globl main

main:
	# PRINT PROMPT1
        la $a0, Prompt1  # load prompt1 address into $a0
        li $v0, 4       # load print_string service into $v0
        syscall         # make syscall


        # READ FILE PATH
        la $a0, FilePath     # load file path address into $a0
        li $a1, 63            # load text size
        li $v0, 8            # load read_string service
        syscall              # make syscall

        # PRINT PROMPT2
        la $a0, Prompt2  # load prompt2 address into $a0
        li $v0, 4       # load print_string service into $v0
        syscall         # make syscall

        #READ FILE size
        la $a0, FileSize    # load file size address into $a0
        li $v0, 5          # syscal: read_int
        syscall            # make syscall
        sw $v0, FileSize

        # PRINT OUT INDICATOR TEXT
        la $a0, OutputMessage     # load output message address
        li $v0, 4           # load print_string service
        syscall             # make syscall

        # PRINT SEPARATOR
        la $a0, Separator     # load Separator address
        li $v0, 4           # load print_string service
        syscall             # make syscall

	# REMOVE THE NEWLINE CHARACTER
	la $t0, FilePath
loop:
	lb $t1, 0($t0)     		# Load byte from file path
    	beqz $t1, done     		# If null terminator is found, exit loop
    	li $t2, 10         		# ASCII code for newline ()
    	beq $t1, $t2, remove_newline    # If it
    	addi $t0, $t0, 1   		# Move to the next byte
    	j loop             		# Repeat loop

remove_newline:
	sb $zero, 0($t0) # replace newline with null terminator
done:
        # Open the file
        li      $v0, 13               # Syscall: open
        la      $a0, FilePath          # File name
        li      $a1, 0                 # Read-only mode
        li      $a2, 0                 # No flags
        syscall
        move    $s0, $v0               # Save file descriptor in $s0
	
	
        # Read the header (44 bytes)
        li      $v0, 14               # Syscall: read
        move    $a0, $s0              # File descriptor
        la      $a1, buffer           # Buffer address
        li      $a2, 44               # Number of bytes to read
        syscall

        # Close the file
        li      $v0, 16               # Syscall: close
        move    $a0, $s0              # File descriptor
        syscall


   			##    READ NUMBER OF CHANNELS   ##
        # Extract number of channels (2 bytes at offset 22)
        la      $t0, buffer           # Base address of buffer
        addi    $t0, $t0, 22	      #  move to offset 22
	
	lbu $t1,0($t0) 
	lbu $t2,1($t0)

        # Combine bytes (little-endian to big-endian)
        sll     $t2, $t2, 8           # Shift the most significant byte left
        or      $t1, $t1, $t2         # Combine with least significant byte

        # Print the result
        li      $v0, 4                # Syscall: print string
        la      $a0, msg              # Address of the message
        syscall

        li      $v0, 1                # Syscall: print integer
        move    $a0, $t1              # Number of channels
	move 	$s0, $t1	# save number of channel to $s0
        syscall

        li      $v0, 4                # Syscall: print newline
        la      $a0, newline
        syscall
		
			##    READ SAMPLE RATE     ##
	
	la $t0, buffer      # load address into $t2
        addi $t0, $t0, 24    #  move to offset
        
        # load bytes from memory
        lbu $t1, 0($t0)  # load the byte at address $t0
        lbu $t2, 1($t0)  # load the 2nd byte
        lbu $t3, 2($t0)  # load the 3rd byte
        lbu $t4, 3($t0)  # load the 4th byte

        # combine the bytes into a 32-bit value 
        sll $t2, $t2, 8       # shift the 2nd byte left by 8 bits
        sll $t3, $t3, 16      #shift the 3rd byte left by 16 bits         
        sll $t4, $t4, 24      #shift the 4th byte left by 24 bits 

        or $t1, $t1, $t2
        or $t1, $t1, $t3
        or $t1, $t1, $t4 

        # Print the result
        li      $v0, 4                # Syscall: print string
        la      $a0, msg2              # Address of the message
        syscall

        li $v0, 1
        move $a0, $t1 
        syscall

        #PRINT NEWLINE 
        la $a0, newline
        li $v0, 4
        syscall
        
                        ##     READ BYTE RATE       ##
        la $t0, buffer      # load address into $t2
        addi $t0, $t0, 28    #  move to offset
        
        # load bytes from memory
        lbu $t1, 0($t0)  # load the byte at address $t0
        lbu $t2, 1($t0)  # load the 2nd byte
        lbu $t3, 2($t0)  # load the 3rd byte
        lbu $t4, 3($t0)  # load the 4th byte

        # combine the bytes into a 32-bit value 
        sll $t2, $t2, 8       # shift the 2nd byte left by 8 bits
        sll $t3, $t3, 16      #shift the 3rd byte left by 16 bits         
        sll $t4, $t4, 24      #shift the 4th byte left by 24 bits 

        or $t1, $t1, $t2
        or $t1, $t1, $t3
        or $t1, $t1, $t4 

        # print the results 
        # Print the result
        li      $v0, 4                # Syscall: print string
        la      $a0, msg3              # Address of the message
        syscall

        li $v0, 1
        move $a0, $t1 
        syscall
        
        #PRINT NEWLINE 
        la $a0, newline
        li $v0, 4
        syscall

           
           
           ##    READ BITS PER SAMPLE   ##
	# read bits per sample
	# Extract number of channels (2 bytes at offset 22)
        la      $t0, buffer           # Base address of buffer
        addi    $t0, $t0, 34          #  move to offset 22

        lbu $t1,0($t0) 
        lbu $t2,1($t0)

        # Combine bytes (little-endian to big-endian)
        sll     $t2, $t2, 8           # Shift the most significant byte left
        or      $t1, $t1, $t2         # Combine with least significant byte


	#print bits per sample
	la $a0, msg4
	li $v0, 4
	syscall

	move $a0, $t1
	li $v0, 1
	syscall

        #PRINT NEWLINE 
        la $a0, newline
        li $v0, 4
        syscall

exit:
     # Exit
     li      $v0, 10               # Syscall: exit
     syscall

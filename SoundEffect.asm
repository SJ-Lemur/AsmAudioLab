# JMSSIM003 
# question3.asm -- will read in a WAVE file, and will then 
#           reverse the audio data in the file, and output this to a new file.
#   Registers used:

    .data 
input_filename:  .space 64
output_filename: .space 64
file_size:       .word 0


buffer:     .space 44      # 44 bytes for header
buffer2:    .space 1024    # buffer for reading data chunks

    .text
main:
        # Read input file name 
        la $a0, input_filename  
        li $v0, 8                
        syscall                 

        # Read output file name 
        la $a0, output_filename 
        li $v0, 8               
        syscall                 

        # Read file size 
        lw $a0, file_size   
        li $v0, 5            
        syscall    
        sw $v0, file_size         

remove_input_space:
        # Remove newline character from input filename
        la $t0, input_filename 
        loop1:
	        lb $t1, 0($t0)     		
    	    beqz $t1, done     		
    	    li $t2, 10         		
    	    beq $t1, $t2, remove_newline1    
    	    addi $t0, $t0, 1   		
    	    j loop1             		

        remove_newline1:
	        sb $zero, 0($t0) # replace newline with null terminator

remove_output_space:
        # Remove newline character from output filename
        la $t0, output_filename 
        loop2:
	        lb $t1, 0($t0)     		
    	    beqz $t1, done     		
    	    li $t2, 10         		
    	    beq $t1, $t2, remove_newline2    
    	    addi $t0, $t0, 1   		
    	    j loop2             		

        remove_newline2:
	        sb $zero, 0($t0) # replace newline with null terminator

    ## OPEN THE FILES ##
    # open input file 
    li $v0, 13              
    la $a0, input_filename  
    li $a1, 0               
    li $a2, 0               
    syscall 
    move $s0, $v0           
    bltz $s0, exit          

    # Open output file 
    li $v0, 13          
    la $a0, output_filename 
    li $a1, 577              # write-only mode 
    li $a2, 438            # permissions
    syscall 
    move $s1, $v0       
    bltz $s1, exit       



    ### STEP 1: COPY THE HEADER (1st 44 bytes) TO OUTPUT FILE ###
copy_header:
        # Read header from input file 
        li $v0, 14       
        move $a0, $s0   
        la $a1, buffer  
        li $a2, 44     # Read 44 bytes (header size)
        syscall
        move $t0, $v0       

        # Write header to output file
        li $v0, 15      
        move $a0, $s1   
        la $a1, buffer  
        move $a2, $t0   # Write exactly 44 bytes
        syscall  
reverse_audio:
        

        lw $t0, file_size
        addi $t0, $t0, -44

        ##  Allocate a buffer based on file size ##
        li $v0, 9   # syscall for sbrk
        move $a0, $t0       # size to allocate 
        syscall 


        # move allocated memory address into a buffer 
                move $a1, $v0   # $a1 = buffer address
       
        li $v0, 14               # Read from input file into buffer
        move $a0, $s0
        move $a1, $a1 
        move $a2, $t0             # Read data in chunks (1024 bytes per chunk)
        syscall
        move $t0, $v0           # $t0 = number of bytes read
        blez $t0, done           # if no bytes are read, exit

        # Make sure we're handling data in multiples of 2 (16-bit samples)
        #andi $t0, $t0, 0xFFFE    # Mask off the last bit to ensure even number of bytes

reverse_chunk:
        move $t1, $a1          # start of buffer
        addu $t2, $t1, $t0       # point to end of the buffer
        addi $t2, $t2, -2        # set pointer to last sample (2 bytes before the end)

reverse_loop:
        blt $t2, $t1, write_chunk  # stop when $t1 crosses $t2

        lh $t3, 0($t1)           # load 2 bytes (1 sample) from start
        lh $t4, 0($t2)           # load 2 bytes (1 sample) from end
        sh $t4, 0($t1)           # store end sample at start
        sh $t3, 0($t2)           # store start sample at end
        addi $t1, $t1, 2         # move forward by 2 bytes
        addi $t2, $t2, -2        # move backward by 2 bytes
        j reverse_loop           # continue reversing

write_chunk:
        # Write the reversed chunk back to the output file
        li $v0, 15
        move $a0, $s1
                # a1 loaded 
        move $a2, $t0            # Write exactly the number of bytes read
        syscall

        j reverse_audio          # repeat for the next chunk

done:
    # close the input file
    li $v0, 16
    move $a0, $s0
    syscall 

    # close the output file 
    li $v0, 16
    move $a0, $s1 
    syscall 

exit:
        li $v0, 10      
        syscall 
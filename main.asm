###############################################################################
# USER TEXT SEGMENT
#
# MARS start to execute at label main in the user .text segment.
###############################################################################

	.globl main
	.text
main:
	# Trigger an arithmetic overflow exception. 
	li $s0, 0x7fffffff  
       	addi $s1, $s0, 1	

	# Trigger a bad data address (on load) exception.	
	lw $s0, 0($zero)
	
	# Trigger a bad data adress (on store) exception
	sw $s0, 0($zero)
	
	# Trigger a trap exception. 
	teqi $zero, 0
	
	# Triger a breakpoint exception
	break

	# Get value of the memory mapped receiver control register.  	
  	lw $s0, 0xffff0000	

	# Set bit 1 (interrupt enable) in receiver control to 1.
	ori $s1, $s0, 0x2
        
 	# Update the memory mapped receiver control register.
        sw $s1, 0xffff0000
          
infinite_loop: 
	# This infinite loop simulates the CPU doing something useful such as
	# executing another job while waiting for user keyboard inut.
	addi $s0, $s0, 1
	j infinite_loop


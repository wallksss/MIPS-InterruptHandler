###############################################################################
# KERNEL DATA SEGMENT
###############################################################################
	.kdata
__m1_:	.asciiz "  Exception "
__m2_:	.asciiz " occurred and ignored\n"
__m3_:  .asciiz "  Pressed key: "
__m4_:  .asciiz " \n"
__e0_:	.asciiz "  [Interrupt] "
__e1_:	.asciiz	"  [TLB modification exception]"
__e2_:	.asciiz	"  [TLB (load or instruction fetch)]"
__e3_:	.asciiz	"  [TLB (store)]"
__e4_:	.asciiz	"  [Address error (load or instruction fetch)] "
__e5_:	.asciiz	"  [Address error (store)] "
__e6_:	.asciiz	"  [Bus error (instruction fetch)] "
__e7_:	.asciiz	"  [Bus error (data reference: load or store)] "
__e8_:	.asciiz	"  [Syscall] "
__e9_:	.asciiz	"  [Breakpoint] "
__e10_:	.asciiz	"  [Reserved instruction] "
__e11_:	.asciiz	"  [Coprocessor Unusable] "
__e12_:	.asciiz	"  [Arithmetic Overflow] "
__e13_:	.asciiz	"  [Trap] "
__e14_:	.asciiz	""
__e15_:	.asciiz	"  [Divide by zero] "
__e16_:	.asciiz	"  [Floating point Overflow]"
__e17_:	.asciiz	"  [Floating point Underflow]"

__excp:	.word __e0_, __e1_, __e2_, __e3_, __e4_, __e5_, __e6_, __e7_, __e8_, __e9_
	.word __e10_, __e11_, __e12_, __e13_, __e14_, __e15_, __e16_, __e17_
	
kernel_stack: .space 1024	
###############################################################################
# KERNEL TEXT SEGMENT 
###############################################################################

   	# The exception vector address for MIPS32.
   	.ktext 0x80000180  
   
__handler_entry_point:
	#In order to make a re-entrant we have to use a stack. But we can't trust the $sp, so we use our own allocated stack.
	la $k0, kernel_stack + 1024
	addi $k0, $k0, -44
	
	#Save $at, which is used in pseudoinstructions. So we don't want to overwrite.
	sw $at, 0($k0)
	
	#Get some free registers
	sw $v0, 4($k0)
	sw $a0, 8($k0)
	sw $a1, 12($k0)
	sw $a2, 16($k0)
	sw $a3, 20($k0)
	sw $v1, 24($k0)
	sw $t0, 28($k0)
	sw $t1, 32($k0)
	sw $s0, 36($k0)
	sw $ra, 40($k0)	
	
	#Make $t0 the stack pointer.
	move $t0, $k0
	
	# Get value in cause register.
	mfc0 $k0, $13   

	# Mask all but the exception code (bits 2 - 6) to zero and shift two bits to the right to get the exception code. 
	andi $s0, $k0, 0x00007c  
	srl  $s0, $s0, 2
	
	#Print information about the exception.
	li $v0 4
	la $a0 __m1_
	syscall

	li $v0 1
	move $a0, $s0
	syscall

	li $v0 4
	andi $a0 $k0 0x3c
	lw $a0 __excp($a0)
	nop
	syscall
	
	#Check for bad PC
	bne $k0 0x18 __ok_pc	
	nop

	mfc0 $a0 $14
	andi $a0 $a0 0x3
	beq $a0 0 __ok_pc
	nop

	li $v0 10
	syscall
	
__ok_pc:
	li $v0 4
	la $a0 __m2_
	syscall

	beqz $s0, __interrupt
	
__exception:
	# Branch on value of the the exception code in $s0. 
	beq $s0, 4, __bad_address_exception_load
	
	beq $s0, 5, __bad_address_exception_store
	
	beq $s0, 9, __breakpoint_exception
	
	beq $s0, 12, __overflow_exception
	
	beq $s0, 13, __trap_exception

__unhandled_exception: 
    	
	#Adicionar codigo de tratamento

 	j __resume_from_exception
 	
 __bad_address_exception_load:

	#Adicionar codigo de tratamento
	
 	j __resume_from_exception	
 	
 __bad_address_exception_store:
 
 	#Adicionar codigo de tratamento
 
 	j __resume_from_exception	
 	
 __breakpoint_exception:
 
 	#Adicionar codigo de tratamento

 	j __resume_from_exception
 	
__overflow_exception:

 	#Adicionar codigo de tratamento
 
 	j __resume_from_exception
 
__trap_exception: 

 	#Adicionar codigo de tratamento
 
 	j __resume_from_exception

__interrupt: 
	# Value of cause register should already be in $k0. 
	# Mask all but bit 8 (interrupt pending) to zero. 
    	andi $k1, $k0, 0x00000100
    	
    	# Shift 8 bits to the right to get the inerrupt pending bit as the 
    	# least significant bit. 
    	srl  $k1, $k1, 8
    	
    	# Branch on the interrupt pending bit. 
    	beq  $k1, 1, __keyboard_interrupt

__unhandled_interrupt: 
 	#Don't skip instruction at EPC since it has not executed.
 	j __resume

__keyboard_interrupt:     	
	li $v0 4
	la $a0 __m3_
	syscall
	
	# Get ASCII value of pressed key from the memory mapped receiver data register. 
	# Store content of the memory mapped receiver data register in $k1.
	lw $k1, 0xffff0004
	move $a0, $k1
	li $v0, 11
	syscall
	
	li $v0 4
	la $a0 __m4_
	syscall
	
	#Don't skip instruction at EPC since it has not executed.
	j __resume
	

__resume_from_exception: 
        # Get value of EPC (Address of instruction causing the exception).
        mfc0 $k0, $14
        
	# Update EPC in coprocessor 0.
        addi $k0, $k0, 4    
        mtc0 $k0, $14
        
__resume:
	#Restore registers
	lw $at, 0($t0)
	lw $v0, 4($t0)
	lw $a0, 8($t0)
	lw $a1, 12($t0)
	lw $a2, 16($t0)
	lw $a3, 20($t0)
	lw $v1, 24($t0)
	lw $t1, 32($t0)
	lw $s0, 36($t0)
	lw $ra, 40($t0)	
	addi $t0, $t0, 44
	
	#Falta restaurar o t0
	
	mfc0 $k0 $12		# Set Status register
	ori  $k0 0x1		# Interrupts enabled (I dont know if it's necessary)
	mtc0 $k0 $12
	
	# Use the eret instruction to set the PC to the value saved in the EPC register.
	eret

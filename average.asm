.data
	answer: .word 0
	array:	.word 720, 480, 80, 3, 1, 0      #enter array elements here
	length: .word 6 		#enter length of the array here
	resultMessage: .ascii "The recursive average is: "
	
.text

.globl main
	main:	
		jal decrypt
		endDecrypt:
			
     ####### below here does average calculation ########		
		lw $a0, length
		
		jal avg
		sw $v0, answer
		
		
		#sysout "The recursive average is: "
		li $v0, 4
		la $a0, resultMessage
		syscall
		
		#sysout answer
		li $v0, 1
		lw $a0, answer
		syscall
		
		
		##end of program
		li $v0, 10
		syscall
#######################################################################################
#-------------------recursive average func---------------------------------		
.globl avg
avg:
	subu $sp, $sp, 8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	#--------base case------ if(n=0)#
	move $v1, $a0
	beq $a0, 0, avgDone
	
	#-------recursive case ---------#
	sub $a0, $a0, 1		#n--
	jal avg	#avg(n-1)
	
	la $t1, array
	mul $t3, $v1, 4	 	#
	add $t1, $t1, $t3 	#address manipulation
	lw $t2, ($t1)  	    #fetching arr[n-1]
	
	mul $v0, $v0, $v1	#
	add $v1, $v1, 1		# v0 = ( avg(n-1) * (n-1) + arr[n-1] ) / n
	add $v0, $t2, $v0	#
	div $v0, $v0, $v1	#

	avgDone:
		lw $ra, ($sp)
		lw $s0, 4($sp)		#returning
		addu $sp, $sp, 8
		jr $ra
															
#decrypt function-------------------------------------------------
.globl decrypt
decrypt:
	la $t1, array		
	lw $t2, length		
	li $t3, 0 	#i
	decryptLoop:
		lw $t4, ($t1)
		andi $t5 ,$t4, 1	#if ( number andi 1 equals 1) that number is odd 
		beq $t5, 1, isOddNumber	#
		j isEvenNumber
			isOddNumber:
				move $a1, $t4
				li  $a2, 5	#mul by 5
				jal multip1	
				mulEnd:
				sw $v0, 0($t1)  #division result stored to the same place
				j endState
			isEvenNumber:
				move $a1, $t4
				li  $a2, 8	#div by 8
				jal divi1
				divEnd:
				sw $v0, 0($t1)
				j endState
		endState:
		add $t1, $t1, 4
		addi $t3, $t3, 1
		blt $t3, $t2, decryptLoop #when i<length, keep looping
		j endDecrypt
		
		
		
.globl multip1
multip1:
	move	$t6, $a1		
	move	$t7, $a2		
	li	$t8, 0 

	# Main loop body
	loop33:	sub	$t6, $t6, 1	# i = i -1
	add	$t8, $t8, $t7	# sum = sum + i
	beqz	$t6, exit33	# if i == 0 stop
	j	loop33
	
	exit33:
		move $v0, $t8
		j mulEnd
		
.globl divi1
divi1:
	move	$t6, $a1		# initialize counter (i)
	move	$t7, $a2		# initialize sum
	li	$t8, -1

	# Main loop body
	loop22:	sub	$t6, $t6, $t7	# number -= divisor
	addi	$t8, $t8, 1	# sum = sum + i
	blt   	$t6, $0, exit22	# if number < 0 stop
	j	loop22
	exit22:
		move $v0, $t8
		j divEnd		
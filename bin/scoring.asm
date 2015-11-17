.text

##  If word is correct, take character count, multiply by 10, then subract time
##

## takes the $t7 value from input/getLength and calculates the current running score and stores to $s4
runningScore:
	
	lw $t0, possibleWordsCounter
	addi $t0, $t0, 1
	sw $t0, possibleWordsCounter
	
	li $v0, 4
	la $a0, inDict
	syscall
	
	lw $t7, inputLength
	
	mul $t7, $t7, 10
	add $s4, $s4, $t7
	jr $ra

subtractFromScore:

	sub $s4, $s4, $s2
	
	jr $ra

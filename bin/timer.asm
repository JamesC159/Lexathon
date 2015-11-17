.text

####	timer.asm can be used to clock anything, jal getStartTime at start point, jal getEndTime at end point, don't forget to save $ra to stack if going to be changed
getStartTime:

	li $v0, 30		##	gets current system time in milliseconds and returns in $a0
	syscall
	
	move $s0, $a0		##	moves returned value to storage register $s0
	div $s0, $s0, 1000	##	converts to seconds
	
	jr $ra			##	jumps back to link where function was called

getEndTime:	

	li $v0, 30		##	gets current system time in milliseconds and returns in $a0
	syscall
	
	move $s1, $a0		##	moves returned value to storage register $s1
	div $s1, $s1, 1000	##	converts to seconds
	
	sub $s2, $s1, $s0	##	subracts start time from end time to get time elapsed and stores in register $s2
	
	jr $ra			##	jumps back to link where function was called
	
## adds to time elapsed	
addToTimer:

	add $s3, $s3, $s2
	jr $ra
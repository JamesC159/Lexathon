.text

####	initializes variables to be used in random.asm
load:

	li $t1, 0			##	initializes $t1 to 0
	la $t2, nineWordBuffer		##	loads nineWordBuffer address to $t2

####	generates random number to search for random 9 letter word, takes the random number and moves to that character in nineWord array
random:
	
	li $a0, 3			##	lower limit past the first \n  and \r
	li $a1, 281900			##	upperbound of character count
	li $v0, 42			##	syscall 42 to generate random number with upperbound in $a1, returns number in $a0
	syscall

	move $t1, $a0			##	moves number generated to $t1 register
	
	la $t0, nineWord		##	loads nineWord address to $t0
	add $t0, $t0, $t1		##	moves the nineWord array pointer to random number character

####	Advances pointer in nineWord array to next \n and uses the next word in the array
advanceChar:

	lb $t7, ($t0)			##	loads current random pointed character to $t7
	beq $t7, 0xa, fillNineWord	##	branch to fillNineWord when it finds the next \n
	addi $t0, $t0, 1		##	increments the pointer to next character
	b advanceChar			##	loops back until \n is found
	
fillNineWord:
	add $t0, $t0, 1
	fillLoop:
	lb $t3, ($t0)			##	load currently pointed character to $t3
	beq $t3, 0xd, possibleArrayJump	##	branch to printNineWord when it sees the \r
	sb $t3, ($t2)			##	stores first letter of word in nineWordBuffer
	addi $t2, $t2, 1		##	increments nineWord pointer
	addi $t0, $t0, 1		##	increments nineWordBuffer pointer
	b fillLoop			##	loops until the 9 letter word is filled to nineWordBuffer based on \r



####	ready the box to be generated	####
possibleArrayJump:

	push($ra)
	jal buildPossibleArray
	pop($ra)

loadBox:

	li $t3, 0				## initialize loop counter
	la $t0, boxArray		## load boxArray pointer to $t0
	la $t1, nineWordBuffer	## load 9 letter word pointer to $t1
#	addi $t1, $t1, 1		## increment nineWordBuffer to get next byte after \r
	
####	load each character from nineWordBuffer and store it into boxArray	####
genBox:

	beq $t3, 9, getKey
	lb $t2, ($t1)			## load character from nineWordBuffer
	sb $t2, ($t0)			## store that character into boxArray
	addi $t1, $t1, 1		## increment the nineWordBuffer pointer by 1
	addi $t0, $t0, 1		## increment the boxArray pointer by 1
	addi $t3, $t3, 1		## increment the loop pointer
	b genBox				## loop until 9 letters have been loaded into boxArray

####	store the central character in the boxArray as the key character	####
getKey:

	la $t0, boxArray		## load boxArray pointer to $t0
	lb $t1, 4($t0)			## load 5th byte from box array, this is the central key letter!
	sb $t1, key				## store central key in reserved memory space "key"
	
	la $t0, boxArray		## load boxArray pointer to $t0
	
	push($ra)
	jal printReady
	pop($ra)
####	Randomizes the boxArray with a simple pseudorandom algorithm each time the user shuffles	####
####	Only works once. Can anyone think of a way to do it???

randomize:
	
	la $t0, nineWordBuffer	## load the address of the word in the box
	li $t1, 0				## initialize counter to 0
	
randLoop:
	
	beq $t1, 9, printScreen	## if loop counter = 9, ##Changed to b to printScreen, which calls printBox, but also prints current time and score
	beq $t1, 4, increment	## if loop counter is at central letter, increment counter
	
	li $v0, 42
	li $a0, 4				## generate random number 0-8
	li $a1, 8
	syscall
	
	move $t2, $a0			## move random number to $t2
		
	bne $t2, 4, contRand	## if loop counter is not central letter, continue randomization
	j randLoop				## otherwise
	
contRand:
	
	beq $t1, $t2, randLoop	## if loop count equals to 
	
	lb 	$t3, boxArray($t1)	#load character at t1 
	lb 	$t4, boxArray($t2)	#load character at t2
	sb 	$t4, boxArray($t1)	#store character in t4 into location at t1
	sb 	$t3, boxArray($t2)	#store character in t3 into location at t2
	
	
increment:
	
	addi $t1, $t1, 1		## increment loop counter
	j randLoop
#####	Print the box out after randomization	####
printBox:
	
	li $t2, 0
	li $t1, 0
	li $t0, 0
	
	printChars(32, 19)				# prints space 19 times
	printChars(42, 13)				# prints "*" 13 times (top of box)
	newline
	printChars(32, 19)				# prints space 19 times
	la $t0, boxArray				# load the box array into $t0
	
loopPrint:

	beq $t1, 3, lineFeed
	beq $t1, 6, lineFeed
	beq $t1, 9, returnPrint
	
contPrint:

	lb $t2, ($t0)					# load byte from box array
	printChar(42)					# prints '*'
	printChar(32)
	li $v0, 11
	la $a0, ($t2)					# print the byte
	addi $a0, $a0, -32				# capitalizes character in box
	syscall
	printChar(32)
	addi $t0, $t0, 1				# increment box pointer
	addi $t1, $t1, 1				# increment loop counter
	j loopPrint

lineFeed:

	printChar(42)					# prints '*'
	newline
	printChars(32, 19)				# prints space 19 times
	printChars(42, 13)				# prints "*" 13 times (in middle of box)
	newline
	printChars(32, 19)				# prints space 19 times
	j contPrint
	
returnPrint:

	printChar(42)					# prints '*'
	newline
	printChars(32, 19)				# prints space 19 times
	printChars(42, 13)				# prints "*" 13 times (in middle of box)
	
	jr $ra							# return to newGame.asm

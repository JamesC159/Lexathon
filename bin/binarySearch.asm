.data

validWords:	.space 5000
validWordsPos:	.word 0
validWordNewline:	.word 0

.text

foundTheWord:

	#awards points and
	#awards time.
	li $t0, 0
	lw $t2, validWordsPos

	
	
storeWordsLoop:
	lb $t1, userInput($t0)		# load characters from userInput
	beq $t1, 0xa, contStoreWords
	sb $t1, validWords($t2)		# store characters into validWords array
	addi $t0, $t0, 1		# increment userInput pointer
	addi $t2, $t2, 1		# increment validWords pointer

	j storeWordsLoop		# loop
	
contStoreWords:
##  Prints a ", " after a word, will also add a newline if a certain string length is reached...working on that part
	li $t6, 0x2c
	li $t7, 0x20
	sb $t6, validWords($t2)
	addi $t2, $t2, 1

	sb $t7, validWords($t2)
	addi $t2, $t2, 1

	push($ra)
	jal contStoreWordsNewline
	pop($ra)
#
	sw $t2, validWordsPos
	j finishStoreWords
	
contStoreWordsNewline:		## If a line in the words found list approaches or exceeds 100 characters, jump to contStoreWordsNewlineAdd

	lw $t5, validWordNewline
	li $t7, 100
	div $t2, $t7
	mflo $t6
	blt $t5, $t6, contStoreWordsNewlineAdd
	jr $ra
	
contStoreWordsNewlineAdd:	## adds a \n on the end of a line

	addi $t5, $t5, 1
	sw $t5, validWordNewline
	li $t4, 0xa
	sb $t4, validWords($t2)
	addi $t2, $t2, 1

	jr $ra
	
printValidWords:
	li $t0, 0		# validWords pointer
		
	li $v0, 4
	la $a0, userValidWords	#print valid words prompt
	syscall
	
countValidWordsLines:		## loads array to count how many \n's are in the file

	la $t0, validWords
	li $t2, 0
	
	countValidWordsLoop:	## counts the \n's and exits when reaches the end of array
	
		lb $t1, ($t0)
		beq $t1, 0x0, finishPrintValidWords
		addi $t0, $t0, 1
		bne $t1, 0xa, countValidWordsLoop
		addi $t2, $t2, 1
		b countValidWordsLoop
	
	
finishPrintValidWords:		## prints the valid words found and the appropriate amount of \n's

	printStr(validWords)

	subi $t2, $t2, 13
	bgt $t2, 0, finishPrintValidWordsExit	## doesn't print a \n if greater than n lines long
	
	newlineValidWords:		## prints new lines until enough have been printed
	
		beq $t2, 0, finishPrintValidWordsExit
		newline
		addi $t2, $t2, 1
		b newlineValidWords
		
finishPrintValidWordsExit:	## addes a delay then jumps back to printscreen
	
	pressAnyKey
	
	jr $ra
	
	
finishStoreWords:
	pop($t0)
	sub $t0, $t0, 1			#MIGHT NEED TO CHANGE BACK
	li $t1, 0x20
	
clearWordLoop:
	lb $t6, ($t0)
	sb $t1, ($t0)
	beq $t6, 0x24, wordIsCleared	#MIGHT NEED TO CHANGE BACK

	sub $t0, $t0, 1
	j clearWordLoop
	wordIsCleared:
	
	push($ra)
	jal runningScore		## calculate the current running score by adding points
	pop($ra)
	jr $ra				#once you've found the word and added points, return to the program
	
wordNotFound:

	li $v0, 4
	la $a0, notInDict
	syscall
	newline
	b printScreen

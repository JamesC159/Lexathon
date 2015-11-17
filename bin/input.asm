.text


####	Get the user input for the guessed word.	####
getInput:
	
	lw $t0, possibleWordsCount
	lw $t1, possibleWordsCounter
	beq $t0, $t1, foundAllWords
	
	push($ra)
	jal getStartTime			## starts timer directly before user input
	pop($ra)

	li $v0, 8
	la $a0, userInput			## store input into storage location userInput
	li $a1, 11				## allow for up to 9 character input including Enter (\n) and null
	syscall
	
	push($ra)
	jal getEndTime				## stops timer directly after user inputs word
	pop($ra)
	
	push($ra)
	jal addToTimer				## adds time to elapsed timer
	pop($ra)
	
	push($ra)
	jal subtractFromScore
	pop($ra)
	
	la $t0, userInput
	li $t2, 0				## initialize character counter
	
####	Get the length of the word to check to see if it is valid	####	
preGetLength:

	la $t0, userInput

getLength:

	lb $t1, ($t0)				## load characters from user input
	beq $t1, 10, checkLength		## if character loaded is null (end of input) check the length
	addi $t2, $t2, 1			## counts each character in the user input buffer
	addi $t0, $t0, 1			## increment pointer
	b getLength

####	Checks to see if the word is of valid length	####
checkLength:
	
	sw $t2, inputLength		## save the length of the word	
	beq $t2, 1, checkSQCD		## if the user only input one character, check to see if it is a "s" or "S"
	
contCheckLength:

	blt $t2, 4, tooShort	## if input is less than 4 characters, then branch to invalLength
	bgt $t2, 9, checkEnter		## if input is greater than 9 characters, check to see if Enter (\n\) is last byte
	move $t7, $t2				## before null
	move $s5, $t2
	
####	Commented out for the time being since it doesn't search for correct word	
	#push($ra)
	#jal wordSearch			## save return address on stack and search for the word
	#pop($ra)

	push($ra)
	jal checkIfInBox
	pop($ra)

	newline


## Prints the screen, time elapsed, current score, and the box
printScreen:

	newlines(1)
	printStr(wordsFound)
	printWord(possibleWordsCounter)
	printChar(0x2F)
	printWord(possibleWordsCount)
	newlines(1)
	printStr(timeElapsed)		## print the elapsed time prompt
	printInt($s3)			## print the elapsed time integer
	newlines(1)
	printStr(currentScore)		## print the current score prompt
	printInt($s4)			## print the current score integer
	newlines(3)
	
	push($ra)
	jal printBox			## save return address on stack and re-print the box
	pop($ra)
	
	newline
	printStr(hotKeys)
	newline
	printStr(enterWord)
	
	b getInput			## allow user to enter another word after input
	
printCheatScreen:	

	newlines(3)	
	printStr(possibilityArray)
	newlines(2)
	printStr(wordsFound)
	printWord(possibleWordsCounter)
	printChar(0x2F)
	printWord(possibleWordsCount)
	newlines(1)
	printStr(timeElapsed)		## print the elapsed time prompt
	printInt($s3)			## print the elapsed time integer
	newlines(1)
	printStr(currentScore)		## print the current score prompt
	printInt($s4)			## print the current score integer
	newlines(3)

	push($ra)
	jal printBox			## save return address on stack and re-print the box
	pop($ra)
	
	newline
	printStr(hotKeys)
	newline
	printStr(enterWord)
		
	b getInput			## allow user to enter another word after input
	

checkEnter:
	
	la $t0, userInput
	li $t1, 10
	lb $t2, userInput($t1)
	bne $t2, 0xa, tooLong
	b getInput
	

####	Checks to see if the user input "s" or "S" to shuffle the box	####
checkSQCD:

	la $t0, userInput
	lb $t1, ($t0)
	beq $t1, 115, isS	#s
	beq $t1, 83, isS	#S
	
	beq $t1, 113, isQ	#q
	beq $t1, 81, isQ	#Q

#	beq $t1, 99, isC	#c
#	beq $t1, 67, isC	#C	
			
	beq $t1, 100, isD	#d
	beq $t1, 68, isD	#D
	
	b contCheckLength
	
####	If they did enter "s" or "S", then shuffle the box	###	
isS:
	
	newlines(2)	
	j randomize		## jumps to randomize, which also calls the reprint and moves to getInput

isQ:

	push($ra)
	jal possibilitesPrint
	pop($ra)

	quitMenu:
	
		newlines(9)
		printStr(finalScore)
		move $a0, $s4
		li $v0, 1
		syscall
		newlines(9)
		printStr(quitKeys)
	
		la $a0, menuSelect		##	loads address to store user input
		la $a1, 2			#	allows for one character input
		li $v0, 8			#	syscall 8 for character
		syscall				##
	
		la $t0, menuSelect		
		lb $t1, 0($t0)			
		beq $t1, 0x44, printQuitWordsFound
		beq $t1, 0x64, printQuitWordsFound
		beq $t1, 0x50, printQuitWordsNotFound
		beq $t1, 0x70, printQuitWordsNotFound
		b quitMenuExit
	
		printQuitWordsNotFound:
		
			newlines(2)
			printStr(wordsNotFound)
			newlines(2)
			push($ra)
			jal possibilityPrintCountNewline
			pop($ra)
			b quitMenu
		
		printQuitWordsFound:
		
			newlines(2)
			printStr(wordsFound)
			newlines(2)
			push($ra)
			jal printValidWords
			pop($ra)
			b quitMenu
	
	quitMenuExit:
	
		jal compareScores	## final score held in $s4, then passed to compareScores in highScores.asm, branches back to menu afterwards

		newlines(9)
		printStr(clearingArrays)
		newlines(10)
		
		jal clearArrays
		jal reset
	
		b menu

isC:

	b printCheatScreen

isD:

	newline
	push($ra)
	jal printValidWords
	pop($ra)
	newlines(3)
	b printScreen	#printValid words is in binarySearch.asm
	
foundAllWords:

	newlines(9)
	printStr(congratulations)
	newlines(9)
	timeDelay(2000)

	b isQ	
	
####	Display invalid length prompt and allow the user to input again		####
####	$t2 holds length of the word
tooShort:

	newline
	printStr(short)
	newline
	b printScreen
	
tooLong:

	newline
	printStr(long)
	newline	
	b printScreen
	


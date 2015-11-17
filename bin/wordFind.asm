checkIfInBox:

	push($ra)
	jal filltempNineWordBuffer
	pop($ra)
	
	li $t1, 4			#make t1 4 real quick
	lb $t8, tempNineWordBuffer($t1)	#t8 becomes the 4th character out of the fixed nine-letter word. (this will be the middle character in the box)
	add $t0, $zero, $zero		#clear t0
	add $t9, $zero, $zero		#clear t9
	add $t1, $zero, $zero		#clear t1
	lookingLoop:
		add $t1, $zero, $zero	#clear t1 again as it's used as another loop counter that resets each time this higher loop "lookingLoop starts"
		lb $t2, userInput($t0)				## load character at t2 from user input
		
		beq $t2, 10, inputIsInBox			## if character loaded is null (end of input) check the length
		#addi $t2, $t2, 1				## counts each character in the user input buffer
		nineWordBufferLoop:				#loop to search through tempNineWordBuffer for a character in user input
			lb $t3, tempNineWordBuffer($t1)		#t3 is the nth character in the temporary nine-letter word
			beq $t2, $t3, continueLookingLoop	#if the character in user input = the character in the nine-letter word, then continue as this letter can be used since it is in the box
			beq $t3, 10, inputIsNotInBox		#(LOOP EXIT)	#if the entire box array or nine letter word was checked (the chracter = "\n") and the user input character is not in it, then reject it and return
			addi $t1, $t1, 1			#increment the index looking through the nine letter word or the box array
		j nineWordBufferLoop				#continue the loop
		continueLookingLoop:			#the character is in the box. continue incrementing through user input characters
		sb $zero, tempNineWordBuffer($t1)		# t9 has 0 in it, so we overwrite the letter with 0 so that no repeat letters can be entered in (if I didn't do this, then if "ha" was in the nine letter word, It would accept "hahaha")
		addi $t0, $t0, 1			## increment pointer looking through user input characters
		
		j lookingLoop				# continue the loop going through user input characters	

inputIsInBox:		#code for the condition that the word only has letters in the box
	add $t0, $zero, $zero
	lw $t2, inputLength
	#sub $t2, $t2, 1
	checkForCentralLetter:	#this code checks to make sure the central letter isn't missing
	
	lb $t1 userInput($t0)
	beq $t0, $t2, centralLetterMissing	#if it has looped through all of the user input, (and lands on "\n") then the word doesn't have the middle letter and cannot be used
	beq $t1, $t8, verifyInPossible		#if the user input has the middle letter, then continue	#t8 was created at the beginning of checkIfInBox and loaded the middle character from the nine letter word before it was partially erased 3(coded) lines before inputIsInBox
	add $t0, $t0, 1
	j checkForCentralLetter

verifyInPossible:

	push($ra)
	jal linearSearch
	pop($ra)
	
	jr $ra

inputIsNotInBox:

	printStr(notInBox)
	newline
	
	b printScreen
	
centralLetterMissing:	
	
	printStr(useMiddleLetter)
	newline
	
	b printScreen		#continue program

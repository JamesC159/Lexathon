.text

####	Function searches through possibility array for the userInput word.
linearSearch:

	la $t0, possibilityArray
	la $t1, userInput
	addi $t0, $t0, 1		## Starts off at $, so increment to first real letter
		
	linearSearchLoop:
	
		lb $t3, ($t1)
		beq $t3, 0xa, foundMatchingString	## When the user input reaches the 0xa, it should have found a whole matching word or string
		
		findMatchingWord:			## both first bytes of the possibility array and user input are loaded
		
			lb $t2, ($t0)
			bne $t2, $t3, advanceToNextPossiblity	## If the first bytes dont match, then the whole word isn't a match
			beq $t2, 0x21, reloadUserInput		## if a 0x21 on possibilityArray is reached, and 0xa on userInput hasn't been reached then user input is longer than the possibility
			beq $t2, 0x0, wordAlreadyFound		## end of possibilityArray has been reached, but jump to see if word has already been found
			beq $t2, $t3, linearSearchIncrement	## jump to increment both characters of possible word and user input
			
			advanceToNextPossiblity:		## advances to next possibility
			
				addi $t0, $t0, 1
				lb $t2, ($t0)
				beq $t2, 0x0, wordAlreadyFound
				bne $t2, 0x24, advanceToNextPossiblity	## advance to the 0x24 for the beginning of the next word
				la $t1, userInput			## reload the user input
				addi $t0, $t0, 1			## move possibilityArray to first character of word (past the $)
				b linearSearchLoop
			
			reloadUserInput:		## reloads the userInput and increments possibilityArray past the !$
			
				la $t1, userInput
				addi $t0, $t0, 2
				b linearSearchLoop
			
			linearSearchIncrement:		## increments both characters for possibilityArray and userInput
			
				addi $t0, $t0, 1
				addi $t1, $t1, 1
				b linearSearchLoop
				
	foundMatchingString:	##  If a string is found and the possibility array is at the "!" pointer, then a whole word match has been found
		
		lb $t2, ($t0)
		beq $t2, 0x21, wordFound	## if the 0x21 has been reached, then jump to wordFound
		b wordAlreadyFound		## if the 0x21 has not been reached then search through possible words already found
		
	wordFound:		## wordFound pushes the $t0 to be restored later and jumps to foundTheWord
		
		push($t0)
		b foundTheWord

	wordAlreadyFound:	## search to see if the userInput has already been found in validWords
	
		la $t6, validWords
		la $t1, userInput
		
		wordAlreadyFoundLoop:
		
			lb $t3, ($t1)
			beq $t3, 0xa, wordNotFoundValid		## if it reaches the 0xa, then not in the words found
			
			matchInputToValidWords:
			
				lb $t7, ($t6)
				beq $t7, 0x2c, reloadUserInputValid
				beq $t7, 0x0, wordNotFoundValid
				beq $t7, $t3, incrementInputValid
				addi $t6, $t6, 1
				b matchInputToValidWords
				
			reloadUserInputValid:
			
				la $t1, userInput
				addi $t6, $t6, 1
				b wordAlreadyFoundLoop
				
			incrementInputValid:
			
				addi $t1, $t1, 1
				addi $t6, $t6, 1
				b wordAlreadyFoundLoop
				
		wordNotFoundValid:
		
			b wordNotFound
		
			

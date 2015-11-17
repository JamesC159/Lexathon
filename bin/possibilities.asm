.data

possibilityArray:	.space 100000		## holds all the matches for the box word
possibleWordsCount:	.word 0			## holds the total count of words that match the box word
possibleWordsCounter:	.word 0			## holds the increment of words found
tempNineWordBuffer:	.space 10		## used as a temp nine word buffer
possibilityArrayPrint:	.space 100000		## printable version of possibilities array at end of game
possibilityArrayNewline:.word 0

.text

###################
buildPossibleArray:	## initalizes possibilites function by filling a temp buffer with the box word, and loading the neccessary variables

	
	
	push($ra)
	jal filltempNineWordBuffer
	pop($ra)
	
	la $t0, tempNineWordBuffer
	la $t1, buffer		## contains the dictionary
	la $t2, possibilityArray
	lb $t3, 4($t0)		## load the pivot letter (5th character) of the box word
	
	matchPivotLetter:	## With the pivot letter loaded, cycle through dictionary to find a match
	
		lb $t4, ($t1)
		beq $t4, 0x0, endOfDictionary
		beq $t4, $t3, pivotMatch
		addi $t1, $t1, 1
		b matchPivotLetter
		
		pivotMatch:	## When a pivot letter is found in a word, decrement the pointer until the beginning of the word is found	
		
			subi $t1, $t1, 1
			lb $t4, ($t1)
			bne $t4, 0x24, pivotMatch
			addi $t1, $t1, 1
			b compareWholeWord
			
			compareWholeWord:	## When the pointer has been decremented to the beginning of the word, load first byte of word
			
				lb $t4, ($t1)
				beq $t4, 0x21, wholeWordFound		## If search below has jumped and incremented past the whole word, then a whole word has been matched

				compareWholeWordLoop:		## Take the first byte of the word and try to match to a letter in the box word
					
					lb $t3, ($t0)
					beq $t3, 0x0, moveToNextDictionaryWord		## If the box word has reached the end and not found a match, jump to moveToNextDictionaryWord
					beq $t3, $t4, matchFound	## If a box letter matches the byte loaded of the dictionary word, jump to matchFound
					addi $t0, $t0, 1
					b compareWholeWordLoop
				
					matchFound:		## when a letter has been matched, whiteout the box word letter with a space so it can't be reused for next search
				
						li $t7, 0x20
						sb $t7, ($t0)
						la $t0, tempNineWordBuffer
						addi $t1, $t1, 1
						b compareWholeWord		## jump back to start search of next letter in dictionary word
					
				wholeWordFound:		## If a whole word has been found, pointer will point to end of word !, so move pointer back to $ beginning of word
					
					subi $t1, $t1, 1
					lb $t4, ($t1)
					beq $t4, 0x21, wholeWordFoundLoop
					b wholeWordFound

					wholeWordFoundLoop:		## loop to store whole found word in possibilityArray, loads both the $ beginning and ! end

						addi $t1, $t1, 1
						lb $t4, ($t1)
						sb $t4, ($t2)
						addi $t2, $t2, 1
						beq $t4, 0x21, moveToNextDictionaryWord
						b wholeWordFoundLoop

				moveToNextDictionaryWord:	## increments to the next word in the dictionary to pick up the search again
						
					addi $t1, $t1, 1
					lb $t4, ($t1)
					beq $t4, 0x0, endOfDictionary
					bne $t4, 0x24, moveToNextDictionaryWord
					addi $t1, $t1, 1
					push($ra)
					jal filltempNineWordBuffer
					pop($ra)
					la $t0, tempNineWordBuffer	## reload the tempNineWordBuffer
					lb $t3, 4($t0)			## reload the pivot letter of the box word to for search through dictionary						
					b matchPivotLetter

#######################
####	Function refills the temp buffer with the nine letter word again							
filltempNineWordBuffer:

	la $t0, tempNineWordBuffer
	la $t7, nineWordBuffer
	
	filltempNineWordBufferLoop:
	
		lb $t6, ($t7)
		beq $t6, 0x0, filltempNineWordBufferLoopExit	## when loaded byte reaches 0x0, the whole word has been filled to temp
		sb $t6, ($t0)
		addi $t7, $t7, 1
		addi $t0, $t0, 1
		b filltempNineWordBufferLoop	## loops until whole word is filled
		
	filltempNineWordBufferLoopExit:
	
		jr $ra
		
			
				

possibilitesPrint:

	la $t0, possibilityArray
	la $t2, possibilityArrayPrint
	li $t3, 0
		
	possibilitesPrintLoop:
	
		lb $t1, ($t0)
		beq $t1, 0x0, possibilityPrintExit
		addi $t0, $t0, 1
		bne $t1, 0x24, possibilitesPrintLoop										
		
		possibilitesPrintCopy:
			
			lb $t1, ($t0)
			beq $t1, 0x21, possibilitesPrintCommaSpace
			sb $t1, ($t2)
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			b possibilitesPrintCopy
	
		possibilitesPrintCommaSpace:
		
			li $t6, 0x2c
			li $t7, 0x20
			sb $t6, ($t2)
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			sb $t7, ($t2)
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			push($ra)
			jal possibilitesPrintNewline
			pop($ra)
			b possibilitesPrintLoop
	
		possibilitesPrintNewline:		## If a line in the words found list approaches or exceeds 100 characters, jump to contStoreWordsNewlineAdd

			lw $t5, possibilityArrayNewline
			li $t7, 100
			div $t3, $t7
			mflo $t6
			blt $t5, $t6, possibilitesPrintNewlineAdd
			jr $ra
			
		possibilitesPrintNewlineAdd:	## adds a \n on the end of a line

			addi $t5, $t5, 1
			sw $t5, possibilityArrayNewline
			li $t4, 0xa
			sb $t4, ($t2)
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			jr $ra
	
	possibilityPrintExit:
	
		jr $ra
	

possibilityPrintCountNewline:		## loads array to count how many \n's are in the file

	la $t0, possibilityArrayPrint
	li $t2, 0
	
	possibilityPrintCountNewlineLoop:	## counts the \n's and exits when reaches the end of array
	
		lb $t1, ($t0)
		beq $t1, 0x0, possibilityPrintNewlineFinish
		addi $t0, $t0, 1
		bne $t1, 0xa, possibilityPrintCountNewlineLoop
		addi $t2, $t2, 1
		b possibilityPrintCountNewlineLoop
	
	
	possibilityPrintNewlineFinish:		## prints the valid words found and the appropriate amount of \n's

	printStr(possibilityArrayPrint)

	subi $t2, $t2, 13
	bgt $t2, 0, possibilityPrintNewlineFinishExit	## doesn't print a \n if greater than 15 lines long
	
	possibilitesPrintNewlineFinishLoop:		## prints new lines until enough have been printed
	
		beq $t2, 0, possibilityPrintNewlineFinishExit
		newline
		addi $t2, $t2, 1
		b possibilitesPrintNewlineFinishLoop
		
possibilityPrintNewlineFinishExit:	## addes a delay then jumps back to printscreen
	
	pressAnyKey
	
	jr $ra


################
####	If end of dictionary is reached, the search has ended, and the total words found are counted.			
endOfDictionary:

	la $t0, possibilityArray
	li $t2, 0

	countPossibleWords:	## Counts the ! in the possibiltyArray to determine total number of
	
		lb $t1, ($t0)
		beq $t1, 0x0, exitPossibleArray		## signifies no more words to count
		beq $t1, 0x21, incrementPossibleWords	## ! is counted to determine total words
		addi $t0, $t0, 1
		b countPossibleWords		## loops until ! is found
		
		incrementPossibleWords:		## increments the possibilityArray as well as the counter
			
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			b countPossibleWords
				
	exitPossibleArray:	## when all !'s have been counted, store the count in possibleWordsCount
	
		la $t0, possibleWordsCount
		sw $t2, ($t0)
		jr $ra

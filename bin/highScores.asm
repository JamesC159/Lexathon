.data

highScorePrompt:.asciiz "\n*** New High Score!! ***"
typeNamePrompt:	.asciiz "\nPlease enter your name: "
negativeScorePrompt:	.asciiz	"\n\nSorry, negative scores are not recorded.\nPlease do better next time!\n"
errorScores:	.asciiz "\n\n\n\n\n\n\n         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n         ! Error Loading Scores File... !\n         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n\n\n\n\n\n\n\n\n"
scoresPrompt:	.asciiz "\n\n\n@@@@@@@@@@@@@@@@@@ Top 10 Scores @@@@@@@@@@@@@@@@@@\n\n"

convertScore:	.space 10		# converts score from hex to ascii
reverseScore:	.space 10		# reverses the convertScore array
extractBuffer:	.space 10		# pulls score from high scores for comparison
bufferScores:	.align 2		# holds the data in scores.txt as array
		.space 519		#
typeNameArray:	.align 2		# holds the user name for a new high score
		.space 20		# max 19 characters
copyBuffer:	.align 2		# used to hold the copied data from the bufferScores array
		.space 519		# 

.text

## function called when user requests high scores from the menu
highScores:

	jal readScores
	jal printScores
	jal overwriteScoresArrays
	jal reset
	
	b menu

####	Function to read scores.txt
readScores:
	
	openFileRead(scores)			##
	beq $t0, 0xFFFFFFFF, printScoresError	## 	If the file is not found, $v0 will be -1, so branch to error message if equal

	li $v0, 14				##	syscall 14 to read file
	move $a0, $t0				#	$t0 holds the file descriptor for "four" and moves it to argument $a0
	la $a1, bufferScores			#	$a1 for address to store data read from file
	li $a2, 519				#	$a2 for the array length
	syscall					##
	
	closeFile
	
	jr $ra

####	Function to write to scores.txt
writeScores:

	openFileWrite(scores)			##
	beq $t0, 0xFFFFFFFF, printScoresError	## 	If the file is not found, $v0 will be -1, so branch to error message if equal

	li $v0, 15				##	syscall for write to file
	move $a0, $t0				##	$t0 holds the file descriptor, moves to $a0 for writing
	la $a1, bufferScores			##	bufferScores holds array to write to file
	li $a2, 519				##	writes 519 bytes
	syscall
	
	closeFile

	jr $ra

####	Function to print high scores array
printScores:

	printStr(scoresPrompt)
	printStr(bufferScores)
	newlines(2)
	printChars(64,51)
	newlines(1)
	pressAnyKey
	jr $ra


####################################################################################################
####	After a game end, a jump statment is directed to here and passes the final score in $s4
####	First the score is compared to 0, if less than 0, it will jump to the negativeScore function
####	otherwise it will start the high scores comparision.
####	First the final score will be converted to ASCII.
####	Then the current high scores will be read from file.
####	The file only holds 10 high scores, which are extracted and stored in a temp array.
####	The current score is compared to each of the 10 high scores and finds its appropriate place.

compareScores:	

	blt $s4, 0, negativeScore		## Game feature, doesn't store negative scores
	push($ra)
	jal convertScoreToAscii			## jumps to convert $s4 passed score
	jal readScores				## reads current scores.txt and stores to bufferScores
	
	li $t7, 23				## initialize $t7, used to point to last digit of score to be extracted
	jal extractScores			## jumps to begin extraction and comparison
	jal writeScores				## bufferScores now holds the new high scores array to be written to file
	pop($ra)
	
	jr $ra					## returns back to menu, view high scores to see your new score
	
	
####################################################################################################
####	Converts score to ASCII
####	Process is a bit complicated.  Variable $s4 hold the score in hexadecimal and 
####		needs to be converted to an ASCII string of its decimal equivalent.
####	Process includes taking the hexadecimal variable, dividing by 10, storing its modulus
####		in a new array, and repeating until the hex value reaches a 0 divisor.
####	After each iteration, +0x30 will be added to convert the digit to ASCII and stored on byte.
####	The new array will hold the bytes of the decimal ascii equivalent, but in reverse order
####	A function is included to reverse the order of the converted score to display appropriately
####	E.G.  Score passed 1234 = 0x4D2
####	0x4D2 will need to read as 0x31323334 = "1234"

convertScoreToAscii:

	la $t0, convertScore		## loads buffer to store converted digits/ASCII
	la $t1, reverseScore		## loads buffer to hold reversed converted digits/ASCII
	li $t2, 1			## counter

####	Loop for converting to ASCII	
convertScoreToAsciiLoop:	

	div $s4, $s4, 10			## divides score by 10
	mfhi $t7				## modulus in MFHI, stored to $t7
	mflo $t6				## divisor in MFLO, stored to $t6
	addi $t7, $t7, 0x30			## modulus + 0x30 to convert to ascii
	sb $t7, ($t0)				## stores in byte location of convertScore
	addi $t0, $t0, 1			## increments byte location of convertScore
	addi $t2, $t2, 1			## increments counter
	bne $t6, 0x0, convertScoreToAsciiLoop	## loops until the dividend is 0, then proceeds to branch addSpaces
	b addSpaces				## jumps to addSpaces to fill in whitespace

####	The maximum digits allowed in the score is 10 (2,147,483,436), so for asthetics and
####	further comparison functions, we need fill in the remaining digits with whitespace
addSpaces:

	li $t3, 0x20				## loads a "space" in $t3		
	sb $t3, ($t0)				## stores the "space" in current convertScore location
	beq $t2, 10, reverseScoreArray		## when all 10 spaces are filled, will branch to reverse the array
	addi $t0, $t0, 1			## increments convertScore
	addi $t2, $t2, 1			## increments counter
	b addSpaces				## loops to continue filling whitespace

####	Fills in reverseArray to make the conversion read from left to right
reverseScoreArray:

	lb $t3, ($t0)				## loads by from converted scores, initially pointing at last digit
	sb $t3, ($t1)				## stores that byte in reverseScore
	addi $t2, $t2, -1			## decrements counter
	beq $t2, 0, convertScoreExit		## when counter reaches 0, reversal is complete, brances to exit
	addi $t0, $t0, -1			## decrements pointer of convertScore
	addi $t1, $t1, 1			## increments pointer of reverseScore
	b reverseScoreArray			## loops until complete
	
####	Exits the conversion, forward reading score is stored in reverseScore
convertScoreExit:

	jr $ra
####################################################################################################





####################################################################################################
####	Extract scores one at a time and compare to current score


extractScores:

	la $t0, bufferScores		## reloads bufferScores
	add $t0, $t0, $t7		## value of $t7 added to pointer of bufferScores
	la $t1, extractBuffer		## extractBuffer used to hold score extracted from current high scores list
	li $t2, 1			## character count for high score

	push($ra)			
	jal findScore			## jumps to begin finding scores in current high scores list

##	The comparision will use reverse order buffers starting at highest order digits for comparison	
	la $t0, extractBuffer		## extractBuffer holds the extracted score in reverse order
	addi $t0, $t0, 9		## initializes pointer to highest order digit of extractBuffer
	la $t1, convertScore		## convertScore holds the backwards order of the converted score
	addi $t1, $t1, 9		## initializes pointer to highest order digit of convertScore
	li $t2, 9			## loop counter
	jal compareExtractConvert	## jumps to begin comparing
	
	pop($ra)			## restores link location
	jr $ra				## jumps back to "jal extractScores"

findScore:

	lb $t3, ($t0)			## loads digit of current high score
	sb $t3, ($t1)			## stores in buffer used for comparison
	addi $t0, $t0, -1		## decrements pointer of bufferScores
	addi $t1, $t1, 1		## increments pointer of extractBuffer
	addi $t2, $t2, 1		## increments counter
	bne $t2, 11, findScore		## continues looping until counter reaches 11
	jr $ra				## returns back to link of "jal findScore"
	
compareExtractConvert:

	lb $t3, ($t0)			## loads digit of extractBuffer
	lb $t4, ($t1)			## loads digit of convertScore
	blt $t4, $t3, nextScoreLine	## if convertScore is less than extractBuffer, it will branch to nextScoreLine to begin extracting the next highest score
	bgt $t4, $t3, newHighScore	## if convertScore is greater than extractBuffer, it will branch to begin placement of new high score
	beq $t2, 0, newHighScore	## if the scores turn out to be equal, the process will push the older high score below the new high score
	addi $t0, $t0, -1		## decrements pointer of extractbuffer
	addi $t1, $t1, -1		## decrements pointer of convertScore
	addi $t2, $t2, -1		## decrements counter
	b compareExtractConvert		## loops until score is to determined to be <, =, > than current high score

nextScoreLine:

	addi $t7, $t7, 52		## adds 52 to $t7, used to increment pointer of bufferScores to next score for extraction
	bgt $t7, 519, noNewScore	## bufferScores has a finite size to hold 10 scores, if comparison cannot find a score for which the new score is less than, then new score is not a high score
	b extractScores			## goes back to extractScores for next extraction/comparison
	
##	If new score is not a high score, then the program resets the buffers and registers then returns to menu
noNewScore:

	pop($ra)
	jr $ra
	
newHighScore:

	newlines(9)
	printStr(highScorePrompt)	## prints prompt notifying of new high score
	newlines(9)

	printStr(typeNamePrompt)	## prompts user to input name for new high score
	
	la $a0, typeNameArray		## typeNameArray hold the user's name
	li $v0, 8
	syscall
	
	move $t6, $t7			## save pointer number to currently pointed score
	addi $t6, $t6, -9		## move pointer number to beginning of score for overwrite
	
	la $t0, bufferScores		## loads current scores.txt array
	la $t1, copyBuffer		## initializes a copy buffer
	addi $t7, $t7, -23		## $t7 will be pointed to last digit of score in line needing replacement, subtract 23 to go to beginning of line
	add $t0, $t7, $t0		## moves pointer of bufferScores to beginning of line needing replacement
	li $t3, 0			## initializes counter
	add $t3, $t3, $t7		## sets $t3 to value of $t7 pointer for counting
	push($ra)
	jal copyScores			## jumps to begin copying the lines on and below current line for be pushed down the list
	
	la $t0, bufferScores		## reinitializes bufferScores
	la $t1, copyBuffer		## reinitializes copyBuffer
	addi $t7, $t7, 52		## adds 52 to $t7, the beginning of the next line where the copyBuffer will overwrite the lower scores of bufferScores with copied data
	add $t0, $t7, $t0		## sets pointer of bufferScores to next line as per $t7
	li $t3, 0			## initializes $t3
	add $t3, $t3, $t7		## sets $t3 counter to same as $t7
	jal moveScoresDown		## jumps to begin overwriting lower scores with copied data
	
	la $t0, bufferScores		## reinitializes bufferScores
	la $t1, reverseScore		## loads the new high score
	add $t0, $t6, $t0		## $t6 holds the pointer where new score needs to be overwritten
	li $t3, 1			## initializes counter
	jal overwriteScore		## jumps to begin overwriting score with new highscore
	
	addi $t0, $t0, 3		## sets pointer of bufferScores past "space hyphen space"
	li $t3, 1			## initializes counter
	jal overwriteName		## jumps to begin overwriting old name with spaces

	addi $t0, $t0, -23		## decrements pointer of bufferScores back to where name is to inserted	
	la $t1, typeNameArray		## loads user inputted name
	jal fillName			## jumps to begin filling name
	pop($ra)			## restores link location
	jr $ra				## jumps back to "jal compareExtractConvert"

		
##	Function copies the data from currently pointed line where score is less than new score, down to bottom of the list
##	When the bufferScores reaches end of list, it will return back to "jal copyScores"
##	Array copy buffer will hold the copied data from bufferScores	
copyScores:

	lb $t2, ($t0)
	sb $t2, ($t1)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t3, $t3, 1
	bne $t3, 519, copyScores		## when counter reaches 519, bufferScores is at the end of list
	jr $ra					## returns to "jal copyScores"
	
##	Function used to overwrite lower scores of bufferScores with copied data.  The lowest line/score will drop off the bottom and not be stored
moveScoresDown:

	lb $t2, ($t1)
	sb $t2, ($t0)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t3, $t3, 1
	bne $t3, 519, moveScoresDown		## when counter reaches 519, bufferScores is at the end of list
	jr $ra					## returns to "jal moveScoresDown"
	
##	overwrites score of current line with new high score
overwriteScore:

	lb $t2, ($t1)
	sb $t2, ($t0)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t3, $t3, 1
	bne $t3, 11, overwriteScore		## loops until counter reaches 11 (overwriting 10 digits)
	jr $ra					## returns to "jal overwriteScore"

##	overwrites name of current line with spaces
overwriteName:

	li $t2, 0x20				## loads "space" to be used to overwrite current data
	sb $t2, ($t0)
	addi $t0, $t0, 1
	addi $t3, $t3, 1
	bne $t3, 24, overwriteName		## loops until all all spaces have been overwritten with whitespace
	jr $ra					## returns to "jal overwriteName"
	
##	overwrites whitespace with new name
fillName:

	lb $t2, ($t1)
	beq $t2, 0xa, exitOverwrite		## continues to fill in characters until the name reaches end of array
	sb $t2, ($t0)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	b fillName				## loops to continue filling name

## used as branch for exit of fillName
exitOverwrite:

	jr $ra					## returns back to "jal fillName"
	
####	Completes adding new high score to top 10 list
####################################################################################################
	
####	If the scores file cannot be found, print this error
printScoresError:

	printStr(errorScores)
	pressAnyKey
	b menu
	
####

####	If score is negative, a prompt will appear after pressing any key	
negativeScore:
	
	la $a0, negativeScorePrompt
	li $v0, 4
	syscall
	
	pressAnyKey
		
	jr $ra			## returns back to isQ link in input.asm
####

####	Fucntion will overwrite highscores arrays to be used for next time
####	Starts counters at buffer size and counts down to 0
overwriteScoresArrays:

	push($ra)
	
	la $t0, convertScore
	li $t2, 10
	jal resetScoresArrayLoop
	
	la $t0, reverseScore
	li $t2, 10
	jal resetScoresArrayLoop
	
	la $t0, extractBuffer
	li $t2, 10
	jal resetScoresArrayLoop
	
	la $t0, bufferScores
	li $t2, 519
	jal resetScoresArrayLoop
	
	la $t0, typeNameArray
	li $t2, 20
	jal resetScoresArrayLoop
	
	la $t0, copyBuffer
	li $t2, 519
	jal resetScoresArrayLoop
	
	pop($ra)

	jr $ra		## returns to location that called function

####	Overwrites current array data with all nulls, ready to use for next time
resetScoresArrayLoop:

	li $t1, 0x0
	sb $t1, ($t0)
	addi $t0, $t0, 1
	addi $t2, $t2, -1
	bne $t2, 1, resetScoresArrayLoop
	jr $ra

.include  "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/macros.asm"
.data

####	ASCII strings used for display and prompts
menuPrompt:	.asciiz "\n\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@|-~*~()~*~-|@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@| LEXATHON |@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@|-~*~()~*~-|@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@|                 |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@| 1 - New Game    |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@|                 |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@| 2 - High Scores |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@|                 |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@| 3 - How to Play |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@|                 |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@| 0 - Exit        |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@|                 |@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
pressAnyKey:	.asciiz "\n\n***   Press any key to return to the menu...   ***"
thanks:		.asciiz "                Thanks for Playing!                \n"
loading:	.asciiz "\n\n\n\n\n\n\n\n\n                  **************\n                  * Loading... *\n                  **************\n\n\n\n\n\n\n\n"
errorDict:	.asciiz "\n\n\n\n\n\n\n         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n         ! Error Loading Dictionary...  !\n         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n\n\n\n\n\n"
clearingArrays:	.asciiz "Clearing Arrays and Registers..."
ready1:		.asciiz "\nGet ready in "
ready2:		.asciiz "GO!!!\n\n\n"
hotKeys:	.asciiz "\n'Q'=Quit, 'S'=Shuffle, 'D'=Display Valid Words Entered"
quitKeys:	.asciiz "\n'D'= Words found, 'P'= Words not found, Any Key to exit"
enterWord:	.asciiz"\nEnter a 4-9 letter word, then press Enter >> "
short:		.asciiz "\nThe word entered is too short, sorry try again!"
long:		.asciiz "\nThe word entered is too long, sorry try again!"
timeElapsed:	.asciiz "Total Time: "
currentScore:	.asciiz "Score: "
finalScore:	.asciiz "Final Score: "
notInBox:	.asciiz "\nThe word you made is not in the Box, Please try again!"
notInDict:	.asciiz "\nThe word you have entered is not in the Dictionary."
inDict:		.asciiz	"\nCongratulations! The word works, and earned you points!"
useMiddleLetter:.asciiz	"\nYour Input needs to contain the middle letter like the instructions say."
userValidWords: .asciiz "These are all of your valid words entered:\n\n"
wordsFound:	.asciiz "Words Found: "
wordsNotFound:	.asciiz "Words Not Found: "
howToPlay:	.asciiz "\nHow to Play:\n\nEnter a word between 4 and 9 characters containing the letters in the box.\nThe word must contain the central letter in the box.\nYou may shuffle the box, but the center letter will stay the same.\nIf your word is valid, you will be awarded 10 points per letter.\nOne point is deducted per second of game play.\n\nHot Keys:\n\nto shuffle - S\nview entered words - D\nquit game - Q\n"
congratulations:.asciiz "Congratulations!  You have found all the words!"

#sound: .byte 70
#soundLength: .byte 130
#loudness: .byte 100

####	Storage for the serarated word files based on character length

nineWord:	.space 300000

####	Used to store words that match the pivot letter and can be used for searches with the rest of the letters

nineTemp:	.space 300000
buffer:		.space 1000000		# This holds every chracter in the dictionary

####	labels for array storage
menuSelect:	.space 2		## Used for menu selection, allows only 1 character then automatically continutes
nineWordBuffer:	.space 10		## Stores random 9 letter word


boxArray:	.space 10			# Used to randomly generate the box
userInput:	.space 10
inputLength:	.word 0


####	Central Letter to the box and other components to print the box
key:		.byte 0				# reserve space for central letter in box
index:		.word 0				# reserve space for array indexing

####	files to import
scores:		.asciiz "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/scores.txt"
nine:		.asciiz "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/dictionary/9.txt"
dictFile:	.asciiz "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/dictionary/dictionary.txt"

.text
.globl main, exit


main:

	printStr(loading)
	
	openFileRead(dictFile)
	
# print errror if file not found
	beq $t0, 0xFFFFFFFF, printDictError
#read from file	
	li   $v0, 14       # system call for read from file
	move $a0, $t0      # file descriptor 
	la   $a1, buffer   # address of buffer to which to read
	li   $a2, 1000000  # hardcoded buffer length
	syscall            # read from file
	
# Close the file 
	closeFile


	b menu			## Branches to menu in menu.asm

menu:

	printStr(menuPrompt)		##	Prints menu
		
	la $a0, menuSelect		##	loads address to store user input
	la $a1, 2			#	allows for one character input
	li $v0, 8			#	syscall 8 for character
	syscall				##
	
	la $t0, menuSelect		##	loads address of stored user input/menu selection
	lb $t1, 0($t0)			##	loads the character that the user inputted
	beq $t1, '0', exit		##	if 0, branches to exit
	beq $t1, '1', newGame		##	if 1, branches to newGame in newGame.asm
	beq $t1, '2', highScores	##	if 2, branches to highScores in highScores.asm
	beq $t1, '3', instructions	##	if 3, branches to instructions in instructions.asm (currently under construction)
	b menu				##	if user input is out of range, loops back to prompt for new input

instructions:

	printStr(howToPlay)
	newlines(3)
	pressAnyKey

	b menu




####	Overwrites arrays by making them all \0's
clearArrays:
	push($ra)

	clearArray(validWordNewline,8)
	clearArray(possibilityArrayNewline,8)
	clearArray(possibilityArray,100000)
	clearArray(possibilityArrayPrint,100000)
	clearArray(possibleWordsCount,8)
	clearArray(possibleWordsCounter,8)
	clearArray(validWords,5000)	
	clearArray(validWordsPos,8)
	clearArray(nineWord,300000)
	clearArray(nineTemp,300000)
	clearArray(convertScore,10)
	clearArray(reverseScore,10)
	clearArray(extractBuffer,10)
	clearArray(bufferScores,519)
	clearArray(typeNameArray,20)
	clearArray(copyBuffer,519)

	pop($ra)

	jr $ra		## returns to location that called function


reset:
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $v0, 0
	jr $ra

exit:

	newlines(8)
	printStr(thanks)
	newlines(7)
	li $v0, 10		## exits program
	syscall

####	Other files to include in program

.include "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/possibilities.asm"
.include "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/linearSearch.asm"
.include "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/input.asm"
.include "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/highScores.asm"
.include  "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/newGame.asm"
.include  "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/initialize.asm"
.include "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/random.asm"
.include  "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/timer.asm"
.include "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/scoring.asm"
.include "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/wordFind.asm"
.include  "/Users/jamescombs/Desktop/School/CompArch./Project/Lexathon/bin/binarySearch.asm"

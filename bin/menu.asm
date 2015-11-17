.text

####	Menu
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

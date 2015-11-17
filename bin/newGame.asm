.text

newGame:
	push($ra)
	jal reset
	pop($ra)
	
	push($ra)
	jal initialize		## Links and jumps to initialize label in initialize.asm
	pop($ra)

	j load			##	jumps to load in random.asm
	
####	Display ready prompts to allow the user 3 seconds to get ready to start playing	####
printReady:

	newlines(18)
	printStr(ready1)
	printChar(0x33)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printChar(0x32)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printChar(0x31)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printChar(0x2e)
	timeDelay(250)
	printStr(ready2)
	timeDelay(500)
	
	jr $ra

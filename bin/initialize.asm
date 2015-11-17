.text

####	Initializes #Word array with imported #.txt files of dictionary
initialize:

	printStr(loading)

	openFileRead(nine)
	
	beq $t0, 0xFFFFFFFF, printDictError
	
	li $v0, 14
	move $a0, $t0
	la $a1, nineWord
	li $a2, 300000
	syscall
	
	closeFile
	
	jr $ra


####	Used to print error message then exits program
printDictError:

	la $a0, errorDict
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall

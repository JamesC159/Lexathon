.macro printWord(%word)
	lw $a0, %word
	li $v0, 1
	syscall
.end_macro

.macro printStr(%reg)	#reg stands for register and Str stands for string
	la $a0, %reg
	li $v0, 4
	syscall
.end_macro 

.macro printInt(%reg)
	move $a0, %reg
	li $v0, 1
	syscall
.end_macro

.macro push (%reg)
	addi $sp, $sp, -4
	sw %reg, 0($sp)
.end_macro

.macro pop (%reg)
	lw %reg, 0($sp)
	addi $sp, $sp, 4
.end_macro


## opens a file for reading and moves descriptor to $t0
.macro openFileRead(%file)
	li $v0, 13
	la $a0, %file
	li $a1, 0
	li $a2, 0
	syscall	
	move $t0, $v0
.end_macro

## opens a file for writing and moves descriptor to $t0
.macro openFileWrite(%file)
	li $v0, 13
	la $a0, %file
	li $a1, 1
	li $a2, 0
	syscall	
	move $t0, $v0
.end_macro

## closes file using descriptor saved to register $t0 from openFile()
.macro closeFile
	li $v0, 16
	move $a0, $t0
	syscall
.end_macro

## Used to prompt user to press any key then continues after key is pressed
.macro	pressAnyKey
	la $a0, pressAnyKey
	li $v0, 4
	syscall
	la $a0, menuSelect
	la $a1, 2
	li $v0, 8
	syscall
.end_macro

##	Prints new line
.macro newline
	li $v0, 11
	li $a0, 0xa		## print a new line
	syscall
.end_macro 

##	Prints "n" amount of new lines
.macro newlines(%n)
	push($t0)
	add $t0, $0, %n
	newLinesLoop:
	newline
	addi $t0, $t0, -1
	bgt $t0, 0, newLinesLoop
	pop($t0)
.end_macro

##	Prints charater, variable as either hex or decimal of character on ASCII table
.macro printChar(%char)
	li $v0, 11
	li $a0, %char						# print end of line stars
	syscall
.end_macro

##	Print same character "n" times
.macro printChars(%char, %n)
	push($t0)
	add $t0, $0, %n
	printCharsLoop:
	printChar(%char)
	addi $t0, $t0, -1
	bgt $t0, 0, printCharsLoop
	pop($t0)
.end_macro

.macro beepSound
li $v0, 31
la $a0, sound
lw $a0 0($a0)
la $a1, soundLength
lw $a1, 0($a1)

syscall
.end_macro

.macro clearArray(%label, %size)
	la $t0, %label
	li $t2, %size
	clearArraysLoop:
		li $t1, 0x0
		sb $t1, ($t0)
		addi $t0, $t0, 1
		addi $t2, $t2, -1
		bne $t2, 1, clearArraysLoop
.end_macro

##  Creates a time delay, arguement in milliseconds
.macro timeDelay(%delay)
	li $v0, 32
	la $a0, %delay
	syscall
.end_macro


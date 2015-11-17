.data
allTempScores:	.ascii	"\n"
		.ascii	"\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
		.ascii	"@@@	1.	James		7839		 @@@\n"
		.ascii	"@@@	--------------------------------------	 @@@\n"
		.ascii	"@@@	2.	Chris		6432		 @@@\n"
		.ascii	"@@@	--------------------------------------	 @@@\n"
		.ascii	"@@@	3.	Nic		4003		 @@@\n"
		.ascii	"@@@	--------------------------------------	 @@@\n"
		.ascii	"@@@	4.	_____		____		 @@@\n"
		.ascii	"@@@						 @@@\n"
		.asciiz	"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
		
quitScoresPrompt: .asciiz	"Press Q to Quit scores page >> "
thatsNotQ:		.asciiz	"\nThat's not Q! No other input is accepted\n"
		
scoresInput:	.space 10		
		


.text

tempScores:
	
	la $a0, allTempScores
	li $v0, 4
	syscall
	
quitScores:
	
	la $a0, quitScoresPrompt
	li $v0, 4
	syscall
	
takeScoresInput:
	
	la $a0, scoresInput
	la $a1,	2
	li $v0, 8
	syscall
	
	la $t0, scoresInput
	lb $t1, ($t0)
	beq $t1, 113, menu
	beq $t1, 81, menu
	
	la $a0, thatsNotQ
	li $v0, 4
	syscall
	
	j quitScores
	

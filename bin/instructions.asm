####	Under construction
.data

howToPlay:	.asciiz "\nHow to Play:\n\nEnter a word between 4 and 9 characters containing the letters in the box.\nThe word must contain the central letter in the box.\nYou may shuffle the box, but the center letter will stay the same.\nIf your word is valid, you will be awarded 10 points per letter.\nOne point is deducted per second of game play.\n\nHot Keys:\n\nto shuffle - S\nview entered words - D\nquit game - Q\n"

.text

####	Displays instructions when selected from menu
instructions:

	printStr(howToPlay)
	newlines(3)
	pressAnyKey

	b menu

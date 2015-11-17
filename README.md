### Lexathon
##Recreation of a popular Android game application using MIPS32 assembler language

Lexathon for MIPS


###########################################################################
#Authors:  

James Combs, Christopher Fox, Nic Powell


###########################################################################
##Description:

Lexathon is a word game that instructs users to find words from an array of
letters printed in a 3x3 box.  Words must be between 4 and 9 letters long
and must contain the central letter in the box.  The user may shuffle the
box, but the central letter will remain the same.  The game ends whenever
the user finds all words for a set of letters or decides to quit the game.
Scoring is based upon the length of the word found, 10 points per letter,
and the amount of time it takes to find the word, one point deduction per
second.


###########################################################################
##Requirements:

The game was written with MARS 4.5 and is recommended for gameplay.
The simulator can be downloaded from the following site:

http://courses.missouristate.edu/KenVollmar/MARS/

MARS is written in Java and requires at least Release 1.5 of the J2SE Java
Runtime Environment (JRE) to work.

The program has been tested on Windows and MAC platforms.


###########################################################################
##Installation and Configuration:

1.  Unzip Lexathon.zip to a desired location.

2.  Open MARS and open file "Lexathon.asm".  The following file paths will
need to be changed based upon the unzipped location.  

scores:		.asciiz	"/<file path>/Lexathon/bin/scores.txt"
dictionary:	.asciiz	"/<file path>/Lexathon/dictionary/dictionary.txt"
nineWord:	.asciiz	"/<file path>/Lexathon/dictionary/9.txt"

For MAC users, the ".include" paths will need to reflect the full path.
Windows users may keep the default locations.

MAC example:

.include	"/<file path>/Lexathon/bin/macros.asm"

Windows example:

.include	"/bin/macros.asm"

After making the required modifications, click save.

3.  Click assemble and press play.  The game main menu will appear.  Adjust
the console height to fit the height of the menu.  The game is now ready to
be played.


###########################################################################
##Features:

The game provides a pseudo graphical interface inside of the MARS console
and is built to support a console height of 18 lines.  Upon assembly/play,
the user will be brought to a menu where they have the option to choose
"New Game", "High Scores", "How to Play", and "Quit".  

"How to Play" provides the user instructions on how to play the game as
well as the hot keys that can be used during gameplay.  The user can exit
by pressing any key.

"High Scores" shows the user the top 10 scores currently on record.  The
user exits the high scores list by pressing any key.

When selecting "New Game", the program will begin to load a new game
instance, and give the user a 3 second countdown before displaying the
randomized 3x3 box.  Also displayed on the screen are the current time
played and score, initally set to 0, and also displays the available hot
keys, to allow the user to shuffle box, view valid words already entered,
and to quit the game.  After each time the user inputs a word, the elapsed
time and score are updated.

The scoring is calculated as followed:
For a correct word, 10 points per letter are awarded, minus the time taken
to find the word at a rate of -1 points per second.  This word is placed in
a running list of valid words entered, viewable by inputting "D" and
returns to the allow user input after 3 seconds.  For an incorrect word, no
word points are awarded, but the time taken to enter the word is deducted
at a rate of -1 points per second.  Negative scores are possible, but are
not allowed to be recorded in the high scores.

If the user attains a high score, a prompt will appear for the user to
input their name.  The score placement can be seen by selecting
"High Scores" from the menu after the game is finished.


###########################################################################
##Limitations:

MARS doesn't provide a GUI to be built, so a pseudo graphical text
interface was created to provde a small degree of cosmetic to the program.


###########################################################################
##Important Notes:

The imported .txt files should not be modified!  The files have a
particular format that accomodates both MAC and Windows systems and the
program is written accordingly.  Modifying the files could result in the
program erroring and raising exceptions.  To fix, overwrite the files with
the files from Lexathon.zip.

If "Loading" or "Clearing Arrays and Registers" screens appear to be hung,
exit/reload MARS and reopen Lexathon.asm.  This appears to be an occasional
problem with the simulator.

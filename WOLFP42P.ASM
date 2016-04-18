	TITLE: WolfProgram4
	PAGE 60, 132
;
;	** Guessing Game (2-player version) **
;	Player must guess a random number between 0 and 9 which
;	is selected by the dealer.
;	
;	If player guesses the number within 3 tries, they win a
;	differing amount of money based on how many guesses
;	it took. If they cannot guess the number within 3
;	tries, they lose. The player may play up to 9 rounds
;	per game and will receive a summary at the end of
;	the game.
;
;	Jay Wolf - April 19, 2016
;
;
;	Define constants
;
CR	EQU	0DH		; define carriage return
LF	EQU	0AH		; define line feed
EOT	EQU	'$'		; define end of text character
;
;	Define macros
;
WRITE	MACRO
	LEA	DX, #1
	MOV	AH, 09H
	INT	21H
	#EM
WRTDLR	MACRO
	MOV	DL,'$'
	MOV	AH,02H
	INT	21H
	#EM
READ	MACRO
	MOV	AH, 01H
	INT	21H
	#EM
EXIT	MACRO
	MOV	AX,4C00H
	INT	21H
	#EM
;
	JMP	START		; bypass variable definitions
;
;	Define variables
;
SUMMARY	DB	190 DUP ' '	; define output buffer
RULES	DB	CR,LF,"***********  Guessing Game  ***************************",CR,LF,LF
	DB	"  You get three chances to guess a number from 0-9.",CR,LF
	DB	"  Get it right on the 1st guess and win ",EOT
WN25	DB	"25.",CR,LF
	DB	"  Get it right on the 2nd guess and win ",EOT
WN10	DB	"10.",CR,LF
	DB	"  Get it right on the 3rd guess and win ",EOT
WN5	DB	"5.",CR,LF,LF
	DB	"  To play, simply type your guess.",CR,LF
	DB	"  There's no need to press [ENTER] after your number.",CR,LF,LF
	DB	"*******************************************************",EOT
GETNUM	DB	CR,LF,LF,"Dealer, enter the secret number: ",EOT
GETGUES	DB	CR,LF,LF,"Player, enter your guess: ",EOT
TOOHIGH	DB	CR,LF,"  Your guess was too high.",EOT
TOOLOW	DB	CR,LF,"  Your guess was too low.",EOT
WIN	DB	CR,LF,"  ** Correct! You won ",EOT
WIN25	DB	"25! **",CR,LF,EOT
WIN10	DB	"10! **",CR,LF,EOT
WIN5	DB	"5! **",CR,LF,EOT
LOSE	DB	CR,LF,LF,"You did not guess the number within 3 tries. Sorry, you didn't win.",CR,LF,EOT
NEWRND	DB	CR,LF,"Would you like to play again? (Y/N): ",EOT
HEADER	DB	CR,LF,LF,"** Game Summary ***",CR,LF
	DB	LF,"RND DN G1 G2 G3 WIN",CR,LF
	DB	"-------------------",CR,LF,EOT
;
;	Beginning of code
;
START:
	WRITE	RULES		; write the rules of the game
	WRTDLR
	WRITE	WN25
	WRTDLR
	WRITE	WN10
	WRTDLR
	WRITE	WN5
	LEA	DI,SUMMARY	; point to the summary buffer
	MOV	CH,1		; initialize the round counter

NRND:	MOV	CL,CH		; place round counter in placeholder
	ADD	CL,30H		; add ASCII bias
	MOV	[DI+1],CL	; write round number to summary buffer
	WRITE	GETNUM		; prompt for secret number from the dealer
	MOV	AH, 07H		; get number from dealer (no echo to screen)
	INT	21H
	MOV	[DI+5],AL	; write secret number to summary buffer

	WRITE	GETGUES		; prompt player for 1st guess
	READ			; get 1st guess
	MOV	[DI+8],AL	; write guess to summary buffer
	CMP	[DI+5],AL	; compare guess to secret number
	JE	W25		; guess correct, win $25
	JB	THIGH1		; guess too high
	JA	TLOW1		; guess too low
W25:	WRITE	WIN		; output win message
	WRTDLR			; output '$'
	WRITE	WIN25		; output dollar amount
	MOV	B[DI+11],'-'	; write null for G2 to summary buffer
	MOV	B[DI+14],'-'	; write null for G3 to summary buffer
	MOV	B[DI+17],'2'	; write 2 for win to summary buffer
	MOV	B[DI+18],'5'	; write 5 for win to summary buffer
	JMP	WRAPUP		; complete the round in the summary buffer
THIGH1: WRITE 	TOOHIGH		; output too high message
	JMP	G2		; jump to the 2nd guess
TLOW1:	WRITE 	TOOLOW		; output too low message
	JMP	G2		; jump to the 2nd guess

G2: 	WRITE	GETGUES		; prompt player for 2nd guess
	READ			; get 2nd guess
	MOV	[DI+11],AL	; write guess to sumary buffer
	CMP	[DI+5],AL	; compare guess to secret number
	JE	W10		; guess correct, win $10
	JB	THIGH2		; guess too high
	JA	TLOW2		; guess too low
W10:	WRITE 	WIN		; output win message
	WRTDLR			; output '$'
	WRITE	WIN10		; output dollar amount
	MOV	B[DI+14],'-'	; write null for G3 in summary buffer
	MOV	B[DI+17],'1'	; write 1 for win to summary buffer
	MOV	B[DI+18],'0'	; write 0 for win to summary buffer
	JMP	WRAPUP		; complete the round in the summary buffer
THIGH2: WRITE 	TOOHIGH		; output too high message
	JMP	G3		; jump to the 3rd guess
TLOW2:	WRITE 	TOOLOW		; output too low message
	JMP	G3		; jump to the 3rd guess

G3: 	WRITE	GETGUES		; prompt player for 3rd guess
	READ			; get 3rd guess
	MOV	[DI+14],AL	; write guess to summary buffer
	CMP	[DI+5],AL	; compare guess to secret number
	JE	W5		; guess correct, win $5
	JB	THIGH3		; guess too high
	JA	TLOW3		; guess too low
W5:	WRITE 	WIN		; output win message
	WRTDLR			; output '$'
	WRITE	WIN5		; output dollar amount
	MOV	B[DI+18],'5'	; write 5 for win to summary buffer
	JMP	WRAPUP		; complete the round in the summary buffer
THIGH3: WRITE 	TOOHIGH		; output too high message
	JMP	LOST		; lost game
TLOW3:	WRITE 	TOOLOW		; output too low message
	JMP	LOST		; lost game

LOST:	WRITE	LOSE		; output player lost message
	MOV	B[DI+18],'0'	; output 0 for win to summary buffer
	JMP	WRAPUP		; complete the round in the summary buffer

WRAPUP:	MOV	B[DI+19],CR	; add CR to end of round
	MOV	B[DI+20],LF	; add LF to end of round
	INC	CH		; increment round counter
	CMP	CH,9		; >=9 rounds played?
	JA	DONE		; max rounds played; output summary
	WRITE	NEWRND		; prompt player for another round
	READ			; get player response
	OR	AL, 20H		; convert upper-case letter to lower case if needed
	CMP	AL, 'y'		; look for 'y'
	JNE	DONE		; not 'y', don't play another round
	ADD	DI,21		; is 'y', move pointer to new round in summary buffer
	JMP	NRND		; play anouther round

DONE:	MOV	B[DI+21],EOT	; add EOT to output summary
	LEA	DI,SUMMARY	; point to the start of the summary buffer
	WRITE	HEADER		; output game summary header

W0:	CMP	B[DI], EOT	; check for end of buffer
	JNE	W1		; not end, stuff to output
	EXIT			; clean exit from program
W1:	MOV	DL, [DI]	; output character
	MOV	AH, 02H		
	INT	21H
	INC 	DI		; move to next character
	JMP	W0		; continue output
;
;
	END
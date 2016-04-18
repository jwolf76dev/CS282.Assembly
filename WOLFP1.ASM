	TITLE: WolfProgram1
	PAGE 60, 132
;
;	Takes a user's name and echos the name with a message, then
;	takes and displays a secret number with a message.
;
;	Jay Wolf - February 16, 2016
;
;
;	Define constants
;
CR	EQU	0DH			; define carriage return
LF	EQU	0AH			; define line feed
EOT	EQU	'$'			; define end of text character
;
;	Define variables
;
JMP	START				; bypass variable definitions
INBUF	DB	50,?,50 DUP ?		; define input buffer
MSG1	DB	CR,LF,"Hello! What is your name? ",EOT
MSG2	DB	CR,LF,"Welcome to assembly, ",EOT
MSG3	DB	CR,LF,"Enter a 1-digit secret number: ",EOT
MSG4	DB	CR,LF,"I can't keep a secret! Your secret number is ",EOT
DOT	DB	'.',CR,LF,EOT
;
;	Beginning of code
;
START:	LEA	DX, MSG1		; Ask for user's name
	MOV	AH, 09H
	INT	21H

	LEA 	DX, INBUF		; Get input from user
	MOV	AH, 0AH
	INT	21H
	
	LEA	SI, INBUF+2		; Point to input
	MOV	BL, [SI-1]		; Set BL to actual entered size
	MOV	BH, 0			; Reset BH to 0 (upper 8 of BX)
	MOV	B[BX+SI], EOT		; Add EOT to input string
	
	LEA 	DX, MSG2		; Write output message to screen
	MOV	AH,09H
	INT	21H
	
	MOV 	DX, SI			; Get stored user's name from SI
	MOV	AH, 09H			; and output to screen after MSG2
	INT	21H

	LEA	DX, DOT			; Output a period ('.') to screen
	MOV	AH, 09H			; after user's name
	INT	21H

	LEA	DX,MSG3			; Ask for a secret character
	MOV	AH,09H
	INT	21H

	MOV	AH, 08H			; Get character from user, no echo
	INT	21H			; to screen (auto stored in AL)

	MOV	BL, AL			; Save input from user
	INT	21H
	
	LEA 	DX, MSG4		; Write output message to screen
	MOV	AH,09H
	INT	21H

	MOV 	DL, BL			; Get secret number from BL and
	MOV	AH, 02H			; output to screen after MSG4
	INT	21H
	
	LEA	DX, DOT			; Output a period ('.') to screen
	MOV	AH, 09H			; after secret number
	INT	21H

	MOV	AX, 4C00H		; Clean exit from the program
	INT 	21H
	END

	TITLE: WolfProgram3
	PAGE 60, 132
;
;	Sorts a string of random characters using the
;	BubbleSort algorithm
;
;	Jay Wolf - March 24, 2016
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
READ	MACRO
	LEA	DX, #1
	MOV	AH, 0AH
	INT	21H
	#EM
EXIT	MACRO
	MOV	AX,4C00H
	INT	21H
	#EM
;
;	Define variables
;
JMP	START			; bypass variable definitions
INBUF	DB	100,?,100 DUP ?	; define input buffer
INMSG	DB	CR,LF,"Input a random sequence of 20 to 100 characters: ",CR,LF,EOT
OUTMSG1	DB	CR,LF,LF,"** UNSORTED **",CR,LF,EOT
OUTMSG2	DB	CR,LF,"** SORTED **",CR,LF,EOT
INERR	DB	CR,LF,LF,"** Input Error **",CR,LF,"Not enough characters entered.",CR,LF,"Exiting program.",CR,LF,EOT
		
SPACE	DB	' ',EOT
;
;	Beginning of code
;
START:
	WRITE	INMSG		; prompt user for input
	READ	INBUF		; get input from user
	LEA	DI, INBUF+2	; point to the start of input string
	MOV	BH, 0		; clear the base pointer
	MOV	BL, [DI-1]	; get the input character count
	
	CMP	BL, 20		; check for minimum number of characters
	JB	LTMIN		; input < 20: write error and exit
	
	MOV	B[BX + DI], EOT	; add end of text marker to string
	WRITE	OUTMSG1		; write unsorted output message
	CALL	WRTOUT		; output unsorted string with proper formatting

	CALL	BUBSORT		; sort string

	WRITE	OUTMSG2		; write sorted output message
	CALL	WRTOUT		; output sorted string with proper formatting
	EXIT			; clean exit

LTMIN:					
	WRITE	INERR		; write error message
	EXIT			; clean exit
;
;
;*** Subroutine BUBSORT ************************************
;
;	A subroutine to perform a BubbleSort on a string.
;	Sorts list largest to smallest.
;
;	Note: Does not perform error checking
;
;	ENTRY: sets DI; must have at least 2 characters stored in input buffer
;	EXIT:  DI pointer reset to start of data
;
BUBSORT:
	LEA	DI, INBUF+2	; set pointer to front of string
	MOV	CL, 0		; set swap counter = 0
COMPR:	MOV	DL, [DI]	; copy [byte] to register
	CMP	DL, [DI+1]	; [byte] > [byte+1]
	JAE	NOSWAP		; no swap needed

	MOV	DH, [DI+1]	; swap bytes; copy [byte+1] to register
	MOV	[DI], DH	; [byte] = [byte+1]
	MOV	[DI+1], DL	; [byte+1] = [byte]
	INC	CL		; inc swap counter

NOSWAP:	INC	DI		; ++pointer
	CMP	B[DI+1], EOT	; [byte+1] = EOT?
	JNE	COMPR		; not at last character; keep comparing

	CMP	CL, 0		; at EOT; is swap counter = 0?
	JNE	BUBSORT		; swaps were made; make another pass

	LEA	DI, INBUF+2	; no swaps made; reset pointer to start of data
	RET			; return to caller

;
;***********************************************************
;
;*** Subroutine WRTOUT *************************************
;
;	A subroutine to format the output of the characters
;	in a string with a specified number of characters
;	per line, each separated by a space.
;
;	Note: Does not perform error checking
;
;	ENTRY: Data pointed to in the DI register
;	EXIT:  Pointer reset to start of string in DI
;
WRTOUT:
	MOV	CH, 0		; clear the counter
	MOV	CL, 20		; set characters-per-line counter

W0:	CMP	B[DI], EOT	; look for EOT
	JNE	W1		; not at EOT: more to output

	MOV	DL, CR		; at EOT: nothing more to output
	INT	21H		; add a new line
	MOV	DL, LF		; 
	INT	21H		;
	LEA	DI, INBUF+2	; reset pointer to start of input data
	RET			; return to caller

W1: 	MOV	DL, [DI]	; write character
	MOV	AH, 02H
	INT	21H
	
	MOV	DL, SPACE	; write space
	MOV	AH, 02H
	INT	21H

	INC	DI		; increment string pointer to next character
	DEC	CL		; decrement characters-per-line counter
	JNZ	W0		; if not at character-per-line limit, repeat

	MOV	DL, CR		; at char-per-line limit: start new line
	INT	21H
	MOV	DL, LF
	INT	21H

	JMP	WRTOUT		; back to start of subroutine
;
;***********************************************************
;
	END

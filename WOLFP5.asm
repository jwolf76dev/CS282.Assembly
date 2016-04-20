	TITLE: WolfProgram5
	PAGE 60, 132
;
;	** Cheap Calculator **
;	Simple 4-function calculator wihch will perform addition,
;	subtraction, multiplication, and division of 2 unsigned values
;	less than or equal to 255 each. The user enters a simple equation
;	in the form operand operator operand, and the program will
;	evaluate it then output the result in ASCII characters.
;
;	Jay Wolf - May 10, 2016
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
	LEA	DX,#1
	MOV	AH,09H
	INT	21H
	#EM
READ	MACRO
	LEA	DX,#1
	MOV	AH,0AH
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
SPACE	DB	' ',EOT
INBUF	DB	10,?,10 DUP ? 	; define input buffer
ANUM1	DB	4 DUP 0		; ASCII version of 1st number
ANUM2	DB	4 DUP 0		; ASCII version of 2nd number
BNUM1	DB	0		; Binary version of 1st number
BNUM2	DB	0		; Binary version of 2nd number
OP	DB	0		; operator
REAULT	DB	0		; output
HEADER	DB	CR,LF,"**********  Cheap Calculator  **********",CR,LF,LF
	DB	
START:
	WRITE	HEADER		; write rules & prompt user for equation
	READ	INBUF		; read input from user
	LEA	DI,INBUF	; point to the input buffer
	MOV	CL,0		; initialize character counter to 0
	
















































	MOV	CL,1		; initialize counter to 1
	READ	INBUF		; get equation from the user
	LEA	SI,INBUF	; point to beginning of the equation
FINDN1:	
	CMP	SI,SPACE	; compare if current byte is a space
	JE	FOUNDIT		; if space, jump to getting number
	INC 	CL		; increment character counter
	INC	SI		; increment pointer to next character
FOUNDIT:
	MOV BX, SI		; save location of pointer
	LEA DI, NUM1+2		; point to the last character space in NUM1
F1:	
	DEC	SI		; move input pointer to previous character
	MOV 	AL,[SI]		; copy character from input (register) to memory
	MOV	[DI],AL		; copy memory to register (actual value)
	DEC 	DI		; move variable pointer down to next value
	DEC 	CL		; decrement character counter
	JNZ	F1		; if not 0, read in more characters
	LEA	SI, BX		; reload pointer to data
	WRITE	NUM1
FINDOP:
	INC SI			; increment pointer to find operator
	CMP	SI, SPACE	; see if space
	JE	FINDOP		; increment until we find not a space
	MOV	OP, SI		; move byte to OP, should it be [SI]?
	WRITE	OP		
FINDN2:
	INC SI			; increment pointer to find number
	CMP SI, SPACE		; see if space
	JE	FINDN2		; if equal, increment again
	MOV	CL, 1		; reset character counter
FINDEND:
	CMP	SI, CR		; see if pointer is at carriage return
	JE	FOUNDN2		; if equal, jump to evaluating 2nd number
	INC CL			; increment counter
	INC SI			; increment pointer
FOUNDN2:
	MOV BX, SI		; save current position of buffer
	LEA	DI, NUM2+2 	; point to last character in NUM2
F2:
	DEC	SI		; move input pointer to previous character
	MOV	AL, [SI]	; save input pointer from register to memory
	MOV	[DI], AL	; move pointer from memory to register
	DEC	DI		; move variable pointer down to next value
	DEC	CL		; decrement character counter
	JNZ	F2		; if not 0, read in more characters
	LEA	SI, BX		; once finished, point back to end

	WRITE NUM2
	EXIT
	END
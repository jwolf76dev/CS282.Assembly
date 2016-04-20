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
SPACE	EQU	' '		; define space
;
;	Define macros
;
WRITE	MACRO
	LEA	DX,#1
	MOV	AH,09H
	INT	21H
	#EM
WRITEC	MACRO
	MOV	DL,#1
	MOV	AH,02H
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
INBUF	DB	10,?,10 DUP ? 	; define input buffer
ANUM1	DB	4 DUP 0		; ASCII version of 1st number
ANUM2	DB	4 DUP 0		; ASCII version of 2nd number
BNUM1	DB	4 DUP 0		; Binary version of 1st number
BNUM2	DB	4 DUP 0		; Binary version of 2nd number
OP	DB	0		; operator
RESULT	DB	0		; Binary result
ANSWER	DB	0		; ASCII result
HEADER	DB	CR,LF,"**********  Cheap Calculator  **********",CR,LF,LF
	DB	"Enter your equation: ",EOT
;
;	Testing Variables
;
AN1HDR	DB	CR,LF,"ANUM1: ",EOT
OPHDR	DB	CR,LF,"   OP: ",EOT
AN2HDR	DB	CR,LF,"ANUM2: ",EOT	
BN1HDR	DB	CR,LF,"BNUM1: ",EOT
BN2HDR	DB	CR,LF,"BNUM2: ",EOT	
;
START:
	WRITE	HEADER		; write rules & prompt user for equation
	READ	INBUF		; read input from user
;
; build 1st ASCII number
	LEA	DI,INBUF+2	; point to the user's input
	MOV	CL,0		; initialize character counter to 0
EON1:	
	MOV	AL,B[DI]	
	CMP	B[DI],SPACE	; @ space?
	JE	BUILDN1		; found end of NUM1
	INC	DI		; not end, increment pointer
	INC	CL		; increment character counter
	JMP	EON1		; repeat
BUILDN1:	
	MOV	BX,DI		; save pointer location
	LEA	SI,ANUM1+3	; point to last character in NUM1
	MOV	B[SI],EOT	; add EOT to ASCII number
BN1:	DEC	SI		; decrement NUM1 pointer
	DEC	DI		; decrement INBUF pointer
	DEC	CL		; decrement character counter
	MOV	AL,B[DI]	; move 1's digit from INBUF to NUM1
	MOV	B[SI],AL	;
	CMP	CL,0		; any more characters to add?
	JNE	BN1		; add another digit
;
; no more digits to add; save operator
	LEA	DI,BX		; reset input pointer to 1st SPACE in input
	INC	DI		; increment INBUF pointer
	MOV	AL,B[DI]	; save character as operator
	MOV	OP,AL		;
;
; build 2nd ASCII number	
	ADD	DI,2		; increment INBUF pointer 2x
	MOV	CL,0		; reset character count to 0
EON2:	
	CMP	B[DI],CR	; @ CR?
	JE	BUILDN2		; found end of NUM2
	INC	DI		; not end, increment pointer
	INC	CL		; increment character counter
	JMP	EON2		; repeat
BUILDN2:	
	MOV	BX,DI		; save pointer location	
	LEA	SI,ANUM2+3	; point to last character in NUM2
	MOV	B[SI],EOT	; add EOT to ASCII number
BN2:	DEC	SI		; decrement NUM2 pointer
	DEC	DI		; decrement INBUF pointer
	DEC	CL		; decrement character counter
	MOV	AL,B[DI]	; move 1's digit from INBUF to NUM2
	MOV	B[SI],AL	;
	CMP	CL,0		; any more characters to add?
	JNE	BN2		; add another digit
;
; no more digits to add
	LEA	DI,BX		; reset input pointer to end of INBUF
;
; write values to screen
	WRITE	AN1HDR
	WRITE	ANUM1
	WRITE	OPHDR
	WRITEC	OP
	WRITE	AN2HDR
	WRITE	ANUM2
;
; convert values to binary
	LEA	SI,ANUM1	; point to ANUM1
	CALL	A2B8		; convert ANUM1 to binary
	MOV	BNUM1,AL	; save result as BNUM1

	LEA	SI,ANUM2	; point to ANUM2
	CALL	A2B8		; convert ANUM2 to binary
	MOV	BNUM2,AL	; save result as BNUM2
;
; write values to screen
	WRITE	BN1HDR
	LEA	SI,BNUM1	; point to BNUM1
	MOV	B[SI+3],EOT	; add EOT to last byte of BNUM1
CHAR1:
	CMP	B[SI],EOT
	JE	C2
	WRITEC	B[SI]
	INC	SI
	JMP	CHAR1
	
C2:	WRITE	BN2HDR
	LEA	SI,BNUM2	; point to BNUM2
	MOV	B[SI+3],EOT	; add EOT to last byte of BNUM2
CHAR2:
	CMP	B[SI],EOT
	JE	ALLDONE
	WRITEC	B[SI]
	INC	SI
	JMP	CHAR2
;
ALLDONE:	EXIT		; clean exit
;
;*** Subroutine A2B8 ***************************************
;
;	A subroutine to convert a 3-digit ASCII value to
;	its corresponding Binary value
;
;	Note: Does not perform error checking
;
;	ENTRY: SI points to value; CH used as character counter
;	       BX will be used to build binary number
;	EXIT:  AL holds binary value
;
A2B8:
	ADD	SI,2		; point to 1's place
	SUB	B[SI],30H	; remove ASCII bias
	MOV	BH,B[SI]	; add 1's value to result
	DEC	SI		; decrement pointer to 10's byte
	CMP	B[SI],0		; is character NULL? (0H)
	JE	DONE		; no more characters to convert

	MOV	BL,B[SI]	; get 10's byte
	SUB	BL,30H		; remove ASCII bias
	MOV	AL,10		; multiply by 10
	MUL	BL		;
	ADD	BH,AL		; add 10's value to result
	DEC	SI		; decrement pointer to 100's byte
	CMP	B[SI],0		; is character NULL? (0H)
	JE	DONE		; no more characters to convert

	MOV	BL,B[SI]	; get 100's byte
	SUB	BL,30H		; remove ASCII bias
	MOV	AL,100		; multiply by 100
	MUL	BL		;
	ADD	BH,AL		; add 100's value to result
DONE:	MOV	AL,BH		; move result to output register
	RET			; return to caller
;
;***********************************************************
;
	END			; end of program

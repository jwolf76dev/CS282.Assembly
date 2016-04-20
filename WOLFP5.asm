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
BNUM1	DB	0		; Binary version of 1st number
BNUM2	DB	0		; Binary version of 2nd number
OP	DB	2 DUP 0		; operator
RESULT	DB	0		; output
HEADER	DB	CR,LF,"**********  Cheap Calculator  **********",CR,LF,LF
	DB	"Enter your equation: ",EOT
;
;	Testing Variables
;
N1HDR	DB	CR,LF,"ANUM1: ",EOT
OPHDR	DB	CR,LF,"   OP: ",EOT
N2HDR:	DB	CR,LF,"ANUM2: ",EOT	
;
START:
	WRITE	HEADER		; write rules & prompt user for equation
	READ	INBUF		; read input from user
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
; no more digits to add, save operator
	LEA	SI,OP+1
	MOV	B[SI],EOT
	DEC	SI
	LEA	DI,BX		; reset input pointer to 1st SPACE in input
	INC	DI		; increment INBUF pointer
	MOV	AL,B[DI]	; save character as operator
	MOV	B[SI],AL	;
	INC	DI		; increment INBUF pointer 2x
	INC	DI
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
; output saved variables
	WRITE	N1HDR
	WRITE	ANUM1
	WRITE	OPHDR
	WRITE	OP
	WRITE	N2HDR
	WRITE	ANUM2

	EXIT
;
	END

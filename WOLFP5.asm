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
RESULT	DW	0		; Binary result
BQUO	DB	0		; Binary quotent for division
BREM	DB	0		; BInary remainder for division
ANSWER	DB	7 DUP 0		; ASCII result for result
REMAIN	DB	6 DUP 0		; ASCII result for division remainder
HEADER	DB	CR,LF,"**********  Cheap Calculator  **********",CR,LF,LF
	DB	"Enter your equation: ",EOT
BADOP	DB	CR,LF,"Invalid operand.",CR,LF,EOT
DIVREM	DB	" r ",EOT
;
;	Testing Variables
;
AN1HDR	DB	CR,LF,"    ANUM1: ",EOT
OPHDR	DB	CR,LF,"       OP: ",EOT
AN2HDR	DB	CR,LF,"    ANUM2: ",EOT	
BN1HDR	DB	CR,LF,"    BNUM1: ",EOT
BN2HDR	DB	CR,LF,"    BNUM2: ",EOT
BRESULT	DB	CR,LF,"   RESULT: ",EOT
ARESULT	DB	CR,LF,"   ANSWER: ",EOT
ALEQU	DB	CR,LF,"	      AL: ",EOT
AHEQU	DB	CR,LF,"	      AH: ",EOT
BQUOHDR	DB	CR,LF,"  QUOTENT: ",EOT
BREMHDR	DB	CR,LF,"REMAINDER: ",EOT
;
START:
	WRITE	HEADER		; write rules & prompt user for equation
	READ	INBUF		; read input from user
;
; build 1st ASCII number
	LEA	DI,INBUF+2	; point to the user's input
	MOV	CL,0		; initialize character counter to 0
EON1:	
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
	MOV	BL,BNUM1
	CALL	DUMP8
	WRITE	BN2HDR
	MOV	BL,BNUM2
	CALL 	DUMP8
;
; preload registers with operands
	MOV	AL,BNUM1	; move 1st operand to register
	MOV	AH,BNUM2	; move 2nd operand to register
	LEA	SI,ANSWER	; point to ASCII answer
;
; process equation based on operand
	CMP	[OP],'+'	; look for add
	JNE	SUB?		; not add, look for subtraction
	CALL	ADDTHEM		; add operands
	MOV	RESULT,AX	; save binary result
	JMP	OUTPUT		; output result
SUB?:	CMP	[OP], '-'	; look for subtract
	JNE	MUL?		; not subtract, look for multiply
	CALL	SUBTHEM		; subtract operands
	MOV	RESULT,AX	; save binary result
	JMP	OUTPUT		; output result
MUL?:	CMP	[OP],'*'	; look for multiply
	JNE	DIV?		; not multiply, look for divide
	CALL	MULTHEM		; multiply operands
	MOV	RESULT,AX	; save binary result
	JMP	OUTPUT		; write result
DIV?:	CMP	[OP],'/'	; look for divide
	JNE	BAD		; not divide, must be bad operator
	CALL	DIVTHEM		; divide operands
	MOV	BQUO,AL		; save binary quotent
	MOV	BREM,AH		; save binary remainder
	JMP	OUTDIV		; output result
BAD:	WRITE	BADOP		; write operator error message
	EXIT			; clean exit
;
; output result
OUTPUT:
	WRITE	BRESULT
	MOV	BX,RESULT
	CALL	DUMP16
	
	WRITE	ARESULT
	MOV	AX,RESULT
	CALL	B2A16
	WRITE	ANSWER
	JMP	ALLDONE

OUTDIV:
	WRITE	BQUOHDR
	MOV	BL,BQUO
	CALL	DUMP8
	
	WRITE	BREMHDR
	MOV	BL,BREM
	CALL	DUMP8

	WRITE	ARESULT
	MOV	AL,BQUO
	MOV	AH,0
	CALL	B2A16
	WRITE	ANSWER

	LEA	SI,REMAIN
	WRITE	DIVREM
	MOV	AL,BREM
	MOV	AH,0
	CALL	B2A16
	WRITE	REMAIN
	
ALLDONE:
	EXIT			; clean exit
;
;*** Subroutine A2B8 ****************************************
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
;************************************************************
;
;*** Subroutine B2A16 ****************************************
;
;	A subroutine to convert a 16-bit binary number to
;	its corresponding ASCII value
;
;	Note: Does not perform error checking
;
;	ENTRY:	AX holds 16-bit value to convert
;		SI points to ASCII save buffer
;	EXIT:	none
;	USED:	CX as a counter; DX for division operations
;
B2A16:
	MOV	DX,0		; reset remainder to 0
	MOV	BX,10000	; load 10000 into denominator
	DIV	BX		; divide AX by BX
	ADD	AX,3030H	; add ASCII bias to result
	MOV	[SI],AL		; save result in 1st char of answer

	MOV	AX,DX		; load remainder into numerator
	MOV	DX,0		; reset remainder to 0
	MOV	BX,1000		; load 1000 into denominator
	DIV	BX		; divide AX by BX
	ADD	AX,3030H	; add ASCII bias to result
	MOV	[SI+1],AL	; save result in 2nd char of answer

	MOV	AX,DX		; load remainder into numerator
	MOV	DX,0		; reset remainder to 0
	MOV	BX,100		; load 100 into denominator
	DIV	BX		; divide AX by BX
	ADD	AX,3030H	; add ASCII bias to result
	MOV	[SI+2],AL	; save result in 3rd char of answer

	MOV	AX,DX		; load remiander into numerator
	MOV	DX,0		; reset remainder to 0
	MOV	BX,10		; load 10 into denominator
	DIV	BX		; divide AX by BX
	ADD	AX,3030H	; add ASCII bias to result
	MOV	[SI+3],AL	; save result in 4th char of answer

	ADD	DX,3030H	; add ASCII bias to remainder
	MOV	[SI+4],DL	; save result in 5th char of answer

	ADD	B[SI+5],EOT	; add EOT to ASCII string
	RET			; return to caller
;
;************************************************************
;
;*** Subroutine ADDTHEM *************************************
;
;	A subroutine to add 2 8-bit binary numbers
;
;	Note: Does not perform error checking
;
;	ENTRY: AL holds first number; AH holds 2nd number;
;	       SI points to ASCII output buffer
;	EXIT:  AX holds binary result
;
ADDTHEM:
	ADD	AL,AH		; result stored in AL
	MOV	AH,0		; reset upper 8-bits of AX register to 0
	ADC	AH,0		; move carry bit into upper 8-bits of AX
	RET			; return to caller
;
;************************************************************
;
;*** Subroutine SUBTHEM *************************************
;
;	A subroutine to subtract 2 8-bit binary numbers
;
;	Note: Does not perform error checking
;
;	ENTRY: AL holds first number; AH holds 2nd number;
;	       SI points to ASCII output buffer
;	EXIT:  AX holds binary result
;
SUBTHEM:
	SUB	AL,AH		; result stored in AX
	MOV	AH,0		; reset upper 8 bits of AX to 0
	JNC	POSNUM		; result is a positive number
	NEG	AL		; negate result (2's complement)
	MOV	B[SI],'-'	; add '-' to output
	INC	SI		; increment answer pointer
POSNUM:	RET			; return to caller
;
;************************************************************
;
;*** Subroutine MULTHEM *************************************
;
;	A subroutine to multiply 2 8-bit binary numbers
;
;	Note: Does not perform error checking
;
;	ENTRY: AL holds first number; AH holds 2nd number;
;	       SI points to ASCII output buffer
;	EXIT:  AX holds binary result
;
MULTHEM:
	MUL	AH		; result stored in AX
	RET			; return to caller
;
;************************************************************
;
;*** Subroutine DIVTHEM *************************************
;
;	A subroutine to divide 2 8-bit binary numbers
;
;	Note: Does not perform error checking
;
;	ENTRY:	AL holds numerator; AH holds denominator;
;		SI points to ASCII output buffer
;	EXIT:	AL holds binary quotient; AH holds binary remainder
;	USED:	BL for working register
;
DIVTHEM:
	MOV	BL,AH		; move denominator to working register
	MOV	AH,0		; reset AH
	DIV	BL		; result stored in AX
	RET			; return to caller
;
;************************************************************
;
;*** Subroutine DUMP8 ***************************************
;
;	A subroutine to output the 8-bit binary equivalent of a
;	value in memory
;
;	Note: Does not perform error checking
;
;	ENTRY:	BL holds binary value to output
;	EXIT:	BL destroyed
;	USED:	AX and DL for output; CX for loop counters
;
DUMP8:
	MOV	CH,2		; set group counter
GROUP8:	
	MOV	CL,4		; set bit counter
PROBIT8:	
	SHL	BL,1		; shift bits left by 1
	JC	P1_8		; bit shifted out = 1, jump to P1
	MOV	DL,'0'		; bit shifted out = 0, print it
	MOV	AH,02H		;
	INT	21H
	DEC	CL		; decrement bit counter
	JNZ	PROBIT8		; more bits to print, process next bit
	JZ	BREAK8		; 4 bits printed, add space
P1_8:	
	MOV	DL,'1'		; print '1'
	MOV	AH,02H		;
	INT	21H		;
	DEC	CL		; decrement bit counter
	JNZ	PROBIT8		; more bits to print; process next bit
BREAK8:	
	MOV	DL,' '		; print space
	MOV	AH,02H
	INT	21H
	DEC	CH		; decrement group counter
	JNZ	GROUP8		; more bits to output
	RET			; return to caller
;
;***********************************************************
;
;*** Subroutine DUMP16 *************************************
;
;	A subroutine to output the 16-bit binary equivalent of a
;	value in memory in 4-bit groups for ease of reading
;
;	Note: Does not perform error checking
;
;	ENTRY:	BX holds binary value to output
;	EXIT: 	BX destroyed
;	USED:	AX and DL for output; CX for loop counters
;
DUMP16:
	MOV	CH,4		; set group counter
GROUP16:
	MOV	CL,4		; set bit counter
PROBIT16:
	SHL	BX,1		; shift bits left by 1
	JC	P1_16		; bit shifted out = 1, jump to P1
	MOV	DL,'0'		; bit shifted out = 0, print it
	MOV	AH,02H
	INT	21H
	DEC	CL		; decrement bit counter
	JNZ	PROBIT16	; more bits to print, process next bit
	JZ	BREAK16		; 4 bits printed, add space
P1_16:
	MOV	DL,'1'		; print '1'
	MOV	AH,02H
	INT	21H
	DEC	CL		; decrement bit counter
	JNZ	PROBIT16	; more bits to print, process next bit
BREAK16:
	MOV	DL,' '		; print space
	MOV	AH,02H
	INT	21H
	DEC	CH		; decrement group counter
	JNZ	GROUP16		; more bits to output
	RET			; return to caller
;
;***********************************************************
;
	END			; end of program

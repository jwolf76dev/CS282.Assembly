	TITLE: WolfProgram2
	PAGE 60, 132
;
;	Retrieves the system clock, converts to ASCII, and
;	displays HH:mm:ss dd/mm/yyyy to the screen.
;
;	Jay Wolf - March 8, 2016
;
;
;	Define constants
;
CR	EQU	0DH		; define carriage return
LF	EQU	0AH		; define line feed
EOT	EQU	'$'		; define end of text character
WRITE	MACRO
	LEA	DX,#1
	MOV	AH,09H
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
OUTTIME	DB	2 DUP ?,':',2 DUP ?,':',2 DUP ?,EOT
OUTDATE	DB	2 DUP ?,'/',2 DUP ?,'/',4 DUP ?,EOT
MSG1	DB	CR,LF,"The date is ",EOT
MSG2	DB	CR,LF,"The time is ",EOT
DOT		DB	'.',EOT
;
;	Beginning of code
;
START:
	WRITE	MSG1		; output date prompt
	LEA	DI,OUTDATE	; point to formatted string
				; for date output
	CALL	CONDATE		; subroutine to process date
	WRITE	OUTDATE		; output formatted date string
	WRITE	DOT
	WRITE	MSG2		; output time prompt
	LEA	DI,OUTTIME	; point to formatted string
				; for time output
	CALL	CONTIME		; subroutine to process time
	WRITE	OUTTIME		; output formatted time string
	WRITE	DOT
	EXIT			; clean exit from program
;
;
;*** Subroutine CONTIME ************************************
;
;	A subroutine to read the time from the real time clock
;	and convert it to ASCII.
;
;	Note: Does not perform error checking
;
;	ENTRY: Read Real Time Clock function is moved into the
;	       AH register
;	EXIT:  Output pointed to in the DI register
;
CONTIME:
	MOV	AH,02H		; Read the RTC time
	INT	1AH
	MOV 	AL, CH		; move hours to AL
	CALL 	BCDASC		; convert hours to ASCII
	ADD	DI,3		; move output pointer fwd 3 bytes
	MOV	AL,CL		; move minutes to AL
	CALL 	BCDASC		; convert minutes to ASCII
	ADD 	DI,3		; move output pointer fwd 3 bytes
	MOV	AL,DH		; move seconds to AL
	CALL 	BCDASC		; convert seconds to ASCII
	RET			; return to caller
;
;***********************************************************
;
;*** Subroutine CONDATE ************************************
;
;	A subroutine to read date from the real time clock
;	and convert it to ASCII.
;
;	Note: Does not perform error checking
;
;	ENTRY: Read Real Time Clock function is moved into the
;	       AH register
;	EXIT:  Output pointed to in the DI register
;
CONDATE:
	MOV	AH,04H		; Read the RTC date
	INT	1AH
	MOV 	AL, DH		; move month to AL
	CALL 	BCDASC		; convert month to ASCII
	ADD	DI,3		; move output pointer fwd 3 bytes
	MOV	AL,DL		; move day to AL
	CALL 	BCDASC		; convert day to ASCII
	ADD 	DI,3		; move output pointer fwd 3 bytes
	MOV	AL,CH		; move century to AL
	CALL 	BCDASC		; convert century to ASCII
	ADD	DI,2		; move output pointer fwd 2 bytes
	MOV	AL,CL		; move year to AL
	CALL 	BCDASC		; convert year to ASCII
	RET			; return to caller
;
;***********************************************************
;
;*** Subroutine BCDASC *************************************
;
;	A subroutine to convert a 2-digit Binary Coded
;	Decimal value to ASCII value
;
;	Note: Does not perform error checking
;
;	ENTRY: AL holds BCD value of characters to be converted
;	EXIT:  Output pointed to in the SI register
;
BCDASC:
	MOV	TMP,AL		; save BCD byte
	SHR	AL,4		; shift higher 4 bits to lower 4 bits
	OR	AL,30H		; convert to ASCII
	MOV	[DI],AL		; save ASCII value
	MOV	AL,TMP		; get the original BCD date
	AND	AL,0FH		; mask lower 4 bits
	OR	AL,30H		; convert to ASCII
	MOV	[DI+1],AL 	; save ASCII value
	RET			; return to caller
TMP	DB	0		; initialize temp placeholder
;
;***********************************************************
;
	END			; end of program
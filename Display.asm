; This function sends the message pointed to by AXreg to the display.
; The full line is displayed, 12 or 16 characters depending on the 
; display type. The display line must be selected before this call 
; is made.
LCDsendAX
		MOVLW	LINE1
		CALL	LCDsendCMD
		MOVFF	AXreg,TBLPTRL
		MOVFF	AXreg+1,TBLPTRH
		CLRF	TBLPTRU,A
		CALL    LCDsendMess
		RETURN

; This function sends the message pointed to by AXreg line 2 of the display.
; The full line is displayed, 12 or 16 characters depending on the 
; display type.
LCDsendAXLine2
		MOVLW	LINE2
		CALL	LCDsendCMD
		MOVFF	AXreg,TBLPTRL
		MOVFF	AXreg+1,TBLPTRH
		CLRF	TBLPTRU,A
		CALL    LCDsendMess
		RETURN

; This function sends the message pointed to by DXreg line 2 of the display.
; The full line is displayed, 12 or 16 characters depending on the 
; display type.
LCDsendDXLine2
		MOVLW	LINE2
		CALL	LCDsendCMD
		MOVFF	DXreg,TBLPTRL
		MOVFF	DXreg+1,TBLPTRH
		CLRF	TBLPTRU,A
		CALL    LCDsendMess
		RETURN

ifdef	MicroProStar
; This function displays the second line of the LCD display. Both lines
; are saved in the display memory.
LCDshowLine2
	; If its already active, exit
		MOVFF	ActiveDisplayLine,WREG
		XORLW	2
		BTFSC	ALUSTA,Z
		RETURN
	; Set to line 2
		MOVLW	0x02
		CALL	LCDsendCMD
		MOVLW	0x18
		CALL	LCDsendCMD
		MOVLW	0x18
		CALL	LCDsendCMD
		MOVLW	0x18
		CALL	LCDsendCMD
		MOVLW	0x18
		CALL	LCDsendCMD
		MOVLW	0x18
		CALL	LCDsendCMD
		MOVLW	0x18
		CALL	LCDsendCMD
		MOVLW	0x18
		CALL	LCDsendCMD
		MOVLW	0x18
		CALL	LCDsendCMD
	; Set active display line flag to 2
		MOVLW	2
		MOVFF	WREG,ActiveDisplayLine
		RETURN
		
; This function resets the display pointer to the first line of the display.
LCDshowLine1
	; If its already active, exit
		MOVFF	ActiveDisplayLine,WREG
		XORLW	1
		BTFSC	ALUSTA,Z
		RETURN
	; Set to line 1
		MOVLW	0x02
		CALL	LCDsendCMD
	; Set active display line flag to 1
		MOVLW	1
		MOVFF	WREG,ActiveDisplayLine
		RETURN

; This function will send a message to the LCD display. This function sends
; the number of characters defined in WREG.
; The table pointers must point to the message in FLASH when this function
; is called.
; This function uses
;		WREG
;		Areg
;		Table pointers
LCDsendMess
		MOVLW	10
		GOTO	LCDsendMessN		
LCDsendMessN
		MOVWF	Areg,A
NEXT
		TBLRD*+
		MOVFF	TABLAT,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		RETURN
		CALL	LCDsendData
	; Send until end of count
NextChar
		DCFSNZ	Areg,F,A
		RETURN
		GOTO	NEXT
else
; This function will send a message to the LCD display. This function sends
; the entire line, 16 characters or 12 characters depending on the display 
; type.
; The table pointers must point to the message in FLASH when this function
; is called.
; This function uses
;		WREG
;		Areg
;		Table pointers
LCDsendMess
ifdef   ECMA1010display
		MOVLW	0C
else
		MOVLW	10
endif
		GOTO	LCDsendMessN
		
; This function will send a message to the LCD display. This function sends
; the number of characters defined in WREG.
; The table pointers must point to the message in FLASH when this function
; is called.
; This function uses
;		WREG
;		Areg
;		Table pointers
LCDsendMessN
		MOVWF	Areg,A
NEXT
		TBLRD*+
		MOVFF	TABLAT,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		RETURN
		CALL	LCDsendData
		DCFSNZ	Areg,F,A
		RETURN
		GOTO	NEXT
endif

; The function displays the value in the WREG on the display in
; binary format (1s and 0s). This value is displayed at the 
; current cursor location.
; Areg and Breg are used by this routine.
LCDbinary
		MOVWF	Areg
		MOVLW	D'8'
		MOVWF	Breg
LCDbinary0
		MOVLW	30
		BTFSC	Areg,7
		MOVLW	31
		CALL	LCDsendData
		RLCF	Areg
		DECFSZ	Breg
		GOTO	LCDbinary0
		RETURN

; The function displays the value in the WREG on the display in
; hex format. This value is displayed at the 
; current cursor location.
; Areg and Breg are used by this routine.
LCDhex
		MOVWF	Areg
		MOVLW	3A
		MOVWF	Breg
	; MS dibble
		MOVPF	Areg,WREG
		ANDLW	0F0
		RRNCF	WREG
		RRNCF	WREG
		RRNCF	WREG
		RRNCF	WREG
		IORLW	030
		CPFSGT	Breg
		ADDLW	7
		CALL	LCDsendData
	; LS dibble
		MOVPF	Areg,WREG
		ANDLW	0F
		IORLW	030
		CPFSGT	Breg
		ADDLW	7
		CALL	LCDsendData
		MOVPF	Areg,WREG
		RETURN

; This function prints the sign of the value in CEXreg 
; and then returns with the absolute value in CEXreg. Only
; the 16 LSBs of CEXreg are used.
LCDsign
	; Set the 2 MS bytes to 0
		MOVLW	0
		MOVFF	WREG,CEXreg+2
		MOVFF	WREG,CEXreg+3
	; Test the sign of CEXreg, assume its a 16 bit reg
		MOVLB	HIGH CEXreg
		MOVLW	' '
		BTFSC	CEXreg+1,7
		MOVLW	'-'
		CALL	LCDsendData
	; If negative then perform 2s complement
		MOVLB	HIGH CEXreg
		BTFSS	CEXreg+1,7
		RETURN
	; Here if negative
		COMF	CEXreg
		COMF	CEXreg+1
		INCF	CEXreg
		BTFSC	ALUSTA,Z
		INCF	CEXreg+1
		RETURN
		

;
; This function prints the unsigned integer that is in 
; CEXreg to the LCD at its current position. There are 
; a number of entry points into this function:
;
; LCDint	prints 5 characters
; LCDint4	prints 4 characters
; LCDint3	prints 3 characters
; LCDint2	prints 2 characters
; LCDint1	prints 1 characters
;
LCDint
		CALL	Int2Str
		MOVFP	Buffer,WREG
		CALL	LCDsendData
LCDintA
		MOVFP	Buffer+1,WREG
		CALL	LCDsendData
LCDintB
		MOVFP	Buffer+2,WREG
		CALL	LCDsendData
LCDintC
		MOVFP	Buffer+3,WREG
		CALL	LCDsendData
LCDintD
		MOVFP	Buffer+4,WREG
		CALL	LCDsendData
		RETURN
LCDint4
		CALL	Int2Str
		GOTO	LCDintA
LCDint3
		CALL	Int2Str
		GOTO	LCDintB
LCDint2
		CALL	Int2Str
		GOTO	LCDintC
LCDint1
		CALL	Int2Str
		GOTO	LCDintD

; This function prints an unsigned int to the LCD at its current loacation
; and performs leading zero suppresion.
LCDintZS
		CALL	Int2Str
		CALL	RemoveLeadingZeros
		MOVFP	Buffer,WREG
		CALL	LCDsendData
		MOVFP	Buffer+1,WREG
		CALL	LCDsendData
		MOVFP	Buffer+2,WREG
		CALL	LCDsendData
		MOVFP	Buffer+3,WREG
		CALL	LCDsendData
		MOVFP	Buffer+4,WREG
		CALL	LCDsendData
		RETURN

; This function removes leading zeros from the ascii string in Buffer.
RemoveLeadingZeros
		MOVLR	HIGH Buffer
		MOVLW	'0'
		CPFSEQ	Buffer
		RETURN
		MOVLW	' '
		MOVWF	Buffer

		MOVLW	'0'
		CPFSEQ	Buffer+1
		RETURN
		MOVLW	' '
		MOVWF	Buffer+1

		MOVLW	'0'
		CPFSEQ	Buffer+2
		RETURN
		MOVLW	' '
		MOVWF	Buffer+2

		MOVLW	'0'
		CPFSEQ	Buffer+3
		RETURN
		MOVLW	' '
		MOVWF	Buffer+3
		RETURN

; This function converts an integer into an ascii string.
; CEXreg contains the integer and the 5 byte
; string is placed in buffer
Int2Str
	; 10000 digit
		MOVLB	HIGH DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLW	LOW D'10000'
		MOVWF	DEXreg
		MOVLW	HIGH D'10000'
		MOVWF	DEXreg+1
		CALL	Divide2416
		MOVLW	30
		IORWF	CEXreg,0
		MOVWF	Buffer
		MOVE32	EEXreg,CEXreg
	; 1000 digit
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLW	LOW D'1000'
		MOVWF	DEXreg
		MOVLW	HIGH D'1000'
		MOVWF	DEXreg+1
		CALL	Divide2416
		MOVLW	30
		IORWF	CEXreg,0
		MOVWF	Buffer+1
		MOVE32	EEXreg,CEXreg
	; 100 digit
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLW	LOW D'100'
		MOVWF	DEXreg
		MOVLW	HIGH D'100'
		MOVWF	DEXreg+1
		CALL	Divide2416
		MOVLW	30
		IORWF	CEXreg,0
		MOVWF	Buffer+2
		MOVE32	EEXreg,CEXreg
	; 10 digit
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLW	LOW D'10'
		MOVWF	DEXreg
		MOVLW	HIGH D'10'
		MOVWF	DEXreg+1
		CALL	Divide2416
		MOVLW	30
		IORWF	CEXreg,0
		MOVWF	Buffer+3
	; The 1's digit is in the remainder's lsb
		MOVLW	30
		IORWF	EEXreg,0
		MOVWF	Buffer+4
		RETURN

; This function sets the DOG display contrast to the value defined in
; DOGcontrast variable. There are 64 valid values, 0 to 63
SetDOGcontrast
   ; Exit if this is not a DOG display
		MOVFF	Dog162,WREG
		COMF	WREG
		TSTFSZ	WREG
		RETURN
   ; Here if DOG display
		MOVLW	39
		CALL	LCDsendCMD
		; Set the 2 MSBs
		MOVFF	DOGcontrast,WREG
		SWAPF	WREG
		ANDLW	03
		IORLW	50
		CALL	LCDsendCMD
		; Set the 4 LSBs
		MOVFF	DOGcontrast,WREG
		ANDLW	0F
		IORLW	70
		CALL	LCDsendCMD
		; Return the normal mode
		MOVLW	38
		CALL	LCDsendCMD
		RETURN


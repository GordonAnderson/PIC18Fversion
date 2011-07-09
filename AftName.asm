;
; This function is called from the calibration mode when the user 
; selects the edit aircraft name option.
; This function allows the pilot to change the Aircraft name using
; the Aielron stick to select the letter and the elevator stick to
; change the letter. The option key is pressed when the changes are
; complete.
;
AircraftName
	; Display the Name
		CALLFL	LCDsendCMD,LINE2
		CALL	DisplayAircraftName
	; Init indirect register
		MOVLW	LOW Name
		MOVWF	FSR1L,A
		MOVLW	HIGH Name
		MOVWF	FSR1H,A
	; Position the cursor and display the cursor char
CAN0
		CALLFL	Delay1mS,D'150'
		MOVLW	LOW Name
		SUBLW	LINE2
		ADDWF	FSR1L,W,A
		MOVFF	WREG,Areg
ifdef		MicroProStar
	; If the position is to the right of center then adjust the pointer
		MOVLW	LINE2+7
		CPFSGT	Areg,A
		GOTO	ANok
		; Here is adjust address, add 38 hex to correct
		MOVLW	38
		ADDWF	Areg,W,A
		MOVFF	WREG,Areg
ANok
endif
		MOVFF	Areg,WREG
		CALL	LCDsendCMD				; Set the cursor position
		MOVF	INDF1,W,A				
		CALL	LCDsendData				; Write the char to the display
		MOVFF	Areg,WREG				; Reposition the cursor
		CALL	LCDsendCMD
		CALLFL	LCDsendCMD,CURSORON
	; Let the user make a selection
		; Aileron stick selects the character to edit
CANa
		CALL	Aileron
		BTFSS	ALUSTA,Z,A
		GOTO	CAN1
		INCF	FSR1L,F,A
		MOVLW	LOW (Name + D'15')
ifdef ECMA1010display
		MOVLW	LOW (Name + D'11')
Endif
		CPFSGT	FSR1L,A
		GOTO	CAN0
		MOVLW	LOW Name				; Reset to start of line
		MOVWF	FSR1L,A
		GOTO	CAN0
CAN1
		BTFSS	ALUSTA,C,A
		GOTO	CAN2
		DECF	FSR1L,F,A
		MOVLW	LOW (Name - 1)
		CPFSEQ	FSR1L,A
		GOTO	CAN0
		MOVLW	LOW (Name + D'15')
ifdef ECMA1010display
		MOVLW	LOW (Name + D'11')
Endif
		MOVWF	FSR1L,A
		GOTO	CAN0

CAN2
		; Elevator stick changes the character value
		CALL	Elevator
		BTFSS	ALUSTA,Z,A
		GOTO	CAN3
		INCF	INDF1,F,A
		MOVLW	'z'
		CPFSLT	INDF1,A
		MOVWF	INDF1,A
		GOTO	CAN0
CAN3
		BTFSS	ALUSTA,C,A
		GOTO	CAN4
		DECF	INDF1,F,A
		MOVLW	' '
		CPFSGT	INDF1,A
		MOVWF	INDF1,A
		GOTO	CAN0

CAN4
	; Test for the option button
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	CANa
	; Save the name
		CALLFL	LCDsendCMD,CURSOROFF
		MOVFF	Aircraft,WREG
		CALL	SaveAircraft
		RETURN

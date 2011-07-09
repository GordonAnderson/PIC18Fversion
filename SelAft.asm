;
; This function is called from the calibration mode after the user
; has selected the option to "Select Aircraft".
; The top line of the display will show the aircraft number and the
; second line will show the aircraft name.
; The elevator stick is used to scroll through all of the posible
; aircraft, when the option desired is displayed, press the option
; button to make your selection and exit this function.
;
SelectAircraft
	; Move digital trims to the current aircraft and update
		MOVE	DTail,DTailA
		MOVE	DTele,DTeleA
		MOVE	DTrud,DTrudA
		MOVE	DTtht,DTthtA
		MOVFF	Aircraft,WREG
		CALL	SaveAircraft		
	; Display the current aircraft number and name
SA4
		MOVFF	Aircraft,WREG
		CALL	LoadAircraftName
		CALLFL	LCDsendCMD,LINE1
		PrintMess MES4
		CALLFL	LCDsendCMD,LINE1+ACFTPOS
		MOVLB	HIGH Aircraft
		MOVF	Aircraft,W
		MOVLB	HIGH CEXreg
		MOVWF	CEXreg
		CLRF	CEXreg+1
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		CALL	LCDint2
		; Now display the aircraft name on the second line
		CALL	DisplayAircraftName
		MOVFF 	IncTime,WREG
		SUBLW	D'127'
		BTFSC	WREG,7,A
		CLRF	WREG,A
		RLNCF	WREG
		TSTFSZ	WREG,A
		CALL	Delay1mS
	; Test elevator for a change request
SA3
		CALL	Elevator
		BTFSS	ALUSTA,Z,A
		GOTO	SA1
		; Here to advance to next aircraft
		MOVLW	(NumAircraft+1)
		MOVLB	HIGH Aircraft
		INCF	Aircraft
		CPFSEQ	Aircraft
		GOTO	SA4
		MOVLW	1
		MOVWF	Aircraft
		GOTO	SA4
SA1
		BTFSS	ALUSTA,C,A
		GOTO	SA2
		; Here to return to last aircraft
		MOVLR	HIGH Aircraft
		DECF	Aircraft
		MOVLW	0
		CPFSEQ	Aircraft
		GOTO	SA4
		MOVLW	NumAircraft
		MOVLR	HIGH Aircraft
		MOVWF	Aircraft
		GOTO	SA4
	; Test for option button
SA2
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	SA3
	; Now read the selected aircraft data and write the selection to Flash
		MOVFF	Aircraft,WREG
		CALL	LoadAircraft
		; Move digital trims to EEPROM and save
		MOVE	DTailA,DTail
		MOVE	DTeleA,DTele
		MOVE	DTrudA,DTrud
		MOVE	DTthtA,DTtht
		MOVEC	DTail,AXreg
		MOVLW	8
		MOVFF	WREG,Areg
		MOVEC	DTail,AXreg
		CALL	EEPROMwriteBlock
		; Save the aircraft number...
		MOVFF	Aircraft,WREG
		MOVFF	WREG,DefaultAircraft
		CALL	SaveGeneral
		RETURN

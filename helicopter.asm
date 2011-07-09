;
; This file contails all of the helicopter functions. This includes both the run time mixing
; functions as well as the user interface calibration functions.
;
; CCPM mixing is supported as well as 3 flight modes and a throttle hold mode. This capability
; was added based on collborations with Jack Dice.
;
; Gordon Anderson
; December 25, 2009
;

;
; This is the run time helicoper function and applies the proper mixes to
; enable helicopter operation. Note; CCPM is applied the the mixer section 
; application, not in this routine.
;
ApplyHelicopter
	; If the helicopter mode is not enabled then exit this function.
		MOVLR	HIGH Henable
		BTFSS	Henable,0
		RETURN
	; Here if in helicopter mode.
	; Apply IdleUp to throttle position
		CALL	HsetIdleUp
		; Apply throttle tables if no idle up value was set
		BTFSS	ALUSTA,C
		CALL	HsetThrottle
	; Apply Throttle hold position if switch is on, detect a switch state
	; change so we can use it to apply the transition time
		MOVLR	HIGH SWTHOLD
		MOVFP	SWTHOLD,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	AHnotHold
		; Here if the hold switch is on
		MOVLR	HIGH THOLDp
		MOVFP	THOLDp,WREG
		MOVLR	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVE	CEXreg,Tpos
		; Look at the state file, if its reset then there was a state change,
		; this is needed for the slew rate control.
		MOVLB	HIGH TholdState
		MOVF	TholdState,W
		BTFSS	ALUSTA,Z
		GOTO	AHtrim
		; Here with state change on Throttle hold, process the transistion time.
		SETF	TholdState
		MOVE	TtransistionT,TstepSize
		GOTO	AHtrim
AHnotHold	
		; Here if the hold switch is off, State flag is set when the switch is on and
		; reset when its off
		MOVLB	HIGH TholdState
		MOVF	TholdState,W
		BTFSC	ALUSTA,Z
		GOTO	AHtrim
		; Here with state change on Throttle hold, process the transistion time.
		CLRF	TholdState
		MOVE	TtransistionT,TstepSize		
	; Apply CH6 control trim to throttle position and apply pitch
	; table
AHtrim
		; If thepitch reverse flag is set then reverse the CH6pos, it
		; will be use for pitch trim
		MOVLR	HIGH HPrev
		BTFSS	HPrev,0
		GOTO	AHnoRev
		; Here to reverse the sign
		MOVLR	HIGH CH6pos
		COMF	CH6pos
		COMF	CH6pos+1
		INCF	CH6pos
		BTFSC	ALUSTA,Z
		INCF	CH6pos+1
AHnoRev
		; Adjust CH6 by the trim pecentage from the throttle channel
		MOVFF	TPT,AXreg
		MOVLR	HIGH AXreg
		CLRF	AXreg+1
		MOVLW	0FF
		BTFSC	AXreg,7
		MOVWF	AXreg+1
		MOVE	CH6pos,BXreg
		CALL	Mult1616
		MOVLR	HIGH DEXreg
		MOVLW	D'100'
		MOVWF	DEXreg
		CLRF	DEXreg+1
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416	; CEXreg has the trim value
		MOVE	CEXreg,CH6pos	; Save the trim value back to the CH6 pos variable
					; Apply the trim after the table is applied
		; Apply the pitch table, result in AXreg
		CALL	HsetPitch
		; Add the pitch trim
		MOVLB	HIGH CH6pos
		MOVFF	AXreg,WREG
		ADDWF	CH6pos,F
		MOVFF	AXreg+1,WREG		
		ADDWFC	CH6pos+1,F
	; Apply the gyro sensitivity setpoint. This is in percentage, 0 to 100.
	; 0 to 100 needs to be maped to -1000 to 1000 and sent to channel 5.
		CALL	HsetSensitivity	
		RETURN
	
; The following functions support the ApplyHelicopter function

; This function is called to apply the idle up logic to the normal, stunt 1, and stunt 2 
; flight modes. If the mode is selected and the idle up switch is on then the throttle
; position is set to the idle up value.
; On return the carry flag is set if the idleup mode is active and a throttle position
; has been set.
HsetIdleUp
	; Test Stunt mode 2 switch
		MOVFF	SWSTUNT2,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	HIUP_ST1		; If not stunt mode 2 then jump
		; Here if stunt mode 2, test idle up switch
		MOVFF	SWIDLEUPST2,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		RETURN				; Exit if switch is off		
		MOVFF	IdleUpST2,Breg
		GOTO	HIUP_SET		; Set the throttle
HIUP_ST1
	; Test Stunt mode 1 switch
		MOVFF	SWSTUNT1,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	HIUP_NORM		; If not stunt mode 1 then jump
		; Here if stunt mode 1, test idle up switch
		MOVFF	SWIDLEUPST1,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		RETURN				; Exit if switch is off		
		MOVFF	IdleUpST1,Breg
		GOTO	HIUP_SET		; Set the throttle
HIUP_NORM
	; Here if in normal flight mode, test idle up switch
		MOVFF	SWIDLEUPN,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		RETURN				; Exit if switch is off		
		MOVFF	IdleUpNorm,Breg
	; Set the throttle position
HIUP_SET
		MOVLR	HIGH AXreg
		MOVFF	Breg,AXreg
		CLRF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVE	CEXreg,Tpos
		; Set the carry flag
		BSF	ALUSTA,C
		RETURN
		
; This function is called with the throttle position in reg AXreg. The
; proper translation table is applied based on mode and then the pitch
; output value is calculated and returned in the AXreg.
HsetPitch
	; Set the normal flight mode value
		MOVFF	HPitch,Breg
	; Test Stunt mode 1 switch
		MOVFF	SWSTUNT1,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		MOVFF	Hst1Pitch,Breg	
	; Test Stunt mode 2 switch
		MOVFF	SWSTUNT2,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		MOVFF	Hst2Pitch,Breg
	; Test the Throttle hold switch
		MOVFF	SWTHOLD,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		MOVFF	HthtPitch,Breg
	; Here with translation table number in Breg
		MOVE	Tnorm,AXreg
		CALL	Translation
	; Test the Pitch reverse flag, if set reverse the pitch sign
		MOVLR	HIGH HPrev
		BTFSS	HPrev,0
		GOTO	HPrevDone
		; Here to reverse the sign
		MOVLR	HIGH AXreg
		COMF	AXreg
		COMF	AXreg+1
		INCF	AXreg
		BTFSC	ALUSTA,Z
		INCF	AXreg+1
HPrevDone
	; Return result in AXreg
		RETURN

; This function is called with the throttle position in Tpos. The
; proper translation table is applied based on mode and then the throttle
; output value is calculated and sent to Throttle output.
HsetThrottle
	; Set the normal flight mode value
		MOVFF	HTht,Breg
	; Test Stunt mode 1 switch
		MOVFF	SWSTUNT1,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		MOVFF	Hst1Tht,Breg	
	; Test Stunt mode 2 switch
		MOVFF	SWSTUNT2,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		MOVFF	Hst2Tht,Breg
	; Test the Throttle hold switch, No table is used for Throttle hold
		MOVFF	SWTHOLD,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		CLRF	Breg,A
	; Here with translation table number in Breg
		MOVE	Tpos,AXreg
		CALL	Translation
	; Save the position information in Throttle output
		MOVE	AXreg,Tpos
		RETURN
		
HsetSensitivity
	; If the GyroTune flag is set then send CH7 channel to CH5 and exit
		MOVE	CH7pos,CH5pos
		MOVLB	HIGH GyroTune
		MOVF	GyroTune,W
		BTFSS	ALUSTA,Z
		RETURN
	; Set the normal flight mode value
		MOVFF	HSen,Breg
	; Test Stunt mode 1 switch
		MOVFF	SWSTUNT1,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		MOVFF	Hst1Sen,Breg	
	; Test Stunt mode 2 switch
		MOVFF	SWSTUNT2,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		MOVFF	Hst2Sen,Breg
	; Test the Throttle hold switch
		MOVFF	SWTHOLD,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		MOVFF	HthtSen,Breg
	; Here with gyro sensitivity in percentage in Breg, convert
	; 0 to 100 to -1000 to 100. subtract 50 then multiply by 20
		MOVFF	Breg,WREG
		ADDLW	-D'50'			; WREG - 50 -> WREG
		MOVFF	WREG,AXreg
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'20',BXreg
		CALL	Mult1616
	; Save the gyro sensitivity information in CH5 output
		MOVE	CEXreg,CH5pos
		RETURN
	
; This routine is called when the option button is pressed in the run mode. If the
; helicopter mode is active and if the GyroTune flag is active then the option 
; button press is used to signal capture of the CH7 control to the gyro sensitivity 
; variable for the select flight mode.
; On exit carry flag is set if the mode is active.
;
; Note! Need to write the variables to FLASH, but only save if we are not in an
;       alternate aircraft mode. Make sure DefaultAircraft equals Aircraft
;	then call SaveAircraft.
GyroTuneProcess
	; Exit if not in the helicopter mode
		BCF	ALUSTA,C
		MOVLR	HIGH Henable
		BTFSS	Henable,0
		RETURN	
	; Exit if the GyroTune flag is not set
		MOVLB	HIGH GyroTune
		MOVF	GyroTune,W
		BTFSC	ALUSTA,Z
		RETURN
	; Here if we need to process the option button in this function.
	; Adjust the beep to signal the action
		MOVLW	D'3'
		MOVFF	WREG,BeepCyl
		MOVLW	D'2'
		CALL	Beep
	; Calculate the percentage from the CH7 control position.
	; Percentage = (CH7pos+1000)/20
		MOVE	CH7pos,CEXreg
		MOVLB	HIGH CEXreg
		MOVLW	LOW D'1000'
		ADDWF	CEXreg,F
		MOVLW	HIGH D'1000'
		ADDWFC	CEXreg+1
		CLRF	CEXreg+2
		MOVLW	D'20'
		MOVFF	WREG,DEXreg
		CALL	Divide168
	; The percentage position data in now in the CEXreg's LS byte.
	; Now determine the flight mode and save in the proper location.
	
	; Test Throttle hold
		MOVFF	SWTHOLD,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	GTP_Stunt2
		MOVFF	CEXreg,HthtSen
		GOTO	GTP_Save
	; Test Stunt 2
GTP_Stunt2
		MOVFF	SWSTUNT2,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	GTP_Stunt1
		MOVFF	CEXreg,Hst2Sen
		GOTO	GTP_Save
	; Test Stunt 1
GTP_Stunt1
		MOVFF	SWSTUNT1,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	GTP_Norm
		MOVFF	CEXreg,Hst1Sen
		GOTO	GTP_Save
	; Here if normal mode
GTP_Norm
		MOVFF	CEXreg,HSen
		BSF	ALUSTA,C
	; Here is save the results is we are not in the alternut aircraft mode
GTP_Save
	; Compare Aircraft and DefaultAircraft, if different then exit
		MOVFF	Aircraft,WREG
		MOVLB	HIGH DefaultAircraft
		XORWF	DefaultAircraft,W
		BSF	ALUSTA,C
		BTFSS	ALUSTA,Z
		RETURN
	; Here is the same so save
		MOVFF	Aircraft,WREG
		CALL	SaveAircraft
		BSF	ALUSTA,C
		RETURN
		
;
; This function will display the helicopter flight mode. The mode is displayed on the
; second line of the display using the two right most characters.
;
; 	Mode			Display
;	Throttle Hold		TH
;	Stunt 1			S1
;	Stunt 2			S2
;
HelicopterModeDisplay
	; Exit if not helicopter mode
		MOVLR	HIGH Henable
		BTFSS	Henable,0
		RETURN
	; Position the display to line 2
		MOVLW	LINE2+D'14'
		CALL	LCDsendCMD
	; Test the Throttle hold switch
		MOVFF	SWTHOLD,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	HMD_TH
	; Test Stunt mode 2 switch
		MOVFF	SWSTUNT2,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	HMD_S2
	; Test Stunt mode 1 switch
		MOVFF	SWSTUNT1,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	HMD_S1
	; Here if in normal mode so just exit
		RETURN
	; Print mode tags on the right side of the display
HMD_TH
		PrintMess	TH_Mode
		RETURN
HMD_S1
		PrintMess	S1_Mode
		RETURN
HMD_S2
		PrintMess	S2_Mode
		RETURN

; Mode display text		
TH_Mode		DB	"TH",0
S1_Mode		DB	"S1",0
S2_Mode		DB	"S2",0

; The following are pre and post processing routines for the Throttle hold transistion time
; function.
PreTTT
	; t = 500 / step size
		CLRF	WREG
		MOVFF	WREG,CEXreg+2
		MOVEC	D'500',CEXreg
		MOVE	TtransistionT,DEXreg
		CALL	Divide2416
	; Move results to step size
		MOVE	CEXreg,TtransistionT
		CLRF	WREG
		MOVFF	WREG,TtransistionT+1
		MOVFF	TtransistionT,WREG
		RETURN
PostTTT
	; If user set the time to 0 then set the step size to 2000 and exit
		MOVFF	TtransistionT,WREG
		TSTFSZ	WREG,A
		GOTO	PreTTT
		MOVEC	D'2000',TtransistionT
		RETURN


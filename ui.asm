;
; This function will exit the Calibration mode if the run/cal
; switch is set to the run mode while we are in the calibration
; mode. The stack pointer is reset and we are vectored to main
;
CALexit
	; Test mode, if not in Cal mode then return
		MOVLR	HIGH Mode
		MOVLW	modeCAL
		CPFSEQ	Mode
		RETURN
	; Here if in the CAL mode, so test the switch
		MOVLR	HIGH PORTEimage
		BTFSS	PORTEimage,RUNCAL
		RETURN	; Still in CAL mode
		; Switched to run mode, reset the stack and goto main...
		; No stack reset function provided, so just jump to main
		; after clearing the stack pointer
		CLRF	STKPTR
		GOTO	main
		
; This function is called from the UI data entry wait loops, if the
; preset button is pressed then this function will save the general
; and aircraft data and return to the "Press Option" cal mode.
CalSaveAndExit
		CALL	Preset
		BTFSS	STATUS,C
		RETURN
	; Here to save data and exit the menu system
		CLRF	STKPTR
		CALL	SaveGeneral
		MOVFF	Aircraft,WREG	; Load aircraft number
		CALL	SaveAircraft
		CALL	BackupAircraft
		GOTO	main

; This function tests the Preset button and returns its state
; in the carry flag. This fuction is used by the UI to exit 
; data entry. This is a shortcut to return to the "Press Option"
; mode.
;
;	C set if Preset button was pressed
Preset
		MOVLR	HIGH PORTDimage
		BTFSC	PORTDimage,PRESET
		GOTO	Preset1
		; Test if its been processed
		BTFSS	PORTDlatch,PRESET
		GOTO	Preset1
		; Here if preset was pressed
		BCF	PORTDlatch,PRESET
		BSF	ALUSTA,C,A
		RETURN
Preset1
		BCF	ALUSTA,C,A
		RETURN

; This function is called when in the CAL mode and the option button
; is pressed. This function allows the user to select the calibration
; option he wishes to use. The jump table located at CALoptions is used
; to call the selected routine.
; No parameters are expected when this routine is called.
Calibration
	; Display the options...
		MOVLB	HIGH AXreg
		MOVLW	HIGH CALMES1
		MOVWF	AXreg+1
		MOVLW	LOW CALMES1
		MOVWF	AXreg
		CALL	SelectionFunction
		CALL	LCDsendAX
	; Goto the jump table and process
		MOVLB	HIGH CXreg
		MOVF	CXreg,WREG
		CALL	CALoptions
		RETURN

; This function is called by the CalUI calibration user interface generic
; processing routine. This function will display the selected calibration
; option on the top line of the display.
; The variable CalOption holds a pointer to the selection option table 
; entry. This entry starts with the string that needs to be displayed.
DisplayCalibration
		MOVE16	CalOption,AXreg
		CALLF	LCDsendAX
		RETURN
		
; This function is called by the adjust routines in the UI
; that need to allow the pilot to see the servo positions 
; update. For example, this is used by adjust percentage 
; for the sub trim functions.
; The flag CalServoUpdate must be set or this function will
; exit with no action.
CalModeProcess
		MOVLB	HIGH CalServoUpdate
		MOVF	CalServoUpdate,W
		BTFSC	STATUS,Z
		RETURN
	; Save FSR1 regs
		MOVFF	FSR1L, SaveFSR1L
		MOVFF	FSR1H, SaveFSR1H
		
		CALL	CalculateNormalizedPositions
		MOVEC	0,Apos				; Zero the aileron and elevator
		MOVEC	0,Epos
		CALL	ApplyDualRates
		CALL	ApplyExpo
		CALL    ApplySnap
		CALL	AutoTrim
		CALL	ApplyTrims
		CALL	ApplyFixedMixersPrior
		CALL	ApplyMixers
		CALL	ApplyFixedMixers
		CALL	ApplySubTrims
		CALL	CalculateServoPositions

		CALL	ProcessCommand
	; Restore FSR1 regs
		MOVFF	SaveFSR1L, FSR1L
		MOVFF	SaveFSR1H, FSR1H
	
		RETURN

; This function is called to set the CalServoUpdate flag. This is a 
; function that is called by the user interface code using the pre call
; table functions.
SetSUflag
		MOVLB	HIGH CalServoUpdate
		SETF	CalServoUpdate
		RETURN

; AXreg points to the start of the message table. This 
; function fills CXreg with the word at the end of the 
; message block. BXreg is then filled with the second
; optional word. DXreg is filled with the third optional
; word. AXreg points at the current message on exit.         
;
; On call:
;	AXreg points to start of message table
; On Exit:
;	AXreg = points to the current selection
;	CXreg = Opt:Type
;	Bxreg = ptr1, first optional word
;	DXreg = ptr2, second optional word
; If the opt bit 6 is set then the min and max parameters
; are read and the limit reg are set. MinValue and MaxValue.
;
SelectionFunction
		CALL	CALexit
        ; Clear the EXIT flag
        	MOVLR	HIGH EXIT
        	CLRF	EXIT 
        	CLRF	YESNO  
        	CLRF	PostCall
        	CLRF	PostCall+1
	; Display the message
SelFun4	
		CALLFL	LCDsendCMD,LINE2
		MOVFF	AXreg,TBLPTRL
		MOVFF	AXreg+1,TBLPTRH
		CLRF	TBLPTRU
		MOVE16	AXreg,BXreg		; Save pointer to current message
		CALL    LCDsendMess
		CALLFL	Delay1mS,D'250'
	; Get the users selection
		CALL	Aileron
		BTFSS	ALUSTA,Z
		GOTO	SelFun1
		; If here go to next selection
		MOVLW	D'17'
		ADDWF	AXreg,F
		BTFSC	ALUSTA,C
		INCF	AXreg+1,F
		GOTO	SelFun2
SelFun1
		BTFSS	ALUSTA,C
		GOTO	SelFun3
		; If here go to last selection
		MOVLW	D'19'
		ADDWF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
SelFun2
		; Load AXreg into the table pointer
		MOVFF	AXreg,TBLPTRL
		MOVFF	AXreg+1,TBLPTRH
		CLRF	TBLPTRU
		; Load AXreg with the table pointer contents...
		TBLRD*+
		MOVFF	TABLAT,AXreg
		TBLRD*+
		MOVFF	TABLAT,AXreg+1
		GOTO	SelFun4
	; Check for Option button
SelFun3
		CALL	CalSaveAndExit
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	SelFun4
	; The option button  has been pressed. Advance the table
	; pointer to the parameters at the end of the record. Load
	; the word into CXreg...
		MOVLW	D'21'
		ADDWF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
		; Load AXreg into the table pointer
		MOVFF	AXreg,TBLPTRL
		MOVFF	AXreg+1,TBLPTRH
		CLRF	TBLPTRU,A
		; Load CXreg with the table pointer contents...
		TBLRD*+
		MOVFF	TABLAT,CXreg
		TBLRD*+
		MOVFF	TABLAT,CXreg+1
	; Restore AXreg to point at current message
		MOVE16	BXreg,AXreg
	; Load the option second word into BXreg
		TBLRD*+
		MOVFF	TABLAT,BXreg
		TBLRD*+
		MOVFF	TABLAT,BXreg+1
	; Load the option third word into DXreg
		TBLRD*+
		MOVFF	TABLAT,DXreg
		TBLRD*+
		MOVFF	TABLAT,DXreg+1
	; If Opt bit 6 is set then load min and max value, opt is in CXreg+1
		; Set default limits
		MOVLB	HIGH MinValue
		CLRF	MinValue
		CLRF	MinValue+1
		SETF	MaxValue
		MOVLW	07F
		MOVFF	WREG,MaxValue+1
		;
		BTFSS	CXreg+1,6
		GOTO	SelFun4a
		; Load MinValue
		TBLRD*+
		MOVFF	TABLAT,MinValue
		TBLRD*+
		MOVFF	TABLAT,MinValue+1
		; Load MaxValue
		TBLRD*+
		MOVFF	TABLAT,MaxValue
		TBLRD*+
		MOVFF	TABLAT,MaxValue+1 
SelFun4a
	; If Opt bit 2 is set then load the Post call variable
		BTFSS	CXreg+1,2
		GOTO	SelFun5
		; Load PostCall vector
		TBLRD*+
		MOVFF	TABLAT,PostCall
		TBLRD*+
		MOVFF	TABLAT,PostCall+1
SelFun5
	; If Opt bit 1 is set then load the Pre call variable
		BTFSS	CXreg+1,1
		GOTO	SelFun5a
		; Load PreCall vector
		TBLRD*+   
		MOVFF	TABLAT,PreCall
		TBLRD*+
		MOVFF	TABLAT,PreCall+1
SelFun5a
	; If Opt bit 7 is set then load AXreg message to line 1 of display
		BTFSS	CXreg+1,7
		GOTO	SelFun6  
		CALLF	LCDsendAX   
	; If Opt bit 3 it set then load DXreg message to line 2 of display
SelFun6
		BTFSS	CXreg+1,3
		GOTO	SelFun7
		CALLF	LCDsendDXLine2 
SelFun7           
	; If Opt bit 1 is set then call the pre function
		BTFSS	CXreg+1,1
		RETURN 
		MOVLR	HIGH PreCall
		CLRF	WREG
		MOVFF	WREG,PCLATU
		MOVFF	PreCall+1,WREG   
		MOVFF	WREG,PCLATH
		MOVFF	PreCall,WREG   
		MOVWF	PCL
;
; This function will look through the table for the value passed
; in reg WREG.
; Inputs:
;	BXreg = points to the start of the table
; 	WREG  = Value we are looking for in the table
; Returns with BXreg pointing to the record that contains WREG's value
;
FindSelection
		MOVFF	WREG,Areg
	; Save BXreg
		MOVE16	BXreg,EEXreg
	; Get this locations value
AdvanceRecord
		MOVFF	BXreg,TBLPTRL
		MOVFF	BXreg+1,TBLPTRH
		CLRF	TBLPTRU,A
	; Add offset to the variable
		MOVLW	D'21'
		ADDWF	TBLPTRL
		BTFSC	ALUSTA,C
		INCF	TBLPTRH
		; Load the variable...
		TBLRD*+
		MOVFF	TABLAT,WREG
		; If WREG = Areg then exit!
		CPFSEQ	Areg
		GOTO	NextRecord
		RETURN
NextRecord
	; Advance BXreg to next table entry
		; Load BXreg into the table pointer
		MOVFF	BXreg,TBLPTRL
		MOVFF	BXreg+1,TBLPTRH
		MOVLW	D'17'
		ADDWF	TBLPTRL
		BTFSC	ALUSTA,C
		INCF	TBLPTRH
		; Load BXreg with the table pointer contents...
		TBLRD*+
		MOVFF	TABLAT,BXreg
		TBLRD*+
		MOVFF	TABLAT,BXreg+1
	; If BXreg = EEXreg then we have been all the way around the loop, so exit anyway!
		MOVFF	BXreg,WREG
		CPFSEQ	EEXreg
		GOTO	AdvanceRecord
		MOVFF	BXreg+1,WREG
		CPFSEQ	EEXreg+1
		GOTO	AdvanceRecord
		RETURN     
                      
; This function calls the routine pointed to in BXreg and then
; returns to this routines caller.      
; If BXreg == 0 then this routine will exit
CallBXreg            
		MOVLB	HIGH BXreg
		MOVF	BXreg+1,W
		IORWF	BXreg,W
		BTFSC	ALUSTA,Z
		RETURN
		CLRF	WREG
		MOVWF	PCLATU
		MOVF	BXreg+1,W
		MOVFF	WREG,PCLATH
		MOVF	BXreg,W
		MOVWF	PCL
		

;
; This function accepts input from the user.
; LSB of CXreg is input type
;	0 = pointer to selection table
;	1 = percent input
;	2 = u sec input
;	3 = yes/no input
;	4 = Channel, Ail - CH8
;       5 = Byte input
;	6 = Select Switch   
;	7 = function call, BXreg contails a 16 bit pointer to the function to be called 
;	8 = Milli volt edit function
;	9 =
;	A = yes/no input, bit flag, mask in LSB of DXreg
;	B = short signed int
;	C = signed int
; BXreg points to the variable location
;
;	CXreg = Opt:Type
;	BXreg = ptr1, first optional word
;	DXreg = ptr2, second optional word
Input	
	; Save the variable pointer into Src for apply to all function
		MOVE	BXreg,Src
		MOVLW	1		; Set the count to 1, indicating byte
		MOVFF	WREG,Cnt
	; Load the variable pointer into FSR1
		MOVLB	HIGH BXreg
		MOVF	BXreg,W
		MOVWF	FSR1L
		MOVF	BXreg+1,W
		MOVWF	FSR1H
	; Get the type and decode...
		MOVLB	HIGH CXreg
		MOVLW	0
		CPFSEQ	CXreg
		GOTO	Input1
		; Get the current variable from the selection table and load 
		; WREG with the current value
		MOVFF	BXreg,TBLPTRL
		MOVFF	BXreg+1,TBLPTRH
		CLRF	TBLPTRU,A
		MOVLW	D'22'
		ADDWF	TBLPTRL,F,A
		BTFSC	ALUSTA,C
		INCF	TBLPTRH,F,A
		; Load WREG with the value pointed to by DXreg
		MOVFF	DXreg,FSR1L
		MOVFF	DXreg+1,FSR1H
		MOVFF	INDF1,WREG	
		CALL	FindSelection
		CALL	VerticalSelection
		RETURN
Input1
		MOVLW	1
		CPFSEQ	CXreg
		GOTO	Input2
	; Here for percent input
		MOVLW	'%'
		MOVFF	WREG,Units	; Set the units character
		CALL	ADJpercent
		RETURN
Input2
		MOVLW	2
		CPFSEQ	CXreg
		GOTO	Input3
	; Here for uS input, do not change the 2 MS bits of the 
	; variable, used for flags
		; If CXreg+1 LSB is set then DXreg contains the
		; DriveCh value.
		MOVLB	HIGH CXreg
		BTFSS	CXreg+1,0
		GOTO	NoDriveCh
		MOVF	DXreg,W
		MOVLB	HIGH DriveCh
		MOVWF	DriveCh
NoDriveCh
		; Put variable in CXreg
		MOVFF	POSTINC1,Areg
		MOVFF	POSTDEC1,Breg
		MOVLB	HIGH CXreg
		MOVFF	Areg,CXreg
		MOVFF	Breg,CXreg+1
		BCF	CXreg+1,7
		BCF	CXreg+1,6
		CALL	ADJuS
		; Write result back
		MOVLB	HIGH BXreg
		MOVFF	BXreg,FSR1L
		MOVFF	BXreg+1,FSR1H
		MOVFF	CXreg,Areg
		MOVFF	CXreg+1,Breg
		MOVPF	Areg,POSTINC1
		MOVFF	INDF1,WREG
		ANDLW	0C0
		IORWF	Breg,F
		MOVFF	Breg,POSTDEC1
		RETURN
Input3
		MOVLW	3
		CPFSEQ	CXreg
		GOTO	Input4
	; Here for Yes/No input using byte flag
		MOVFF	INDF1,WREG
		RLCF	WREG
		CALL	YesNo
		MOVLW	0
		BTFSC	ALUSTA,C
		COMF	WREG
		MOVWF	Areg
		MOVLB	HIGH BXreg
		MOVFF	BXreg,FSR1L
		MOVFF	BXreg+1,FSR1H
		MOVPF	Areg,INDF1
		RETURN
Input4
		MOVLW	4
		CPFSEQ	CXreg
		GOTO	Input5
	; Here for channel selection input
		MOVFF	INDF1,WREG	; Load the current value
		CALL	SelectChannel
		MOVWF	Areg
		MOVLB	HIGH BXreg
		MOVFF	BXreg,FSR1L
		MOVFF	BXreg+1,FSR1H
		MOVPF	Areg,INDF1
		RETURN
Input5
		MOVLW	5
		CPFSEQ	CXreg
		GOTO	Input6
	; Here for byte input
		MOVFF	INDF1,WREG
		CALL	ADJbyte
		MOVFF	WREG,Areg
		MOVLB	HIGH BXreg
		MOVFF	BXreg,FSR1L
		MOVFF	BXreg+1,FSR1H
		MOVFF	Areg,INDF1		
		RETURN
Input6
		MOVLW	6
		CPFSEQ	CXreg
		GOTO	Input7
	; Here for switch selection
		MOVFF	INDF1,Areg		; This is the current value
		MOVE16	BXreg,DXreg		; Save the pointer to selected variable
		MOVEC	SWMENU1,BXreg		; Point to the switch table
		MOVFF	Areg,WREG
		CALL	FindSelection		; This will adjust BXreg to point to
						; the current selection.
		CALL	VerticalSelection	; Let the user make a selectoion,
						; The result is in SWselect.
		RETURN
Input7
		MOVLW	7
		CPFSEQ	CXreg
		GOTO	Input8
	; Here for function call, pointer in BXreg
		CALL	CallBXreg 
		RETURN
Input8
		MOVLW	8
		CPFSEQ	CXreg
		GOTO	Input9
	; Here for voltage input
		MOVFF	INDF1,WREG
		CALL	ADJvolt
		MOVFF	WREG,Areg
		MOVLB	HIGH BXreg
		MOVFF	BXreg,FSR1L
		MOVFF	BXreg+1,FSR1H
		MOVFF	Areg,INDF1		
Input9
		MOVLW	0A
		CPFSEQ	CXreg
		GOTO	InputB
	; Here for Yes/No input using bit flag
		MOVFF	INDF1,WREG
		MOVLB	HIGH DXreg
		ANDWF	DXreg,W
		BCF	ALUSTA,C
		BTFSC	ALUSTA,Z
		BSF	ALUSTA,C
		CALL	YesNo
		MOVLB	HIGH DXreg
		MOVFF	DXreg,Areg
		MOVLB	HIGH BXreg
		MOVFF	BXreg,FSR1L
		MOVFF	BXreg+1,FSR1H
		BTFSC	ALUSTA,C
		GOTO	Input8a
		MOVFF	Areg,WREG
		IORWF	INDF1
		RETURN
Input8a              
		MOVFF	Areg,WREG
		COMF	WREG
		ANDWF	INDF1
		RETURN        
InputB
		MOVLW	0B
		CPFSEQ	CXreg
		GOTO	InputC
	; Here for short int input, signed byte
		MOVLW	' '
		MOVFF	WREG,Units	; Set the units character
		CALL	ADJpercent
		RETURN
InputC
		MOVLW	0C
		CPFSEQ	CXreg
		GOTO	InputD
	; Here for int input, signed 16 bit value
		; Put variable in CXreg
		MOVFF	POSTINC1,Areg
		MOVFF	POSTDEC1,Breg
		MOVLB	HIGH CXreg
		MOVFF	Areg,CXreg
		MOVFF	Breg,CXreg+1
		CALL	ADJinteger
		; Write result back
		MOVLB	HIGH BXreg
		MOVFF	BXreg,FSR1L
		MOVFF	BXreg+1,FSR1H
		MOVFF	CXreg,Areg
		MOVFF	CXreg+1,Breg
		MOVPF	Areg,POSTINC1
		MOVFF	Breg,POSTDEC1
		RETURN
InputD
		RETURN
; This function displays Accept on the second line of the
; LCD display. The Aileron stick is used to change the selection
; from Yes to No. The default entry is set by the carry flag
; when the function is called. The carry flag also defines the
; users selection:
;	C set for Yes
;	C clear for No
Accept
	; Set the flag in Areg
		CLRF	Breg
		BTFSC	ALUSTA,C
		COMF	Breg
	; Print the accept text...
		CALLFL  LCDsendCMD,LINE2
		PrintMess MES7
AcceptLoop
		BTFSS	Breg,0
		GOTO	Accept1
	; Highlight Yes
		CALLFL  LCDsendCMD,LINE2+YPOS
		CALLFL	LCDsendData,'('
		CALLFL  LCDsendCMD,LINE2+YNPOS
		CALLFL	LCDsendData,')'
		CALLFL  LCDsendCMD,LINE2+NPOS
		CALLFL	LCDsendData,' '
		GOTO	Accept2
Accept1
	; Highlight No
		CALLFL  LCDsendCMD,LINE2+YPOS
		CALLFL	LCDsendData,' '
		CALLFL  LCDsendCMD,LINE2+YNPOS
		CALLFL	LCDsendData,'('
		CALLFL  LCDsendCMD,LINE2+NPOS
		CALLFL	LCDsendData,')'
Accept2
	; Call Aileron position test....
	;   Z flag set if Right
	;   C flag set if Left
		CALL	Aileron
		BTFSC	ALUSTA,Z
		CLRF	Breg
		MOVLW	0FF
		BTFSC	ALUSTA,C
		MOVWF	Breg
	; Test if option button has been pressed
	; Carry flag set if pressed
		CALL	CalSaveAndExit
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	AcceptLoop
	; Set the carry flag on exit
		BCF	ALUSTA,C
		BTFSC	Breg,0
		BSF	ALUSTA,C
		RETURN

; This function displays Yes No on the second line of the
; LCD display, right justified. The Aileron stick is used to change from
; from Yes to No. The default entry is set by the carry flag
; when the function is called. The carry flag also defines the
; users selection:
;	C set for Yes
;	C clear for No
YesNo
	; Set the flag in Areg
		CLRF	Breg,A
		BTFSC	ALUSTA,C,A
		COMF	Breg,F,A
	; Print the Yes No text...
		CALLFL  LCDsendCMD,LINE2+YPOS
		PrintMess MES11
YesNoLoop
		BTFSS	Breg,0,A
		GOTO	YesNo1
	; Highlight Yes
		CALLFL  LCDsendCMD,LINE2+YPOS
		CALLFL	LCDsendData,'('
		CALLFL  LCDsendCMD,LINE2+YNPOS
		CALLFL	LCDsendData,')'
		CALLFL  LCDsendCMD,LINE2+NPOS
		CALLFL	LCDsendData,' '
		GOTO	YesNo2
YesNo1
	; Highlight No
		CALLFL  LCDsendCMD,LINE2+YPOS
		CALLFL	LCDsendData,' '
		CALLFL  LCDsendCMD,LINE2+YNPOS
		CALLFL	LCDsendData,'('
		CALLFL  LCDsendCMD,LINE2+NPOS
		CALLFL	LCDsendData,')'
YesNo2
	; Call Aileron position test....
	;   Z flag set if Right
	;   C flag set if Left
		CALL	Aileron
		BTFSC	ALUSTA,Z,A
		CLRF	Breg,A
		MOVLW	0FF
		BTFSC	ALUSTA,C,A
		MOVWF	Breg,A
	; Test if option button has been pressed
	; Carry flag set if pressed
		CALL	CalSaveAndExit
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	YesNoLoop
	; Set the carry flag on exit
		BCF	ALUSTA,C,A
		BTFSC	Breg,0,A
		BSF	ALUSTA,C,A
		RETURN


; This function tests value in WREG against the limts in MaxByte and
; MinByte. If its outside of this range, the value is set to the nearest
; limit.
Limit8
	; Test the MaxByte limit
		MOVLB	HIGH MaxByte
		CPFSGT	MaxByte
		MOVF	MaxByte,W
		CPFSLT	MinByte
		MOVF	MinByte,W
		RETURN


;==============================================================================
;
; Function: ADJbyte, ADJvolt
;
; Purpose:
;    This function allows the user to adjust the value of a byte variable.
;    The minimum and maximum values allowed are defined in MinByte and MaxByte.
;    The Byte that will be adjusted in in WREG, and is also returned in WREG.
;    The elevator stick is used to adjust the value, pressing the option
;    button will accept the new value and cause this routine to exit.
;
; Inputs:
;    Wreg    = value to adjust
;    MinByte = lower limit
;    MaxByte = upper limit
;
; Outputs:
;    Wreg = adjusted value
;
; Uses:
;    Ctemp
;    CEXreg
;
; Calls:
;    Int2Str
;    LCDsendCMD
;    LCDsendData
;    Elevator
;    Option
;
;==============================================================================
ADJvolt
	; This is a second entry point into ADJbyte. This will set a 
	; decimal point in the displayed result. This entry point sets
	; the DP flag.
		MOVLB	HIGH DPflag
		SETF	DPflag
	; First save WREG in Ctemp
		MOVLB	HIGH Ctemp
		MOVWF	Ctemp
		GOTO	ADJbyteloop
ADJbyte
	; First save WREG in Ctemp
		MOVLB	HIGH Ctemp
		MOVWF	Ctemp
	; Clear the decimal point flag
		MOVLB	HIGH DPflag
		CLRF	DPflag
	; Convert Breg to string
ADJbyteloop
		CALLFL	Delay1mS,D'150'
		MOVFF	Ctemp,WREG
		; Save in CEXreg
		MOVLB	HIGH CEXreg
		MOVWF	CEXreg
		CLRF	CEXreg+1
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		; Make into a string...
		CALL	Int2Str
		; Test the DP flag and display results
		MOVLB	HIGH DPflag
		TSTFSZ	DPflag
		GOTO	ShowDP
		; Position and print...
		CALLFL	LCDsendCMD,LINE2+BYTEPOS
		CALLFF	LCDsendData,Buffer+2
		CALLFF	LCDsendData,Buffer+3
		CALLFF	LCDsendData,Buffer+4
		GOTO	ADJbyte2
		; Here to display the decimal point
ShowDP
		CALLFL	LCDsendCMD,LINE2+BYTEPOS-1
		CALLFF	LCDsendData,Buffer+2
		CALLFF	LCDsendData,Buffer+3
		CALLFL	LCDsendData,'.'		
		CALLFF	LCDsendData,Buffer+4
	; Test the elevator stick
ADJbyte2
		CALL	Elevator
		MOVLB	HIGH Ctemp
		BTFSS	ALUSTA,Z
		GOTO	ADJbyte1
		INCF	Ctemp
		; Test if its greater than MaxByte
		MOVFF	MaxByte,WREG
		CPFSLT	Ctemp
		MOVWF	Ctemp		
		TSTFSZ	Ctemp
		GOTO	ADJbyte3
		MOVWF	Ctemp		
		GOTO	ADJbyte3

ADJbyte1
		BTFSS	ALUSTA,C
		GOTO	ADJbyte3
		MOVFF	Ctemp,WREG
		CPFSLT	MinByte
		GOTO	ADJbyte3
		DECF	Ctemp
		; Test if its less that than MinByte
		MOVFF	MinByte,WREG
		CPFSGT	Ctemp
		MOVWF	Ctemp		
	; Test for the option button to indicate we exit
ADJbyte3
		CALL	CalSaveAndExit
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	ADJbyteloop
		MOVLB	HIGH Ctemp
		MOVFF	Ctemp,WREG
		RETURN
		
; This function will display the signed percentage in INDF1 and allow
; the pilot to adjust the value using the elevator stick. The result
; is returned in WREG
ADJpercent
		CALL	CalModeProcess
		MOVFF 	IncTime,WREG
		SUBLW	D'127'
		BTFSC	WREG,7,A
		CLRF	WREG,A
		RLNCF	WREG
		TSTFSZ	WREG,A
		CALL	Delay1mS
;		CALLFL	Delay1mS,D'250'
		MOVFF	INDF1,WREG
		BTFSC	INDF1,7
		COMF	WREG
		BTFSC	INDF1,7
		INCF	WREG
		; Save in CEXreg
		MOVLB	HIGH CEXreg
		MOVWF	CEXreg
		CLRF	CEXreg+1
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		; Make into a string...
		CALL	Int2Str
		; Position the print position and print...
		CALLFL	LCDsendCMD,LINE2+PERCENTPOS
		MOVLW	' '
		BTFSC	INDF1,7
		MOVLW	'-'
		CALLFW	LCDsendData
		CALLFF	LCDsendData,Buffer+2
		CALLFF	LCDsendData,Buffer+3
		CALLFF	LCDsendData,Buffer+4
		MOVFF	Units,WREG
		CALLFW	LCDsendData
	; Test the elevator stick
ADJ2
		CALL	Elevator
		MOVLB	HIGH Ctemp
		BTFSS	ALUSTA,Z
		GOTO	ADJ1
		INCF	INDF1		
		GOTO	ADJ3
ADJ1
		BTFSS	ALUSTA,C
		GOTO	ADJ3
		DECF	INDF1
	; Test for the option button to indicate we exit
ADJ3
		CALL	CalSaveAndExit
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	ADJpercent
	; Clear the update flag if set 
		MOVLB	HIGH CalServoUpdate
		CLRF	CalServoUpdate
		RETURN

; This function tests the value in CXreg against the MinTime and
; MaxTime limites. If the value is outside of this range it will
; be set to the nearest limit.
Limit16
	; Test the MaxTime Limit
		MOVLB	HIGH CXreg
		MOVF	CXreg,W
		SUBWF	MaxTime,W
		MOVF	CXreg+1,W
		SUBWFB	MaxTime+1,W
		; Test flag, set to max and exit if its over the limit
		BTFSC	ALUSTA,C
		GOTO	Limit16a
		MOVF	MaxTime,W
		MOVWF	CXreg
		MOVF	MaxTime+1,W
		MOVWF	CXreg+1
		RETURN
Limit16a
	; The the MinTime Limit
		MOVF	MinTime,W
		SUBWF	CXreg,W
		MOVF	MinTime+1,W
		SUBWFB	CXreg+1,W
		; Test flag, set to min and exit if its under the limit
		BTFSC	ALUSTA,C
		GOTO	Limit16b
		MOVF	MinTime,W
		MOVWF	CXreg
		MOVF	MinTime+1,W
		MOVWF	CXreg+1
Limit16b		
		RETURN
		
; This function allows the pilot to adjust the millisec
; value saved in CXreg. This is an unsigned value and its
; limited to MinTime and MaxTime. The value is displayed in millisec.
; This function does not allow you to adjust outside of this
; range. The values is range tested and adjusted to
; a valid limit.
; The units are in .5 uS, so a time of 1 millisec = 2000
;
; CXreg contains the 16 bit time value.
ADJuS
		CALL	Limit16
		MOVLB	HIGH SymSet
		CLRF	SymSet
ADJuSz  
	; If the DriveCh flag is non zero, then it points
	; to the channel times array point into witch to write
	; this position. 
		MOVLB	HIGH DriveCh
		MOVF	DriveCh,W
		IORWF	WREG
		BTFSC	ALUSTA,Z
		GOTO	ADJuSa
		; Here if we are going to send the values to the 
		; times array
		MOVF	DriveCh,W
		MOVWF	FSR1L
		MOVLW	HIGH DriveCh
		MOVWF	FSR1H
		MOVFF	CXreg,POSTINC1
		MOVFF	CXreg+1,INDF1
	;
ADJuSa
		MOVFF 	IncTime,WREG
		SUBLW	D'127'
		BTFSC	WREG,7,A
		CLRF	WREG,A
		RLNCF	WREG
		TSTFSZ	WREG,A
		CALL	Delay1mS
	; Convert the value in CXreg into a string
		MOVE16	CXreg,CEXreg
		; Divide by two before the display operation
		BCF     ALUSTA,C
		RRCF    CEXreg+1
		RRCF    CEXreg
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		CALL	Int2Str
	; Position the print position and print...
		CALLFL	LCDsendCMD,LINE2+uSPOS
		CALLFF	LCDsendData,Buffer+1
		CALLFL	LCDsendData,'.'
		CALLFF	LCDsendData,Buffer+2
		CALLFF	LCDsendData,Buffer+3
		CALLFF	LCDsendData,Buffer+4
		CALLFL	LCDsendData,'m'
		CALLFL	LCDsendData,'S'
	; Test the elevator stick
ADJus2
		CALL	Elevator
		MOVLB	HIGH CXreg
		BTFSS	ALUSTA,Z
		GOTO	ADJus1
		INCF	CXreg
		BTFSC	ALUSTA,Z
		INCF	CXreg+1
		INCF	CXreg
		BTFSC	ALUSTA,Z
		INCF	CXreg+1
		; Test the limits...
		MOVF	MaxTime+1,W
		CPFSEQ	CXreg+1
		GOTO	ADJuS
		MOVF	MaxTime,W
		CPFSLT	CXreg
		MOVWF	CXreg
		GOTO	ADJuS
ADJus1
		BTFSS	ALUSTA,C
		GOTO	ADJus3
		DECF	CXreg
		BTFSS	ALUSTA,C
		DECF	CXreg+1
		DECF	CXreg
		BTFSS	ALUSTA,C
		DECF	CXreg+1
		; Test limits
		MOVF	MinTime+1,W
		CPFSEQ	CXreg+1
		GOTO	ADJuS
		MOVF	MinTime,W
		CPFSGT	CXreg
		MOVWF	CXreg
		GOTO	ADJuS
	; Test if the AUTO trim button has been pressed...
ADJus3
		MOVLB	HIGH SymSet
		BTFSS	PORTEimage,AUTOT
		SETF	SymSet
	; If Snap Right button is pressed then set time to max
		BTFSC	PORTEimage,SNAPR
		GOTO	ADJus3a
		MOVEC	D'4000', CXreg
ADJus3a
	; If snap Left button is pressed then set time to min
		MOVLB	HIGH PORTEimage
		BTFSC	PORTEimage,SNAPL
		GOTO	ADJus3b
		MOVEC	D'2000', CXreg
ADJus3b	
	; Test for the option button to indicate we exit
		CALL	CalSaveAndExit
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	ADJuSz
		RETURN

; This function allows the pilot to adjust the signed integer
; value saved in CXreg. ;
; CXreg contains the 16 bit signed integer value.
ADJinteger
	; Adjust the delay time based on stick position
		MOVFF 	IncTime,WREG
		SUBLW	D'127'
		BTFSC	WREG,7,A
		CLRF	WREG,A
		RLNCF	WREG
		TSTFSZ	WREG,A
		CALL	Delay1mS
	; Convert the value in CXreg into a string
		MOVE16	CXreg,CEXreg
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		CALL	Int2Str
	; Position and print
		CALLFL	LCDsendCMD,LINE2+INTPOS
		CALLFF	LCDsendData,Buffer
		CALLFF	LCDsendData,Buffer+1
		CALLFF	LCDsendData,Buffer+2
		CALLFF	LCDsendData,Buffer+3
		CALLFF	LCDsendData,Buffer+4
	; Test the elevator stick
ADJint2
		CALL	Elevator
		MOVLB	HIGH CXreg
		BTFSS	ALUSTA,Z
		GOTO	ADJint1
		INCF	CXreg
		BTFSC	ALUSTA,Z
		INCF	CXreg+1
		; Test the limits...
		MOVF	MaxTime+1,W
		CPFSEQ	CXreg+1
		GOTO	ADJinteger
		MOVF	MaxTime,W
		CPFSLT	CXreg
		MOVWF	CXreg
		GOTO	ADJinteger
ADJint1
		BTFSS	ALUSTA,C
		GOTO	ADJint3
		DECF	CXreg
		BTFSS	ALUSTA,C
		DECF	CXreg+1
		; Test limits
		MOVF	MinTime+1,W
		CPFSEQ	CXreg+1
		GOTO	ADJinteger
		MOVF	MinTime,W
		CPFSGT	CXreg
		MOVWF	CXreg
		GOTO	ADJinteger
	; Test for the option button to indicate we exit
ADJint3	
		CALL	CalSaveAndExit
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	ADJinteger
		RETURN


; This function uses the elevator stick to select an option
; from the table pointed to by the value in BXreg. When the
; Option key is pressed, the variable at the end of the selected
; table is placed in the pointer defined in the DXreg.
; The variable is one byte, 8 bits only.
;
; BXreg points to table 
; DXreg points to variable location
VerticalSelection
	; Display the message
VerSel4	
		CALLFL	LCDsendCMD,LINE2
		MOVFF	BXreg,TBLPTRL
		MOVFF	BXreg+1,TBLPTRH
		CALL    LCDsendMess
		CALLFL	Delay1mS,D'250'
	; Get the users selection
		CALL	Elevator
		BTFSS	ALUSTA,Z
		GOTO	VerSel1
		; If here go to next selection
		MOVLW	D'17'
		ADDWF	BXreg,F
		BTFSC	ALUSTA,C
		INCF	BXreg+1,F
		GOTO	VerSel2
VerSel1
		BTFSS	ALUSTA,C
		GOTO	VerSel3
		; If here go to last selection
		MOVLW	D'19'
		ADDWF	BXreg
		BTFSC	ALUSTA,C
		INCF	BXreg+1
VerSel2
		; Load BXreg into the table pointer
		MOVFF	BXreg,TBLPTRL
		MOVFF	BXreg+1,TBLPTRH
		CLRF	TBLPTRU
		; Load BXreg with the table pointer contents...
		TBLRD*+
		MOVFF	TABLAT,BXreg
		TBLRD*+
		MOVFF	TABLAT,BXreg+1
		GOTO	VerSel4
	; Check for Option button
VerSel3
		CALL	CalSaveAndExit
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	VerSel4
	; The option button  has been pressed. Advance the table
	; pointer to the parameters at the end of the record.
		MOVLW	D'21'
		ADDWF	BXreg
		BTFSC	ALUSTA,C
		INCF	BXreg+1
		; Load BXreg into the table pointer
		MOVFF	BXreg,TBLPTRL
		MOVFF	BXreg+1,TBLPTRH
		CLRF	TBLPTRU
		; Load the variable...
		TBLRD*+
		MOVFF	TABLAT,Areg
		TBLRD*+
		MOVFP	TABLAT,WREG
	; Load the variable into the address contained in DXreg
		MOVFF	DXreg,FSR1L
		MOVFF	DXreg+1,FSR1H
		MOVPF	Areg,INDF1  
		RETURN
;
; This function uses the elevator stick to select a channel.
; The selected channel is returned in WREG when the option 
; key is pressed. On call WREG contains the current value.
;
SelectChannel
	; Valid Range for WREG is 0 to 8, now enforce it...
		ANDLW	0F
		BTFSC	WREG,3
		ANDLW	08
	; Set to current selection
		MULLW	LOW (SERVOSEL2 - SERVOSEL1)
		MOVFF	PRODL,CEXreg
		MOVFF	PRODH,CEXreg+1
	; Use CEXreg to point to the message table
		MOVLR	HIGH CEXreg
		MOVLW	LOW SERVOSEL1
		ADDWF	CEXreg,F
		MOVLW	HIGH SERVOSEL1
		ADDWFC	CEXreg+1,F
	; Display the message
SelectChannel4	
		CALLFL	LCDsendCMD,LINE2+SELCHPOS
		MOVFF	CEXreg,TBLPTRL
		MOVFF	CEXreg+1,TBLPTRH
		CALL    LCDsendMess
		CALLFL	Delay1mS,D'250'
	; Get the users selection
		CALL	Elevator
		BTFSS	ALUSTA,Z,A
		GOTO	SelectChannel1
		; If here go to next selection
		MOVLW	D'5'
		ADDWF	CEXreg,F
		BTFSC	ALUSTA,C,A
		INCF	CEXreg+1,F
		GOTO	SelectChannel2
SelectChannel1
		BTFSS	ALUSTA,C
		GOTO	SelectChannel3
		; If here go to last selection
		MOVLW	D'7'
		ADDWF	CEXreg
		BTFSC	ALUSTA,C,A
		INCF	CEXreg+1
SelectChannel2
		; Load CEXreg into the table pointer
		MOVFF	CEXreg,TBLPTRL
		MOVFF	CEXreg+1,TBLPTRH
		CLRF	TBLPTRU
		; Load CEXreg with the table pointer contents...
		TBLRD*+
		MOVFF	TABLAT,CEXreg
		TBLRD*+
		MOVFF	TABLAT,CEXreg+1
		GOTO	SelectChannel4
	; Check for Option button
SelectChannel3
		CALL	CalSaveAndExit
		CALLF	Option
		BTFSS	ALUSTA,C
		GOTO	SelectChannel4
	; The option button  has been pressed. Advance the table
	; pointer to the parameters at the end of the record.
		MOVLW	D'9'
		ADDWF	CEXreg
		BTFSC	ALUSTA,C
		INCF	CEXreg+1
		; Load CEXreg into the table pointer
		MOVFF	CEXreg,TBLPTRL
		MOVFF	CEXreg+1,TBLPTRH
		CLRF	TBLPTRU
		; Load the variable...
		TBLRD*+
		MOVFF	TABLAT,WREG	; LSB
		RETURN

; This function tests the position of the Aileron stick. The aileron
; center position is read on powerup and saved in AilCenter, this value
; is used by this routine.
;
; The status is returned in the C and Z flags:
;    C set for Left
;    Z set for Right
Aileron
	; Read ADC channel 4
		CALLFL	ADCread,ADCail
		CALLFL	ADCread,ADCail
	; Subtract the center position, and save the result in the ADC regs
		MOVFF   AilCenter,WREG
		SUBWF   ADRESL,F,A
		MOVFF   AilCenter+1,WREG
		SUBWFB  ADRESH,F,A
	; If positive then Left...
		BTFSC   ADRESH,7,A
		GOTO 	Aileron1
		; Now subtract the threshold value
		MOVLW   LOW StickThres
		SUBWF   ADRESL,F,A
		MOVLW   HIGH StickThres
		SUBWFB  ADRESH,F,A
		; If its Positive then clear flags and exit
		BTFSC   ADRESH,7,A
		GOTO 	Aileron2
		BSF	ALUSTA,Z,A
		BCF	ALUSTA,C,A
		RETURN
Aileron1
	; if negative then right
		; Now add the threshold value
		MOVLW   LOW StickThres
		ADDWF   ADRESL,F,A
		MOVLW   HIGH StickThres
		ADDWFC   ADRESH,F,A
		; If its negative then clear flags and exit
		BTFSS   ADRESH,7,A
		GOTO 	Aileron2
		BCF	ALUSTA,Z,A
		BSF	ALUSTA,C,A
		RETURN
Aileron2
		BCF	ALUSTA,Z,A
		BCF	ALUSTA,C,A
		RETURN

; This function tests the position of the Elevator stick.
; The status is returned in the C and Z flags:
;    C set for DOWN
;    Z set for UP
Elevator
	; Read ADC channel 5
		CALLFL	ADCread,ADCele
		CALLFL	ADCread,ADCele
	; Subtract the center position, and save the result in the ADC regs
		MOVFF   EleCenter,WREG
		SUBWF   ADRESL,F,A
		MOVFF   EleCenter+1,WREG
		SUBWFB  ADRESH,F,A
	; If positive then UP...
		BTFSC   ADRESH,7,A
		GOTO 	Elevator1
		; Now subtract the threshold value
		MOVLW   LOW StickThres
		SUBWF   ADRESL,F,A
		MOVLW   HIGH StickThres
		SUBWFB  ADRESH,F,A
		; If its negative then clear flags and exit
		BTFSC   ADRESH,7,A
		GOTO 	Elevator2
		; Save the value over the threshold for use in the variable value increment speed
		BCF	ALUSTA,C,A	; Divide by 2
		RRCF	ADRESH,F,A
		RRCF	ADRESL,F,A
		BCF	ALUSTA,C,A	; Divide by 2
		RRCF	ADRESH,F,A
		RRCF	ADRESL,F,A
		
		TSTFSZ	ADRESH,A
		SETF	ADRESL,A
		MOVFF	ADRESL,IncTime
		BSF	ALUSTA,Z,A
		BCF	ALUSTA,C,A
		RETURN
Elevator1
	; if negative then DOWN
		; Now add the threshold value
		MOVLW   LOW StickThres
		ADDWF   ADRESL,F,A
		MOVLW   HIGH StickThres
		ADDWFC  ADRESH,F,A
		; If its positive then clear flags and exit
		BTFSS   ADRESH,7,A
		GOTO 	Elevator2
		; Save the value over the threshold for use in the variable value increment speed
		BSF	ALUSTA,C,A	; Divide by 2
		RRCF	ADRESH,F,A
		RRCF	ADRESL,F,A
		BSF	ALUSTA,C,A	; Divide by 2
		RRCF	ADRESH,F,A
		RRCF	ADRESL,F,A

		COMF	ADRESL,F,A
		COMF	ADRESH,F,A
		TSTFSZ	ADRESH,A
		SETF	ADRESL,A
		MOVFF	ADRESL,IncTime
		BCF	ALUSTA,Z,A
		BSF	ALUSTA,C,A
		RETURN
Elevator2
		BCF	ALUSTA,Z,A
		BCF	ALUSTA,C,A
		RETURN

; 
; This function is used to ask the pilot if he/she would like to apply the edited parameter
; to all aircraft settings. This function will return with the carry flag indicating the
; pilots selection.
;
; Carry flag
;
;	Set = yes selected
;
ApplyToAll
	; Display message on display
		CALLFL	LCDsendCMD,LINE1
		PrintMess MES29
		CALLFL	LCDsendCMD,LINE2
		PrintMess MES7
	; Get user selection
		CALL	YesNo
		RETURN

; Generic apply to all aircraft function
ATLpost
	; Ask user if he/she would like to apply to all
		CALL	ApplyToAll
		BTFSS	ALUSTA,C
		RETURN
	; Here to apply to all aircraft
		CALLFL	LCDsendCMD,LINE2
		PrintMess MES30
		CALL	FlashAllAircraft
		RETURN                     

; This section contains the routines that support each of the calibration
; options. 

;***************
CalSelectAircraft
;***************
		GOTO	SelectAircraft

;***************
CalAircraftName
;***************
		CALLFL	LCDsendCMD,LINE1
		PrintMess CALMES2
		GOTO	AircraftName

;***************
CalTimer
;***************
		MOVEC	CALMES3,CalOption
		MOVEC	MTIMER1,CalMenu
		CALL	CalUI
	; Save the parameters and exit
CalSaveExit
		CALLF	SaveGeneral
		MOVFF	Aircraft,WREG	; Load aircraft number
		CALL	SaveAircraft
		CALL	BackupAircraft
		RETURN

;***************
CalSnap
;***************
		MOVEC	CALMES4,CalOption
		MOVEC	SNAP1,CalMenu
		CALL	CalUI
		GOTO	CalSaveExit

;***************
CalServos
;***************
		MOVEC	CALMES5,CalOption
		MOVEC	SCHNMES1,CalMenu
		CALL	CalUI
		GOTO	CalSaveExit
		
;***************
CalMixers
;***************
		MOVEC	CALMES6,CalOption
		MOVEC	FMIX1,CalMenu
		CALL	CalUI
		GOTO	CalSaveExit
		
;***************
CalSwitch
;***************
		MOVEC	CALMES7,CalOption
		MOVEC	SWFUN1,CalMenu
		CALL	CalUI
		GOTO	CalSaveExit
		
;***************
CalOptions
;***************
		MOVLR	HIGH Mto
		CLRF	Mto
		MOVEC	CALMES8,CalOption
		MOVEC	COP1,CalMenu
		CALL	CalUI
		GOTO	CalSaveExit
		
;***************
CalSystemSetup
;***************
		MOVEC	CALMES10,CalOption
		MOVEC	SYS1,CalMenu
		CALL	CalUI
		GOTO	CalSaveExit
		
;***************
CalSelectFrequency
;***************
		GOTO	SelectFrequency
		
;***************
CalAdvanced
;***************
		MOVEC	CALMES12,CalOption
		MOVEC	ADV1,CalMenu
		CALL	CalUI
		GOTO	CalSaveExit

;***************
CalHelicopter
;***************
	; Move all the table pointers to the lower nibble for the UI routines
		MOVLB	HIGH HTht
		SWAPF	HTht
		SWAPF	HPitch
		SWAPF	HthtPitch
		SWAPF	Hst1Tht
		SWAPF	Hst1Pitch
		SWAPF	Hst2Tht
		SWAPF	Hst2Pitch
	; Call the UI routines
		MOVEC	CALMES13,CalOption
		MOVEC	HELI1,CalMenu
		CALL	CalUI
	; Move all the table pointers to the high nibble for the run time code
		MOVLB	HIGH HTht
		SWAPF	HTht
		SWAPF	HPitch
		SWAPF	HthtPitch
		SWAPF	Hst1Tht
		SWAPF	Hst1Pitch
		SWAPF	Hst2Tht
		SWAPF	Hst2Pitch
	; Done!
		GOTO	CalSaveExit
		


; This is the generic calibration user interface processing routine.
; This function will allow menu nesting up to three levels. This function
; is called after the user select the option he wishes to use. All of the
; selected option's parameters are processed by this code. 
CalUI               
	; Clear the DriveCh in case its not needed
		MOVLW	0
		MOVFF	WREG,DriveCh
	; Display the Calibration Selection
		CALL	DisplayCalibration
	; Load menu pointer              
		MOVE16	CalMenu,AXreg
	        CALL	SelectionFunction
	        MOVE16	AXreg,CalMenu  
	        MOVE16	PostCall,PostCallLevel1
		; If CXreg contains 9, then BXreg points to another selection table
		MOVLB	HIGH CXreg
		MOVF	CXreg,WREG
		XORLW	9
		BTFSS	ALUSTA,Z,A
		GOTO	CUI2
	        ; Here to process a selection table, nesting level of 2
		 MOVE16	BXreg,AXreg
CUI3
	         CALL	SelectionFunction 
	         MOVE16	AXreg,CalMenu1 
	         MOVE16	PostCall,PostCallLevel2
		 ; If CXreg contains 9, then BXreg points to another selection table
		 MOVLB	HIGH CXreg
		 MOVF	CXreg,WREG
		 XORLW	9
		 BTFSS	ALUSTA,Z,A
		 GOTO	CUI4
	         ; Here to process a selection table, nesting level of 3
		 MOVE16	BXreg,AXreg
CUI5
	         CALL	SelectionFunction 
	         MOVE16	AXreg,CalMenu2 
	         MOVE16	PostCall,PostCallLevel3
		 CALL	Input 
	         ; If EXIT flag is exit, RETURN 
	         MOVLB	HIGH EXIT
	         BTFSC	EXIT,0
	         GOTO	CUI4a 
	         MOVE16	PostCallLevel3,BXreg
	         CALL	CallBXreg 
		 MOVE16	CalMenu2,AXreg    
		 GOTO	CUI5	        
CUI4	        
		 CALL	Input 
	         ; If EXIT flag is exit, RETURN 
	         MOVLB	HIGH EXIT
	         BTFSC	EXIT,0
	         GOTO	CUI2a 
CUI4a 
	         MOVE16	PostCallLevel2,BXreg
	         CALL	CallBXreg 
		 ; Restore the top line of the display from TrackMenu
		 MOVE16	CalMenu,AXreg 
		 CALLF	LCDsendAX   
		 MOVE16	CalMenu1,AXreg 
		 GOTO	CUI3
CUI2	
	        CALL	Input
	        ; If EXIT flag is exit, RETURN 
	        MOVLB	HIGH EXIT
	        BTFSC	EXIT,0
	        RETURN
CUI2a
	        MOVE16	PostCallLevel1,BXreg
	        CALL	CallBXreg 
	        GOTO	CalUI       
		RETURN

; User interface include files....		

	Include	<SelAft.asm>
	Include	<AftName.asm>
	Include	<Servo.asm>
	Include	<Mixers.asm>
	Include	<Options.asm>
	Include	<System.asm>
	Include	<SelFreq.asm>
	Include	<Advanced.asm>

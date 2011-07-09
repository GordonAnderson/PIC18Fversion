; DigitalTrims.asm
;
; This file contains the routines used to support Digital Trims on the MicroStar.
; The second line of the display shows the trim position the top line shows the
; trim function being displayed.

; This function is called at powerup to initalize the digital trim
; variables.
DigitalTrimInit
	MOVEC	0,DTdataAil
	MOVEC	0,DTdataEle
	MOVEC	0,DTdataRud
	MOVEC	0,DTdataTht
	MOVLW	0
	MOVFF	WREG,DTdisplay
	RETURN

; This is the digital trim processing code that is called in the main run
; loop of the microstar application. This routine processes the digital
; trim requests from all channels.
ProcessDtrims
   ; Test the selected aileron trim, if not digital move to elevator test
	MOVFF	AilTrimCh,WREG
	ANDLW	0xF0
	BZ	PDele
   ; Here if its a digital trim
	SWAPF	WREG			; Analog trim number to use
   ; Process aileron ditital trim, read the trim switch
   	CALL	TestTrim		; Read the trim switch position using analog
					; trim number in WREG
   	MOVLR	HIGH DTdataAil
   	SWAPF	DTdataAil
   	BCF	DTdataAil,0
   	BCF	DTdataAil,1
	BTFSC	ALUSTA,C
	BSF	DTdataAil,0
	BTFSC	ALUSTA,Z
	BSF	DTdataAil,1
	; Process this trim with the generic routine
	MOVE	DTdataAil,AXreg
	MOVE	DTail,BXreg
	CALL	DigitalTrim
	MOVE	BXreg,DTail
	MOVE	AXreg,DTdataAil
   	; If carry flag is set then update the trim value
   	BTFSS	ALUSTA,C
	GOTO	PD0
	MOVE	DTail,BXreg
	MOVLW	LOW DTail
	MOVFF	WREG,AXreg
	CLRF	WREG
	MOVFF	WREG,AXreg+1
	CALL	EEPROMwriteWord
PD0
   	; If timer is non zero then set the display flag and exit
   	MOVFF	DTdataAil+1,WREG
   	IORWF	WREG
   	BTFSS	ALUSTA,Z
   	MOVLW	1
   	MOVFF	WREG,DTdisplay
   	TSTFSZ	WREG
   	RETURN
PDele
   ; Test the selected elevator trim, if not digital move to rudder test
	MOVFF	EleTrimCh,WREG
	ANDLW	0xF0
	BZ	PDrud
   ; Here if its a digital trim
	SWAPF	WREG			; Analog trim number to use
   ; Process elevator ditital trim, read the trim switch
   	CALL	TestTrim		; Read the trim switch position using analog
					; trim number in WREG
   	MOVLR	HIGH DTdataEle
   	SWAPF	DTdataEle
   	BCF	DTdataEle,0
   	BCF	DTdataEle,1
	BTFSC	ALUSTA,C
	BSF	DTdataEle,0
	BTFSC	ALUSTA,Z
	BSF	DTdataEle,1
	; Process this trim with the generic routine
	MOVE	DTdataEle,AXreg
	MOVE	DTele,BXreg
	CALL	DigitalTrim
	MOVE	BXreg,DTele
	MOVE	AXreg,DTdataEle
   	; If carry flag is set then update the trim value
   	BTFSS	ALUSTA,C
	GOTO	PD1
	MOVE	DTele,BXreg
	MOVLW	LOW DTele
	MOVFF	WREG,AXreg
	CLRF	WREG
	MOVFF	WREG,AXreg+1
	CALL	EEPROMwriteWord
PD1
   	; If timer is non zero then set the display flag and exit
   	MOVFF	DTdataEle+1,WREG
   	IORWF	WREG
   	BTFSS	ALUSTA,Z
   	MOVLW	2
   	MOVFF	WREG,DTdisplay
   	TSTFSZ	WREG
   	RETURN
PDrud
   ; Test the selected rudder trim, if not digital move to throttle test
	MOVFF	RudTrimCh,WREG
	ANDLW	0xF0
	BZ	PDtht
   ; Here if its a digital trim
	SWAPF	WREG			; Analog trim number to use
   ; Process rudder ditital trim, read the trim switch
   	CALL	TestTrim		; Read the trim switch position using analog
					; trim number in WREG
   	MOVLR	HIGH DTdataRud
   	SWAPF	DTdataRud
   	BCF	DTdataRud,0
   	BCF	DTdataRud,1
	BTFSC	ALUSTA,C
	BSF	DTdataRud,0
	BTFSC	ALUSTA,Z
	BSF	DTdataRud,1
	; Process this trim with the generic routine
	MOVE	DTdataRud,AXreg
	MOVE	DTrud,BXreg
	CALL	DigitalTrim
	MOVE	BXreg,DTrud
	MOVE	AXreg,DTdataRud
   	; If carry flag is set then update the trim value
   	BTFSS	ALUSTA,C
	GOTO	PD2
	MOVE	DTrud,BXreg
	MOVLW	LOW DTrud
	MOVFF	WREG,AXreg
	CLRF	WREG
	MOVFF	WREG,AXreg+1
	CALL	EEPROMwriteWord
PD2
   	; If timer is non zero then set the display flag and exit
   	MOVFF	DTdataRud+1,WREG
   	IORWF	WREG
   	BTFSS	ALUSTA,Z
   	MOVLW	3
   	MOVFF	WREG,DTdisplay
   	TSTFSZ	WREG
   	RETURN
PDtht
   ; Test the selected throttle trim, if not digital exit
	MOVFF	ThtTrimCh,WREG
	ANDLW	0xF0
	BZ	PDexit
   ; Here if its a digital trim
	SWAPF	WREG			; Analog trim number to use
   ; Process throttle ditital trim, read the trim switch
   	CALL	TestTrim		; Read the trim switch position using analog
					; trim number in WREG
   	MOVLR	HIGH DTdataTht
   	SWAPF	DTdataTht
   	BCF	DTdataTht,0
   	BCF	DTdataTht,1
	BTFSC	ALUSTA,C
	BSF	DTdataTht,0
	BTFSC	ALUSTA,Z
	BSF	DTdataTht,1
	; Process this trim with the generic routine
	MOVE	DTdataTht,AXreg
	MOVE	DTtht,BXreg
	CALL	DigitalTrim
	MOVE	BXreg,DTtht
	MOVE	AXreg,DTdataTht
   	; If carry flag is set then update the trim value
   	BTFSS	ALUSTA,C
	GOTO	PD3
	MOVE	DTtht,BXreg
	MOVLW	LOW DTtht
	MOVFF	WREG,AXreg
	CLRF	WREG
	MOVFF	WREG,AXreg+1
	CALL	EEPROMwriteWord
PD3
   	; If timer is non zero then set the display flag and exit
   	MOVFF	DTdataTht+1,WREG
   	IORWF	WREG
   	BTFSS	ALUSTA,Z
   	MOVLW	4
   	MOVFF	WREG,DTdisplay
   ; Exit!
PDexit
   	RETURN


; This function tests the trim value defined in reg WREG. The BXreg contains the analog
; trim channel's normalized value. This value is used as the digital trim input by
; setting the value to the two analog trim extreams with a center off switch.
;
; On call
;	WREG = Analog trim control used for this digital trim channel
; On return
;	C flag set for right/down
;	Z flag set for left/up
TestTrim
   ; Load BXreg with the referenced analog trim channel
	MOVWF	FSR1L		; Build pointer to analog trim location
	DECF	FSR1L,F,A
	BCF	ALUSTA,C
	RLCF	FSR1L,F,A
	MOVLW	HIGH Atrim
	MOVWF	FSR1H,A
	MOVLW	LOW Atrim
	ADDWF	FSR1L,F,A
	MOVF	POSTINC1,W	; Load value into BXreg
	MOVFF	WREG,BXreg
	MOVF	POSTINC1,W
	MOVFF	WREG,BXreg+1
   ; Test BXreg sign
   	MOVLR	HIGH BXreg
   	BTFSC	BXreg+1,7
   	GOTO	TT0
   ; Here if positive, sub 512, if still pos set Carry flag and exit
   	MOVLW	2
   	SUBWF	BXreg+1
   	BCF	ALUSTA,Z
	RETURN   
   ; Here if negative, add 512, if still neg set z flag and exit
TT0
   	MOVLW	2
   	ADDWF	BXreg+1
   	BCF	ALUSTA,Z
   	BTFSS	ALUSTA,C
   	BSF	ALUSTA,Z
   	BCF	ALUSTA,C
	RETURN

; This is a generic routine that process a digitial trim. This function is
; called at the the transmitters framming rate. It is assumed this routine 
; is called from the main run loop of the encoder.
;
; On call:
;		AXreg = flag byte, bit 0 = right/down
;				   bit 1 = left/up
;				   bit 4 = right/down, last value
;				   bit 5 = left/up, last value
;		AXreg+1 = tick counter
;		BXreg = Digital trim value 
;
; On return:
;		BXreg = updated trim position
;		C flag set if trim value was changed
; 
DigitalTrim
   ; Determine if there has been a state change on the trim inputs
   	MOVFF	AXreg,WREG
   	SWAPF	WREG
   	MOVLB	HIGH AXreg
   	XORWF	AXreg,W
   	BTFSS	ALUSTA,Z
   	GOTO	DTrim0
   ;
   ; Here if there has been no change
   ;
     ; If counter is not zero then dec and exit
   	TSTFSZ	AXreg+1
   	GOTO	DTrim1
     ; Here if counter is zero
DTrim2
     	CLRF	WREG
     	BTFSC	AXreg,0
     	MOVLW	D'25'
     	BTFSC	AXreg,1
     	MOVLW	-D'25'
     	IORWF	WREG
  	BCF	ALUSTA,C
     	BTFSC	ALUSTA,Z
     	RETURN			; Exit if nothing to do
     ; Update the trim position
     	ADDWF	BXreg,F
     	CLRF	WREG
     	BTFSC	AXreg,1
     	COMF	WREG
     	ADDWFC	BXreg+1,F
     ; Apply limits and beep
	MOVLW	D'1'  
	MOVFF	WREG,BeepCyl		; Set bit time
     	CALL	DigitalTrimLimit	; C flag set if at limit
     	MOVLW	D'1'
     	BTFSC	ALUSTA,C
     	MOVLW	D'5'
	CALL	Beep			; Beep
     ; Set the delay time and exit
     	MOVFF	DTrimAdjustDelay,AXreg+1
  	BSF	ALUSTA,C
     	RETURN
     ; Here if counter is not zero so dec and exit
DTrim1
  	DECF	AXreg+1
	BZ	DTrim2
  	BCF	ALUSTA,C
  	RETURN 
   ;
   ; Here if there has been a trim switch change
   ;
DTrim0
     ; If the switch is in the center position then set a long
     ; delay time and exit
	MOVFF	AXreg,WREG
	ANDLW	03
	BNZ	DTrim2     ; Bypass the delay and jump into the "no change" code
	MOVLW	D'80'
	MOVFF	WREG,AXreg+1
  	BCF	ALUSTA,C
     	RETURN
;
; This function tests the digital trim value saved in the BXreg and makes sure
; it is between -1000 and 1000. If its out of this range it will be set to
; the proper limit.
; Carry flag is set if the limit is reached
;
DigitalTrimLimit
   ; Test the trim to see if its positive or negative
   	MOVLR	HIGH BXreg
   	BTFSC	BXreg+1,7
   	GOTO	DTL0		
   ; Here if the trim value is positive
   	MOVLW	LOW D'1000'
   	SUBWF	BXreg,W
   	MOVLW	HIGH D'1000'
   	SUBWFB	BXreg+1,W
   	BTFSS	ALUSTA,C
   	RETURN
   	; Over 1000 so set to 1000 and exit
   	MOVEC	D'1000',BXreg
   	BSF	ALUSTA,C
   	RETURN
   ; Here if the trim value is negative   	
DTL0
   	MOVLW	LOW D'1000'
   	ADDWF	BXreg,W
   	MOVLW	HIGH D'1000'
   	ADDWFC	BXreg+1,W
	BTG	ALUSTA,C
   	BTFSS	ALUSTA,C
   	RETURN
   	; Over 1000 so set to 1000 and exit
   	MOVEC	-D'1000',BXreg
   	BSF	ALUSTA,C
   	RETURN


; Line 1 text messages for the trims
DTmess
	DB	"L Aileron Trim R"
	DB	"U ElevatorTrim D"
	DB	"L Rudder  Trim R"
	DB	"L ThrottleTrim H"
	
; This function will display the trim position on a 2 line by 16 character display.
; The first line defines the trim being displayed and the second line shows the
; trim position. On call the following registers are assumed to contain valid
; data:
;	WREG = Trim channel; 1=ALI,2=ELE,3=RUD,4=THT
;	DTail = 16 bit digital trim value for aileron
;	DTele = 16 bit digital trim value for elevator
;	DTrud = 16 bit digital trim value for rudder
;	DTtht = 16 bit digital trim value for throttle
DisplayTrim
   ; Display the description text on line 1
	MOVFF	WREG,Atemp	; save for later
	; Build pointer to message
	MOVEC	DTmess,AXreg
	MOVFF	Atemp,WREG
	DECF	WREG
	SWAPF	WREG		; This will multiply by 16 and make index into an offset
	MOVLB	HIGH AXreg
	ADDWF	AXreg,F
	BTFSC	ALUSTA,C
	INCF	AXreg+1
	; Now print the first line of the display
	CALL	LCDsendAX
   ; Load the selected trim into AXreg
	MOVFF	Atemp,WREG
	MOVWF	FSR1L		; Build pointer to digital trim location
	DECF	FSR1L,F,A
	BCF	ALUSTA,C
	RLCF	FSR1L,F,A
	MOVLW	HIGH DTail
	MOVWF	FSR1H,A
	MOVLW	LOW DTail
	ADDWF	FSR1L,F,A
	MOVF	POSTINC1,W	; Load value into AXreg
	MOVFF	WREG,AXreg
	MOVF	POSTINC1,W
	MOVFF	WREG,AXreg+1
   ; Paint the trim position on second line
	CALL	PaintRightBar
	CALL	PaintLeftBar
	RETURN

ifndef           SED1230display
; The trim position is in AXreg when this function is called. The trim position
; vaires from -1000 to 1000. Right bar values are positive and each pixel position
; indicates a trim change of 25 units. This function will update the right side
; of the display on the second line.
PaintRightBar
   ; If the trim value is negative, clear the right side of the display and exit
	MOVLB	HIGH AXreg
	BTFSS	AXreg+1,7
   	GOTO	PRB3
   ; Clear the right side of the display
   	MOVLW	LINE2+LCDRIGHT		; Cursor to center
	CALL	LCDsendCMD	
	CLRF	WREG		; The zero mark
	CALL	LCDsendData   
	; Send 7 spaces
	PrintMess MES9
   	RETURN
PRB3
   ; Set up the character generator for this direction
   	NoAddCorrection
   	MOVLW	40 + 7 * 8
   	CALL	LCDsendCMD
   	MOVLW	D'8'
   	PrintMessN	HCGtbl + 8 * 8
   	MOVLW	40 + 3 * 8
   	CALL	LCDsendCMD
   	MOVLW	D'8'
   	PrintMessN	HCGtbl + 3 * 8
   ; Determine the number of bars to light.
   	MOVE	AXreg,CEXreg
   	MOVLW	D'125'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168	; Divide trim value by 125, one full character position
   	MOVFF	CEXreg,BXreg	; This is the number of character position to "light up"
   	MOVFF	EEXreg,CEXreg	; Now divide the remainder by 25 to get the number of
   				; bars to "light up" in the last character position
   	MOVLB	HIGH CEXreg
   	CLRF	CEXreg+1
   	MOVLW	D'25'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168
   	MOVFF	CEXreg,BXreg+1	; Number of bars
   ; "Light up" the display.
	; Center the display cursor
   	MOVLW	LINE2+LCDRIGHT
	CALL	LCDsendCMD	
   	; Loop through all 8 character positions
   	MOVLW	8
   	MOVFF	WREG,Areg
   	MOVLB	HIGH BXreg
   	INCF	BXreg		; Advance the character counter
PRB0
	BCF	STATUS,Z	; Clear the zero flag
	TSTFSZ	BXreg
	DECF	BXreg		; Dec BXreg if its not 0
	BNZ	PRB1
	; Here if the char count went to zero
	MOVFF	BXreg+1,WREG
	DECF	WREG
	BNC	PRB1
	CALL	LCDsendData
	GOTO	PRB2
PRB1
	; Here to clear or fill a character position
	MOVLW	' '		; Assume this position is clear
	TSTFSZ	BXreg
	MOVLW	07		; Lite up the position
	CALL	LCDsendData	; Set the value
PRB2
   	DECF	Areg,F,A
   	BNZ	PRB0
   ; Exit, done!
   	AddCorrection
	RETURN
	


; The trim position is in AXreg when this function is called. The trim position
; vaires from -1000 to 1000. Left bar values are negative and each pixel position
; indicates a trim change of 25 units. This function will update the left side
; of the display on the second line.
PaintLeftBar
   	NoAddCorrection
   ; Set the display cursor advance to the left
	MOVLW	04
	CALL	LCDsendCMD   
   ; If the trim value is positive, clear the left side of the display and exit
	MOVLB	HIGH AXreg
	MOVFF	AXreg,WREG
	IORWF	AXreg+1,W
	BZ	PLB4		; If trim is zero then clear the left side of display
	BTFSC	AXreg+1,7
   	GOTO	PLB3
   ; Clear the left side of the display
PLB4
   	MOVLW	LINE2+7		; Cursor to center
	CALL	LCDsendCMD	
	MOVLW	4		; The zero mark
	CALL	LCDsendData   
	; Send 7 spaces
	PrintMess MES9
   ; reset the display cursor advance to the right
	MOVLW	06
	CALL	LCDsendCMD   
   	AddCorrection
   	RETURN
PLB3
   ; Set the display cursor advance to the right
	MOVLW	06
	CALL	LCDsendCMD   
   ; Set up the character generator for this direction
   	MOVLW	40 + 3 * 8
   	CALL	LCDsendCMD
   	MOVLW	D'8'
   	PrintMessN	HCGtbl + 8 * 8
   	MOVLW	40 + 7 * 8
   	CALL	LCDsendCMD
   	MOVLW	D'8'
   	PrintMessN	HCGtbl + 7 * 8
   ; Set the display cursor advance to the left
	MOVLW	04
	CALL	LCDsendCMD   
   ; Determine the number of bars to light.
   	MOVE	AXreg,CEXreg
   	MOVLW	-D'125'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168	; Divide trim value by 125, one full character position
   	MOVFF	CEXreg,BXreg	; This is the number of character position to "light up"
   	MOVFF	EEXreg,CEXreg	; Now divide the remainder by 25 to get the number of
   				; bars to "light up" in the last character position
   	MOVLB	HIGH CEXreg
   	CLRF	CEXreg+1
   	MOVLW	D'25'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168
   	MOVFF	CEXreg,BXreg+1	; Number of bars
   ; "Light up" the display.
	; Center the display cursor
   	MOVLW	LINE2+7
	CALL	LCDsendCMD	
   	; Loop through all 8 character positions
   	MOVLW	8
   	MOVFF	WREG,Areg
   	MOVLB	HIGH BXreg
   	INCF	BXreg		; Advance the character counter
PLB0
	BCF	STATUS,Z	; Clear the zero flag
	TSTFSZ	BXreg
	DECF	BXreg		; Dec BXreg if its not 0
	BNZ	PLB1
	; Here if the char count went to zero
	MOVFF	BXreg+1,WREG
	DECF	WREG
	BNC	PLB1
	ADDLW	4
	CALL	LCDsendData
	GOTO	PLB2
PLB1
	; Here to clear or fill a character position
	MOVLW	' '		; Assume this position is clear
	TSTFSZ	BXreg
	MOVLW	03		; Lite up the position
	CALL	LCDsendData	; Set the value
PLB2
   	DECF	Areg,F,A
   	BNZ	PLB0
   ; Exit, done!
   ; reset the display cursor advance to the right
	MOVLW	06
	CALL	LCDsendCMD   
   	AddCorrection
	RETURN

; The position is in AXreg when this function is called. The position
; vaires from 0 to 1000. Right bar values are positive and each pixel position
; indicates a position change in 12.5 units. This function will use the full range
; of the display on the second line.
PaintBar
   ; If the trim value is negative, clear the display and exit
	MOVLB	HIGH AXreg
	BTFSS	AXreg+1,7
   	GOTO	PB3
   ; Clear the display
   	MOVLW	LINE2		; Cursor to center
	CALL	LCDsendCMD	
	CLRF	WREG		; The zero mark
	CALL	LCDsendData   
	; Send 16 spaces
	PrintMess MES0
   	RETURN
PB3
   ; Set up the character generator for this direction
   	NoAddCorrection
   	MOVLW	40 + 7 * 8
   	CALL	LCDsendCMD
   	MOVLW	D'8'
   	PrintMessN	HCGtbl + 8 * 8
   	MOVLW	40 + 3 * 8
   	CALL	LCDsendCMD
   	MOVLW	D'8'
   	PrintMessN	HCGtbl + 3 * 8
   	AddCorrection
   ; Determine the number of bars to light.
   	MOVE	AXreg,CEXreg
   	MOVLW	D'63'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168	; Divide pos value by 63, one full character position
   	MOVFF	CEXreg,BXreg	; This is the number of character position to "light up"
   	MOVFF	EEXreg,CEXreg	; Now divide the remainder by 13 to get the number of
   				; bars to "light up" in the last character position
   	MOVLB	HIGH CEXreg
   	CLRF	CEXreg+1
   	MOVLW	D'13'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168
   	MOVFF	CEXreg,BXreg+1	; Number of bars
   ; "Light up" the display.
	; Center the display cursor
   	MOVLW	LINE2
	CALL	LCDsendCMD	
   	; Loop through all 16 character positions
   	MOVLW	16
   	MOVFF	WREG,Areg
   	MOVLB	HIGH BXreg
   	INCF	BXreg		; Advance the character counter
PB0
	BCF	STATUS,Z	; Clear the zero flag
	TSTFSZ	BXreg
	DECF	BXreg		; Dec BXreg if its not 0
	BNZ	PB1
	; Here if the char count went to zero
	MOVFF	BXreg+1,WREG
	DECF	WREG
	BNC	PB1
	CALL	LCDsendData
	GOTO	PB2
PB1
	; Here to clear or fill a character position
	MOVLW	' '		; Assume this position is clear
	TSTFSZ	BXreg
	MOVLW	07		; Lite up the position
	CALL	LCDsendData	; Set the value
PB2
   	DECF	Areg,F,A
   	BNZ	PB0
   ; Exit, done!
	RETURN
endif
	
ifdef           SED1230display
; The trim position is in AXreg when this function is called. The trim position
; vaires from -1000 to 1000. Right bar values are positive and each pixel position
; indicates a trim change of 25 units. This function will update the right side
; of the display on the second line.
PaintRightBar
   ; If the trim value is negative, clear the right side of the display and exit
	MOVLB	HIGH AXreg
	BTFSS	AXreg+1,7
   	GOTO	PRB3
   ; Clear the right side of the display
   	MOVLW	LINE2+LCDRIGHT		; Cursor to center
	CALL	LCDsendCMD	
	MOVLW	0		; The zero mark
	CALL	LCDsendData   
	; Send 7 spaces
	PrintMess MES9
   	RETURN
PRB3
   ; Determine the number of bars to light.
   	MOVE	AXreg,CEXreg
   	MOVLW	D'125'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168	; Divide trim value by 125, one full character position
   	MOVFF	CEXreg,BXreg	; This is the number of character position to "light up"
   	MOVFF	EEXreg,CEXreg	; Now divide the remainder by 25 to get the number of
   				; bars to "light up" in the last character position
   	MOVLB	HIGH CEXreg
   	CLRF	CEXreg+1
   	MOVLW	D'25'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168
   	MOVFF	CEXreg,BXreg+1	; Number of bars
   ; "Light up" the display.
	; Center the display cursor
   	MOVLW	LINE2+LCDRIGHT
	CALL	LCDsendCMD	
   	; Loop through all 8 character positions
   	MOVLW	8
   	MOVFF	WREG,Areg
   	MOVLB	HIGH BXreg
   	INCF	BXreg		; Advance the character counter
PRB0
	BCF	STATUS,Z	; Clear the zero flag
	TSTFSZ	BXreg
	DECF	BXreg		; Dec BXreg if its not 0
	BNZ	PRB1
	; Here if the char count went to zero
	MOVFF	BXreg+1,WREG
	DECF	WREG
	BNC	PRB1
	ADDLW	081
	CALL	LCDsendData
	GOTO	PRB2
PRB1
	; Here to clear or fill a character position
	MOVLW	' '		; Assume this position is clear
	TSTFSZ	BXreg
	MOVLW	0FF		; Lite up the position
	CALL	LCDsendData	; Set the value
PRB2
   	DECF	Areg,F,A
   	BNZ	PRB0
   ; Exit, done!
	RETURN
	


; The trim position is in AXreg when this function is called. The trim position
; vaires from -1000 to 1000. Left bar values are negative and each pixel position
; indicates a trim change of 25 units. This function will update the left side
; of the display on the second line.
PaintLeftBar
   ; If the trim value is positive, clear the left side of the display and exit
	MOVLB	HIGH AXreg
	MOVFF	AXreg,WREG
	IORWF	AXreg+1,W
	BZ	PLB4		; If trim is zero then clear the left side of display
	BTFSC	AXreg+1,7
   	GOTO	PLB3
   ; Clear the left side of the display
PLB4
   	MOVLW	LINE2		; Cursor to left
	CALL	LCDsendCMD	
	; Send 7 spaces
	PrintMess MES9
	MOVLW	1		; The zero mark
	CALL	LCDsendData   
   	RETURN
PLB3
   ; Determine the number of bars to light.
   	MOVE	AXreg,CEXreg
   	MOVLW	-D'125'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168	; Divide trim value by 125, one full character position
   	MOVFF	CEXreg,WREG	; This is the number of character position to "light up"
	SUBLW	8
	BTFSS	ALUSTA,C
	MOVLW	0		; Set to zero if it went negative
	MOVFF	WREG,BXreg
   	MOVFF	EEXreg,CEXreg	; Now divide the remainder by 25 to get the number of
   				; bars to "light up" in the last character position
   	MOVLB	HIGH CEXreg
   	CLRF	CEXreg+1
   	MOVLW	D'25'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168
   	MOVFF	CEXreg,BXreg+1	; Number of bars
   ; "Light up" the display.
	; Start at the far left, the first character
   	MOVLW	LINE2
	CALL	LCDsendCMD	
   	; Loop through all 8 character positions
   	MOVLW	8
   	MOVFF	WREG,Areg
   	MOVLB	HIGH BXreg
;   	DECF	BXreg		; Advance the character counter
PLB0
	BCF	STATUS,Z	; Clear the zero flag
	TSTFSZ	BXreg
	DECF	BXreg		; Dec BXreg if its not 0
	BNZ	PLB1
	; Here if the char count went to zero
	MOVFF	BXreg+1,WREG
	DECF	WREG
	BNC	PLB1a
	ADDLW	081
	CALL	LCDsendData
	GOTO	PLB2
PLB1
	; Here to clear or fill a character position
	MOVLW	0FF		; Light up this position
	TSTFSZ	BXreg
PLB1a	MOVLW	' '		; Clear the position
	CALL	LCDsendData	; Set the value
PLB2
   	DECF	Areg,F,A
   	BNZ	PLB0
   ; Exit, done!
   ; reset the display cursor advance to the right
	MOVLW	06
	CALL	LCDsendCMD   
	RETURN

; The position is in AXreg when this function is called. The position
; vaires from 0 to 1000. Right bar values are positive and each pixel position
; indicates a position change in 12.5 units. This function will use the full range
; of the display on the second line.
PaintBar
   ; If the trim value is negative, clear the display and exit
	MOVLB	HIGH AXreg
	BTFSS	AXreg+1,7
   	GOTO	PB3
   ; Clear the display
   	MOVLW	LINE2		; Cursor to center
	CALL	LCDsendCMD	
	CLRF	WREG		; The zero mark
	CALL	LCDsendData   
	; Send 16 spaces
	PrintMess MES0
   	RETURN
PB3
   ; Determine the number of bars to light.
   	MOVE	AXreg,CEXreg
   	MOVLW	D'63'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168	; Divide pos value by 63, one full character position
   	MOVFF	CEXreg,BXreg	; This is the number of character position to "light up"
   	MOVFF	EEXreg,CEXreg	; Now divide the remainder by 13 to get the number of
   				; bars to "light up" in the last character position
   	MOVLB	HIGH CEXreg
   	CLRF	CEXreg+1
   	MOVLW	D'13'
   	MOVFF	WREG,DEXreg
   	CALL	Divide168
   	MOVFF	CEXreg,BXreg+1	; Number of bars
   ; "Light up" the display.
	; Center the display cursor
   	MOVLW	LINE2
	CALL	LCDsendCMD	
   	; Loop through all 16 character positions
   	MOVLW	16
   	MOVFF	WREG,Areg
   	MOVLB	HIGH BXreg
   	INCF	BXreg		; Advance the character counter
PB0
	BCF	STATUS,Z	; Clear the zero flag
	TSTFSZ	BXreg
	DECF	BXreg		; Dec BXreg if its not 0
	BNZ	PB1
	; Here if the char count went to zero
	MOVFF	BXreg+1,WREG
	DECF	WREG
	BNC	PB1
	ADDLW	081
	CALL	LCDsendData
	GOTO	PB2
PB1
	; Here to clear or fill a character position
	MOVLW	' '		; Assume this position is clear
	TSTFSZ	BXreg
	MOVLW	0FF		; Lite up the position
	CALL	LCDsendData	; Set the value
PB2
   	DECF	Areg,F,A
   	BNZ	PB0
   ; Exit, done!
	RETURN
endif	



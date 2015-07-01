
;
; This file contains the Mixer User Interface Pre and Post functions. The 
; Pre function is called before the selected user interface option is processed
; by the user interface routines and the Post function is called after the
; user interface routine returns. These funtions move the mixer data into
; a generic area before the user adjusts parameters and returns the data to
; the correct specific place when finished.
;

; This function is called when the Move Mixer option is selected. This function
; will prompt the pilot to select the from and to mixer channels for the move
; and then provide an option to clear or reset the from channel.
MoveMixer
	; Ask the pilot to select the from channel
		CALLFL	LCDsendCMD,LINE1
		PrintMess MES25
		MOVEC	MIXSEL1,BXreg
		MOVEC	Src,DXreg
		CALL	VerticalSelection
	; Ask the pilot to select the to channel
		CALLFL	LCDsendCMD,LINE1
		PrintMess MES26
		MOVEC	MIXSEL1,BXreg
		MOVEC	Dst,DXreg
		CALL	VerticalSelection
	; Confirm the move
		CALLFL	LCDsendCMD,LINE1
		PrintMess MES27
		CALLFL	LCDsendCMD,LINE2
		PrintMess MES7
		BCF	ALUSTA,C
		CALL	YesNo
		BTFSS	ALUSTA,C
		RETURN
		; Now do the move, first set the high bytes because VerticalSelection read one byte only
		MOVLW	HIGH M1Afrom
		MOVFF	WREG,Src+1
		MOVFF	WREG,Dst+1
		MOVLW	5
		MOVFF	WREG,Cnt
		CALL	BlkMove		
	; Ask the pilot if he/she would like to clear or reset the from channel
		CALLFL	LCDsendCMD,LINE1
		PrintMess MES28
		CALLFL	LCDsendCMD,LINE2
		PrintMess MES7
		BCF	ALUSTA,C
		CALL	YesNo
		BTFSS	ALUSTA,C
		RETURN
		; Clear the from mixer channel, enter 0,0,10,10,0
		MOVLB	HIGH Src
		MOVF	Src,W
		MOVWF	FSR1L	
		MOVF	Src+1,W
		MOVWF	FSR1H	
		MOVLW	0
		MOVFF	WREG,POSTINC1
		MOVFF	WREG,POSTINC1
		MOVLW	D'10'		
		MOVFF	WREG,POSTINC1
		MOVFF	WREG,POSTINC1
		MOVLW	0
		MOVFF	WREG,POSTINC1
		RETURN

; This is the function called before the specific mixer user interface 
; function is called. This routine moves the selected mixer data into
; the generic area and unpacks some of the data to allow the user to
; adjust the parameters.
;
; DXreg = Pointer to selected mixer data
PreMix
	; Clear the Servo Update flag
		MOVLB	HIGH CalServoUpdate
		CLRF	CalServoUpdate
	; Copy the selected mixer parameters to the working space
		MOVE16	DXreg,Src
		MOVEC	Mfrom,Dst
		MOVLW	5
		MOVWF	Cnt
		CALL	BlkMove
		MOVE16	DXreg,Dst	; Set the destination pointer for the post call
	; Calculate the necessary flags
		MOVLB	HIGH Mfrom
		; MS 4 bits of Mfrom channel define a table...
		MOVF	Mfrom,W
		SWAPF	WREG
		ANDLW	0F
		MOVWF	Mtbl
		; Bit 7 of Mto set = replace, 0 = add
		CLRF	Mreplace
		BTFSC	Mto,7
		COMF	Mreplace,F
		; Bit 6 of Mto set = indirect positive gain, channel in Mpg
		CLRF	Mpi
		MOVF	Mpg,W
		BTFSC	Mto,6
		MOVWF	Mpi
		; Bit 5 of Mto set = indirect negative gain, channel in Mng
		CLRF	Mni
		MOVF	Mng,W
		BTFSC	Mto,5
		MOVWF	Mni
		; Clear all flag bits...
		MOVLW	0F
		ANDWF	Mpi,F
		ANDWF	Mni,F
		ANDWF	Mto,F
		ANDWF	Mfrom,F
		RETURN
		
; After the user has finished editing the selected mixer and has accepted 
; his options then this routine is called. The data is repacked as needed
; by the mixer functions and the data is moved from the generic area to the
; specific mixer location.
PostMix
	; Restore all flag bits..
		MOVLB	HIGH Mfrom
		; MS 4 bits of Mfrom channel define a table...
		MOVF	Mtbl,W
		SWAPF	WREG
		ANDLW	0F0
		IORWF	Mfrom,F
		; Bit 7 of Mto set = replace, 0 = add
		BTFSC	Mreplace,7
		BSF	Mto,7
		; Bit 6 of Mto set = indirect positive gain, channel in Mpg
		MOVF	Mpi,W
		IORWF	WREG		; Set flags
		BTFSC	ALUSTA,Z
		GOTO	CMA1
		MOVF	Mpi,W
		MOVWF	Mpg
		BSF	Mto,6
		; Bit 5 of Mto set = indirect negative gain, channel in Mng
CMA1
		MOVF	Mni,W
		IORWF	WREG		; Set flags
		BTFSC	ALUSTA,Z
		GOTO	CMA2
		MOVF	Mni,W
		MOVWF	Mng
		BSF	Mto,5
CMA2
	; Write mixer data back to where it came
		MOVEC	Mfrom,Src
		MOVLW	5
		MOVWF	Cnt
		CALL	BlkMove
		RETURN
		
		
PreA2R
		MOVFF	AilRudPos,Mpg
		MOVFF	AilRudNeg,Mng
		RETURN
		
PostA2R
		MOVFF	Mpg,AilRudPos
		MOVFF	Mng,AilRudNeg
		RETURN

PreR2A
		MOVFF	RudAilPos,Mpg
		MOVFF	RudAilNeg,Mng
		RETURN
		
PostR2A
		MOVFF	Mpg,RudAilPos
		MOVFF	Mng,RudAilNeg
		RETURN
		
PreR2E
		MOVFF	RudElePos,Mpg
		MOVFF	RudEleNeg,Mng
		RETURN
		
PostR2E
		MOVFF	Mpg,RudElePos
		MOVFF	Mng,RudEleNeg
		RETURN

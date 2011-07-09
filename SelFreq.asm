;
; This function will display the selected frequency on the display line pointed
; to by the number in Ctemp. The Fband flag is used to define the 
; frequency band.
;
; Fband:
;     1 = 50 MHz
;     2 = 53 MHz
;     3 = 72 MHz
;
DisplayFrequency
	; If the OFF flag is set, display OFF and exit...
		MOVLB	HIGH SelFreq
		MOVLW	0FF
		CPFSEQ	SelFreq
		GOTO	DF0
		MOVLR	HIGH Ctemp
		MOVF	Ctemp,W
		CALLFW  LCDsendCMD
		PrintMess MES6
		RETURN
	; Display the selected freq...
DF0
	; Test if its 53MHz
		MOVLB	HIGH Fband
		BTFSC	Fband,0
		GOTO	DF50MHz
		BTFSS   Fband,1
		GOTO    DF50MHz
	; Here if 53MHz
		MOVLB	HIGH Ctemp
		MOVF	Ctemp,W
		CALLFW  LCDsendCMD
		PrintMess MES5
		MOVLB	HIGH Ctemp
		MOVF	Ctemp,W
		ADDLW	CH53POS
		CALLFW  LCDsendCMD
		MOVLB	HIGH SelFreq
		MOVLW	031
		ADDWF	SelFreq,0
		CALLFW	LCDsendData
		RETURN
DF50MHz
	; Test if its 50MHz
		MOVLB	HIGH Fband
		BTFSS	Fband,0
		GOTO	DF72MHz
		BTFSC   Fband,1
		GOTO    DF72MHz
        ; Here if its 50MHz	
		MOVLB	HIGH Ctemp
		MOVF	Ctemp,W
		CALLFW  LCDsendCMD
		PrintMess MES14
		MOVLB	HIGH Ctemp
		MOVF	Ctemp,W
		ADDLW	CH50POS
		CALLFW  LCDsendCMD
		MOVLB	HIGH SelFreq
		MOVLW	030
		ADDWF	SelFreq,W
		CALLFW	LCDsendData
		; Now do the frequency part...
		MOVLB	HIGH SelFreq
		MOVF	SelFreq,W
		BCF	ALUSTA,C
		RLCF	WREG
		ADDLW	D'80'
		; WREG now holds the variable part of the freq,
		; convert it to a string
		MOVLB	HIGH CEXreg
		MOVWF	CEXreg
		CLRF	CEXreg+1
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		CALL	Int2Str
		; Now Print the number...
		MOVLB	HIGH Ctemp
		MOVF	Ctemp,W
		ADDLW	CH50MHZPOS
		CALLFW  LCDsendCMD
		MOVF	Buffer+3,W
		CALLFW  LCDsendData
		MOVF	Buffer+4,W
		CALLFW  LCDsendData
		RETURN
DF72MHz
	; Test if its 72MHz
		MOVLB	HIGH Fband
		BTFSS	Fband,0
		RETURN
		BTFSS   Fband,1
		RETURN
        ; Here if its 72MHz	
		MOVLB	HIGH Ctemp
		MOVF	Ctemp,W
		CALLFW  LCDsendCMD
		PrintMess MES22
		MOVLB	HIGH Ctemp
		MOVF	Ctemp,W
		ADDLW	CH72POS
		CALLFW  LCDsendCMD
		MOVLB	HIGH SelFreq
		MOVF    SelFreq,W
		MOVLB   HIGH FCN
		ADDWF   FCN,WREG
		MOVLB   HIGH CEXreg
		MOVWF   CEXreg
		CLRF    CEXreg+1 
		CLRF    CEXreg+2
		CLRF    CEXreg+3
		CALLF   LCDint2
		; Now do the frequency part...
		MOVLB	HIGH SelFreq
		MOVF	SelFreq,W
		BCF	ALUSTA,C
		RLCF	WREG
		ADDLW	D'01'
		; WREG now holds the variable part of the freq,
		; convert it to a string
		MOVLB	HIGH CEXreg
		MOVWF	CEXreg
		CLRF	CEXreg+1
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		CALL	Int2Str
		; Now Print the number...
		MOVLB	HIGH Ctemp
		MOVF	Ctemp,W
		ADDLW	CH72MHZPOS
		CALLFW  LCDsendCMD
		MOVF	Buffer+3,W
		CALLFW  LCDsendData
		MOVF	Buffer+4,W
		CALLFW  LCDsendData
                RETURN

;
; This function allows the pilot to select the frequency using the
; elevator stick...
;
SelectFrequency
	; Display current selection
SF4
		MOVLB	HIGH ModelChannel
		MOVLW	0FF
		CPFSEQ	ModelChannel
		GOTO	SF0
		CALLFL  LCDsendCMD,LINE2
		PrintMess MES6
		CALLFL	Delay1mS,D'250'
		GOTO	SF1
	; Display the current freq...
SF0
		MOVLB	HIGH ModelChannel
		MOVF	ModelChannel,W
		MOVLB	HIGH SelFreq
		MOVWF	SelFreq
		MOVLW	LINE2
		MOVLB	HIGH Ctemp
		MOVWF	Ctemp
		CALL	DisplayFrequency
		CALLFL	Delay1mS,D'250'
	; Wait for confirm or advance...
	; Elevator = change...
	; Option = accept
SF1
	; Test for change
		CALL	Elevator
		BTFSS	ALUSTA,Z
		GOTO	SF2
		; Here to advance to next selection
		MOVLB   HIGH NUMFREQ
		MOVF    NUMFREQ,W
		MOVLB	HIGH ModelChannel
		INCF	ModelChannel
		CPFSEQ	ModelChannel
		GOTO	SF4
		MOVLW	0FF		; 0FF to enable OFF option
		MOVWF	ModelChannel
		GOTO	SF4
SF2
		BTFSS	ALUSTA,C
		GOTO	SF3
		; Here to return to last selection
		MOVLB	HIGH ModelChannel
		DECF	ModelChannel
		MOVLW	0FE		; 0FF to enable OFF option
		CPFSEQ	ModelChannel
		GOTO	SF4
		MOVLB   HIGH NUMFREQ
		MOVF    NUMFREQ,W
                DECF    WREG
        MOVLB   HIGH ModelChannel
		MOVWF	ModelChannel
		GOTO	SF4
SF3
		; Test if the option button has been pressed
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	SF1
		; Save the new frequency to Sprom
		MOVFF	Aircraft,WREG	; Load aircraft number
		CALL	SaveAircraft
		RETURN

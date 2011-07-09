;
; This is a IO test routine entered when the Option and Preset buttons are
; held down during power up. The display will show binary data for ports
; D and E on the top line, and G and B on the second line.
;
ifdef 	MicroProStar
; Entry point for the MicroProStar mode.
TestIO
	; Enable the MOD output pin
		BCF	DDRF,MOD,A
	;
		SingleLine
		CALL	LCDshowLine1
		CLRF	WREG		; Make sure we point to line one of the display
		MOVFF	WREG,DisplayLine
	; Make sure test select buttons are released
		Release	OPTION_BUTTON
		Release	PORTD,PRESET
TestIOa
	; Display the digitial port data
		MOVLW	LINE1
		CALL	LCDsendCMD
		CALL	MP8KreadD
		CALL	LCDbinary
		MOVLW	LINE1+LCDRIGHT
		CALL	LCDsendCMD
		CALL	MP8KreadE
		CALL	LCDbinary
	; Use aileron dual rate to drive mod pin, this is useful for
	; setting the RF deck modulation depth
		CALL	MP8KreadD
		BTFSC	WREG,AilDR
		BSF	PORTF,MOD
		BTFSS	WREG,AilDR
		BCF	PORTF,MOD
	; Use rudder dual rate to turn on and off buzzer
		BCF	PORTA,BUZZER,A 
		BTFSS	WREG,RudDR
		BSF	PORTA,BUZZER,A 
		CALL	MP8Kbuzzer	
		; Delay a bit
		MOVLW	D'50'
		CALL	Delay1mS
		Pressed	OPTION_BUTTON
		BTFSC	ALUSTA,C
		GOTO	TestIOa
		Release	OPTION_BUTTON
	; Read and display the ADC channels... 
		MOVLR	HIGH CXreg
		CLRF	CXreg
else
;
; This is the entry point for the MicroStar mode.
;
TestIO
		Release	OPTION_BUTTON
		Release	PORTD,PRESET
TestIOa
ifdef ECMA1010display
		MOVLW	LINE1
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLW	LINE3
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLW	LINE4
		CALL    LCDsendCMD
		PrintMess MES0
endif
	; Read and display parallel IO ports
		MOVLW	LINE1
		CALL    LCDsendCMD	; First line of display
		MOVLB	HIGH PORTD	; Port D
		MOVFP	PORTD,WREG
		CALL	LCDbinary
ifdef ECMA1010display
		MOVLW	LINE2
		CALL    LCDsendCMD
endif
		MOVLB	HIGH PORTE	; Port E
		MOVFP	PORTE,WREG
		CALL	LCDbinary
		MOVLW	LINE3		; Second line of display
		CALL    LCDsendCMD
		MOVLB	HIGH PORTG	; Port G
		MOVFP	PORTG,WREG
		CALL	LCDbinary
ifdef ECMA1010display
		MOVLW	LINE4
		CALL    LCDsendCMD
endif
		MOVLB	HIGH PORTB	; Port B
		MOVFP	PORTB,WREG
		CALL	LCDbinary
	; Test LEDs
	; PortD bit 0 (Ail DR) = LED1
	; PortD bit 1 (Eve DR) = LED2
		MOVLB	HIGH PORTD
		MOVFP	PORTD,WREG
	        BSF     PORTC,LED1
	        BSF     PORTB,LED2
	        BTFSC   WREG,0
	        BCF     PORTC,LED1
	        BTFSC   WREG,1
	        BCF     PORTB,LED2
	; Test the buzzer = PORTD bit 2 (Rud DR)
	        BCF     PORTA,BUZZER
	        BTFSC   WREG,2
	        BSF     PORTA,BUZZER
	; Loop untill the option button is pressed...
		MOVLW	D'50'
		CALL	Delay1mS
		Pressed	OPTION_BUTTON
		BTFSC	ALUSTA,C
		GOTO	TestIOa
		Release	OPTION_BUTTON
	; Read the ADC channels...
ifdef ECMA1010display
		MOVLW	LINE3
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLW	LINE4
		CALL    LCDsendCMD
		PrintMess MES0
endif
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLR	HIGH CXreg
		CLRF	CXreg
endif
;
; The following is common code for both the MicroStar and MicroProStar
;
TestIO1
		MOVLW	LINE1
		CALL    LCDsendCMD
		PrintMess MES3
		MOVLW	LINE1+TESTCHPOS
		CALL    LCDsendCMD
		MOVLR	HIGH AXreg
		MOVFP	CXreg,WREG
		CALL	LCDhex
		CALL	ADCread
		; divide by 4 if its the PIC 18F8722
		MOVFF	PIC18F8723,WREG
		TSTFSZ	WREG,A
		GOTO	TestIO2
		BCF	ALUSTA,C,A
		RRCF	ADRESH,F,A
		RRCF	ADRESL,F,A
		BCF	ALUSTA,C,A
		RRCF	ADRESH,F,A
		RRCF	ADRESL,F,A
TestIO2		;
		MOVLW	LINE1+TESTVALPOS
		CALL    LCDsendCMD
ifdef TestADChex
		MOVLB	HIGH ADRESH
		MOVPF	ADRESH,WREG
		CALL	LCDhex	
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,WREG
		CALL	LCDhex	
else
		MOVFF	ADRESL,CEXreg
		MOVFF	ADRESH,CEXreg+1
		MOVLB	HIGH CEXreg
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		CALL	LCDint4
endif
	; Delay
		MOVLW	D'50'
		CALL	Delay1mS
	; If option button is pressed then advance to next channel
	; after channel 12, exit
		Pressed	OPTION_BUTTON
		BTFSC	ALUSTA,C
		GOTO	TestIO1
		Release	OPTION_BUTTON
	; Advance ADC channel
		MOVLR	HIGH CXreg
		INCF	CXreg
		MOVLW	D'12'
		CPFSGT	CXreg
		GOTO	TestIO1
		GOTO	TestIOa

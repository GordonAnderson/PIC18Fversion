;
; ADC.asm
;
; This file contains routines used for ADC data processing for the MicroStar and
; MicroProStar applications. This file also contains a number of related routines 
; including the processor type detection function.
;
; Gordon Anderson
;

; This function displays the transmitter voltage on the first line of the LCD
; display. The ADC value for the display is expected to be in Vbat. This function
; also tests the voltage against an alarm limit, if the value is below the limit 
; the buzzer is used to signal an alarm.
TransVoltage
	; Display the Battery voltage
		; Set the print position
		MOVLW	LINE1
		CALL	LCDsendCMD
		; Multiply the BattAlarm by 100 and place in CXreg
		MOVE	BattAlarm,AXreg 
		CLRF	AXreg+1
		MOVEC	D'100',BXreg
		CALL	Mult1616
		MOVE	CEXreg,CXreg		
		; Filter the battery voltage before display
		CALL	TransFilter
		MOVE	VmonG,BXreg
		CALL	Mult1616
		MOVFP	CEXreg+1,WREG
		MOVPF	WREG,CEXreg
		MOVFP	CEXreg+2,WREG
		MOVPF	WREG,CEXreg+1
		CLRF	CEXreg+2
	; If this is a MicroProStar we need to add the diode voltage drop to the
	; ADC value to improve the linearity in this conversion. The voltage is 
	; multiplied by 100 so add 80 to represent a .8 volts diode drop.
ifdef		MicroProStar
		MOVLW	LOW D'80'
		ADDWF	CEXreg,F
		MOVLW	HIGH D'80'
		ADDWFC	CEXreg+1,F
endif
		; Test the battery voltage, if its below the limit
		; then beep a bunch of times
		MOVLR	HIGH LValarm
		BTFSC	LValarm,0
		GOTO	NoAlarm
		MOVLR	HIGH CEXreg
		MOVFP	CXreg,WREG
		SUBWF	CEXreg,W
		MOVFP	CXreg+1,WREG
		SUBWFB	CEXreg+1,W
		; If result is negative then beep! 
		BTFSS	WREG,7
		GOTO	NoAlarm
		; Make noise!
		MOVLW	D'201'
		MOVLR	HIGH BeepCyl
		MOVWF	BeepCyl
		MOVLW	D'5'
		CALL	Beep 
		; Set the alarm flag so wo do not do this again!
		MOVLR	HIGH LValarm
		SETF	LValarm
	; Display the voltage
NoAlarm		
		MOVLR	HIGH CEXreg
		CALL	Int2Str
		MOVLW	' '
		MOVPF	WREG,Areg
		MOVLW	'0'
		CPFSGT	Buffer
		MOVPF	Areg,Buffer
		MOVFP	Buffer,WREG
		CALL	LCDsendData
		MOVFP	Buffer+1,WREG
		CALL	LCDsendData
		MOVLW	'.'
		CALL	LCDsendData
		MOVFP	Buffer+2,WREG
		CALL	LCDsendData  
		RETURN
		
; This function applies a difference filter to the transmitter ADC value used
; to monitor the battery voltage. The filter function (time constant) is fixed
; and define by the constant below.
; The filter calculation:
;	Vbat * 256 = Vbat(t-1) * (256 - FilterTC) + Vbat(t) * FilterTC
; Vbat(t) = Vbat when called
; Filtered Vbat is returned in AXreg as well
FilterTC	EQU	30
TransFilter
	; Calculate Vbat(t-1) * FilterTC
		MOVFF	Vbat256+1,AXreg
		MOVFF	Vbat256+2,AXreg+1
		MOVEC	FilterTC,BXreg
		CALL	Mult1616		; Result in CEXreg
	; Calculate Vbat(t-1) * (256 - FilterTC), subtract CEXreg from Vbat256
		MOVLB	HIGH Vbat256
		MOVFF	CEXreg,WREG
		SUBWF	Vbat256,F
		MOVFF	CEXreg+1,WREG
		SUBWFB	Vbat256+1,F
		MOVFF	CEXreg+2,WREG
		SUBWFB	Vbat256+2,F
	; Calculate Vbat(t) * FilterTC
		MOVE	Vbat,AXreg
		MOVEC	FilterTC,BXreg
		CALL	Mult1616
	; Sum into Vbat256
		MOVLB	HIGH Vbat256
		MOVFF	CEXreg,WREG
		ADDWF	Vbat256,F
		MOVFF	CEXreg+1,WREG
		ADDWFC	Vbat256+1,F
		MOVFF	CEXreg+2,WREG
		ADDWFC	Vbat256+2,F
	; Load filtered value into AXreg and return
		MOVFF	Vbat256+1,AXreg
		MOVFF	Vbat256+2,AXreg+1
		RETURN
		
; This function will read ADC channel 13, this is the receiver
; voltage monitor channel. If the value is greater than a few 
; counts then the data is displayed on the second line of the 
; display. If the receiver value is displayed then this function
; returns with the carry flag set.
RecVoltage    
	; Read ADC positive reference channel 
		MOVLW	ADCrec
		CALL	ADCread		; Results are in Pos
		MOVLW	ADCrec
		CALL	ADCread		; Results are in Pos
	; Convert the ACD counts into the voltage
		MOVE	Pos,AXreg
		MOVE	VRmonG,BXreg
		CALL	Mult1616
	; Divide the value in CEXreg by 256
		MOVLR	HIGH CEXreg
		MOVFP	CEXreg+1,WREG
		MOVWF	CEXreg
		MOVFP	CEXreg+2,WREG
		MOVWF	CEXreg+1
		MOVFP	CEXreg+3,WREG
		MOVWF	CEXreg+2
		CLRF	CEXreg+3
	; Now convert to a string...
		CALL	Int2Str                                  
		; The string is in Buffer, in millivolts
	; If the voltage is greater that 1 volt, then display it!
		MOVLR	HIGH Buffer
		MOVFP	Buffer,WREG
		IORWF	Buffer+1,W
		ANDLW	0F
		BCF	ALUSTA,C
		BTFSC	ALUSTA,Z
		RETURN
	; Here to display the value!
		MOVLW	LINE2
		CALL	LCDsendCMD
		PrintMess MES23
		MOVLW	LINE2 + RECVPOS
		CALL	LCDsendCMD
	        MOVLR	HIGH Buffer
	        MOVFP	Buffer,WREG
	        CALL	LCDsendData
	        MOVFP	Buffer+1,WREG
	        CALL	LCDsendData    
	        MOVLW	'.'
	        CALL	LCDsendData
	        MOVFP	Buffer+2,WREG
	        CALL	LCDsendData    
	        MOVFP	Buffer+3,WREG
	        CALL	LCDsendData
	; Set carry flag and exit
	        BSF	ALUSTA,C
		RETURN

; This function reads the PIC type and set the PIC18F8723 flag if the processor is detected.
; This is used to determine if a 12 or 10 bit ADC is present. The 8723 has a 12 bit ADC.
ProcessorType
		CLRF	WREG
		MOVFF	WREG,PIC18F8723		; Clear the flag
		MOVLW	UPPER 3FFFFF		; Load the dievide ID address
		MOVWF	TBLPTRU,A
		MOVLW	HIGH 3FFFFF
		MOVWF	TBLPTRH,A
		MOVLW	LOW 3FFFFF
		MOVWF	TBLPTRL,A
		; Read the device type and set the memory flag
		TBLRD*
		MOVF	TABLAT,W,A
		XORLW	4A			; If 4A then its an 8723
		MOVLW	0FF
		BTFSC	ALUSTA,Z
		MOVFF	WREG,PIC18F8723
		RETURN

; This function will read the ADC channel defined in WREG 256 times and
; sum the results in ADCsum.
ReadADC256
	; First clear ADCsum
		MOVLR	HIGH ADCsum
		CLRF	ADCsum
		CLRF	ADCsum+1
		CLRF	ADCsum+2
	; Save Channel to Areg
		MOVWF	Areg,A
	; Setup Breg as a loop counter
		CLRF	Breg,A
	; Read the ADC
RD256a
		MOVF	Areg,W,A
		CALL	ADCread
	; Sum the result
		MOVLR	HIGH ADCsum
		MOVFP	ADRESL,W,A
		ADDWF	ADCsum
		MOVFP	ADRESH,W,A
		ADDWFC	ADCsum+1
		BTFSC	ALUSTA,C,A
		INCF	ADCsum+2
	; Do the loop counter test
		DECFSZ	Breg
		GOTO	RD256a
		RETURN
;
; This function reads data from the ADC channel defined in WREG.
; The results are in the ADC registers when this function returns.
; The results are also written to Pos.
; Areg will contain the channel number when this function returns
; as will WREG.
; The function ADClookup is called to translate the ADC channel number 
; into the value that will be used to select the ADC channel and the
; ADC reference. The bit use is defined below:
;
ADCread
	; Save the ADC requested channel
		MOVWF	Areg,A
	; Lookup the ADC parameters, mux channel and reference data
		CALL	ADClookup
	; Test bit 4, if set this is the MPS fixed mode
		BTFSS	WREG,4
		GOTO	ADCread00
	; Here for MPS fixed mode
		CALL	ADCfixed
		BTFSC	ALUSTA,C
		CALL	ADCfixed
		MOVFF	Areg,WREG
		RETURN		
	; Here for normal mode, Perform the conversion
ADCread00
		CALL	ADCreadChan
	; Restore the requested channel
		MOVFF	Areg,WREG
		RETURN
;
; This function reads the ADC channel defined in the WREG reg and applies
; the reference voltages as defined via the flag bits.
; The results are in the ADC registers when this function returns.
; The results are also written to Pos.
;	WREG bit definition
;		0	\
;		1	 | ADC mux channel
;		2	 |
;		3	/
;		4	Set for the MSP glitch detection mode, this also requires the 5 Volt ref flag to be set
;		5	for MicroProStar this is mux select
;		6	- ref 0=gnd, 1=ext, MicroProStar only
;		7	+ ref 0=ext, 1=5 volts
;
ADCreadChan
	; Set default reference values
		CLRF	ADCON1,A	; Use VDD and VSS as reference
	; If MSB is clear then use ext ref	
		BTFSS	WREG,7,A
		BSF	ADCON1,VCFG0,A	; Use external reference for positive supply
		BCF	WREG,7,A
#ifdef MicroProStar
	; Select the ADC MUX
		BTFSC	WREG,6,A
		BSF	ADCON1,VCFG1,A	; Use external reference for negative supply
		BTFSS	WREG,6,A
		BCF	ADCON1,VCFG1,A	; Use ground reference for negative supply
	; Select the negative reference
		BTFSC	WREG,5,A
		BSF	MP8K_LCD,MP8K_LCD_RS,A
		BTFSS	WREG,5,A	
		BCF	MP8K_LCD,MP8K_LCD_RS,A
	; Clear upper bits to maintain compatability
		ANDLW	0x0F
#endif
	; Select the channel
		RLNCF	WREG,W,A
		RLNCF	WREG,W,A
		MOVWF	ADCON0,A
	; Setup ADC
		MOVLW	0A1		; Right justify and 1MHz conversion clock
		MOVWF	ADCON2,A
	; Setup the loop counter
		MOVLW	4
		MOVFF	WREG,Creg
		MOVEC	0,Pos
	; Start the conversion
ADCread1
		BSF	ADCON0,ADON,A
		NOP			; delay to let the Mux settle
		NOP
		NOP
		BSF	ADCON0,GO,A
	; Wait for the ADC to finish
ADCread0
		BTFSC	ADCON0,DONE,A
		GOTO	ADCread0
	; Sum results in Pos
		MOVLR	HIGH Pos
		MOVF	ADRESL,W,A
		ADDWF	Pos,F
		MOVF	ADRESH,W,A
		ADDWFC	Pos+1,F
	; Loop till done
		MOVLR	HIGH Creg
		DECF	Creg,F
		BNZ	ADCread1
	; Here when done, test for 8723
		MOVFF	PIC18F8723,WREG
		COMF	WREG
		TSTFSZ	WREG,A
		GOTO	ADCread2
		; divide by 4	
		BCF	ALUSTA,C
		RRCF	Pos+1
		RRCF	Pos
		BCF	ALUSTA,C
		RRCF	Pos+1
		RRCF	Pos
ADCread2	
	; Make the ADC regs match Pos
		MOVFF	Pos,ADRESL
		MOVFF	Pos+1,ADRESH
		RETURN
;
; This ADC read function supports the MPS where the 5 volt reference is used to read
; the joystick pots. The pots are powered from the battery so the battery voltage is
; used to normalize the value read. The battery voltage is read before and after the
; channel is read and if the values are not close then carry flag is set on return.
;
; Procedure:
;	1.) Read the battery voltage and save
;	2.) Read the requested channel
;	3.) Read the battery voltage and save
;	4.) If values from 1 and 3 are not close in value then there is a read error
;	    and we need to exit with an error flag set, carry flag set on error
;	5.) If no error then the value = requested channel * nominal bat voltage / battery voltage
;
; Areg contains the ADC channel request
;
ADCfixed
	; Save AXreg and BXreg, in use in some places
		MOVE	AXreg,AXregSave
		MOVE	BXreg,BXregSave
		MOVE32	CEXreg,CEXregSave
	; Read the reference
		MOVLW	ADCref
		CALL	ADClookup
		CALL	ADCreadChan
		MOVE	Pos,DEXreg
	; Read the requested channnel
		MOVFF	Areg,WREG
		CALL	ADClookup
		BCF	WREG,4		; Clear the MPS fixed flag bit
		CALL	ADCreadChan
		MOVE	Pos,AXreg
	; Read the reference again
		MOVLW	ADCref
		CALL	ADClookup
		CALL	ADCreadChan
	; Now calculate the difference between the two ref values
	; pos = pos - DEXref
		MOVLB	HIGH Pos
		MOVFF	DEXreg,WREG
		SUBWF	Pos,F
		MOVFF	DEXreg+1,WREG
		SUBWFB	Pos+1,F
	; Get the absolute value of the difference
		BTFSS	Pos+1,7
		GOTO	ADCfixed1
		; Here if negative so take 2s complement
		COMF	Pos
		COMF	Pos+1
		INCF	Pos
		BTFSC	ALUSTA,Z
		INCF	Pos+1
	; Now check the difference
ADCfixed1
		MOVF	Pos+1,W
		BTFSS	ALUSTA,Z
		GOTO	ADCfixed2	; If the MS byte is non zero then the change is too big
		MOVF	Pos,W
		MOVLB	HIGH ADCfixThres
		SUBWF	ADCfixThres,W
		BTFSS	ALUSTA,C
		GOTO	ADCfixed2
	; Here if the bat values are close and we have valid data
		MOVEC	NOMINALBAT,BXreg
		CALL	Mult1616
		CALL	Divide2416
		MOVE	CEXreg,Pos
	; Make the ADC regs match Pos
		MOVFF	Pos,ADRESL
		MOVFF	Pos+1,ADRESH
	; Restore AXreg and BXreg
		MOVE	AXregSave,AXreg
		MOVE	BXregSave,BXreg
		MOVE32	CEXregSave,CEXreg
		BCF	ALUSTA,C
		RETURN
	; Here with a big bat value error and we have invalid data, calculate the result anyway
ADCfixed2
		MOVEC	NOMINALBAT,BXreg
		CALL	Mult1616
		CALL	Divide2416
		MOVE	CEXreg,Pos
	; Make the ADC regs match Pos
		MOVFF	Pos,ADRESL
		MOVFF	Pos+1,ADRESH
	; Restore AXreg and BXreg
		MOVE	AXregSave,AXreg
		MOVE	BXregSave,BXreg	
		MOVE32	CEXregSave,CEXreg
		BSF	ALUSTA,C
		RETURN
	

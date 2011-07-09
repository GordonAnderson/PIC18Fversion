;
; Monitor.asm
;
; This function allows the pilot to display the channel position information on the LCD
; screen using the digitial trim bar graph display. This is designed to aid the pilot in
; setup and testing of the transmitter. To enable this mode of operation the pilot must
; hold down the option key when power is applied and then release the key a few seconds 
; after power up. When in the mode the option key will advance from channel to channel.
; The only way to exit this mode of operation is to cycle power on the transmitter.
;
; AutoTrimMonitor allows the pilot to monitor the status of the three autotrim positions.
; This data is displayed in percentage. The pilot holds down the Auto Trim button on power
; up to enable this display mode. Pressing the option button will advance the display from
; channel to channel. 
;
; Gordon Anderson
; 25 December 2008
; 12 June 2011
;


;================================================================================
;
; Display headers for each channel
;
;================================================================================
AilMes		DB	"L  Ail  xxx%   R"
EleMes		DB	"U  Ele  xxx%   D"
RudMes		DB	"L  Rud  xxx%   R"
ThtMes		DB	"L  Tht  xxx%   H"
CH5Mes		DB	"A  CH5  xxx%   B"
CH6Mes		DB	"U  CH6  xxx%   D"
CH7Mes		DB	"U  CH7  xxx%   D"
CH8Mes		DB	"C  CH8  xxx%   A"
; Now display the servo output pulse width data for each channel
SV1Mes		DB	"Elevator        "
SV2Mes		DB	"Aileron         "
SV3Mes		DB	"Rudder          "
SV4Mes		DB	"Throttle        "
SV5Mes		DB	"CH5             "
SV6Mes		DB	"CH6             "
SV7Mes		DB	"CH7             "
SV8Mes		DB	"CH8             "

; This function performes the channel and servo output position display.
Monitor
	SingleLine
   ; It is assumed that the enable flag is tested before this call.
   ; First build a pointer to the display header
	MOVEC	AilMes,AXreg
	MOVFF	MonChan,WREG
	SWAPF	WREG			; This will multiply by 16 and make index into an offset
	MOVLB	HIGH AXreg
	ADDWF	AXreg,F
	BTFSC	ALUSTA,C
	INCF	AXreg+1
	; Now print the first line of the display
	CALL	LCDsendAX
   ; Output pulse width data if selected channel is over 7
   	CALL	MonitorPulseWidth
   	BTFSC	ALUSTA,C
   	GOTO	Mon2
   ; Load the selected channel into AXreg
	MOVEC	Apos,FSR1L
	MOVFF	MonChan,WREG
	ANDLW	07			; Only channels 0 - 7 are valid
	RLNCF	WREG			; Make into word pointer
	ADDWF	FSR1L,F,A
	BTFSC	ALUSTA,C
	INCF	FSR1H,F,A	
	MOVF	POSTINC1,W		; Load value into AXreg
	MOVFF	WREG,AXreg
	MOVF	POSTINC1,W
	MOVFF	WREG,AXreg+1
   ; Divide the normalized position by 10 to make it into a percentage, then display
   ; in on the first line of the display
	MOVE	AXreg,CEXreg
	MOVLW	D'10'
	MOVWF	DEXreg
	CALL	Divide168
   	; CEX now contains the percentage, now display it
	MOVLW	LINE1 + D'7'
	CALL	LCDsendCMD   	
   	CALL	LCDsign
   	CALL	LCDint3
   ; If this is the throttle channel then use the paint bar function because the
   ; throottle channel range is 0 to 1000
   	MOVFF	FSR1L,WREG
   	XORLW	LOW (Tpos + 2)
   	BTFSS	ALUSTA,Z
   	GOTO	Mon1
	CALL	PaintBar
	GOTO	Mon2
   ; Paint the trim position on second line
Mon1	CALL	PaintRightBar
	CALL	PaintLeftBar
   ; If the option button is pressed then advance the Moniton Channel value
Mon2	CALL	Option
	MOVLR	HIGH MonChan
   	BTFSC	ALUSTA,C
   	INCF	MonChan
   	MOVLW	0F
   	ANDWF	MonChan,F
   	DualLine
   	RETURN

; In this mode I use the top display line to show the channel name and servo position 
; pulse width. Use the second line as a bar graph position indicator
; with min and max servo positions defining the range of the bar graph.
MonitorPulseWidth
   ; Exit if the channel number if under 8
	BCF	ALUSTA,C
   	MOVFF	MonChan,WREG
   	BTFSS	WREG,3
   	RETURN
   ; Build index into the pulse width data
	MOVEC	chELE,FSR1L
   	MOVFF	MonChan,WREG
	ANDLW	07			; Only channels 0 - 7 are valid
	RLNCF	WREG			; Make into word pointer
	ADDWF	FSR1L,F,A
	BTFSC	ALUSTA,C
	INCF	FSR1H,F,A	
	MOVF	POSTINC1,W		; Load value into CEXreg
	MOVFF	WREG,CEXreg
	MOVF	POSTDEC1,W
	MOVFF	WREG,CEXreg+1
   ; Display the value on the top line of the display
	MOVLW	LINE1+LCDRIGHT + D'1'
	CALL	LCDsendCMD
   	CALL	LCDmSfix   
   ; Display a bar graph on the second line of the display
	MOVF	POSTINC1,W		; Load value into AXreg
	MOVFF	WREG,AXreg
	MOVF	POSTDEC1,W		; Load value into AXreg
	MOVFF	WREG,AXreg+1
	CALL	DisplayServoMS
	BSF	ALUSTA,C
	RETURN

; This function display a bar graph on the second line of the display.
; The value to be displayed is in AXreg and its a servo position in
; .5 uS units. The display range is defined by the servo min and max values.
; The following equation is used to put the data into a 0 to 1000 range
; for display.
;
; DisplayValue = (ServoPos - ServoMin) * 1000 / (ServoMax - ServoMin)
; 
; Called with ServoPos in reg AXreg
;
DisplayServoMS
   ; AXreg = ServoPos - ServoMin
   	MOVLB	HIGH AXreg
   	MOVFF	ServoMin,WREG
   	SUBWF	AXreg,F
   	MOVFF	ServoMin+1,WREG
   	SUBWFB	AXreg+1,F
   ; Multiply by 1000
   	MOVEC	D'1000',BXreg
   	CALL	Mult1616
   ; DEXreg = ServoMax - ServoMin
   	MOVE	ServoMax,DEXreg
   	MOVLB	HIGH DEXreg
   	MOVFF	ServoMin,WREG
   	SUBWF	DEXreg,F
   	MOVFF	ServoMin+1,WREG
   	SUBWFB	DEXreg+1,F
   ; Result in CEXreg
   	CALL	Divide2416
   ; Now display this bar on the second line of the display
	MOVLW	LINE2
	CALL	LCDsendCMD
   	MOVE	CEXreg,AXreg
   	CALL	PaintBar   	
   	RETURN

; This is an optional entry point into the LCDmS function, this entry point will
; divide the value by 2 before its displayed, this is to correct for the fact that
; the times are saved in 0.5 uS units
LCDmSfix
	; Divide by two
	MOVLB	HIGH CEXreg
	BCF     ALUSTA,C
	RRCF    CEXreg+1
	RRCF    CEXreg
	CLRF	CEXreg+2
	CLRF	CEXreg+3
; This function prints the value in CEXreg to the LCD display at the current
; character position.
LCDmS
; Convert to string
	CALL	Int2Str
; Position the print position and print...
	CALLFF	LCDsendData,Buffer+1
	CALLFL	LCDsendData,'.'
	CALLFF	LCDsendData,Buffer+2
	CALLFF	LCDsendData,Buffer+3
	CALLFF	LCDsendData,Buffer+4
	CALLFL	LCDsendData,'m'
	CALLFL	LCDsendData,'S'
	RETURN

; This function is used to display the Auto Trim position data.
AutoTrimMonitor
	SingleLine
   ; It is assumed that the enable flag is tested before this call.
   ; First build a pointer to the display header
	MOVEC	AilMes,AXreg
	MOVFF	MonChan,WREG
	SWAPF	WREG			; This will multiply by 16 and make index into an offset
	MOVLB	HIGH AXreg
	ADDWF	AXreg,F
	BTFSC	ALUSTA,C
	INCF	AXreg+1
	; Now print the first line of the display
	CALL	LCDsendAX
   ; Load the selected channel into AXreg
	MOVLR	HIGH MonChan
	CLRF	WREG
	MOVFF	WREG,AXreg+1
	CPFSLT	MonChan
	MOVFF	AAT,AXreg
	INCF	WREG
	CPFSLT	MonChan
	MOVFF	EAT,AXreg
	INCF	WREG
	CPFSLT	MonChan
	MOVFF	RAT,AXreg
	; Extend the sign
	MOVLR	HIGH AXreg
	BTFSC	AXreg,7
	SETF	AXreg+1
   ; Display in on the first line of the display
	MOVE	AXreg,CEXreg
   	; CEX now contains the percentage, now display it
	MOVLW	LINE1 + D'7'
	CALL	LCDsendCMD   	
   	CALL	LCDsign
   	CALL	LCDint3
   ; Multiply the percentage in the AXreg by 10 for the bar graph display
   	MOVEC	D'10',BXreg
   	CALL	Mult1616
   	MOVE	CEXreg,AXreg
   ; Paint the trim position on second line
	CALL	PaintRightBar
	CALL	PaintLeftBar
   ; If the option button is pressed then advance the Auto Trim Channel number
	CALL	Option
	MOVLR	HIGH MonChan
   	BTFSC	ALUSTA,C
   	INCF	MonChan
   	MOVLW	03
   	CPFSLT	MonChan
   	CLRF	MonChan
   	DualLine
	RETURN
; 
; This file contains the routines that support the tachometer feature. This feature uses
; an enternal module that contains the photo cell used to detect the prop. Timer 0 is
; used to count the pulses from the detector and RB1/INT1 is used to count prop revolutions.
;
; Tach algorithm
; The CPU is interrupted on each detection of the prop and the prop dectections are
; counted. Timer 0 is set to free running count mode. Every second the following
; parameters are measured:
;	Number of prop blade detections, 16 bit number (BladeDet)
;	Total timer counts, 16 bit number (BladeTime)
; The timer is set to 62500 Hz clock rate. At each blade detection the timer value is
; read and added to the blade time value.
; To calculate the RPM:
; RPM = ((Clock/BladeTime)*BladeDet)*60/NumBlades


; This function is called on power up to initalize the Tach. Set to 16 bit mode free running
; with a clock rate of 62500Hz.
; Timer is stoped after init, it will start on first blade detection.
TachInit
	MOVLW	04H
	MOVWF	T0CON
	RETURN

; This function is called every second to stop the processing of blade detection
; interrupts. This is done by disabling timer0.
TachRead
        BCF	T0CON,TMR0ON,A
	RETURN	

; This function tests the TachEnable bit and if its clear the RPM is calculated
; and displayed on line two of the display. If the Tach is enabled this routine
; returns with the carry flag set.
TackDisplay
	BCF	ALUSTA,C
ifdef	NOTACHENA
	RETURN
endif
	BTFSC	PORTH,TACHENA
	RETURN
   ; Here if the tach is enabled
 	BSF	ALUSTA,C
  	; Exit if the timer is enabled
        BTFSC	T0CON,TMR0ON
 	RETURN
   ; Here with valid data to calculate the RPM and display the value	
   	; RPM = ((Clock/BladeTime)*BladeDet)*60/NumBlades, calculated this way:
   	; RPM = (Clock * BladeDet * 60) / (NumBlades * BladeTime)
   	; First; 60 * BladeDet
   	MOVE	BladeDet, AXreg
   	MOVEC	D'60', BXreg
	CALL	Mult1616u
	; Ans fits in 16 bits, move ans from CEXreg to AXreg
	MOVE	CEXreg,AXreg
   	MOVEC	D'62500', BXreg
	CALL	Mult1616u
	; CEXreg  = (Clock * BladeDet * 60)
	; Now divide by BladeTime
	MOVEC32	D'0',DEXreg
	MOVE	BladeTime,DEXreg
	CALL	Divide3232u
	; Now divide by NumBlades
   	MOVE	NumBlades,DEXreg
   	MOVLR	HIGH DEXreg
   	CLRF	DEXreg+1
   	CALL	Divide2416
   ; RPM in CEXreg, now display the result
	; Display the template
	MOVLW	LINE2
	CALL	LCDsendCMD
	PrintMess MES15
	; Display the RPM
	MOVLW	LINE2+TACHRPMPOS
	CALL	LCDsendCMD
	CALL	LCDintZS
	; Diplay the number of blades
	MOVE	NumBlades,CEXreg
	CLRF	CEXreg+1
	MOVLW	LINE2
	CALL	LCDsendCMD
	CALL	LCDint1
	; Set carry flag and exit
	MOVEC	0,BladeDet
	BSF	ALUSTA,C
	RETURN

	

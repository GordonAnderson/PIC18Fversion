; This file contains the System Options User Interface Pre and Post functions. The 
; Pre function is called before the selected user interface option is processed
; by the user interface routines and the Post function is called after the
; user interface routine returns. 

postConfig
	; Allow application to all aircraft
		MOVEC	ChannelOrder,Src
		MOVLW	8
		MOVFF	WREG,Cnt
		CALL	ATLpost
		RETURN
		
PostChan
		MOVLB	HIGH MaxChannels
		BCF	ALUSTA,C,A
		RLCF	MaxChannels
	; Allow application to all aircraft
		MOVEC	MaxChannels,Src
		MOVLW	1
		MOVFF	WREG,Cnt
		CALL	ATLpost
		RETURN
		
PreChan
		MOVLB	HIGH MaxChannels
		BCF	ALUSTA,C,A
		RRCF	MaxChannels
		RETURN

; This function will enable the FMS flight simulator mode if the FMSflag flag is set
FMSenable
	; Test the FMS flags and exit if all the flags is not set
		MOVLB	HIGH FMSflag
		BTFSC	FMSflag,7
		GOTO	FMSenable1
		MOVLB	HIGH FMSflagU1
		BTFSS	FMSflagU1,7
		RETURN
	; Init the FMS mode uart
FMSenable1
		CALL	FMSinit
		RETURN


; This function is used to calibrate the transmitter voltage monitoring function.
TXvoltSet
	; First place the ADC channel in Ftemp and the gain
	; value, VmonG, in BXreg
		MOVE	VmonG,BXreg
		MOVLW	ADCref      
		MOVLB	HIGH Ftemp
		MOVWF	Ftemp
		CALL	CalVoltMeter
		MOVE	BXreg,VmonG
		RETURN

; This function is used to calibrate the receiver voltage monitoring function.
RXvoltSet             
	; First place the ADC channel in Ftemp and the gain
	; value, VRmonG, in BXreg
		MOVE	VRmonG,BXreg
		MOVLW	D'13'         
		MOVLB	HIGH Ftemp
		MOVWF	Ftemp
		CALL	CalVoltMeter
		MOVE	BXreg,VRmonG
		RETURN

; This function is used to reset the battery timer value. This value is only
; cleared if the YESNO flag is set.
ResetBatTimer
	; Test the YESNO flag and exit if the flag is not set
		MOVLB	HIGH YESNO
		BTFSS	YESNO,7
		RETURN
	; Clear the battery timer value
		MOVLB	HIGH BatteryTimer
		CLRF	BatteryTimer
		CLRF	BatteryTimer+1
	; Set flag to store the timer to EEPROM
		MOVLR	HIGH BTflag
		SETF	BTflag
		RETURN

; Format primary SPROM
FmtFlsh
		CALL	FormatFlash
		ShowLine2
		RETURN

; Define a channels gain parameters to convert raw ADC counts to normalized units
; for a trim channel. Trim channels go from -1000 to 1000
; Steps:
;	1.) Read RT/DWN position
;	2.) Read LT/UP position
;	Ct = (LT/UP + RT/DWN)/2
;	GH = 1000 * 256/(LT/UP - RT/DWN)/2)
; Results placed in the following reg during the calculations then moved to
; final location:
;	Gh,Ct
; On call the parameters needed are packed in the DXreg. The MSB contains
; the ADC channel number and the LSB contains the low 8 bit of the location
; address for the results. Its assumed that are destinations are in the
; same page.
; DXreg = (ADC channel):(low byte address of Destination)
JStrimsChan
	; Load the Dst register and the ADC channel
		MOVLB	HIGH DXreg
		MOVF	DXreg,W
		MOVWF	Dst
		MOVLW	HIGH (AHG)
		MOVWF	Dst+1
		MOVF	DXreg+1,W
	; Save channel in Areg
		MOVLB	HIGH Atemp
		MOVWF	Atemp
	; Read Vbat
		MOVLW	ADCref
		CALLFW	ReadADC256
		MOVFF	ADCsum+1,Vbat
		MOVFF	ADCsum+2,Vbat+1
	; Get the RT/DWN position
		CALLFL	LCDsendCMD,LINE2
		PrintMess JCALMES15
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	$-6
		MOVLB	HIGH Atemp
		MOVF	Atemp,W
		CALLFW	ReadADC256
		MOVFF	ADCsum+1,Ct
		MOVFF	ADCsum+2,Ct+1
		MOVFF	ADCsum+1,Gl
		MOVFF	ADCsum+2,Gl+1
		MOVLW	D'250'
		CALLFW	Delay1mS
	; Get the LT/UP position
		CALLFL	LCDsendCMD,LINE2
		PrintMess JCALMES16
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	$-6
		MOVLB	HIGH Atemp
		MOVF	Atemp,W
		CALLFW	ReadADC256
		MOVFF	ADCsum+1,Gh
		MOVFF	ADCsum+2,Gh+1
		MOVLW	D'250'
		CALLFW	Delay1mS
	; Now calcuate the gain
	; Ct = (LT/UP + RT/DWN)/2
		MOVLB	HIGH Ct
		MOVF	Gh,W
		ADDWF	Ct
		MOVF	Gh+1,W
		ADDWFC	Ct+1
		RRCF	Ct+1
		RRCF	Ct
		BCF	Ct+1,7
	; Gh = 1000 * 256/(LT/UP - RT/DWN)/2)
		MOVE	Gl,DEXreg
		; Set the 32 bit CEXreg to 1000 time 256
		MOVLB	HIGH CEXreg
		MOVLW	LOW (D'1000')
		MOVWF	CEXreg+1
		MOVLW	HIGH (D'1000')
		MOVWF	CEXreg+2
		MOVLW	0
		CLRF	CEXreg
		CLRF	CEXreg+3
		;
		MOVF	Gh,W
		SUBWF	DEXreg
		MOVF	Gh+1,W
		SUBWFB	DEXreg+1
		RRCF	DEXreg+1
		RRCF	DEXreg
		BTG	DEXreg+1,7
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416
		MOVE	CEXreg,Gh
	; Move the results
		MOVEC	Gh,Src
		MOVLW	4
		MOVLB	HIGH Cnt
		MOVWF	Cnt
		CALL	BlkMove
		RETURN


; Define a channels gain parameters to convert raw ADC counts to normalized units
; for a non-centering channel.
; Steps:
;	1.) Read RT/DWN position
;	2.) Read LT/UP position
;	Ct = LT/UP
;	GH = 1000 * 256/(RT/DWN-Ct)
; Results placed in the following reg during the calculations then moved to
; final location:
;	Gh,Ct
; On call the parameters needed are packed in the DXreg. The MSB contains
; the ADC channel number and the LSB contains the low 8 bit of the location
; address for the results. Its assumed that are destinations are in the
; same page.
; DXreg = (ADC channel):(low byte address of Destination)
JSncChan
	; Load the Dst register and the ADC channel
		MOVLB	HIGH DXreg
		MOVF	DXreg,W
		MOVWF	Dst
		MOVLW	HIGH (AHG)
		MOVWF	Dst+1
		MOVF	DXreg+1,W
	; Save channel in Areg
		MOVLB	HIGH Atemp
		MOVWF	Atemp
	; Get the RT/DWN position
		CALLFL	LCDsendCMD,LINE2
		PrintMess JCALMES15
		CALLF	Option
		BTFSS	ALUSTA,C,A
		GOTO	$-6
		MOVLB	HIGH Atemp
		MOVF	Atemp,W
		CALLFW	ReadADC256
		MOVFF	ADCsum+1,Gh
		MOVFF	ADCsum+2,Gh+1
		MOVLW	D'250'
		CALLFW	Delay1mS
	; Get the LT/UP position
		CALLFL	LCDsendCMD,LINE2
		PrintMess JCALMES16
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	$-6
		MOVLB	HIGH Atemp
		MOVF	Atemp,W
		CALLFW	ReadADC256
		MOVFF	ADCsum+1,Ct
		MOVFF	ADCsum+2,Ct+1
		MOVLW	D'250'
		CALLFW	Delay1mS
	; Now calcuate the gain
	; Calculate the gain values.
	; Gh = (1000 * 256)/(Gh-Ct)
		; Set the 32 bit CEXreg to 1000 time 256
		MOVLB	HIGH CEXreg
		MOVLW	LOW (D'1000')
		MOVWF	CEXreg+1
		MOVLW	HIGH (D'1000')
		MOVWF	CEXreg+2
		MOVLW	0
		CLRF	CEXreg
		CLRF	CEXreg+3
		;
		MOVE	Gh,DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLB	HIGH Ct
		MOVF	Ct,W
		SUBWF	DEXreg
		MOVF	Ct+1,W
		SUBWFB	DEXreg+1
		BTFSS	DEXreg+1,7
		GOTO	$+6
		MOVLW	0FF
		MOVWF	DEXreg+2
		MOVWF	DEXreg+3
		CALLF	Divide2416
		MOVE	CEXreg,Gh
	; Move the results
		MOVEC	Gh,Src
		MOVLW	4
		MOVLB	HIGH Cnt
		MOVWF	Cnt
		CALL	BlkMove
		RETURN

; Define a channels gain parameters to convert raw ADC counts to normalized units
; for a centering channel.
; Steps:
;	1.) Read center position
;	2.) Read RT/DWN position
;	3.) Read LT/UP position
;	Ct = center value
;	GH = 1000 * 256/(RT/DWN-Ct)
;	GL = 1000 * 256/(Ct-LT/UP)
; Results placed in the following reg during the calculations then moved to
; final location:
;	Gh,Ct,Gl
; On call the parameters needed are packed in the DXreg. The MSB contains
; the ADC channel number and the LSB contains the low 8 bit of the location
; address for the results. Its assumed that are destinations are in the
; same page.
; DXreg = (ADC channel):(low byte address of Destination)
JScChan
	; Load the Dst register and the ADC channel
		MOVLB	HIGH DXreg
		MOVF	DXreg,W
		MOVWF	Dst
		MOVLW	HIGH (AHG)
		MOVWF	Dst+1
		MOVF	DXreg+1,W
	; Save channel in Areg
		MOVLB	HIGH Atemp
		MOVWF	Atemp
	; Get the center position
		CALLFL	LCDsendCMD,LINE2
		PrintMess JCALMES14
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	$-6
		MOVLB	HIGH Atemp
		MOVF	Atemp,W
		CALLFW	ReadADC256
		MOVFF	ADCsum+1,Ct
		MOVFF	ADCsum+2,Ct+1
		MOVLW	D'250'
		CALLFW	Delay1mS
	; Get the RT/DWN position
		CALLFL	LCDsendCMD,LINE2
		PrintMess JCALMES15
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	$-6
		MOVLB	HIGH Atemp
		MOVF	Atemp,W
		CALLFW	ReadADC256
		MOVFF	ADCsum+1,Gh
		MOVFF	ADCsum+2,Gh+1
		MOVLW	D'250'
		CALLFW	Delay1mS
	; Get the LT/UP position
		CALLFL	LCDsendCMD,LINE2
		PrintMess JCALMES16
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	$-6
		MOVLB	HIGH Atemp
		MOVF	Atemp,W
		CALLFW	ReadADC256
		MOVFF	ADCsum+1,Gl
		MOVFF	ADCsum+2,Gl+1
		MOVLW	D'250'
		CALLFW	Delay1mS
	; Calculate the gain values.
	; Gh = (1000 * 256)/(Gh-Ct)
		; Set the 32 bit CEXreg to 1000 time 256
		MOVLB	HIGH CEXreg
		MOVLW	LOW (D'1000')
		MOVWF	CEXreg+1
		MOVLW	HIGH (D'1000')
		MOVWF	CEXreg+2
		MOVLW	0
		CLRF	CEXreg
		CLRF	CEXreg+3
		;
		MOVE	Gh,DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLB	HIGH Ct
		MOVF	Ct,W
		SUBWF	DEXreg
		MOVF	Ct+1,W
		SUBWFB	DEXreg+1
		BTFSS	DEXreg+1,7
		GOTO	$+6
		MOVLW	0FF
		MOVWF	DEXreg+2
		MOVWF	DEXreg+3
		CALL	Divide2416
		MOVE	CEXreg,Gh
	; Gl = (1000 * 256)/(Ct-Gl)
		; Set the 32 bit CEXreg to 1000 time 256
		MOVLB	HIGH CEXreg
		MOVLW	LOW (D'1000')
		MOVWF	CEXreg+1
		MOVLW	HIGH (D'1000')
		MOVWF	CEXreg+2
		MOVLW	0
		CLRF	CEXreg
		CLRF	CEXreg+3
		;
		MOVE	Ct,DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLB	HIGH Gl
		MOVF	Gl,W
		SUBWF	DEXreg
		MOVF	Gl+1,W
		SUBWFB	DEXreg+1
		BTFSS	DEXreg+1,7
		GOTO	$+6
		MOVLW	0FF
		MOVWF	DEXreg+2
		MOVWF	DEXreg+3
		CALL	Divide2416
		MOVE	CEXreg,Gl
	; Move the results
		MOVEC	Gh,Src
		MOVLW	6
		MOVLB	HIGH Cnt
		MOVWF	Cnt
		CALL	BlkMove
		RETURN
		
; This function is used to calibrate the voltmeter used for
; both the transmitter voltage monitor and the receiver voltmeter.
; On call:
;             Ftemp = ADC channel number
;             BXreg = Voltmeter gain control, this value is
;                     adjusted by this function and contains the
;                     result when this function exits.		
CalVoltMeter
		CALLFL	Delay1mS,D'20'
	; Read the ADC and calculate the voltage
		MOVLB	HIGH Ftemp
		MOVF	Ftemp,W
		CALLFW	ADCread
	; Display the voltage
		CALLFL	LCDsendCMD,LINE2
		PrintMess MVOLTS
		CALLFL	LCDsendCMD,LINE2+CVMPOS
		MOVE	Pos,AXreg
		CALL	Mult1616
		MOVF	CEXreg+1,W
		MOVWF	CEXreg
		MOVF	CEXreg+2,W
		MOVWF	CEXreg+1
		CLRF	CEXreg+2
		CALL	Int2Str
		MOVLW	' '
		MOVWF	Areg
		MOVLW	'0'
		CPFSGT	Buffer
		MOVFF	Areg,Buffer
		CALLFF	LCDsendData,Buffer
		CALLFF	LCDsendData,Buffer+1
		CALLFL	LCDsendData,'.'
		CALLFF	LCDsendData,Buffer+2
		CALLFF	LCDsendData,Buffer+3
	; Test the elevator stick and adjust the gain
		CALL	Elevator
		BTFSS	ALUSTA,Z,A
		GOTO	CalVolt1
		MOVLB	HIGH BXreg
		INCF	BXreg
		BTFSC	ALUSTA,Z,A
		INCF	BXreg+1
		GOTO	CalVoltMeter
CalVolt1
		BTFSS	ALUSTA,C,A
		GOTO	CalVolt2
		MOVLB	HIGH BXreg
		DECF	BXreg
		MOVLW	0FF
		CPFSLT	BXreg
		DECF	BXreg+1
		GOTO	CalVoltMeter
	; Exit if the Option button is pressed
CalVolt2
		CALL	Option
		BTFSS	ALUSTA,C,A
		GOTO	CalVoltMeter		
		RETURN


; This function is called after the frequence band is changed

PostBand
		MOVLW	0FF
		MOVFF	WREG,ModelChannel
		CALL	PLLinit
		RETURN
		
; This function is called after the pilot has selected the desired channel order.
; This function uses the value in Atemp to define the order:
; 1 = ACE,EART5678
; 2 = Futaba, AETR5678
; 3 = Airtronics, EATR5678
; 4 = JR, TAER5678
PostSetOrder
	; Set channels 5,6,7, and 8. These are the same for all configurations
		MOVLB	HIGH ChannelOrder
		MOVLW	5
		MOVWF	ChannelOrder+4
		MOVLW	6
		MOVWF	ChannelOrder+5
		MOVLW	7
		MOVWF	ChannelOrder+6
		MOVLW	8
		MOVWF	ChannelOrder+7		
	; Test the selected order and set A,E,R,T depending on option selected.
		MOVLB	HIGH Atemp
		MOVLW	1
		CPFSEQ	Atemp
		GOTO	PSO1
	; Here if ACE order
		MOVLB	HIGH ChannelOrder
		MOVLW	2
		MOVWF	ChannelOrder
		MOVLW	1
		MOVWF	ChannelOrder+1
		MOVLW	3
		MOVWF	ChannelOrder+2
		MOVLW	4
		MOVWF	ChannelOrder+3		
		RETURN
	; Test if Futaba
PSO1
		MOVLB	HIGH Atemp
		MOVLW	2
		CPFSEQ	Atemp
		GOTO	PSO2
	; Here if Futaba order
		MOVLB	HIGH ChannelOrder
		MOVLW	1
		MOVWF	ChannelOrder
		MOVLW	2
		MOVWF	ChannelOrder+1
		MOVLW	4
		MOVWF	ChannelOrder+2
		MOVLW	3
		MOVWF	ChannelOrder+3		
		RETURN
	; Test if Airtronics
PSO2
		MOVLB	HIGH Atemp
		MOVLW	3
		CPFSEQ	Atemp
		GOTO	PSO3
	; Here if Airtronics order
		MOVLB	HIGH ChannelOrder
		MOVLW	2
		MOVWF	ChannelOrder
		MOVLW	1
		MOVWF	ChannelOrder+1
		MOVLW	4
		MOVWF	ChannelOrder+2
		MOVLW	3
		MOVWF	ChannelOrder+3		
		RETURN
	; Test if JR
PSO3
		MOVLB	HIGH Atemp
		MOVLW	4
		CPFSEQ	Atemp
		RETURN
	; Here if JR order
		MOVLB	HIGH ChannelOrder
		MOVLW	4
		MOVWF	ChannelOrder
		MOVLW	1
		MOVWF	ChannelOrder+1
		MOVLW	2
		MOVWF	ChannelOrder+2
		MOVLW	3
		MOVWF	ChannelOrder+3		
		RETURN

;
; The following routines are the Apply to All options supported in the system menu
;
		
		
		
		
		
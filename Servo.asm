; The following two functions are rounding functions used by the servo UI
; calibration routines. These routiens are called before the divide calls 
; in the Convert2Times and Convert2Gains functions. These routines add 1/2
; the divisor to the dividend that is located in the CEXreg.
;
; Added Nov 29, 2009
Round256
	; Test the sign of CEXreg
		MOVLB	HIGH CEXreg
		BTFSC	CEXreg+3,7
		GOTO	R256_1
	; Here is CEX is positive
		MOVLW	LOW (D'128')
		ADDWF	CEXreg,F
		MOVLW	0
		ADDWFC	CEXreg+1,F
		ADDWFC	CEXreg+2,F
		ADDWFC	CEXreg+3,F
		RETURN
R256_1
	; Here is CEX is negative			
		MOVLW	LOW (D'128')
		SUBWF	CEXreg,F
		MOVLW	0
		SUBWFB	CEXreg+1,F
		SUBWFB	CEXreg+2,F
		SUBWFB	CEXreg+3,F
	; Exit
		RETURN

Round1000
	; Test the sign of CEXreg
		MOVLB	HIGH CEXreg
		BTFSC	CEXreg+3,7
		GOTO	R1000_1
	; Here is CEX is positive
		MOVLW	LOW (D'500')
		ADDWF	CEXreg,F
		MOVLW	HIGH (D'500')
		ADDWFC	CEXreg+1,F
		MOVLW	0
		ADDWFC	CEXreg+2,F
		ADDWFC	CEXreg+3,F
		RETURN
R1000_1
	; Here is CEX is negative			
		MOVLW	LOW (D'128')
		SUBWF	CEXreg,F
		MOVLW	0
		SUBWFB	CEXreg+1,F
		SUBWFB	CEXreg+2,F
		SUBWFB	CEXreg+3,F
	; Exit
		RETURN
; 
; This file contains the Servo User Interface Pre and Post functions. The 
; Pre function is called before the selected user interface option is processed
; by the user interface routines and the Post function is called after the
; user interface routine returns. These funtions move the servo data into
; a generic area before the user adjust parameters and returns the data to
; the correct specific place when finished.
;
; This function is used to convert the normalized position data into time
; in units of .5 uSec. This is done using generic parameters. The caller
; fills the generic parameters with the channel specfic data.
;
; The following calculations are performed:
; CENTER = CENTER
; RTDWN = (1000 * G)/256 + CENTER
; LTUP = (-1000 * G)/256 + CENTER
;
Convert2Times
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
		; RT/DWN
		MOVE16	RTDWN,AXreg
		MOVEC	D'1000',BXreg
		; If the gain is negative, set the reverse servo flag
		CLRF	WREG
		BTFSC	AXreg+1,7
		SETF	WREG
		MOVFF	WREG,ServoREV
		MOVFF	WREG,ServoREV+1		; Need two copies to see if user makes a change
		; End of reverse flag code
		CALL	Mult1616
		CALL	Round256
		MOVEC	D'256',DEXreg
		CALL	Divide2416
		MOVE16	CEXreg,RTDWN
		MOVLB	HIGH RTDWN
		MOVF	CENTER,W
		ADDWF	RTDWN,F
		MOVF	CENTER+1,W
		ADDWFC	RTDWN+1,F
		; LF/UP
		MOVE16	LTUP,AXreg
		MOVEC	D'1000',BXreg
		CALL	Mult1616
		CALL	Round256
		MOVEC	D'256',DEXreg
		CALL	Divide2416
		MOVE16	CENTER,LTUP
		MOVF	CEXreg,W
		SUBWF	LTUP,F
		MOVF	CEXreg+1,W
		SUBWFB	LTUP+1,F
		; Limit test
		MOVE16	RTDWN,AXreg
		CALL	ApplyLimit
		MOVE16	AXreg,RTDWN
		MOVE16	CENTER,AXreg
		CALL	ApplyLimit
		MOVE16	AXreg,CENTER
		MOVE16	LTUP,AXreg
		CALL	ApplyLimit
		MOVE16	AXreg,LTUP
		;
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN
; The following calculations are performed:
; RTDWN  = (1000 * RTDWN)/256 + CENTER
; CENTER = (-1000 * RTDWN)/256 + CENTER
Convert2TimesNC
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
		; 
		MOVE16	RTDWN,AXreg
		MOVEC	D'1000',BXreg
		; If the gain is negative, set the reverse servo flag
		CLRF	WREG
		BTFSC	AXreg+1,7
		SETF	WREG
		MOVFF	WREG,ServoREV
		MOVFF	WREG,ServoREV+1		; Need two copies to see if user makes a change
		; End of reverse flag code
		CALL	Mult1616
		CALL	Round256
		MOVEC	D'256',DEXreg
		CALL	Divide2416
		; CEXreg = 1000*RTDWN/256
		MOVE16	CENTER,RTDWN
		MOVLB	HIGH RTDWN
		MOVF	CEXreg,W
		ADDWF	RTDWN,F
		MOVF	CEXreg+1,W
		ADDWFC	RTDWN+1,F
		;
		MOVF	CEXreg,W
		SUBWF	CENTER,F
		MOVF	CEXreg+1,W
		SUBWFB	CENTER+1,F
		; Limit test
		MOVE16	RTDWN,AXreg
		CALL	ApplyLimit
		MOVE16	AXreg,RTDWN
		MOVE16	CENTER,AXreg
		CALL	ApplyLimit
		MOVE16	AXreg,CENTER
		;
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN

Convert2Gains
	; RTDWN = ((RTDWN - CENTER) * 256)/1000
	; LTUP =  ((CENTER - LTUP) * 256)/1000
	; CENTER = CENTER
		; RTDWN
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
		MOVE16	RTDWN,AXreg
		MOVF	CENTER,W
		SUBWF	AXreg,F
		MOVF	CENTER+1,W
		SUBWFB	AXreg+1,F
		MOVEC	D'256',BXreg
		CALL	Mult1616
		CALL	Round1000
		MOVEC	D'1000',DEXreg
		CALL	Divide2416
		MOVE16	CEXreg,RTDWN
		; LTUP
		MOVE16	CENTER,AXreg
		MOVF	LTUP,W
		SUBWF	AXreg,F
		MOVF	LTUP+1,W
		SUBWFB	AXreg+1,F
		MOVEC	D'256',BXreg
		CALL	Mult1616
		CALL	Round1000
		MOVEC	D'1000',DEXreg
		CALL	Divide2416
		MOVE16	CEXreg,LTUP
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN
Convert2GainsNC
	; RTDWN = ((RTDWN - CENTER) * 256)/2000
	; CENTER = CENTER + (1000*RTDWN)/256
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
		MOVE16	RTDWN,AXreg
		MOVLB	HIGH CENTER
		MOVF	CENTER,W
		SUBWF	AXreg,F
		MOVF	CENTER+1,W
		SUBWFB	AXreg+1,F
		MOVEC	D'256',BXreg
		CALL	Mult1616
		CALL	Round1000
		CALL	Round1000
		MOVEC	D'2000',DEXreg
		CALL	Divide2416
		MOVE16	CEXreg,RTDWN
		;
		MOVE16	RTDWN,AXreg
		MOVEC	D'1000',BXreg
		CALL	Mult1616
		CALL	Round256
		MOVEC	D'256',DEXreg
		CALL	Divide2416
		MOVLB	HIGH CENTER
		MOVF	CEXreg,W
		ADDWF	CENTER,F
		MOVF	CEXreg+1,W
		ADDWFC	CENTER+1,F
		;
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN

; If Auto Trim button was pressed and we were adjusting 
; a servo limit, then apply it to the other limit, with
; equal extent...
ApplySymSet	
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
		MOVLB	HIGH SymSet
		BTFSS	SymSet,0
		GOTO	NoAT
		; Here if the Auto Trim button was set, BXreg points to the var
		; of intrest.
		; Does BXreg point to RTDWN, if so LTUP = 2*CENTER - RTDWN
		MOVLW	HIGH RTDWN
		MOVLB	HIGH BXreg
		XORWF	BXreg,W
		BTFSC	ALUSTA,Z,A
		GOTO	NotRTDWN
		; Here if its RTDWN
		MOVE16	CENTER,CEXreg
		BCF	ALUSTA,C,A
		RLCF	CEXreg
		RLCF	CEXreg+1
		MOVF	RTDWN,W
		SUBWF	CEXreg
		MOVF	RTDWN+1,W
		SUBWFB	CEXreg+1
		MOVE16	CEXreg,LTUP
		GOTO	NoAT
		; Does BXreg point to LTUP, if so RTDWN = 2*CENTER - LTUP
NotRTDWN
		MOVLW	HIGH LTUP
		MOVLB	HIGH BXreg
		XORWF	BXreg,W
		BTFSC	ALUSTA,Z,A
		GOTO	NoAT
		; Here if its RTDWN
		MOVE16	CENTER,CEXreg
		BCF	ALUSTA,C,A
		RLCF	CEXreg
		RLCF	CEXreg+1
		MOVF	LTUP,W
		SUBWF	CEXreg
		MOVF	LTUP+1,W
		SUBWFB	CEXreg+1
		MOVE16	CEXreg,RTDWN
		; Test the exit flag
NoAT
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN


AilPre
	; Move the Aileron servo parameters into the general area
	; and convert gains into positions in uS
		MOVLW	chAIL
		MOVLB	HIGH DriveCh
		MOVWF	DriveCh
		MOVEC	AM1H,Src
AERPre	; This is a common entry point for the Aileron Elevetor and Rudder Pre
	; routines
		MOVEC	RTDWN,Dst
		MOVLW	D'11'
		MOVWF	Cnt
		CALL	BlkMove
		CLRF	ATRST
	; Convert into times
		CALL	Convert2Times
		RETURN
ElePre
		MOVLW	chELE
		MOVLB	HIGH DriveCh
		MOVWF	DriveCh
		MOVEC	EM1H,Src
		GOTO	AERPre
RudPre
		MOVLW	chRUD
		MOVLB	HIGH DriveCh
		MOVWF	DriveCh
		MOVEC	RM1H,Src
		GOTO	AERPre

AilPost
		MOVEC	AM1H,Dst
AERPost	; This is a common entry point for the Aileron Elevetor and Rudder Post
	; routines
	; Apply the Symertical set routine
		CALL	ApplySymSet
	; Test for autotrim reset
		BTFSC	ATRST,0
		CLRF	ATRM
	; Now convert back to the radios units
		CALL	Convert2Gains
	; Move the results back
		MOVEC	RTDWN,Src
		MOVLW	D'11'
		MOVWF	Cnt
		CALL	BlkMove
	; Clear the Drive Channel value
		MOVLB	HIGH DriveCh
		CLRF	DriveCh
		RETURN
		
ElePost
		MOVEC	EM1H,Dst
		GOTO	AERPost

RudPost
		MOVEC	RM1H,Dst
		GOTO	AERPost

ThtPre
	; Save registers
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
	; Convert all of the throttle parameters into uS
		MOVLB	HIGH TBH
		; High
		MOVE16	TMH,AXreg
		MOVEC	D'1000',BXreg
		; If the gain is negative, set the reverse servo flag
		CLRF	WREG
		BTFSC	AXreg+1,7
		SETF	WREG
		MOVFF	WREG,ServoREV
		MOVFF	WREG,ServoREV+1		; Need two copies to see if user makes a change
		; End of reverse flag code
		CALL	Mult1616
		CALL	Round256
		MOVEC	D'256',DEXreg
		CALL	Divide2416
		MOVE16	CEXreg,TMH
		MOVLB	HIGH TBH
		MOVF	TBH,W
		ADDWF	TMH,F
		MOVF	TBH+1,W
		ADDWFC	TMH+1,F
	; Restore registers
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN

ThtPost
	; Save registers
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
	; Restore the throttle parameters
		; High
		MOVE16	TMH,AXreg
		MOVLB	HIGH TMH
		MOVF	TBH,W
		MOVLB	HIGH AXreg
		SUBWF	AXreg,F
		MOVLB	HIGH TMH
		MOVF	TBH+1,W
		MOVLB	HIGH AXreg
		SUBWFB	AXreg+1,F
		MOVEC	D'256',BXreg
		CALL	Mult1616
		CALL	Round1000
		MOVEC	D'1000',DEXreg
		CALL	Divide2416
		MOVE16	CEXreg,TMH
	; Restore registers
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
	; Clear the Drive Channel value
		MOVLB	HIGH DriveCh
		CLRF	DriveCh
		RETURN

CH5Pre
		MOVLW	chCH5
		MOVLB	HIGH DriveCh
		MOVWF	DriveCh
	; Move the CH5 servo parameters into the general area
	; and convert gains into positions in uS
		MOVEC	CH5MH,Src
CH567Pre
		MOVEC	RTDWN,Dst
		MOVLW	4
		MOVWF	Cnt
		CALL	BlkMove
	; Convert into times, as follows
		CALL	Convert2TimesNC
		RETURN
CH6Pre
		MOVLW	chCH6
		MOVLB	HIGH DriveCh
		MOVWF	DriveCh
		MOVEC	CH6MH,Src
		GOTO	CH567Pre
CH7Pre
		MOVLW	chCH7
		MOVLB	HIGH DriveCh
		MOVWF	DriveCh
		MOVEC	CH7MH,Src
		GOTO	CH567Pre
		
CH5Post
		MOVEC	CH5MH,Dst
CH567Post
	; Convert back to the radios units
		CALL	Convert2GainsNC
	; Move the results back
		MOVEC	RTDWN,Src
		MOVLW	4
		MOVWF	Cnt
		CALL	BlkMove
	; Clear the Drive Channel value
		MOVLB	HIGH DriveCh
		CLRF	DriveCh
		RETURN
CH6Post
		MOVEC	CH6MH,Dst
		GOTO	CH567Post
CH7Post
		MOVEC	CH7MH,Dst
		GOTO	CH567Post
CH8Pre
	; Move the selected servo parameters into the general area
	; and convert gains into positions in uS
		MOVEC	CH8_A,Src
		MOVEC	RTDWN,Dst
		MOVLW	6
		MOVWF	Cnt
		CALL	BlkMove
	; Convert into times, as follows
		CALL	Convert2Times
		RETURN
CH8Post
	; Now convert back to the radios units
		CALL	Convert2Gains
	; Move the results back
		MOVEC	RTDWN,Src
		MOVEC	CH8_A,Dst
		MOVLW	6
		MOVWF	Cnt
		CALL	BlkMove
	; Clear the Drive Channel value
		MOVLB	HIGH DriveCh
		CLRF	DriveCh
		RETURN

; This function moves the servo limits to the min and max values
; used by the user interface input routines
SerLim
		MOVE16	ServoMin,MinTime
		MOVE16	ServoMax,MaxTime
		RETURN


;
; The following routines are used for the servo direction reverse function.
;
SrevCPost
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
		; If the ServoREV flags do not match then the user has made a change so
		; reverse the position limits before proceeding
		MOVLB	HIGH ServoREV
		MOVFF	ServoREV,WREG
		XORWF	ServoREV+1
		BZ	SCP_RevDone
		MOVE16	RTDWN,AXreg
		MOVE16	LTUP,RTDWN
		MOVE16	AXreg,LTUP
SCP_RevDone	
		MOVFF	ServoREV,WREG
		MOVFF	WREG,ServoREV+1
		; End of servo reverse code
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN

SrevNCPost
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
		; If the ServoREV flags do not match then the user has made a change so
		; reverse the position limits before proceeding
		MOVLB	HIGH ServoREV
		MOVFF	ServoREV,WREG
		XORWF	ServoREV+1
		BZ	SNCP_RevDone
		MOVE16	RTDWN,AXreg
		MOVE16	CENTER,RTDWN
		MOVE16	AXreg,CENTER
SNCP_RevDone	
		MOVFF	ServoREV,WREG
		MOVFF	WREG,ServoREV+1
		; End of servo reverse code
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN

TrevPost
		MOVE16	AXreg,AXregS
		MOVE16	BXreg,BXregS
		; If the ServoREV flags do not match then the user has made a change so
		; reverse the position limits before proceeding
		MOVLB	HIGH ServoREV
		MOVFF	ServoREV,WREG
		XORWF	ServoREV+1
		BZ	TP_RevDone
		MOVE16	TBH,AXreg
		MOVE16	TMH,TBH
		MOVE16	AXreg,TMH
TP_RevDone	
		MOVFF	ServoREV,WREG
		MOVFF	WREG,ServoREV+1
		; End of servo reverse code
		MOVE16	AXregS,AXreg
		MOVE16	BXregS,BXreg
		RETURN


; The following code is used for the slew rate controls on CH 5 and
; CH 8.

; This function converts the step size into a servo transent time in
; .1 sec units.
PostCH5
	; If user set the time to 0 then set the step size to 2000 and exit
		MOVFF	CH5stepSize,WREG
		TSTFSZ	WREG,A
		GOTO	PreCH5
		MOVEC	D'2000',CH5stepSize
		RETURN
PreCH5
	; t = 500 / step size
		CLRF	WREG
		MOVFF	WREG,CEXreg+2
		MOVEC	D'500',CEXreg
		MOVE	CH5stepSize,DEXreg
		CALL	Divide2416
	; Move results to step size
		MOVE	CEXreg,CH5stepSize
		CLRF	WREG
		MOVFF	WREG,CH5stepSize+1
		MOVFF	CH5stepSize,WREG
		RETURN

PostCH8
	; If user set the time to 0 then set the step size to 2000 and exit
		MOVFF	CH8stepSize,WREG
		TSTFSZ	WREG,A
		GOTO	PreCH8
		MOVEC	D'2000',CH8stepSize
		RETURN
PreCH8
	; t = 500 / step size
		CLRF	WREG
		MOVFF	WREG,CEXreg+2
		MOVEC	D'500',CEXreg
		MOVE	CH8stepSize,DEXreg
		CALL	Divide2416
	; Move results to step size
		MOVE	CEXreg,CH8stepSize
		CLRF	WREG
		MOVFF	WREG,CH8stepSize+1
		MOVFF	CH8stepSize,WREG
		RETURN

; This function will reset all the Sub Trim values to zero if the YESNO flag is
; set.
STreset
	; Test the YESNO flag and exit if the flag is not set
		MOVLB	HIGH YESNO
		BTFSS	YESNO,7
		RETURN
	; Here to clear the sub trim values
		CLRF	WREG
		MOVFF	WREG,SubTrim
		MOVFF	WREG,SubTrim+1
		MOVFF	WREG,SubTrim+2
		MOVFF	WREG,SubTrim+3
		MOVFF	WREG,SubTrim+4
		MOVFF	WREG,SubTrim+5
		MOVFF	WREG,SubTrim+6
		MOVFF	WREG,SubTrim+7
		RETURN

; This file contains the Options User Interface Pre and Post functions. The 
; Pre function is called before the selected user interface option is processed
; by the user interface routines and the Post function is called after the
; user interface routine returns. 

; This function will move the Temp table data (CalTable) to the 
; location pointed to by the DXreg.
Temp2Table
		MOVEC	CalTable,Src
		MOVE16	DXregS,Dst
		MOVLW	D'11'
		MOVWF	Cnt
		CALLF	BlkMove
		RETURN
		
; This function will move the table data defined in DXreg to the
; Temp table (CalTable).
Table2Temp
		MOVEC	CalTable,Dst
		MOVE16	DXreg,Src
		MOVE16	DXreg,DXregS
		MOVLW	D'11'
		MOVWF	Cnt
		CALL	BlkMove  
		RETURN

; This function will reset the Auto Trim values to zero if the YESNO flag is
; set.
ATreset
	; Test the YESNO flag and exit if the flag is not set
		MOVLB	HIGH YESNO
		BTFSS	YESNO,7
		RETURN
	; Here to clear the reset values
		MOVLB	HIGH AAT
		CLRF	AAT
		CLRF	EAT
		CLRF	RAT
		RETURN


; This function will copy the current trim positions to the trim zero  variables if
; the YESNO flag is set.
TrimZero
	; Test the YESNO flag and exit if the flag is not set
		MOVLB	HIGH YESNO
		BTFSS	YESNO,7
		RETURN
	; Aileron
		MOVE16	TrimZeroAil,CEXreg
		MOVF	Atrim,W
		ADDWF	CEXreg,F
		MOVF	Atrim+1,W
		ADDWFC	CEXreg+1,F
		MOVE16	CEXreg,TrimZeroAil
	; Elevator
		MOVE16	TrimZeroEle,CEXreg
		MOVF	Etrim,W
		ADDWF	CEXreg,F
		MOVF	Etrim+1,W
		ADDWFC	CEXreg+1,F
		MOVE16	CEXreg,TrimZeroEle
	; Rudder
		MOVE16	TrimZeroRud,CEXreg
		MOVF	Rtrim,W
		ADDWF	CEXreg,F
		MOVF	Rtrim+1,W
		ADDWFC	CEXreg+1,F
		MOVE16	CEXreg,TrimZeroRud
		RETURN

		
; This function will clear the Trim zero variables. This function is only performed 
; is the YESNO flag is set.
TrimZeroClear
	; Test the YESNO flag and exit if the flag is not set
		MOVLB	HIGH YESNO
		BTFSS	YESNO,7
		RETURN
	; Clear the Trim Zero variables
		MOVLB	HIGH TrimZeroAil
		CLRF	TrimZeroAil
		CLRF	TrimZeroAil+1
		CLRF	TrimZeroEle
		CLRF	TrimZeroEle+1
		CLRF	TrimZeroRud
		CLRF	TrimZeroRud+1
		RETURN
		
; This function will set the variable limits for the alternate aircraft function. This 
; limit is NumAircraft.
SetAftRange
		MOVLB	HIGH MinByte
		CLRF	MinByte	
		INCF	MinByte
		MOVLW	NumAircraft
		MOVLB	HIGH MaxByte
		MOVWF	MaxByte	
		RETURN

; This function will copy the current aircraft data into the select aircraft number. The
; selected aircraft number is saved in mto. If mto is set to zero then nothing is done.
CopyAFT
	; Do the copy operation if Mto is > 0
		MOVLB	HIGH Mto
		MOVF	Mto,W
		TSTFSZ	Mto
		GOTO	CopyAFTgo  
		RETURN
	; Copy the aircraft number to a temp variable then move Mto 
	; to aircraft number and call SaveAircraft...
CopyAFTgo
		MOVLB	HIGH Aircraft
		MOVFF	Aircraft,Areg
		MOVWF	Aircraft
		MOVLB	HIGH Mto
		MOVFF	Areg,Mto
		CALL	SaveAircraft
		MOVLB	HIGH Mto
		MOVFF	Mto,Areg
		MOVLB	HIGH Aircraft
		MOVFF	Areg,Aircraft
		RETURN
		
; This function will copy the Auto Trim values to the Trim Zero variables and then
; clear the Auto Trim values. This function is only performed is the YESNO flag is
; set.
AutoTrim2Zero
	; Test the YESNO flag and exit if the flag is not set
		MOVLB	HIGH YESNO
		BTFSS	YESNO,7
		RETURN
	; Aileron channel
		MOVLB	HIGH AAT
		MOVF	AAT,W
		CLRF	AAT
		MOVFF	APT,Areg
		MOVLB	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		BTFSC	WREG,7
		SETF	AXreg+1
		RLCF	AXreg			; Multiply by 2
		RLCF	AXreg+1		
		MOVEC	D'100',BXreg
		CALL	Mult1616
		MOVFF	Areg,DEXreg
		CLRF	DEXreg+1
		CALL	Divide2416
		MOVF	CEXreg,W
		MOVLB	HIGH TrimZeroAil
		ADDWF	TrimZeroAil,F
		MOVLB	HIGH CEXreg
		MOVF	CEXreg+1,W
		MOVLB	HIGH TrimZeroAil
		ADDWFC	TrimZeroAil+1,F
	; Elevator channel
		MOVLB	HIGH EAT
		MOVF	EAT,W
		CLRF	EAT
		MOVFF	EPT,Areg
		MOVLB	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		BTFSC	WREG,7
		SETF	AXreg+1
		RLCF	AXreg			; Multiply by 2
		RLCF	AXreg+1
		MOVEC	D'100',BXreg
		CALLF	Mult1616
		MOVFF	Areg,DEXreg
		CLRF	DEXreg+1
		CALL	Divide2416
		MOVF	CEXreg,W
		MOVLB	HIGH TrimZeroEle
		ADDWF	TrimZeroEle,F
		MOVLB	HIGH CEXreg
		MOVF	CEXreg+1,W
		MOVLB	HIGH TrimZeroEle
		ADDWFC	TrimZeroEle+1,F
	; Rudder channel
		MOVLB	HIGH RAT
		MOVF	RAT,W
		CLRF	RAT
		MOVFF	RPT,Areg
		MOVLB	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		BTFSC	WREG,7
		SETF	AXreg+1
		RLCF	AXreg			; Multiply by 2
		RLCF	AXreg+1
		MOVEC	D'100',BXreg
		CALL	Mult1616
		MOVFF	Areg,DEXreg
		CLRF	DEXreg+1
		CALL	Divide2416
		MOVF	CEXreg,W
		MOVLB	HIGH TrimZeroRud
		ADDWF	TrimZeroRud,F
		MOVLB	HIGH CEXreg
		MOVF	CEXreg+1,W
		MOVLB	HIGH TrimZeroRud
		ADDWFC	TrimZeroRud+1,F
		RETURN

; This function will copy the default aircraft paraameters into memory. This function 
; is only performed is the YESNO flag is set.
SetDefault
	; Test the YESNO flag and exit if the flag is not set
		MOVLB	HIGH YESNO
		BTFSS	YESNO,7
		RETURN
	; Set the aircraft defaults
		CALL	LoadAircraftDefaults
		RETURN
		

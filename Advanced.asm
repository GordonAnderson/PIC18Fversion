;
; This file contins the processing routine specific to the Advanced menu selections.
;

; convert Rreg50 to frequency in KHz units.
PreRef
   ; Save registers
	MOVE	AXreg,AXregS
	MOVE	BXreg,BXregS
   ; Save the current value
   	MOVE24	Rreg50,Rreg53
   ; Convert the value into the reference freq in KHz
   	MOVLR	HIGH Rreg50
   	RRCF	Rreg50+2
   	RRCF	Rreg50+1
   	RRCF	Rreg50
   	RRCF	Rreg50+2
   	RRCF	Rreg50+1
   	RRCF	Rreg50
	CLRF	Rreg50+2
	MOVLW	0x3F
	ANDWF	Rreg50+1,F
   ; The ref for the 50MHz band is assumed to be 20KHz so
   ; now multiply by 20 to get in KHz units
   	MOVE	Rreg50,AXreg
   	MOVEC	D'20',BXreg
   	CALL	Mult1616
   	MOVE	CEXreg,Rreg50
   ; Now we are ready for the pilot to select the ref freq!
   ; Restore registers
	MOVE	AXregS,AXreg
	MOVE	BXregS,BXreg
	RETURN
	
; convert the frequency back to Rreg50 value
PostRef
   ; Save registers
	MOVE	AXreg,AXregS
	MOVE	BXreg,BXregS
   ; first divide by 5 to get Rreg units
   	MOVE	Rreg50,CEXreg
   	MOVLR	HIGH CEXreg
   	CLRF	CEXreg+2
   	MOVEC	D'5',DEXreg
   	CALL	Divide2416
   ; Now clear all but the 14 counter bits in all three Rreg sets, 50, 53, and 72MHz
   	MOVLR	HIGH Rreg53
   	MOVLW	0x03
   	ANDWF	Rreg53,F
   	MOVLW	0x00
   	ANDWF	Rreg53+1,F
   	MOVE24	Rreg53,Rreg50
   	MOVE24	Rreg53,Rreg72
   ; Make sure the 2 LSB are zero
   	MOVLR	HIGH CEXreg
   	MOVLW	0xFC
   	ANDWF	CEXreg,F
   ; Move the counter data into the regs
   	MOVFF	CEXreg,WREG
   	IORWF	Rreg50
   	IORWF	Rreg53
   	MOVFF	CEXreg+1,WREG
   	IORWF	Rreg50+1
   	IORWF	Rreg53+1
   ; Multiply count by two and then apply to the 72MHz reg
	BCF	ALUSTA,C
   	MOVLR	HIGH CEXreg
   	RLCF	CEXreg
   	RLCF	CEXreg+1
   	MOVLR	HIGH Rreg72
   	MOVFF	CEXreg,WREG
   	IORWF	Rreg72
   	MOVFF	CEXreg+1,WREG
   	IORWF	Rreg72+1
   ; Done   	
   ; Restore registers
	MOVE	AXregS,AXreg
	MOVE	BXregS,BXreg
	RETURN
	
	
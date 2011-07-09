;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; EEPROM read/write functions
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

; This function reads 256 bytes from the EEPROM and fills RAM page
; 5 with its contents. The EEPROM holds configureation data as well
; as the Transmitter on time parameter
EEPROMread
	; Setup pointer to RAM
		MOVLW	5
		MOVWF	FSR1H,A
		CLRF	WREG
		MOVWF	FSR1L,A
	; EEPROM address setup
		CLRF	WREG 		; EEPROM high address high address
		MOVWF 	EEADRH,A	; Upper bits of Data Memory Address to read
		CLRF 	WREG 	;
		MOVWF 	EEADR,A		; Lower bits of Data Memory Address to read
EEPROMnext
		BCF 	EECON1, EEPGD,A	; Point to DATA memory
		BCF 	EECON1, CFGS,A 	; Access EEPROM
		BSF 	EECON1, RD,A 	; EEPROM Read
		MOVF 	EEDATA, W,A 	; W = EEDATA
		; Save results in RAM
		MOVWF	POSTINC1,A		
		; Advanced through full page
		INCF	EEADR,F,A
		BNZ	EEPROMnext
		RETURN

; This function reads a block of data from the EEPROM to memory. The low
; address of EEPROM and RAM are assumed the same so this only works for
; the first 256 byts of the EEPROM.
; 
; On call
;	AXreg = pointer to RAM memory
;	Areg  = block size in bytes
EEPROMreadBlock
	; Setup pointer to RAM
		MOVFF	AXreg+1,WREG
		MOVWF	FSR1H,A
		MOVFF	AXreg,WREG
		MOVWF	FSR1L,A
	; EEPROM address setup
		CLRF	WREG 		; EEPROM high address high address
		MOVWF 	EEADRH,A	; Upper bits of Data Memory Address to read
		MOVFF	AXreg,WREG
		MOVWF 	EEADR,A		; Lower bits of Data Memory Address to read
EEPROMnextRB
		BCF 	EECON1, EEPGD,A	; Point to DATA memory
		BCF 	EECON1, CFGS,A 	; Access EEPROM
		BSF 	EECON1, RD,A 	; EEPROM Read
		MOVF 	EEDATA, W,A 	; W = EEDATA
		; Save results in RAM
		MOVWF	POSTINC1,A		
		; Advanced through full page
		INCF	EEADR,F,A
		DECF	Areg,F,A
		BNZ	EEPROMnextRB
		RETURN


; This function reads a byte from EEPROM.
;
;	AXreg = EEPROM address
;	WREG = data byte read from EEPROM
EEPROMreadByte
		MOVFF 	AXreg+1,WREG 	;
		MOVWF 	EEADRH,A	; Upper bits of Data Memory Address to read
		MOVFF 	AXreg,WREG 	;
		MOVWF 	EEADR,A		; Lower bits of Data Memory Address to read
		BCF 	EECON1, EEPGD,A	; Point to DATA memory
		BCF 	EECON1, CFGS,A 	; Access EEPROM
		BSF 	EECON1, RD,A 	; EEPROM Read
		MOVF 	EEDATA, W,A 	; W = EEDATA
		RETURN
		
; This function writes a byte to EEPROM.
;
;	AXreg = EEPROM address
;	WREG = data byte to write to EEPROM
EEPROMwriteByte
	; Write the byte
		BCF	PIR2,EEIF,A
		MOVWF 	EEDATA,A	; Data Memory Value to write
		MOVFF 	AXreg+1,WREG 	;
		MOVWF 	EEADRH,A	; Upper bits of Data Memory Address to write
		MOVFF 	AXreg,WREG 	;
		MOVWF 	EEADR,A		; Lower bits of Data Memory Address to write
		BCF 	EECON1, EEPGD,A	; Point to DATA memory
		BCF 	EECON1, CFGS,A 	; Access EEPROM
		BSF 	EECON1, WREN,A 	; Enable writes
		BCF 	INTCON, GIE,A 	; Disable Interrupts
		MOVLW 	55h 		;
		MOVWF 	EECON2,A	; Write 55h
		MOVLW 	0AAh 		;
		MOVWF 	EECON2,A	; Write 0AAh
		BSF 	EECON1, WR,A 	; Set WR bit to begin write
		BSF 	INTCON, GIE,A 	; Enable Interrupts
	; Wait for EEIF bit to set
EEPROMwriteByteWait
		BTFSS 	PIR2,EEIF,A
		GOTO	EEPROMwriteByteWait
		BCF	PIR2,EEIF,A
		RETURN

; This function writes a word to EEPROM.
;
;	AXreg = EEPROM address
;	BXreg = data word to write to EEPROM
EEPROMwriteWord
	; Write first byte
		MOVFF	BXreg,WREG
		CALL	EEPROMwriteByte
	; Advance the address and write second byte
		MOVLR	HIGH AXreg
		INCF	AXreg
		BTFSC	ALUSTA,Z
		INCF	AXreg+1
		MOVFF	BXreg+1,WREG
		CALL	EEPROMwriteByte
		RETURN

; This function writes a block of data from memory to EEPROM. The low
; address of EEPROM and RAM are assumed the same so this only works for
; the first 256 byts of the EEPROM.
; 
; On call
;	AXreg = pointer to RAM memory
;	Areg  = block size in bytes
EEPROMwriteBlock
	; Setup pointer to RAM
		MOVFF	AXreg+1,WREG
		MOVWF	FSR1H,A
		MOVFF	AXreg,WREG
		MOVWF	FSR1L,A
	; EEPROM address setup
		CLRF	WREG 		; EEPROM high address high address
		MOVWF 	EEADRH,A	; Upper bits of Data Memory Address to read
		MOVFF	AXreg,WREG
		MOVWF 	EEADR,A		; Lower bits of Data Memory Address to read
		BCF	PIR2,EEIF,A
EEPROMnextWB
	; Write the byte
		MOVF	POSTINC1,W,A
		MOVWF	EEDATA,A	; Byte to write
		BCF 	EECON1, EEPGD,A	; Point to DATA memory
		BCF 	EECON1, CFGS,A 	; Access EEPROM
		BSF 	EECON1, WREN,A 	; Enable writes
		BCF 	INTCON, GIE,A 	; Disable Interrupts
		MOVLW 	55h 		;
		MOVWF 	EECON2,A	; Write 55h
		MOVLW 	0AAh 		;
		MOVWF 	EECON2,A	; Write 0AAh
		BSF 	EECON1, WR,A 	; Set WR bit to begin write
		BSF 	INTCON, GIE,A 	; Enable Interrupts
	; Wait for EEIF bit to set
EEPROMwriteBWait
		BTFSS 	PIR2,EEIF,A
		GOTO	EEPROMwriteBWait
		BCF	PIR2,EEIF,A
	; Advanced through the block
		INCF	EEADR,F,A
		DECF	Areg,F,A
		BNZ	EEPROMnextWB
		RETURN


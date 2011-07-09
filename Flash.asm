;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; Flash configuration storage routines
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; This function will format the Flash configuration memory.
; The default data is used for this format opertion.
FormatFlash
		SingleLine
		ShowLine1
		MOVLW	LINE1
		CALL    LCDsendCMD
	; display the accept message
		; Display format message
		PrintMess MES17
	; Make sure the pilot is ok with this!
		MOVLW	D'250'
		CALL	Delay1mS
		ShowLine2
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES7
		CALL	YesNo
		BTFSS	ALUSTA,C
		RETURN			; GOTO	FSexit
	; Display the formating message
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES19
ifdef		MicroProStar
	; If this is the MicroProStar then display on both lines to make sure it shows!
		MOVLW	LINE1
		CALL    LCDsendCMD
		PrintMess MES19
endif
	; Here if its OK to format, Load the default parameters
		CALL	LoadDefaults
		CALL	SaveGeneral
	; Setup loop counter to format all aircraft setups
		MOVLB	HIGH Dtemp
		MOVLW	NumAircraft
		MOVWF	Dtemp
FS03
		MOVFF	Aircraft,WREG	; Load aircraft number
		CALL	SaveAircraft
		MOVLB	HIGH Aircraft
		INCF	Aircraft	; Next Aircraft
		; Now advance the generic aircraft name's, "MODEL XX"
		MOVLB	HIGH Name
		INCF	Name+7
		; Look to see if it's greater that '9', 3A
		MOVLW	3A
		CPFSEQ	Name+7
		GOTO	FS04
		; Now advance Name+6 and set Name+7 to '0'
		INCF	Name+6
		MOVLW	30
		MOVWF	Name+7
	; Loop till finished....
FS04
		MOVLB	HIGH Dtemp
		DECFSZ	Dtemp
		GOTO	FS03
	; Here when we are finished, Reload the setup information
FSexit
		CALL	LoadGeneral
		MOVFF	Aircraft,WREG
		CALL	LoadAircraft
		ShowLine1
		RETURN

;
; This function will write variables to all aircraft settings memory.
; This is used to allow a pilot to apply an edited parameter to all
; aircraft. This function assumes that the bytes to be changed are all
; contained with in one 64 byte block. This is not error checked and
; assumed that the caller has checked this constraint.
;
; The following registeres are used:
;
;	Src	= Address of source data
;	Cnt	= Number of bytes to update
;	BlkBuf	= 64 byte buffer used to hole each flash block
;
FlashAllAircraft
	; Exit if the source address is not on RAM page 3 or 4
		MOVLR	HIGH Src
		MOVLW	3
		XORWF	Src+1,W
		BTFSC	ALUSTA,Z
		GOTO	AddressOK
		MOVLW	4
		XORWF	Src+1,W
		BTFSS	ALUSTA,Z
		RETURN
	; Setup loop counter
AddressOK
		MOVLW	NumAircraft
		MOVFF	WREG,Creg
	; Define the destination address
		MOVLR	HIGH Dst
		CLRF	Dst+1
		MOVF	Src,W
		ANDLW	0x3F		; The 64 lower bits of the address
		ADDLW	LOW BlkBuf
		MOVWF	Dst
		MOVLW	HIGH BlkBuf
		ADDWFC	Dst+1,F
	; Define the Flash memory address, place in CEXreg
		MOVE	Src,CEXreg
		CLRF	CEXreg+2
		MOVLW	0xC0
		ANDWF	CEXreg,F
		MOVLW	3
		SUBWF	CEXreg+1,F
		MOVLW	LOW CFGaircraft
		ADDWF	CEXreg,F
		MOVLW	HIGH CFGaircraft
		ADDWFC	CEXreg+1,F
		MOVLW	UPPER CFGaircraft
		ADDWFC	CEXreg+2,F
	; Read the 64 byte block from Flash to the ram buffer
FlashAllAircraftNext
		MOVEC	BlkBuf,AXreg
		MOVLW	D'64'
		MOVFF	WREG,Areg
		CALL	FlashRead
	; Erase the 64 byte Flash block
		MOVLW	1
		MOVFF	WREG,Areg
		CALL	FlashErase
	; Write the new data to the ram buffer
		MOVFF	Cnt,Areg
		CALL	BlkMove
		MOVFF	Areg,Cnt
	; Write the data back to flash
		MOVEC	BlkBuf,AXreg
		MOVLW	1
		MOVFF	WREG,Areg
		CALL	FlashWrite
	; Advance the aircraft config memory pointer, advance by 512 
		MOVLR	HIGH CEXreg
		MOVLW	2
		ADDWF	CEXreg+1,F
		BTFSC	ALUSTA,Z
		INCF	CEXreg+2,F
	; Loop through all aircraft
		DECFSZ	Creg,F,A
		GOTO	FlashAllAircraftNext
		RETURN

; This function will read data from flash memory and save it
; at the address in reg AXreg.  The following registers are 
; assumed defined when this call is made:
;
;	AXreg  = Destination address in ram
;	CEXreg = Flash memory address 
;	Areg   = Number of bytes to read
;
FlashRead
	; Set table pointer with Flash program memory address
		MOVLR	HIGH CEXreg
		MOVFP	CEXreg+2,W
		MOVWF	TBLPTRU,A
		MOVFP	CEXreg+1,W
		MOVWF	TBLPTRH,A
		MOVFP	CEXreg,W
		MOVWF	TBLPTRL,A
	; Setup indirection regs
		MOVLR	HIGH AXreg
		MOVFP	AXreg+1,W
		MOVWF	FSR1H,A
		MOVFP	AXreg,W
		MOVWF	FSR1L,A
FlashRead1
		TBLRD*+
		MOVF	TABLAT,W
		MOVWF	POSTINC1
		DECF	Areg
		TBLRD*+
		MOVF	TABLAT,W
		MOVWF	POSTINC1
		DECFSZ	Areg
		GOTO	FlashRead1
		RETURN


; This function will erase 64 byte blocks of Flash program memory. 
; The following registers are defined when this function
; is called:
;
;	CEXreg = Flash memory address, pointer to first block 
;	Areg   = Number of 64 byte blocks to erase
FlashErase
	; Load the pointer to flash block to erase
		MOVLR	HIGH CEXreg
		MOVFP	CEXreg+2,W
		MOVWF	TBLPTRU,A
		MOVFP	CEXreg+1,W
		MOVWF	TBLPTRH,A
		MOVFP	CEXreg,W
		MOVWF	TBLPTRL,A
	; Erase this block
		BSF 	EECON1, EEPGD,A	; point to Flash program memory
		BCF 	EECON1, CFGS,A 	; access Flash program memory
		BSF 	EECON1, WREN,A 	; enable write to memory
		BSF 	EECON1, FREE,A 	; enable Row Erase operation
		BCF 	INTCON, GIE,A 	; disable interrupts
		MOVLW 	55h
		MOVWF 	EECON2,A	; write 55h
		MOVLW 	0AAh
		MOVWF 	EECON2,A	; write 0AAh
		BSF 	EECON1, WR,A 	; start erase (CPU stall)
		NOP
		BSF 	INTCON, GIE,A 	; re-enable interrupts
	; Exit on last block
		DCFSNZ	Areg,F,A
		RETURN
	; Advance to the next block by adding 64 to CEXreg
		MOVLR	HIGH CEXreg
		MOVLW	D'64'
		ADDWF	CEXreg
		MOVLW	0
		ADDWFC	CEXreg+1
		ADDWFC	CEXreg+2
	; Loop till all blocks are erased
		GOTO	FlashErase

; This function will write data to flash memory. The source
; data address is in reg AXreg.  The following registers are 
; assumed defined when this call is made:
;
;	AXreg  = Ram source memory address 
;	CEXreg = Destination address in Flash, must be on 64 byte page
;	Areg   = Number of 64 byte blocks to program
;
FlashWrite
		CALL	SyncUp
	; Load the pointer to flash block
		MOVLR	HIGH CEXreg
		MOVFP	CEXreg+2,W
		MOVWF	TBLPTRU,A
		MOVFP	CEXreg+1,W
		MOVWF	TBLPTRH,A
		MOVFP	CEXreg,W
		MOVWF	TBLPTRL,A
	; Erase this block
		BSF 	EECON1, EEPGD,A	; point to Flash program memory
		BCF 	EECON1, CFGS,A 	; access Flash program memory
		BSF 	EECON1, WREN,A 	; enable write to memory
		BSF 	EECON1, FREE,A 	; enable Row Erase operation
		BCF 	INTCON, GIE,A 	; disable interrupts
		MOVLW 	55h
		MOVWF 	EECON2,A	; write 55h
		MOVLW 	0AAh
		MOVWF 	EECON2,A	; write 0AAh
		BSF 	EECON1, WR,A 	; start erase (CPU stall)
		BSF 	INTCON, GIE,A 	; re-enable interrupts
	; Write the buffer to holding reg
		TBLRD*- 		; dummy read decrement
		MOVLR	HIGH AXreg
		MOVFP	AXreg+1,W 	; point to buffer
		MOVWF 	FSR1H,A
		MOVFP	AXreg,W
		MOVWF 	FSR1L,A
		MOVLW 	D'64' 		; number of bytes in holding register
		MOVWF 	Breg,A
WRITE_BYTE_TO_HREGS
		MOVFF 	POSTINC1, WREG 	; get low byte of buffer data
		MOVWF 	TABLAT,A	; present data to table latch
		TBLWT+* 		; write data, perform a short write
					; to internal TBLWT holding register.
		DECFSZ 	Breg,F,A	 	; loop until buffers are full
		BRA 	WRITE_BYTE_TO_HREGS
	; Program the block
		BSF 	EECON1, EEPGD,A	; point to Flash program memory
		BCF 	EECON1, CFGS,A 	; access Flash program memory
		BSF 	EECON1, WREN,A 	; enable write to memory
		BCF 	INTCON, GIE,A 	; disable interrupts
		MOVLW 	55h
		MOVWF 	EECON2,A	; write 55h
		MOVLW 	0AAh
		MOVWF 	EECON2,A	; write 0AAh
		BSF 	EECON1, WR,A 	; start program (CPU stall)
		BSF 	INTCON, GIE,A 	; re-enable interrupts
		BCF 	EECON1, WREN,A 	; disable write to memory
	; Exit after last block
		DCFSNZ	Areg,F,A
		RETURN
	; Advance pointers to next block
		MOVLR	HIGH CEXreg
		MOVLW	D'64'
		ADDWF	CEXreg
		MOVLW	0
		ADDWFC	CEXreg+1
		ADDWFC	CEXreg+2
		MOVLR	HIGH AXreg
		MOVLW	D'64'
		ADDWF	AXreg
		MOVLW	0
		ADDWFC	AXreg+1
	; Loop till all blocks are processed
		GOTO	FlashWrite

; This function will write data to flash memory. The source
; data address is in reg AXreg.  The following registers are 
; assumed defined when this call is made:
;
;	AXreg  = Ram source memory address 
;	CEXreg = Destination address in Flash, must be on 64 byte page
;	Areg   = Number of 64 byte blocks to program
;
FlashWrite_8720
	; Load the pointer to flash block
		MOVLR	HIGH CEXreg
		MOVFP	CEXreg+2,W
		MOVWF	TBLPTRU,A
		MOVFP	CEXreg+1,W
		MOVWF	TBLPTRH,A
		MOVFP	CEXreg,W
		MOVWF	TBLPTRL,A
	; Erase this block
		BSF 	EECON1, EEPGD,A	; point to Flash program memory
		BCF 	EECON1, CFGS,A 	; access Flash program memory
		BSF 	EECON1, WREN,A 	; enable write to memory
		BSF 	EECON1, FREE,A 	; enable Row Erase operation
		BCF 	INTCON, GIE,A 	; disable interrupts
		MOVLW 	55h
		MOVWF 	EECON2,A	; write 55h
		MOVLW 	0AAh
		MOVWF 	EECON2,A	; write 0AAh
		BSF 	EECON1, WR,A 	; start erase (CPU stall)
		NOP
		BSF 	INTCON, GIE,A 	; re-enable interrupts
	; Write the buffer to holding reg
		TBLRD*- 				; dummy read decrement
WRITE_BUFFER_BACK
		MOVLW 	8 				; number of write buffer groups of 8 bytes
		MOVWF 	Breg,A
		MOVLR	HIGH AXreg
		MOVFP	AXreg+1,W 	; point to buffer
		MOVWF 	FSR1H,A
		MOVFP	AXreg,W
		MOVWF 	FSR1L,A
PROGRAM_LOOP
		MOVLW 	8 				; number of bytes in holding register
		MOVWF 	Creg,A
WRITE_WORD_TO_HREGS
		MOVFF 	POSTINC1, WREG 	; get low byte of buffer data
		MOVWF 	TABLAT,A		; present data to table latch
		TBLWT+* 				; write data, perform a short write
								; to internal TBLWT holding register.
		DECFSZ 	Creg,F,A 		; loop until buffers are full
		BRA 	WRITE_WORD_TO_HREGS
PROGRAM_MEMORY
		BSF 	EECON1, EEPGD,A	; point to Flash program memory
		BCF 	EECON1, CFGS,A 	; access Flash program memory
		BSF 	EECON1, WREN,A 	; enable write to memory
		BCF 	INTCON, GIE,A 	; disable interrupts
		MOVLW 	055h
		MOVWF 	EECON2,A		; write 55H
		MOVLW 	0AAh
		MOVWF 	EECON2,A		; write AAH
		BSF 	EECON1, WR,A	; start program (CPU stall)
		NOP
		BSF 	INTCON, GIE,A 	; re-enable interrupts
		DECFSZ 	Breg,F,A 		; loop until done
		BRA 	PROGRAM_LOOP
		BCF 	EECON1, WREN,A 	; disable write to memory
	; Advance pointers to next block
		MOVLR	HIGH CEXreg
		MOVLW	D'64'
		ADDWF	CEXreg
		MOVLW	0
		ADDWFC	CEXreg+1
		ADDWFC	CEXreg+2
		MOVLR	HIGH AXreg
		MOVLW	D'64'
		ADDWF	AXreg
		MOVLW	0
		ADDWFC	AXreg+1
	; Loop till all blocks are processed
		DECFSZ	Areg,F,A
		GOTO	FlashWrite_8720
		RETURN	

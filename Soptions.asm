; This file contains the Shared Options User Interface Pre and Post functions. The 
; Pre function is called before the selected user interface option is processed
; by the user interface routines and the Post function is called after the
; user interface routine returns. 


; This function will move the Temp table data (CalTable) to the 
; location pointed to by the DXreg.
Temp2Table
		CALLF	BlkMove
		RETURN
		
; This function will move the table data defined in DXreg to the
; Temp table (CalTable).
Table2Temp
		MOVEC	CalTable,Dst
		MOVE16	DXreg,Src
		MOVLW	D'11'
		MOVWF	Cnt
		CALL	BlkMove  
		; setup for the move back!
		MOVEC	CalTable,Src
		MOVE16	DXreg,Dst
		MOVLW	D'11'
		MOVWF	Cnt
		RETURN


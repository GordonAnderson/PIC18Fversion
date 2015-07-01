;**********************************************************************
;                                                                     *
;**********************************************************************
;  
;    Filename:	    MStar.asm 
;    Date:          November 14, 2004
;    File Version:  1.1a
; 
;    Author:  Gordon Anderson
;    Company: GAA Custom Electronics
;
;    The MicroStar 2000 is a model airplane encoder. An encoder reads
;    the joy stick pots and the switches and generates the modulation
;    signal sent to the RF deck, the other significant part of a
;    transmitter.
;
;    The PIC processor has several pages or banks of ram. Each is 224
;    bytes long. These banks are used as follows:
;    Bank0:
;          Contains all of the working variables. None of this information
;          is saved, and on powerup its in a undefined state.
;    Bank1:
;          Used for misc variables.
;    Bank2:
;          This bank contains all of the general parameters. These are
;          the parameters that are constant for all aircraft settings,
;          like joy stick calibration. This information is saved in the
;          serial prom.
;    Bank3:
;          This bank contains are the aircraft specific data. These 
;          parameters are read from the serial prom on powerup or when
;	   a new aircraft configuration is selected.
;
;    SPROM
;	The Sprom is used to store general parameters and aircraft specific
;	setup parameters. 224 bytes are used for general parameters, this
;	is the size of bank 2 and all general parameters are in bank 2.
;	224 bytes are also used for each of the 8 aircraft setups that 
;	can be saved in the Sprom. The aircraft setting are saved in bank
;	3. On powerup the general parameters are loaded then the aircraft
;	specified is loaded.
;
;    Startup options:
;
;       Press OPTION + PRESET   = Start the IO test routine
;       Press PRESET + AUTOTRIM = bypass sprom load and load from
;                                 default table. This is designed 
;                                 for initial startup with a new sprom.
; BUG report:
;
; Requests:
;	1.) Expo on throttle, not going to do this, use tables
;	2.) Redesign the PC interface program
;	3.) Another goody would be programmable delay when switching 
;           between flight configurations.
;	4.) Slow servo travel option for retracts
;
; Revision History:
;
;	Version 1.0b
;		First release, Jan 2001
;	Version 1.0c
;		Fixed a few minor bugs and finished the dual SPROM
;		support
;       Version 1.0d, Jan 28, 2001
;               Fixed a timming put in the SPROM read function.
;       Version 1.0E, April 16,2001
;               Fixed the interface to RF deck, added support for
;		50MHz, 53MHz, and 72MHz.         
;		Added support for the receiver battery test function.
;       Version 1.0F, May 5, 2001
;               Placed the PLL in high current mode.
;               Fixed a display bug in the LCD52 drivers.   
;               Small display bug in 4x12 display driver.
;	Version 1.0G, October 21, 2001
;		Added programmable channel output order
;		Added Programmable trim assignment
;		Added support for Futaba type buddy box
;		Added new Auto Trim mode, where full adjustment is made when button
;		is pressed
;		Added enable switch to timer and throttle trigger to timer
;		Added up counter mode
;       Version 1.0H, March 17, 2002
;               Fixed a bug in the throttle trim, the percentage value used
;               was from the rudder!
;               Added a timer option to stop at zero on down counting.
;               Fixed bug in UP counter.
;       Version 1.0I, August 18, 2002
;               1.) Servo limits changed to .750 mS and 2.250 mS
;               2.) Snap PB changed to % and done after normalization
;               3.) CROW added
;	Version 1.0J, November 30, 2003
;		1.) Fixed a bug in the table edit mode that would not
;		    allow you to edit the last position.
;		2.) Fixed the Fixed First Mixer bug.
;	Version 1.1a, December 2004
;		1.) Added high and low rate expo to A,E,R (tested)
;		2.) Fixed the alt aircraft timer problem (tested)
;		3.) Added the Throttle low point adjust feature (tested)
;		4.) Added second alternate aircraft switch (tested)
;		5.) Add set model to default parameters (tested)
;		6.) Add buttons to set time values in min and max as short cuts.
;		    use snap right and snap left buttons. (tested)
;		6.) Add battery timer (tested)
;		7.) Add FMS flight simulator support (tested)
;		8.) Channel trigger points (tested)
;		9.) Add battery alarm level adjustment (tested)
;		10.)Reorder the menus into a more logical order (tested)
;		11.)Add 4 more tables (tested)
;		12.)Move Shift setting to Aircraft area (tested)
;		13.)Fix bug in the Frequency selection function, can not 
;		    select OFF as an option. (tested)
;		14.)Changed the way Mixer 2 works. (tested)
;		15.)Bug that causes the transmitter to crash in CAL mode when
;		    a mixer is on. I think it was the select chan functions mult.
;		    (tested)
;	Version 1.1b, January 14, 2005, bug fixes only
;		1.) Fixed a EPROM space bug
;		2.) Det defaults for min and max value
;		3.) Fixed AUXOUT on top line of display
;	Version 1.1c, Feburary 12 2005, bug fix
;		1.) Fixed bug in AutoTrim one shot mode if you have full
;		    stick deflection.
;	Version 1.1d, July 7 2005, requests, not yet implemented
;		Found and fixed a servo position editing bug. This had
;               to do with block move using wrong radix. 
;	Version 1.1e, July 24 2005
;		Found and fixed a aileron differential bug
;	Version 1.1f, December 10 2005
;		Found and fixed a channel 8 bug that caused the programed values to
;		be off by a factor of two from center
;	Version 1.1g, Feburary 18 2005, requests, not yet implemented
;		1.) Move channel order to aircraft memory area
;		2.) Auto Trim range increase to +- 20 percent
;		3.) Use preset button as an exit from UI
;
; 
; ***********************************************************************
; *
; *                       GAA Custom Electronics                        
; *                     SOFTWARE LICENSE AGREEMENT
; *
; *
; *     BY USING THIS SOFTWARE, YOU ARE AGREEING TO BE BOUND BY THE TERMS
; *     OF THIS AGREEMENT.  DO NOT USE THE SOFTWARE UNTIL YOU HAVE CAREFULLY
; *     READ AND AGREED TO THE FOLLOWING TERMS AND CONDITIONS.  IF YOU DO
; *     NOT AGREE TO THE TERMS OF THIS AGREEMENT, PROMPTLY RETURN THE
; *     SOFTWARE PACKAGE AND ANY ACCOMPANYING ITEMS.
; *
; *     IF YOU USE THIS SOFTWARE, YOU WILL BE BOUND BY THE TERMS OF THIS
; *     AGREEMENT
; *
; *     LICENSE: GAA Custom Electronics ("GAACE") grants you the non-exclusive
; *     right to use the enclosed software program ("Software").  You will
; *     not use, copy, modify, rent, sell or transfer the Software or any
; *     portion thereof, except as provided in this Agreement.
; *
; *     User System Developers may:
; *
; *     1.      Copy the Software for support, backup or archival purposes;
; *     2.      Install, use, or distribute GAACE owned Software in object
; *             code only for use on a single computer system; 
; *     3.      Modify and/or use Software source code that GAACE directly
; *             ships to you for your personal use only.
; *     4.      Install, use, modify, distribute, and/or make or have made 
; *             derivatives ("Derivatives") of GAACE owned Software under the 
; *             terms and conditions in this Agreement, ONLY if you are an
; *             an end-user.
; *
; *
; *     RESTRICTIONS:
; *
; *     YOU WILL NOT:
; *
; *     1.     Copy the Software, in whole or in part, except as provided 
; *            for in this Agreement;
; *     2.     Decompile or reverse engineer Software provided in object code
; *            format;
; *
; *     TRANSFER:  You may transfer the Software to another party if the
; *     receiving party agrees to the terms of this Agreement at the sole
; *     risk of any receiving party.
; *
; *     OWNERSHIP AND COPYRIGHT OF SOFTWARE:  Title to the Software and all
; *     copies thereof remain with GAA Custom Electronics.  The Software
; *     copyright has been filed and will be protected by United States and 
; *     international copyright laws.  You will not remove the copyright 
; *     notice from the Software.  
; *     You agree to prevent any unauthorized copying of the Software.
; *
; *     DERIVATIVE WORK:  Users that make or have made Derivatives will not be 
; *     required to provide GAACE with a copy of the source or object code. 
; *     Users are not authorized to market, sell, and/or distribute 
; *     derivatives works without the written permission of GAACE.
; *
; *     WARRANTY:  GAACE warrants that it has the right to license you to
; *     use, modify, or distribute the Software as provided in this Agreement.
; *     The Software is provided "AS IS". GAACE warrants that the media on
; *     which the Software is furnished will be free from defects in material
; *     and workmanship for a period of one (1) year from the date of 
; *     purchase. Upon return of such defective media, GAACE's entire 
; *     liability and your exclusive remedy shall be the replacement of the 
; *     Software.
; *
; *     THE ABOVE WARRANTIES ARE THE ONLY WARRANTIES OF ANY KIND EITHER
; *     EXPRESS OR IMPLIED INCLUDING WARRANTIES OF MERCHANTABILITY OR FITNESS
; *     FOR ANY PARTICULAR PURPOSE.
; *
; *     LIMITATION OF LIABILITY:    NEITHER GAACE NOR ITS VENDORS OR AGENTS
; *     SHALL BE LIABLE FOR ANY LOSS OF PROFITS, LOSS OF USE, LOSS OF DATA,
; *     INTERRUPTION OF BUSINESS, NOR FOR INDIRECT, SPECIAL, INCIDENTAL OR
; *     CONSEQUENTIAL DAMAGES OF ANY KIND WHETHER UNDER THIS AGREEMENT OR
; *     OTHERWISE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; *
; *     TERMINATION OF THIS LICENSE:  GAACE reserves the right to conduct or
; *     have conducted audits to verify your compliance with this Agreement.
; *     GAACE may terminate this Agreement at any time if you are in breach
; *     of any of its terms and conditions.  Upon termination, you will
; *     immediately destroy, and certify in writing the destruction of, the
; *     Software or return all copies of the Software and documentation to
; *     GAACE.
; *
; ************************************************************************
;

	list      p=18F8722            ; list directive to define processor
	#include <P18F8722.INC>         ; processor specific variable definitions
	errorlevel 2
	
;	__CONFIG   _XT_OSC & _WDT_OFF & _MC_MODE & _BODEN_ON & _INHX32

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

;******************************************************************************
;******************************************************************************
;******************************************************************************
;
; MicroStar configuration options
;
;      These are switches that you can use to define the type MicroStar
;      firmware you wish to build. After you set these options you need
;      to rebuild the application using MPLAB from microchip.
;
; The display type is defined by un-commenting one of the following three
; lines, only one can be un-commented!
 #define		LCD52display
; #define		SED1230display
; #define		ECMA1010display
;
; The following line should be commented out unless you are going to use
; proline type wheel trims
;  #define		PROLINE
;
; Please leave this line un-commented, it deals with how the ADC sticks
; are read.
  #define               ENABLEOVERSAMPLE      
 
; Misc options
; #define			CountOn		; Turns on timer on powerup
;
;******************************************************************************
;******************************************************************************
;******************************************************************************

#define		MOVFP	MOVF
#define		MOVLR	MOVLB
#define		MOVPF	MOVFF
#define		ALUSTA	STATUS

; ADC channel assignments
;
;	CH	Use
;	0	Vpos monitor
;	1	Gnd
;	2	CH7
;	3	CH6
;	4	Aileron
;	5	Elevator
;	6	Rudder
;	7	Throttle
;	8	Aileron trim
;	9	Elevator trim
;	10	Rudder trim
;	11	Throttle trim
;	12	+5 volt monitor 
;       13	Receiver voltage monitor
;

NumAircraft	EQU	16

BNK1	EQU	100
BNK2	EQU	200
BNK3	EQU	300

; Misc constants
StickThres      EQU     D'100'
AutoTrimOStime	EQU	D'40
VoltageLimit	EQU	D'8800'

; PLL constants
HICUR   EQU     10

; Display Line numbers
ifdef		LCD52display
LINE1      EQU       080
LINE2      EQU       0C0
LINE3      EQU       0C0
CURSORON   EQU       0E
CURSOROFF  EQU       0C
YPOS       EQU       08
YNPOS      EQU       0C
NPOS       EQU       0F
ACFTPOS    EQU       0D
BYTEPOS    EQU       0D
PERCENTPOS EQU       0B
uSPOS      EQU       09
SELCHPOS   EQU       0C
CVMPOS     EQU       0B
ONTIMEPOS  EQU       0B
CH53POS    EQU       08
CH50POS    EQU       0E
CH72POS    EQU       0D
CH50MHZPOS EQU       04
CH72MHZPOS EQU       04
TESTCHPOS  EQU       07
TESTVALPOS EQU       0C
TACHRPMPOS EQU       0B
RECVPOS    EQU       0B
endif

ifdef           SED1230display
LINE1      EQU       0B0
LINE2      EQU       0C0
LINE3      EQU       0C0
CURSORON   EQU       03F
CURSOROFF  EQU       031
YPOS       EQU       08
YNPOS      EQU       0C
NPOS       EQU       0F
ACFTPOS    EQU       0D
BYTEPOS    EQU       0D
PERCENTPOS EQU       0B
uSPOS      EQU       09
SELCHPOS   EQU       0C
CVMPOS     EQU       0B
ONTIMEPOS  EQU       0B
CH53POS    EQU       08
CH50POS    EQU       0E
CH72POS    EQU       0D
CH50MHZPOS EQU       04
CH72MHZPOS EQU       04
TESTCHPOS  EQU       07
TESTVALPOS EQU       0C
TACHRPMPOS EQU       0B
RECVPOS    EQU       0B
endif

ifdef           ECMA1010display
LINE1     EQU        0B0
LINE2     EQU        0C0
LINE3     EQU        0D0
LINE4     EQU        0E0
CURSORON  EQU        03F
CURSOROFF EQU        031
YPOS      EQU        07
YNPOS     EQU        09
NPOS      EQU        0B
ACFTPOS    EQU       0A
BYTEPOS    EQU       09
PERCENTPOS EQU       07
uSPOS      EQU       05
SELCHPOS   EQU       08
CVMPOS     EQU       07
ONTIMEPOS  EQU       07
CH53POS    EQU       05
CH50POS    EQU       0B
CH72POS    EQU       0A
CH50MHZPOS EQU       03
CH72MHZPOS EQU       03
TESTCHPOS  EQU       05
TESTVALPOS EQU       08
TACHRPMPOS EQU       07  
RECVPOS    EQU       07
endif

; Button and signal definitions for the Transmitter controls
; PortA bits
BUZZER	EQU	4

; PortB bits
TACHIN	EQU	1
LED2	EQU	2
PLLRST	EQU	5		; PIC reset on RFDECK
SDObit	EQU	7		; Serial data out

; PortC bits
OPT1	EQU	0		; Install jumper to enable RF
OPT2	EQU	1		; Install for 50MHz, empty for 53MHz
CFGMEM2	EQU	2
LED1	EQU	3
SDIbit	EQU	4
CLK	EQU	5		; Clock for PLL and config mem

; PortD bits
AilDR	EQU	0
EleDR	EQU	1
RudDR	EQU	2
PRESET	EQU	3
MIX1	EQU	4
MIX2	EQU	5
MIX3	EQU	6
CH5	EQU	7

; PortE bits
RUNCAL	EQU	0
AUTOT	EQU	1
OPTION	EQU	2
CH8A	EQU	3
CH8C	EQU	4
ALTAFK	EQU	5
SNAPR	EQU	6
SNAPL	EQU	7

; PortF bits
MOD	EQU	7

; PortG bits
CFGMEM1	EQU	0
PLLCS	EQU	3

; PortH bits
AUXOUT	EQU	0
TACHENA	EQU	1
RECCOMM	EQU	2

; LCD PORTS
LCDDATA		EQU	PORTJ
LCDDATADIR	EQU	DDRJ
LCDCTRL		EQU	PORTB
LCDCTRLDIR	EQU	DDRB



;******* BANK0 variables
		ORG	0x00
;*******    INTERRUPT CONTEXT SAVE/RESTORE VARIABLES
TEMP_WREG       RES     1
TEMP_ALUSTA     RES     1
TEMP_BSR        RES     1
TEMP_PCLATH     RES     1
TEMP_WREG_L     RES     1
TEMP_ALUSTA_L   RES     1
TEMP_BSR_L      RES     1
TEMP_PCLATH_L   RES     1
Areg		RES	1	; General purpose registers
Breg		RES	1
;
; Gereral variables
;
AXreg		RES	2	; 16 bit register
BXreg		RES	2	; 16 bit register
CXreg		RES	2	; 16 bit register
CEXreg		RES	4	; 32 bit regester
DEXreg		RES	4	; 32 bit regester
EEXreg		RES	4	; 32 bit regester
Atemp		RES	1
Btemp		RES	1
FPFLAGS		RES	1
SIGN		RES	1
Buffer		RES	D'10'
ISRtemp		RES	1	; Interrupt temp variable
PORTDimage	RES	1	; PortD debounced
PORTDlast	RES	1
PORTDlatch	RES	1
PORTEimage	RES	1	; PortE debounced
PORTElast	RES	1
PORTElatch	RES	1
;
Mode		RES	1	; Defines the system mode
modeRUN		EQU	1
modeCAL		EQU	2
Cmd		RES	1	; This flag is set by a host PC to
				; request an action. Valid commands are:
				; 	31 = Read general data from sprom
				;	32 = Read selected aircraft data from sprom
				;	33 = Write general data to sprom
				;	34 = Write selected aircraft data to sprom
; The following variables are used for the generation of the
; PPM output pulse train. All times are in .5uS units, 2MHz
; internal clock used by timer. Timer3 is used for this pulse
; generation.
CYCLECOUNTS	EQU	D'50000'; The number of timer counts in one 25 mS cycle
CHtimes		RES	D'20'	; One 16 bit word for each channel
				; 8 channels plus one checksum channel
;
; This table defines the transmitted channel order.
;
chELE	EQU	CHtimes+2
chAIL	EQU	CHtimes+4
chRUD	EQU	CHtimes+6
chTHT	EQU	CHtimes+8
chCH5	EQU	CHtimes+0A
chCH6	EQU	CHtimes+0C
chCH7	EQU	CHtimes+0E
chCH8	EQU	CHtimes+10
;

Pstate		RES	1	; State variable
NumChan		RES	1	; Number of transmit channels times two
NextTime	RES	2	; The timers next compare reg value
Psum		RES	2	; Total pulse time from start of output
Sync		RES	2	; Sync pulse width.
; The following variables are involved in time keeping
TICKSPER	EQU	D'40'	; Ticks per second
Cmode		RES	1	; Counter mode, 0 = count up, 1 = timer
Tick		RES	1	; Tick counter
Secs		RES	1	; Seconds sence reset
Mins		RES	1	; Minutes sence reset
Dsecs		RES	1	; Timer Seconds 
Dmins		RES	1	; Timer Minutes 
DsecsLatch	RES	1	; Timer Seconds 
BeepTicks	RES	1	; This is used to create a beep. The RTI will
				; turn off the buzzer after this many ticks
BeepCtr		RES	1	; Working counter...
BeepCyl		RES	1	; Number of cycles
TimeOut		RES	1	; This is a timeout counter. the RTI will dec this
				; if its not zero. Used by the serial rec routine
TimeOut1	RES	1
TimeOut2	RES	1
; The following variables are used by USART1 serial receiver. Receive messages
; are in the following format:
;		1 byte, start of message = 0x55
;		1 byte, message type
;		1 byte, Bank address
;		1 byte, location
;		1 byte, data length
;		(optional data block if its a receive message)
;		1 byte, mod 256 checksum
; Valid message types are:
;	1 = Reveive message, from host
;	2 = Send message, to host
RECMESS		EQU	1
SENDMESS	EQU	2
ACK		EQU	D'12'
NAK		EQU	D'13'

MessState	RES	1	; defines the message receive state
MessStart	RES	1
MessType	RES	1
MessBank	RES	1
MessLoc		RES	1
MessLen		RES	1
MessCHK		RES	1
CheckSum	RES	1
; Generic channel work space
Pos		RES	2	; Pot position
Gh		RES	2	; High side gain
Ct		RES	2	; Center position
Gl		RES	2	; Low side gain
Npos		RES	2	; Normalized position
; Normalized channel positions, centering channels go -1000 to 1000
; and non centering channels go 0 to 1000
Apos		RES	2
Epos		RES	2
Rpos		RES	2
Tpos		RES	2
CH5pos		RES	2
CH6pos		RES	2
CH7pos		RES	2
CH8pos		RES	2
Atrim		RES	2
Etrim		RES	2
Rtrim		RES	2
Ttrim		RES	2
Vbat		RES	2
; Mixed channel positions
AposM		RES	2
EposM		RES	2
RposM		RES	2
TposM		RES	2
CH5posM		RES	2
CH6posM		RES	2
CH7posM		RES	2
CH8posM		RES	2
; More variables...
Ctemp		RES	1
Dtemp		RES	1
Etemp		RES	1
Ftemp		RES	1
TimeOut3	RES	1
TimeOut4	RES	1
TimeOut5	RES	1
TEMPB3		RES	1
DefaultAircraft	RES	1	; Default Aircraft number
SPROMAircraft	RES	2	; SPROM adress to start of current Aircraft data
MasterState	RES	1	; State variable used by the Buddy box system
MasterPos	RES	2	; Position variable
MApos		RES	2
MEpos		RES	2
MRpos		RES	2
MTpos		RES	2
Dst		RES	2	; Destination address
Src		RES	2	; Source address
Cnt		RES	1	; Number of bytes to move
DriveCh		RES	1	;
MinValue
MinTime
MinByte		RES	2
MaxValue
MaxTime
MaxByte		RES	2
OVERRUN		RES	1	; This flag is set if data is not updated
				; within one frame time
SymSet		RES	1	; This flag is set during the servo cal
				; function if the user wants to set the
				; channel symeterical about its center.
SWID		RES	2
BladeTime	RES	2	; Timer counts for aprox 1 sec worth of blade counts
BladeDet	RES	2	; Counts prop blade detections
AilCenter       RES     2       ; Ailron channel pot center position
EleCenter       RES     2       ; Elevator channel pot center position        
EnaSecSprom	RES	1	; This flag is set if a secondary Sprom is enabled
Usecs		RES	1	; Up counter seconds value
Umins		RES	1	; Up counter minutes value

TTflag		RES	1	; Flag set if in the Throttle trim adjust mode
; Variables used by the calibrate servos functions, and misc UI functions
EXIT		RES	1
DXreg  		RES	2
CalTable
SWselect
RTDWN		RES	2
CENTER		RES	2
LTUP		RES	2
DRP		RES	1
TRIMP		RES	1
ATRM		RES	1
EXPOHI		RES	1
EXPOLOW		RES	1
YESNO
ATRST		RES	1
STRIM
; Variables used by Mixer UI
Mfrom		RES	1
Mto		RES	1
Mzp		RES	1
Mpg		RES	1
Mng		RES	1
Mpi		RES	1
Mni		RES	1
Mreplace	RES	1
Mtbl		RES	1
AUXSTATE	RES	1	; State of AUXOUT signal.
SelSprom	RES	1	; Used by the Sprom Write functions the selected
				; devices Bit is set.      
TimerCount	RES	1	; This flag is set (FF) if the timer counting is 
				; Enabled. This flag is set in the TemerEnable 
				; Subroutine.
DPflag		RES	1	; Flag set to display a decimal point in the adjust
				; byte function
FMSflag		RES	1	; Flag set when in the FMS flight simulator mode

PostCall	RES	2	; Pointer to a post call function used by the UI functions
PreCall		RES	2	; Pointer to a pre call function used by the UI functions
;******* BANK1 variables
		ORG	0x100
; LMX2306 PLL setup parameters
; For the 50 MHz band
;       PDF     = 20
;       FCF     = 50800
;       FCN     = 0
;       NUMFREQ = 10
; For the 72 NHz band
;       PDF     = 10
;       FCF     = 72010
;       FCN     = 11
;       NUMFREQ = 60
Nreg		RES	3	; 21 bit register
Rreg		RES	3	; 21 Bit register
Freg		RES	3	; 20 bit register
PDF             RES     2       ; Phase detector frequency, in KHz
FCF             RES     3       ; First channel frequency, in KHz
FCN             RES     1       ; First channel number   
PMUL            RES     1       ; Phase clock multiplier
NUMFREQ         RES     1       ; Number of freq channel

; Misc variables
LValarm		RES	1	; Flag set after the low voltage alarm is given

; Temp data block, used to save data vars
TempBlock	RES	8	; 8 Bytes of storage

; Temp variables used for the Throttle Trim mode
TTBH		RES	2
TTMH		RES	2

; These variables are used by the User Interface routines
CalOption	RES	2
CalMenu		RES	2
CalMenu1	RES	2
CalMenu2	RES	2

PostCallLevel1	RES	2
PostCallLevel2	RES	2
PostCallLevel3	RES	2         

AXregS		RES	2
BXregS		RES	2
CXregS		RES	2
DXregS		RES	2
  
; Four main channels position information used for the trigger point switch routines
ATpos		RES	2
ETpos		RES	2
RTpos		RES	2
TTpos		RES	2

; Temp Alt Aircraft numbers
TAltA1		RES	1
TAltA2		RES	1

;******* BANK2 variables
; 
; This area contains general setup parameters. This area is read from
; the serial prom on power up and these parameters apply to all aircraft.
; These parameters can not be reordered!
;
		ORG	0x200
Aircraft	RES	1	; Aircraft number 0 thru 7
; LMX2306 PLL setup parameters, R and F regs values
; for 50,53 and 72MHz bands
Rreg50		RES	3
Freg50		RES	3
Rreg53		RES	3
Freg53		RES	3
Rreg72		RES	3
Freg72		RES	3

; Voltage monitor gains, (Raw adc counts)* gain = millivolts
VmonG		RES	2	; Gain
; Joy stick calibration parameters. The gains are all times 256
; - first the centering sticks...
AHG		RES	2	; High side gain
ACT		RES	2	; Center counts
ALG		RES	2	; Low side gain

EHG		RES	2	; High side gain
ECT		RES	2	; Center counts
ELG		RES	2	; Low side gain

RHG		RES	2	; High side gain
RCT		RES	2	; Center counts
RLG		RES	2	; Low side gain
; The non centering sticks...
THG		RES	2	; High side gain
TCT		RES	2	; Center counts

AtrimHG		RES	2	; High side gain
AtrimCT		RES	2	; Center counts

EtrimHG		RES	2	; High side gain
EtrimCT		RES	2	; Center counts

RtrimHG		RES	2	; High side gain
RtrimCT		RES	2	; Center counts

TtrimHG		RES	2	; High side gain
TtrimCT		RES	2	; Center counts

CH6HG		RES	2	; High side gain
CH6CT		RES	2	; Center counts

CH7HG		RES	2	; High side gain
CH7CT		RES	2	; Center counts

		RES	3

; Translation tables
Table1		RES	D'11'
Table2		RES	D'11'
Table3		RES	D'11'
Table4		RES	D'11'
Table5		RES	D'11'
Table6		RES	D'11'
Table7		RES	D'11'
Table8		RES	D'11'

AutoTrimStep	RES	1	; Auto Trim step size
AutoTrimTime	RES	1	; Auto Trim adjust time in ticks

Student		RES	1	; This flag is set if this transmitter
				; will be used as a slave in the buddy box
				; system. 0 = clear, FF = set
Master		RES	1	; This flag is set if this transmitter will
				; be used as a master in the buddy box
				; system. 0 = clear, FF = set.
MaxChannels	RES	1	; Number of transmit channels
SyncWidth	RES	2	; Sync pulse width, in .5uS units
SelFreq		RES	1	; Selected frequency
				; 0FF = off
		RES	1	
Signature	RES	2	; This is a formatted signature, it must be A5 E7 or you
				; will be asked if you want to format the Sprom.
VRmonG		RES	2	; Gain for the receiver voltage monitor ADC channel
PLLinitWORD	RES	3	; This is the PLL initialization word, use to shut the
				; PLL down
ServoMin        RES     2       ; Servo minimum limit
ServoMax        RES     2       ; Servo maximum limit    

; Trim table. This table is used to define witch trim adjustment is used
; for each flight control.
; Valid values are:
;	0 = none
;	1 = Ail trim
;	2 = Ele trim
;	3 = Rud trim
;	4 = Tht trim
AilTrimCh	RES	1
EleTrimCh	RES	1
RudTrimCh	RES	1
ThtTrimCh	RES	1   

; Output order. This table defines the output channel order. The user can
; configure any order he likes. You can even repeat the same channel if
; required for your application
ChannelOrder	RES	8

ATmode          RES     1       ; Auto trim mode, 0 = incremental, 1 = one shot
MasterMode	RES	1	; Master mode, 0 = MicroStar, 1 = Futaba

BatteryTimer	RES	2	; This variable holds the total "on" time of the
				; transmitter.
BTflag		RES	1	; This flag is set when its time to update the
				; battery timer value
BattAlarm	RES	1	; Battery alarm voltage level in .1 volt units
AUXMODE		RES	1	; Defines the channel to output on the
				; AUXOUT pin used for direct servo drive.
				; Setting the MSB defines the output to be
				; the encoded pulse train. To output a channel
				; set this variable to the channel number times
				; 2 plus 1.
;******* BANK3 variables 
;
; This area contains aircraft specific setup parameters. The serial
; prom contains 8 total setup, the selected aircraft's parameters are
; copied into this block. These parameters can not be reordered!
;
		ORG	0x300
; Channel specfic data.
; Gereral data
Name		RES	D'16'	; Aircraft name for display!
Reserved	RES	1	; 
; Aielron
AM1H		RES	2	; Right gain
AB		RES	2	; Offset
AM2H		RES	2	; Left gain
ALR		RES	1	; Low rate, in percent
APT		RES	1	; Percent trim
AAT		RES	1	; Autotrim offset
AEXHI		RES	1	; Expo high rate percentage
AEXLOW		RES	1	; Expo low rate percentage
; Elevator
EM1H		RES	2	; Up gain
EB		RES	2	; Offset
EM2H		RES	2	; Down gain
ELR		RES	1	; Low rate, in percent
EPT		RES	1	; Percent trim
EAT		RES	1	; Autotrim offset
EEXHI		RES	1	; Expo high rate percentage
EEXLOW		RES	1	; Expo low rate percentage
; Rudder
RM1H		RES	2	; Right gain
RB		RES	2	; Offset
RM2H		RES	2	; Left
RLR		RES	1	; Low rate, in percent
RPT		RES	1	; Percent trim
RAT		RES	1	; Autotrim offset
REXHI		RES	1	; Expo high rate percentage
REXLOW		RES	1	; Expo low rate percentage
; Throttle
TMH		RES	2	; Gain and offset
TBH		RES	2
TPT		RES	1	; Percent trim
TMODE		RES	1	; Trim mode
Tpreset		RES	2	; Preset servo position
; CH5, retract
CH5MH		RES	2
CH5BH		RES	2
; CH6
CH6MH		RES	2	; Gain and offset
CH6BH		RES	2
; CH7
CH7MH		RES	2	; Gain and offset
CH7BH		RES	2
; CH8, three position, A,B,C
CH8_A		RES	2
CH8_B		RES	2
CH8_C		RES	2
; Snap right
SR_A		RES	2
SR_E		RES	2
SR_R		RES	2
SR_T		RES	2
; Snap left
SL_A		RES	2
SL_E		RES	2
SL_R		RES	2
SL_T		RES	2
; Mixers, 3 total
; 1
M1Afrom		RES	1
M1Ato		RES	1
M1Azp		RES	1
M1Aur		RES	1
M1Adl		RES	1
M1Bfrom		RES	1
M1Bto		RES	1
M1Bzp		RES	1
M1Bur		RES	1
M1Bdl		RES	1
M1Cfrom		RES	1
M1Cto		RES	1
M1Czp		RES	1
M1Cur		RES	1
M1Cdl		RES	1
M1Dfrom		RES	1
M1Dto		RES	1
M1Dzp		RES	1
M1Dur		RES	1
M1Ddl		RES	1
; 2
M2Afrom		RES	1
M2Ato		RES	1
M2Azp		RES	1
M2Aur		RES	1
M2Adl		RES	1
M2Bfrom		RES	1
M2Bto		RES	1
M2Bzp		RES	1
M2Bur		RES	1
M2Bdl		RES	1
M2Cfrom		RES	1
M2Cto		RES	1
M2Czp		RES	1
M2Cur		RES	1
M2Cdl		RES	1
M2Dfrom		RES	1
M2Dto		RES	1
M2Dzp		RES	1
M2Dur		RES	1
M2Ddl		RES	1
; 3
M3Afrom		RES	1
M3Ato		RES	1
M3Azp		RES	1
M3Aur		RES	1
M3Adl		RES	1
M3Bfrom		RES	1
M3Bto		RES	1
M3Bzp		RES	1
M3Bur		RES	1
M3Bdl		RES	1
M3Cfrom		RES	1
M3Cto		RES	1
M3Czp		RES	1
M3Cur		RES	1
M3Cdl		RES	1
M3Dfrom		RES	1
M3Dto		RES	1
M3Dzp		RES	1
M3Dur		RES	1
M3Ddl		RES	1
; Fixed mix functions.
VTAIL		RES	1	; 0=off and FF=on
ELEVON		RES	1	; 0=off and FF=on
DUALA		RES	1	; 0=off and FF=on
REVA		RES	1	; 0=nornal, FF=channel 7 reverse
DIFFA		RES	1	; Percentage of differential, 0 = off
FPgain		RES	1	; Amount of flaps, 0 = off
THOLD		RES	1	; Throttle hold flag, FF = On
THOLDp		RES	1	; Throttle hold percentage
IDLEUP		RES	1	; Idle up flag, FF = On
IDLEUPpA	RES	1	; Idle up percentage A
IDLEUPpB	RES	1	; Idle up percentage B
ALTaircraft	RES	1	; Alternate aircraft number. If this value is not
				; FF then it indicates the setup to be used if the
				; ALTAFT switch is on
FixedFirst	RES	1	; If this flag is set (FF) then the fixed mixer
				; functions are completed before the general mixers.
NumBlades	RES	1	; Number of prop blades, used by Tach
RetractsWarning	RES	1	; This flag is set if you want a retracts up warning

; The following variables hold the trim zero values. These variables are used to recenter
; the trims. 

TrimZeroAil	RES	2
TrimZeroEle	RES	2
TrimZeroRud	RES	2

ModelChannel	RES	1	; This models fraquency channel

; Switch selections
SWAILDR		RES	1
SWELEDR		RES	1
SWRUDDR		RES	1
SWPRESET	RES	1
SWMIX1		RES	1
SWMIX2		RES	1
SWMIX3		RES	1
SWCH5		RES	1
SWATRIM		RES	1
SWCH8A		RES	1
SWCH8B		RES	1
SWCH8C		RES	1
SWALT		RES	1
SWSNAPR		RES	1
SWSNAPL		RES	1 

; Timer variables...
CNTmode		RES	1	; 0 = On time only, 1 = DWN timer
DWNSecs		RES	1
DWNMins		RES	1
TEnaSW		RES	1	; Switch used to enable timer
Tthres		RES	1	; Throttle threshold for timer

; More switch selections
SWTHOLD		RES	1
SWIDLEUP1	RES	1
SWIDLEUP2	RES	1

; Additions for the CROW function
SWCROW          RES     1       ; The Crow switch, by default is Mixer 1 switch
CROWENA         RES     1       ; Flag set if CROW is enabled.

; Alternate aircraft 2 variables
SWALT2		RES	1	; Alt 2 switch definition
ALTaircraft2	RES	1	; Alt 2 aircraft number

; Control stick trigger positions
ATP		RES	1
ETP		RES	1
RTP		RES	1
TTP		RES	1

SHIFT		RES	1	; Set to FF for ACE shift

;*******    MACROS
GOTOF		MACRO	ADDRS
		GOTO	ADDRS
		ENDM

CALLF		MACRO 	ADDRS
		CALL	(ADDRS)
		ENDM

CALLFL		MACRO 	ADDRS,VAL
		MOVLW	(VAL)
		CALL	(ADDRS)
		ENDM

CALLFW		MACRO 	ADDRS
		CALL	(ADDRS)
		ENDM

CALLFF		MACRO 	ADDRS,VAL
		MOVFP	(VAL),WREG
		CALL	(ADDRS)
		ENDM

PUSHREGS        MACRO                 ;macro for saving registers, used in high priority ISRs
            	MOVFP   WREG,TEMP_WREG
            	MOVFP   ALUSTA,TEMP_ALUSTA
            	MOVFP   BSR,TEMP_BSR
            	MOVFP   PCLATH,TEMP_PCLATH
            	ENDM


POPREGS         MACRO                 ;macro for restoring registers, used in high priority ISRs
            	MOVFP   TEMP_PCLATH,PCLATH
            	MOVFP   TEMP_BSR,BSR
            	MOVFP   TEMP_ALUSTA,ALUSTA
            	MOVFP   TEMP_WREG,WREG
            	ENDM

PUSHREGSLOW     MACRO                 ;macro for saving registers, used in low priority ISRs
            	MOVFP   WREG,TEMP_WREG_L
            	MOVFP   ALUSTA,TEMP_ALUSTA_L
            	MOVFP   BSR,TEMP_BSR_L
            	MOVFP   PCLATH,TEMP_PCLATH_L
            	ENDM


POPREGSLOW      MACRO                 ;macro for restoring registers, used in low priority ISRs
            	MOVFP   TEMP_PCLATH_L,PCLATH
            	MOVFP   TEMP_BSR_L,BSR
            	MOVFP   TEMP_ALUSTA_L,ALUSTA
            	MOVFP   TEMP_WREG_L,WREG
            	ENDM

PrintMess   	MACRO   MESSAGE
		MOVLW	HIGH (MESSAGE)
		MOVWF	TBLPTRH
		MOVLW	LOW (MESSAGE)
		MOVWF	TBLPTRL
		CALLF	LCDsendMess
	    	ENDM

; This macro set the carry flag if the port's bit is set
State		MACRO	PORT,BIT
		MOVLB	HIGH PORT
		BCF	ALUSTA,C
		BTFSC	PORT,BIT
		BSF	ALUSTA,C
		ENDM

; Carry flag is cleared if the button is pressed and remains pressed
; 10 mSec later
Pressed		MACRO	PORT,BIT
		State	PORT,BIT
		BTFSC	ALUSTA,C
		GOTO	$ + 7
		MOVLW	D'10'
		CALL	Delay1mS
		State	PORT,BIT
		ENDM

; Waits for a button to be released and stay released for 10 mSec
Release		MACRO	PORT,BIT
		State	PORT,BIT
		BTFSS	ALUSTA,C
		GOTO	$ - 5
		MOVLW	D'10'
		CALL	Delay1mS
		State	PORT,BIT
		BTFSS	ALUSTA,C
		GOTO	$ - 13
		ENDM

MOVEB		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		ENDM
		
MOVE16		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		MOVFF	REG1+1,REG2+1
		ENDM
		
MOVE		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		MOVFF	REG1+1,REG2+1
		ENDM

MOVE24		MACRO	REG1,REG2
		MOVFF	REG1,REG2
		MOVFF	REG1+1,REG2+1
		MOVFF	REG1+2,REG2+2
		ENDM
		
MOVEC		MACRO	CONST,REG
		MOVLR	HIGH (REG)
		MOVLW	LOW (CONST)
		MOVWF	(REG)
		MOVLW	HIGH (CONST)
		MOVWF	(REG+1)
		ENDM     
		
MOVEC24		MACRO	CONST,REG
		MOVLR	HIGH (REG)
		MOVLW	LOW (CONST)
		MOVWF	(REG)
		MOVLW	LOW (CONST/100)
		MOVWF	(REG+1)
		MOVLW	HIGH (CONST/100)
		MOVWF	(REG+2)
		ENDM

; The following macros support indirect word movements

        ; Move from address to word
MOVEIW          MACRO   ADD,REG
                MOVLW   0F
                ANDWF   BSR,F
                MOVLR   HIGH ADD
                MOVFP   ADD,FSR1
                MOVFP   ADD+1,WREG
                SWAPF   WREG
                IORWF   BSR,F
                BCF     ALUSTA,FS3
                BSF     ALUSTA,FS2
                MOVPF   INDF1,REG
                MOVPF   INDF1,REG+1
                ENDM
                
        ; Move from word to address
MOVEWI          MACRO   REG,ADD
                MACRO   ADD,REG
                MOVLW   0F
                ANDWF   BSR,F
                MOVLR   HIGH ADD
                MOVFP   ADD,FSR1
                MOVFP   ADD+1,WREG
                SWAPF   WREG
                IORWF   BSR,F
                BCF     ALUSTA,FS3
                BSF     ALUSTA,FS2
                MOVFP   REG,INDF1
                MOVFP   REG+1,INDF1
                ENDM  
                
        ; Move from address to byte
MOVEIB          MACRO   ADD,REG
                MOVLW   0F
                ANDWF   BSR,F
                MOVLR   HIGH ADD
                MOVFP   ADD,FSR1
                MOVFP   ADD+1,WREG
                SWAPF   WREG
                IORWF   BSR,F
                MOVPF   INDF1,WREG
                MOVLR	HIGH REG
                MOVWF	REG
                ENDM
                
        ; Move from byte to address
MOVEBI          MACRO   REG,ADD
		MOVLR	HIGH REG
		MOVFP	REG,PRODH
                MOVLW   0F
                ANDWF   BSR,F
                MOVLR   HIGH ADD
                MOVFP   ADD,FSR1
                MOVFP   ADD+1,WREG
                SWAPF   WREG
                IORWF   BSR,F
                MOVFP   PRODH,INDF1
                ENDM
;**********************************************************************
                ORG    0x000
                goto   start	


;************   High Priority INTERRUPT VECTOR
                ORG    		0x008
		GOTO		HIGHISRS

;************   Low Priority INTERRUPT VECTOR
                ORG		0x018
		GOTO		LOWISRS


HIGHISRS
                PUSHREGS              	;save specific registers
        ; Test if this is a hardware interrupt 1. This is used for the tach and 
        ; the futaba trainer system
        	BTFSS	INTCON3,INT1IP	; If INT1 is set to low priority then do not test
        	GOTO	HIGHISRS0	; if its active
        	BTFSC	INTCON3,INT1IF
        	CALL	INT1ISR
	; Test if this is a timer3 interrupt, compare reg 2
HIGHISRS0      	BTFSS	IPR2,CCP2IP	; If Timer3 is set to high priority then do not test
        	GOTO	HIGHISRS1	; if its active
		BTFSC	PIR2,CCP2IF
		CALL	TIMER3ISR
	; Exit
HIGHISRS1      	POPREGS               	;restore specific registers
                retfie            	;return from interrupt
               

LOWISRS
                PUSHREGSLOW            	;save specific registers
        ; Test if this is a hardware interrupt 1. This is used for the tach and 
        ; the futaba trainer system
        	BTFSC	INTCON3,INT1IP	; If INT1 is set to high priority then do not test
        	GOTO	LOWISRS0	; if its active
        	BTFSC	INTCON3,INT1IF
        	CALL	INT1ISR
	; Test if this is a timer3 interrupt
LOWISRS0       	BTFSC	IPR2,CCP2IP	; If Timer3 is set to high priority then do not test
        	GOTO	LOWISRS1	; if its active
		BTFSC	PIR2,CCP2IF
		CALL	TIMER3ISR
	; Test for COMM port 2 interrupt, only happens in student mode
LOWISRS1	BTFSC	PIR3,RC2IF
		CALL	SendStudent
	; Exit	
		POPREGSLOW             	;restore specific registers
                retfie            	;return from interrupt




; Jump tables all Call tables.....
; These tables must not be moved...
; Calibration options...
CALoptions
		MOVLR	HIGH CXreg
		MOVFP	CXreg,WREG
		ADDWF	PCL
		GOTOF	CalSelectAircraft
		GOTOF	CalAircraftName
		GOTOF	CalTimer
		GOTOF	CalSnap
		GOTOF	CalServos
		GOTOF	CalMixers
		GOTOF	CalSwitch
		GOTOF	CalOptions
		GOTOF	CalSharedOptions
		GOTOF	CalSystemSetup
		GOTOF	CalSelectFrequency
		RETURN 					; Exit option
		
; This function will load BXreg with the trim value indexed by WREG
; WREG              
;	0 = Set to 0, no trim
;	1 = Aileron
;	2 = Elevator
;	3 = Rudder
;	4 = Throttle 
SelectTrim        
		IORLW	0
		BTFSS	ALUSTA,Z
		GOTO	ST1
		MOVEC	0,BXreg
		RETURN
ST1              
	; Build index
		DECF	WREG
		ANDLW	3
		MULLW	9
		MOVFP	PRODL,WREG
		ADDWF	PCL
		; Aileron 
		MOVE	Atrim,BXreg
		RETURN
		; Elevator
		MOVE	Etrim,BXreg
		RETURN
		; Rudder
		MOVE	Rtrim,BXreg
		RETURN
		; Throttle
		MOVE	Ttrim,BXreg
		RETURN   
                      
; This function returns the selected channel. WREG is the index into
; the ChannelOrder table. The indexed value is moved into NextTime.                      
SelectOutputChannel
 	; Build index
		DECF	WREG
		ANDLW	7
		RLNCF	WREG		; * 2
		RLNCF	WREG		; * 4
		RLNCF	WREG		; * 8
		ADDWF	PCL
                ; Aileron
                MOVE16	chAIL,NextTime
		RETURN
		NOP
		NOP
                ; Elevator
                MOVE16	chELE,NextTime
		RETURN
		NOP
		NOP
                ; Rudder
                MOVE16	chRUD,NextTime
		RETURN
		NOP
		NOP
                ; Throttle
                MOVE16	chTHT,NextTime
		RETURN
		NOP
		NOP
                ; CH5
                MOVE16	chCH5,NextTime
		RETURN
		NOP
		NOP
                ; CH6
                MOVE16	chCH6,NextTime
		RETURN
		NOP
		NOP
                ; CH7
                MOVE16	chCH7,NextTime
		RETURN
		NOP
		NOP
                ; CH8
                MOVE16	chCH8,NextTime
		RETURN
		
		ORG	200
; This function will return the channel number in reg AXreg. The
; channel number must be in WREG the channels are numbered 1 to 8.
; The position data is read from the mixed position array.
GetFrom
		MOVLR	HIGH AposM
		DECF	WREG
		ANDLW	7
		MULLW	5
		MOVFP	PRODL,WREG
		ADDWF	PCL	
	; Channel 1
		MOVFP	AposM,WREG
		MOVWF	AXreg
		MOVFP	AposM+1,WREG
		MOVWF	AXreg+1
		RETURN
	; Channel 2
		MOVFP	EposM,WREG
		MOVWF	AXreg
		MOVFP	EposM+1,WREG
		MOVWF	AXreg+1
		RETURN
	; Channel 3
		MOVFP	RposM,WREG
		MOVWF	AXreg
		MOVFP	RposM+1,WREG
		MOVWF	AXreg+1
		RETURN
	; Channel 4
		MOVFP	TposM,WREG
		MOVWF	AXreg
		MOVFP	TposM+1,WREG
		MOVWF	AXreg+1
		RETURN
	; Channel 5
		MOVFP	CH5posM,WREG
		MOVWF	AXreg
		MOVFP	CH5posM+1,WREG
		MOVWF	AXreg+1
		RETURN
	; Channel 6
		MOVFP	CH6posM,WREG
		MOVWF	AXreg
		MOVFP	CH6posM+1,WREG
		MOVWF	AXreg+1
		RETURN
	; Channel 7
		MOVFP	CH7posM,WREG
		MOVWF	AXreg
		MOVFP	CH7posM+1,WREG
		MOVWF	AXreg+1
		RETURN
	; Channel 8
		MOVFP	CH8posM,WREG
		MOVWF	AXreg
		MOVFP	CH8posM+1,WREG
		MOVWF	AXreg+1
		RETURN

; This function will sum the value in AXreg with the channel number defined
; in the WREG. This sum is performed on the position variable array. If the
; MSB is set then the value is AXreg replaces the old position value, if the
; MSB is clear then AXreg is added to the position value
ApplyMix
		MOVLR	HIGH Apos
		BTFSC	WREG,7
		GOTO	ApplyMixReplace
		DECF	WREG
		ANDLW	7
		MULLW	5
		MOVFP	PRODL,WREG
		ADDWF	PCL	
	; Channel 1
		MOVFP	AXreg,WREG
		ADDWF	Apos,F
		MOVFP	AXreg+1,WREG
		ADDWFC	Apos+1,F
		RETURN
	; Channel 2
		MOVFP	AXreg,WREG
		ADDWF	Epos,F
		MOVFP	AXreg+1,WREG
		ADDWFC	Epos+1,F
		RETURN
	; Channel 3
		MOVFP	AXreg,WREG
		ADDWF	Rpos,F
		MOVFP	AXreg+1,WREG
		ADDWFC	Rpos+1,F
		RETURN
	; Channel 4
		MOVFP	AXreg,WREG
		ADDWF	Tpos,F
		MOVFP	AXreg+1,WREG
		ADDWFC	Tpos+1,F
		RETURN
	; Channel 5
		MOVFP	AXreg,WREG
		ADDWF	CH5pos,F
		MOVFP	AXreg+1,WREG
		ADDWFC	CH5pos+1,F
		RETURN
	; Channel 6
		MOVFP	AXreg,WREG
		ADDWF	CH6pos,F
		MOVFP	AXreg+1,WREG
		ADDWFC	CH6pos+1,F
		RETURN
	; Channel 7
		MOVFP	AXreg,WREG
		ADDWF	CH7pos,F
		MOVFP	AXreg+1,WREG
		ADDWFC	CH7pos+1,F
		RETURN
	; Channel 8
		MOVFP	AXreg,WREG
		ADDWF	CH8pos,F
		MOVFP	AXreg+1,WREG
		ADDWFC	CH8pos+1,F
		RETURN
ApplyMixReplace
		DECF	WREG
		ANDLW	7
		MULLW	5
		MOVFP	PRODL,WREG
		ADDWF	PCL	
	; Channel 1
		MOVFP	AXreg,WREG
		MOVWF	Apos
		MOVFP	AXreg+1,WREG
		MOVWF	Apos+1
		RETURN
	; Channel 2
		MOVFP	AXreg,WREG
		MOVWF	Epos
		MOVFP	AXreg+1,WREG
		MOVWF	Epos+1
		RETURN
	; Channel 3
		MOVFP	AXreg,WREG
		MOVWF	Rpos
		MOVFP	AXreg+1,WREG
		MOVWF	Rpos+1
		RETURN
	; Channel 4
		MOVFP	AXreg,WREG
		MOVWF	Tpos
		MOVFP	AXreg+1,WREG
		MOVWF	Tpos+1
		RETURN
	; Channel 5
		MOVFP	AXreg,WREG
		MOVWF	CH5pos
		MOVFP	AXreg+1,WREG
		MOVWF	CH5pos+1
		RETURN
	; Channel 6
		MOVFP	AXreg,WREG
		MOVWF	CH6pos
		MOVFP	AXreg+1,WREG
		MOVWF	CH6pos+1
		RETURN
	; Channel 7
		MOVFP	AXreg,WREG
		MOVWF	CH7pos
		MOVFP	AXreg+1,WREG
		MOVWF	CH7pos+1
		RETURN
	; Channel 8
		MOVFP	AXreg,WREG
		MOVWF	CH8pos
		MOVFP	AXreg+1,WREG
		MOVWF	CH8pos+1
		RETURN

;************************************************************************
;************************************************************************
;*****	MAIN PROGRAM  *****
;************************************************************************
;************************************************************************
start
	; First thing, kill the buzzer!
		BCF	DDRA,BUZZER,A
		BCF	PORTA,BUZZER,A  
		BCF	DDRB,PLLRST,A
		BCF	PORTB,PLLRST,A
		MOVLR	HIGH BeepTicks
		CLRF	BeepTicks
		CLRF	BeepCtr
	; Let hardware stabilize
		MOVLW	D'100'
		CALL Delay1mS
	; Kill the buzzer! again, make sure its dead!
		BCF	DDRA,BUZZER,A
		BCF	PORTA,BUZZER,A
		MOVLR	0
		CLRF	Cmode	
	; 100 mS startup delay to let all systems stabilize
		MOVLW	D'100'
		CALL Delay1mS
	; Init the port variables
		MOVLB	HIGH PORTD
		MOVFP	PORTD,WREG
		MOVWF	PORTDimage
		MOVWF	PORTDlast
		MOVWF	PORTDlatch
		MOVLB	HIGH PORTE
		MOVFP	PORTE,WREG
		MOVWF	PORTEimage
		MOVWF	PORTElast
		MOVWF	PORTElatch
		MOVLB	HIGH PORTH
		BCF	DDRH,AUXOUT
		BSF	PORTH,AUXOUT		; by default output the ppm pulse train
		MOVLB	HIGH DDRB
		BCF	DDRB,LED2  
	; Init math variables
		MOVEC	0,DEXreg
		MOVEC	0,DEXreg+2
		MOVEC	0,EEXreg
		MOVEC	0,EEXreg+2
		MOVEC	0,CEXreg
		MOVEC	0,CEXreg+2
	; Init misc variables
		MOVEC	0,MApos
		MOVEC	0,MEpos
		MOVEC	0,MRpos
		MOVEC	0,MTpos
		MOVLR	HIGH TimeOut
		CLRF	TimeOut
		CLRF	TimeOut1
		CLRF	TimeOut2
		CLRF	TimeOut3
		CLRF	TimeOut4
		CLRF	TimeOut5   
		SETF	TimerCount
		CLRF	FMSflag
		MOVLR	HIGH AUXMODE
		CLRF	AUXMODE
		MOVLR	HIGH LValarm
		CLRF	LValarm
	; Read the stick center positions
	        MOVLW   4
	        CALL    ADCread
	        MOVLW   4
	        CALL    ADCread
	        MOVLR   HIGH AilCenter
                MOVLB   HIGH ADRESL
	        MOVFP   ADRESL,WREG
	        MOVWF   AilCenter
	        MOVFP   ADRESH,WREG
	        MOVWF   AilCenter+1
	        MOVLW   5
	        CALL    ADCread
	        MOVLW   5
	        CALL    ADCread
	        MOVLR   HIGH AilCenter
                MOVLB   HIGH ADRESL
	        MOVFP   ADRESL,WREG
	        MOVWF   EleCenter
	        MOVFP   ADRESH,WREG
	        MOVWF   EleCenter+1
	; Load the defaults
		CALLF	LoadDefaults
		; Set DefaultAircraft equal to Aircraft
		MOVLR	HIGH Aircraft
		MOVFP	Aircraft,WREG
		MOVLR	HIGH DefaultAircraft
		MOVWF	DefaultAircraft
		MOVLR	0
	; Signon message
		CALL	LCDinit
		MOVLW	D'250'
		CALL Delay1mS
		MOVLW	D'250'
		CALL Delay1mS
		MOVLW	D'250'
		CALL Delay1mS
		MOVLW	D'250'
		CALL Delay1mS
	; Perform initializations...
		CALL	Timer3Init
		CALL	TachInit
		CALL 	USART1init
		CALL 	USART2init
	; Enable global interrups...
		BSF	INTCON,GIE
		BSF	INTCON,PEIE
		BSF	RCON,IPEN
	; Read the serial prom general data into bank 2
		; If the PRESET and the AUTOTRIM button are pressed, then bypass...
		CALL	SpromInit
		Pressed PORTD,PRESET
		BTFSC	ALUSTA,C
		GOTO	UseGeneral
		Pressed PORTE,AUTOT
		BTFSS	ALUSTA,C
		GOTO	UseDefaults
		; Read the gereral aircraft data...
UseGeneral
		CALL	LoadGeneral
		; Test the Signature, if its not valid call FormatSprom
		MOVLR	HIGH Signature
		MOVLW	0A5
		CPFSEQ	Signature
		GOTO	FormatIt
		MOVLW	0E7
		CPFSEQ	Signature+1
FormatIt
		CALL	FormatSprom
		; Read this aircraft...into bank 3
		CALL	LoadAircraft
		; Move ModelChannel to SelFreq
		MOVLR	HIGH ModelChannel
		MOVFP	ModelChannel,WREG
		MOVLR	HIGH SelFreq
		MOVWF	SelFreq
	; Init the PLL and turn the RF off
		CALL	PLLinit    
		CALL	PLLCalNreg
		; Set the LSB of Freg to F2 to turn off the RF
		MOVLR	HIGH Freg
		MOVLW	0F2
		MOVWF	Freg
		CALL	PLLsetup	
UseDefaults
		; Make sure the AUTOTRIM button is released before
		; we continue...
		Release PORTE,AUTOT
	; If Student mode turn on uart 2 interrupts
		MOVLR	HIGH Student
		MOVFP	Student,Areg
		BTFSS	Areg,0
		GOTO	StartNoStudent
		; Turn on the interrupts
		MOVLB	HIGH PIE2
		BSF	PIE2,RC2IE
StartNoStudent
	; Test if the option button and the preset button are pressed
	; If they are both pressed then enter the IO test routine
		Pressed	PORTE,OPTION
		BTFSC	ALUSTA,C
		GOTO	mainStartup
		Pressed	PORTD,PRESET
		BTFSS	ALUSTA,C
		GOTO	TestIO
mainStartup
		; If student mode turn off RF
		MOVLR	HIGH Student
		MOVFP	Student,Areg
		MOVLR	HIGH SelFreq
		MOVLW	0FF
		BTFSC	Areg,0
		MOVWF	SelFreq
		CPFSLT	SelFreq
		GOTO	Startup1
	; If Retracks up warning is enabled and the retracts are up,
	; issue a warning to the pilot
		MOVLR	HIGH RetractsWarning
		BTFSS	RetractsWarning,0
		GOTO	NoRetractWarn
		MOVLB	HIGH PORTD
		BTFSC	PORTD,CH5
		GOTO	NoRetractWarn
		; If here warn the pilot before the RF goes on!
		MOVLW	LINE1
		CALL	LCDsendCMD
		PrintMess MES16
		MOVLW	LINE2
		CALL	LCDsendCMD
		PrintMess MES8
NRWwfo
		Pressed	PORTE,OPTION
		BTFSC	ALUSTA,C
		GOTO	NRWwfo
		Release	PORTE,OPTION
		MOVLW	D'200'
		CALL	Delay1mS
NoRetractWarn
	; If jumper OPT1 or OPT2 is not in then no RF deck to control
		MOVLB	HIGH PORTC
		BTFSS	PORTC,OPT2
		GOTO	RFask
		BTFSC	PORTC,OPT1
		GOTO	Startup1
	; Display the Freq and ask pilot
RFask
		MOVLW	LINE1
		MOVLR	HIGH Ctemp
		MOVWF	Ctemp
		CALLF	DisplayFrequency
		BCF	ALUSTA,C
		CALLF	Accept
		; If no, set SelFreq=FF else turn on rf
		BTFSC	ALUSTA,C
		GOTO	Startup2
		; Here to leave rf off
		MOVLR	HIGH SelFreq
		MOVLW	0FF
		MOVWF	SelFreq
		GOTO	Startup1
Startup2	; Here to turn on rf
		CALL	PLLinit    
		CALL	PLLCalNreg
		CALL	PLLsetup
		MOVLW	D'10'
		CALL	Delay1mS
Startup1
		MOVLR	HIGH Mode
		MOVLW	modeRUN
		MOVWF	Mode
	; Read a few more setup parameters...
		MOVE	SyncWidth,Sync
		MOVLR	HIGH MaxChannels
		MOVFP	MaxChannels,WREG
		MOVLR	HIGH NumChan
		MOVWF	NumChan
	; Init the button id byte
		CALL	ButtonIDinit
;
; main program code goes here. There are two main loop
; modes, RUN and CAL. The mode is controlled by the RUN/CAL
; switch on the transmitter. The following functions are
; performed in each mode.
;
; RUN:
;	1.) Read all pots and perform the normalizations
;	2.) Calculate all servo position times
;	3.) Update display
;
; CALIBRATE:
;	1.) Look for received messages from host computer
;	2.) Process commands send from host
;	3.) Allow user to configure radio
;
; Every time around the main loop the run/cal switch is tested,
; if it remains the same for two passes then the mode is channged.
;
	; Turn on the timer        
ifdef	CountOn
		MOVLR	HIGH Cmode
		MOVLW	1
		MOVWF	Cmode
		MOVE	DWNSecs,Dsecs
		CLRF	Usecs
		CLRF	Umins
endif
main     
	; Test the stack overflow bit and light LED2 if its set!
		BTFSC	STKPTR,STKFUL
		GOTO	NoStackOverflow
		MOVLB	HIGH DDRB
		BCF	DDRB,LED2
		BCF	PORTB,LED2
NoStackOverflow
	; Test the run/cal switch...
		MOVLR	HIGH PORTEimage
		BTFSC	PORTEimage,RUNCAL
		GOTO	RUNmode
		; Here if in the CAL mode, test current system mode
		MOVLW	modeRUN
		CPFSEQ	Mode
		GOTO	CALmode
		; If here, beep three times and change to CAL mode
		MOVLR	HIGH BeepCyl
		MOVLW	5
		MOVPF	WREG,BeepCyl
		MOVLW	D'7'
		CALL	Beep		; Startup short beep!
		MOVLW	modeCAL
		MOVWF	Mode
		; Make sure the default aircraft is loaded...
		MOVLR	HIGH DefaultAircraft
		MOVFP	DefaultAircraft,WREG
		MOVLR	HIGH Aircraft
		CPFSEQ	Aircraft
		GOTO	Reload
		GOTO	CALmode
Reload
		MOVWF	Aircraft
		CALL	LoadAircraft
		GOTO	CALmode
;**********************************************************************************
; R U N    M O D E
;**********************************************************************************
RUNmode
		MOVLW	modeRUN
		MOVWF	Mode
		CALL	AlternateAircraft
		CALL	CalculateNormalizedPositions 
		CALL	TimerEnable
		; If master mode and AutoTrim button is pressed then
		; Apply positions from slave
		MOVLR	HIGH Master
		BTFSS	Master,0
		GOTO	RUNmodeNotMaster
		; Is auto trim button pressed?
		MOVLR	HIGH SWATRIM
		MOVFP	SWATRIM,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	RUNmodeNotMaster
		; Test if this is the Futaba mode....
		MOVLR	HIGH MasterMode
		TSTFSZ	MasterMode
		GOTO	FutabaMode
		MOVE	MApos,Apos
		MOVE	MEpos,Epos
		MOVE	MRpos,Rpos
		MOVE	MTpos,Tpos
		GOTO	RUNmodeNotMaster
FutabaMode
		; Here if its Futaba mode, Set INT1 to high priority and TMR3 to low
		BSF	INTCON3,INT1IP
		BCF	IPR2,CCP2IP
		GOTO	FutabaDone
RUNmodeNotMaster			; , Set INT1 to low priority and TMR3 to high
		BCF	INTCON3,INT1IP
		BSF	IPR2,CCP2IP
FutabaDone
		; If we are in student mode, do no more processing!
		MOVLR	HIGH Student
		BTFSC	Student,0
		GOTO	RUNmode3
		CALL	ThrottleTrim
		BTFSC	ALUSTA,Z
		GOTO	RUNmode3
		CALL	ApplyDualRates
		CALL	ApplyExpo
		CALL    ApplySnap
		CALL	AutoTrim
		CALL	ApplyTrims
		CALL	ApplyFixedMixersPrior
		CALL	ApplyMixers
		CALL	ApplyFixedMixers
		MOVLR	HIGH FMSflag
		TSTFSZ	FMSflag
		CALL	FMS
RUNmode3
		; Set timeout 3 to a count of 1 and wait for it to clear.
		; This will insure we have time to update the channel times
		; before the ISR needs them
		MOVLR	HIGH TimeOut3
		MOVLW	1
		MOVWF	TimeOut3
RUNmode1                              
		MOVLR	HIGH TimeOut3
		TSTFSZ	TimeOut3
		GOTO	RUNmode1
		CALL	CalculateServoPositions
		; We will update the display every 1/4 sec using timeout4
		MOVLR	HIGH TimeOut4
		TSTFSZ	TimeOut4
		GOTO	RUNmode2
		MOVLW	d'10'
		MOVWF	TimeOut4
		CALL	Display
RUNmode2
		; Clear COMM port 2 overrun flags here...
		MOVLB	HIGH RCSTA2
		BTFSS	RCSTA2,OERR
		GOTO	RUNmode4
		; Here with an overrun
		BCF	RCSTA2,CREN
		BSF	RCSTA2,CREN
		; Empty the receive buffer
		MOVLB	HIGH RCREG2
		MOVFP	RCREG2,WREG
RUNmode4
		GOTO	main
;**********************************************************************************
; C A L   M O D E
;**********************************************************************************
CALmode
	; Display the CAL mode message...
		MOVLW	LINE1
		CALL	LCDsendCMD
		PrintMess CALMES0
		MOVLW	LINE2
		CALL	LCDsendCMD
		PrintMess MES8
	; If option is pressed then enter the CAL function
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	CalNotSel
		CALLF	Calibration
CalNotSel
	;
		CALL	CalculateNormalizedPositions
		CALL	ApplyDualRates
		CALL	ApplyExpo
		CALL    ApplySnap
		CALL	AutoTrim
		CALL	ApplyTrims
		CALL	ApplyFixedMixersPrior
		CALL	ApplyMixers
		CALL	ApplyFixedMixers
		CALL	CalculateServoPositions
	; Call the serial routine in a tight loop while
	; MessState > 0 and TimeOut1 > 0
S2
		CALL	USART1rec
		MOVLW	0
		MOVLR	HIGH MessState
		CPFSGT	MessState
		GOTO	S1		; Exit in state 0, idle
		CPFSGT	TimeOut1
		GOTO	S1		; Exit if timed out
		GOTO	S2
S1
		CLRF	MessState
		; Clear the overrun flags here...
		MOVLB	HIGH RCSTA1
		BTFSS	RCSTA1,OERR
		GOTO	S3
		; Here with an overrun
		BCF	RCSTA1,CREN
		BSF	RCSTA1,CREN
S3
		MOVLR	0
		MOVLB	0
	; End of serial comms with host PC
	; Test the command flag and process any requests
		MOVLR	HIGH Cmd
		MOVLW	31		; Read general reg
		CPFSEQ	Cmd
		GOTO	Not31
		; Here if its a read general command
		CALL	LoadGeneral
		GOTO	CmdEnd
Not31
		MOVLW	32
		CPFSEQ	Cmd
		GOTO	Not32
		; Here if its a read aircraft data command
		CALL	LoadAircraft
		GOTO	CmdEnd
Not32
		MOVLW	33		; Write general reg
		CPFSEQ	Cmd
		GOTO	Not33
		; Here if its a write general command
		CALL	SaveGeneral	
		GOTO	CmdEnd
Not33	
		MOVLW	34		; Write aircraft data
		CPFSEQ	Cmd
		GOTO	CmdEnd
		; Here if its a write aircraft data command
		CALL	SaveAircraft
CmdEnd
		CLRF	Cmd
	; End of command processing
		GOTO	main
;******************************************************************

DisplayAircraftName
		MOVLR	0
	; Display the aircraft name on the second line
		MOVLW	D'16
		MOVWF	Breg
		MOVLW	LINE2
		CALL	LCDsendCMD
		MOVLW	LOW Name
		MOVWF	FSR1L
		MOVLW	HIGH Name
		MOVWF	FSR1H		
Next_Char
		MOVFP	POSTINC1,WREG
		CALL	LCDsendData
		DECFSZ	Breg
		GOTO	Next_Char
		RETURN
;
; This is the run mode display update subroutine.
;
Display
		MOVLR	0
		MOVLB	0
	; Display the Mixer states...
ifdef	ECMA1010display
		; Turn on the RF output ICON if RF is on
		MOVLR	HIGH SelFreq
		BTFSC	SelFreq,7
		GOTO	RFisOFF
		MOVLW	0F7
		CALL	LCDsendCMD
		PrintMess MRFON
RFisOFF
		MOVLW	0DC
		CALL	LCDsendCMD
		MOVLR	HIGH SWALT
		MOVFP	SWALT,WREG
		CALL	SwitchTest
		MOVLW	99
		BTFSS	ALUSTA,C
		MOVLW	00
		CALL	LCDsendData
		MOVLW	LINE1+4
		CALL	LCDsendCMD
else
		MOVLW	LINE1+4
		CALL	LCDsendCMD
		MOVLW	' '
		CALL	LCDsendData
		MOVLR	HIGH SelFreq
		MOVLW	'R'
		BTFSC	SelFreq,7
		MOVLW	' '
		MOVLR	0
		CALL	LCDsendData
		MOVLR	HIGH SWALT
		MOVFP	SWALT,WREG
		CALL	SwitchTest
		MOVLW	'A'
		BTFSS	ALUSTA,C
		MOVLW	' '
		CALL	LCDsendData
endif
		MOVLR	HIGH SWMIX1
		MOVFP	SWMIX1,WREG
		CALL	SwitchTest
		MOVLW	'M'
		BTFSC	ALUSTA,C
		MOVLW	'-'
		CALL	LCDsendData
		MOVLR	HIGH SWMIX2
		MOVFP	SWMIX2,WREG
		CALL	SwitchTest
		MOVLW	'M'
		BTFSC	ALUSTA,C
		MOVLW	'-'
		CALL	LCDsendData
		MOVLR	HIGH SWMIX3
		MOVFP	SWMIX3,WREG
		CALL	SwitchTest
		MOVLW	'M'
		BTFSC	ALUSTA,C
		MOVLW	'-'
		CALL	LCDsendData
ifndef	ECMA1010display
		MOVLW	' '
		CALL	LCDsendData
endif
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
		; Calculate the voltage
		MOVE	Vbat,AXreg
		MOVE	VmonG,BXreg
		CALL	Mult1616
		MOVFP	CEXreg+1,WREG
		MOVPF	WREG,CEXreg
		MOVFP	CEXreg+2,WREG
		MOVPF	WREG,CEXreg+1
		CLRF	CEXreg+2
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
	; If the Auto Trim button is pressed then display the total on time of
	; the transmitter
		MOVLR	HIGH SWATRIM
		MOVFP	SWATRIM,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	DispNoBT
		; Here is the Auto Trim button is pressed
		MOVLW	LINE1
		CALL	LCDsendCMD
		MOVE	BatteryTimer,CEXreg
		CALL	LCDintZS		
DispNoBT	
		; Test the BTflag and update the time if necessary
		MOVLR	HIGH BTflag
		BTFSS	BTflag,7
		GOTO	DispNoSaveBT   
		CLRF	BTflag
		; Here to update the time in SPROM
		MOVLW	2
		MOVPF	WREG,Breg	; Number of bytes to write
		MOVLW	20		; Bank 2 for data source
		MOVPF	WREG,Areg
		MOVLW	LOW BatteryTimer
		MOVPF	WREG,FSR1	; RAM address of data to write
		CALL	SaveSPROM
DispNoSaveBT
	; Display the Throttle Adjust message if the TTflag is set
		CALL	ThrottleAdjustMessage
		BTFSC	ALUSTA,C
		GOTO	DispAircraftDone		
	; Display the receiver bat voltage if its non zero..
		CALL	RecVoltage
		BTFSC	ALUSTA,C
		GOTO	DispAircraftDone
	; Display The Tach RPM if enabled
		CALL	TackDisplay
		BTFSC	ALUSTA,C
		GOTO	DispAircraftDone
	; Call the Button ID function
		CALL	ButtonID
		; If timeout5 is not zero then exit...
		MOVLR	HIGH TimeOut5
		MOVFP	TimeOut5,WREG
		IORWF	WREG
		BTFSS	ALUSTA,Z
		GOTO	DispAircraftDone
	; Display the aircraft name on the second line
		; If student mode then display student
		MOVLR	HIGH Student
		BTFSS	Student,0
		GOTO	DispNotStudent
		MOVLW	LINE2
		CALL	LCDsendCMD
		PrintMess MES10
		GOTO	DispAircraftDone
DispNotStudent
		CALL	DisplayAircraftName
DispAircraftDone
	; Process the option button press and release
		MOVLR	HIGH PORTEimage
		BTFSC	PORTEimage,OPTION
		GOTO	Dsp1
		; Test if its been processed
		BTFSS	PORTElatch,OPTION
		GOTO	Dsp1
		; Beep one time to indicate we detected the
		; button...
		BCF	PORTElatch,OPTION
		MOVLW	D'1'
		MOVWF	BeepCyl
		MOVLW	D'5'
		CALL	Beep
	; If the mode is 1 set it to 0, if its 0 set it to 1
		MOVLR	HIGH Cmode
		TSTFSZ	Cmode
		GOTO	Dsp2
		; Here if counter mode is 0, set to 1 and start the down counter
		INCF	Cmode,F
		MOVE	DWNSecs,Dsecs
		CLRF	Usecs
		CLRF	Umins

		GOTO	Dsp1
Dsp2		
		; Here if counter mode is 1
		DECF	Cmode,F

Dsp1
	; Test the timer mode...
	; Display the down counter, do the following
	; at 1 min, beep 3 times
	; at 30 sec, beep 2 times
	; at 10 sec, beep 1 time
	; and one time at 5,4,3,2,1 sec
		MOVLR	HIGH Cmode
		BTFSS	Cmode,0
		GOTO	Dsp3 
		; Here if we are in the count down mode
		TSTFSZ	Dmins
		GOTO	Dsp3
		; Here if this is the last minute of the 
		; timer, test for and generate the warning beeps
		MOVLW	D'59'	
		CPFSEQ	DsecsLatch
		GOTO	Dsp3a
		MOVLW	5
		MOVWF	BeepCyl
		MOVLW	D'10'
		CALL	Beep
		GOTO	Dsp3
Dsp3a
		MOVLW	D'30'	
		CPFSEQ	DsecsLatch
		GOTO	Dsp3b
		MOVLW	3
		MOVWF	BeepCyl
		MOVLW	D'10'
		CALL	Beep
		GOTO	Dsp3
Dsp3b
		MOVLW	D'10'	
		CPFSEQ	DsecsLatch
		GOTO	Dsp3c
		MOVLW	1
		MOVWF	BeepCyl
		MOVLW	D'10'
		CALL	Beep
		GOTO	Dsp3
Dsp3c
		MOVLW	6	
		CPFSLT	DsecsLatch
		GOTO	Dsp3
		MOVLW	1
		MOVWF	BeepCyl
		MOVLW	D'10'
		CALL	Beep
		GOTO	Dsp3

Dsp3
		MOVLW	07F
		MOVWF	DsecsLatch
	; Display the current ON time or count down time... 
		; If Cmode = 0 then display the on time
		; If Cmode = 1 and CNTmode = 1 then display the down timer
		; If Cmode = 1 and CNTmode = 0 then display the up timer
		; If Cmode = 1 and CNTmode = 2 then display the down timer and stop at 0
		MOVFP	Secs,WREG       ; Move counter to DXreg
		MOVWF	DXreg
		MOVFP	Mins,WREG
		MOVWF	DXreg+1
		MOVLW	1
		CPFSEQ	Cmode
		GOTO	Dsp3d           ; Jump if Cmode is zero
	   ; Here if Cmode == 1
		MOVFP	Dsecs,WREG      ; Test down counter to see if its 0
		IORWF	Dmins,W
		BTFSC	ALUSTA,Z
		GOTO	DSP3d1          ; Jump if zero
	   ; Here if down counter has not reached 0	  
		MOVFP	Dsecs,WREG      ; Move down counter to DXreg
		MOVWF	DXreg
		MOVFP	Dmins,WREG
		MOVWF	DXreg+1
		MOVLW	0 
		MOVLR	HIGH CNTmode
		CPFSEQ	CNTmode
		GOTO	Dsp3d           ; If CNTmode != 0 then jump
DSP3d1	   ; Here if CNTmode == 0   
		MOVLW	2 
		MOVLR	HIGH CNTmode
		SUBWF   CNTmode,W
		BTFSC	ALUSTA,Z
		GOTO	Dsp3d1a         ; If CNTmode == 2 then jump
           ; Here if CNTmode != 2       
		MOVLR	HIGH Usecs      ; Move up time to DXreg
		MOVFP	Usecs,WREG
		MOVWF	DXreg
		MOVFP	Umins,WREG
		MOVWF	DXreg+1
		GOTO    Dsp3d
Dsp3d1a    ; Here if CNTmode == 2
                CLRF    WREG
                MOVLR   HIGH DXreg
		MOVWF	DXreg
		MOVWF	DXreg+1
Dsp3d	   ; Display the time in DXreg	                  
		MOVLR	HIGH DXreg
		MOVLW	LINE1+ONTIMEPOS
		CALL 	LCDsendCMD
		MOVFP	DXreg+1,WREG
		MOVPF	WREG,CEXreg
		CLRF	CEXreg+1
		CLRF	CEXreg+2
		CLRF	CEXreg+3
		CALL	LCDint2
		MOVLW	':'
		CALL	LCDsendData
		MOVFP	DXreg,WREG
		MOVPF	WREG,CEXreg
		CALL	LCDint2
		RETURN
                
; This function looks at the Timer enabling options:
;  1.) The enable switch
;  2.) The throttle stick position enable
; If both of these are true, then the TimerCount flag is
; set, FF. This function is called in the run main loop.                
TimerEnable    
	; Read the enabled switch status 
		MOVLR	HIGH TEnaSW
		MOVFP	TEnaSW,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	TE1       
	; Test the throttle position
		MOVLR	HIGH Tthres
		MOVLW	0
		CPFSGT	Tthres
		GOTO	TE2   
		MOVLR	HIGH Tpos
		BTFSC	Tpos+1,7
		GOTO	TE1
		MOVLR	HIGH Tthres
		MOVFP	Tthres,WREG
		MOVLR	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	Tpos,WREG
		SUBWF	CEXreg
		MOVFP	Tpos+1,WREG
		SUBWF	CEXreg+1,W
		BTFSC	ALUSTA,C
		GOTO	TE1  
	; Enable the counter 
TE2    		
		MOVLR	HIGH TimerCount
		SETF	TimerCount
		RETURN
TE1                               
		MOVLR	HIGH TimerCount
		CLRF	TimerCount
		RETURN

; This function tests the TTflag, if its set then the Throttle
; adjust message is printed on the second line of the display
; and the carry flag is set on exit.
ThrottleAdjustMessage
	; Test the TTflag
	        BCF	ALUSTA,C
		MOVLR	HIGH TTflag
		BTFSS	TTflag,7
		RETURN
	; Here to display message
		MOVLW	LINE2
		CALL	LCDsendCMD
		PrintMess MES24
	; Set carry flag and exit
	        BSF	ALUSTA,C	
		RETURN
		             
; This function will read ADC channel 13, this is the receiver
; voltage monitor channel. If the value is greater than a few 
; counts then the data is displayed on the second line of the 
; display. If the receiver value is displayed then this function
; returns with the carry flag set.
RecVoltage       
	; Read ADC channel 13 
		MOVLW	D'13'
		CALL	ADCread		; Results are in Pos
		MOVLW	D'13'
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

;
; This is a IO test routine entered when the Option and Preset buttons are
; held down during power up. The display will show binary data for ports
; C and D on the top line, and G and H on the second line.
;
TestIO
		Release	PORTE,OPTION
		Release	PORTD,PRESET
TestIOa
ifdef ECMA1010display
		MOVLW	LINE1
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLW	LINE3
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLW	LINE4
		CALL    LCDsendCMD
		PrintMess MES0
endif
	; Read and display parallel IO ports
		MOVLW	LINE1
		CALL    LCDsendCMD	; First line of display
		MOVLB	HIGH PORTD	; Port D
		MOVFP	PORTD,WREG
		CALL	LCDbinary
ifdef ECMA1010display
		MOVLW	LINE2
		CALL    LCDsendCMD
endif
		MOVLB	HIGH PORTE	; Port E
		MOVFP	PORTE,WREG
		CALL	LCDbinary
		MOVLW	LINE3		; Second line of display
		CALL    LCDsendCMD
		MOVLB	HIGH PORTG	; Port G
		MOVFP	PORTG,WREG
		CALL	LCDbinary
ifdef ECMA1010display
		MOVLW	LINE4
		CALL    LCDsendCMD
endif
		MOVLB	HIGH PORTH	; Port H
		MOVFP	PORTH,WREG
		CALL	LCDbinary
	; Test LEDs
	; PortD bit 0 (Ail DR) = LED1
	; PortD bit 1 (Eve DR) = LED2
		MOVLB	HIGH PORTD
		MOVFP	PORTD,WREG
		MOVLB	HIGH PORTC
	        BSF     PORTC,LED1
	        BSF     PORTB,LED2
	        BTFSC   WREG,0
	        BCF     PORTC,LED1
	        BTFSC   WREG,1
	        BCF     PORTB,LED2
	; Test the buzzer = PORTD bit 2 (Rud DR)
	        BCF     PORTA,BUZZER
	        BTFSC   WREG,2
	        BSF     PORTA,BUZZER
	; Loop untill the option button is pressed...
		MOVLW	D'50'
		CALL	Delay1mS
		Pressed	PORTD,OPTION
		BTFSC	ALUSTA,C
		GOTO	TestIOa
		Release	PORTD,OPTION
	; Read the ADC channels...
ifdef ECMA1010display
		MOVLW	LINE3
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLW	LINE4
		CALL    LCDsendCMD
		PrintMess MES0
endif
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES0
		MOVLR	HIGH AXreg
		CLRF	AXreg
TestIO1
		MOVLW	LINE1
		CALL    LCDsendCMD
		PrintMess MES3
		MOVLW	LINE1+TESTCHPOS
		CALL    LCDsendCMD
		MOVLR	HIGH AXreg
		MOVFP	AXreg,WREG
		CALL	LCDhex
		CALL	ADCread
		MOVLW	LINE1+TESTVALPOS
		CALL    LCDsendCMD
		MOVLB	HIGH ADRESH
		MOVPF	ADRESH,WREG
		CALL	LCDhex	
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,WREG
		CALL	LCDhex	
	; Delay
		MOVLW	D'50'
		CALL	Delay1mS
	; If option button is pressed then advance to next channel
	; after channel 12, exit
		Pressed	PORTD,OPTION
		BTFSC	ALUSTA,C
		GOTO	TestIO1
		Release	PORTD,OPTION
	; Advance ADC channel
		MOVLR	HIGH AXreg
		INCF	AXreg
		MOVLW	D'12'
		CPFSGT	AXreg
		GOTO	TestIO1
		GOTO	TestIOa

; This function will read the ADC channel defined in WREG 256 times and
; sum the results in CEXreg.
ReadADC256
	; First clear CEXreg
		MOVLR	HIGH CEXreg
		CLRF	CEXreg
		CLRF	CEXreg+1
		CLRF	CEXreg+2
		CLRF	CEXreg+3
	; Save Channel to Areg
		MOVWF	Areg
	; Setup Breg as a loop counter
		CLRF	Breg
	; Read the ADC
RD256a
		MOVFP	Areg,WREG
		CALL	ADCread
	; Sum the result
		MOVLB	HIGH ADRESH
		MOVLR	HIGH CEXreg
		MOVFP	ADRESL,WREG
		ADDWF	CEXreg
		MOVFP	ADRESH,WREG
		ADDWFC	CEXreg+1
		BTFSC	ALUSTA,C
		INCF	CEXreg+2
	; Do the loop counter test
		DECFSZ	Breg
		GOTO	RD256a
		RETURN
;
; This function reads data from the ADC channel defined in WREG.
; The results are in the ADC registers when this function returns.
; The results are also written to Pos.
; Areg will contain the channel number when this function returns.
;
; If the PROLINE option is selected then the trim channels are read
; using the 5 volt reference.
ADCread
		MOVWF	Areg		; Save channel number
	; Configure the ADC, channels 2 thru 7 use external reference, for a PROLINE
	; or 2 thru 11 for a MicroPro
		MOVLW	060   		; 5V reference
		MOVLB	HIGH ADCON1
		MOVPF	WREG,ADCON1
		MOVLW	1
		CPFSGT	Areg
		GOTO	ADCread1 
		MOVLW	D'12'           ; GAA was 11, fixed 11/18/01
		CPFSLT	Areg
		GOTO	ADCread1
ifdef	PROLINE
		MOVLW	7
else
		MOVLW	0B
endif
		CPFSGT	Areg
		BSF	ADCON1,PCFG0
ADCread1
	; Select the channel and start the conversion
		MOVPF	Areg,WREG
		RLNCF	WREG
		RLNCF	WREG
		RLNCF	WREG
		RLNCF	WREG
		IORLW	1
		MOVLB	HIGH ADCON0
		MOVPF	WREG,ADCON0
		NOP			; delay to let the Mux settle
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		BSF	ADCON0,GO
	; Wait for the ADC to finish
ADCread0
		BTFSC	ADCON0,DONE
		GOTO	ADCread0
	; Save results in Pos
		MOVLR	HIGH Pos
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,Pos
		MOVPF	ADRESH,Pos+1
		RETURN

; This function will read the ADC channel again and sum this result
; with the value in Pos. This is used for oversampling.
ADCreadAgainandSum
		MOVLB	HIGH ADCON0
		BSF	ADCON0,GO
	; Wait for the ADC to finish
ADCreadAgain0
		BTFSC	ADCON0,DONE
		GOTO	ADCreadAgain0
	; Now sum with POS
		MOVLR	HIGH Pos
		MOVLB	HIGH ADRESL
		MOVFP	ADRESL,WREG
		ADDWF	Pos,F
		MOVFP	ADRESH,WREG
		ADDWFC	Pos+1,F
		RETURN

; WREG has channel number.
OverSample
	; Read the ADC channel 4 times
		CALL	ADCread
		CALL	ADCreadAgainandSum
		CALL	ADCreadAgainandSum
		CALL	ADCreadAgainandSum
	; Now divide by 4, or 2 if we are oversampling
		MOVLR	HIGH Pos
		; Divide by 2
		RRCF	Pos+1
		BCF	Pos+1,7
		RRCF	Pos
ifndef		ENABLEOVERSAMPLE
		; Divide by 2
		RRCF	Pos+1
		BCF	Pos+1,7
		RRCF	Pos
endif
		RETURN


; Timer3 init routine.
Timer3Init
	; Write initial values into data arrays
		MOVLR	HIGH Pstate
		CLRF	Pstate
		CLRF	Secs
		CLRF	Mins
		MOVLW	TICKSPER
		MOVPF	WREG,Tick
	; Fill the channel times array with nominal values
		MOVEC	D'400',Sync
		MOVEC	D'400',NextTime
		CLRF	Psum
		CLRF	Psum+1
		MOVLW	D'16'
		MOVLR	HIGH Pstate
		MOVPF	WREG,NumChan
		CLRF	CHtimes
		CLRF	CHtimes+2
		CLRF	CHtimes+4
		CLRF	CHtimes+6
		CLRF	CHtimes+8
		CLRF	CHtimes+D'10'
		CLRF	CHtimes+D'12'
		CLRF	CHtimes+D'14'
		CLRF	CHtimes+D'16'
		CLRF	CHtimes+D'18'
		MOVLW	8
		MOVPF	WREG,CHtimes+1
		MOVPF	WREG,CHtimes+3
		MOVPF	WREG,CHtimes+5
		MOVPF	WREG,CHtimes+7
		MOVPF	WREG,CHtimes+9
		MOVPF	WREG,CHtimes+D'11'
		MOVPF	WREG,CHtimes+D'13'
		MOVPF	WREG,CHtimes+D'15'
		MOVPF	WREG,CHtimes+D'17'
		MOVPF	WREG,CHtimes+D'19'
	; Output initial Mod pin state and define as ouput
		BCF	PORTF-1,MOD,A	; Define as output
		BSF	PORTF,MOD,A	; Set initial state
	; Setup timer3 and turn on interrupts
	 	; Setup the compare register, using compare reg 2
		MOVLR	HIGH Sync
		MOVFP	Sync,WREG
		MOVLB	HIGH CCPR2L
		MOVPF	WREG,CCPR2L
		MOVLR	HIGH Sync + 1
		MOVFP	(Sync + 1),WREG
		MOVLB	HIGH CCPR2H
		MOVPF	WREG,CCPR2H
		MOVLW	0B			; Interrupt on conpare equal counter
						; and reset timer 3
		MOVLB	HIGH CCP2CON
		MOVPF	WREG,CCP2CON		; Setup the condition reg
		; Enable the interrupt, compare reg 2. timer 3 does not
		; generate an interrupt
		MOVLB	HIGH PIE2
		BSF	PIE2,CCP2IE
		MOVLB	HIGH PIR2
		BCF	PIR1,CCP2IF
		; Configure timer 3, sync count
		MOVLB	HIGH T3CON
 		MOVLW	00
 		MOVPF	WREG,T3CON
 		BSF	T3CON,TMR3ON
		RETURN

; Timer3 interrupt service routine
;
;   This function generates the PPM output signal. A state
;   variable Pstate controls the function. When a state ends
;   in an odd number then we are outputting the sync pulse.
;   Sync pulses have a constant width.
;
;   Timer 3 uses compare reg 2. When the compare reg matches the
;   counter then the counter is reset and an interrupt is generated.
;
TIMER3ISR
	; If we are in master mode, turn off UART2 interrupts
		MOVLR	HIGH Master
		BTFSS	Master,0
		GOTO	NotMaster
		MOVLB	HIGH PIE2
		BCF	PIE2,RC2IE
NotMaster
	;
		MOVLR	HIGH Pstate
	; Output the MOD pin state
		BTFSS	INTCON3,INT1IE
		BTG	PORTF,MOD,A
	; Output the AUXOUT signal
		MOVLB	HIGH PORTH
		MOVLR	HIGH AUXMODE
		BTFSS	AUXMODE,7
		GOTO	AuxServoChanMode
		BTG	PORTH,AUXOUT
		GOTO	EndAuxState
AuxServoChanMode
		MOVLR	HIGH AUXSTATE
		BTFSC	AUXSTATE,0
		GOTO	AuxStateClr
		BSF	PORTH,AUXOUT
		GOTO	EndAuxState
AuxStateClr
		BCF	PORTH,AUXOUT
EndAuxState
	; Set the timers next Period count
		MOVLW	0FF
		MOVLB	HIGH CCPR2H
		MOVPF	WREG,CCPR2H

		MOVLR	HIGH NextTime
		MOVFP	NextTime,WREG
		MOVLB	HIGH CCPR2L
		MOVPF	WREG,CCPR2L

		MOVLR	HIGH NextTime
		MOVFP	(NextTime + 1),WREG
		MOVLB	HIGH CCPR2H
		MOVPF	WREG,CCPR2H
	; Advance to next state
		MOVLR	HIGH Pstate
		CLRF	WREG
		CPFSGT	Pstate
		CALL	RTC		; Do the real time clock stuff.
					; This happens at 40 Hz
		MOVLR	HIGH Pstate
		INCF	Pstate
		MOVFP	Pstate,WREG
		ANDLW	0FE
		CPFSLT	NumChan
		GOTO	TIMER3ISR0
	; IF here reset the state to 0
		CLRF	Pstate
		; Calculate the time to the next output sequence,
		; 40Hz rate
		MOVLW	LOW CYCLECOUNTS
		MOVPF	WREG,NextTime
		MOVFP	Psum,WREG
		SUBWF	NextTime,1
		MOVLW	HIGH CYCLECOUNTS
		MOVPF	WREG,NextTime+1
		MOVFP	Psum+1,WREG
		SUBWFB	NextTime+1,1
		CLRF	Psum
		CLRF	Psum+1
		GOTO	TIMER3ISR3
TIMER3ISR0
	; Test for an odd state number. If its odd then we
	; output the sync pulse time
		BTFSS	Pstate,0
		GOTO	TIMER3ISR1
		MOVFP	Sync,WREG
		MOVPF	WREG,NextTime
		MOVFP	Sync+1,WREG
		MOVPF	WREG,NextTime+1
	; Test if this channel position is being output to the
	; AUXOUT pin
		MOVLR	HIGH AUXMODE
		MOVFP	AUXMODE,WREG
		MOVLR	HIGH AUXSTATE
		BSF	AUXSTATE,0
		CPFSEQ	Pstate
		GOTO	TIMER3ISR2
		BCF	AUXSTATE,0
		GOTO	TIMER3ISR2
	; Test if this is the 9th chanel, if so then send
	; the sum divided by 16
TIMER3ISR1
;		MOVFP	Pstate,WREG
		MOVLW	D'18'
;		CPFSEQ	NumChan
		CPFSEQ	Pstate                  ; This should fix the channel 9 bug
		GOTO	TIMER3ISR1a
		MOVFP	Psum,WREG
		MOVPF	WREG,NextTime
		MOVFP	Psum+1,WREG
		MOVPF	WREG,NextTime+1
		RRCF	NextTime+1,1
		RRCF	NextTime,1
		RRCF	NextTime+1,1
		RRCF	NextTime,1
		RRCF	NextTime+1,1
		RRCF	NextTime,1
		RRCF	NextTime+1,1
		RRCF	NextTime,1
		MOVLW	0F
		ANDWF	NextTime+1,1
		GOTO	TIMER3ISR2
	; Get the next state time using indirect addressing
TIMER3ISR1a
		MOVLW	ChannelOrder
		MOVPF	WREG,FSR0
		MOVFP	Pstate,WREG
		RRCF	WREG
		BCF	WREG,7
		DECF	WREG
		MOVLR	HIGH ChannelOrder
		ADDWF	FSR0,F
		MOVPF	INDF0,WREG
		CALL	SelectOutputChannel
		; Subtract the Sync pulse width from this time
		MOVFP	Sync,WREG
		SUBWF	NextTime
		MOVFP	Sync+1,WREG
		SUBWFB	NextTime+1
	; Now sum the channel times
TIMER3ISR2
		MOVFP	NextTime,WREG
		ADDWF	Psum,1
		MOVFP	NextTime+1,WREG
		ADDWFC	Psum+1,1
	; Clear the interrupt bit and exit
TIMER3ISR3
		MOVLB	HIGH PIR1
		BCF	PIR1,CCP2IF
		RETURN

; This function is called at 40Hz and is responsible for all
; time generation. Up to 10mS can be spent in this routine.
RTC
	; Bypass the overrun test if not in the run mode
		MOVLR	HIGH Mode
		MOVLW	modeRUN
		CPFSEQ	Mode
		GOTO	NotOverrunTest
	; Test the OVERRUN flag if set then turn on the LED
		MOVLB	HIGH PORTC
		MOVLR	HIGH OVERRUN
		BSF	PORTC,LED1
		BTFSC	OVERRUN,0
		BCF	PORTC,LED1
	; Always set the OVERRUN flag
		MOVLW	0FF
		MOVWF	OVERRUN
NotOverrunTest
	; Insure that the Mod pin is in the correct state
		BCF	PORTH,AUXOUT
		MOVLR	HIGH SHIFT
		BTFSC	SHIFT,7
		GOTO	RTCx
	        BTFSS	INTCON2,INTEDG0
		BCF	PORTF,MOD,A
		GOTO	RTCy
RTCx
	        BTFSS	INTCON2,INTEDG0
		BSF	PORTF,MOD,A
RTCy
	;
		MOVLR	HIGH Tick
		DECFSZ	Tick
		GOTO	RTC1
	; If here its time to inc the secs, here one time per second
	; First test the down counter and dec if its not zero
		CALL	TachRead
		MOVLR	HIGH Cmode
		BTFSS	Cmode,0
		GOTO	RTC1a
		MOVLR	HIGH TimerCount
		MOVLW	0FF
		CPFSEQ	TimerCount
		GOTO	RTC1a		; Jump is not enabled
		MOVFP	Dsecs,WREG
		IORWF	Dmins,W
		BTFSC	ALUSTA,Z
		GOTO	RTC1d
	; Dec the down counter...
		TSTFSZ	Dsecs
		GOTO	RTC1b
		; Here if Sec is zero
		MOVLW	D'60'
		MOVWF	Dsecs
		DECF	Dmins,F
RTC1b
		DECF	Dsecs,F
RTC1c
		MOVFP	Dsecs,WREG
		MOVWF	DsecsLatch 
	; If CNTmode != 0 (down) and the down count times are zero,
	; then reset the up counters to zero
		MOVLR	HIGH CNTmode
		CLRF	WREG
		IORWF   CNTmode,W
		BTFSC	ALUSTA,Z
		GOTO	RTC1d
		MOVLR	HIGH Dsecs
		MOVFP	Dsecs,WREG
		IORWF	Dmins,W
		BTFSC	ALUSTA,Z
		GOTO	RTC1d
		CLRF	Usecs
		CLRF	Umins	
		GOTO	RTC1a		
	; Here to inc the up counter
RTC1d
                MOVLR   HIGH Usecs
		INCF	Usecs
		MOVLW	D'60'
		CPFSEQ	Usecs
		GOTO	RTC1a
		CLRF	Usecs
		INCF	Umins
RTC1a
		MOVLW	TICKSPER
		MOVPF	WREG,Tick
		INCF	Secs
		MOVLW	D'60'
		CPFSEQ	Secs
		GOTO	RTC1
	; If here its time to inc the minutes, here one time per minute
		CLRF	Secs
		INCF	Mins
		; Increment the battery timer and set the flag            
		MOVLR	HIGH BatteryTimer
		INCF	BatteryTimer
		BTFSC	ALUSTA,Z
		INCF	BatteryTimer+1
		SETF	BTflag				
RTC1              
	; If we are in master mode, turn on UART2 interrupts
		MOVLR	HIGH Master
		BTFSS	Master,0
		GOTO	RTC1NotMaster
		MOVLB	HIGH PIE2
		BSF	PIE2,RC2IE
	; Send an S to tell the Slave its ok to send!
		MOVLW	'S'
		CALL	USART2sendChar
		; Clear the MasterState variable
		MOVLR	HIGH MasterState
		CLRF	MasterState
RTC1NotMaster
	; Debounce port D
		MOVLR	HIGH PORTDimage
		MOVLB	HIGH PORTD
		MOVFP	PORTD,WREG
		XORWF	PORTDlast,F
		BTFSS	ALUSTA,Z
		MOVWF	PORTDimage
		MOVWF	PORTDlast
		MOVFP	PORTDimage,WREG
		IORWF	PORTDlatch,F
	; Debounce port E
		MOVLR	HIGH PORTEimage
		MOVLB	HIGH PORTE
		MOVFP	PORTE,WREG
		XORWF	PORTElast,F
		BTFSS	ALUSTA,Z
		MOVWF	PORTEimage
		MOVWF	PORTElast
		MOVFP	PORTEimage,WREG
		IORWF	PORTElatch,F
	; Test the TimeOut counters
		TSTFSZ	TimeOut
		DECF	TimeOut
		TSTFSZ	TimeOut1
		DECF	TimeOut1
		TSTFSZ	TimeOut2
		DECF	TimeOut2
		TSTFSZ	TimeOut3
		DECF	TimeOut3
		TSTFSZ	TimeOut4
		DECF	TimeOut4
		TSTFSZ	TimeOut5
		DECF	TimeOut5
	; Do the buzzer stuff...
		TSTFSZ	BeepCtr
		GOTO	RTC2
		RETURN
RTC2	; Here if the buzzer is active
		DECFSZ	BeepCtr
		RETURN
		MOVLB	HIGH PORTA
		BTG	PORTA,BUZZER
		DCFSNZ	BeepCyl
		RETURN
		MOVFP	BeepTicks,WREG
		MOVPF	WREG,BeepCtr
		RETURN

; Call this function with the number of ticks to beep in WREG
; BeepCly is assumed set...
Beep
		MOVLR	HIGH BeepTicks
		MOVPF	WREG,BeepTicks
		MOVPF	WREG,BeepCtr
	; Thur it on!
		MOVLB	HIGH PORTA
		BSF	PORTA,BUZZER
		RETURN

; This routine sends the value in Areg MSB first. The number of bits to send
; are defined in Breg. Both Areg and Breg are destroyed.
PLLsend
	; Select the bank
		MOVLB	HIGH PORTB
	; Set the data line
		BTFSC	Areg,7
		GOTO	PLLsend1
		BCF	PORTB,SDObit
		GOTO	PLLsend2
PLLsend1
		BSF	PORTB,SDObit
PLLsend2
	; Pulse the clock line
		BSF	PORTB,CLK
		BCF	PORTB,CLK
	; Loop untill finished
		RLNCF	Areg
		DECFSZ	Breg
		GOTO	PLLsend
		RETURN

; This function powers the PLL down and shuts off the RF output stage.
PLLpowerDown               
		MOVLR	HIGH PLLinitWORD
		MOVFP	PLLinitWORD+2,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend  
		MOVLR	HIGH PLLinitWORD
		MOVFP	PLLinitWORD+1,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend 
		MOVLR	HIGH PLLinitWORD
		MOVFP	PLLinitWORD,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		; Pulse the load line
		BSF	PORTG,PLLCS,A
		BCF	PORTG,PLLCS,A
		RETURN

; This function is used to calculate the PLL register N.
PLLCalNreg
        ; Calculate N, N=FCF/PDF
                MOVE24  FCF,CEXreg
                MOVE    PDF,DEXreg
                CALL    Divide2416
        ; Add the selected channel to the result. To allow the phase lock freq
        ; to be different that the channel spacing, the variable PMUL is provided.
                MOVLR   HIGH SelFreq
                MOVFP   SelFreq,WREG
                MOVLR	HIGH PMUL
                MULWF	PMUL
                MOVFP	PRODL,WREG
                MOVLR   HIGH CEXreg
                ADDWF   CEXreg,F
                BTFSC   ALUSTA,C
                INCF    CEXreg+1
                BTFSC   ALUSTA,C
                INCF    CEXreg+2
         ; Now move the result to Nreg and add the control bits...
                MOVLR   HIGH Nreg
                CLRF    Nreg
                CLRF    Nreg+1
                CLRF    Nreg+2
                MOVLR   HIGH CEXreg
                MOVFP   CEXreg,WREG
                RLNCF   WREG
                RLNCF   WREG
                BSF     WREG,0
                BCF     WREG,1
                ANDLW   01F
                BTFSC   CEXreg,3
                BSF     WREG,7
                MOVLR   HIGH Nreg
                MOVWF   Nreg
                ; Now the MS two bytes...
                MOVLR   HIGH CEXreg   
                RLCF    CEXreg+0
                RLCF    CEXreg+1
                RLCF    CEXreg+2
                RLCF    CEXreg+0
                RLCF    CEXreg+1
                RLCF    CEXreg+2
                RLCF    CEXreg+0
                RLCF    CEXreg+1
                RLCF    CEXreg+2
                RLCF    CEXreg+0
                RLCF    CEXreg+1
                RLCF    CEXreg+2
                MOVFP   CEXreg+1,WREG
                MOVLR   HIGH Nreg
                MOVWF   Nreg+1
                MOVLR   HIGH CEXreg
                MOVFP   CEXreg+2,WREG
                ANDLW   01F
                MOVLR   HIGH Nreg
                IORLW   HICUR
                MOVWF   Nreg+2
                RETURN

; This routine initializes the PLL. The three regs F, R, and N are downloaded to
; the PLL.
PLLsetup         
	; Calculate the Nreg
		CALL	PLLCalNreg
	; F register
		MOVLR	HIGH Freg
		MOVFP	Freg+2,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		MOVLR	HIGH Freg
		MOVFP	Freg+1,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		MOVLR	HIGH Freg
		MOVFP	Freg,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		; Pulse the load line
		BSF	PORTG,PLLCS,A
		BCF	PORTG,PLLCS,A
	; R register
		MOVLR	HIGH Rreg
		MOVFP	Rreg+2,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		MOVLR	HIGH Rreg
		MOVFP	Rreg+1,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		MOVLR	HIGH Rreg
		MOVFP	Rreg,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		; Pulse the load line
		BSF	PORTG,PLLCS,A
		BCF	PORTG,PLLCS,A
	; N register
		MOVLR	HIGH Nreg
		MOVFP	Nreg+2,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		MOVLR	HIGH Nreg
		MOVFP	Nreg+1,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		MOVLR	HIGH Nreg
		MOVFP	Nreg,WREG
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg
		CALL	PLLsend
		; Pulse the load line
		BSF	PORTG,PLLCS,A
		BCF	PORTG,PLLCS,A
		RETURN
;
; This function sets up the port directions and initalizes the data variables
; for the PLL.     
; The PLL PIC reset bit is set to 0
;
; Jumpers (PORTG):
;     OPT1 installed = 53 MHz
;     OPT2 installed = 50 MHz
;     BOTH installed = 72 MHz
;
PLLinit
	; Set port directions and initial states
		MOVLB	HIGH PORTB
		BCF	DDRB,SDObit
		BCF	DDRB,CLK
		BCF	DDRB,PLLRST
		BCF	PORTB,PLLRST
		BCF	PORTB,SDObit
		BCF	PORTB,CLK
		BCF	DDRG,PLLCS,A
		BCF	PORTG,PLLCS,A
	; Setup the PLL variables depending on the OPT1 and OPT2 jumpers
	        MOVLB   HIGH PORTC
	        BTFSS   PORTC,OPT1
	        GOTO    PLLinit0
	        BTFSC   PORTC,OPT2
	        GOTO    PLLinit0
	; Here if its the 50MHz band
		MOVE24	Freg50,Freg
	 	MOVE24	Rreg50,Rreg
	 	MOVEC24 D'50800',FCF
	 	MOVEC	D'20',PDF
	 	MOVLR	HIGH FCN   
	 	CLRF	FCN
	 	MOVLW	D'10'
	 	MOVWF	NUMFREQ
	 	MOVLW	1
	 	MOVWF	PMUL
	        RETURN
PLLinit0
	        MOVLB   HIGH PORTC
	        BTFSC   PORTC,OPT1
	        GOTO    PLLinit1
	        BTFSS   PORTC,OPT2
	        GOTO    PLLinit1
	 ; Here if its the 53MHz band
	 	MOVE24	Freg53,Freg
	 	MOVE24	Rreg53,Rreg
	 	MOVEC24 D'53100',FCF
	 	MOVEC	D'100',PDF
	 	MOVLR	HIGH FCN   
	 	CLRF	FCN
	 	MOVLW	D'8'
	 	MOVWF	NUMFREQ 
	 	MOVLW	1
	 	MOVWF	PMUL
	        RETURN
PLLinit1       
	        MOVLB   HIGH PORTC
	        BTFSC   PORTC,OPT1
	        GOTO    PLLinit2
	        BTFSC   PORTC,OPT2
	        GOTO    PLLinit2
	 ; Here if its the 72MHz band
		MOVE24	Freg72,Freg
	 	MOVE24	Rreg72,Rreg
	 	MOVEC24 D'72010',FCF
	 	MOVEC	D'10',PDF
	 	MOVLR	HIGH FCN
	 	MOVLW	D'11'   
	 	MOVWF	FCN
	 	MOVLW	D'50'
	 	MOVWF	NUMFREQ
	 	MOVLW	2
	 	MOVWF	PMUL
	        RETURN         
PLLinit2
		RETURN



;****** Hardware INTERRUPT 1 SERVICE HANDLER
;
; This interrupt is used to support the Futaba buddy box operation.
; The ppm signal from a futaba encoder is assumed to be connected to
; the INT1 pin of the CPU.
; This pin is also used for the Tach. The blade detector in the tach
; module is connected to this pin. If the tach is eanbled then this
; routine will count prop revolutions.
;
INT1ISR
   ; Test for for the tach module
		BTFSC	PORTH,TACHENA
		GOTO	NoTach
   ; Here if tach module is present
   	; If timer 0 is enabled then save its value and advance blade counter
	        BTFSS	T0CON,TMR0ON
   		GOTO	TimerOff
		MOVLR	HIGH  BladeTime
		MOVPF	TMR0L,BladeTime
		MOVPF	TMR0H,BladeTime+1	; Save blade time count
		MOVLR	HIGH  BladeDet
		INCF	BladeDet		; Advance blade detector count
		BTFSC	ALUSTA,Z
		INCF	BladeDet+1
		BCF	INTCON3,INT1IF
		RETURN
   	; If timer 0 is disabled and blade counter is 0 then enable counter
TimerOff   	
		MOVLR	HIGH  BladeDet
		MOVFP	BladeDet,WREG
		IORWF	BladeDet+1,W
		BTFSS	ALUSTA,Z
		BCF	INTCON3,INT1IF
		RETURN   			; If blade count is non zero, exit
   		; Enable counter
	        BSF	T0CON,TMR0ON
		BCF	INTCON3,INT1IF
		RETURN	
   ; Here if no tach module has been detected
NoTach
	; Toggle the edge trigger and read status
	        BTG	INTCON2,INTEDG1
	; Test the SHIFT value 
		MOVLR	HIGH SHIFT
		BTFSC	SHIFT,0
		GOTO	ACESHIFT
	; Here for normal shift 
	        BTFSS	INTCON2,INTEDG1
	        BCF	PORTF,MOD,A
	        BTFSC	INTCON2,INTEDG1
	        BSF	PORTF,MOD,A
	        GOTO	INT1ISR_EXIT
ACESHIFT                       
	; Here for ACE shift
	        BTFSS	INTCON2,INTEDG1
	        BSF	PORTF,MOD,A
	        BTFSC	INTCON2,INTEDG1
	        BCF	PORTF,MOD,A
	; Exit
INT1ISR_EXIT    
		BCF	INTCON3,INT1IF
                RETURN



;
; Delay subroutine. Delay = 2uS * WREG value
;
Delay2uS
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		DECFSZ	WREG
		GOTO	Delay2uS
		RETURN

;
; Delay subroutine. Delay = 1mS * Areg value
;
Delay1mS
		MOVWF	Areg
Delay1mS0
		MOVLW	D'250'
		CALL	Delay2uS
		MOVLW	D'250'
		CALL	Delay2uS
		DECFSZ	Areg
		GOTO	Delay1mS0
		RETURN

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; Serial prom routines
;
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; This function will format the Sprom selected by SelSprom.
; The default data is used for this format opertion. It is 
; assumed that the on board sprom is formated if you are
; atempting to format the sec device.
FormatSprom
		MOVLW	LINE1
		CALL    LCDsendCMD
	; display the accept message
		MOVLR	HIGH SelSprom
		BTFSS	SelSprom,CFGMEM1
		GOTO	FS01
		; Here if its primary Sprom, Display format message
		PrintMess MES17
		GOTO	FS02
FS01
		; Here if its secondary Sprom
		PrintMess MES18
FS02
	; Make sure the pilot is ok with this!
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES7
		CALLF	YesNo
		BTFSS	ALUSTA,C
		GOTO	FSexit
	; Display the formating message
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES19
	; Here if its OK to format, Load the default parameters
		CALLF	LoadDefaults
		CALL	SaveGeneral
		; Now define the starting aircraft number
		MOVLR	HIGH SelSprom
		BTFSS	SelSprom,CFGMEM2
		GOTO	FS03a
		; Set start at 9, here for second SPROM
		MOVLR	HIGH Name
		MOVLW	39
		MOVWF	Name+7
		; Set Aircraft number to 9
		MOVLR	HIGH Aircraft
		MOVLW	9
		MOVWF	Aircraft
FS03a
	; Now program all 8 aircraft setups
		MOVLR	HIGH Dtemp
		MOVLW	8
		MOVWF	Dtemp
FS03
		CALL	SaveAircraft
		MOVLR	HIGH Aircraft
		INCF	Aircraft	; Next Aircraft
		; Now advance the generic aircraft name's, "MODEL XX"
		MOVLR	HIGH Name
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
		MOVLR	HIGH Dtemp
		DECFSZ	Dtemp
		GOTO	FS03
	; Here when we are finished, Reload the setup information
		; Set SelSprom to the onboard device
FSexit
		MOVLR	HIGH SelSprom
		CLRF	SelSprom
		BSF	SelSprom,CFGMEM1
		CALL	LoadGeneral
		CALL	LoadAircraft
		RETURN

; This function will copy the contents of one Sprom to the next.
; SelSprom should have the source Sprom select bit set. It is 
; assumed that the on board sprom is formated.
CopySprom
	; Ask the pilot if he is sure
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES7
		CALLF	YesNo
		BTFSS	ALUSTA,C
		GOTO	CSexit
	; Display the copying message...
		MOVLW	LINE2
		CALL    LCDsendCMD
		PrintMess MES20
	; Load the General data
		CALL	LoadGeneral
		MOVLR	HIGH SelSprom
		BTG	SelSprom,CFGMEM1
		BTG	SelSprom,CFGMEM2
	; Save the general data
		CALL	SaveGeneral
		MOVLR	HIGH SelSprom
		BTG	SelSprom,CFGMEM1
		BTG	SelSprom,CFGMEM2
	; Use the following temp reg:
	;   Ctemp = source aircraft number
	;   Dtemp = dest aircraft number
	;   Etemp = loop counter
		MOVLR	HIGH Etemp
		MOVLW	8
		MOVWF	Etemp
		MOVLW	1
		MOVWF	Ftemp
		MOVLW	9
		MOVWF	Dtemp
		; If we are coping Sec to Pri then reverse
		; the source and dest regesters
		MOVLR	HIGH SelSprom
		BTFSS	SelSprom,CFGMEM2
		GOTO	CS01
		; Here if its Sec to Pri
		MOVLR	HIGH Etemp
		MOVLW	9
		MOVWF	Ftemp
		MOVLW	1
		MOVWF	Dtemp
CS01
	; The copy loop...
		MOVLR	HIGH Etemp
		MOVFP	Ftemp,WREG
		MOVLR	HIGH Aircraft
		MOVWF	Aircraft
		CALL	LoadAircraft
		MOVLR	HIGH Dtemp
		MOVFP	Dtemp,WREG
		MOVLR	HIGH Aircraft
		MOVWF	Aircraft
		CALL	SaveAircraft
		; Test if we are finished
		MOVLR	HIGH Etemp
		INCF	Ftemp
		INCF	Dtemp
		DECFSZ	Etemp
		GOTO	CS01
	; Reload parameters and exit
CSexit
		MOVLR	HIGH SelSprom
		CLRF	SelSprom
		BSF	SelSprom,CFGMEM1
		CALL	LoadGeneral
		CALL	LoadAircraft
		RETURN

; This routine sets the port direction bits and defines the initial states.
SpromInit
	; Make on board SPROM the default 
		MOVLR	HIGH EnaSecSprom
		CLRF	EnaSecSprom
		MOVLR	HIGH SelSprom
		CLRF	SelSprom
		BSF	SelSprom,CFGMEM1
	; Clock and data out lines
  		MOVLB	HIGH DDRB
		BCF	DDRB,CLK
		BCF	DDRB,SDObit
		BCF	PORTB,CLK
		BCF	PORTB,SDObit
		MOVLB	HIGH PORTC
		BSF	PORTC,SDIbit
	; Chip select lines
		MOVLB	HIGH DDRG
		BCF	DDRG,CFGMEM1
		BCF	PORTG,CFGMEM1
		
		MOVLB	HIGH DDRC
		BCF	DDRC,CFGMEM2
		BCF	PORTC,CFGMEM2 
	; Look for ther presents of the second SPROM
		MOVLW	2
		MOVWF	Breg
		MOVLW	HIGH BXreg
		MOVWF	Areg
		MOVLW	LOW BXreg
		MOVWF	FSR1
		MOVLR	HIGH AXreg
		MOVLW	LOW (Signature - 220)
		MOVWF	AXreg
		MOVLW	HIGH (Signature - 220)
		MOVWF	AXreg+1  
		MOVLR	HIGH SelSprom 
		BCF	SelSprom,CFGMEM1 
		BSF	SelSprom,CFGMEM2
		CALL	SpromRead
		MOVLR	HIGH SelSprom 
		BCF	SelSprom,CFGMEM2 
		BSF	SelSprom,CFGMEM1
		; If BXreg = E7A5 then enable the second sprom 
		MOVLR	HIGH BXreg
		MOVLW	0A5
		CPFSEQ	BXreg
		RETURN
		MOVLW	0E7
		CPFSEQ	BXreg+1
		RETURN
		MOVLR	HIGH EnaSecSprom 
		SETF	EnaSecSprom
		RETURN
		
; This function will read data from the serial prom and save it
; at the address in indirect register FSR1. FSR1 must be setup
; prior to this call. The following registers are assumed defined
; when this call is made:
;
;       SelSprom = Chip Select Bit set for the device you wish to select.
;	AXreg = starting address in Sprom
;	Areg  = Bank for destination
;	Breg  = Number of bytes to read
;
SpromRead
	; Add the opcode to the address
		MOVLR	HIGH AXreg
		MOVLW	07
		ANDWF	AXreg+1,F
		MOVLW	30
		IORWF	AXreg+1,F
	; Output the data, 14 bits, MSB first
		; Select the device
		MOVLR	HIGH SelSprom
		MOVFP	SelSprom,WREG
		BTFSC	WREG,CFGMEM1,A
		BTG	PORTG,CFGMEM1,A
		BTFSC	WREG,CFGMEM2,A
		BTG	PORTC,CFGMEM2,A
		; end of select
		MOVLR	HIGH AXreg
		MOVLW	D'14'
		MOVWF	Atemp		; Loop counter
SR1
		BCF	PORTB,SDObit,A
		BTFSC	AXreg+1,5
		BSF	PORTB,SDObit,A
		BSF	PORTC,CLK,A
		BCF	PORTC,CLK,A
		RLCF	AXreg
		RLCF	AXreg+1
		DECFSZ	Atemp
		GOTO	SR1
	; Now we are ready to read the data
SR2a
		MOVLW	8
		MOVWF	Atemp
		MOVLW	0
SR2
		BSF	PORTC,CLK,A
		NOP
		NOP
		NOP
		NOP
		BTFSC	PORTC,SDIbit,A
		BSF	WREG,7
		RLNCF	WREG
		BCF	PORTC,CLK,A
		DECFSZ	Atemp
		GOTO	SR2
	; Save the byte in the indirect reg...
		MOVFP	Areg,BSR
		MOVWF	POSTINC1
		MOVLR	HIGH Atemp
		DECFSZ	Breg
		GOTO	SR2a
	; Here with all of the data read!		
	; reset the auto increment
		BCF	PORTG,CFGMEM1,A	
		BCF	PORTC,CFGMEM2,A
		MOVLR	0
		RETURN

; This function enables the erase and write commands
; This function uses:
;			Atemp
;			WREG
;       SelSprom = Chip Select Bit set for the device you wish to select.
SpromEWEN
	; Output the data, 14 bits, MSB first
		; Select the device
		MOVLR	HIGH SelSprom
		MOVFP	SelSprom,WREG
		BTFSC	WREG,CFGMEM1,A
		BTG	PORTG,CFGMEM1,A
		BTFSC	WREG,CFGMEM2,A
		BTG	PORTC,CFGMEM2,A
		; end of select
		MOVLR	HIGH Atemp
		MOVLW	D'14'
		MOVWF	Atemp		; Loop counter
		MOVLW	98		; Opcode
EWEN1
		BCF	PORTB,SDObit,A
		BTFSC	WREG,7,A
		BSF	PORTB,SDObit,A
		BSF	PORTC,CLK,A
		BCF	PORTC,CLK,A
		RLCF	WREG,A
		DECFSZ	Atemp
		GOTO	EWEN1
	; All done!
		BCF	PORTG,CFGMEM1,A	
		BCF	PORTC,CFGMEM2,A
		MOVLR	0
		RETURN

; This function disables the erase and write commands
; This function uses:
;			Atemp
;			WREG
;       SelSprom = Chip Select Bit set for the device you wish to select.
SpromEWNDS	; Output the data, 14 bits, MSB first
		; Select the device
		MOVLR	HIGH SelSprom
		MOVFP	SelSprom,WREG
		BTFSC	WREG,CFGMEM1,A
		BTG	PORTG,CFGMEM1,A
		BTFSC	WREG,CFGMEM2,A
		BTG	PORTC,CFGMEM2,A
		; end of select
		MOVLR	HIGH Atemp
		MOVLW	D'14'
		MOVWF	Atemp		; Loop counter
		MOVLW	80		; Opcode
EWNDS1
		BCF	PORTB,SDObit,A
		BTFSC	WREG,7
		BSF	PORTB,SDObit,A
		BSF	PORTC,CLK,A
		BCF	PORTC,CLK,A
		RLCF	WREG,A
		DECFSZ	Atemp
		GOTO	EWNDS1
	; All done!
		BCF	PORTG,CFGMEM1,A	
		BCF	PORTC,CFGMEM2,A
		MOVLR	0
		RETURN

; This function will erase one byte in the sprom. Reg AXreg 
; contains the address to erase.
;  AXreg is preserved
; This function uses:
;			Atemp
;			WREG
;       SelSprom = Chip Select Bit set for the device you wish to select.
SpromErase
	; Add the opcode to the address
		MOVLR	HIGH AXreg
		MOVLW	07
		ANDWF	AXreg+1,1
		MOVLW	38
		IORWF	AXreg+1,1
	; Output the data, 14 bits, MSB first
		; Select the device
		MOVLR	HIGH SelSprom
		MOVFP	SelSprom,WREG
		BTFSC	WREG,CFGMEM1,A
		BTG	PORTG,CFGMEM1,A
		BTFSC	WREG,CFGMEM2,A
		BTG	PORTC,CFGMEM2,A
		; end of select
		MOVLW	D'14'
		MOVWF	Atemp		; Loop counter
SE1
		BCF	PORTB,SDObit,A
		BTFSC	AXreg+1,5
		BSF	PORTB,SDObit,A
		BSF	PORTC,CLK,A
		BCF	PORTC,CLK,A
		RLCF	AXreg
		RLCF	AXreg+1
		DECFSZ	Atemp
		GOTO	SE1
	; Now we are ready to test the status
	; Wait for SDI to go high
		; Pulse the CS line
		MOVLR	HIGH SelSprom
		MOVFP	SelSprom,WREG
		BCF	PORTG,CFGMEM1,A	
		BCF	PORTC,CFGMEM2,A
		BTFSC	WREG,CFGMEM1,A
		BSF	PORTG,CFGMEM1,A
		BTFSC	WREG,CFGMEM2,A
		BSF	PORTC,CFGMEM2,A
		; end of CS pulse
SE2
		BTFSS	PORTC,SDIbit,A
		GOTO	SE2
	; Deselect the device
		BCF	PORTG,CFGMEM1,A	
		BCF	PORTC,CFGMEM2,A
		MOVLR	0
		RETURN

;
; This function will write data to the serial prom from
; the address in indirect register FSR1. FSR1 must be setup
; prior to this call. The following registers are assumed defined
; when this call is made:
;
;       SelSprom = Chip Select Bit set for the device you wish to select.
;	AXreg = starting address in Sprom
;	Areg  = Bank for source
;	Breg  = Number of bytes to send
;
; This function uses:
;			Btemp
;			Ctemp
;			WREG
;
SpromWrite
		MOVLR	HIGH Btemp
		MOVPF	Areg,Btemp
		MOVPF	Breg,Ctemp
	; Enable the write operation
		CALL	SpromEWEN
	; Get the byte we are going to write
SPW
		MOVE	AXreg,BXreg
		MOVLR	HIGH Btemp
		MOVFP	Btemp,WREG
		MOVWF	BSR
		MOVPF	POSTINC1,WREG
		MOVWF	Areg
	; Write the byte
		CALL	SpromWriteByte
	; Advance the address
		MOVE	BXreg,AXreg
		MOVLR	HIGH AXreg
		INFSNZ	AXreg
		INCF	AXreg+1
	; Loop till all bytes are sent
		MOVLR	HIGH Ctemp
		DECFSZ	Ctemp
		GOTO	SPW
	; Disable writes
		CALL	SpromEWNDS
	; Make sure we deselect them both!
		BCF	PORTG,CFGMEM1,A	
		BCF	PORTC,CFGMEM2,A
		MOVLR	0
		RETURN

; This function writes one byte to the serial prom. AXreg points to the
; location to write and Areg contains the data to program.
; Uses Areg and Atemp
;       SelSprom = Chip Select Bit set for the device you wish to select.
SpromWriteByte
	; Add the opcode to the address
		MOVLR	HIGH AXreg
		MOVLW	07
		ANDWF	AXreg+1,1
		MOVLW	28
		IORWF	AXreg+1,1
	; Output the data, 14 bits, MSB first
		; Select the device
		MOVLR	HIGH SelSprom
		MOVFP	SelSprom,WREG
		BTFSC	WREG,CFGMEM1
		BTG	PORTG,CFGMEM1
		BTFSC	WREG,CFGMEM2
		BTG	PORTC,CFGMEM2
		; end of select
		MOVLR	HIGH AXreg
		MOVLW	D'14'
		MOVWF	Atemp		; Loop counter
SW1
		BCF	PORTB,SDObit,A
		BTFSC	AXreg+1,5
		BSF	PORTB,SDObit,A
		BSF	PORTC,CLK,A
		BCF	PORTC,CLK,A
		RLCF	AXreg
		RLCF	AXreg+1
		DECFSZ	Atemp
		GOTO	SW1
	; Send the data byte in the next 8 clocks
		MOVLW	8
		MOVWF	Atemp
SW2a
		BCF	PORTB,SDObit,A
		BTFSC	Areg,7
		BSF	PORTB,SDObit,A
		BSF	PORTC,CLK,A
		BCF	PORTC,CLK,A
		RLNCF	Areg
		DECFSZ	Atemp
		GOTO	SW2a
	; Now we are ready to test the status
	; Wait for SDI to go high
		; Pulse the CS line
		MOVLR	HIGH SelSprom
		MOVFP	SelSprom,WREG
		BCF	PORTG,CFGMEM1,A	
		BCF	PORTC,CFGMEM2,A
		BTFSC	WREG,CFGMEM1,A
		BSF	PORTG,CFGMEM1,A
		BTFSC	WREG,CFGMEM2,A
		BSF	PORTC,CFGMEM2,A
		; end of CS pulse
SW2
		BTFSS	PORTC,SDIbit,A
		GOTO	SW2
	; Deselect the device
		BCF	PORTG,CFGMEM1	
		BCF	PORTC,CFGMEM2
		MOVLR	0
		RETURN

; Listed below are include statements for the two LCD display types 
; that are supported. Only include one of these files.
ifdef		LCD52display
	Include	<lcd52.asm>
endif
ifdef           SED1230display
	Include	<sed1230.asm>
endif
ifdef           ECMA1010display
	Include	<ECMA1010.asm>
endif


LCDsendAX
		MOVLW	LINE1
		CALL	LCDsendCMD
		MOVLR	HIGH AXreg
		MOVFP	AXreg,TBLPTRL
		MOVFP	AXreg+1,TBLPTRH
		CLRF	WREG
		MOVWF	TBLPTRU
		CALL    LCDsendMess
		RETURN
LCDsendAXLine2
		MOVLW	LINE2
		CALL	LCDsendCMD
		MOVLR	HIGH AXreg
		MOVFP	AXreg,TBLPTRL
		MOVFP	AXreg+1,TBLPTRH
		CLRF	WREG
		MOVWF	TBLPTRU
		CALL    LCDsendMess
		RETURN
LCDsendDXLine2
		MOVLW	LINE2
		CALL	LCDsendCMD
		MOVLR	HIGH DXreg
		MOVFP	DXreg,TBLPTRL
		MOVFP	DXreg+1,TBLPTRH
		CLRF	WREG
		MOVWF	TBLPTRU
		CALL    LCDsendMess
		RETURN

LCDsendMess
ifdef   ECMA1010display
		MOVLW	0C
else
		MOVLW	10
endif
		MOVWF	Areg
NEXT
		TBLRD*+
		MOVFF	TABLAT,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		GOTO	DONE1
		CALL	LCDsendData
		DCFSNZ	Areg
		GOTO	DONE1
		TBLRD*+
		MOVFF	TABLAT,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		GOTO	DONE1
		CALL	LCDsendData
		DECFSZ	Areg
		GOTO	NEXT
DONE1	
		RETURN
LCDbinary
		MOVWF	Areg
		MOVLW	D'8'
		MOVWF	Breg
LCDbinary0
		MOVLW	30
		BTFSC	Areg,7
		MOVLW	31
		CALL	LCDsendData
		RLCF	Areg
		DECFSZ	Breg
		GOTO	LCDbinary0
		RETURN

LCDhex
		MOVWF	Areg
		MOVLW	3A
		MOVWF	Breg
	; MS dibble
		MOVPF	Areg,WREG
		ANDLW	0F0
		RRNCF	WREG
		RRNCF	WREG
		RRNCF	WREG
		RRNCF	WREG
		IORLW	030
		CPFSGT	Breg
		ADDLW	7
		CALL	LCDsendData
	; LS dibble
		MOVPF	Areg,WREG
		ANDLW	0F
		IORLW	030
		CPFSGT	Breg
		ADDLW	7
		CALL	LCDsendData
		MOVPF	Areg,WREG
		RETURN

; This function prints the unsigned integer that is in 
; CEXreg to the LCD at the current position
LCDint
		CALL	Int2Str
		MOVFP	Buffer,WREG
		CALL	LCDsendData
LCDintA
		MOVFP	Buffer+1,WREG
		CALL	LCDsendData
LCDintB
		MOVFP	Buffer+2,WREG
		CALL	LCDsendData
LCDintC
		MOVFP	Buffer+3,WREG
		CALL	LCDsendData
LCDintD
		MOVFP	Buffer+4,WREG
		CALL	LCDsendData
		RETURN
LCDint4
		CALL	Int2Str
		GOTO	LCDintA
LCDint3
		CALL	Int2Str
		GOTO	LCDintB
LCDint2
		CALL	Int2Str
		GOTO	LCDintC
LCDint1
		CALL	Int2Str
		GOTO	LCDintD

LCDintZS
		CALL	Int2Str
		CALL	RemoveLeadingZeros
		MOVFP	Buffer,WREG
		CALL	LCDsendData
		MOVFP	Buffer+1,WREG
		CALL	LCDsendData
		MOVFP	Buffer+2,WREG
		CALL	LCDsendData
		MOVFP	Buffer+3,WREG
		CALL	LCDsendData
		MOVFP	Buffer+4,WREG
		CALL	LCDsendData
		RETURN

; This function removes leading zeros from the ascii string in Buffer.
RemoveLeadingZeros
		MOVLR	HIGH Buffer
		MOVLW	'0'
		CPFSEQ	Buffer
		RETURN
		MOVLW	' '
		MOVWF	Buffer

		MOVLW	'0'
		CPFSEQ	Buffer+1
		RETURN
		MOVLW	' '
		MOVWF	Buffer+1

		MOVLW	'0'
		CPFSEQ	Buffer+2
		RETURN
		MOVLW	' '
		MOVWF	Buffer+2

		MOVLW	'0'
		CPFSEQ	Buffer+3
		RETURN
		MOVLW	' '
		MOVWF	Buffer+3
		RETURN

; This function converts an integer into an ascii string.
; CEXreg contains the integer and the 5 byte
; string is placed in buffer
Int2Str
	; 10000 digit
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLR	HIGH CEXreg
		MOVLW	LOW D'10000'
		MOVPF	WREG,DEXreg
		MOVLW	HIGH D'10000'
		MOVPF	WREG,DEXreg+1
		CALL	Divide2416
		MOVLW	30
		IORWF	CEXreg,0
		MOVWF	Buffer
		MOVE	EEXreg,CEXreg
		MOVE	EEXreg+2,CEXreg+2
	; 1000 digit
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLW	LOW D'1000'
		MOVPF	WREG,DEXreg
		MOVLW	HIGH D'1000'
		MOVPF	WREG,DEXreg+1
		CALL	Divide2416
		MOVLW	30
		IORWF	CEXreg,0
		MOVWF	Buffer+1
		MOVE	EEXreg,CEXreg
		MOVE	EEXreg+2,CEXreg+2
	; 100 digit
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLW	LOW D'100'
		MOVPF	WREG,DEXreg
		MOVLW	HIGH D'100'
		MOVPF	WREG,DEXreg+1
		CALL	Divide2416
		MOVLW	30
		IORWF	CEXreg,0
		MOVWF	Buffer+2
		MOVE	EEXreg,CEXreg
		MOVE	EEXreg+2,CEXreg+2
	; 10 digit
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVLW	LOW D'10'
		MOVPF	WREG,DEXreg
		MOVLW	HIGH D'10'
		MOVPF	WREG,DEXreg+1
		CALL	Divide2416
		MOVLW	30
		IORWF	CEXreg,0
		MOVWF	Buffer+3
	; The 1's digit is in the remainder's lsb
		MOVLW	30
		IORWF	EEXreg,0
		MOVWF	Buffer+4
		RETURN

INCLUDE		<comms.asm>
INCLUDE		<FMS.asm>
INCLUDE		<Math.asm>


; This function is called in the run mode. When the Auto Trim and and Preset buttons
; are held down the throttle low point adjustment mode is entered. In this mode the
; elevator stick will adjust the throttle low value as long as the buttons are held.
; This function is called after the stick positions are read and normalized.
; Returns:
;	Z flag clear if not selected
;	Z flag set if mode is selected
ThrottleTrim
	; Test the buttons
		Pressed PORTD,PRESET
		BTFSC	ALUSTA,C
		GOTO	TTexit
		Pressed PORTE,AUTOT
		BTFSC	ALUSTA,C
		GOTO	TTexit
	; Here if the two buttons are pressed
		; If the throttle trim flag is not set then init the variables needed
		; and set the TTflag
		MOVLR	HIGH TTflag
		TSTFSZ	TTflag
		GOTO	TTinited
	; Here to set the flag and init the variables
		MOVLR	HIGH TTflag
		SETF	TTflag		
		; Convert throttle gains to uS
		MOVLR	HIGH TBH
		MOVE	TMH,AXreg
		MOVEC	D'1000',BXreg
		CALL	Mult1616
		MOVE	CEXreg+1,TTMH
		MOVLR	HIGH TBH
		MOVFP	TBH,WREG
		MOVLR	HIGH TTMH
		ADDWF	TTMH,F
		MOVLR	HIGH TBH
		MOVFP	TBH+1,WREG
		MOVLR	HIGH TTMH
		ADDWFC	TTMH+1,F
		MOVE	TBH,TTBH
TTinited
		; See if the Elevator stick indicates an adjustment	
		CALLF	Elevator	; C set for Up, Z set for Down
		BTFSC	ALUSTA,C
		GOTO	TTup
		BTFSS	ALUSTA,Z
		GOTO	TTgo
		; Here to decrease the low throttle position
		MOVLR	HIGH TTBH
		DECF	TTBH
		BTFSS	ALUSTA,C
		DECF	TTBH+1
		DECF	TTBH
		BTFSS	ALUSTA,C
		DECF	TTBH+1
		GOTO	TTgo		
		; Here to increase the low throttle position
TTup
		MOVLR	HIGH TTBH
		INCF	TTBH
		BTFSC	ALUSTA,Z
		INCF	TTBH+1
		INCF	TTBH
		BTFSC	ALUSTA,Z
		INCF	TTBH+1
		; Convert the throttle positions to gains
TTgo
		MOVE	TTMH,AXreg
		MOVLR	HIGH TTMH
		MOVFP	TTBH,WREG
		MOVLR	HIGH AXreg
		SUBWF	AXreg,F
		MOVLR	HIGH TTBH
		MOVFP	TTBH+1,WREG
		MOVLR	HIGH AXreg
		SUBWFB	AXreg+1,F
		MOVEC	D'256',BXreg
		CALL	Mult1616
		MOVEC	D'1000',DEXreg
		CALL	Divide2416
		MOVE	CEXreg,TMH
		MOVE	TTBH,TBH
		; Apply the trims and exit with the Z flag set
		CALL	ApplyTrims
		BSF	ALUSTA,Z
		RETURN
TTexit
	; Clear the Z flag and exit
		; If TTflag is set, save the throttle gains and clear the flag
		MOVLR	HIGH TTflag
		TSTFSZ	TTflag
		GOTO	TTsave
		; here if flag was clear so just exit now
		BCF	ALUSTA,Z
		RETURN
TTsave:
		; here to clear flag and save
		CLRF	TTflag
		MOVLW	4
		MOVPF	WREG,Breg	; Number of bytes to write
		MOVLW	30		; Bank 3 for data source
		MOVPF	WREG,Areg
		MOVLW	LOW TMH
		MOVPF	WREG,FSR1	; RAM address of data to write
		CALL	SaveSPROM
		; exit 
		BCF	ALUSTA,Z
		RETURN

; This function uses the generic parameter locations to calculate
; the joy stick position.
CenterNormalize
	; Is pos > center ?
		MOVLR	HIGH AXreg
		; AXreg = Pos - Ct
		MOVFP	Pos,WREG
		MOVPF	WREG,AXreg
		MOVFP	Pos+1,WREG
		MOVPF	WREG,AXreg+1
		MOVFP	Ct,WREG
		SUBWF	AXreg
		MOVFP	Ct+1,WREG
		SUBWFB	AXreg+1
		; If carry is set then Pos was less than Ct
		BTFSS	ALUSTA,C
		GOTO	CN1
	; If here then Pos >= Ct
		MOVFP	Gh,WREG
		MOVPF	WREG,BXreg
		MOVFP	Gh+1,WREG
		MOVPF	WREG,BXreg+1
		CALL	Mult1616
		; Get the ans divided by 256
		MOVFP	CEXreg+1,WREG
		MOVPF	WREG,Npos
		MOVFP	CEXreg+2,WREG
		MOVPF	WREG,Npos+1
		RETURN
	; If here then Pos < Ct
CN1
		MOVFP	Gl,WREG
		MOVPF	WREG,BXreg
		MOVFP	Gl+1,WREG
		MOVPF	WREG,BXreg+1
		CALL	Mult1616
		; Get the ans divided by 256
		MOVFP	CEXreg+1,WREG
		MOVPF	WREG,Npos
		MOVFP	CEXreg+2,WREG
		MOVPF	WREG,Npos+1
		RETURN

; This function is used to calculate the normalized position for a non
; centering input channel.
; 
; Inputs:
;	Pos = 16 bit variable containing the ADC counts
;	Ct  = 16 bit variable containing the offset
; 	Gh  = 16 bit variable containing the gain
; Outputs:
;	Npos = 16 bit variable containing the normailized result.
;	Npos = (Pos - Ct) * Gt / 256
NonCenterNormalize
	; AXreg = Pos - Ct
		MOVE	Pos,AXreg
		MOVFP	Ct,WREG
		SUBWF	AXreg,F
		MOVFP	Ct+1,WREG
		SUBWFB	AXreg+1,F
	; CEXreg = AXreg * Gh
		MOVE	Gh,BXreg
		CALL	Mult1616	; CEXreg = AXreg * BXreg
	; Npos = CEXreg/256
		MOVFP	CEXreg+1,WREG
		MOVPF	WREG,Npos
		MOVFP	CEXreg+2,WREG
		MOVPF	WREG,Npos+1
		RETURN
;
; This function will convert the raw ADC cound data into normalized
; joy stick position information. The centering channels and all trim
; channels are normalized to -1000 to +1000. The non centerning channels
; are normalized to 0 to 1000.
; The joy stick calibration parameters are used for this calculation.
;
; There are two version of this routine, one the the MicroPro upgrade
; and one for the PROLINE upgrade.
;
CalculateNormalizedPositions
	; Aielron
		MOVLW	4
		CALL	ADCread
		MOVLW	4
		CALL	OverSample
		; Move all parameters to normalized space
		MOVE	AHG,Gh
		MOVE	ACT,Ct
		MOVE	ALG,Gl
		; Normalize it!
		CALL	CenterNormalize
		MOVE	Npos,ATpos
		MOVE	Npos,Apos
	; Elevador
		MOVLW	5
		CALL	ADCread
		MOVLW	5
		CALL	OverSample
		; Move all parameters to normalized space
		MOVE	EHG,Gh
		MOVE	ECT,Ct
		MOVE	ELG,Gl
		; Normalize it!
		CALL	CenterNormalize
		MOVE	Npos,ETpos
		MOVE	Npos,Epos
	; Rudder
		MOVLW	6
		CALL	ADCread
		MOVLW	6
		CALL	OverSample
		; Move all parameters to normalized space
		MOVE	RHG,Gh
		MOVE	RCT,Ct
		MOVE	RLG,Gl
		; Normalize it!
		CALL	CenterNormalize
		MOVE	Npos,RTpos
		MOVE	Npos,Rpos
	; Throttle
		MOVLW	7
		CALL	ADCread
		MOVLW	7
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	THG,Gh
		MOVE	TCT,Ct
		; Normalize it!
		CALL	NonCenterNormalize
		MOVE	Npos,TTpos
		MOVE	Npos,Tpos
	; The PROLINE trims use the internal 5 volt ref and the battery for the pots,
	; so we need to reference them to the battery.
		MOVLW	0
		CALL	ADCread
		; Save data in Vbat
		MOVLR	HIGH Vbat
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,WREG
		MOVPF	WREG,Vbat
		MOVPF	ADRESH,WREG
		MOVPF	WREG,Vbat+1
ifdef		PROLINE
	; Aielron trim
		MOVLW	8
		CALL	ADCread
		; Save data in AXreg
		MOVLR	HIGH AXreg
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,WREG
		MOVPF	WREG,AXreg
		MOVPF	ADRESH,WREG
		MOVPF	WREG,AXreg+1
		; Multiply by the Vbats nominal value
		CLRF	BXreg
		MOVLW	2
		MOVPF	WREG,BXreg+1
		CALL	Mult1616	; Result in CEXreg
		; Now divide by the actual Vbat value to correct for Vbat changes
		MOVLR	HIGH DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVE	Vbat,DEXreg
		CALL	Divide2416
		; Now normalize
		MOVE	AtrimCT,Ct
		MOVE	AtrimHG,Gh	
		MOVE	CEXreg,Pos
		CALL	NonCenterNormalize
		MOVE	Npos,Atrim
	; Elevator trim
		MOVLW	9
		CALL	ADCread
		; Save data in AXreg
		MOVLR	HIGH AXreg
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,WREG
		MOVPF	WREG,AXreg
		MOVPF	ADRESH,WREG
		MOVPF	WREG,AXreg+1
		; Multiply by the Vbats nominal value
		CLRF	BXreg
		MOVLW	2
		MOVPF	WREG,BXreg+1
		CALL	Mult1616	; Result in CEXreg
		; Now divide by the actual Vbat value to correct for Vbat changes
		MOVLR	HIGH DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVE	Vbat,DEXreg
		CALL	Divide2416
		; Now normalize
		MOVE	EtrimCT,Ct
		MOVE	EtrimHG,Gh	
		MOVE	CEXreg,Pos
		CALL	NonCenterNormalize
		MOVE	Npos,Etrim
	; Rudder trim
		MOVLW	0A
		CALL	ADCread
		; Save data in AXreg
		MOVLR	HIGH AXreg
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,WREG
		MOVPF	WREG,AXreg
		MOVPF	ADRESH,WREG
		MOVPF	WREG,AXreg+1
		; Multiply by the Vbats nominal value
		CLRF	BXreg
		MOVLW	2
		MOVPF	WREG,BXreg+1
		CALL	Mult1616	; Result in CEXreg
		; Now divide by the actual Vbat value to correct for Vbat changes
		MOVLR	HIGH DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVE	Vbat,DEXreg
		CALL	Divide2416
		; Now normalize
		MOVE	RtrimCT,Ct
		MOVE	RtrimHG,Gh	
		MOVE	CEXreg,Pos
		CALL	NonCenterNormalize
		MOVE	Npos,Rtrim
	; Throttle trim
		MOVLW	0B
		CALL	ADCread
		; Save data in AXreg
		MOVLR	HIGH AXreg
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,WREG
		MOVPF	WREG,AXreg
		MOVPF	ADRESH,WREG
		MOVPF	WREG,AXreg+1
		; Multiply by the Vbats nominal value
		CLRF	BXreg
		MOVLW	2
		MOVPF	WREG,BXreg+1
		CALL	Mult1616	; Result in CEXreg
		; Now divide by the actual Vbat value to correct for Vbat changes
		MOVLR	HIGH DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVE	Vbat,DEXreg
		CALL	Divide2416
		; Now normalize
		MOVE	TtrimCT,Ct
		MOVE	TtrimHG,Gh	
		MOVE	CEXreg,Pos
		CALL	NonCenterNormalize
		MOVE	Npos,Ttrim
else
	; This section contains the normalization code for the trims found
	; on a MicroPro 8000

	; Aielron trim
		MOVLW	8
		CALL	ADCread
		; Now normalize
		MOVE	AtrimCT,Ct
		MOVE	AtrimHG,Gh	
		CALL	NonCenterNormalize
		MOVE	Npos,Atrim
	; Elevator trim
		MOVLW	9
		CALL	ADCread
		; Now normalize
		MOVE	EtrimCT,Ct
		MOVE	EtrimHG,Gh	
		CALL	NonCenterNormalize
		MOVE	Npos,Etrim
	; Rudder trim
		MOVLW	0A
		CALL	ADCread
		; Now normalize
		MOVE	RtrimCT,Ct
		MOVE	RtrimHG,Gh	
		CALL	NonCenterNormalize
		MOVE	Npos,Rtrim
	; Throttle trim
		MOVLW	0B
		CALL	ADCread
		; Now normalize
		MOVE	TtrimCT,Ct
		MOVE	TtrimHG,Gh	
		CALL	NonCenterNormalize
		MOVE	Npos,Ttrim
endif
	; CH5, 0 or 1000
		MOVLR	HIGH SWCH5
		MOVFP	SWCH5,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CH5_OFF
		MOVLW	HIGH D'1000'
		MOVWF	CH5pos+1
		MOVLW	LOW D'1000'
		MOVWF	CH5pos
		GOTO	CH5_Done
CH5_OFF
		CLRF	CH5pos
		CLRF	CH5pos+1
CH5_Done
	; CH6
		MOVLW	03
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	CH6HG,Gh
		MOVE	CH6CT,Ct
		; Normalize it!
		CALL	NonCenterNormalize
		MOVE	Npos,CH6pos
	; CH7
		MOVLW	02
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	CH7HG,Gh
		MOVE	CH7CT,Ct
		; Normalize it!
		CALL	NonCenterNormalize
		MOVE	Npos,CH7pos
	; CH8, 0, 500, or 1000
		MOVLR	HIGH SWCH8A
		MOVFP	SWCH8A,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CH8_c
		MOVLW	HIGH D'1000'
		MOVWF	CH8pos+1
		MOVLW	LOW D'1000'
		MOVWF	CH8pos
		GOTO	CH8_Done
CH8_c
		MOVLR	HIGH SWCH8C
		MOVFP	SWCH8C,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CH8_b
		CLRF	CH8pos
		CLRF	CH8pos+1
		GOTO	CH8_Done
CH8_b
		MOVLR	HIGH SWCH8B
		MOVFP	SWCH8B,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CH8_Done
		MOVLW	HIGH D'500'
		MOVWF	CH8pos+1
		MOVLW	LOW D'500'
		MOVWF	CH8pos
CH8_Done
		RETURN

;
; This function applies the expo to Aileron, Elevator and Rudder. There are
; two expo values for each channel. A high rate and low rate expo value.
; Below are the two expo functions:
;  High rate function (E = expo percentage)
;   Pos = Pos - (E * Pos/100 - E * Pos * Pos/100000)
;  Low rate function (E = expo percentage, G = low rate percentage)
;   Pos = Pos - (E * Pos/100 - E * Pos * Pos/(1000 * G))
;

; Generic function, assumes:
;	BXreg	=	Expo percentage
;	Breg	=	Channel gain
;	AXreg	=	Pos
; Result returned in AXreg
;
Expo:
	; Sign extend BXreg
		MOVLR	HIGH BXreg
		CLRF	BXreg+1
		BTFSC	BXreg,7
		COMF	BXreg+1
	; Calculate E * Pos/100
		CALL	Mult1616
		MOVEC	D'100',DEXreg
		CALL	Divide2416
	; CEXreg contains E * Pos/100
		MOVE	CEXreg,CXreg	; E * Pos/100 to CXreg
		MOVE	CEXreg,BXreg	; E * Pos/100 to BXreg
		; Because Pos*Pos will always be positive, we must take
		; the complement of Pos if its negative, make sense??
		BTFSS	AXreg+1,7
		GOTO	ExpoPos
		COMF	BXreg
		COMF	BXreg+1
		INCF	BXreg
		BTFSC	ALUSTA,C
		INCF	BXreg+1	
ExpoPos:
		CALL	Mult1616
		MOVEC	D'10',DEXreg
		CALL	Divide2416      ; ans in CEXreg
		MOVFP	Breg,WREG
		MOVPF	WREG,DEXreg
		CLRF	DEXreg+1	
		BTFSC	DEXreg,7
		COMF	DEXreg+1
		CALL	Divide2416      ; ans in CEXreg
	; Now wrap it up... do the additions...
		MOVFP	CXreg,WREG
		SUBWF	AXreg,F
		MOVFP	CXreg+1,WREG
		SUBWFB	AXreg+1,F
		MOVFP	CEXreg,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	AXreg+1,F
	; Done
		RETURN

		
; This function applies the generic expo function to all of the 
; channels, A,E, and R.
ApplyExpo:
	; Aileron expo
		; Test dual rate switch
		MOVLR	HIGH SWAILDR
		MOVFP	SWAILDR,WREG
		CALL	SwitchTest
		MOVE	Apos,AXreg
		BTFSS	ALUSTA,C
		GOTO	AEX1
		; Here if Low rate
		MOVLR	HIGH AEXLOW
		MOVFP	AEXLOW,WREG
		MOVLR	HIGH BXreg
		MOVPF	WREG,BXreg
		MOVLR	HIGH ALR
		MOVFP	ALR,WREG
		MOVPF	WREG,Breg
		GOTO	AEX1a
		; Here if high rate
AEX1:
		MOVLR	HIGH AEXHI
		MOVFP	AEXHI,WREG
		MOVLR	HIGH BXreg
		MOVPF	WREG,BXreg
		MOVLW	D'100'
		MOVPF	WREG,Breg
AEX1a:
		CALL	Expo
		MOVE	AXreg,Apos
	; Elevator expo
		; Test dual rate switch
		MOVLR	HIGH SWELEDR
		MOVFP	SWELEDR,WREG
		CALL	SwitchTest
		MOVE	Epos,AXreg
		BTFSS	ALUSTA,C
		GOTO	EEX1
		; Here if Low rate
		MOVLR	HIGH EEXLOW
		MOVFP	EEXLOW,WREG
		MOVLR	HIGH BXreg
		MOVPF	WREG,BXreg
		MOVLR	HIGH ELR
		MOVFP	ELR,WREG
		MOVPF	WREG,Breg
		GOTO	EEX1a
EEX1:
		; Here if high rate
		MOVLR	HIGH EEXHI
		MOVFP	EEXHI,WREG
		MOVLR	HIGH BXreg
		MOVPF	WREG,BXreg
		MOVLW	D'100'
		MOVPF	WREG,Breg
EEX1a:
		CALL	Expo
		MOVE	AXreg,Epos
	; Rudder expo
		; Test dual rate switch
		MOVLR	HIGH SWRUDDR
		MOVFP	SWRUDDR,WREG
		CALL	SwitchTest
		MOVE	Rpos,AXreg
		BTFSS	ALUSTA,C
		GOTO	REX1
		; Here if Low rate
		MOVLR	HIGH REXLOW
		MOVFP	REXLOW,WREG
		MOVLR	HIGH BXreg
		MOVPF	WREG,BXreg
		MOVLR	HIGH RLR
		MOVFP	RLR,WREG
		MOVPF	WREG,Breg
		GOTO	REX1a
REX1:
		; Here if high rate
		MOVLR	HIGH REXHI
		MOVFP	REXHI,WREG
		MOVLR	HIGH BXreg
		MOVPF	WREG,BXreg
		MOVLW	D'100'
		MOVPF	WREG,Breg
REX1a:
		CALL	Expo
		MOVE	AXreg,Rpos
		RETURN

;
; This function calculates the dual rate servo positions. Here is the math
; Pos = (G * Pos) /100
;
ApplyDualRates
	;
	; Aielron, Lin dual rate, Pos = (Pos * G)/100
	;
		MOVLR	HIGH SWAILDR
		MOVFP	SWAILDR,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	ADR1
		MOVE	Apos,BXreg
		MOVE	ALR,AXreg
		CLRF	AXreg+1
		BTFSC	AXreg,7
		COMF	AXreg+1
		CALL	Mult1616
		MOVEC	D'100',DEXreg
		CALL	Divide2416
		MOVE	CEXreg,Apos
	;
	; Elevador
	;
ADR1
		MOVLR	HIGH SWAILDR
		MOVFP	SWELEDR,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	ADR2
		MOVE	Epos,BXreg
		MOVE	ELR,AXreg
		CLRF	AXreg+1
		BTFSC	AXreg,7
		COMF	AXreg+1
		CALL	Mult1616
		MOVEC	D'100',DEXreg
		CALL	Divide2416
		MOVE	CEXreg,Epos
	;
	; Rudder
	;
ADR2
		MOVLR	HIGH SWAILDR
		MOVFP	SWRUDDR,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	ADR3
		MOVE	Rpos,BXreg
		MOVE	RLR,AXreg
		CLRF	AXreg+1
		BTFSC	AXreg,7
		COMF	AXreg+1
		CALL	Mult1616
		MOVEC	D'100',DEXreg
		CALL	Divide2416
		MOVE	CEXreg,Rpos
ADR3
		RETURN

ApplyTrims
	; Aielron
		MOVLR	HIGH AilTrimCh
		MOVFP	AilTrimCh,WREG
		CALL	SelectTrim
		; Now add the trim zero values...
		MOVLR	HIGH TrimZeroAil
		MOVFP	TrimZeroAil,WREG
		MOVLR	HIGH BXreg
		ADDWF	BXreg
		MOVLR	HIGH TrimZeroAil
		MOVFP	TrimZeroAil+1,WREG
		MOVLR	HIGH BXreg
		ADDWFC	BXreg+1
		; 
		MOVE	APT,AXreg
		MOVLR	HIGH AXreg
		CLRF	AXreg+1
		MOVLW	0FF
		BTFSC	AXreg,7
		MOVWF	AXreg+1
		CALL	Mult1616
		MOVLR	HIGH DEXreg
		MOVLW	D'100'
		MOVWF	DEXreg
		CLRF	DEXreg+1
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416
		MOVLR	HIGH CEXreg
		; Autotrim...
		MOVLR	HIGH AAT
		MOVFP	AAT,WREG
		MOVLR	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		BTFSC	AXreg,7
		COMF	AXreg+1
		MOVFP	AXreg,WREG
		ADDWF	CEXreg,F
		MOVFP	AXreg+1,WREG
		ADDWFC	CEXreg+1,F
		; End Autotrim...
		MOVFP	CEXreg,WREG
		ADDWF	Apos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Apos+1,F
	; Elevator
		MOVLR	HIGH EleTrimCh
		MOVFP	EleTrimCh,WREG
		CALL	SelectTrim
		; Now add the trim zero values...
		MOVLR	HIGH TrimZeroEle
		MOVFP	TrimZeroEle,WREG
		MOVLR	HIGH BXreg
		ADDWF	BXreg
		MOVLR	HIGH TrimZeroEle
		MOVFP	TrimZeroEle+1,WREG
		MOVLR	HIGH BXreg
		ADDWFC	BXreg+1
		; 
		MOVE	EPT,AXreg
		MOVLR	HIGH AXreg
		CLRF	AXreg+1
		MOVLW	0FF
		BTFSC	AXreg,7
		MOVWF	AXreg+1
		CALL	Mult1616
		MOVLR	HIGH DEXreg
		MOVLW	D'100'
		MOVWF	DEXreg
		CLRF	DEXreg+1
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416
		MOVLR	HIGH CEXreg
		; Autotrim...
		MOVLR	HIGH EAT
		MOVFP	EAT,WREG
		MOVLR	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		BTFSC	AXreg,7
		COMF	AXreg+1
		MOVFP	AXreg,WREG
		ADDWF	CEXreg,F
		MOVFP	AXreg+1,WREG
		ADDWFC	CEXreg+1,F
		; End Autotrim...
		MOVFP	CEXreg,WREG
		ADDWF	Epos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Epos+1,F
	; Rudder
		MOVLR	HIGH RudTrimCh
		MOVFP	RudTrimCh,WREG
		CALL	SelectTrim
		; Now add the trim zero values...
		MOVLR	HIGH TrimZeroRud
		MOVFP	TrimZeroRud,WREG
		MOVLR	HIGH BXreg
		ADDWF	BXreg
		MOVLR	HIGH TrimZeroRud
		MOVFP	TrimZeroRud+1,WREG
		MOVLR	HIGH BXreg
		ADDWFC	BXreg+1
		; 
		MOVE	RPT,AXreg
		MOVLR	HIGH AXreg
		CLRF	AXreg+1
		MOVLW	0FF
		BTFSC	AXreg,7
		MOVWF	AXreg+1
		CALL	Mult1616
		MOVLR	HIGH DEXreg
		MOVLW	D'100'
		MOVWF	DEXreg
		CLRF	DEXreg+1
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416
		MOVLR	HIGH CEXreg
		; Autotrim...
		MOVLR	HIGH RAT
		MOVFP	RAT,WREG
		MOVLR	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		BTFSC	AXreg,7
		COMF	AXreg+1
		MOVFP	AXreg,WREG
		ADDWF	CEXreg,F
		MOVFP	AXreg+1,WREG
		ADDWFC	CEXreg+1,F
		; End Autotrim...
		MOVFP	CEXreg,WREG
		ADDWF	Rpos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Rpos+1,F
	; Throttle, TMODE control out this trim is applied
	; 0 = normal
	; 1 = trim at low throttle only
	; 2 = trim at high throttle only
		; First calculate the trim...
		MOVLR	HIGH ThtTrimCh
		MOVFP	ThtTrimCh,WREG
		CALL	SelectTrim
		MOVE	TPT,AXreg
		MOVLR	HIGH AXreg
		CLRF	AXreg+1
		MOVLW	0FF
		BTFSC	AXreg,7
		MOVWF	AXreg+1
		CALL	Mult1616
		MOVLR	HIGH DEXreg
		MOVLW	D'100'
		MOVWF	DEXreg
		CLRF	DEXreg+1
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416	; Trim is now in CEXreg
		; Test the trim mode
		MOVLR	HIGH TMODE
		MOVLW	1
		CPFSEQ	TMODE
		GOTO	AT1
		; Here for mode 1, trim at low
		MOVLR	HIGH AXreg
		MOVLW	HIGH D'1000'
		MOVWF	AXreg+1
		MOVWF	DEXreg+1
		MOVLW	LOW D'1000'
		MOVWF	AXreg
		MOVWF	DEXreg
		MOVFP	Tpos,WREG
		SUBWF	AXreg,F
		MOVFP	Tpos+1,WREG
		SUBWFB	AXreg+1,F
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		MOVE	CEXreg,BXreg
		CALL	Mult1616
		CALL	Divide2416		
		GOTO	AT2
AT1
		MOVLW	2
		CPFSEQ	TMODE
		GOTO	AT2
		; Here for mode 2, trim at high
		MOVLR	HIGH AXreg
		MOVFP	Tpos,WREG
		MOVWF	AXreg
		MOVFP	Tpos+1,WREG
		MOVWF	AXreg+1
		MOVE	CEXreg,BXreg
		CALL	Mult1616
		MOVLR	HIGH DEXreg
		MOVLW	HIGH D'1000'
		MOVPF	WREG,DEXreg+1
		MOVLW	LOW D'1000'
		MOVPF	WREG,DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416		
AT2		; Apply the trim to the throttle position
		MOVLR	HIGH CEXreg
		MOVFP	CEXreg,WREG
		ADDWF	Tpos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Tpos+1,F
		RETURN

ApplySnap
		MOVEC	D'10',AXreg
	; Snap right
	; Test the right snap button
		MOVLR	HIGH SWSNAPR
		MOVFP	SWSNAPR,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	AS10
		; If the MSB is clear then set the servo position
		MOVLR	HIGH SR_A
		BTFSS	SR_A+1,7
		GOTO	AS9a
		MOVEB	SR_A,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVE	CEXreg,Apos		
AS9a		
		MOVLR	HIGH SR_E
		BTFSS	SR_E+1,7
		GOTO	AS9b
		MOVEB	SR_E,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVE	CEXreg,Epos		
AS9b		
		MOVLR	HIGH SR_R
		BTFSS	SR_R+1,7
		GOTO	AS9c
		MOVEB	SR_R,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVE	CEXreg,Rpos		
AS9c		
		MOVLR	HIGH SR_T
		BTFSS	SR_T+1,7
		GOTO	AS10
		MOVEB	SR_T,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVE	CEXreg,Tpos		
AS10
	;  Snap left
		MOVLR	HIGH SWSNAPL
		MOVFP	SWSNAPL,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	AS11
		; If the MSB is clear then set the servo position
		MOVLR	HIGH SL_A
		BTFSS	SL_A+1,7
		GOTO	AS10a
		MOVEB	SL_A,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVE	CEXreg,Apos		
AS10a		
		MOVLR	HIGH SL_E
		BTFSS	SL_E+1,7
		GOTO	AS10b
		MOVEB	SL_E,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVE	CEXreg,Epos		
AS10b		
		MOVLR	HIGH SL_R
		BTFSS	SL_R+1,7
		GOTO	AS10c
		MOVEB	SL_R,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVE	CEXreg,Rpos		
AS10c		
		MOVLR	HIGH SL_T
		BTFSS	SL_T+1,7
		GOTO	AS11
		MOVEB	SL_T,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVE	CEXreg,Tpos		
AS11
        ; If Tpos is negative, set it to zero
                MOVLR   HIGH Tpos
                BTFSS   Tpos+1,7
                RETURN
                ; Here is Tpos is negative
                CLRF    WREG
                MOVWF   Tpos
                MOVWF   Tpos+1
                RETURN

; This function perfroms the auto trim algorithm. If the autotrim
; buttom is pressed and one of the centering stick is not 
; centered then the trim position is adjusted.
; There are two AutoTrim modes determined by ATmode.
; ATmode:
;        0 = Standard mode, while you hold the auto trim button the
;            channel is moved in small increments. You can define the
;            increment size and time between adjustments.
;        1 = One shot mode, in this mode the entire adjustment is made
;            in one step.
; The Auto Trim function will only allow a maximum of +- 10 percent adjustment
; of a channels position.
AutoTrim
	; If we are in the master mode then exit, do not
	; do auto trim in master mode!
		MOVLR	HIGH Master
		BTFSC	Master,0
		RETURN
	; Test the autotrim button
		MOVLR	HIGH SWATRIM
		MOVFP	SWATRIM,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		RETURN
	; Make sure its time...
		MOVLR	HIGH TimeOut2
		TSTFSZ	TimeOut2
		RETURN
		MOVLR	HIGH AutoTrimTime
		MOVFP	AutoTrimTime,WREG
		MOVLR	HIGH TimeOut2
		MOVWF	TimeOut2
		; Test if this is one shot mode
                MOVLR   HIGH ATmode
                MOVLW   1
                CPFSEQ  ATmode
                GOTO	AutoTrim0
		; Beep one time to indicate we are doing the adjustment
		MOVLW	D'1'  
		MOVLR	HIGH BeepCyl
		MOVWF	BeepCyl
		MOVLW	D'5'
		CALL	Beep
	        ; Set the one shot time, this is a fixed value
	        MOVLW   AutoTrimOStime	
		MOVLR	HIGH TimeOut2
		MOVWF	TimeOut2
AutoTrim0		
		CALL	DetermineDevice
	; Aileron
		MOVE	Apos,AXreg
		CALL    AutoLimit
		BTFSS   ALUSTA,Z
		GOTO	AutoTrim2
		; Adjust autotrim position
		MOVLR   HIGH ATmode
		TSTFSZ  ATmode
		GOTO    AutoTrim1e
		MOVLR	HIGH AutoTrimStep
		MOVFP	AutoTrimStep,WREG
AutoTrim1e	MOVLR	HIGH Apos
		BTFSC	Apos+1,7
		GOTO	AutoTrim1a
		; Here if positive
		MOVLR	HIGH AAT
		ADDWF	AAT
		BTFSS	AAT,7
		GOTO	AutoTrim1c
		BTFSS	ALUSTA,OV
		GOTO	AutoTrim1c
		GOTO	AutoTrim1plim
AutoTrim1a	; Here if negative
		MOVLR	HIGH AAT
		SUBWF	AAT
		BTFSC	AAT,7
		GOTO	AutoTrim1c
		BTFSS	ALUSTA,OV
		GOTO	AutoTrim1c
		GOTO	AutoTrim1b
AutoTrim1c	; Now do the limit testing
		BTFSC	AAT,7
		GOTO	AutoTrim1b
		; Here if positive
AutoTrim1plim	MOVLW	D'100'
		CPFSLT	AAT
		MOVWF	AAT
		GOTO	AutoTrim1d
AutoTrim1b	; Here if negative
		MOVLW	D'100'
		COMF	WREG
		INCF	WREG
		CPFSGT	AAT
		MOVWF	AAT
		; Save the new value to Sprom
AutoTrim1d
		CALL	SpromEWEN
		MOVLR	HIGH AAT
		MOVFP	AAT,Areg
		MOVE	SPROMAircraft,AXreg
		MOVLW	20
		SUBLW	LOW AAT
		ADDWF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
		CALL	SpromWriteByte
		CALL	SpromEWNDS
	; Elevator
AutoTrim2
		MOVE	Epos,AXreg
		CALL    AutoLimit
		BTFSS   ALUSTA,Z
		GOTO	AutoTrim3
		; Adjust autotrim position
		MOVLR   HIGH ATmode
		TSTFSZ  ATmode
		GOTO    AutoTrim2e
		MOVLR	HIGH AutoTrimStep
		MOVFP	AutoTrimStep,WREG
AutoTrim2e	MOVLR   HIGH Epos
		BTFSC	Epos+1,7
		GOTO	AutoTrim2a
		; Here if positive
		MOVLR	HIGH EAT
		ADDWF	EAT
		BTFSS	EAT,7
		GOTO	AutoTrim2c
		BTFSS	ALUSTA,OV
		GOTO	AutoTrim2c
		GOTO	AutoTrim2plim
AutoTrim2a	; Here if negative
		MOVLR	HIGH EAT
		SUBWF	EAT
		BTFSC	EAT,7
		GOTO	AutoTrim2c
		BTFSS	ALUSTA,OV
		GOTO	AutoTrim2c
		GOTO	AutoTrim2b
AutoTrim2c	; Now do the limit testing
		BTFSC	EAT,7
		GOTO	AutoTrim2b
		; Here is positive
AutoTrim2plim	MOVLW	D'100'
		CPFSLT	EAT
		MOVWF	EAT
		GOTO	AutoTrim2d
AutoTrim2b	; Here if negative
		MOVLW	D'100'
		COMF	WREG
		INCF	WREG
		CPFSGT	EAT
		MOVWF	EAT
		; Save the new value to Sprom
AutoTrim2d
		CALL	SpromEWEN
		MOVLR	HIGH EAT
		MOVFP	EAT,Areg
		MOVE	SPROMAircraft,AXreg
		MOVLW	20
		SUBLW	LOW EAT
		ADDWF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
		CALL	SpromWriteByte
		CALL	SpromEWNDS
	; Rudder
AutoTrim3
		MOVE	Rpos,AXreg
		CALL    AutoLimit
		BTFSS   ALUSTA,Z
		GOTO	AutoTrim4
		; Adjust autotrim position
		MOVLR   HIGH ATmode
		TSTFSZ  ATmode
		GOTO    AutoTrim3e
		MOVLR	HIGH AutoTrimStep
		MOVFP	AutoTrimStep,WREG
AutoTrim3e	MOVLR   HIGH Rpos
		BTFSC	Rpos+1,7
		GOTO	AutoTrim3a
		; Here if positive
		MOVLR	HIGH RAT
		ADDWF	RAT
		BTFSS	RAT,7
		GOTO	AutoTrim3c
		BTFSS	ALUSTA,OV
		GOTO	AutoTrim3c
		GOTO	AutoTrim3plim
AutoTrim3a	; Here if negative
		MOVLR	HIGH RAT
		SUBWF	RAT
		BTFSC	RAT,7
		GOTO	AutoTrim3c
		BTFSS	ALUSTA,OV
		GOTO	AutoTrim3c
		GOTO	AutoTrim3b
AutoTrim3c	; Now do the limit testing
		BTFSC	RAT,7
		GOTO	AutoTrim3b
		; Here is positive
AutoTrim3plim	MOVLW	D'100'
		CPFSLT	RAT
		MOVWF	RAT
		GOTO	AutoTrim3d
AutoTrim3b	; Here if negative
		MOVLW	D'100'
		COMF	WREG
		INCF	WREG
		CPFSGT	RAT
		MOVWF	RAT
		; Save the new value to Sprom
AutoTrim3d
		CALL	SpromEWEN
		MOVLR	HIGH RAT
		MOVFP	RAT,Areg
		MOVE	SPROMAircraft,AXreg
		MOVLW	20
		SUBLW	LOW RAT
		ADDWF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
		CALL	SpromWriteByte
		CALL	SpromEWNDS
AutoTrim4
		GOTO	ResetDevice


; This function takes the absolute value of the number in reg AXreg and limits
; it to 100. This function is used by the AutoTrim algorithm
; The channel's normalized position must be in AXreg. Additionally the position
; information is test to see if its over threshold.
; Zero flag is set if the channel is above threshold.
; The limited value is returned in WREG
AutoLimit   
	; First determine the absolute value
		MOVLR	HIGH AXreg
		BTFSS	AXreg+1,7
		GOTO	AutoLimit1
		COMF	AXreg
		COMF	AXreg+1
		INCF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
	; Now determine if its over 100
AutoLimit1
		TSTFSZ	AXreg+1
		GOTO	AutoLimit3
		MOVLW	D'100'
		CPFSGT	AXreg
		GOTO    AutoLimit2
	; Set limit to 100
AutoLimit3	MOVEC	D'100',AXreg
	; Test Threshold
AutoLimit2
                ; Divide by 8
                MOVFP   AXreg,WREG
                RRCF    WREG
                RRCF    WREG
                RRCF    WREG
                ANDLW   01F
                BTG     ALUSTA,Z
                MOVFP   AXreg,WREG
                RETURN

;
; This function uses the normalized servo position and the selected aircraft's
; setup information to calculate the servo positions and place the results
; in the timing array. If the dual aileron mixer mode is enabled then channel
; 7 will use the aileron channel gains.
;
CalculateServoPositions
	; Clear OVERRUN flag
		MOVLR	HIGH OVERRUN
		CLRF	OVERRUN
	; Aielron
		MOVLR	HIGH Apos
		BTFSC	Apos+1,7
		GOTO	CSP1
		; Here if positive
		MOVE	AM1H,AXreg
		MOVE	Apos,BXreg
		CALL	Mult1616
		GOTO	CSP2

CSP1		; Here if negative
		MOVE	AM2H,AXreg
		MOVE	Apos,BXreg
		CALL	Mult1616
CSP2
		; Add the offset
		MOVE	AB,AXreg
		MOVLR	HIGH AXreg
		MOVFP	CEXreg+1,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+2,WREG
		ADDWFC	AXreg+1,F
		; Place in output timing array
		CALL    ApplyLimit
		MOVE	AXreg,chAIL
	; Elevator
		MOVLR	HIGH Epos
		BTFSC	Epos+1,7
		GOTO	CSP3
		; Here if positive
		MOVE	EM1H,AXreg
		MOVE	Epos,BXreg
		CALL	Mult1616
		GOTO	CSP4

CSP3		; Here if negative
		MOVE	EM2H,AXreg
		MOVE	Epos,BXreg
		CALL	Mult1616
CSP4
		; Add the offset
		MOVE	EB,AXreg
		MOVLR	HIGH AXreg
		MOVFP	CEXreg+1,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+2,WREG
		ADDWFC	AXreg+1,F
		; Place in output timing array
		CALL    ApplyLimit
		MOVE	AXreg,chELE
	; Rudder
		MOVLR	HIGH Rpos
		BTFSC	Rpos+1,7
		GOTO	CSP5
		; Here if positive
		MOVE	RM1H,AXreg
		MOVE	Rpos,BXreg
		CALL	Mult1616
		GOTO	CSP6

CSP5		; Here if negative
		MOVE	RM2H,AXreg
		MOVE	Rpos,BXreg
		CALL	Mult1616
CSP6
		; Add the offset
		MOVE	RB,AXreg
		MOVLR	HIGH AXreg
		MOVFP	CEXreg+1,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+2,WREG
		ADDWFC	AXreg+1,F
		; Place in output timing array
		CALL    ApplyLimit
		MOVE	AXreg,chRUD
	; Throttle
		MOVE	TMH,AXreg
		MOVE	Tpos,BXreg
		CALL	Mult1616
		MOVE	TBH,AXreg
		MOVLR	HIGH AXreg
		MOVFP	CEXreg+1,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+2,WREG
		ADDWFC	AXreg+1,F
		; Place in output timing array
		CALL    ApplyLimit
		MOVE	AXreg,chTHT
	; CH5	
		MOVE	CH5MH,AXreg
		MOVE	CH5pos,BXreg
		CALL	Mult1616
		MOVE	CH5BH,AXreg
		MOVLR	HIGH AXreg
		MOVFP	CEXreg+1,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+2,WREG
		ADDWFC	AXreg+1,F
		; Place in output timing array
		CALL    ApplyLimit
		MOVE	AXreg,chCH5
	; CH6
		MOVE	CH6MH,AXreg
		MOVE	CH6pos,BXreg
		CALL	Mult1616
		MOVE	CH6BH,AXreg
		MOVLR	HIGH AXreg
		MOVFP	CEXreg+1,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+2,WREG
		ADDWFC	AXreg+1,F
		; Place in output timing array
		CALL    ApplyLimit
		MOVE	AXreg,chCH6
	; CH7
	; Test if the dual aileron mixer flag is set...
		MOVLR	HIGH DUALA
		BTFSS	DUALA,0		
		GOTO	CH7normal
	; Here if the dual aileron flag is set
CH7duala
		MOVLR	HIGH CH7pos
		BTFSC	CH7pos+1,7
		GOTO	CSP1a
		; Here if positive
		MOVE	AM1H,AXreg
		MOVE	CH7pos,BXreg
		CALL	Mult1616
		GOTO	CSP2a

CSP1a		; Here if negative
		MOVE	AM2H,AXreg
		MOVE	CH7pos,BXreg
		CALL	Mult1616
CSP2a
		; Add the offset
		MOVE	AB,AXreg
		MOVLR	HIGH AXreg
		MOVFP	CEXreg+1,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+2,WREG
		ADDWFC	AXreg+1,F
		GOTO	CH7save
	; Here if the dual aileron flag is clear
CH7normal
		MOVE	CH7MH,AXreg
		MOVE	CH7pos,BXreg
		CALL	Mult1616
		MOVE	CH7BH,AXreg
		MOVLR	HIGH AXreg
		MOVFP	CEXreg+1,WREG
		ADDWF	AXreg,F
		MOVFP	CEXreg+2,WREG
		ADDWFC	AXreg+1,F
		; Place in output timing array
CH7save
		CALL    ApplyLimit
		MOVE	AXreg,chCH7
	; CH8, Subtract 500 from CH8pos
		MOVE	CH8pos,AXreg
		MOVLW	LOW D'500'
		SUBWF	AXreg,F
		MOVLW	HIGH D'500'
		SUBWFB	AXreg+1,F
		; Multipy AXreg by 2
		BCF	ALUSTA,C
		RLCF	AXreg
		RLCF	AXreg+1
		; Test the sign
		BTFSC	AXreg+1,7
		GOTO	CSP7
		; Here if postive
		MOVE	CH8_A,BXreg
		CALL	Mult1616
		GOTO	CSP8		
CSP7		; Here if negative
		MOVE	CH8_C,BXreg
		CALL	Mult1616
CSP8		; Add the offset term...
		MOVE	CH8_B,AXreg
		MOVFP	AXreg,WREG
		ADDWF	CEXreg+1,F
		MOVFP	AXreg+1,WREG
		ADDWFC	CEXreg+2,F
		MOVE    CEXreg+1,AXreg
		CALL    ApplyLimit
		MOVE	AXreg,chCH8
	; Now proccess all of the buttons:
	;  Throttle preset
		MOVLR	HIGH TTflag		; If the throttle trim adjust flag is set then
		TSTFSZ	TTflag			; ignore the preset button test.
		GOTO	CSP9
		MOVLR	HIGH SWPRESET
		MOVFP	SWPRESET,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CSP9
		MOVE	Tpreset,chTHT
CSP9
		RETURN
	
; This function will test the value in AXreg using the variables in
; ServoMin and ServoMax. If the value in AXreg exceeds the limts, AXreg
; will be set to limit.	
ApplyLimit
        ; Test the minimum limit by subtrating it from the servo position
                MOVLR   HIGH ServoMin
                MOVFP   ServoMin,WREG
                MOVLR   HIGH AXreg
                SUBWF   AXreg,W
                MOVLR   HIGH ServoMin
                MOVFP   ServoMin+1,WREG
                MOVLR   HIGH AXreg
                SUBWFB  AXreg+1,W
         ; If its negative then its below the minimum limit
                BTFSS   WREG,7
                GOTO    AL1
                ; Here is negative, so set to minimum and exit
                MOVE    ServoMin,AXreg
                RETURN                
        ; Test the maximum limit by subtracting the maximum from the servo position
AL1
                MOVLR   HIGH ServoMax
                MOVFP   ServoMax,WREG
                MOVLR   HIGH AXreg
                SUBWF   AXreg,W
                MOVLR   HIGH ServoMax
                MOVFP   ServoMax+1,WREG
                MOVLR   HIGH AXreg
                SUBWFB  AXreg+1,W
         ; If its negative then its below the minimum limit
                BTFSC   WREG,7
                RETURN
                ; Here is negative, so set to minimum and exit
                MOVE    ServoMax,AXreg
                RETURN


; This function tests the Option button and returns its state
; in the carry flag.
;	C set if Option button was pressed
Option
		MOVLR	HIGH PORTDimage
		BTFSC	PORTDimage,OPTION
		GOTO	Option1
		; Test if its been processed
		BTFSS	PORTDlatch,OPTION
		GOTO	Option1
		; Beep one time to indicate we detected the
		; button...
		BCF	PORTDlatch,OPTION
		MOVLW	D'1'
		MOVWF	BeepCyl
		MOVLW	D'5'
		CALL	Beep
		BSF	ALUSTA,C
		RETURN
Option1
		BCF	ALUSTA,C
		RETURN

; This function will load the general setup data from SPROM into bank 2
; This data applies to all aircraft and includes the joy stick calibration
; parameters.
LoadGeneral
		MOVLW	20		; Bank 2
		MOVPF	WREG,Areg
		MOVLR	HIGH AXreg
		MOVLW	0E0		; Number of bytes
		MOVPF	WREG,Breg
		CLRF	AXreg
		CLRF	AXreg+1
		MOVLW	20
		MOVPF	WREG,FSR1
		CALL	SpromRead	; Read the data
		; Load Aircraft number into current aircraft
		MOVLR	HIGH Aircraft
		MOVFP	Aircraft,WREG
		MOVLR	HIGH DefaultAircraft
		MOVWF	DefaultAircraft
		RETURN
; Writes the general parameters to SPROM
SaveGeneral
		MOVLW	20		; Bank 2
		MOVPF	WREG,Areg
		MOVLR	HIGH AXreg
		MOVLW	0E0		; Number of bytes
		MOVPF	WREG,Breg
		CLRF	AXreg
		CLRF	AXreg+1
		MOVLW	20
		MOVPF	WREG,FSR1
		CALL	SpromWrite
		RETURN
		
; This function is used to save a data to the SPROM.
; On call:
;	FSR1 = Address of data in RAM to write to SPROM
;	Areg = Bank for data to write
;	Breg = number of bytes to write
; If the Bank is set to 20 (the general data area) then the first
; SPROM will be used.
SaveSPROM		
		CALL	DetermineDevice
		MOVE	SPROMAircraft,AXreg	; Load the pointer to start of current aircraft
		; Test the bank register and see if its in the general area.
		MOVLW	20		; Load bank 2 constant
		CPFSEQ	Areg
		GOTO	SaveSPROM0
		; Here if in bank 2
		MOVLR	HIGH AXreg
		CLRF	AXreg
		CLRF	AXreg+1
		MOVLR	HIGH SelSprom
		CLRF	SelSprom
		BSF	SelSprom,CFGMEM1
SaveSPROM0
		CALL	SpromEWEN
		MOVLW	20		; Offest to start of RAM
		SUBWF	FSR1,W
		ADDWF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1		; AXreg points to the address in SPROM
		CALL	SpromWrite	; Areg = seg, Breg = #bytes, AXreg = address
		CALL	SpromEWNDS
		CALL	ResetDevice
		RETURN

; This function calculates the sprom selection mask based on the 
; aircraft number. The selection mask is used to determine the 
; sprom device to use.
; The aircraft number-1 in the selected device is returned in
; reg WREG.
DetermineDevice
	; Calculate the Sprom address of the selected arecraft
		MOVLR	HIGH Aircraft
		MOVFP	Aircraft,WREG
		DECF	WREG
		BTFSS	WREG,3
		RETURN
		; Here if this is the sec sprom
		BCF	WREG,3
		MOVLR	HIGH SelSprom
		CLRF	SelSprom
		BSF	SelSprom,CFGMEM2
		RETURN
; This function resets the selected device to the onboard sprom.	
ResetDevice
		MOVLR	HIGH SelSprom
		CLRF	SelSprom
		BSF	SelSprom,CFGMEM1
		RETURN

; This function loads just the aircraft name for the current aircraft
; number defined in Aircraft.
LoadAircraftName
		CALL	DetermineDevice
		INCF	WREG
		MULLW	0E0
		MOVLR	HIGH AXreg
		MOVPF	PRODL,AXreg
		MOVPF	PRODH,AXreg+1
		MOVLW	HIGH Name
		SWAPF	WREG
		MOVWF	Areg
		MOVLW	D'16'
		MOVWF	Breg
		MOVLW	020
		MOVWF	FSR1
		CALL	SpromRead
		GOTO	ResetDevice
		
SaveAircraftName
		CALL	DetermineDevice
		INCF	WREG
		MULLW	0E0
		MOVLR	HIGH AXreg
		MOVPF	PRODL,AXreg
		MOVPF	PRODH,AXreg+1
		MOVLW	HIGH Name
		SWAPF	WREG
		MOVWF	Areg
		MOVLW	D'16'
		MOVWF	Breg
		MOVLW	020
		MOVWF	FSR1
		CALL	SpromWrite
		GOTO	ResetDevice

; This function will load the aircraft data. The parameter SelSprom
; is defined by this function. Aircraft numbers 1 through 8 are in 
; device 1, aircraft 9 through 16 are in device 2. SelSprom is reset
; to the on board device when this function exits.
LoadAircraft
	; Setup variables...
		MOVLW	30
		MOVWF	Areg
		CALL	DetermineDevice
		INCF	WREG
		MOVLR	HIGH AXreg
		MULLW	0E0
		MOVPF	PRODL,AXreg
		MOVPF	PRODH,AXreg+1
		MOVE	AXreg,SPROMAircraft
		MOVLW	0E0		; Number of bytes
		MOVPF	WREG,Breg
		MOVLW	20
		MOVPF	WREG,FSR1
		CALL	SpromRead	; Read the data
		GOTO	ResetDevice
SaveAircraft
	; Setup variables...
		MOVLW	30
		MOVWF	Areg
		CALL	DetermineDevice
		INCF	WREG
		MOVLR	HIGH AXreg
		MULLW	0E0
		MOVPF	PRODL,AXreg
		MOVPF	PRODH,AXreg+1
		MOVLW	0E0		; Number of bytes
		MOVPF	WREG,Breg
		MOVLW	20
		MOVPF	WREG,FSR1
		CALL	SpromWrite	; Read the data
		GOTO	ResetDevice

;
; Mixer routines...
;
; This routine will move all of the channel position data to the Mixed
; position variables.
Move2Mix
		MOVE16	Apos,AposM
		MOVE16	Epos,EposM
		MOVE16	Rpos,RposM
		MOVE16	Tpos,TposM
		MOVE16	CH5pos,CH5posM
		MOVE16	CH6pos,CH6posM
		MOVE16	CH7pos,CH7posM
		MOVE16	CH8pos,CH8posM
		RETURN

; This function applies the mixers to all servo channels. The mixer switch
; position are tested and if on the mixers are applied. The preprogramed mix
; function are not applied by the routine
ApplyMixers
		CALL	Move2Mix
	; Test Mixer 1
		MOVLR	HIGH SWMIX1
		MOVFP	SWMIX1,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	APmix2
		; Apply all four mix channels
		MOVLW	LOW M1Afrom
		MOVWF	FSR1
		CALL	Mixer
		MOVLW	LOW M1Bfrom
		MOVWF	FSR1
		CALL	Mixer
		MOVLW	LOW M1Cfrom
		MOVWF	FSR1
		CALL	Mixer
		MOVLW	LOW M1Dfrom
		MOVWF	FSR1
		CALL	Mixer
APmix2
		CALL	Move2Mix
		MOVLR	HIGH SWMIX2
		MOVFP	SWMIX2,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	APmix3
		MOVLW	LOW M2Afrom
		MOVWF	FSR1
		CALL	Mixer
		CALL	Move2Mix
		MOVLW	LOW M2Bfrom
		MOVWF	FSR1
		CALL	Mixer
		CALL	Move2Mix
		MOVLW	LOW M2Cfrom
		MOVWF	FSR1
		CALL	Mixer
		CALL	Move2Mix
		MOVLW	LOW M2Dfrom
		MOVWF	FSR1
		CALL	Mixer
APmix3
		CALL	Move2Mix
		MOVLR	HIGH SWMIX3
		MOVFP	SWMIX3,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	APdone
		MOVLW	LOW M3Afrom
		MOVWF	FSR1
		CALL	Mixer
		MOVLW	LOW M3Bfrom
		MOVWF	FSR1
		CALL	Mixer
		MOVLW	LOW M3Cfrom
		MOVWF	FSR1
		CALL	Mixer
		MOVLW	LOW M3Dfrom
		MOVWF	FSR1
		CALL	Mixer
APdone
		RETURN

; This function calculates the fixed mixer functions:
;	VTAIL		Rudder and Elevator mix
;	ELEVON		Aileron and Elevator mix
;	DUALA		Dual aileron
; It is assumed the position variables have been copied to 
; the mixer array. The information is calculated using the
; mixer array as the source and the standard array as the 
; destination.
CalculateFixedMixers
	; VTAIL mixing, VTAIL flag is 0 if off
	;    Rudder   = Elevator/2 + Rudder/2
	;    Elevator = Elevator/2 - Rudder/2
		MOVLR	HIGH VTAIL
		BTFSS	VTAIL,0
		GOTO	AFM1
		; Here if the Vtail is enabled.
		MOVE	EposM,AXreg
		MOVE	RposM,BXreg
		; AXreg = Axreg/2
		BCF	ALUSTA,C
		BTFSC	AXreg+1,7
		BSF	ALUSTA,C
		RRCF	AXreg+1
		RRCF	AXreg
		; BXreg = BXreg/2
		BCF	ALUSTA,C
		BTFSC	BXreg+1,7
		BSF	ALUSTA,C
		RRCF	BXreg+1
		RRCF	BXreg
		; Do the math...
		MOVE	AXreg,Epos
		MOVE	AXreg,Rpos
		MOVFP	BXreg,WREG
		ADDWF	Rpos
		MOVFP	BXreg+1,WREG
		ADDWFC	Rpos+1
		MOVFP	BXreg,WREG
		SUBWF	Epos
		MOVFP	BXreg+1,WREG
		SUBWFB	Epos+1
	; ELEVON mixing, ELEVON flag is 0 if off
	;    Aileron  = Elevator/2 + Aileron/2
	;    Elevator = Elevator/2 - Aileron/2
AFM1
		MOVLR	HIGH ELEVON
		BTFSS	ELEVON,0
		GOTO	AFM2
		; Here if the ELEVON is enabled.
		MOVE	EposM,AXreg
		MOVE	AposM,BXreg
		; AXreg = Axreg/2
		BCF	ALUSTA,C
		BTFSC	AXreg+1,7
		BSF	ALUSTA,C
		RRCF	AXreg+1
		RRCF	AXreg
		; BXreg = BXreg/2
		BCF	ALUSTA,C
		BTFSC	BXreg+1,7
		BSF	ALUSTA,C
		RRCF	BXreg+1
		RRCF	BXreg
		; Do the math...
		MOVE	AXreg,Epos
		MOVE	AXreg,Apos
		MOVFP	BXreg,WREG
		ADDWF	Apos
		MOVFP	BXreg+1,WREG
		ADDWFC	Apos+1
		MOVFP	BXreg,WREG
		SUBWF	Epos
		MOVFP	BXreg+1,WREG
		SUBWFB	Epos+1
	; DUALA, dual aileron mixing. CH7 used for second
	; aileron channel, if REVA flag is non zero then channel
	; 7 is reversed.
AFM2
		MOVLR	HIGH DUALA
		BTFSS	DUALA,0
		GOTO	AFM3
		; Here if the DUALA is enabled.
		MOVE	AposM,AXreg
		MOVE	AXreg,Apos
		MOVE	AXreg,CH7pos
;		MOVLR	HIGH REVA
;		BTFSS	REVA,0
;		GOTO	AFM2z
		; Here if CH7 needs to be reversed
;		MOVLR	HIGH AXreg
;		COMF	AXreg
;		COMF	AXreg+1
;		INCF	AXreg
;		BTFSC	ALUSTA,C
;		INCF	AXreg+1
;		MOVE	AXreg,CH7pos
		; Apply the diferential.
;AFM2z
		MOVEC	D'100',DEXreg
		MOVLR	HIGH DIFFA
		MOVFP	DIFFA,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		GOTO	AFM2a
		; If the percentage is positive then apply to positive servo 
		; position, if negative apply to negative servo positions.
		BTFSC	WREG,7
		GOTO	AFM2b
		; Here if positive
		SUBLW	D'100'		; WREG = 100 - DIFFA
		MOVLR	HIGH Apos
		MOVWF	BXreg
		CLRF	BXreg+1
		BTFSC	Apos+1,7
		GOTO	AFM2c
		MOVE	Apos,AXreg
		CALL	Mult1616	; CEXreg = AXreg * BXreg
		CALL	Divide2416
		MOVE	CEXreg,Apos
AFM2c
		MOVLR	HIGH CH7pos
		BTFSS	CH7pos+1,7
		GOTO	AFM2a
		MOVE	CH7pos,AXreg
		CALL	Mult1616	; CEXreg = AXreg * BXreg
		CALL	Divide2416
		MOVE	CEXreg,CH7pos
		GOTO	AFM2a
AFM2b		; Here if negative
		ADDLW	D'100'		; WREG = 100 + DIFFA
		MOVLR	HIGH Apos
		MOVWF	BXreg
		CLRF	BXreg+1
		BTFSS	Apos+1,7
		GOTO	AFM2d
		MOVE	Apos,AXreg
		CALL	Mult1616	; CEXreg = AXreg * BXreg
		CALL	Divide2416
		MOVE	CEXreg,Apos
AFM2d
		MOVLR	HIGH CH7pos
		BTFSC	CH7pos+1,7
		GOTO	AFM2a
		MOVE	CH7pos,AXreg
		CALL	Mult1616	; CEXreg = AXreg * BXreg
		CALL	Divide2416
		MOVE	CEXreg,CH7pos
AFM2a
		; If CH7 reverse flag is set then reverse the CH7 polarity here
		MOVLR	HIGH REVA
		BTFSS	REVA,0
		GOTO	AFM2z
		; Here if CH7 needs to be reversed
		MOVLR	HIGH CH7pos
		COMF	CH7pos
		COMF	CH7pos+1
		INCF	CH7pos
		BTFSC	ALUSTA,C
		INCF	CH7pos+1
AFM2z	
		; Apply flapperrons if enabled
		; Use the old CH7pos signal as the flap control.
		; (1000 - CH7pos) * FPgain / 100
		MOVEC	D'100',DEXreg
		MOVLR	HIGH FPgain
		MOVFP	FPgain,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		GOTO	AFM2e           ; If gain is 0 then its disabled so jump out
		; If CROW is enabled and CROW switch is OFF then jump out
		MOVLR	HIGH CROWENA    ; Test for CROW enable...
		MOVFP	CROWENA,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		GOTO    AFM2aa          ; Jump if CROW is disabled
		MOVLR	HIGH SWCROW
		MOVFP	SWCROW,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	AFM2e           ; Jump out if CROW switch is off
		MOVEC	D'1000',AXreg
		MOVFP	TposM,WREG
		SUBWF	AXreg,F
		MOVFP	TposM+1,WREG
		SUBWFB	AXreg+1,F	; AXreg = 1000 - TposM
                GOTO    AFM2aaa
		; Here to apply the flap, first calculate the position
AFM2aa		MOVEC	D'1000',AXreg
		MOVFP	CH7posM,WREG
		SUBWF	AXreg,F
		MOVFP	CH7posM+1,WREG
		SUBWFB	AXreg+1,F	; AXreg = 1000 - CH7posM
AFM2aaa		MOVE	FPgain,BXreg
		CLRF	BXreg+1
		BTFSC	WREG,7
		COMF	BXreg+1
		CALL	Mult1616
		CALL	Divide2416		; Ans is now in CExreg
		; Apply to Apos...
		MOVFP	CEXreg,WREG
		ADDWF	Apos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Apos+1,F
		; Apply to CH7pos...
		; First see if we need to invert...
		MOVLR	HIGH REVA
		BTFSC	REVA,0
		GOTO	AFM2f
		MOVLR	HIGH CEXreg
		COMF	CEXreg
		COMF	CEXreg+1
		INCF	CEXreg
		BTFSC	ALUSTA,C
		INCF	CEXreg+1
AFM2f
		MOVLR	HIGH CEXreg
		MOVFP	CEXreg,WREG
		ADDWF	CH7pos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	CH7pos+1,F
AFM2e
AFM3
		RETURN

ApplyFixedMixersPrior
	; If the FixedFirst flag is clear then exit
		MOVLR	HIGH FixedFirst
		BTFSS	FixedFirst,0
		RETURN
	; Now do the processing...
		CALL	Move2Mix
		CALL	CalculateFixedMixers	
		RETURN

; This function is designed to apply the fixed mixers used for the
; follwoing functions:
;	VTAIL		Rudder and Elevator mix
;	ELEVON		Aileron and Elevator mix
;	DUALA		Dual aileron
;	Throttle hold	Using channel 5
;	Idle up		Using channel 8
ApplyFixedMixers
	; Calculate the fixed mixer functions...
		; If the FixedFirst flag is clear...
		MOVLR	HIGH FixedFirst
		BTFSC	FixedFirst,0
		GOTO	AFM0
		CALL	Move2Mix
		CALL	CalculateFixedMixers
AFM0
	; Throttle hold. If set then channel 5 is used to enable
	; the throttle hold.		
		MOVLR	HIGH THOLD
		BTFSS	THOLD,0
		GOTO	AFM4
		; Here if the Throttle hold is enabled.
		MOVLR	HIGH SWTHOLD
		MOVFP	SWTHOLD,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	AFM4
		MOVLR	HIGH THOLD
		MOVFP	THOLDp,WREG
		MOVLR	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVE	CEXreg,Tpos
	; Idle up. If set then channel 8 is used to enable
	; two idle up levels
AFM4
		MOVLR	HIGH IDLEUP
		BTFSS	IDLEUP,0
		GOTO	AFM5
		; Here if idle up is enabled, test switch
		MOVLR	HIGH SWIDLEUP1
		MOVFP	SWIDLEUP1,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	AFM4a
		MOVLR	HIGH IDLEUPpA
		MOVFP	IDLEUPpA,WREG
		GOTO	AFM4c
		; Test for idle up position 2
AFM4a		MOVLR	HIGH SWIDLEUP2
		MOVFP	SWIDLEUP2,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	AFM5
		MOVLR	HIGH IDLEUPpB
		MOVFP	IDLEUPpB,WREG
		; WREG has the idle up percentage...
AFM4c		MOVLR	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		; Test IDLE position, if less that CEXreg then set throttle
		; position to CEXreg
		MOVFP	CEXreg,WREG
		SUBWF	Tpos,W
		MOVFP	CEXreg+1,WREG
		SUBWFB	Tpos+1,W
		BTFSS	WREG,7
		GOTO	AFM5
		MOVE	CEXreg,Tpos
AFM5
		RETURN

; This function applies the translation table, pointed to by the MS 4 bits
; of Breg, to the 16 bit value in AXreg.
Translation
	; Exit if table address is 0
		MOVFP	Breg,WREG
		ANDLW	0F0
		BTFSC	ALUSTA,Z
		RETURN
		MOVE	AXreg,Pos
	; If AXreg is neg, change its sign...
		BTFSS	AXreg+1,7
		GOTO	Trans1
		COMF	AXreg
		COMF	AXreg+1
		INCF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
Trans1
	; Here if we have a table address in Breg
	; Calculate the table index
		MOVE	AXreg,CEXreg
		MOVLW	D'100'
		MOVWF	DEXreg
		CALL	Divide168
		; CEXreg now contains the index into the tables number defined
		; in the upper 4 bit of Breg. Test this value, if its greater than
		; 9 set it to 9
		MOVLW	D'9'
		CPFSLT	CEXreg
		MOVWF	CEXreg
		MOVPF	FSR1,Areg	; Save this for later restore
		MOVFP	Breg,WREG
		SWAPF	WREG
		DECF	WREG
		ANDLW	07
		MULLW	D'11'
		MOVFP	PRODL,WREG
		ADDLW	LOW Table1
		ADDWF	CEXreg,W	; WREG now points to the correct byte of the
					; selected table
		MOVPF	WREG,FSR1
		MOVLR	HIGH Table1
		MOVPF	INDF1,WREG	; A point in table
		MOVPF	INDF1,Breg	; B point in table
		MOVLR	HIGH AXreg
		; Restore indirect reg
		MOVFP	Areg,FSR1
		MOVPF	WREG,Areg
		; AXreg = B - A
		MOVPF	Breg,AXreg
		MOVFP	Areg,WREG
		SUBWF	AXreg,F
		CLRF	AXreg+1
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVFP	EEXreg,WREG
		MOVWF	BXreg
		CLRF	BXreg+1
		CALL	Mult1616
		MOVLW	D'10'
		MOVWF	DEXreg
		CALL	Divide168
		; A * 10 + CEXreg = the final position
		MOVFP	Areg,WREG
		MULLW	D'10'
		MOVFP	PRODL,WREG
		ADDWF	CEXreg,F
		MOVFP	PRODH,WREG
		ADDWFC	CEXreg+1,F
	; Now the final step, test the sign of Pos and adjust the result
		MOVE	CEXreg,AXreg
		MOVLR	HIGH Pos
		BTFSS	Pos+1,7
		RETURN
		; Here to change sign of AXreg
		MOVLR	HIGH AXreg
		COMF	AXreg
		COMF	AXreg+1
		INCF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
		RETURN
;
; This routine performes the mixer calculations for the mixer pointed
; to by FSR1. The mixer data tables are assumed to be located in bank 3.
; The From variable contains the from channel in the lower 4 bits
; and a translation table number in the upper 4 bits. If the upper 4 bits
; are zero then no translation table is applied.
; The To channel MSB is a flag indicating the results should be
; added to the To channel (0) or replace the To channel (1).
; To channel bit 6 set indicates indirect level control and the channel is in Gp
; To channel bit 5 set indicates indirect level control and the channel is in Gn
;
Mixer
	; Get the from channel
		MOVLR	HIGH M1Afrom
		MOVFP	POSTINC1,WREG
		MOVPF	WREG,Breg
		IORWF	WREG
		BTFSC	ALUSTA,Z
		RETURN			; Not selected so exit!
		CALL	GetFrom		; From channel data in AXreg
		CALL	Translation	; Apply the Translation table
		MOVE	AXreg,CXreg
		MOVLR	HIGH M1Afrom
		MOVFP	POSTINC1,Areg	; To channel to Areg
	; Now get the Zero point in percent
		MOVLR	HIGH M1Afrom
		MOVPF	POSTINC1,WREG
		MOVLR	HIGH AXreg
		MOVPF	WREG,AXreg
		CLRF	AXreg+1
		BTFSC	AXreg,7
		COMF	AXreg+1		; Sign extend
		MOVEC	d'10',BXreg
		CALL	Mult1616
		MOVE	CXreg,AXreg
		MOVFP	CEXreg,WREG
		SUBWF	AXreg,F
		MOVFP	CEXreg+1,WREG
		SUBWFB	AXreg+1,F
	; AXreg is now = ChannelPos - Zp. Test the sign and apply the correct
	; gain factor...
		BTFSC	AXreg+1,7
		GOTO	MixNeg
		; Here if positive...
		MOVLR	HIGH M1Afrom
		MOVPF	POSTINC1,WREG
		MOVLR	HIGH AXreg
		; Test bit 6 of the To channel in Areg. If this bit is
		; set then we are going to do indirect mixing and the 
		; 4 LSBs of WREG define the channel number that is the mix level
		BTFSS	Areg,6
		GOTO	MixNoIdP
		; Here if is an indirect mix...
		MOVE	WREG,CEXreg
		MOVE	AXreg,CXreg
		MOVFP	CEXreg,WREG
		CALL	GetFrom
		MOVE	AXreg,CEXreg
		MOVLW	D'10'
		MOVWF	DEXreg
		CALL	Divide168
		MOVE	CXreg,AXreg
		MOVFP	CEXreg,WREG
MixNoIdP
		MOVWF	BXreg
		CLRF	BXreg+1
		BTFSC	BXreg,7
		COMF	BXreg+1		; Sign extend
		CALL	Mult1616
		MOVEC	D'100',DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416
		MOVE	CEXreg,AXreg
		MOVFP	Areg,WREG
		CALL	ApplyMix
		RETURN
MixNeg		; Here if negative...
		MOVLR	HIGH M1Afrom
		MOVPF	POSTINC1,WREG
		MOVPF	POSTINC1,WREG
		MOVLR	HIGH AXreg
		; Test bit 5 of the To channel in Areg. If this bit is
		; set then we are going to do indirect mixing and the 
		; 4 LSBs of WREG define the channel number that is the mix level
		BTFSS	Areg,5
		GOTO	MixNoIdN
		; Here if is an indirect mix...
		MOVPF	WREG,CEXreg
		MOVE	AXreg,CXreg
		MOVFP	CEXreg,WREG
		CALL	GetFrom
		MOVE	AXreg,CEXreg
		MOVLW	D'10'
		MOVWF	DEXreg
		CALL	Divide168
		MOVE	CXreg,AXreg
		MOVFP	CEXreg,WREG
MixNoIdN
		MOVWF	BXreg
		CLRF	BXreg+1
		BTFSC	BXreg,7
		COMF	BXreg+1		; Sign extend
		CALL	Mult1616
		MOVEC	D'100',DEXreg
		CLRF	DEXreg+2
		CLRF	DEXreg+3
		CALL	Divide2416
		MOVE	CEXreg,AXreg
		MOVFP	Areg,WREG
		CALL	ApplyMix
		RETURN

; This function will switch the aircraft parameters between
; the selected aircraft and the alternate aircraft. This 
; function is only valid in the RUN mode. Two Alternate Aircraft
; switches are supported, if both are on, the second switch takes
; precedence.
AlternateAircraft
	; Save the timer variables
		MOVEC	CNTmode,Src
		MOVEC	TempBlock,Dst
		MOVLW	5
		MOVWF	Cnt
		CALLF	BlkMove
	; Save the ALTAKF switch definitions to use 
		MOVLR	HIGH SWALT2
		MOVFP	SWALT2,Areg
		MOVFP	SWALT,Breg
		MOVLR	HIGH DXreg
		MOVPF	Areg,DXreg
		MOVPF	Breg,DXreg+1
	; Save the Alternate Aircraft numbers
		MOVEB	ALTaircraft,TAltA1
		MOVEB	ALTaircraft2,TAltA2
	; Test the ALTAFK2 switch
		MOVLR	HIGH SWALT2
		MOVFP	SWALT2,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	AAselected2
	; Test the ALTAFK switch
		MOVLR	HIGH SWALT
		MOVFP	SWALT,WREG
		CALL	SwitchTest
		BTFSC	ALUSTA,C
		GOTO	AAselected
	; Here if Alt aircraft is not selected.
	; If DefaultAircraft = Aircraft then exit
		MOVLR	HIGH Aircraft
		MOVFP	Aircraft,WREG
		MOVLR	HIGH DefaultAircraft
		CPFSEQ	DefaultAircraft
		GOTO	AAloadDefault
		RETURN
AAloadDefault
	; Load the default aircraft parameters
		MOVFP	DefaultAircraft,WREG
		MOVLR	HIGH Aircraft
		MOVWF	Aircraft
		CALL	LoadAircraft
		MOVLR	0
		RETURN
AAselected2
	; Test ALTaircraft number, if invalid then exit
		MOVLR	HIGH ALTaircraft2
		MOVLW	0
		CPFSGT	ALTaircraft2
		RETURN
		MOVLW	9
		MOVLR	HIGH EnaSecSprom
		BTFSC	EnaSecSprom,0
		MOVLW	11
		MOVLR	HIGH ALTaircraft2
		CPFSLT	ALTaircraft2
		RETURN
	; Here if Alt aircraft is selected. 
	; If Aircraft = ALTaircraft then exit
		MOVLR	HIGH ALTaircraft2
		MOVFP	ALTaircraft2,WREG
		MOVLR	HIGH Aircraft
		CPFSEQ	Aircraft
		GOTO	AAloadALT
		RETURN
AAselected
	; Test ALTaircraft number, if invalid then exit
		MOVLR	HIGH ALTaircraft
		MOVLW	0
		CPFSGT	ALTaircraft
		RETURN
		MOVLW	9
		MOVLR	HIGH EnaSecSprom
		BTFSC	EnaSecSprom,0
		MOVLW	11
		MOVLR	HIGH ALTaircraft
		CPFSLT	ALTaircraft
		RETURN
	; Here if Alt aircraft is selected. 
	; If Aircraft = ALTaircraft then exit
		MOVLR	HIGH ALTaircraft
		MOVFP	ALTaircraft,WREG
		MOVLR	HIGH Aircraft
		CPFSEQ	Aircraft
		GOTO	AAloadALT
		RETURN
AAloadALT
	; Load the alt airecraft parameters, but we need to keep the orginal
	; aircrafts timer data.
		; Load altaircraft		
		MOVLR	HIGH Aircraft
		MOVWF	Aircraft
		CALL	LoadAircraft
		; Restore the timer variables
		MOVEC	TempBlock,Src
		MOVEC	CNTmode,Dst
		MOVLW	5
		MOVWF	Cnt
		CALLF	BlkMove
		; Restore the alt aircraft switch data
		MOVLR	HIGH DXreg
		MOVFP	DXreg, Areg
		MOVFP	DXreg+1, Breg
		MOVLR	HIGH SWALT2
		MOVPF	Areg,SWALT2
		MOVPF	Breg,SWALT
		; Restore the Alternate Aircraft numbers
		MOVEB	TAltA1,ALTaircraft
		MOVEB	TAltA2,ALTaircraft2
		; exit
		MOVLR	0
		RETURN


; This function moves data from the Src to Dst. Cnt contains the number
; of bytes to move.
; Uses: Areg
;	Indirect reg set 1 used for source
;	Indirect reg set 2 used for destination
BlkMove
	; Set up the regesters
		MOVLR	HIGH Src
		MOVFP	Src,WREG
		MOVWF	FSR1L	
		MOVFP	Src+1,WREG
		MOVWF	FSR1H	

		MOVLR	HIGH Dst
		MOVFP	Dst,WREG
		MOVWF	FSR2L	
		MOVFP	Dst+1,WREG
		MOVWF	FSR2H	
	; Get source byte
BlkMove1
		TBLRD*+
		TBLWT*+
	; Loop till all are sent...
		MOVLR	HIGH Cnt
		DECFSZ	Cnt
		GOTO	BlkMove1
		RETURN

;
; This function is called to initialize the button ID byte.
;
ButtonIDinit
	; Clear the switch ID byte
		MOVLR	HIGH SWID
		CLRF	SWID
	; Do the aileron DR
		MOVLR	HIGH SWAILDR
		MOVFP	SWAILDR,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		BTFSC	ALUSTA,C
		BSF	SWID,0
	; Do the elevator DR
		MOVLR	HIGH SWELEDR
		MOVFP	SWELEDR,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		BTFSC	ALUSTA,C
		BSF	SWID,1
	; Do the rudder DR
		MOVLR	HIGH SWRUDDR
		MOVFP	SWRUDDR,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		BTFSC	ALUSTA,C
		BSF	SWID,2
	; Do the preset
		MOVLR	HIGH SWPRESET
		MOVFP	SWPRESET,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		BTFSC	ALUSTA,C
		BSF	SWID,3
	; Do the Auto Trim
		MOVLR	HIGH SWATRIM
		MOVFP	SWATRIM,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		BTFSC	ALUSTA,C
		BSF	SWID,4
	; Do the Snap R
		MOVLR	HIGH SWSNAPR
		MOVFP	SWSNAPR,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		BTFSC	ALUSTA,C
		BSF	SWID,5
	; Do the Snap L
		MOVLR	HIGH SWSNAPL
		MOVFP	SWSNAPL,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		BTFSC	ALUSTA,C
		BSF	SWID,6
	; Bye!
		RETURN
;
; This function looks at the button image ports and prints the name of the
; last change, if one has been detected. This message will be displayed for
; a few seconds.
;
ButtonID
	; Set display to line 2
		MOVLW	LINE2
		CALL	LCDsendCMD
	; Test each funcion looking for a state change
		; Aileron DR
		MOVLR	HIGH SWAILDR
		MOVFP	SWAILDR,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		CLRF	WREG
		BSF	WREG,0
		ANDWF	SWID,W
		; If carry flag is set and z flag is clear then no change
		BTFSS	ALUSTA,C
		GOTO	BID0
		BTFSS	ALUSTA,Z
		GOTO	BIDELE
		; Here with a change
		BTG	SWID,0
		PrintMess IDAILLOW
		GOTO	BIDEXIT
		; If carry flag is clear and z flag is set then no change
BID0
		BTFSC	ALUSTA,C
		GOTO	BIDELE
		BTFSC	ALUSTA,Z
		GOTO	BIDELE
		; Here with a change
		BTG	SWID,0
		PrintMess IDAILHI
		GOTO	BIDEXIT
BIDELE
		; Elevator DR
		MOVLR	HIGH SWELEDR
		MOVFP	SWELEDR,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		CLRF	WREG
		BSF	WREG,1
		ANDWF	SWID,W
		; If carry flag is set and z flag is clear then no change
		BTFSS	ALUSTA,C
		GOTO	BID1
		BTFSS	ALUSTA,Z
		GOTO	BIDRUD
		; Here with a change
		BTG	SWID,1
		PrintMess IDELELOW
		GOTO	BIDEXIT
		; If carry flag is clear and z flag is set then no change
BID1
		BTFSC	ALUSTA,C
		GOTO	BIDRUD
		BTFSC	ALUSTA,Z
		GOTO	BIDRUD
		; Here with a change
		BTG	SWID,1
		PrintMess IDELEHI
		GOTO	BIDEXIT
BIDRUD
		; Rudder DR
		MOVLR	HIGH SWRUDDR
		MOVFP	SWRUDDR,WREG
		CALL	SwitchTest
		MOVLR	HIGH SWID
		CLRF	WREG
		BSF	WREG,2
		ANDWF	SWID,W
		; If carry flag is set and z flag is clear then no change
		BTFSS	ALUSTA,C
		GOTO	BID2
		BTFSS	ALUSTA,Z
		GOTO	BIDPRESET
		; Here with a change
		BTG	SWID,2
		PrintMess IDRUDLOW
		GOTO	BIDEXIT
		; If carry flag is clear and z flag is set then no change
BID2
		BTFSC	ALUSTA,C
		GOTO	BIDPRESET
		BTFSC	ALUSTA,Z
		GOTO	BIDPRESET
		; Here with a change
		BTG	SWID,2
		PrintMess IDRUDHI
		GOTO	BIDEXIT
BIDPRESET
		; Preset
		MOVLR	HIGH SWPRESET
		MOVFP	SWPRESET,WREG
		CALL	SwitchTest
		; If carry flag is set and bit 3 is not then display message.
		MOVLR	HIGH SWID
		BTFSS	ALUSTA,C
		GOTO	BID3
		BTFSC	SWID,3
		GOTO	BIDAUTOT
		BTG	SWID,3
		PrintMess IDPRESET
		GOTO	BIDEXIT
BID3
		BCF	SWID,3
BIDAUTOT
		; Auto trim
		MOVLR	HIGH SWATRIM
		MOVFP	SWATRIM,WREG
		CALL	SwitchTest
		; If carry flag is set and bit 4 is not then display message.
		MOVLR	HIGH SWID
		BTFSS	ALUSTA,C
		GOTO	BID4
		BTFSC	SWID,4
		GOTO	BIDSNAPR
		BTG	SWID,4
		PrintMess IDAUTOT
		GOTO	BIDEXIT
BID4
		BCF	SWID,4
BIDSNAPR
		; SNAP right
		MOVLR	HIGH SWSNAPR
		MOVFP	SWSNAPR,WREG
		CALL	SwitchTest
		; If carry flag is set and bit 5 is not then display message.
		MOVLR	HIGH SWID
		BTFSS	ALUSTA,C
		GOTO	BID5
		BTFSC	SWID,5
		GOTO	BIDSNAPL
		BTG	SWID,5
		PrintMess IDSNAPR
		GOTO	BIDEXIT
BID5
		BCF	SWID,5
BIDSNAPL
		; SNAP left
		MOVLR	HIGH SWSNAPL
		MOVFP	SWSNAPL,WREG
		CALL	SwitchTest
		; If carry flag is set and bit 6 is not then display message.
		MOVLR	HIGH SWID
		BTFSS	ALUSTA,C
		GOTO	BID6
		BTFSC	SWID,6
		GOTO	BIDNEXT
		BTG	SWID,6
		PrintMess IDSNAPL
		GOTO	BIDEXIT
BID6
		BCF	SWID,6
BIDNEXT
		RETURN
BIDEXIT
		MOVLW	D'80'
		MOVWF	TimeOut5
		RETURN


;
; This function will test the switch code passed in WREG. If the
; code is true then the Carry flag is set, else its reset. Here
; is the definition of a switch code:
;   
;   7 6 5 4 3 2 1 0
;   x x x x x x x x
;   | | | | | | | +-- \
;   | | | | | | +----  > Bit position, 0 to 7
;   | | | | | +------ /
;   | | | | +-------- Port select, 0 = PORTD, 1 = PORTE
;   | | | +---------- ON  \ If both the ON and OFF bits are set then
;   | | +------------ OFF / this is a control position switch
;   | +-------------- And with next bit
;   +---------------- Invert
;
; The port data is read from the debounced data saved in regs:
;    PORTDimage
;    PORTEimage
;
; For control position mode (bits 4 and 5 set:
;   Bit codes
;      0 = aileron
;      1 = elevator
;      2 = rudder
;      3 = throttle
;   Invert bit 7 changes trigger polarity
;
SwitchTest
        ; Test if this is control position trigger flag
		BTFSS	WREG,5
		GOTO	STgo
		BTFSS	WREG,4
        	GOTO	STgo
        	; Here is bits 4 and 5 are set
        	; Load the percentage and multiply it by 10 to make it
        	; into normalized position
        	MOVWF	Areg		; Save WREG
        	ANDLW	07		; Get the selection bits
        	ADDLW	LOW ATP		; Make index to percentage
        	MOVWF	FSR1L
		MOVLW	HIGH ATP
		MOVWF	FSR1H
		MOVF	POSTINC1,WREG	; Load the percentage into Wreg
		; Multiply by 10
		MOVLR	HIGH AXreg
		MOVPF	WREG,AXreg
		CLRF	AXreg+1
		BTFSC	WREG,7
		SETF	AXreg+1		; Sign extended into AXreg
		MOVEC	D'10',BXreg
		CALL	Mult1616	; Result in CEXreg
		; Now load the position pointer
		MOVFP	Areg,WREG
		ANDLW	07
		RLNCF	WREG		; Make it into a word pointer
		ADDLW	LOW ATpos
		MOVPF	WREG,FSR1L	; Load the position pointer
		MOVLW	HIGH ATpos
		MOVF	FSR1H
		MOVPF	POSTINC1,WREG
		MOVPF	POSTINC1,Breg	; Load the position
		; Test the position
		MOVLR	HIGH CEXreg
		SUBWF	CEXreg
		MOVFP	Breg,WREG
		SUBWFB	CEXreg+1,WREG   
		RLCF	WREG
		; If the Invert bit is set then invert the carry flag
		BTFSC	Areg,7
		RETURN
		BTG	ALUSTA,C
		RETURN
	; Test the on and off bits first
STgo
		BCF	ALUSTA,C
		BTFSC	WREG,5
		RETURN
		BSF	ALUSTA,C
		BTFSC	WREG,4
		RETURN
	; Now process the swith options...
		MOVLR	HIGH Atemp
		MOVWF	Atemp		; Save WREG
		CLRF	Btemp
	; If the And with next bit is set then set the LSB of Btemp
		BTFSC	WREG,6
		BSF	Btemp,0
		ANDLW	07		; get just the 3 LSBs
		INCF	WREG
		BSF	ALUSTA,C	; Set the carry flag
ST00
		RLCF	Btemp,F
		DECFSZ	WREG
		GOTO	ST00
	; Now the proper bit is set in Btemp
		MOVFP	PORTDimage,WREG
		BTFSC	Atemp,3
		MOVFP	PORTEimage,WREG
		ANDWF	Btemp,W
		BSF	ALUSTA,C
		CPFSEQ	Btemp
		BCF	ALUSTA,C
	; Test if the invert flag is set
		BTFSC	Atemp,7
		BTG	ALUSTA,C	
		RETURN

INCLUDE		<tach.asm>
INCLUDE		<ui.asm>

;
; This function is called at startup to load a set of default parameters
; into bank 2 and bank 3.
;
LoadDefaults
	; Bank2
	; Set table pointer
		MOVLW	UPPER DFTgeneral
		MOVWF	TBLPTRU
		MOVLW	HIGH DFTgeneral
		MOVWF	TBLPTRH
		MOVLW	LOW DFTgeneral
		MOVWF	TBLPTRL
	; Load counter
		MOVLW	00
		MOVWF	Areg
	; Setup indirection regs
		MOVLW	HIGH BNK2
		MOVWF	FSR1H
		MOVLW	LOW BNK2
		MOVWF	FSR1L
LoadDefaults1
		TBLRD*+
		MOVF	TABLAT,WREG
		MOVWF	POSTINC0
		DECF	Areg
		TBLRD*+
		MOVF	TABLAT,WREG
		MOVWF	POSTINC0
		DECFSZ	Areg
		GOTO	LoadDefaults1
LoadAircraftDefaults
	; Bank3	
	; Set table pointer
		MOVLW	UPPER DFTaircraft
		MOVWF	TBLPTRU
		MOVLW	HIGH DFTaircraft
		MOVWF	TBLPTRH
		MOVLW	LOW DFTaircraft
		MOVWF	TBLPTRL
	; Setup counter
		MOVLW	00
		MOVWF	Areg
	; Setup indirection
		MOVLW	HIGH BNK3
		MOVWF	FSR1H
		MOVLW	LOW BNK3
		MOVWF	FSR1L
LoadDefaults2
		TBLRD*+
		MOVF	TABLAT,WREG
		MOVWF	POSTINC0
		DECF	Areg
		TBLRD*+
		MOVF	TABLAT,WREG
		MOVWF	POSTINC0
		DECFSZ	Areg
		RETURN

ifdef           ECMA1010display
INCLUDE         <DataS.asm>
else
INCLUDE         <data.asm>
endif

;
; The following default tables are loaded instead of the Sprom for general setup parameters
; and aircraft specific setting. These are loaded if the Preset and Auto Trim buttons are
; held down at power up. These tables also hold the default data used to format the SPROM.
;
DFTgeneral      DB 01,00,0F,00,0D2,00,00,00,03,00,0D2,00,00,00,1E,00			;200
		DB 0D2,00,00,080,012,09,02,0C8,02,0AC,01,094,01,08A,02,0D0		;210
		DB 01,0C4,01,07A,02,0F5,01,0C1,01,05,00,025,02,0E1,01,028		;220
		DB 02,0DE,01,05E,02,0B5,01,024,02,0E4,01,036,01,073,00,05F		;230
		DB 01,06F,00,00,00,08,00,01,04,09,10,19,24,31,40,51			;240
		DB 64,00,13,24,33,40,4b,54,5b,60,63,64,00,01,02,03			;250
		DB 06,0C,15,22,33,49,64,00,1b,31,42,4f,58,5e,61,62			;260
		DB 63,64,00,0A,14,1E,28,32,3C,46,50,5A,64,00,14,28			;270
		DB 3C,50,64,50,3C,28,14,00,00,05,0A,0F,14,19,28,37			;280
		DB 46,55,64,00,0F,1E,2D,3C,4B,50,55,5A,5F,64,01,0A			;290
		DB 00,00,010,090,01,0FF,00,0A5,0E7,0C0,09,0F3,00,00,0DC,05 		;2A0
		DB 094,011,01,02,03,04,02,01,03,04,05,06,07,08,00,00			;2B0
		DB 00,00,00,58,81,00,00,00,00,00,00,00,00,00,00,00			;2C0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;2D0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;2E0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;2F0

DFTaircraft     DB 4D,4F,44,45,4C,20,30,31,20,20,20,20,20,20,20,20			;300	
		DB 00,00,01,0B8,0B,00,01,03C,019,00,00,00,00,01,0B8,0B			;310
		DB 00,01,03C,019,00,00,00,00,01,0B8,0B,00,01,03C,019,00			;320
		DB 00,00,00,0FE,0A0,0F,019,01,0D0,07,00,0FE,0A0,0F,00,0FE		;330
		DB 0A0,0F,00,0FE,0A0,0F,00,01,0B8,0B,00,01,32,0FF,32,00			;340
		DB 32,00,32,00,0CE,0FF,0CE,00,0CE,00,0CE,00,00,00,00,014		;350
		DB 014,00,00,00,0A,0A,00,00,00,0A,0A,00,00,00,0A,0A			;360
		DB 00,00,0F4,01,0A,00,00,00,0A,0A,00,00,00,0A,0A,00			;370
		DB 00,00,0A,0A,00,00,00,0A,0A,00,00,00,0A,0A,00,00			;380
		DB 00,0A,0A,00,00,00,0A,0A,00,00,00,00,00,00,00,0A			;390
		DB 00,00,00,00,00,02,00,00,00,00,00,00,00,0FF,00,01			;3A0
		DB 02,083,04,05,06,07,089,08B,04B,08C,0D,08E,08F,01,00,08		;3B0
		DB 010,00,07,04B,08C,04,00,20,00,00,00,00,00,0FF,00,00			;3C0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;3D0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;3E0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;3F0


; This area is reserved to store the general and aircraft configuration data. 

		org	0x10000
	
CFGgeneral	RES	D'256'

CFGaircraft	RES	(D'256') * NumAircraft
	
                END     ;required directive


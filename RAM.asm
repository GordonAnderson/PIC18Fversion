;******* BANK0 variables
Bank0		udata_acs	0x00
;*******    INTERRUPT CONTEXT SAVE/RESTORE VARIABLES
TEMP_WREG       RES     1
TEMP_ALUSTA     RES     1
TEMP_BSR        RES     1
TEMP_PRODL      RES     1
TEMP_PRODH      RES     1
TEMP_WREG_L     RES     1
TEMP_ALUSTA_L   RES     1
TEMP_BSR_L      RES     1
TEMP_PRODL_L    RES     1
TEMP_PRODH_L    RES     1
Areg		RES	1	; General purpose registers
Breg		RES	1
Creg		RES	1
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
FSR1Lsave	RES	1
FSR1Hsave	RES	1
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
CycleCounts	RES	2	; D'2000000'/TICKSPER, The number of timer counts in one frame

;
; The following array holds the channel times for the PPM signal.
; One 16 bit word for each channel,8 channels plus one checksum channel 
CHtimes		RES	2	; First word is for sync
chELE		RES	2
chAIL		RES	2
chRUD		RES	2
chTHT		RES	2
chCH5		RES	2
chCH6		RES	2
chCH7		RES	2
chCH8		RES	2
		RES	2	; Checksum channel
;

Pstate		RES	1	; State variable
NumChan		RES	1	; Number of transmit channels times two
NextTime	RES	2	; The timers next compare reg value
Psum		RES	2	; Total pulse time from start of output
Sync		RES	2	; Sync pulse width.
; The following variables are involved in time keeping
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
Bank0a		udata	0x060
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
; Actual output position information for the channels that have slew rate control
CH5posActual	RES	2
CH8posActual	RES	2
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
; In many cases there are multiple variable names for the same
; physical memory, basicaly overloading. 
Ctemp		RES	1
Dtemp		RES	1
Etemp		RES	1
Ftemp		RES	1
TimeOut3	RES	1	; This timeer is used by the sync up function
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
; Do not move or reorder this block, used for servo position editing
RTDWN		RES	2
CENTER		RES	2
LTUP		RES	2
DRP		RES	1
TRIMP		RES	1
ATRM		RES	1
EXPOHI		RES	1
EXPOLOW		RES	1
; End of fixed block
YESNO		RES	1
STRIM
ServoREV			; This is a word flag used by the servo reverse logic
; Temp variables used by Mixer and servo UI reoutines
Mfrom		RES	1
Mto		RES	1
ATRST
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
FMSflag		RES	1	; Flag set when in the FMS flight simulator mode, UART2
FMSflagU1	RES	1	; Flag set when in the FMS flight simulator mode. UART1

PostCall	RES	2	; Pointer to a post call function used by the UI functions
PreCall		RES	2	; Pointer to a pre call function used by the UI functions
FutabaStudent	RES	1	; This flag is set when in the Futaba student mode and the
				; the student button is pressed.
CalServoUpdate	RES	1	; The flag CalServoUpdate must be set or this function will
				; exit with no action.
IncTime		RES	1	; This value hold the number of ADC counts over threshold for 
				; use in the variable value increment time
PIC18F8723	RES	1	; Flag set if 8723 PIC is detected
; These variables were added in December 2009 to improve the debounce logic on the Option 
; button
PORTDlatchLow	RES	1
PORTElatchLow	RES	1

; The following variables are only used in helicopter mode.
GyroTune	RES	1	; This is a flag used in the helicopter mode to enable
				; the gyro sensitivity adjust mode. This flag is reset on 
				; powerup
; Actual output position information for the throttle channel, used only in helicopter
; mode.
TposActual	RES	2
TholdState	RES	1	; Flag used to save throttle hold switch state, needed of slew 
				; rate control when flight mode is selected.
TMR4intNum	RES	1	; Counter used by the timer 4 interrupt




;******* BANK1 variables
Bank1		udata	0x100
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

; Temporary storage for FSR1 reg set
SaveFSR1L	RES	1
SaveFSR1H	RES	1

Units		RES	1		; Used to store units character for UI routines
LCDwreg		RES	1		; temp storage for the WREG in the LCD routine

; Digital trim working variables
DTdataAil	RES	2
DTdataEle	RES	2
DTdataRud	RES	2
DTdataTht	RES	2

DTdisplay	RES	1		; Display flag
; Last trim normalized positions for A,E, and R. Used for center beep
; logic
AtrimLast	RES	2
EtrimLast	RES	2
RtrimLast	RES	2
TtrimLast	RES	2
CH6Last		RES	2
CH7Last		RES	2
TrimBeepSignChange	RES	1
; This is a version number variable used to provide PC application compatability
Version		RES	3		; Format is ASCII, X.YZ for example 2,0,i
RecVADC		RES	2		; Contains the receiver voltage monitor raw ADC
					; values. Used by PC application
MonFlag		RES	1		; Flag set if in the channel monitor mode.
					; 0 = flag is clear
					; 1 = Servo position monitor mode
					; 2 = Auto trim monitor mode
MonChan		RES	1		; Monitor channel number

LCDcgFlag	RES	1		; This flag is set when a character generator
					; address commend is given to the LCD display.
					; This is used by the MicroProStar LCD drivers.
ActiveDisplayLine RES	1		; This variable defines the active display line, 
					; used in MPS mode.
ADCsum		RES	3		; This variable holds the summed ADC value from 
					; ADCread256 function.
; The following variables are used to save the contents of shared registers in the
; MPS ADC routine
AXregSave	RES	2
BXregSave	RES	2
CEXregSave	RES	4

; transmitter voltage display filter accumunation register
Vbat256		RES	3


;******* BANK2 variables
; 
; This area contains general setup parameters. This area is read from
; the serial prom on power up and these parameters apply to all aircraft.
; These parameters can not be reordered!
;
Bank2		udata	0x200
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
		RES	1	
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
; The same registers define the digitial trims. The codes are as follows:
;	16 = Ail trim
;	32 = Ele trim
;	48 = Rud trim
;	64 = Tht trim
AilTrimCh	RES	1
EleTrimCh	RES	1
RudTrimCh	RES	1
ThtTrimCh	RES	1   

ATmode          RES     1       ; Auto trim mode, 0 = incremental, 1 = one shot
MasterMode	RES	1	; Master mode, 0 = MicroStar, 1 = Futaba

BTflag		RES	1	; This flag is set when its time to update the
				; battery timer value
BattAlarm	RES	1	; Battery alarm voltage level in .1 volt units
AUXMODE		RES	1	; Defines the channel to output on the
				; AUXOUT pin used for direct servo drive.
				; Setting the MSB defines the output to be
				; the encoded pulse train. To output a channel
				; set this variable to the channel number times
				; 2 plus 1.
; This is the ADC address table. This table is 16 bytes long and each byte selects
; the ADC multiplexer address and the ADC refrence. The reference is selected by the MSB 
; of each entery, 0 = external ref and 1 = 5 volt ref
ADCaddTbl		RES	16

; This is a flag byte used to define the frequency band for the RF deck. 
; Bit definitions:
;	Bit		Definition
;	0		Set for 50 MHz
;	1		Set for 53 MHz
; If both bits 0 and 1 are set then the 72 MHz band is selected
Fband			RES	1
; Buzzer polarity
BuzPol			RES	1	; 0 = normal sense, 0xFF = inverted
; Trim Center Beep flag, this is for A,E, and R trims only
TrimCenterBeepFlag	RES	1	; 0 = off, no beep, 0xFF = on, beep on center cross
; The following variables are used for the generation of the
; PPM output pulse train. All times are in .5uS units, 2MHz
; internal clock used by timer. Timer3 is used for this pulse
; generation.
TicksPer		RES	1	; Ticks per second, default = 40
FrameDefect		RES	1	; Frame time defect, allows the pilot to enter a frame time error
					; theu making the frame time unique to this transmitter
SerialSend		RES	1	; This flag is set to cause the ppm data to be send using USART 
					; port 2. The data is sent at full resolution.
; Trim Center Beep flag for throttle trim and channels 6&7
ThtTCenterBeepFlag	RES	1	; 0 = off, no beep, 0xFF = on, beep on center cross
CH67CenterBeepFlag	RES	1	; 0 = off, no beep, 0xFF = on, beep on center cross
; This variable is used to define the digital trim update rate when the trim button is held down
DTrimAdjustDelay	RES	1
; Display mode for the MPS
DisplayMode		RES	1	; Two modes are supported:
					; 0  = Altenate mode
					; 0FF = Auto Trim select display line
DisplayLine		RES	1	; Indicates the line to display
					; 0   = line 1
					; 0FF = line 2
ADCfixThres		RES	1	; This is the ADC stability threshold used for the MPS
					; to remove glitching due to power pulses from the RF deck.
Gversion		RES	3	; Format is ASCII, X.YZ for example 2,0,i
ATthreshold		RES	1	; Auto Trim stick position threshold
DOGcontrast		RES	1	; Contrast setting for DOG display

;******* BANK3 variables 
;
; This area contains aircraft specific setup parameters. The serial
; prom contains 8 total setup, the selected aircraft's parameters are
; copied into this block. These parameters can not be reordered!
;
Bank3		udata	0x300
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
FPgainN		RES	1	; Amount of flaps, negative gain
DIFFA		RES	1	; Percentage of differential, 0 = off
FPgain		RES	1	; Amount of flaps, positive gain
		RES	2	; Reserved to preserve alignment
IDLEUP		RES	1	; Idle up flag, FF = On
IDLEUPpA	RES	1	; Idle up percentage A
IDLEUPpB	RES	1	; Idle up percentage B
		RES	1	
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
		RES	1
SWSNAPR		RES	1
SWSNAPL		RES	1 

; Timer variables...
CNTmode		RES	1	; 0 = On time only, 1 = DWN timer
DWNSecs		RES	1
DWNMins		RES	1
TEnaSW		RES	1	; Switch used to enable timer
Tthres		RES	1	; Throttle threshold for timer

; More switch selections
		RES	1	; Reserved to preserve alignment
SWIDLEUP1	RES	1
SWIDLEUP2	RES	1

; Additions for the CROW function
SWCROW          RES     1       ; The Crow switch, by default is Mixer 1 switch
CROWENA         RES     1       ; Flag set if CROW is enabled.

		RES	1	
		RES	1	

; Control stick trigger positions
ATP		RES	1
ETP		RES	1
RTP		RES	1
TTP		RES	1

SHIFT		RES	1	; Set to FF for ACE shift

; Alternate aircraft array, 6 entries, each entry is:
;   First byte =  Switch ID
;   Second byte = Aircraft number
NumAlt		EQU	6
AltAircraft	RES	2 * 6

; Aircraft specific translation tables
Atable1		RES	D'11'
Atable2		RES	D'11'

;******* BANK4 variables 
;
; This page holds the second 256 byte page of the aircraft specific memory
;
Bank4		udata	0x400
; Output order. This table defines the output channel order. The user can
; configure any order he likes. You can even repeat the same channel if
; required for your application
ChannelOrder	RES	8
; The following table supports subtrims. This allows the pilot to set the servo 
; center position of any cannel independently
SubTrim		RES	8
; The following variables support additional fixed mixers that are commonly 
; used by pilots
;			- Ail to rudder, 2 bytes
;			- Rud to ail, 2 bytes
;			- Rud to ele, 2 bytes
;			- Throttle to ele, 1 byte
;			- Dual elevator, 2 bytes
AilRudPos	RES	1
AilRudNeg	RES	1

RudAilPos	RES	1
RudAilNeg	RES	1

RudElePos	RES	1
RudEleNeg	RES	1

ThtEle		RES	1

DualE		RES	1	; Flag, 0=off, FF=on
		RES	1	
		
; Slew rate limits servo speed control
CH5stepSize	RES	2
CH8stepSize	RES	2

; Helicopter CCPM mixing flag
; 	0 = off
; 	1 = 3 servos 120 degrees
; 	2 = 3 servos 140 degrees
; 	3 = 3 servos 90 degrees
CCPMmode	RES	1

; Digitial trim values, these variables save an aircraft specific copy of the digital
; trim values. The working values are saved in EEPROM and these are updated when
; the aircraft is saved.
DTailA		RES	2
DTeleA		RES	2
DTrudA		RES	2
DTthtA		RES	2

;
; The following variables are used for the Helicopter modes.
; CH6 is used for pitch control
; CH5 outputs gyro sensitivity, When the GyroTune mode is active then CH7
; defines the gyro sensitivity on CH5 output and pressing the option button
; will save the position in the proper variable.
; CH6 control is used for pitch trim
; 3 flight modes and throttle hold mode is supported
;
Henable		RES	1	; Non zero value enables the helicopter mode
Tnorm		RES	2	; This value contains the throttle normalized position before
				; Any trims are applied. This is needed for trim speration from
				; the pitch control. CH6 control is used for pitch trim adjust
HPrev		RES	1	; Pitch reverse flag
; Normal mode parameters:
HSen		RES	1	; Gyro sensitivity, output on CH5
HTht		RES	1	; Table for throttle curve
HPitch		RES	1	; Table of pitch curve
SWIDLEUPN	RES	1	; Idle up switch for normal mode
IdleUpNorm	RES	1	; Idle up throttle position
; Throttle hold parameters:
SWTHOLD		RES	1	; Switch to activate throttle hold mode
THOLDp		RES	1	; Throttle hold percentage
HthtSen		RES	1	; Gyro sensitivity, output on CH5
HthtPitch	RES	1	; Table of pitch curve
; Stunt mode 1 parameters:
SWSTUNT1	RES	1	; Switch to activate stunt mode 1
Hst1Sen		RES	1	; Gyro sensitivity, output on CH5
Hst1Tht		RES	1	; Table for throttle curve
Hst1Pitch	RES	1	; Table of pitch curve
SWIDLEUPST1	RES	1	; Idle up switch for stunt mode 1
IdleUpST1	RES	1	; Idle up throttle position
; Stunt mode 2 parameters:
SWSTUNT2	RES	1	; Switch to activate stunt mode 2
Hst2Sen		RES	1	; Gyro sensitivity, output on CH5
Hst2Tht		RES	1	; Table for throttle curve
Hst2Pitch	RES	1	; Table of pitch curve
SWIDLEUPST2	RES	1	; Idle up switch for stunt mode 2
IdleUpST2	RES	1	; Idle up throttle position

; Throttle hold slew rate control valiables
TstepSize	RES	2	; Servo motion step size for each tick. This is set via the 
				; helicopter function when the throttle hold mode is changed.
TtransistionT	RES	2	; Throttle hold transistion time. This is user programmed.

; Analog control remap tables
AILremap	RES	1
ELEremap	RES	1
RUDremap	RES	1
THTremap	RES	1
CH6remap	RES	1
CH7remap	RES	1

MaxChannels	RES	1	; Number of transmit channels

; Helicopter CCPM reversal flags
HArev		RES	1	; Aileron reversal
HErev		RES	1	; Elevator reversal

Debug		RES	2

;******* BANK5 variables 
;
; This area is backed up in EEPROM memory
;
Bank5		udata	0x500
BatteryTimer	RES	2	; This variable holds the total "on" time of the
				; transmitter. This value is saved in the EEPROM.
; System cofiguration Options
Adapter		RES	1	; This flag is set for the Adapter mode
Dog162		RES	1	; This flag is set for the DOG 162 display

Bank5a		udata	0x580	; Save space for more config flags
; These are the digital trim working variables. These values are uppdated when the aircraft 
; is saved/changed. These are the variables that save the active trim settings
DTail		RES	2
DTele		RES	2
DTrud		RES	2
DTtht		RES	2

; This buffer if used for the apply to all aircraft option
BlkBuf		RES	D'64'

;
; This page holds a copy of the primary aircraft setup variables. This data is used by
; the alternate aircraft function. The switch data held in this area is used to contol
; the selection.
;
Bank6		udata	0x600
Backup		RES	D'256'

;
; This page holds the second backup 256 byte page of aircraft setup variables.
;
Bank7		udata	0x700

;
; This page is used for the save aircraft name function
;
Bank8		udata	0x800

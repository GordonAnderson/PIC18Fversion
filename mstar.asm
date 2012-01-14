;**********************************************************************
;                                                                     *
;**********************************************************************
;  
;    Filename: MStar.asm 
; 
;    Author:  Gordon Anderson
;    Company: GAA Custom Electronics
;
;    The MicroStar 2000 is a model airplane encoder. An encoder reads
;    the joy stick pots and the switches and generates the modulation
;    signal sent to the RF deck, the other significant part of a
;    transmitter.
;
;    This project started in 2000 with the first software release in January
;    of 2001.
;
;    The PIC processor has several pages or banks of ram. Each is 256
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
;          configuration area of flash memory.
;    Bank3 and Bank4:
;          These banks contain the aircraft specific data. These 
;          parameters are read from the flash memory on powerup or when
;	   a new aircraft configuration is selected.
;    Bank5:
;          This bank holds a working copy of all EEprom parameters.
;    Bank6 and Bank7:
;	   These banks are used to hold the aircraft specfic data used when
;          alternate aircraaft mode.
;    Bank8:
;          This bank is used for the aircraft name function.
;
;
;    Flash memory
;	The flash memory is used to store general parameters and aircraft specific
;	setup parameters. 256 bytes are used for general parameters, This
;	is the size of bank 2 and all general parameters are in bank 2.
;	512 bytes are also used for each of the 96 aircraft setups that 
;	can be saved in the flash. The aircraft setting are saved in banks
;	3 and 4. On powerup the general parameters are loaded then the aircraft
;	specified is loaded.
;       This flash memory is the same memory used to hold the MicroStar PIC application
;       code.
;
;    Startup options:
;
;       Press OPTION + PRESET   = Start the IO test routine
;       Press PRESET + AUTOTRIM = bypass sprom load and load from
;                                 default table. This is designed 
;                                 for initial startup with a new sprom.
;	Press OPTION		= Servo output position monitor mode.
;	Press AUTO TRIM		= Auto trim position monitor mode.
;
; BUG report:
;
; Revision History:
;	All of the version 1.0 revesions were for the orginal Encoder design that had
;	a final hardware revision of 3.0. Versions 2.0 are all designed for the hardware
;	revision 4.0 and beyond. This revision uses the PIC 18F8722 PIC. The orginal 
;	encoder used a 17C766 PIC and the version 2.0 series is not compatable with that
;	PIC.
;
;	Version 1.0b
;		First release, Jan 2001
;	Version 1.0c
;		Fixed a few minor bugs and finished the dual SPROM
;		support
;       Version 1.0d, Jan 28, 2001
;               Fixed a timming bug in the SPROM read function.
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
;
;	Version 2.0a, December 2006.
;		1.) Move channel order to aircraft memory area
;		2.) Auto Trim range increase to +- 20 percent
;		3.) Use preset button as an exit from UI
;		4.) Move tables to Aircraft area (2 tables added, 22 bytes)
;		5.) Add fixed mixers (12 bytes total)
;			- Ail to rudder, 2 bytes
;			- Rud to ail, 2 bytes
;			- Rud to ele, 2 bytes
;			- Throttle to ele, 1 byte
;			- Dual elevator, 2 bytes
;		6.) Add sub trims, 8 bytes
;		7.) Fix the format flash functions to sync with ppm signal output
;		8.) Change invert function to say, positive/negative
;	Version 2.0b, January 2007
;		1.) Fixed bug with both LEDs
;		2.) Fixed bug in transmitter voltage adjust
;		3.) Fixed bug in throttle servo position set
;		4.) Added the Adapter assembley switch
;	Version 2.0c, March 2007
;		1.) Fixed bug in copy aircraft, limited aircraft number to 8.
;		2.) Added the frequency band selection menu options to replance jumpers,
;	Version 2.0d, April 8 2007
;		1.) Alternate aircraft number problem. 0 is allowed, look at copy 
;		    function as well. Fixed copy bug, 0 is OK in alt aircraft define
;		    zero disables function
;		2.) Power up student mode throttle adjust lockup, added clear to TTflag
;		    on powerup
;		3.) Elevon bug, aileron channel is dead
;		4.) VTAIL bug, rudder is dead
;		5.) For elevaon and vtail remove the code to divide throws in half
;	Version 2.0e
;		1.) Added variable rate to mS change function
;		2.) Fixed subtrim bug, they were not working at all due to indirect reg being
;		    overwritten
;		3.) Bug with the on time counter, in process need to add init to format function
;		4.) Fixed ADC reference problems
;		5.) Test auto trims
;		6.) Changed channel 5,6,7, and 8 to be -1000 to 1000 range. This makes mixing
;		     better and allows the end points adjustments to work on dual A and E.
;	Version 2.0e2, Feb 3, 2008
;		1.) Fix a bug with the joystick center determination function. It was before the 
;		    configuration parameters were read causing a bug when the ref is changed to 
;		    5 volts.
;	Version 2.0e3, March 16 2008
;		1.) Added an option to invert the buzzer polarity. This is to allow a vibrator to
;		    be used in place of the buzzer on the rev 4.0 encoder.
;	Version 2.0f, July 13 2008
;		1.) change snap buttons to allow sticks to still function, A,E,R only.
;		2.) Fixed bug in the throttle stick timer enable.
;		3.) Auto trim bugs, no errors found.
;		4.) Fix the slew speed.
;		5.) Fixed bug in the stick position switch function.
;		6.) Added stick speed control to select aircraft and percentage.
;		7.) Add message to indicate you are in student mode.
;		8.) Beep when the trims are set to zero.
;		9.) Added servo slew rate control to channel 5 and 8.
;		10.) Allow the user to select the RF deck ref osc frequency.
;		11.) Allow adjustment of the framming rate and frame time defect.
;		12.) Added the configureation option to EEPROM. This allows the firmware
;		     modes to be selected via flags and only one set of firmware is needed.
;	Version 2.0g, August 2 2008
;		1.) Added the CCPM mixing.
;		2.) Fixed init bug on servo rates.
;		3.) Added port B to the TEST IO mode 2nd line.
;		4.) Added hysistress to trim beep.
;		5.) Added digital trims.
;		6.) Fixed FMS simulator bug.
;		7.) Added Serial send mode, USART2 38400 baud.
;		8.) Fixed trim center beep bug.
;	Version 2.0h, October 11, 2008
;		1.) Fixed a bug that caused the transmitter to lockup when the tach was 
;		    pluged in.
;	Version 2.0i, December 6, 2008
;		1.) Add servo reversing function.
;			- Add the reverse option to each servo's set of options
;			- Do this by looking and the sign of the channels gain, positive gain 
;			  indicates non reversed channel.
;		2.) Add center beep option for throttle trim and CH6 and CH7
;		3.) Fixed the DOG display bugs in the digial trim display
;		4.) Fixed a center beep bug on the digitial trims
;		5.) Upgrade to the 12bit ADC pic, The Encoder will now auto detect CPU.
;		6.) Added function to allow user to adjust digital trim update rate
;		7.) Added clear all sub trims function.
;	Version 2.0j, December 25 2008
;		1.) Copied the ADC normalized position data to bank 8 for the PC interface.
;		2.) Read the receiver voltage raw ADC values in cal mode for PC interface
;		3.) Add a servo position monitor function. Press and hold option button
;		    on power up to enter this mode.
;	Version 2.0k, May 3, 2009
;		1.) Changed the order of calls in the run and cal mode, moved the slew rate
;		    function before the sub trims.
;		2.) Changed the mix functions to use the slewrate limited values for CH8 and
;		    CH5.
;		3.) Added FMS on UART 1 or UART 2, June 12, 2009
;	Version 2.0l, November 2009
;		1.) Fixed bugs in the futaba buddy box modes
;		2.) Addded a delay between channels on the MicroStar buddybox mode to 
;		    allow UARTs to sync up when the osc freq is a little different.
;	Version 2.0m, November 29 2009
;		1.) Fixed a rounding problem with the servo calibration routines
;		2.) Improved the OPTION button debouncing logic
;	Version 2.0n, January 11, 2010
;		This version has significant updates to the helicopter mode thanks to
;		input from Jack Dice.
;		1.) Added a helicopter mode enable
;		2.) Use CH8 switch as flight modes, A=Normal, B=Stunt 1, C= Stunt 2.
;		    Normal is really defined by no other mode being active.
;		3.) Treat Throttle Hold as a 4th flight mode that overrides other modes
;		4.) Use a table for Throttle, definable in each mode
;		5.) Use a table for Pitch, definable in each mode
;		6.) Use CH6 control as pitch trim and seperate from throttle
;		7.) Each mode provides gyro sensitivity constant but programable output,
;		    this signal is output on CH5
;		8.) Added helicopter option to main cal menu to adjust parameters
;		9.) Added flight mode display to helicopter mode
;		10.) fixed an error in the CH8 servo monitor display, A and C were
;		     reversed.
;		11.) Fixed the tables to support negative values.
;		12.) Fixed a minor display bug in the servo monitor function
;		13.) Added the gyro tune sensitivity adjust mode
;		14.) Expanded the servo monitor to include output pulse width data as well.
;		15.) Fixed a bug in the mixers when a slew rate controlled channel is
;		     mixed to itself.
;		16.) Initial restructuring of the code for the MicroProStar and addition
;		     of the drivers. First release of the MicroProStar.
;		17.) The default for the throttle servo range was in the reverse direction, 
;                    I fliped it in this release.
;		18.) The MicroStar buddybox mode had a baudrate error.
;		19.) Updated the AUXOUT logic so that shift invert will change the PPM
;		     signal as it does the RF deck modulation pin.
;	Version 2.0o, August 1, 2010
;		1.) Fixed a table numeric range bug, a rare issue that only happen at
;		    extreme stick and trim limits.
;		2.) Added remap function and table to Advanced menu.
;		3.) Added displays modes to the MPS.
;		4.) Move number of channels to aircraft memory area.
;		5.) Decreased the stick sensitivity for the Auto Trim function.
;		6.) Fixed a very minor bug on the tables.
;		7.) Fixed the init routine and stop sending the initial PPM pulse train.
;		8.) Fixed SNAPL to work like SNAPR, so that controls influence the positions.
;		9.) Change default servo limits and position to 900 and 2100 for the system 
;		    maximums and 1100 and 1900 for the servo starting points
;		10.) Added a new ADC read mode for the MPS. This mode reads the joystick using 
;		     the 5 volt ref and does battery voltage correct as well as insuring that
;		     the battery supply is stable.
;		11.) Fixed a mixer programming bug caused by the CalServoUpdate flag not being 
;		     cleared on power up.
;		12.) Add canned output order, ACE = EART5678, Futaba = AETR5678, 
;		     Airtronics = EATR5678, JR = TAER5678
;		13.) Make the ADC test mode display in decimal.
;		14.) Added the version number to the general data storage area.
;		15.) Added threshold adjustment to Auto Trim stick positions. 6/19/10
;		16.) Test the throttle adjust function and make sure its OK. Tested OK
;		17.) Added auto trim disable option
;		18.) Format flash bug in UI, when slect no it reloaded all settings.
;		19.) MPS format flash display bug
;		20.) Changed MPS display default to alternate
;	Version 2.0p, December 2010
;		1.) Allow user to define PPM logic level of AUXOUT
;		2.) Add Move Mix function, also ask to clear the mixer we moved from.
;		3.) Add Apply to all option on a number of global functions, channel order
;		4.) Add a filter to the battery voltage monitor. Use a difference equation
;		    Vbat * N = Vbat(t-1) * (N - 1) + Vbat(t). Where N = filter time constant.
;		    This filter is scalled by 256 to prevent round off errors.
;		5.) Add a servo monitor display of position in percentage to allow transfer to
;		    mixer gain. Change all labels to three chars and add % to display.
;		6.) Fixed a bug on the mixers that only happens on throttle, CH5, or CH8 when
;		    mixed to itself.
;		7.) DOG-M contrast adjustment to the system setup menu.
;		8.) Initalized DriveCh when not used
;	Version 2.0q, January 2011
;		1.) Fixed the DOG contrast adjust function, it actually has 64 levels. I expanded
;		    the range a bit.
;		2.) Fixed a rounding issue on throttle servo end point adjustment.
;		3.) Fixed a bug introduced in 2.0p that killed the servo position update in
;		    the servo setup routine.
;	Version 2.0r, Februray 2011
;		1.) Fixed a bug in entering table position using the transmitter UI.
;		2.) Fixed a bug that caused the auto trim value to be reset when the servo
;		    cal menu is entered.
;	Version 2.0s, June 2011, in progress
;		1.) Added CCPM reverse options for Ail and Ele
;		2.) Added display monitor for auto trim position. Hold the auto trim button down
;		    on power up to enter the auto trim monitor mode.
;		3.) Fixed a strange fixed mixer bug with the Rud to Ele mixer only when negative
;		    gains are used. 12/19/2011
;		4.) Fixed the mstar.asm file to define the config blocks using cblock
;		5.) Fixed a bug in the send serial data mode that messed up the data and baud rate
;
;	Version 2.0x, to do list
;		A.) Make the display interface work in 4 bit mode. Use 2 of the freed bits for
;		    display control. One for display mode, and the other to advance sub mode.
;		B.) Fix the retract warning to work even without my RF deck and hold off the
;		    modulation signal.
;		C.) Look into a minor display bug in the channel order options. The UI does
;		    reflect the currently select channel order.
;		D.) Add the ability to control the servo positions from the PC
;	    	    application. Also add an API so a user can control with his own
;	    	    application.
;		1.) Add more aircraft specific tables, 7 total. Can't have more than 7
;		    aircraft tables. here is what needs to be done for this change:
;			a.) Move the aircraft tables to the end of page 4 in the aircraft setup area.
;			    reserve the old space so we don't have to adjust pointers.
;			b.) Add the 5 additional entries in the data.asm file
;			c.) Edit the PC app to support the new tables and set defaults
;			d.) Test this function
;		2.) and i just remembered another thing i don't find so user friendly:  
;		    whenever i need to adjust something in one of the alternate aircraft 
;		    memories i have to first call up and select that memory.  with the new 
;		    version's 6 alternates this could turn into a real nighmare.  could it 
;		    be changed so that whenever you switch to CAL mode you're automatically 
;		    in the menu of whatever memory was currently being used and displayed on 
;		    the LCD when the switch was hit?
;		3.) Allow no confirm of RF at startup. Do this by adding a EEPROM config function
;		    to the bootloader. Allow the following types of functions or at least consider
;		    these functions:
;			a.) The no RF confirm option
;			b.) Oversampling
;		4.) Trims carries across alternate aircraft. This should be optional and
;		    selectable trim by trim
;		5.) Additional channels for generated channels
;		6.) Have the transmitter broadcast the position information during adjustment
;		    of the table values.
;		7.) Digitial trim issues
;			- The system doesn't seem to save to the *.CFG file the actual position
;			  of digital trims, and then, when loading the file using another MS2K
;			  radio, they are lost.;
;			-When I set up an alternative aircraft and it happens to need a
;			 different trim position than the master has, that is, when I need
;			 different flight phases with different trimmings, digital trims do not
;			 act independently, but on all the phases at once.
;		8.) Allow auto trim to automatically go to trim zero thus more total range and
;		    no need to go to cal menus.
;		9.) Smooth transistion and timed when changing modes using alternate aircraft.
;		10.) Add a new mixer that allows you to define an output channel via writing
;		     an equation. This should also support "if" logic.
;		11.) Simplify the alternate aircraft setup options.
;		12.) Look at the CROW function and update it as per the MP8000
;		13.) Add switch functions to CH6 and CH7
;
; Bugs and problems reported:
;	1.) Reported by Jack Dice 3/7/2009
;		It takes three models to define this glider, a main definition and two alternate 
;		A/C's, Both alt A/C's are operated by the ch8 switch, one on posA, the other on 
;		posC. I needed to change the elev trim on the Alt A/C in posA so I went to cal, 
;		selected the model of the alt a/c of interest and made a change to the elevator 
;		sub-trim. I backed out of that menu and then went to "select A/C" to get back to 
;		the main model definition.  When I returned to "run" the alt A/C definitions were 
;		dead, ie moving the ch8 switch did nothing, no A indication in the display 
;		(although only one of the alt A/c's show up as an A on the display) and no change 
;		in the airplane's control settings. The solution to the problem was to turn the 
;		transmitter off and then back on again, after which everything worked as expected. 
;		I would have thought the system would not require a re-boot after making changes 
;		to the alt A/C models but maybe that is the way it works!
;	2.) Jon Crick requests, feb 20, 2010
;	    	-How about a menu scroll slow-down when holding the Auto-trim or Preset button?
;    		-Holding a digital trim for two seconds or longer increments at a faster rate.
;	
; MicroProStar bugs and requests:
;	1.) From danny Miller, 3/6/2011
;		- Buzzer is on for 1 to 2 secs on power up, this is random.
;		- Allow the display line alternate time delay to be adjusted.
;
; Upgrade ideas (many of these are user ideas, some I will implement some I will not.)
;	1.) New trainer mode where the master can influence the student...
;	2.) Programmable delay when switching between flight configurations.
;       3.) it would be nice that when entering cal mode you were in the programming menus 
;	    for the model#  that appeared on the display when you hit the switch.  as it is 
;	    (or was as i haven't played with this on ver.2) you can be on one of the alts, 
;	    hit the cal switch and you'll be editing the master and not the alt.  only way 
;	    to edit the alt is to select that specific memory and then cal...can be almost 
;	    as confusing as what i just wrote and now we've got 6 alts instead of just two. 
;
; Rev 6.0 notes / needs
;	1.) Reserve the A19 signal for use as a USB / RS232 selection signal.
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

	list      p=18F8722, f=INHX32   ; list directive to define processor
	#include <P18F8722.INC>         ; processor specific variable definitions
	errorlevel 2
	
;	CONFIG   OSC = HS,BOR = ON,PWRT = OFF,WDT = OFF,MODE = MC,OSCS = ON,DEBUG = OFF
;
; Configuration register values
;	300001 = 02
;	300002 = 1F
;	300003 = 1E
;	300004 = F3
;	300005 = 83
;	300006 = 81
;	300008 = FF
;	300009 = C0
;	30000A = FF
;	30000B = E0
;	30000C = FF
;	30000D = 40

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
;
 #define		LCD52display
; #define		SED1230display
; #define		ECMA1010display

;
#define OPTION_BUTTON PORTE,OPTION
;#define OPTION_BUTTON PORTH,RECCOMM

; Language option
; #define			Catalan

; #define		MicroProStar
;
; Misc options
; #define		CountOn		; Turns on timer on powerup
; #define		TestADChex	; Causes the TestIO mode to display ADC values in hex
; #define		NOTACHENA	; Causes the tach function to be disabled regardless of the
					; enable line status
;
;******************************************************************************
;******************************************************************************
;******************************************************************************

	Include <Constants.asm>
	Include	<RAM.asm>
	Include	<Macros.asm>
	
ResetEntry      code    	0x0000 + OFFSET
                goto   start


;************   High Priority INTERRUPT VECTOR
HPinterrupt     code    	0x0008 + OFFSET
		goto		HIGHISRS

;************   Low Priority INTERRUPT VECTOR
LPinterrupt     code		0x0018 + OFFSET
		goto		LOWISRS


; High priority interrupt handeler
HIGHISRS
           	PUSHREGS              		;save specific registers
        ; Test if this is a hardware interrupt 1. This is used for the tach and 
        ; the futaba trainer system
        	BTFSS	INTCON3,INT1IP,A	; If INT1 is set to low priority then do not test
        	GOTO	HIGHISRS0		; if its active
        	BTFSC	INTCON3,INT1IF,A
        	CALL	INT1ISR
	; Test if this is a timer3 interrupt, compare reg 2
HIGHISRS0   	BTFSS	IPR2,CCP2IP,A		; If Timer3 is set to low priority then do not test
        	GOTO	HIGHISRS1		; if its active
		BTFSC	PIR2,CCP2IF,A
		CALL	TIMER3ISR
	; Exit
HIGHISRS1   	POPREGS               		;restore specific registers
            	retfie            		;return from interrupt
               
; Low priority interrupt handeler
LOWISRS
            	PUSHREGSLOW            		;save specific registers
        ; Test if this is a hardware interrupt 1. This is used for the tach and 
        ; the futaba trainer system
        	BTFSC	INTCON3,INT1IP,A	; If INT1 is set to high priority then do not test
        	GOTO	LOWISRS0		; if its active
        	BTFSC	INTCON3,INT1IF,A
        	CALL	INT1ISR
	; Test if this is a timer3 interrupt
LOWISRS0    	BTFSC	IPR2,CCP2IP,A		; If Timer3 is set to high priority then do not test
        	GOTO	LOWISRS1		; if its active
		BTFSC	PIR2,CCP2IF,A
		CALL	TIMER3ISR
	; Test for COMM port interrupts, call service routine if active
LOWISRS1	
	; If Timer3 ISR is low priority then don't call the USART functions.
	; Read the USARTS and exit.
		BTFSC	IPR2,CCP2IP,A
		GOTO	LOWISR2
		MOVFF	RCREG1,WREG
		MOVFF	RCREG2,WREG
		GOTO	LOWISR3
	; Here to process the USARTS
LOWISR2
		BTFSC	PIR1,RC1IF,A
		CALL	USART1rec
		BTFSC	PIR3,RC2IF,A
		CALL	SendStudent
LOWISR3
ifdef		MicroProStar
	; Test for Timer4 interrupt and process
		BTFSC	PIR3,TMR4IF
		CALL	Timer4ISR
endif
	; Exit	
		POPREGSLOW             		;restore specific registers
            	retfie            		;return from interrupt

JumpTable1	code	0x0100 + OFFSET
;
; The following section contains Jump tables and Call tables. This tables are used
; to programmatically control return values.
; These tables must not be moved. The tables need to be contained in a 256 byte page.
;

; Calibration options. Called with an offset value in CXreg. This funtion
; will add the offset to the program counter to index into the jump 
; table.
CALoptions
		MOVF	PCL,W,A		; Refresh the latch regs
		MOVLB	HIGH CXreg
		MOVF	CXreg,W
		ADDWF	PCL
		GOTO	CalSelectAircraft
		GOTO	CalAircraftName
		GOTO	CalTimer
		GOTO	CalSnap
		GOTO	CalServos
		GOTO	CalMixers
		GOTO	CalSwitch
		GOTO	CalOptions
		GOTO	CalSystemSetup
		GOTO	CalSelectFrequency
		GOTO	CalAdvanced
		GOTO	CalHelicopter
		RETURN 			; Exit option, this return is never hit
		
; This function will load BXreg with the trim value indexed by WREG.
; WREG              
;	0 = Set to 0, no trim
;	1 = Aileron
;	2 = Elevator
;	3 = Rudder
;	4 = Throttle 
; If the WREG defines a ditital trim then the BXreg reg is unchanged.
SelectTrim
	; Test if any of the 4 MSBs are set, if so exit
		BTFSC	WREG,4,A
		RETURN
		BTFSC	WREG,5,A
		RETURN
		BTFSC	WREG,6,A
		RETURN
		BTFSC	WREG,7,A
		RETURN
	; Here if not a ditital trim		
		ANDLW	0x0F
		BTFSS	ALUSTA,Z
		GOTO	ST1
		MOVEC	0,BXreg
		RETURN
ST1              
	; Build index
		DECF	WREG
		ANDLW	3
		MULLW	D'10'
		MOVFF	PCL,WREG		; Refresh the program counter latch
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

JumpTable2	code	0x0200 + OFFSET
                      
; This function returns the selected channel. WREG is the index into
; the ChannelOrder table. The indexed value is moved into NextTime. 
; Reg INDF0 contains the index value                     
SelectOutputChannel
 	; Build index
		MOVFF	INDF0,WREG
		DECF	WREG
		ANDLW	7
		MULLW	D'10'
		MOVFF	PCL,WREG		; Refresh the program counter latch
		MOVF	PRODL,W,A
		ADDWF	PCL	

               ; Aileron
                MOVE16	chAIL,NextTime
		RETURN
                ; Elevator
                MOVE16	chELE,NextTime
		RETURN
                ; Rudder
                MOVE16	chRUD,NextTime
		RETURN
                ; Throttle
                MOVE16	chTHT,NextTime
		RETURN
                ; CH5
                MOVE16	chCH5,NextTime
		RETURN
                ; CH6
                MOVE16	chCH6,NextTime
		RETURN
                ; CH7
                MOVE16	chCH7,NextTime
		RETURN
                ; CH8
                MOVE16	chCH8,NextTime
		RETURN
		
; This function will load the ADC mux byte from the ADCaddTbl table located
; in the general data area, page 2.
; On call WREG contains the ADC channel request and on return the data is in 
; WREG.
ADClookup
   ; Compute the jump location
		ANDLW	0F
		MULLW	6
		MOVFF	PCL,WREG		; Refresh the program counter latch
		MOVF	PRODL,W,A
		ADDWF	PCL	

		MOVFF	ADCaddTbl, WREG
		RETURN
		MOVFF	ADCaddTbl+1, WREG
		RETURN
		MOVFF	ADCaddTbl+2, WREG
		RETURN
		MOVFF	ADCaddTbl+3, WREG
		RETURN
		MOVFF	ADCaddTbl+4, WREG
		RETURN
		MOVFF	ADCaddTbl+5, WREG
		RETURN
		MOVFF	ADCaddTbl+6, WREG
		RETURN
		MOVFF	ADCaddTbl+7, WREG
		RETURN
		MOVFF	ADCaddTbl+8, WREG
		RETURN
		MOVFF	ADCaddTbl+9, WREG
		RETURN
		MOVFF	ADCaddTbl+0A, WREG
		RETURN
		MOVFF	ADCaddTbl+0B, WREG
		RETURN
		MOVFF	ADCaddTbl+0C, WREG
		RETURN
		MOVFF	ADCaddTbl+0D, WREG
		RETURN
		MOVFF	ADCaddTbl+0E, WREG
		RETURN
		MOVFF	ADCaddTbl+0F, WREG
		RETURN

JumpTable3	code	0x0300 + OFFSET

; This function will return the channel number in reg AXreg. The
; channel number must be in WREG the channels are numbered 1 to 8.
; The position data is read from the mixed position array.
GetFrom
		MOVLB	HIGH AposM
		DECF	WREG
		ANDLW	7
		MULLW	D'10'
		MOVFF	PCL,WREG		; Refresh the program counter latch
		MOVF	PRODL,W,A
		ADDWF	PCL	
	; Channel 1
		MOVF	AposM,W
		MOVWF	AXreg
		MOVF	AposM+1,W
		MOVWF	AXreg+1
		RETURN
	; Channel 2
		MOVF	EposM,W
		MOVWF	AXreg
		MOVF	EposM+1,W
		MOVWF	AXreg+1
		RETURN
	; Channel 3
		MOVF	RposM,W
		MOVWF	AXreg
		MOVF	RposM+1,W
		MOVWF	AXreg+1
		RETURN
	; Channel 4
		MOVF	TposM,W
		MOVWF	AXreg
		MOVF	TposM+1,W
		MOVWF	AXreg+1
		RETURN
	; Channel 5
		MOVF	CH5posM,W
		MOVWF	AXreg
		MOVF	CH5posM+1,W
		MOVWF	AXreg+1
		RETURN
	; Channel 6
		MOVF	CH6posM,W
		MOVWF	AXreg
		MOVF	CH6posM+1,W
		MOVWF	AXreg+1
		RETURN
	; Channel 7
		MOVF	CH7posM,W
		MOVWF	AXreg
		MOVF	CH7posM+1,W
		MOVWF	AXreg+1
		RETURN
	; Channel 8
		MOVF	CH8posM,W
		MOVWF	AXreg
		MOVF	CH8posM+1,W
		MOVWF	AXreg+1
		RETURN

JumpTable4	code	0x0400 + OFFSET

; This function will sum the value in AXreg with the channel number defined
; in the WREG. This sum is performed on the position variable array. If the
; MSB is set then the value is AXreg replaces the old position value, if the
; MSB is clear then AXreg is added to the position value
ApplyMix
		MOVLB	HIGH Apos
		BTFSC	WREG,7
		GOTO	ApplyMixReplace
		DECF	WREG
		ANDLW	7
		MULLW	D'10'
		MOVFF	PCL,WREG		; Refresh the program counter latch
		MOVF	PRODL,W,A
		ADDWF	PCL	
	; Channel 1
		MOVF	AXreg,W
		ADDWF	Apos,F
		MOVF	AXreg+1,W
		ADDWFC	Apos+1,F
		RETURN
	; Channel 2
		MOVF	AXreg,W
		ADDWF	Epos,F
		MOVF	AXreg+1,W
		ADDWFC	Epos+1,F
		RETURN
	; Channel 3
		MOVF	AXreg,W
		ADDWF	Rpos,F
		MOVF	AXreg+1,W
		ADDWFC	Rpos+1,F
		RETURN
	; Channel 4
		MOVF	AXreg,W
		ADDWF	Tpos,F
		MOVF	AXreg+1,W
		ADDWFC	Tpos+1,F
		RETURN
	; Channel 5
		MOVF	AXreg,W
		ADDWF	CH5pos,F
		MOVF	AXreg+1,W
		ADDWFC	CH5pos+1,F
		RETURN
	; Channel 6
		MOVF	AXreg,W
		ADDWF	CH6pos,F
		MOVF	AXreg+1,W
		ADDWFC	CH6pos+1,F
		RETURN
	; Channel 7
		MOVF	AXreg,W
		ADDWF	CH7pos,F
		MOVF	AXreg+1,W
		ADDWFC	CH7pos+1,F
		RETURN
	; Channel 8
		MOVF	AXreg,W
		ADDWF	CH8pos,F
		MOVF	AXreg+1,W
		ADDWFC	CH8pos+1,F
		RETURN
ApplyMixReplace
		DECF	WREG
		ANDLW	7
		MULLW	D'10'
		MOVFF	PCL,WREG		; Refresh the program counter latch
		MOVF	PRODL,W,A
		ADDWF	PCL	
	; Channel 1
		MOVF	AXreg,W
		MOVWF	Apos
		MOVF	AXreg+1,W
		MOVWF	Apos+1
		RETURN
	; Channel 2
		MOVF	AXreg,W
		MOVWF	Epos
		MOVF	AXreg+1,W
		MOVWF	Epos+1
		RETURN
	; Channel 3
		MOVF	AXreg,W
		MOVWF	Rpos
		MOVF	AXreg+1,W
		MOVWF	Rpos+1
		RETURN
	; Channel 4
		MOVF	AXreg,W
		MOVWF	Tpos
		MOVF	AXreg+1,W
		MOVWF	Tpos+1
		RETURN
	; Channel 5
		MOVF	AXreg,W
		MOVWF	CH5pos
		MOVF	AXreg+1,W
		MOVWF	CH5pos+1
		RETURN
	; Channel 6
		MOVF	AXreg,W
		MOVWF	CH6pos
		MOVF	AXreg+1,W
		MOVWF	CH6pos+1
		RETURN
	; Channel 7
		MOVF	AXreg,W
		MOVWF	CH7pos
		MOVF	AXreg+1,W
		MOVWF	CH7pos+1
		RETURN
	; Channel 8
		MOVF	AXreg,W
		MOVWF	CH8pos
		MOVF	AXreg+1,W
		MOVWF	CH8pos+1
		RETURN
		
		code
	
; This function will return after the PPM transmission has just completed.
; If the interrupts are not enabled this function will return without
; any delay.
SyncUp
   ; Test interrupts and return if disabled
		BTFSS	INTCON,GIE
		RETURN
   ; Set time out counter 3 to 1 and wait for it to reach 0
		MOVLB	HIGH TimeOut3
		MOVLW	1
		MOVWF	TimeOut3
SyncUp1                              
 		TSTFSZ	TimeOut3
		GOTO	SyncUp1
		RETURN
		
;************************************************************************
;************************************************************************
;                      ***** MAIN PROGRAM  *****
;************************************************************************
;************************************************************************
start
	; Read EEPROM page to RAM page 5
		CALL	EEPROMread
	; kill the buzzer
		BSF	DDRA,BUZZER,A		; Set control pin as input to disable
						; Init the port after config is loaded
		MOVFF	Adapter,WREG
		COMF	WREG
		TSTFSZ	WREG
		GOTO	BuzOK
		; Here for Adapter mode INIT
		BCF	DDRA,BUZZER,A		; If its an adapter, assume normal buzzer
		BCF	PORTA,BUZZER,A 
BuzOK
	;
		BCF	DDRB,PLLRST,A
		BCF	PORTB,PLLRST,A
		MOVLB	HIGH BeepTicks
		CLRF	BeepTicks
		CLRF	BeepCtr
	; Read the PIC type and set the PIC18F8723 flag if the processor is detected
		CALL	ProcessorType
	; Clear counter mode
		MOVLB	HIGH Cmode
		CLRF	Cmode	
	; 100 mS startup delay to let all systems stabilize
		MOVLW	D'100'
		CALL Delay1mS
ifdef		MicroProStar
		CALL	MP8Kinit
endif
	; Place usable data in the TicksPer and cyccleCounts variable, this will
	; Allow the system to boot
		MOVLW	D'40'
		MOVFF	WREG,TicksPer
		MOVEC	D'50000',CycleCounts
	; Init the port variables
		; Init port D debound variables
ifdef		MicroProStar
		CALL	MP8KreadD
else
		MOVFF	PORTD,WREG
endif
		MOVLR	HIGH PORTDimage
		MOVWF	PORTDimage
		MOVWF	PORTDlast
		MOVWF	PORTDlatch
		COMF	WREG
		MOVWF	PORTDlatchLow
		; Init port D debound variables
ifdef		MicroProStar
		CALL	MP8KreadE
else
		MOVFF	PORTE,WREG
		
		BCF	WREG,OPTION
		BTFSC	OPTION_BUTTON
		BSF	WREG,OPTION
endif
		MOVLR	HIGH PORTEimage
		MOVWF	PORTEimage
		MOVWF	PORTElast
		MOVWF	PORTElatch
		COMF	WREG
		MOVWF	PORTElatchLow

		MOVLB	HIGH PORTH
		BCF	DDRH,AUXOUT
		BSF	PORTH,AUXOUT		; by default output the ppm pulse train
ifndef		MicroProStar
		BCF	DDRC,LED1  
		BCF	DDRB,LED2  
		BCF	PORTC,LED1  
		BCF	PORTB,LED2
endif
	; Init math variables
		MOVEC32	0,DEXreg
		MOVEC32	0,EEXreg
		MOVEC32	0,CEXreg
	; Init misc variables
		MOVEC	0,MApos
		MOVEC	0,MEpos
		MOVEC	0,MRpos
		MOVEC	0,MTpos
		MOVEC	0,MonFlag
		MOVEC	0F,ADCfixThres
		MOVLB	HIGH TimeOut
		CLRF	TimeOut
		CLRF	TimeOut1
		CLRF	TimeOut2
		CLRF	TimeOut3
		CLRF	TimeOut4
		CLRF	TimeOut5   
		SETF	TimerCount
		CLRF	FMSflag
		CLRF	FMSflagU1
		CLRF	GyroTune
		CLRF	TholdState
		CLRF	WREG
		MOVFF	WREG,DisplayLine
		MOVFF	WREG,TTflag
		MOVFF	WREG,LValarm
		MOVFF	WREG,AUXMODE
		MOVFF	WREG,ActiveDisplayLine
		MOVFF	WREG,CalServoUpdate
	; Init the version variable
		MOVLW	UPPER (MES2+D'10')		; Load pointer the the version number
		MOVWF	TBLPTRU,A
		MOVLW	HIGH (MES2+D'10')
		MOVWF	TBLPTRH,A
		MOVLW	LOW (MES2+D'10')
		MOVWF	TBLPTRL,A
		; Read the version number into RAM
		TBLRD*+
		MOVFF	TABLAT,Version
		TBLRD*+
		TBLRD*+
		MOVFF	TABLAT,Version+1
		TBLRD*+
		MOVFF	TABLAT,Version+2
	; Load the defaults
		CALL	LoadDefaults
		; Set DefaultAircraft equal to Aircraft
		MOVLB	HIGH Aircraft
		MOVF	Aircraft,W
		MOVLB	HIGH DefaultAircraft
		MOVWF	DefaultAircraft
	; Read the stick center positions
	        MOVLW   ADCail
	        CALL    ADCread
	        MOVLW   ADCail
	        CALL    ADCread
	        MOVLB   HIGH AilCenter
	        MOVF    ADRESL,W,A
	        MOVWF   AilCenter
	        MOVF    ADRESH,W,A
	        MOVWF   AilCenter+1
	        MOVLW   ADCele
	        CALL    ADCread
	        MOVLW   ADCele
	        CALL    ADCread
	        MOVLB   HIGH EleCenter
	        MOVF    ADRESL,W,A
	        MOVWF   EleCenter
	        MOVF   	ADRESH,W,A
	        MOVWF   EleCenter+1
	; Initalize the Transmitter  battery voltage filter
		MOVLW	ADCref
		CALL	ADCread
		; Save data in Vbat256
		MOVFF	Pos,Vbat256+1
		MOVFF	Pos+1,Vbat256+2
	; Signon message
		CALL	LCDinit
		MOVLW	D'250'
		CALL 	Delay1mS
		MOVLW	D'250'
		CALL 	Delay1mS
		ShowLine2
		MOVLW	D'250'
		CALL 	Delay1mS
		MOVLW	D'250'
		CALL 	Delay1mS
	; Perform initializations...
		CALL	Timer3Init
		CALL	TachInit
		CALL 	USART1init
		CALL 	USART2init
		CALL	DigitalTrimInit
	; Enable global interrups...
		BSF	INTCON,GIE
		BSF	INTCON,PEIE
		BSF	RCON,IPEN
	; Read the Flash general data into bank 2
		; If the PRESET and the AUTOTRIM button are pressed, then bypass...
		Pressed PORTD,PRESET
		BTFSC	ALUSTA,C
		GOTO	UseGeneral
		Pressed PORTE,AUTOT
		BTFSC	ALUSTA,C
		GOTO	UseGeneral
	; Make sure the AUTOTRIM button is released before
	; we continue...
		Release PORTE,AUTOT		
		GOTO	UseDefaults
		; Read the gereral aircraft data...
UseGeneral
		CALL	LoadGeneral
		; Test the Signature, if its not valid call FormatFlash
		MOVLB	HIGH Signature
		MOVLW	0A5
		CPFSEQ	Signature
		GOTO	FormatIt
		MOVLW	0E7
		CPFSEQ	Signature+1
		GOTO	FormatIt
		GOTO	FormatOK
FormatIt
ifdef		MicroProStar
		BSF	PORTA,BUZZER,A 
endif
		CALL	LoadDefaults
		CALL	FormatFlash
FormatOK
		; Read this aircraft...into bank 3
		MOVFF	Aircraft,WREG
		CALL	LoadAircraft
		; Move ModelChannel to SelFreq
		MOVLB	HIGH ModelChannel
		MOVF	ModelChannel,W
		MOVLB	HIGH SelFreq
		MOVWF	SelFreq
	; Init the PLL and turn the RF off
ifndef		MicroProStar
		CALL	PLLinit    
		CALL	PLLCalNreg
		; Set the LSB of Freg to F2 to turn off the RF
		MOVLB	HIGH Freg
		MOVLW	0F2
		MOVWF	Freg
		CALL	PLLsetup
endif
UseDefaults
	; Init the buzzer and turn it off
		BCF	PORTA,BUZZER,A 
		MOVFF	Adapter,WREG
		TSTFSZ	WREG
		BTG	PORTA,BUZZER,A
		MOVFF	BuzPol,WREG
		TSTFSZ	WREG
		GOTO	BuzInited
		BSF	PORTA,BUZZER,A 
		MOVFF	Adapter,WREG
		TSTFSZ	WREG
		BTG	PORTA,BUZZER,A
BuzInited:
		BCF	DDRA,BUZZER,A		; Set control pin as ouput	
	; Set the DOG display contrast
		CALL	SetDOGcontrast
	; Calculate the TicksPer and cyccleCounts values, this will
	; Allow the system to boot
		MOVLW	UPPER D'2000000'
		MOVFF	WREG, CEXreg+2
		MOVLW	HIGH D'2000000'
		MOVFF	WREG, CEXreg+1
		MOVLW	LOW D'2000000'
		MOVFF	WREG, CEXreg
		MOVFF	TicksPer, DEXreg
		CLRF	WREG
		MOVFF	WREG,DEXreg+1
		CALL	Divide2416
		; Now add the FrameDefect
		MOVFF	FrameDefect,WREG
		MOVLR	HIGH CEXreg
		ADDWF	CEXreg,F
		CLRF	WREG
		ADDWFC	CEXreg+1,F
		; Save the result
		MOVE	CEXreg,CycleCounts
	; Reestablish the stick center positions
	        MOVLW   ADCail
	        CALL    ADCread
	        MOVLW   ADCail
	        CALL    ADCread
	        MOVLB   HIGH AilCenter
	        MOVF    ADRESL,W,A
	        MOVWF   AilCenter
	        MOVF    ADRESH,W,A
	        MOVWF   AilCenter+1
	        MOVLW   ADCele
	        CALL    ADCread
	        MOVLW   ADCele
	        CALL    ADCread
	        MOVLB   HIGH EleCenter
	        MOVF    ADRESL,W,A
	        MOVWF   EleCenter
	        MOVF   	ADRESH,W,A
	        MOVWF   EleCenter+1
	; Test if the option button and the preset button are pressed
	; If they are both pressed then enter the IO test routine
		Pressed	OPTION_BUTTON
		BTFSC	ALUSTA,C
		GOTO	mainStartup
		Pressed	PORTD,PRESET
		BTFSS	ALUSTA,C
		GOTO	TestIO
mainStartup
	; Init UART2 again because the loaded configurations may have changed the defaults
		CALL 	USART2init
	; Clear the displayline variable
		CLRF	WREG
		MOVFF	WREG,DisplayLine
	; If option button is pressed then set the monitor mode flag
		Pressed	OPTION_BUTTON
		MOVLB	HIGH MonFlag
		BTFSS	ALUSTA,C
		BSF	MonFlag,0
	; If Auto trim button is pressed then set the monitor mode flag
		Pressed	PORTE,AUTOT
		MOVLB	HIGH MonFlag
		BTFSS	ALUSTA,C
		BSF	MonFlag,1		
		; If student mode turn off RF
		MOVLB	HIGH Student
		MOVFF	Student,Areg
		MOVLB	HIGH SelFreq
		MOVLW	0FF
		BTFSC	Areg,0
		MOVWF	SelFreq
		CPFSLT	SelFreq
		GOTO	Startup1
	; If Retracks up warning is enabled and the retracts are up,
	; issue a warning to the pilot
		MOVLB	HIGH RetractsWarning
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
		Pressed	OPTION_BUTTON
		BTFSC	ALUSTA,C
		GOTO	NRWwfo
		Release	OPTION_BUTTON
		MOVLW	D'200'
		CALL	Delay1mS
NoRetractWarn
	; If Fband = 0 then no RF deck to control
		MOVLB	HIGH Fband
		BTFSC	Fband,0
		GOTO	RFask
		BTFSS	Fband,1
		GOTO	Startup1
	; Display the Freq and ask pilot
RFask
		MOVLW	LINE1
		MOVLB	HIGH Ctemp
		MOVWF	Ctemp
		CALL	DisplayFrequency
		BCF	ALUSTA,C
		CALL	Accept
		; If no, set SelFreq=FF else turn on rf
		BTFSC	ALUSTA,C
		GOTO	Startup2
		; Here to leave rf off
		MOVLB	HIGH SelFreq
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
		MOVLB	HIGH Mode
		MOVLW	modeRUN
		MOVWF	Mode
	; Read a few more setup parameters...
		MOVE	SyncWidth,Sync
		MOVLB	HIGH MaxChannels
		MOVF	MaxChannels,W
		MOVLB	HIGH NumChan
		MOVWF	NumChan
	; Init the button id byte
		CALL	ButtonIDinit
		CALL	BackupAircraft
	; Flag the CH5, CH8, and throttle Active position values to force an init
		MOVLW	0xC0
		MOVFF	WREG,CH5posActual+1
		MOVFF	WREG,CH8posActual+1
		MOVFF	WREG,TposActual+1
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
		MOVLB	HIGH Cmode
		MOVLW	1
		MOVWF	Cmode
		MOVE	DWNSecs,Dsecs
		CLRF	Usecs
		CLRF	Umins
endif
main     
	; Enable the MOD output pin
		BCF	DDRF,MOD,A
	; Test the stack overflow bit and light LED2 if its set!
		BTFSS	STKPTR,STKFUL
		GOTO	NoStackOverflow
		MOVLB	HIGH DDRB
		BCF	DDRB,LED2
		BCF	PORTB,LED2
NoStackOverflow
	; Test the run/cal switch...
		MOVLB	HIGH PORTEimage
		BTFSC	PORTEimage,RUNCAL
		GOTO	RUNmode
		; Here if in the CAL mode, test current system mode
		MOVLW	modeRUN
		CPFSEQ	Mode
		GOTO	CALmode
		; If here, beep three times and change to CAL mode
		MOVLB	HIGH BeepCyl
		MOVLW	5
		MOVFF	WREG,BeepCyl
		MOVLW	D'7'
		CALL	Beep		; Startup short beep!
		MOVLW	modeCAL
		MOVWF	Mode
		SingleLine
		ShowLine2
		; Make sure the default aircraft is loaded...
		MOVLB	HIGH DefaultAircraft
		MOVF	DefaultAircraft,W
		MOVLB	HIGH Aircraft
		CPFSEQ	Aircraft
		GOTO	Reload
		GOTO	CALmode
Reload
		MOVWF	Aircraft
		CALL	LoadAircraft
		CALL	BackupAircraft
		GOTO	CALmode
;**********************************************************************************
; R U N    M O D E
;**********************************************************************************
RUNmode
		DualLine
		MOVLW	modeRUN
		MOVWF	Mode
		CALL	AlternateAircraft
		CALL	CalculateNormalizedPositions 
		CALL	UpdateLastPos			; This function support center beep options
		CALL	TimerEnable
		; If master mode and AutoTrim button is pressed then
		; Apply positions from slave
		MOVLB	HIGH Master
		BTFSS	Master,0
		GOTO	RUNmodeNotMaster
		; Is auto trim button pressed?
		MOVLB	HIGH SWATRIM
		MOVF	SWATRIM,W
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	RUNmodeNotMaster
		; Test if this is the mode....
		MOVLB	HIGH MasterMode
		TSTFSZ	MasterMode
		GOTO	FutabaMode
		MOVE	MApos,Apos
		MOVE	MEpos,Epos
		MOVE	MRpos,Rpos
		MOVE	MTpos,Tpos
		GOTO	RUNmodeNotMaster
FutabaMode
	; Here if its Futaba mode and the student button (auto trim) is pressed
	; Set INT1 to high priority and TMR3 to low
		BSF	INTCON3,INT1IP,A
		BSF	INTCON3,INT1IE,A
		BCF	IPR2,CCP2IP,A
	; Set the FutabaStudent flag
		SETF	WREG
		MOVFF	WREG,FutabaStudent
		GOTO	FutabaDone
RUNmodeNotMaster
	; Here if not in Futabe student mode
	; Set INT1 to low priority and TMR3 to high
		BCF	INTCON3,INT1IP,A
		BSF	INTCON3,INT1IE,A
		BSF	IPR2,CCP2IP,A
	; Clear the FutabaStudent flag
		CLRF	WREG
		MOVFF	WREG,FutabaStudent
FutabaDone
		; If we are in student mode, do no more processing!
		MOVLB	HIGH Student
		BTFSC	Student,0
		GOTO	RUNmode3
		CALL	ThrottleTrim
		BTFSC	ALUSTA,Z
		GOTO	RUNmode3
		CALL	ApplyDualRates
		CALL	ApplyExpo
		CALL    ApplySnap
		CALL	AutoTrim
		CALL	CenterBeep
		CALL	ApplyTrims
		CALL	ApplyHelicopter
		CALL	ApplyFixedMixersPrior
		CALL	ApplyMixers
		CALL	ApplyFixedMixers
		CALL	CCPMmixer
		CALL	ApplySlewRate
		CALL	ApplySubTrims
		CALL	ProcessDtrims
		MOVLB	HIGH FMSflag
		TSTFSZ	FMSflag
		CALL	FMS
		MOVLB	HIGH FMSflagU1
		TSTFSZ	FMSflagU1
		CALL	FMS
RUNmode3
		; Sync up with the PPM signal transmission.
		; This will insure we have time to update the channel times
		; before the ISR needs them
		CALL	SyncUp
		CALL	CalculateServoPositions
		CALL	SerialSendPositionData
		CALL	ProcessCommand
		; We will update the display every 1/4 sec using timeout4
		MOVLB	HIGH TimeOut4
		TSTFSZ	TimeOut4
		GOTO	RUNmode2
		MOVLW	d'10'
		MOVWF	TimeOut4
		CALL	Display
RUNmode2
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
	; Read Receiver voltage monitor ADC
		MOVLW	ADCrec
		CALL	ADCread		; Results are in Pos
		MOVE	Pos,RecVADC	
	; If option is pressed then enter the CAL function
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	CalNotSel
		CALL	Calibration
CalNotSel
	;
		CALL	CalculateNormalizedPositions
		CALL	UpdateLastPos
		CALL	ApplyDualRates
		CALL	ApplyExpo
		CALL    ApplySnap
		CALL	AutoTrim
		CALL	CenterBeep
		CALL	ApplyTrims
		CALL	ApplyHelicopter
		CALL	ApplyFixedMixersPrior
		CALL	ApplyMixers
		CALL	ApplyFixedMixers
		CALL	CCPMmixer
		CALL	ApplySlewRate
		CALL	ApplySubTrims
		CALL	CalculateServoPositions

		CALL	ProcessCommand
		GOTO	main
;******************************************************************


; This function will print the aircraft model name on the second
; line of the LCD display.
DisplayAircraftName
		MOVLB	0
	; Display the aircraft name on the second line
		MOVLW	D'16'
		MOVWF	Breg
		MOVLW	LINE2
		CALL	LCDsendCMD
		MOVLW	LOW Name
		MOVWF	FSR1L
		MOVLW	HIGH Name
		MOVWF	FSR1H		
Next_Char
		MOVF	POSTINC1,W
		CALL	LCDsendData
		DECFSZ	Breg
		GOTO	Next_Char
		RETURN
;
; This is the run mode display update subroutine. The routine
; displays all the information on the LCD display in the run 
; mode of the transmitter.
;
Display
	; Test the physical Auto Trim switch to see if it was just pressed,
	; if so then toggle the DisplayLine variable. This variable is only
	; used in the MicroProStar mode but the code is executed to all modes.
		MOVLB	HIGH PORTEimage
		BTFSC	PORTEimage,AUTOT
		GOTO	DisplayModeDone
		BTFSS	PORTElatch,AUTOT
		GOTO	DisplayModeDone
		BCF	PORTElatch,AUTOT
		; Toggle the state of the DisplayLine flag
		MOVLB	HIGH DisplayLine
		COMF	DisplayLine
DisplayModeDone:
	; Test if the monitor mode flag is set, if so
	; jump to the proper monitoring routine.
		MOVFF	MonFlag,WREG
		BTFSC	WREG,0
		GOTO	Monitor
		BTFSC	WREG,1
		GOTO	AutoTrimMonitor
	; Test if digitial trim data needs to be displayed, if so
	; jump to the display routine.
		MOVFF	DTdisplay,WREG
		TSTFSZ	WREG
		GOTO	DisplayTrim
		MOVLB	0
	; Display the Mixer states...
ifdef	ECMA1010display
		; Turn on the RF output ICON if RF is on
		MOVLB	HIGH SelFreq
		BTFSC	SelFreq,7
		GOTO	RFisOFF
		MOVLW	0F7
		CALL	LCDsendCMD
		PrintMess MRFON
RFisOFF
		MOVLW	0DC
		CALL	LCDsendCMD
		MOVLR	HIGH Backup
		MOVFP	AltAircraft,WREG
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
		MOVLR	HIGH Backup
		MOVFP	AltAircraft,WREG
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
		BTFSS	ALUSTA,C
		MOVLW	'-'
		CALL	LCDsendData
		MOVLR	HIGH SWMIX2
		MOVFP	SWMIX2,WREG
		CALL	SwitchTest
		MOVLW	'M'
		BTFSS	ALUSTA,C
		MOVLW	'-'
		CALL	LCDsendData
		MOVLR	HIGH SWMIX3
		MOVFP	SWMIX3,WREG
		CALL	SwitchTest
		MOVLW	'M'
		BTFSS	ALUSTA,C
		MOVLW	'-'
		CALL	LCDsendData
ifndef	ECMA1010display
		MOVLW	' '
		CALL	LCDsendData
endif
	; Display the transmitter voltage
		CALL	TransVoltage
	; If the Auto Trim button is pressed then display the total on time of
	; the transmitter
		MOVLR	HIGH SWATRIM
		MOVFP	SWATRIM,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	DispNoBT
		; Here if the Auto Trim button is pressed
		; Test if the transmitter is in the Master mode, if so then
		; display Stdnt on the display instead of the on time
		MOVFF	Master,WREG
		COMF	WREG
		TSTFSZ	WREG
		GOTO	DispBT
		; Here is display the Stdnt message
		MOVLW	LINE1
		CALL	LCDsendCMD
		PrintMess MES12
		GOTO	DispNoBT
DispBT		
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
		; Here to update the time in EEPROM
		MOVLW	LOW BatteryTimer
		MOVFF	WREG,AXreg	; RAM address of data to write
		CLRF	WREG,A
		MOVFF	WREG,AXreg+1
		MOVFF	BatteryTimer,WREG
		CALL	EEPROMwriteByte

		MOVLW	LOW (BatteryTimer+1)
		MOVFF	WREG,AXreg	; RAM address of data to write
		CLRF	WREG,A
		MOVFF	WREG,AXreg+1
		MOVFF	BatteryTimer+1,WREG
		CALL	EEPROMwriteByte
DispNoSaveBT
	; Display the Throttle Adjust message if the TTflag is set
		CALL	ThrottleAdjustMessage
		BTFSC	ALUSTA,C
		GOTO	DispAircraftDone		
	; Display the receiver bat voltage if its non zero..
ifndef		MicroProStar			; These functions do not exist on the MicroProStar
		CALL	RecVoltage
		BTFSC	ALUSTA,C
		GOTO	DispAircraftDone
	; Display The Tach RPM if enabled
		CALL	TackDisplay
		BTFSC	ALUSTA,C
		GOTO	DispAircraftDone
endif
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
		CALL	HelicopterModeDisplay
DispAircraftDone
	; Process the Option button
		CALL	Option
		BTFSS	ALUSTA,C
		GOTO	Dsp1
	; Test if the Helicopter Gyro tune mode is active and process
		CALL	GyroTuneProcess
		BTFSC	ALUSTA,C
		GOTO	Dsp1
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
		MOVFF	DXreg,WREG
		MOVFF	WREG,CEXreg
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
		SUBWFB	CEXreg+1,W
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
		             
	Include	<TestIO.asm>
	Include	<ADC.asm>

; Timer3 init routine.
Timer3Init
	; Write initial values into data arrays
		MOVLR	HIGH Pstate
		CLRF	Pstate
		CLRF	Secs
		CLRF	Mins
		MOVFF	TicksPer,WREG
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
;		BCF	DDRF,MOD,A	; Define as output, do this after all setup is done
		BSF	PORTF,MOD,A	; Set initial state
	; Setup timer3 and turn on interrupts
	 	; Setup the compare register, using compare reg 2
		MOVLR	HIGH Sync
		MOVFP	Sync,WREG
		MOVLB	HIGH CCPR2L
		MOVPF	WREG,CCPR2L
		MOVLR	HIGH (Sync + 1)
		MOVFP	(Sync + 1),WREG
		MOVLB	HIGH CCPR2H
		MOVPF	WREG,CCPR2H
		MOVLW	0A			; Interrupt on conpare equal counter
						; (0B = reset timer 3)
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
 		MOVLW	08
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
	; Output the MOD pin state if this is not futaba master mode and
	; enabled for the student
		MOVLB	HIGH FutabaStudent
		BTFSS	FutabaStudent,0
		BTG	PORTF,MOD,A
	; Output the AUXOUT signal
		MOVLB	HIGH AUXMODE
		BTFSS	AUXMODE,7
		GOTO	AuxServoChanMode
		BTG	PORTH,AUXOUT,A
		GOTO	EndAuxState
AuxServoChanMode
		MOVLB	HIGH AUXSTATE
		BTFSC	AUXSTATE,0
		GOTO	AuxStateClr
		BSF	PORTH,AUXOUT,A
		GOTO	EndAuxState
AuxStateClr
		BCF	PORTH,AUXOUT,A
EndAuxState
	; Set the timers next compare value, sum current value with NextTime
		MOVLB	HIGH NextTime
		MOVFF	CCPR2L,WREG
		ADDWF	NextTime
		MOVFF	CCPR2H,WREG
		ADDWFC	NextTime+1

		MOVFF	NextTime,WREG
		MOVFF	WREG,CCPR2L

		MOVFF	(NextTime + 1),WREG
		MOVFF	WREG,CCPR2H
	; Advance to next state
		MOVLB	HIGH Pstate
		CLRF	WREG,A
		CPFSGT	Pstate
		CALL	RTC		; Do the real time clock stuff.
					; This happens at 40 Hz
		MOVLB	HIGH Pstate
		INCF	Pstate
		MOVFF	Pstate,WREG
		ANDLW	0FE
		CPFSLT	NumChan
		GOTO	TIMER3ISR0
	; IF here reset the state to 0
		CLRF	Pstate
		; Calculate the time to the next output sequence,
		; 40Hz rate
		MOVFF	CycleCounts,WREG
		MOVFF	WREG,NextTime
		MOVFF	Psum,WREG
		SUBWF	NextTime,F
		MOVFF	CycleCounts+1,WREG
		MOVFF	WREG,NextTime+1
		MOVFF	Psum+1,WREG
		SUBWFB	NextTime+1,F
		CLRF	Psum
		CLRF	Psum+1
		GOTO	TIMER3ISR3
TIMER3ISR0
	; Test for an odd state number. If its odd then we
	; output the sync pulse time
		BTFSS	Pstate,0
		GOTO	TIMER3ISR1
		MOVFF	Sync,WREG
		MOVFF	WREG,NextTime
		MOVFF	Sync+1,WREG
		MOVFF	WREG,NextTime+1
	; Test if this channel position is being output to the
	; AUXOUT pin
		MOVFF	AUXMODE,WREG
		MOVLB	HIGH AUXSTATE
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
		MOVFF	Psum,WREG
		MOVFF	WREG,NextTime
		MOVFF	Psum+1,WREG
		MOVFF	WREG,NextTime+1
		RRCF	NextTime+1,F
		RRCF	NextTime,F
		RRCF	NextTime+1,F
		RRCF	NextTime,F
		RRCF	NextTime+1,F
		RRCF	NextTime,F
		RRCF	NextTime+1,F
		RRCF	NextTime,F
		MOVLW	0F
		ANDWF	NextTime+1,F
		GOTO	TIMER3ISR2
	; Get the next state time using indirect addressing
TIMER3ISR1a
		MOVLW	HIGH ChannelOrder
		MOVFF	WREG,FSR0H
		MOVLW	ChannelOrder
		MOVFF	WREG,FSR0L
		MOVFF	Pstate,WREG
		RRCF	WREG,W,A
		BCF	WREG,7,A
		DECF	WREG,W,A
		ADDWF	FSR0L,F,A
		CALL	SelectOutputChannel
		; Subtract the Sync pulse width from this time
		MOVFF	Sync,WREG
		SUBWF	NextTime
		MOVFF	Sync+1,WREG
		SUBWFB	NextTime+1
	; Now sum the channel times
TIMER3ISR2
		MOVFF	NextTime,WREG
		ADDWF	Psum,F
		MOVFF	NextTime+1,WREG
		ADDWFC	Psum+1,F
	; Clear the interrupt bit and exit
TIMER3ISR3
		MOVLB	HIGH PIR2
		BCF	PIR2,CCP2IF
		RETURN

; This function is called at 40Hz and is responsible for all
; time generation. Up to 10mS can be spent in this routine.
RTC
	; Call the MPS real time interrupt process code
		ifdef	MicroProStar
		CALL	MPSrtc
		endif
	; Test the USARTS
		CALL	USART1reset
		CALL	USART2reset
	; Bypass the overrun test if not in the run mode
		MOVLR	HIGH Mode
		MOVLW	modeRUN
		CPFSEQ	Mode
		GOTO	NotOverrunTest
	; Test the OVERRUN flag if set then turn on the LED
		MOVLB	HIGH OVERRUN
ifndef		MicroProStar
		BSF	PORTC,LED1,A
		BTFSC	OVERRUN,0
		BCF	PORTC,LED1,A
endif
	; Always set the OVERRUN flag
		MOVLW	0FF
		MOVWF	OVERRUN
NotOverrunTest
	; Insure that the Mod pin is in the correct state and do not output the
	; Mod pulse if in the Futaba mode and control is sent to student
		MOVLR	HIGH SHIFT
		BTFSC	SHIFT,7
		GOTO	RTCx
		MOVLB	HIGH FutabaStudent	; added for 2.0l
		BTFSS	FutabaStudent,0		; added for 2.0l
		BCF	PORTF,MOD,A
		GOTO	RTCy
RTCx
		MOVLB	HIGH FutabaStudent	; added for 2.0l
		BTFSS	FutabaStudent,0		; added for 2.0l
		BSF	PORTF,MOD,A
RTCy
	; Test the AUXOUT mode and if we are in PPM 
	; Version 2.0n allowed the shift level to invert.
	; Version 2.0p has an inverted PPM output, LSB set incicates invert.
		MOVLB	HIGH AUXMODE
		BTFSS	AUXMODE,7
		GOTO	NotPPM			; Jump if not in PPM mode
		; Test LSB to see if its inverted
		BTFSC	AUXMODE,0
		GOTO	AUXhi
		BCF	PORTH,AUXOUT,A
		GOTO	NotPPM		
AUXhi
		BSF	PORTH,AUXOUT,A
NotPPM	
	; End of AUXOUT processing
		MOVLR	HIGH Tick
		DECFSZ	Tick
		GOTO	RTC1
	; If here its time to inc the secs, here one time per second
	; First test the down counter and dec if its not zero
		CALL	TachRead
		MOVLB	HIGH Cmode
		BTFSS	Cmode,0
		GOTO	RTC1a
		MOVLB	HIGH TimerCount
		MOVLW	0FF
		CPFSEQ	TimerCount
		GOTO	RTC1a		; Jump is not enabled
		MOVFF	Dsecs,WREG
		IORWF	Dmins,W
		BTFSC	ALUSTA,Z,A
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
		MOVF	Dsecs,W
		MOVWF	DsecsLatch 
	; If CNTmode != 0 (down) and the down count times are zero,
	; then reset the up counters to zero
		MOVLB	HIGH CNTmode
		CLRF	WREG,A
		IORWF   CNTmode,W
		BTFSC	ALUSTA,Z,A
		GOTO	RTC1d
		MOVLB	HIGH Dsecs
		MOVF	Dsecs,W
		IORWF	Dmins,W
		BTFSC	ALUSTA,Z,A
		GOTO	RTC1d
		CLRF	Usecs
		CLRF	Umins	
		GOTO	RTC1a		
	; Here to inc the up counter
RTC1d
                MOVLB   HIGH Usecs
		INCF	Usecs
		MOVLW	D'60'
		CPFSEQ	Usecs
		GOTO	RTC1a
		CLRF	Usecs
		INCF	Umins
RTC1a
		MOVFF	TicksPer,WREG
		MOVFF	WREG,Tick
		INCF	Secs
		MOVLW	D'60'
		CPFSEQ	Secs
		GOTO	RTC1
	; If here its time to inc the minutes, here one time per minute
		CLRF	Secs
		INCF	Mins
		; Increment the battery timer and set the flag            
		MOVLB	HIGH BatteryTimer
		INCF	BatteryTimer
		BTFSC	ALUSTA,Z,A
		INCF	BatteryTimer+1
		MOVLB	HIGH BTflag
		SETF	BTflag				
RTC1              
	; Send an S to tell the Slave its ok to send!
		MOVLB	HIGH Master
		BTFSS	Master,0
		GOTO	RTC1NotMaster
		MOVLW	'S'
		CALL	USART2sendChar
		; Clear the MasterState variable
		MOVLB	HIGH MasterState
		CLRF	MasterState
RTC1NotMaster
ifdef		MicroProStar
		MP8K_IsBusy		; If the IO system is in use do not read the IO
		BTFSC	ALUSTA,C
		GOTO	RTCioBusy
		; Process the buzzer
		CALL	MP8Kbuzzer
endif
	; Debounce port D
ifdef		MicroProStar
		CALL	MP8KreadD
else
		MOVFF	PORTD,WREG
endif
		MOVLB	HIGH PORTDimage
		XORWF	PORTDlast,F
		BTFSS	ALUSTA,Z,A
		MOVWF	PORTDimage
		MOVWF	PORTDlast
		MOVFF	PORTDimage,WREG
		IORWF	PORTDlatch,F
		COMF	WREG
		IORWF	PORTDlatchLow,F
		MOVFF	PORTDlatch,WREG
		ANDWF	PORTDlatchLow,F
	; Debounce port E
ifdef		MicroProStar
		CALL	MP8KreadE
else
		MOVFF	PORTE,WREG
		
		BCF	WREG,OPTION
		BTFSC	OPTION_BUTTON
		BSF	WREG,OPTION
endif
		MOVLB	HIGH PORTEimage
		XORWF	PORTElast,F
		BTFSS	ALUSTA,Z,A
		MOVWF	PORTEimage
		MOVWF	PORTElast
		MOVFF	PORTEimage,WREG
		IORWF	PORTElatch,F
		COMF	WREG
		IORWF	PORTElatchLow,F
		MOVFF	PORTElatch,WREG
		ANDWF	PORTElatchLow,F
RTCioBusy
	; Test the TimeOut counters
		MOVLB	HIGH TimeOut
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
		BTG	PORTA,BUZZER,A
		DCFSNZ	BeepCyl
		RETURN
		MOVFF	BeepTicks,WREG
		MOVFF	WREG,BeepCtr
		RETURN

; Call this function with the number of ticks to beep in WREG
; BeepCly is assumed set...
Beep
		MOVFF	WREG,BeepTicks
		MOVFF	WREG,BeepCtr
	; Turn it on!
		MOVFF	BuzPol,WREG
		TSTFSZ	WREG,A
		GOTO	BuzInvert
	;
		BCF	PORTA,BUZZER,A 
		MOVFF	Adapter,WREG
		TSTFSZ	WREG
		BTG	PORTA,BUZZER,A
ifdef		MicroProStar
		CALL	MP8Kbuzzer
endif
		RETURN
BuzInvert:
		BSF	PORTA,BUZZER,A 
		MOVFF	Adapter,WREG
		TSTFSZ	WREG
		BTG	PORTA,BUZZER,A
ifdef		MicroProStar
		CALL	MP8Kbuzzer
endif
		RETURN


; This routine sends the value in Areg MSB first. The number of bits to send
; are defined in Breg. Both Areg and Breg are destroyed.
PLLsend
	; Select the bank
		MOVLB	HIGH Areg
	; Set the data line
		BTFSC	Areg,7
		GOTO	PLLsend1
		BCF	PORTB,SDObit
		GOTO	PLLsend2
PLLsend1
		BSF	PORTB,SDObit
PLLsend2
	; Pulse the clock line
		BSF	PORTC,CLK
		BCF	PORTC,CLK
	; Loop untill finished
		RLNCF	Areg
		DECFSZ	Breg
		GOTO	PLLsend
		RETURN

; This function powers the PLL down and shuts off the RF output stage.
PLLpowerDown               
		MOVLB	HIGH PLLinitWORD
		MOVF	PLLinitWORD+2,W
		MOVWF	Areg
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend  
		MOVLB	HIGH PLLinitWORD
		MOVF	PLLinitWORD+1,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend 
		MOVLB	HIGH PLLinitWORD
		MOVF	PLLinitWORD,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
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
                MOVLB   HIGH SelFreq
                MOVF    SelFreq,W
                MOVLB	HIGH PMUL
                MULWF	PMUL
                MOVF	PRODL,W
                MOVLB   HIGH CEXreg
                ADDWF   CEXreg,F
                BTFSC   ALUSTA,C
                INCF    CEXreg+1
                BTFSC   ALUSTA,C
                INCF    CEXreg+2
         ; Now move the result to Nreg and add the control bits...
                MOVLB   HIGH Nreg
                CLRF    Nreg
                CLRF    Nreg+1
                CLRF    Nreg+2
                MOVLB   HIGH CEXreg
                MOVF    CEXreg,W
                RLNCF   WREG
                RLNCF   WREG
                BSF     WREG,0
                BCF     WREG,1
                ANDLW   01F
                BTFSC   CEXreg,3
                BSF     WREG,7
                MOVLB   HIGH Nreg
                MOVWF   Nreg
                ; Now the MS two bytes...
                MOVLB   HIGH CEXreg   
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
                MOVF    CEXreg+1,W
                MOVLB   HIGH Nreg
                MOVWF   Nreg+1
                MOVLB   HIGH CEXreg
                MOVF    CEXreg+2,W
                ANDLW   01F
                MOVLB   HIGH Nreg
                IORLW   HICUR
                MOVWF   Nreg+2
                RETURN

; This routine initializes the PLL. The three regs F, R, and N are downloaded to
; the PLL.
PLLsetup         
	; Calculate the Nreg
		CALL	PLLCalNreg
	; F register
		MOVLB	HIGH Freg
		MOVF	Freg+2,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend
		MOVLB	HIGH Freg
		MOVF	Freg+1,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend
		MOVLB	HIGH Freg
		MOVF	Freg,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend
		; Pulse the load line
		BSF	PORTG,PLLCS,A
		BCF	PORTG,PLLCS,A
	; R register
		MOVLB	HIGH Rreg
		MOVF	Rreg+2,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend
		MOVLB	HIGH Rreg
		MOVF	Rreg+1,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend
		MOVLB	HIGH Rreg
		MOVF	Rreg,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend
		; Pulse the load line
		BSF	PORTG,PLLCS,A
		BCF	PORTG,PLLCS,A
	; N register
		MOVLB	HIGH Nreg
		MOVF	Nreg+2,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend
		MOVLB	HIGH Nreg
		MOVF	Nreg+1,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
		CALL	PLLsend
		MOVLB	HIGH Nreg
		MOVF	Nreg,W
		MOVWF	Areg,A
		MOVLW	8
		MOVWF	Breg,A
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
; Fband:
;     1 = 50 MHz
;     2 = 53 MHz
;     3 = 72 MHz
;
PLLinit
	; Set port directions and initial states
		MOVLB	HIGH PORTB
		BCF	DDRB,SDObit
		BCF	DDRC,CLK
		BCF	DDRB,PLLRST
		BCF	PORTB,PLLRST
		BCF	PORTB,SDObit
		BCF	PORTC,CLK
		BCF	DDRG,PLLCS,A
		BCF	PORTG,PLLCS,A
	; Setup the PLL variables depending on the Fband value
	        MOVLB   HIGH Fband
	        MOVLW	1
	        CPFSEQ	Fband
	        GOTO	PLLinit0
	; Here if its the 50MHz band
		MOVE24	Freg50,Freg
	 	MOVE24	Rreg50,Rreg
	 	MOVEC24 D'50800',FCF
	 	MOVEC	D'20',PDF
	 	MOVLB	HIGH FCN   
	 	CLRF	FCN
	 	MOVLW	D'10'
	 	MOVWF	NUMFREQ
	 	MOVLW	1
	 	MOVWF	PMUL
	        RETURN
PLLinit0
	        MOVLW	2
	        CPFSEQ	Fband
	        GOTO	PLLinit1
	 ; Here if its the 53MHz band
	 	MOVE24	Freg53,Freg
	 	MOVE24	Rreg53,Rreg
	 	MOVEC24 D'53100',FCF
	 	MOVEC	D'20',PDF
	 	MOVLB	HIGH FCN   
	 	CLRF	FCN
	 	MOVLW	D'8'
	 	MOVWF	NUMFREQ 
	 	MOVLW	5
	 	MOVWF	PMUL
	        RETURN
PLLinit1       
	        MOVLW	3
	        CPFSEQ	Fband
	        GOTO	PLLinit2
	 ; Here if its the 72MHz band
		MOVE24	Freg72,Freg
	 	MOVE24	Rreg72,Rreg
	 	MOVEC24 D'72010',FCF
	 	MOVEC	D'10',PDF
	 	MOVLB	HIGH FCN
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
; module is connected to this pin. If the tach is enabled then this
; routine will count prop revolutions.
;
INT1ISR
   ; Test for for the tach module
ifdef	NOTACHENA
		GOTO	NoTach
endif
		BTFSC	PORTH,TACHENA,A
		GOTO	NoTach
   ; Here if tach module is present
   	; If timer 0 is enabled then save its value and advance blade counter
	        BTFSS	T0CON,TMR0ON,A
   		GOTO	TimerOff
		MOVFF 	TMR0L,BladeTime
		MOVFF	TMR0H,BladeTime+1	; Save blade time count
		MOVLB	HIGH  BladeDet
		INCF	BladeDet		; Advance blade detector count
		BTFSC	ALUSTA,Z
		INCF	BladeDet+1
		BCF	INTCON3,INT1IF,A
		RETURN
   	; If timer 0 is disabled and blade counter is 0 then enable counter
TimerOff   	
		MOVLB	HIGH  BladeDet
		MOVF 	BladeDet,W
		IORWF	BladeDet+1,W
		BCF	INTCON3,INT1IF,A
		BTFSS	ALUSTA,Z
		RETURN   			; If blade count is non zero, exit
   		; Enable counter
		CLRF	WREG
		MOVFF	WREG,TMR0H
		MOVFF	WREG,TMR0L
	        BSF	T0CON,TMR0ON,A
		BCF	INTCON3,INT1IF,A
		RETURN	
   ; Here if no tach module has been detected
NoTach
	; Toggle the edge trigger and read status
	        BTG	INTCON2,INTEDG1,A
	; If the Auto Trim button is not pressed then exit. This state is indicated
	; by INT1 being low prority
        	BTFSS	INTCON3,INT1IP,A	; If INT1 is set to low priority then exit
        	GOTO	INT1ISR_EXIT		
	; Test the SHIFT value 
		MOVLB	HIGH SHIFT
		BTFSS	SHIFT,0
		GOTO	ACESHIFT
	; Here for normal shift 
	        BTFSS	INTCON2,INTEDG1,A
	        BSF	PORTF,MOD,A		; Reversed for 2.0l
	        BTFSC	INTCON2,INTEDG1,A
	        BCF	PORTF,MOD,A
	        GOTO	INT1ISR_EXIT
ACESHIFT                       
	; Here for ACE shift
	        BTFSS	INTCON2,INTEDG1,A
	        BCF	PORTF,MOD,A
	        BTFSC	INTCON2,INTEDG1,A
	        BSF	PORTF,MOD,A
	; Exit
INT1ISR_EXIT    
		BCF	INTCON3,INT1IF,A
                RETURN



;
; Delay subroutine. Delay = 2uS * WREG value
;
Delay2uS
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

		Include	<EEPROM.asm>
		Include	<Flash.asm>
		
ifdef		LCD52display
		Include	<lcd52.asm>
endif
ifdef           SED1230display
		Include	<sed1230.asm>
endif
ifdef           ECMA1010display
		Include	<ECMA1010.asm>
endif
ifdef		MicroProStar
		Include <MP8000.asm>
endif
		Include	<Display.asm>
		Include	<comms.asm>
		Include	<FMS.asm>
		Include	<Math.asm>
		Include	<Monitor.asm>

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
		MOVFF	CEXreg+1,TTMH
		MOVFF	CEXreg+2,TTMH+1
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
		CALL	SaveAircraftPage1
		; exit 
		BCF	ALUSTA,Z
		RETURN

; This function uses the generic parameter locations to calculate
; the joy stick position.
CenterNormalize
	; Is pos > center ?
		MOVLR	HIGH AXreg
		; AXreg = Pos - Ct
		MOVFP	Pos,W
		MOVPF	WREG,AXreg
		MOVFP	Pos+1,W
		MOVPF	WREG,AXreg+1
		MOVFP	Ct,W
		SUBWF	AXreg
		MOVFP	Ct+1,W
		SUBWFB	AXreg+1
		; If carry is set then Pos was less than Ct
		BTFSS	ALUSTA,C,A
		GOTO	CN1
	; If here then Pos >= Ct
		MOVFP	Gh,W
		MOVPF	WREG,BXreg
		MOVFP	Gh+1,W
		MOVPF	WREG,BXreg+1
		CALL	Mult1616
		; Get the ans divided by 256
		MOVFP	CEXreg+1,W
		MOVPF	WREG,Npos
		MOVFP	CEXreg+2,W
		MOVPF	WREG,Npos+1
		RETURN
	; If here then Pos < Ct
CN1
		MOVFP	Gl,W
		MOVPF	WREG,BXreg
		MOVFP	Gl+1,W
		MOVPF	WREG,BXreg+1
		CALL	Mult1616
		; Get the ans divided by 256
		MOVFP	CEXreg+1,W
		MOVPF	WREG,Npos
		MOVFP	CEXreg+2,W
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
		MOVF	Ct,W
		SUBWF	AXreg,F
		MOVF	Ct+1,W
		SUBWFB	AXreg+1,F
	; CEXreg = AXreg * Gh
		MOVE	Gh,BXreg
		CALL	Mult1616	; CEXreg = AXreg * BXreg
	; Npos = CEXreg/256
		MOVF	CEXreg+1,W
		MOVPF	WREG,Npos
		MOVF	CEXreg+2,W
		MOVPF	WREG,Npos+1
		RETURN
;
; This function will convert the raw ADC cound data into normalized
; joy stick position information. All channels except the throttle
; are normalized to -1000 to 1000. The throttle channel is normalized
; 0 to 1000.
; This function also allows a translation table to be refined to remap
; the control using a programmable table. This support is provided
; for, Ail,Ele,Rud,Tht,CH^, and CH7.
;
; The joy stick calibration parameters are used for this calculation.
;
CalculateNormalizedPositions
	; Copy the position data to page 8 for use my the PC interface
		MOVEC	Apos, Src
		MOVEC	Apos, Dst
		MOVLW	8
		MOVFF	WREG,Dst+1
		MOVLW	26
		MOVWF	Cnt
		CALL	BlkMove
	; Aielron
		MOVLW	ADCail
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	AHG,Gh
		MOVE	ACT,Ct
		MOVE	ALG,Gl
		; Normalize it!
		CALL	CenterNormalize
		MOVE	Npos,AXreg
		MOVFF	AILremap,Breg
		SWAPF	Breg,F,A
		CALL	Translation
		MOVE	AXreg,ATpos
		MOVE	AXreg,Apos
	; Elevator
		MOVLW	ADCele
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	EHG,Gh
		MOVE	ECT,Ct
		MOVE	ELG,Gl
		; Normalize it!
		CALL	CenterNormalize
		MOVE	Npos,AXreg
		MOVFF	ELEremap,Breg
		SWAPF	Breg,F,A
		CALL	Translation
		MOVE	AXreg,ETpos
		MOVE	AXreg,Epos
	; Rudder
		MOVLW	ADCrud
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	RHG,Gh
		MOVE	RCT,Ct
		MOVE	RLG,Gl
		; Normalize it!
		CALL	CenterNormalize
		MOVE	Npos,AXreg
		MOVFF	RUDremap,Breg
		SWAPF	Breg,F,A
		CALL	Translation
		MOVE	AXreg,RTpos
		MOVE	AXreg,Rpos
	; Throttle
		MOVLW	ADCthr
		CALL	ADCread
		MOVLW	ADCthr
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	THG,Gh
		MOVE	TCT,Ct
		; Normalize it!
		CALL	NonCenterNormalize
		MOVE	Npos,AXreg
		MOVFF	THTremap,Breg
		SWAPF	Breg,F,A
		CALL	Translation
		MOVE	AXreg,TTpos
		MOVE	AXreg,Tpos
		MOVE	AXreg,Tnorm
	; The ADC reference input is read and saved here, this value represent the battery
	; voltage.
		MOVLW	ADCref
		CALL	ADCread
		; Save data in Vbat
		MOVLR	HIGH Vbat
		MOVLB	HIGH ADRESL
		MOVPF	ADRESL,WREG
		MOVPF	WREG,Vbat
		MOVPF	ADRESH,WREG
		MOVPF	WREG,Vbat+1
	; This section contains the normalization code for the trims found
	; on a MicroPro 8000
	; Aielron trim
		MOVLW	ADCailTrim
		CALL	ADCread
		; Now normalize
		MOVE	AtrimCT,Ct
		MOVE	AtrimHG,Gh	
		CALL	NonCenterNormalize
		MOVE	Npos,Atrim
	; Elevator trim
		MOVLW	ADCeleTrim
		CALL	ADCread
		; Now normalize
		MOVE	EtrimCT,Ct
		MOVE	EtrimHG,Gh	
		CALL	NonCenterNormalize
		MOVE	Npos,Etrim
	; Rudder trim
		MOVLW	ADCrudTrim
		CALL	ADCread
		; Now normalize
		MOVE	RtrimCT,Ct
		MOVE	RtrimHG,Gh	
		CALL	NonCenterNormalize
		MOVE	Npos,Rtrim
	; Throttle trim
		MOVLW	ADCthrTrim
		CALL	ADCread
		; Now normalize
		MOVE	TtrimCT,Ct
		MOVE	TtrimHG,Gh	
		CALL	NonCenterNormalize
		MOVE	Npos,Ttrim
	; CH5, -1000 or 1000
		MOVLR	HIGH SWCH5
		MOVFP	SWCH5,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CH5_OFF
		MOVEC	D'1000',CH5pos
		GOTO	CH5_Done
CH5_OFF
		MOVEC	-D'1000',CH5pos	
CH5_Done
	; CH6
		MOVLW	ADCch6
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	CH6HG,Gh
		MOVE	CH6CT,Ct
		; Normalize it!
		CALL	NonCenterNormalize
		MOVE	Npos,AXreg
		MOVFF	CH6remap,Breg
		SWAPF	Breg,F,A
		CALL	Translation
		MOVE	AXreg,CH6pos
	; CH7
		MOVLW	ADCch7
		CALL	ADCread
		; Move all parameters to normalized space
		MOVE	CH7HG,Gh
		MOVE	CH7CT,Ct
		; Normalize it!
		CALL	NonCenterNormalize
		MOVE	Npos,AXreg
		MOVFF	CH7remap,Breg
		SWAPF	Breg,F,A
		CALL	Translation
		MOVE	AXreg,CH7pos
	; CH8, -1000, 0, or 1000
		MOVLR	HIGH SWCH8A
		MOVFP	SWCH8A,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CH8_c
		MOVEC	D'1000',CH8pos
		GOTO	CH8_Done
CH8_c
		MOVLR	HIGH SWCH8C
		MOVFP	SWCH8C,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CH8_b
		MOVEC	0FC18,CH8pos
		GOTO	CH8_Done
CH8_b
		MOVLR	HIGH SWCH8B
		MOVFP	SWCH8B,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	CH8_Done
		MOVEC	0,CH8pos
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
	; Elevator
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

; This function is called to test the center beep for all the trims and CH6/7. If any one of these
; has changed sign, crossed center, and it has been enabled, then a sound is generated.
CenterBeep
	; Test sign change beep flag and exit is clear	
		MOVFF	TrimBeepSignChange,WREG
		COMF	WREG
		TSTFSZ	WREG
		RETURN
	; Clear the flag and beep!		
		CLRF	WREG
		MOVFF	WREG,TrimBeepSignChange
		MOVLW	D'3'  
		MOVLR	HIGH BeepCyl
		MOVWF	BeepCyl
		MOVLW	D'3'
		CALL	Beep
		RETURN
		
; This function updates all the center beep controls based on the state of the enable flags. These
; center beep functions support A,E,R, and T trims as well as channels 6 and 7. This routine sets
; a center beed flag if any control is detected to cross center. Three flags control this routine
; and only enabled center beep channels are tested. The flag has to be set to enable the center
; beep test:
;
;	TrimCenterBeepFlag = enables A,E,R trims
;	ThtTCenterBeepFlag = enables T trim
;	CH67CenterBeepFlag = CH6 and CH7
;
UpdateLastPos
	; Test enable flag and bypass the test is not set
		MOVFF	TrimCenterBeepFlag,WREG
		COMF	WREG
		TSTFSZ	WREG
		GOTO	ULP0
	; Aileron
		MOVE	DTail,BXreg			; in case its a digital trim
		MOVLR	HIGH AilTrimCh
		MOVFP	AilTrimCh,WREG
		CALL	SelectTrim			; Loads BXreg with trim value
		MOVE	BXreg,AXreg
		MOVE	AtrimLast,BXreg
		CALL	UpdateLast
		SETF	WREG
		BTFSC	ALUSTA,C
		MOVFF	WREG,TrimBeepSignChange
		MOVE	BXreg,AtrimLast
	; Elevator
		MOVE	DTele,BXreg			; in case its a digital trim
		MOVLR	HIGH EleTrimCh
		MOVFP	EleTrimCh,WREG
		CALL	SelectTrim			; Loads BXreg with trim value
		MOVE	BXreg,AXreg
		MOVE	EtrimLast,BXreg
		CALL	UpdateLast
		SETF	WREG
		BTFSC	ALUSTA,C
		MOVFF	WREG,TrimBeepSignChange
		MOVE	BXreg,EtrimLast
	; Rudder
		MOVE	DTrud,BXreg			; in case its a digital trim
		MOVLR	HIGH RudTrimCh
		MOVFP	RudTrimCh,WREG
		CALL	SelectTrim			; Loads BXreg with trim value
		MOVE	BXreg,AXreg
		MOVE	RtrimLast,BXreg
		CALL	UpdateLast
		SETF	WREG
		BTFSC	ALUSTA,C
		MOVFF	WREG,TrimBeepSignChange
		MOVE	BXreg,RtrimLast		
ULP0
	; Test enable flag and bypass the test is not set
		MOVFF	ThtTCenterBeepFlag,WREG
		COMF	WREG
		TSTFSZ	WREG
		GOTO	ULP1
	; Throttle
		MOVE	DTtht,BXreg			; in case its a digital trim
		MOVLR	HIGH ThtTrimCh
		MOVFP	ThtTrimCh,WREG
		CALL	SelectTrim			; Loads BXreg with trim value
		MOVE	BXreg,AXreg
		MOVE	TtrimLast,BXreg
		CALL	UpdateLast
		SETF	WREG
		BTFSC	ALUSTA,C
		MOVFF	WREG,TrimBeepSignChange
		MOVE	BXreg,TtrimLast		
ULP1
	; Test enable flag and bypass the test is not set
		MOVFF	CH67CenterBeepFlag,WREG
		COMF	WREG
		TSTFSZ	WREG
		RETURN
	; CH6
		MOVE	CH6pos,AXreg
		MOVE	CH6Last,BXreg
		CALL	UpdateLast
		SETF	WREG
		BTFSC	ALUSTA,C
		MOVFF	WREG,TrimBeepSignChange
		MOVE	BXreg,CH6Last		
	; CH7
		MOVE	CH7pos,AXreg
		MOVE	CH7Last,BXreg
		CALL	UpdateLast
		SETF	WREG
		BTFSC	ALUSTA,C
		MOVFF	WREG,TrimBeepSignChange
		MOVE	BXreg,CH7Last		
		RETURN
		
; This funcion will update the last values for the beep function. The last
; values are set to the current values if they have changed by a minimun 
; amount. This is to keep the beep function from going off all the time if the 
; Trim is sitting on zero.
; On call
;	AXreg = Current trim position
;	BXreg = Last trim position
;	CXreg is used
; On return
;	BXrex = New last position value
; 	The carry flag is set if the last value is updated and its sign changed
UpdateLast
	; Subtract the trim from the last value
		MOVE	AXreg,CXreg
		MOVLR	HIGH CXreg
		MOVFF	BXreg,WREG
		SUBWF	CXreg
		MOVFF	BXreg+1,WREG
		SUBWFB	CXreg+1
		; determine the absolute value
		BTFSS	CXreg+1,7
		GOTO	UL1
		COMF	CXreg
		COMF	CXreg+1
		INCF	CXreg
		BTFSC	ALUSTA,Z
		INCF	CXreg+1
UL1
		; Divide by 32
		BCF	ALUSTA,C
		RRCF	CXreg+1
		RRCF	CXreg
		BCF	ALUSTA,C
		RRCF	CXreg+1
		RRCF	CXreg
		BCF	ALUSTA,C
		RRCF	CXreg+1
		RRCF	CXreg
		BCF	ALUSTA,C
		RRCF	CXreg+1
		RRCF	CXreg
		BCF	ALUSTA,C
		RRCF	CXreg+1
		RRCF	CXreg
		; If CXreg is zero then change is too small to update the last value
		MOVFF	CXreg,WREG
		IORWF	CXreg+1
		BCF	ALUSTA,C
		BTFSC	ALUSTA,Z
		RETURN
		; If the sign changed then set the carry flag
		MOVFF	AXreg+1,WREG
		XORWF	BXreg+1,W
		RLCF	WREG
		; Move current position to last
		MOVE	AXreg,BXreg
		RETURN

; This function is called to apply the trim position information to the
; normalized final channel position.
ApplyTrims
	; Aielron
		MOVE	DTail,BXreg			; in case its a digital trim
		MOVLR	HIGH AilTrimCh
		MOVFP	AilTrimCh,WREG
		CALL	SelectTrim			; Loads BXreg with trim value
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
		RLCF	AXreg				; Multiply by 2
		RLCF	AXreg+1
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
		MOVE	DTele,BXreg			; in case its a digital trim
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
		RLCF	AXreg			; Multiply by 2
		RLCF	AXreg+1
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
		MOVE	DTrud,BXreg			; in case its a digital trim
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
		RLCF	AXreg			; Multiply by 2
		RLCF	AXreg+1
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
		MOVE	DTtht,BXreg			; in case its a digital trim
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
		
ApplySubTrims
	; Add all the sub trim values to the position data
		; Aileron sub trim
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		MOVFF	SubTrim,AXreg
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	CEXreg,WREG
		ADDWF	Apos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Apos+1,F
		; Elevator sub trim
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		MOVFF	SubTrim+1,AXreg
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	CEXreg,WREG
		ADDWF	Epos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Epos+1,F
		; Rudder sub trim
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		MOVFF	SubTrim+2,AXreg
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	CEXreg,WREG
		ADDWF	Rpos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Rpos+1,F
		; Throttle sub trim
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		MOVFF	SubTrim+3,AXreg
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	CEXreg,WREG
		ADDWF	Tpos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Tpos+1,F
		; CH5 sub trim
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		MOVFF	SubTrim+4,AXreg
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	CEXreg,WREG
		ADDWF	CH5pos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	CH5pos+1,F
		; CH6 sub trim
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		MOVFF	SubTrim+5,AXreg
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	CEXreg,WREG
		ADDWF	CH6pos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	CH6pos+1,F
		; CH7 sub trim
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		MOVFF	SubTrim+6,AXreg
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	CEXreg,WREG
		ADDWF	CH7pos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	CH7pos+1,F
		; CH8 sub trim
		MOVLB	HIGH AXreg
		CLRF	AXreg+1
		MOVFF	SubTrim+7,AXreg
		BTFSC	AXreg,7
		SETF	AXreg+1
		MOVEC	D'10',BXreg
		CALL	Mult1616
		MOVFP	CEXreg,WREG
		ADDWF	CH8pos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	CH8pos+1,F
		RETURN

; This function applies the right and left snap switch. The snap position is
; added to the current servo position for A,E, and R. Throttle is set. In all
; cases the channel is changed only if the enable flag is set.
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
		MOVLR	HIGH Apos
		MOVFF	CEXreg,WREG
		ADDWF	Apos
		MOVFF	CEXreg+1,WREG
		ADDWFC	Apos+1
AS9a		
		MOVLR	HIGH SR_E
		BTFSS	SR_E+1,7
		GOTO	AS9b
		MOVEB	SR_E,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVLR	HIGH Epos
		MOVFF	CEXreg,WREG
		ADDWF	Epos
		MOVFF	CEXreg+1,WREG
		ADDWFC	Epos+1
AS9b		
		MOVLR	HIGH SR_R
		BTFSS	SR_R+1,7
		GOTO	AS9c
		MOVEB	SR_R,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVLR	HIGH Rpos
		MOVFF	CEXreg,WREG
		ADDWF	Rpos
		MOVFF	CEXreg+1,WREG
		ADDWFC	Rpos+1
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
		MOVLR	HIGH Apos
		MOVFF	CEXreg,WREG
		ADDWF	Apos
		MOVFF	CEXreg+1,WREG
		ADDWFC	Apos+1
AS10a		
		MOVLR	HIGH SL_E
		BTFSS	SL_E+1,7
		GOTO	AS10b
		MOVEB	SL_E,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVLR	HIGH Epos
		MOVFF	CEXreg,WREG
		ADDWF	Epos
		MOVFF	CEXreg+1,WREG
		ADDWFC	Epos+1
AS10b		
		MOVLR	HIGH SL_R
		BTFSS	SL_R+1,7
		GOTO	AS10c
		MOVEB	SL_R,BXreg
		CLRF    BXreg+1
		BTFSC   BXreg,7
		SETF    BXreg+1
		CALL	Mult1616
		MOVLR	HIGH Rpos
		MOVFF	CEXreg,WREG
		ADDWF	Rpos
		MOVFF	CEXreg+1,WREG
		ADDWFC	Rpos+1
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

; This function is used to slow the output channels slew rate. At this time
; only CH5 and CH8 can be programmed with a rate limit.
; The channel position variable i.e. CH5pos, is used as a setpoint and the
; slewed position is saved in CH5posActual. Down stream code has to be updated
; to use the right variable.
ApplySlewRate
	; Peocess CH5.
	; Determine the different between the CH5 current position and its 
	; setpoint position
		; If the CH5posActual is set to C0xx then set it to CH5pos, init flag
		MOVFF	CH5posActual+1,WREG
		XORLW	0xC0			; test the flag
		BZ	ASR5final
		; AXreg = Setpoint - Actual
		MOVE	CH5pos,AXreg
		MOVLR	HIGH AXreg
		MOVFF	CH5posActual,WREG
		SUBWF	AXreg,F
		MOVFF	CH5posActual+1,WREG
		SUBWFB	AXreg+1,F
		BTFSC	AXreg+1,7
		GOTO	ASR0
		; Here if AXreg is positive
		; AXreg = AXreg - step size
		MOVFF	CH5stepSize, WREG
		SUBWF	AXreg,F
		MOVFF	CH5stepSize+1, WREG
		SUBWFB	AXreg+1,F
		; If AXreg is negative then set the position to setpoint
		BTFSC	AXreg+1,7
		GOTO	ASR5final
		; If here move actual by step size
		MOVLR	HIGH CH5posActual
		MOVFF	CH5stepSize,WREG
		ADDWF	CH5posActual,F
		MOVFF	CH5stepSize+1,WREG
		ADDWFC	CH5posActual+1,F
		GOTO	ASRCH8			; Done, move to next channel
		; Here if AXreg is negative
ASR0
		; AXreg = AXreg + step size
		MOVFF	CH5stepSize, WREG
		ADDWF	AXreg,F
		MOVFF	CH5stepSize+1, WREG
		ADDWFC	AXreg+1,F
		; If AXreg is positive then set the position to setpoint
		BTFSS	AXreg+1,7
		GOTO	ASR5final
		; If here move actual by step size
		MOVLR	HIGH CH5posActual
		MOVFF	CH5stepSize,WREG
		SUBWF	CH5posActual,F
		MOVFF	CH5stepSize+1,WREG
		SUBWFB	CH5posActual+1,F
		GOTO	ASRCH8			; Done, move to next channel
		; Set to final position
ASR5final	
		MOVE	CH5pos, CH5posActual
	; Now process CH8
ASRCH8
		; If the CH8posActual is set to C0xx then set it to CH8pos, init flag
		MOVFF	CH8posActual+1,WREG
		XORLW	0xC0			; test the flag
		BZ	ASR8final
		; AXreg = Setpoint - Actual
		MOVE	CH8pos,AXreg
		MOVLR	HIGH AXreg
		MOVFF	CH8posActual,WREG
		SUBWF	AXreg,F
		MOVFF	CH8posActual+1,WREG
		SUBWFB	AXreg+1,F
		BTFSC	AXreg+1,7
		GOTO	ASR1
		; Here if AXreg is positive
		; AXreg = AXreg - step size
		MOVFF	CH8stepSize, WREG
		SUBWF	AXreg,F
		MOVFF	CH8stepSize+1, WREG
		SUBWFB	AXreg+1,F
		; If AXreg is negative then set the position to setpoint
		BTFSC	AXreg+1,7
		GOTO	ASR8final
		; If here move actual by step size
		MOVLR	HIGH CH8posActual
		MOVFF	CH8stepSize,WREG
		ADDWF	CH8posActual,F
		MOVFF	CH8stepSize+1,WREG
		ADDWFC	CH8posActual+1,F
		GOTO	ASRtht			; Done, move to next channel
		; Here if AXreg is negative
ASR1
		; AXreg = AXreg + step size
		MOVFF	CH8stepSize, WREG
		ADDWF	AXreg,F
		MOVFF	CH8stepSize+1, WREG
		ADDWFC	AXreg+1,F
		; If AXreg is positive then set the position to setpoint
		BTFSS	AXreg+1,7
		GOTO	ASR8final
		; If here move actual by step size
		MOVLR	HIGH CH8posActual
		MOVFF	CH8stepSize,WREG
		SUBWF	CH8posActual,F
		MOVFF	CH8stepSize+1,WREG
		SUBWFB	CH8posActual+1,F
		GOTO	ASRtht			; Done, move to next channel
		; Set to final position
ASR8final	
		MOVE	CH8pos, CH8posActual
	; Thw following code processes the slew rate limit for the throttle channel,
	; this is only used in the helicopter mode when entering and leaving the
	; throttle hold flight mode.	
ASRtht
		; If the TposActual is set to C0xx then set it to Tpos, init flag
		MOVFF	TposActual+1,WREG
		XORLW	0xC0			; test the flag
		BZ	ASRTfinal
		; AXreg = Setpoint - Actual
		MOVE	Tpos,AXreg
		MOVLR	HIGH AXreg
		MOVFF	TposActual,WREG
		SUBWF	AXreg,F
		MOVFF	TposActual+1,WREG
		SUBWFB	AXreg+1,F
		BTFSC	AXreg+1,7
		GOTO	ASR2
		; Here if AXreg is positive
		; AXreg = AXreg - step size
		MOVFF	TstepSize, WREG
		SUBWF	AXreg,F
		MOVFF	TstepSize+1, WREG
		SUBWFB	AXreg+1,F
		; If AXreg is negative then set the position to setpoint
		BTFSC	AXreg+1,7
		GOTO	ASRTfinal
		; If here move actual by step size
		MOVLR	HIGH TposActual
		MOVFF	TstepSize,WREG
		ADDWF	TposActual,F
		MOVFF	TstepSize+1,WREG
		ADDWFC	TposActual+1,F
		GOTO	ASRdone			; Done, move to next channel
		; Here if AXreg is negative
ASR2
		; AXreg = AXreg + step size
		MOVFF	TstepSize, WREG
		ADDWF	AXreg,F
		MOVFF	TstepSize+1, WREG
		ADDWFC	AXreg+1,F
		; If AXreg is positive then set the position to setpoint
		BTFSS	AXreg+1,7
		GOTO	ASRTfinal
		; If here move actual by step size
		MOVLR	HIGH TposActual
		MOVFF	TstepSize,WREG
		SUBWF	TposActual,F
		MOVFF	TstepSize+1,WREG
		SUBWFB	TposActual+1,F
		GOTO	ASRdone			; Done, move to next channel
		; Set to final position
ASRTfinal	
		MOVE	Tpos, TposActual
		MOVEC	D'2000',TstepSize	; This is a one shot function of the throttle
	; Exit
ASRdone
		RETURN

; This function perfroms the auto trim algorithm. If the autotrim
; buttom is pressed and one of the centering stick is not 
; centered then the trim position is adjusted.
; There are three AutoTrim modes determined by ATmode.
; ATmode:
;        0 = Standard mode, while you hold the auto trim button the
;            channel is moved in small increments. You can define the
;            increment size and time between adjustments.
;        1 = One shot mode, in this mode the entire adjustment is made
;            in one step.
;	 2 = Off
; The Auto Trim function will only allow a maximum of +- 20 percent adjustment
; of a channels position.
;
; Note: The Auto Trim value is saved in a signed 8 bit variable so in order
; to get 20% range the aut trim value is doubled before its added to the
; channel value.
AutoTrim
 	; Test if the ATmode is 2, off. Exit if this is the case. This is done with a bit
 	; test because the only value values are 0,1 and 2
		MOVLR	HIGH ATmode
		BTFSC	ATmode,1
		RETURN 		
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
		; Save the new value to Flash
AutoTrim1d
		CALL	SaveAircraftPage1
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
		; Save the new value to Flash
AutoTrim2d
		CALL	SaveAircraftPage1
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
		; Save the new value to Flash
AutoTrim3d
		CALL	SaveAircraftPage1
AutoTrim4
		RETURN


; This function takes the absolute value of the number in reg AXreg and limits
; it to 200 (20 %). This function is used by the AutoTrim algorithm
; The channel's normalized position must be in AXreg. Additionally the position
; information is tested to see if its over threshold.
; Zero flag is set if the channel is above threshold.
; The limited value is returned in WREG divided by 2.
;
; The channel value is divided by two before testing, this is done because
; The auto trim value is doubled be its applied.
AutoLimit   
	; First determine the absolute value
		MOVLB	HIGH AXreg
		BTFSS	AXreg+1,7
		GOTO	AutoLimit1
		COMF	AXreg
		COMF	AXreg+1
		INCF	AXreg
		BTFSC	ALUSTA,C
		INCF	AXreg+1
	; Now determine if its over the 20% limit. First divide by 2 then
	; test agianst 100.
AutoLimit1
		; Divide by 2
		BCF	ALUSTA,C
                RRCF    AXreg+1
                RRCF    AXreg
		; Limit test		
		TSTFSZ	AXreg+1
		GOTO	AutoLimit3
		MOVLW	D'100'
		CPFSGT	AXreg
		GOTO    AutoLimit2
	; Set limit to 100, this is the value used in the one shot mode it will
	; be doubled before its applied to get 20% range.
AutoLimit3	MOVEC	D'100',AXreg
	; Test Threshold. This is the trigger to indicate if the stick is off center
	; indicating auto trim function should be performed.
	; Set zero flag if above threshold.
AutoLimit2
		MOVFF	AXreg,WREG
		RLNCF	WREG
		MOVLB	HIGH ATthreshold
		SUBWF	ATthreshold,W
		MOVLB	HIGH AXreg
		BCF	ALUSTA,Z
		BTFSS	ALUSTA,C
		BSF	ALUSTA,Z
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
	; Aeliron
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
;		MOVE	Tpos,BXreg
		MOVE	TposActual,BXreg
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
		MOVE	CH5posActual,BXreg
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
CH6save
		CALL    ApplyLimit
		MOVE	AXreg,chCH6
	; CH7
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
	; CH8
		MOVE	CH8posActual,AXreg
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
		MOVFF    CEXreg+1,AXreg
		MOVFF    CEXreg+2,AXreg+1
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
		MOVLR	HIGH PORTElatchLow
		BTFSS	PORTElatchLow,OPTION
		GOTO	Option1
		BCF	PORTElatchLow,OPTION
		; Test if its been processed
		BTFSS	PORTElatch,OPTION
		GOTO	Option1
		; Beep one time to indicate we detected the
		; button...
		BCF	PORTElatch,OPTION
		MOVLW	D'1'
		MOVWF	BeepCyl
		MOVLW	D'5'
		CALL	Beep
		BSF	ALUSTA,C,A
		RETURN
Option1
		BCF	ALUSTA,C,A
		RETURN

; This function will load the general setup data from Flash into bank 2
; This data applies to all aircraft and includes the joy stick calibration
; parameters.
LoadGeneral
	; Setup variables...
	;   AXreg  = Destination address in ram
	;   CEXreg = Flash memory address 
	;   Areg   = Number of bytes to read
		MOVEC	200,AXreg
		MOVEC24	ConfigLoc,CEXreg
		CLRF	WREG,A
		MOVWF	Areg,A
	
		CALL	FlashRead	; Read the data
	; Load Aircraft number into current aircraft
		MOVLR	HIGH Aircraft
		MOVFP	Aircraft,W
		MOVLR	HIGH DefaultAircraft
		MOVWF	DefaultAircraft
	; Save the version data into the general area
		MOVLW	UPPER (MES2+D'10')		; Load pointer the the version number
		MOVWF	TBLPTRU,A
		MOVLW	HIGH (MES2+D'10')
		MOVWF	TBLPTRH,A
		MOVLW	LOW (MES2+D'10')
		MOVWF	TBLPTRL,A
		; Read the version number into RAM
		TBLRD*+
		MOVFF	TABLAT,Gversion
		TBLRD*+
		TBLRD*+
		MOVFF	TABLAT,Gversion+1
		TBLRD*+
		MOVFF	TABLAT,Gversion+2
		RETURN

; Writes the general parameters to Flash
SaveGeneral
	; Setup variables...
	;   AXreg  = Destination address in ram
	;   CEXreg = Flash memory address 
	;   Areg   = Number of bytes to read
		MOVEC	200,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVLW	4
		MOVWF	Areg,A
		CALL	FlashWrite	; Read the data
		RETURN
		
; This function loads just the aircraft name for the current aircraft
; number defined in WREG.
LoadAircraftName
	;   AXreg  = Destination address in ram
	;   CEXreg = Flash memory address 
	;   Areg   = Number of bytes to read
		; Convert aircraft number to page pointer into config area
		RLNCF	WREG
		DECF	WREG
		MOVWF	Breg,A		; Save page pointer
	; Load 16 bytes
		MOVEC	300,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVF	Breg,W,A
		ADDWF	CEXreg+1
		CLRF	WREG,A
		ADDWFC	CEXreg+2
		MOVLW	D'16'
		MOVWF	Areg,A
		CALL	FlashRead
		RETURN

; This function saves the Name (16 bytes) in the aircraft number defined in 
; WREG. The first 64 bytes of the selected aircraft is copied to ram block 8
; and then the Name is updated and copied back to flash.
SaveAircraftName
	; First read the first 64 bytes (1 page) of the selected aircraft
	;   AXreg  = Destination address in ram
	;   CEXreg = Flash memory address 
	;   Areg   = Number of bytes to read
		; Convert aircraft number to page pointer into config area
		RLNCF	WREG
		DECF	WREG
		MOVWF	Breg,A		; Save page pointer
		
		MOVEC	800,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVFP	Breg,W,A
		ADDWF	CEXreg+1
		CLRF	WREG,A
		ADDWFC	CEXreg+2
		MOVLW	D'64'
		MOVWF	Areg,A
	
		CALL	FlashRead
	; Now update the Name
		MOVEC	Name, Src
		MOVEC	Name, Dst
		MOVLR	HIGH Dst
		MOVLW	8		; Block 8
		MOVWF	Dst+1
		MOVLW	D'16'
		MOVWF	Cnt
		CALL	BlkMove
	; Write back to flash aircraft number
	;   AXreg  = Destination address in ram
	;   CEXreg = Flash memory address 
	;   Areg   = Number of bytes to read
		MOVEC	800,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVFP	Breg,W,A
		ADDWF	CEXreg+1
		CLRF	WREG,A
		ADDWFC	CEXreg+2
		MOVLW	1
		MOVWF	Areg,A
	
		CALL	FlashWrite	; Read the data
		RETURN

; This function will load the aircraft data from Flash memory.
; 	WERG = Aircraft number
LoadAircraft
	; Setup variables...
	;   AXreg  = Destination address in ram
	;   CEXreg = Flash memory address 
	;   Areg   = Number of bytes to read
		; Convert aircraft number to page pointer into config area
		RLNCF	WREG
		DECF	WREG
		MOVWF	Breg,A		; Save page pointer
	; Read first page		
		MOVEC	300,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVFP	Breg,W,A
		ADDWF	CEXreg+1
		CLRF	WREG,A
		ADDWFC	CEXreg+2
		MOVWF	Areg,A
		CALL	FlashRead	; Read the data
	; Read second page		
		MOVEC	400,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVFP	Breg,W,A
		INCF	WREG
		ADDWF	CEXreg+1
		CLRF	WREG,A
		ADDWFC	CEXreg+2
		MOVWF	Areg,A
		CALL	FlashRead	; Read the data
		RETURN
; 	WERG = Aircraft number
SaveAircraft
	; Setup variables...
	;   AXreg  = Destination address in ram
	;   CEXreg = Flash memory address 
	;   Areg   = Number of bytes to read
		; Convert aircraft number to page pointer into config area
		RLNCF	WREG
		DECF	WREG
		MOVWF	Creg,A		; Save Page pointer
	; Save first page
		MOVEC	300,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVFP	Creg,W,A
		ADDWF	CEXreg+1
		CLRF	WREG,A
		ADDWFC	CEXreg+2
		MOVLW	4
		MOVWF	Areg,A
		CALL	FlashWrite	; Write the data
	; Save second page
		MOVEC	400,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVFP	Creg,W,A
		INCF	WREG
		ADDWF	CEXreg+1
		CLRF	WREG,A
		ADDWFC	CEXreg+2
		MOVLW	4
		MOVWF	Areg,A
		CALL	FlashWrite	; Write the data		
		RETURN
		
; This function copies the aircraft setup data stored in page 3 and 4 to its backup
; location in page 6 and 7. This backup data is used for the alternate aircraft function.
BackupAircraft
		MOVEC	300, Src
		MOVEC	600, Dst
		MOVLW	0
		MOVWF	Cnt
		CALL	BlkMove

		MOVEC	400, Src
		MOVEC	700, Dst
		MOVLW	0
		MOVWF	Cnt
		CALL	BlkMove
		RETURN
		
; This functions saves the first page (64 bytes) of the aircraft configuration
; data to flash memory. The Aircraft number is used for the storage location.
SaveAircraftPage1
	; Setup variables...
	;   AXreg  = Destination address in ram
	;   CEXreg = Flash memory address 
	;   Areg   = Number of bytes to read
		MOVLR	HIGH Aircraft
		MOVFP	Aircraft,W
		; Convert aircraft number to page pointer into config area
		RLNCF	WREG
		DECF	WREG
		MOVWF	Areg,A		; Save page pointer
		
		MOVEC	300,AXreg
		MOVEC24	ConfigLoc,CEXreg
		MOVFP	Areg,W,A
		ADDWF	CEXreg+1
		CLRF	WREG,A
		ADDWFC	CEXreg+2
		MOVLW	1
		MOVWF	Areg,A
	
		CALL	FlashWrite	; Read the data
		RETURN

;
; Mixer routines...
;
; This routine will move all of the channel position data to the Mixed
; position variables.
;
; Scan all 12 mixers, if the from and to channel are the same and they are
; equal to Throttle, CH5 or CH8 (4,5, or 8), then do not use the actual
; position variables. This is to allow a mix to itself to work on the
; slew rate chanels. You cannot make slew rate work when mixing a channel
; to itself.
;
Move2Mix
	; Set the Mix values
		MOVE16	Apos,AposM
		MOVE16	Epos,EposM
		MOVE16	Rpos,RposM
		MOVE16	Tpos,TposM
		MOVE16	TposActual,TposM
		MOVE16	CH5posActual,CH5posM
		MOVE16	CH6pos,CH6posM
		MOVE16	CH7pos,CH7posM
		MOVE16	CH8posActual,CH8posM
	; Look through all mixers for mix to self examples
		MOVLW	HIGH M1Afrom
		MOVWF	FSR1H,A
		MOVLW	LOW M1Afrom
		MOVWF	FSR1L,A
		MOVLW	D'12'
		MOVFF	WREG,Areg
M2Mloop
		; Loop through all the mixers
		MOVFF	POSTINC1,WREG
		ANDLW	0x0F
		BTFSC	ALUSTA,Z
		GOTO	M2Mnext
		; Here if the mixer is defined
		XORWF	INDF1,W,A
		ANDLW	0x0F
		BTFSS	ALUSTA,Z
		GOTO	M2Mnext
		; Here with a mix to self detected
		MOVFF	INDF1,WREG
		ANDLW	0xF0
		IORLW	4
		CPFSEQ	INDF1
		GOTO	M2MtryCH5
		; Here if Throttle
		MOVE16	Tpos,TposM
		GOTO	M2Mnext	
M2MtryCH5
		MOVFF	INDF1,WREG
		ANDLW	0xF0
		IORLW	5
		CPFSEQ	INDF1
		GOTO	M2MtryCH8
		; Here if CH5
		MOVE16	CH5posActual,CH5posM
		GOTO	M2Mnext	
M2MtryCH8
		MOVFF	INDF1,WREG
		ANDLW	0xF0
		IORLW	8
		CPFSEQ	INDF1
		GOTO	M2Mnext
		; Here if CH8
		MOVE16	CH8posActual,CH8posM
		; Advanced through all mixers
M2Mnext
		MOVLW	4		; Advanced to next mixer, this was 5 fixed 12/19/2010
		ADDWF	FSR1L
		DECF	Areg
		BTFSS	ALUSTA,Z
		GOTO	M2Mloop
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
		BTFSS	ALUSTA,C
		GOTO	APmix2
		; Apply all four mix channels
		MOVLW	HIGH M1Afrom
		MOVWF	FSR1H,A
		MOVLW	LOW M1Afrom
		MOVWF	FSR1L,A
		CALL	Mixer
		MOVLW	LOW M1Bfrom
		MOVWF	FSR1L,A
		CALL	Mixer
		MOVLW	LOW M1Cfrom
		MOVWF	FSR1L,A
		CALL	Mixer
		MOVLW	LOW M1Dfrom
		MOVWF	FSR1L,A
		CALL	Mixer
APmix2
		CALL	Move2Mix
		MOVLR	HIGH SWMIX2
		MOVFP	SWMIX2,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	APmix3
		MOVLW	HIGH M2Afrom
		MOVWF	FSR1H,A
		MOVLW	LOW M2Afrom
		MOVWF	FSR1L,A
		CALL	Mixer
		CALL	Move2Mix
		MOVLW	LOW M2Bfrom
		MOVWF	FSR1L,A
		CALL	Mixer
		CALL	Move2Mix
		MOVLW	LOW M2Cfrom
		MOVWF	FSR1L,A
		CALL	Mixer
		CALL	Move2Mix
		MOVLW	LOW M2Dfrom
		MOVWF	FSR1L,A
		CALL	Mixer
APmix3
		CALL	Move2Mix
		MOVLR	HIGH SWMIX3
		MOVFP	SWMIX3,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	APdone
		MOVLW	HIGH M3Afrom
		MOVWF	FSR1H,A
		MOVLW	LOW M3Afrom
		MOVWF	FSR1L,A
		CALL	Mixer
		MOVLW	LOW M3Bfrom
		MOVWF	FSR1L,A
		CALL	Mixer
		MOVLW	LOW M3Cfrom
		MOVWF	FSR1L,A
		CALL	Mixer
		MOVLW	LOW M3Dfrom
		MOVWF	FSR1L,A
		CALL	Mixer
APdone
		RETURN

; This function calculates the fixed mixer functions:
;	Aileron to rudder
;	Rudder to aileron
;	Rudder to elevator
;	Throttle to elevator
; After these functions are performed the mixer
; position array data is copied back to the input
; position array. 
;	Dual elevator
;	VTAIL		Rudder and Elevator mix
;	ELEVON		Aileron and Elevator mix
;	DUALA		Dual aileron
; It is assumed the position variables have been copied to 
; the mixer array. The information is calculated using the
; mixer array as the source and the standard array as the 
; destination.
CalculateFixedMixers
	; Aileron to rudder mix
		MOVE	AposM,AXreg		; Load position data
		MOVFF	AilRudPos,BXreg		; Load positive mix level as default
		MOVLB	HIGH BXreg
		BTFSC	AXreg+1,7
		MOVFF	AilRudNeg,BXreg		; If pos is neg, load neg gain
		CLRF	BXreg+1
		BTFSC	BXreg,7
		SETF	BXreg+1			; Sign extend
		CALL	Mult1616		; CEXreg = AXreg * BXreg
		MOVEC	D'100',DEXreg
		CALL	Divide2416		; CEXreg = CEXreg / DEXreg
		; Add mix level in CEXreg to rudder position
		MOVLB	HIGH RposM
		MOVFF	CEXreg,WREG
		ADDWF	RposM
		MOVFF	CEXreg+1,WREG
		ADDWFC	RposM+1
	; Rudder to aileron mix
		MOVE	RposM,AXreg		; Load position data
		MOVFF	RudAilPos,BXreg		; Load positive mix level as default
		MOVLB	HIGH BXreg
		BTFSC	AXreg+1,7
		MOVFF	RudAilNeg,BXreg		; If pos is neg, load neg gain
		CLRF	BXreg+1
		BTFSC	BXreg,7
		SETF	BXreg+1			; Sign extend
		CALL	Mult1616		; CEXreg = AXreg * BXreg
		MOVEC	D'100',DEXreg
		CALL	Divide2416		; CEXreg = CEXreg / DEXreg
		; Add mix level in CEXreg to aileron position
		MOVLB	HIGH AposM
		MOVFF	CEXreg,WREG
		ADDWF	AposM
		MOVFF	CEXreg+1,WREG
		ADDWFC	AposM+1
	; Rudder to elevator mix
		MOVE	RposM,AXreg		; Load position data
		MOVFF	RudElePos,BXreg		; Load positive mix level as default
		MOVLB	HIGH BXreg
		BTFSC	AXreg+1,7
		MOVFF	RudEleNeg,BXreg		; If pos is neg, load neg gain
		CLRF	BXreg+1
		BTFSC	BXreg,7
		SETF	BXreg+1			; Sign extend
		CALL	Mult1616		; CEXreg = AXreg * BXreg
		MOVEC	D'100',DEXreg
		CALL	Divide2416		; CEXreg = CEXreg / DEXreg
		; Add mix level in CEXreg to elevator position
		MOVLB	HIGH EposM
		MOVFF	CEXreg,WREG
		ADDWF	EposM
		MOVFF	CEXreg+1,WREG
		ADDWFC	EposM+1
	; Throttle to elevator mix
		MOVE	TposM,AXreg		; Load position data
		MOVFF	ThtEle,BXreg		; Load mix level
		MOVLB	HIGH BXreg
;		BTFSC	AXreg+1,7		; This statement is a bug! GAA 12/19/11
		CLRF	BXreg+1
		BTFSC	BXreg,7
		SETF	BXreg+1			; Sign extend
		CALL	Mult1616		; CEXreg = AXreg * BXreg
		MOVEC	D'100',DEXreg
		CALL	Divide2416		; CEXreg = CEXreg / DEXreg
		; Add mix level in CEXreg to elevator position
		MOVLB	HIGH EposM
		MOVFF	CEXreg,WREG
		ADDWF	EposM
		MOVFF	CEXreg+1,WREG
		ADDWFC	EposM+1	
	; Copy the mix results to the position array
		MOVE	AposM,Apos
		MOVE	EposM,Epos
		MOVE	RposM,Rpos
;		MOVE	TposM,Tpos
		MOVE	TposM,TposActual
	; Dual Elevator mixing function. Use CH6 for the second elevator
		MOVLR	HIGH DualE
		BTFSS	DualE,0
		GOTO	AFM0z
		; Here if dual elevator mixing is enabled
		MOVE	EposM,CH6pos
AFM0z
	; VTAIL mixing, VTAIL flag is 0 if off
	;    Rudder   = Elevator/2 + Rudder/2
	;    Elevator = Elevator/2 - Rudder/2
		MOVLR	HIGH VTAIL
		BTFSS	VTAIL,0
		GOTO	AFM1
		; Here if the Vtail is enabled.
		MOVE	EposM,AXreg
		MOVE	RposM,BXreg
		MOVLR	HIGH AXreg
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
		MOVLR	HIGH AXreg
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
	; aileron channel
AFM2
		MOVLR	HIGH DUALA
		BTFSS	DUALA,0
		GOTO	AFM3
		; Here if the DUALA is enabled.
		MOVE	AposM,AXreg
		MOVE	AXreg,Apos
		MOVE	AXreg,CH7pos
		MOVLR	HIGH CH7pos
		COMF	CH7pos
		COMF	CH7pos+1
		INFSNZ	CH7pos
		INCF	CH7pos+1
		; Apply the diferential.
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
		GOTO	AFM2a
AFM2c
		MOVLR	HIGH CH7pos
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
		GOTO	AFM2a
AFM2d
		MOVLR	HIGH CH7pos
		MOVE	CH7pos,AXreg
		CALL	Mult1616	; CEXreg = AXreg * BXreg
		CALL	Divide2416
		MOVE	CEXreg,CH7pos
AFM2a
		; Apply flapperrons:
		;  Use the old CH7pos signal as the flap control.
		;  CH7pos/2 * gain / 100
		;  FPgain for positive gain
		;  FPgainN for negative gain
		MOVEC	D'100',DEXreg	; Will be used later as a divisor
		; If CROW is enabled and CROW switch is OFF then jump out
		MOVLR	HIGH CROWENA    ; Test for CROW enable...
		MOVFP	CROWENA,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		GOTO    AFM2aa          ; Jump if CROW is disabled
		MOVLR	HIGH SWCROW
		MOVFP	SWCROW,WREG
		CALL	SwitchTest
		BTFSS	ALUSTA,C
		GOTO	AFM2e           ; Jump out if CROW switch is off
		; Here if CROW mixing is enabled.
		MOVEC	D'1000',AXreg
		MOVFP	TposM,WREG
		SUBWF	AXreg,F
		MOVFP	TposM+1,WREG
		SUBWFB	AXreg+1,F	; AXreg = 1000 - TposM
                GOTO    AFM2aaa
		; Here to apply the flap, first calculate the position
AFM2aa
		MOVE	CH7posM,AXreg
AFM2aaa		MOVFF	FPgain,BXreg
		MOVLR	HIGH AXreg
		BTFSC	AXreg+1,7
		MOVFF	FPgainN,BXreg
		CLRF	BXreg+1
		BTFSC	BXreg,7
		COMF	BXreg+1
		CALL	Mult1616
		CALL	Divide2416		; Ans is now in CExreg
		; Apply to Apos...
		MOVFP	CEXreg,WREG
		ADDWF	Apos,F
		MOVFP	CEXreg+1,WREG
		ADDWFC	Apos+1,F
		; Apply to CH7pos...
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
	; Idle up. If set then channel 8 is used to enable
	; two idle up levels
AFM0
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

;
; This function applies the CCPM mixer. The CCPMmode flag defines the type of mixing that
; is applied:
;	0 = off
;	1 = 3 servo 120 degree
;	2 = 3 servo 140 degree
;	3 = 3 servo 90 degree
;
;    CH6   Ail
;	\ /
;	 |
;	Ele
;
; For 3 servos 120 degrees
; 	CH6 = CH6 - Ail - .5Ele
; 	Ail = CH6 + Ail - .5Ele
; 	Ele = CH6 + Ele
;
; For 3 servos 140 degrees, equal arm lengths
; 	CH6 = CH6 - Ail - Ele
; 	Ail = CH6 + Ail - Ele
; 	Ele = CH6 + Ele
;
;    CH6- -Ail
;	 |
;	Ele
;
; For 3 servos 90 degrees
; 	CH6 = CH6 - Ail
; 	Ail = CH6 + Ail
; 	Ele = CH6 + Ele
;
CCPMmixer
	; Exit if we are not in the helicopter mode
		MOVLR	HIGH Henable
		BTFSS	Henable,0
		RETURN
	; If mode is zero, exit
		MOVFF	CCPMmode,WREG
		IORWF	WREG
		BTFSC	ALUSTA,Z
		RETURN
	; Reverse the Ail input if the HArev flag is set
		MOVLR	HIGH HArev
		BTFSS	HArev,0
		GOTO	CCPM1
		; Here to reverse the sign
		MOVLR	HIGH Apos
		COMF	Apos
		COMF	Apos+1
		INCF	Apos
		BTFSC	ALUSTA,Z
		INCF	Apos+1
CCPM1
	; Reverse the Ele input if the HErev flag is set
		MOVLR	HIGH HErev
		BTFSS	HErev,0
		GOTO	CCPM2
		; Here to reverse the sign
		MOVLR	HIGH Epos
		COMF	Epos
		COMF	Epos+1
		INCF	Epos
		BTFSC	ALUSTA,Z
		INCF	Epos+1
CCPM2
	; First calculate 3 servo 90 degree because all 3 modes need these values
	; as a starting point
		MOVE	Apos,AXreg
		MOVE	Epos,BXreg
		MOVE	CH6pos,Apos
		MOVE	CH6pos,Epos
		MOVLR	HIGH Apos
		MOVFF	AXreg,WREG
		ADDWF	Apos
		MOVFF	AXreg+1,WREG
		ADDWFC	Apos+1
		MOVFF	AXreg,WREG
		SUBWF	CH6pos
		MOVFF	AXreg+1,WREG
		SUBWFB	CH6pos+1
		MOVFF	BXreg,WREG
		ADDWF	Epos
		MOVFF	BXreg+1,WREG
		ADDWFC	Epos+1
		; Exit if the CCPMmode is 3
		MOVFF	CCPMmode,WREG
		SUBLW	3
		BTFSC	ALUSTA,Z
		RETURN
	; Divide BXreg by 2
		MOVLR	HIGH BXreg
		BCF	ALUSTA,C
		BTFSC	BXreg+1,7
		BSF	ALUSTA,C
		RRCF	BXreg+1
		RRCF	BXreg
	; Calculate the 120 degree mode
		MOVLR	HIGH Apos
		MOVFF	BXreg,WREG
		SUBWF	CH6pos
		MOVFF	BXreg+1,WREG
		SUBWFB	CH6pos+1
		MOVFF	BXreg,WREG
		SUBWF	Apos
		MOVFF	BXreg+1,WREG
		SUBWFB	Apos+1
		; Exit if CCPMmode is 1
		MOVFF	CCPMmode,WREG
		SUBLW	1
		BTFSC	ALUSTA,Z
		RETURN
	; Calculate the 140 degree mode
		MOVLR	HIGH Apos
		MOVFF	BXreg,WREG
		SUBWF	CH6pos
		MOVFF	BXreg+1,WREG
		SUBWFB	CH6pos+1
		MOVFF	BXreg,WREG
		SUBWF	Apos
		MOVFF	BXreg+1,WREG
		SUBWFB	Apos+1
		RETURN

; This function applies the translation table, pointed to by the MS 4 bits
; of Breg, to the 16 bit value in AXreg.
Translation
	; Exit if table address is 0
		MOVFF	Breg,WREG
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
		MOVLB	HIGH EEXreg
		CLRF	EEXreg+1
		; CEXreg now contains the index into the tables number defined
		; in the upper 4 bit of Breg. Test this value, if its greater than
		; 9 set it to 9
		MOVLW	D'9'
		CPFSLT	CEXreg
		GOTO	Trans5
		MOVFF	Breg,WREG
		SWAPF	WREG
		DECF	WREG
		ANDLW	0F
		MOVFF	WREG,Breg
		BTFSC	WREG,3
		GOTO	Trans3
		GOTO	Trans4
	; Here if index is over 9, need to calculate a new remainder
Trans5
		MOVWF	CEXreg
		MOVE	AXreg,EEXreg
		MOVLW	LOW D'900'
		MOVLB	HIGH EEXreg
		SUBWF	EEXreg
		MOVLW	HIGH D'900'
		SUBWFB	EEXreg+1
		MOVFF	Breg,WREG
		SWAPF	WREG
		DECF	WREG
		ANDLW	0F
		MOVFF	WREG,Breg
		BTFSC	WREG,3
		GOTO	Trans3		
	; Load pointer to global table
Trans4
		MOVLW	HIGH Table1
		MOVFF	WREG,FSR2H
		; Index into table based table number in Breg
		MOVFF	Breg,WREG
		MULLW	D'11'
		MOVFP	PRODL,WREG
		ADDLW	LOW Table1	; WREG now holds index into the proper table
		GOTO	Trans2
	; Load pointer to aircraft table
Trans3
		MOVLW	HIGH Atable1
		MOVFF	WREG,FSR2H
		; Index into table based table number in Breg
		MOVFF	Breg,WREG
		BCF	WREG,3
		MULLW	D'11'
		MOVFP	PRODL,WREG
		ADDLW	LOW Atable1	; WREG now holds index into proper table
	; Load the table's last value and adjust pointer to selected byte
Trans2
		MOVFF	WREG,FSR2L
		; Load the table last value into Creg, we may need it on exit
		MOVFF	INDF2,Creg				
		; Index back to selected byte of table
		MOVFF	CEXreg,WREG
		ADDWF	FSR2L,F,A
	; Here to load the table pointers and calculate the translation
		MOVFF	POSTINC2,Areg	; A point in table
		MOVFF	INDF2,Breg	; B point in table
		; AXreg = B - A
		MOVLB	HIGH AXreg
		MOVFF 	Breg,AXreg 
		CLRF	AXreg+1
		BTFSC	Breg,7
		SETF	AXreg+1
		MOVFF 	Areg,WREG  
		SUBWF	AXreg,F
		MOVLW	00
		BTFSC	Areg,7
		MOVLW	0xFF	
		SUBWFB	AXreg+1,F		
;		MOVLB	HIGH AXreg	; Updated to code shown above as per Andrey Kondratev
;		MOVFF	Breg,AXreg
;		MOVFF	Areg,WREG
;		SUBWF	AXreg,F
;		CLRF	AXreg+1
;		BTFSC	AXreg,7
;		SETF	AXreg+1
		MOVE	EEXreg,BXreg
		CALL	Mult1616
		MOVEC	D'10',DEXreg
		CALL	Divide2416
		; A * 10 + CEXreg = the final position
		MOVF	Areg, W, A	; signed multiply
		MULLW	D'10'
		MOVLW 	D'10'
		BTFSC 	Areg, 7, A
		SUBWF	PRODH, F
		MOVFF	PRODL,WREG
		ADDWF	CEXreg,F
		MOVFF	PRODH,WREG
		ADDWFC	CEXreg+1,F
	; Now the final step, test the sign of Pos and adjust the result
		MOVE	CEXreg,AXreg
		MOVLB	HIGH Pos
		BTFSS	Pos+1,7
		RETURN
		; Here if input was negative, adjust output to 2(low) - AXreg
		; The table's final value is in the Creg
		MOVFF	Creg,WREG
		MULLW	D'20'
		MOVLW	D'20'		
		BTFSC	Creg,7,A
		SUBWF	PRODH,F
		
		MOVFF	PRODL,AXreg
		MOVFF	PRODH,AXreg+1
		MOVLB	HIGH AXreg
		MOVFF	CEXreg,WREG
		SUBWF	AXreg,F
		MOVFF	CEXreg+1,WREG
		SUBWFB	AXreg+1,F
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
		MOVFP	POSTINC1,WREG
		MOVFF	WREG,Breg
		ANDLW	0F
		BTFSC	ALUSTA,Z
		RETURN			; Not selected so exit!
		MOVFF	Breg,WREG
		CALL	GetFrom		; From channel data in AXreg
		CALL	Translation	; Apply the Translation table
		MOVE	AXreg,CXreg
		MOVFF	POSTINC1,Areg	; To channel to Areg
	; Now get the Zero point in percent
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
		MOVPF	POSTINC1,WREG
		MOVLR	HIGH AXreg
		; Test bit 6 of the To channel in Areg. If this bit is
		; set then we are going to do indirect mixing and the 
		; 4 LSBs of WREG define the channel number that is the mix level
		BTFSS	Areg,6,A
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
		MOVF	Areg,W,A
		CALL	ApplyMix
		RETURN
MixNeg		; Here if negative...
		MOVPF	POSTINC1,WREG
		MOVPF	POSTINC1,WREG
		MOVLR	HIGH AXreg
		; Test bit 5 of the To channel in Areg. If this bit is
		; set then we are going to do indirect mixing and the 
		; 4 LSBs of WREG define the channel number that is the mix level
		BTFSS	Areg,5,A
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
		MOVF	Areg,W,A
		CALL	ApplyMix
		RETURN


; This function will switch the aircraft parameters between
; the selected aircraft and the alternate aircraft. This 
; function is only valid in the RUN mode. An Alternate Aircraft
; array is used to support multiple switches, if more than one
; switch is on the higher array index takes precedence.
AlternateAircraft
	; Save the timer variables
		MOVEC	CNTmode,Src
		MOVEC	TempBlock,Dst
		MOVLW	5
		MOVWF	Cnt
		CALLF	BlkMove
	; Search the alternate aircraft array looking for a active 
	; selection. 
		MOVLW	LOW AltAircraft		; Point to end of array
		ADDLW	(2 * NumAlt) - 1
		MOVFF	WREG,FSR2L
		MOVLW	HIGH Backup
		MOVFF	WREG,FSR2H
		MOVLW	NumAlt			; Load counter
		MOVFF	WREG,Creg
	; Loop through all the alternate aircraft entries
AAloop
		MOVFF	POSTDEC2,WREG		; Get the alternate aircraft number
		IORWF	WREG			; Set flags
		BTFSC	STATUS,Z
		GOTO	AAnext
		; Here with non zero aircraft number
		MOVFF	INDF2,WREG		; Get the switch code
		CALL	SwitchTest
		BTFSC	STATUS,C
		GOTO	AAselected		; Load the selected aircraft
	; Advance to next entry and loop till done
AAnext
		MOVFF	POSTDEC2,WREG		; Advance to next array entry
		DECFSZ	Creg,F,A
		GOTO	AAloop
	; Exit if no alternate aircraft located. Make sure the default aircraft is loaded
		MOVFF	DefaultAircraft,WREG
		MOVLB	HIGH Aircraft
		CPFSEQ	Aircraft
		GOTO	AAload	
		RETURN
	; Here to load the selected aircraft
AAselected
		MOVFF	POSTINC2,WREG
		MOVFF	POSTINC2,WREG		; Get the aircraft number 
		; If this aircraft is loaded then exit
		MOVLB	HIGH Aircraft
		CPFSEQ	Aircraft
		GOTO	AAload
		RETURN
	; Here to load the aircraft
AAload
		MOVFF	WREG,Aircraft
		CALL	LoadAircraft
		; Restore the timer variables
		MOVEC	TempBlock,Src
		MOVEC	CNTmode,Dst
		MOVLW	5
		MOVWF	Cnt
		CALLF	BlkMove
		RETURN		


; This function moves data from the Src to Dst. Cnt contains the number
; of bytes to move.
; Uses: Areg
;	Indirect reg set 1 used for source
;	Indirect reg set 2 used for destination
BlkMove
	; Set up the regesters
		MOVLB	HIGH Src
		MOVF	Src,W
		MOVWF	FSR1L	
		MOVF	Src+1,W
		MOVWF	FSR1H	

		MOVLB	HIGH Dst
		MOVF	Dst,W
		MOVWF	FSR2L	
		MOVF	Dst+1,W
		MOVWF	FSR2H	
	; Get source byte
BlkMove1
		MOVFF	POSTINC1,WREG
		MOVFF	WREG,POSTINC2
	; Loop till all are sent...
		MOVLB	HIGH Cnt
		DECFSZ	Cnt
		GOTO	BlkMove1
		RETURN

;
; This function is called to initialize the button ID byte.
;
ButtonIDinit
	; Clear the switch ID byte
		MOVLB	HIGH SWID
		CLRF	SWID
	; Do the aileron DR
		MOVLB	HIGH SWAILDR
		MOVF	SWAILDR,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		BTFSC	ALUSTA,C,A
		BSF		SWID,0
	; Do the elevator DR
		MOVLB	HIGH SWELEDR
		MOVF	SWELEDR,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		BTFSC	ALUSTA,C,A
		BSF	    SWID,1
	; Do the rudder DR
		MOVLB	HIGH SWRUDDR
		MOVF	SWRUDDR,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		BTFSC	ALUSTA,C,A
		BSF		SWID,2
	; Do the preset
		MOVLB	HIGH SWPRESET
		MOVF	SWPRESET,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		BTFSC	ALUSTA,C,A
		BSF		SWID,3
	; Do the Auto Trim
		MOVLB	HIGH SWATRIM
		MOVF	SWATRIM,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		BTFSC	ALUSTA,C,A
		BSF		SWID,4
	; Do the Snap R
		MOVLB	HIGH SWSNAPR
		MOVF	SWSNAPR,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		BTFSC	ALUSTA,C,A
		BSF		SWID,5
	; Do the Snap L
		MOVLB	HIGH SWSNAPL
		MOVF	SWSNAPL,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		BTFSC	ALUSTA,C,A
		BSF		SWID,6
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
		MOVLB	HIGH SWAILDR
		MOVF	SWAILDR,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		CLRF	WREG,A
		BSF	WREG,0,A
		ANDWF	SWID,W
		; If carry flag is set and z flag is clear then no change
		BTFSS	ALUSTA,C,A
		GOTO	BID0
		BTFSS	ALUSTA,Z,A
		GOTO	BIDELE
		; Here with a change
		BTG	SWID,0
		PrintMess IDAILLOW
		GOTO	BIDEXIT
		; If carry flag is clear and z flag is set then no change
BID0
		BTFSC	ALUSTA,C,A
		GOTO	BIDELE
		BTFSC	ALUSTA,Z,A
		GOTO	BIDELE
		; Here with a change
		BTG	SWID,0
		PrintMess IDAILHI
		GOTO	BIDEXIT
BIDELE
		; Elevator DR
		MOVLB	HIGH SWELEDR
		MOVF	SWELEDR,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		CLRF	WREG,A
		BSF		WREG,1,A
		ANDWF	SWID,W
		; If carry flag is set and z flag is clear then no change
		BTFSS	ALUSTA,C,A
		GOTO	BID1
		BTFSS	ALUSTA,Z,A
		GOTO	BIDRUD
		; Here with a change
		BTG		SWID,1
		PrintMess IDELELOW
		GOTO	BIDEXIT
		; If carry flag is clear and z flag is set then no change
BID1
		BTFSC	ALUSTA,C,A
		GOTO	BIDRUD
		BTFSC	ALUSTA,Z,A
		GOTO	BIDRUD
		; Here with a change
		BTG		SWID,1
		PrintMess IDELEHI
		GOTO	BIDEXIT
BIDRUD
		; Rudder DR
		MOVLB	HIGH SWRUDDR
		MOVF	SWRUDDR,W
		CALL	SwitchTest
		MOVLB	HIGH SWID
		CLRF	WREG,A
		BSF		WREG,2,A
		ANDWF	SWID,W
		; If carry flag is set and z flag is clear then no change
		BTFSS	ALUSTA,C,A
		GOTO	BID2
		BTFSS	ALUSTA,Z,A
		GOTO	BIDPRESET
		; Here with a change
		BTG		SWID,2
		PrintMess IDRUDLOW
		GOTO	BIDEXIT
		; If carry flag is clear and z flag is set then no change
BID2
		BTFSC	ALUSTA,C,A
		GOTO	BIDPRESET
		BTFSC	ALUSTA,Z,A
		GOTO	BIDPRESET
		; Here with a change
		BTG		SWID,2
		PrintMess IDRUDHI
		GOTO	BIDEXIT
BIDPRESET
		; Preset
		MOVLB	HIGH SWPRESET
		MOVF	SWPRESET,W
		CALL	SwitchTest
		; If carry flag is set and bit 3 is not then display message.
		MOVLB	HIGH SWID
		BTFSS	ALUSTA,C,A
		GOTO	BID3
		BTFSC	SWID,3
		GOTO	BIDAUTOT
		BTG		SWID,3
		PrintMess IDPRESET
		GOTO	BIDEXIT
BID3
		BCF	SWID,3
BIDAUTOT
		; Auto trim
		MOVLB	HIGH SWATRIM
		MOVF	SWATRIM,W
		CALL	SwitchTest
		; If carry flag is set and bit 4 is not then display message.
		MOVLB	HIGH SWID
		BTFSS	ALUSTA,C,A
		GOTO	BID4
		BTFSC	SWID,4
		GOTO	BIDSNAPR
		BTG		SWID,4
		PrintMess IDAUTOT
		GOTO	BIDEXIT
BID4
		BCF	SWID,4
BIDSNAPR
		; SNAP right
		MOVLB	HIGH SWSNAPR
		MOVF	SWSNAPR,W
		CALL	SwitchTest
		; If carry flag is set and bit 5 is not then display message.
		MOVLB	HIGH SWID
		BTFSS	ALUSTA,C,A
		GOTO	BID5
		BTFSC	SWID,5
		GOTO	BIDSNAPL
		BTG		SWID,5
		PrintMess IDSNAPR
		GOTO	BIDEXIT
BID5
		BCF	SWID,5
BIDSNAPL
		; SNAP left
		MOVLB	HIGH SWSNAPL
		MOVF	SWSNAPL,W
		CALL	SwitchTest
		; If carry flag is set and bit 6 is not then display message.
		MOVLB	HIGH SWID
		BTFSS	ALUSTA,C,A
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
		MOVFF	WREG,TimeOut5
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
; Uses:
;	Areg
;
SwitchTest
        ; Test if this is control position trigger flag
		BTFSS	WREG,5
		GOTO	STgo
		BTFSS	WREG,4
        	GOTO	STgo
        	; Here if bits 4 and 5 are set
        	; Load the percentage and multiply it by 10 to make it
        	; into normalized position
        	MOVWF	Areg,A		; Save WREG
        	ANDLW	07		; Get the selection bits
        	ADDLW	LOW ATP		; Make index to percentage
        	MOVWF	FSR1L,A
		MOVLW	HIGH ATP
		MOVWF	FSR1H,A
		MOVF	POSTINC1,W,A	; Load the percentage into Wreg
		; Multiply by 10
		MOVLR	HIGH AXreg
		MOVWF	AXreg
		CLRF	AXreg+1
		BTFSC	WREG,7
		SETF	AXreg+1		; Sign extended into AXreg
		MOVEC	D'10',BXreg
		CALL	Mult1616	; Result in CEXreg
		; Now load the position pointer
		MOVF	Areg,W,A
		ANDLW	07
		RLNCF	WREG		; Make it into a word pointer
		ADDLW	LOW ATpos
		MOVWF	FSR1L,A		; Load the position pointer
		MOVLW	HIGH ATpos
		MOVWF	FSR1H,A
		MOVFF	POSTINC1,AXreg
		MOVFF	POSTINC1,AXreg+1 ; Load the position
		; Absolute value of AXreg
		MOVLB	HIGH AXreg
		BTFSS	AXreg+1,7
		GOTO	ST01
		COMF	AXreg
		COMF	AXreg+1
		INFSNZ	AXreg
		INCF	AXreg+1
ST01:
		; Test the position
		MOVFF	AXreg,WREG
		SUBWF	CEXreg
		MOVFF	AXreg+1,WREG
		SUBWFB	CEXreg+1,W   
		RLCF	WREG
		BTG	ALUSTA,C,A
		; If the Invert bit is set then invert the carry flag
		BTFSC	Areg,7,A
		RETURN
		BTG	ALUSTA,C,A
		RETURN
	; Test the on and off bits first
STgo
		BCF	ALUSTA,C,A
		BTFSC	WREG,5
		RETURN
		BSF	ALUSTA,C,A
		BTFSC	WREG,4
		RETURN
	; Now process the swith options...
		MOVLB	HIGH Atemp
		MOVWF	Atemp		; Save WREG
		CLRF	Btemp
	; If the And with next bit is set then set the LSB of Btemp
		BTFSC	WREG,6,A
		BSF	Btemp,0
		ANDLW	07		; get just the 3 LSBs
		INCF	WREG
		BSF	ALUSTA,C,A	; Set the carry flag
ST00
		RLCF	Btemp,F
		DECFSZ	WREG
		GOTO	ST00
	; Now the proper bit is set in Btemp
		MOVF	PORTDimage,W
		BTFSC	Atemp,3
		MOVF	PORTEimage,W
		ANDWF	Btemp,W
		BSF	ALUSTA,C,A
		CPFSEQ	Btemp
		BCF	ALUSTA,C,A
	; Test if the invert flag is set
		BTFSC	Atemp,7
		BTG	ALUSTA,C,A	
		RETURN

INCLUDE		<helicopter.asm>
INCLUDE		<tach.asm>
INCLUDE		<ui.asm>

;
; This function is called at startup to load a set of default parameters
; into bank 2, bank 3 and bank 4.
;
LoadDefaults
	; Bank2
	; Set table pointer
		MOVLW	UPPER DFTgeneral
		MOVWF	TBLPTRU,A
		MOVLW	HIGH DFTgeneral
		MOVWF	TBLPTRH,A
		MOVLW	LOW DFTgeneral
		MOVWF	TBLPTRL,A
	; Load counter
		MOVLW	00
		MOVWF	Areg,A
	; Setup indirection regs
		MOVLW	HIGH BNK2
		MOVWF	FSR1H,A
		MOVLW	LOW BNK2
		MOVWF	FSR1L,A
LoadDefaults1
		TBLRD*+
		MOVF	TABLAT,W,A
		MOVWF	POSTINC1,A
		DECF	Areg,F,A
		TBLRD*+
		MOVF	TABLAT,W,A
		MOVWF	POSTINC1,A
		DECFSZ	Areg,F,A
		GOTO	LoadDefaults1
LoadAircraftDefaults
	; Bank3	
	; Set table pointer
		MOVLW	UPPER DFTaircraft
		MOVWF	TBLPTRU,A
		MOVLW	HIGH DFTaircraft
		MOVWF	TBLPTRH,A
		MOVLW	LOW DFTaircraft
		MOVWF	TBLPTRL,A
	; Setup counter
		MOVLW	00
		MOVWF	Areg,A
	; Setup indirection
		MOVLW	HIGH BNK3
		MOVWF	FSR1H,A
		MOVLW	LOW BNK3
		MOVWF	FSR1L,A
LoadDefaults2
		TBLRD*+
		MOVF	TABLAT,W,A
		MOVWF	POSTINC1,A
		DECF	Areg,F,A
		TBLRD*+
		MOVF	TABLAT,W,A
		MOVWF	POSTINC1,A
		DECFSZ	Areg,F,A
		GOTO	LoadDefaults2
	; Bank4	
	; Set table pointer
		MOVLW	UPPER DFTaircraft2
		MOVWF	TBLPTRU,A
		MOVLW	HIGH DFTaircraft2
		MOVWF	TBLPTRH,A
		MOVLW	LOW DFTaircraft2
		MOVWF	TBLPTRL,A
	; Setup counter
		MOVLW	00
		MOVWF	Areg,A
	; Setup indirection
		MOVLW	HIGH BNK4
		MOVWF	FSR1H,A
		MOVLW	LOW BNK4
		MOVWF	FSR1L,A
LoadDefaults3
		TBLRD*+
		MOVF	TABLAT,W,A
		MOVWF	POSTINC1,A
		DECF	Areg,F,A
		TBLRD*+
		MOVF	TABLAT,W,A
		MOVWF	POSTINC1,A
		DECFSZ	Areg,F,A
		GOTO	LoadDefaults3
		RETURN

Include		<DigitalTrims.asm>
ifdef           ECMA1010display
Include         <DataS.asm>
else
ifdef		MicroProStar
Include         <dataMPS.asm>
else
ifdef		Catalan
Include         <data_ct.asm>
else
Include         <data.asm>
endif
endif
endif
;
; The following default tables are loaded instead of the Sprom for general setup parameters
; and aircraft specific setting. These are loaded if the Preset and Auto Trim buttons are
; held down at power up. These tables also hold the default data used to format the SPROM.
;
ifdef	MicroProStar
; General default setting for MicrProStar
DFTgeneral	DB 01,00,0F,00,0D2,00,00,00,0F,00,0D2,00,00,00,01E,00
		DB 0D2,00,00,072,05,0AF,00,020,0C,0C9,00,0F6,00,088,0C,0E1
		DB 00,02E,01,089,0C,0E5,00,087,00,015,08,0B6,0FE,0EB,0B,0C6
		DB 0FE,0DD,0B,053,01,0FD,0B,02D,01,092,0B,035,01,099,0B,030
		DB 01,09F,0B,00,00,08,00,01,04,09,010,019,024,031,040,051
		DB 064,00,013,024,033,040,04B,054,05B,060,063,064,00,01,02,03
		DB 06,0C,015,022,033,049,064,00,01B,031,042,04F,058,05E,061,062
		DB 063,064,00,0A,014,01E,028,032,03C,046,050,05A,064,00,014,028
		DB 03C,050,064,050,03C,028,014,00,00,05,0A,0F,014,019,028,037
		DB 046,055,064,00,0F,01E,02D,03C,04B,050,055,05A,05F,064,0A,0A
		DB 00,00,010,0BC,02,0FF,00,0A5,0E7,070,02,0F3,00,00,08,07
		DB 068,010,01,02,03,04,00,00,00,058,01,090,091,083,082,094
		DB 095,096,097,0B4,0B5,0B6,0B7,08C,08D,0E,0F,00,00,00,00,00
		DB 00,00,00,00,028,00,00,00,00,0A,00,00,08,032,030,06F
		DB 030,24,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
; Aircraft default settings for MicroProStar
DFTaircraft	DB 04D,04F,044,045,04C,020,030,031,020,020,020,020,020,020,020,020
		DB 00,0CD,00,0B8,0B,0CD,00,03C,019,00,00,00,0CD,00,0B8,0B
		DB 0CD,00,03C,019,00,00,00,0CD,00,0B8,0B,0CD,00,03C,019,00
		DB 00,00,09A,01,098,08,019,01,0D0,07,0CD,00,0B8,0B,0CD,00
		DB 0B8,0B,0CD,00,0B8,0B,0CD,00,0B8,0B,0CD,00,032,0FF,032,00
		DB 032,00,032,00,0CE,0FF,0CE,00,0CE,00,0CE,00,00,00,00,0A
		DB 0A,00,00,00,0A,0A,00,00,00,0A,0A,00,00,00,0A,0A
		DB 00,00,00,0A,0A,00,00,00,0A,0A,00,00,00,0A,0A,00
		DB 00,00,0A,0A,00,00,00,0A,0A,00,00,00,0A,0A,00,00
		DB 00,0A,0A,00,00,00,0A,0A,00,00,00,00,00,00,00,0A
		DB 00,00,00,00,00,02,00,00,00,00,00,00,00,0FF,080,081
		DB 082,083,084,085,086,087,089,08B,04B,08C,08D,08E,08F,01,00,08
		DB 010,00,087,04B,08C,084,00,020,00,00,00,00,00,0FF,08D,00
		DB 020,00,020,00,020,00,020,00,020,00,00,01,04,09,010,019
		DB 024,031,040,051,064,00,013,024,033,040,04B,054,05B,060,063,064
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

DFTaircraft2	DB 02,01,03,04,05,06,07,08,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,0D0,07,0D0,07,00,00,00
		DB 00,00,00,00,00,00,00,028,00,00,032,010,020,020,00,087
		DB 00,00,00,020,032,00,00,020,00,020,032,00,00,020,00,0D0
		DB 07,0D0,07,00,00,00,00,00,00,10,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
else
; General default settings for MicroStar
DFTgeneral	DB 01,00,0F,00,0D2,00,00,00,0F,00,0D2,00,00,00,01E,00			;200
		DB 0D2,00,00,0A0,04,089,00,0B,07,0B4,00,09E,00,05E,06,0D6		;210
		DB 00,086,00,05A,06,0C6,00,057,00,0CC,01,021,01,04C,04,02E		;220
		DB 01,0FB,03,035,01,0B,04,0C,01,09C,04,08C,00,0DC,08,08F		;230
		DB 00,0C1,08,00,00,08,00,01,04,09,010,019,024,031,040,051		;240
		DB 064,00,013,024,033,040,04B,054,05B,060,063,064,00,01,02,03		;250
		DB 06,0C,015,022,033,049,064,00,01B,031,042,04F,058,05E,061,062		;260
		DB 063,064,00,0A,014,01E,028,032,03C,046,050,05A,064,00,014,028		;270
		DB 03C,050,064,050,03C,028,014,00,00,05,0A,0F,014,019,028,037		;280
		DB 046,055,064,00,0F,01E,02D,03C,04B,050,055,05A,05F,064,0A,0A		;290
		DB 00,00,010,0BC,02,0FF,00,0A5,0E7,070,02,0F3,00,00,08,07		;2A0
		DB 094,011,01,02,03,04,00,00,00,058,01,00,01,02,083,04			;2B0
		DB 05,06,07,08,09,0A,0B,08C,08D,0E,0F,00,00,00,00,00			;2C0
		DB 00,00,00,00,028,00,00,00,00,0A,00,00,08,00,00,00			;2D0
		DB 30,24,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;2E0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;2F0
; Aircraft default settings for MicroStar
DFTaircraft	DB 04D,04F,044,045,04C,020,030,031,020,020,020,020,020,020,020,020	;300
		DB 00,0CD,00,0B8,0B,0CD,00,03C,019,00,00,00,0CD,00,0B8,0B		;310
		DB 0CD,00,03C,019,00,00,00,0CD,00,0B8,0B,0CD,00,03C,019,00		;320
		DB 00,00,09A,01,098,08,019,01,0D0,07,0CD,00,0B8,0B,0CD,00		;330
		DB 0B8,0B,0CD,00,0B8,0B,0CD,00,0B8,0B,0CD,00,032,0FF,032,00		;340
		DB 032,00,032,00,0CE,0FF,0CE,00,0CE,00,0CE,00,00,00,00,014		;350
		DB 014,00,00,00,0A,0A,00,00,00,0A,0A,00,00,00,0A,0A			;360
		DB 00,00,0F4,01,0A,00,00,00,0A,0A,00,00,00,0A,0A,00			;370
		DB 00,00,0A,0A,00,00,00,0A,0A,00,00,00,0A,0A,00,00			;380
		DB 00,0A,0A,00,00,00,0A,0A,00,00,00,00,00,00,00,0A			;390
		DB 00,00,00,00,00,02,00,00,00,00,00,00,00,0FF,080,081			;3A0
		DB 082,083,084,085,086,087,089,08B,04B,08C,08D,08E,08F,01,00,08		;3B0
		DB 010,00,087,04B,08C,084,00,020,00,00,00,00,00,0FF,08D,00		;3C0
		DB 020,00,020,00,020,00,020,00,020,00,00,01,04,09,010,019		;3D0
		DB 024,031,040,051,064,00,013,024,033,040,04B,054,05B,060,063,064	;3E0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;3F0

DFTaircraft2	DB 02,01,03,04,05,06,07,08,00,00,00,00,00,00,00,00			;400
		DB 00,00,00,00,00,00,00,00,00,0D0,07,0D0,07,00,00,00			;410
		DB 00,00,00,00,00,00,00,0B1,02,00,032,010,020,020,00,087		;420
		DB 00,00,00,020,032,00,00,020,00,020,032,00,00,020,00,0D0		;430
		DB 07,0D0,07,00,00,00,00,00,00,10,00,00,00,00,00,00			;440
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;450
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;460
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;470
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;480
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;490
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;4A0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;4B0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;4C0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;4D0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;4E0
		DB 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00			;4F0

endif

; This area is reserved to store the general and aircraft configuration data. 

ConfigLoc	org	0x10000

		cblock	0x10000
			CFGgeneral
		endc
		cblock	0x10000 + D'256'
			CFGaircraft
		endc

;CFGgeneral	res	D'256'

;CFGaircraft	res	(D'256') * 2 * NumAircraft
		
                END     ;required directive


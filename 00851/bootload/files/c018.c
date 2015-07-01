#pragma nolist
/* $Id: c018.c,v 1.11.4.1 2001/09/25 21:43:14 krt Exp $ */

/* Copyright (c)1999 Microchip Technology */

/* MPLAB-C18 startup code */

/* external reference to the user's main routine */
extern void main (void);
/* prototype for the startup function */
static void _entry (void);
static void _startup (void);
extern near char FPFLAGS;
#define RND 6

#pragma code _entry_scn=0x000200
static void
_entry (void)
{
_asm goto _startup _endasm}

#pragma code _startup_scn
static void
_startup (void)
{
  _asm
    // Initialize the stack pointer
    lfsr 1, _stack lfsr 2, _stack clrf TBLPTRU, 0 // 1st silicon doesn't do this on POR
    bsf FPFLAGS,RND,0 // Initalize rounding flag for floating point libs
_endasm loop:

  // Call the user's main routine
  main ();

  goto loop;
}                               /* end _startup() */
#pragma list

.area _DATA
selector:: 		.db #0
title1: 		.db #80, #76, #65, #89, #0
title2: 		.db #69, #88, #73, #84, #0
.area _CODE
.include "cpctelera.h.s"
.include "keyboard/keyboard.s"

updateSelectMenu:
	ld 		de, #0xC000
	ld 		a, #48
	ld 		c, a
	ld 		a, (selector)
	add		c
	call 	loadColors
	call 	cpct_drawCharM0_asm

	ld 		a, (selector)
	dec 	a

	cp 		#0
	jr 		z, exit
	jp 		m, play
	play:
		ld 		de, #0xC426
		ld 		a, #0x00
		ld 		c, #0x02
		ld 		b, #0x08
		call	cpct_drawSolidBox_asm

		ld 		de, #0xC336
		ld 		a, #0xFF
		ld 		c, #0x02
		ld 		b,	#0x08
		call	cpct_drawSolidBox_asm
		ret
	exit:
		ld 		de, #0xC336
		ld 		a, #0x00
		ld 		c, #0x02
		ld 		b,	#0x08
		call	cpct_drawSolidBox_asm

		ld 		de, #0xC426
		ld 		a, #0xFF
		ld 		c, #0x02
		ld 		b,	#0x08
		call	cpct_drawSolidBox_asm
		ret
loadMenu::
	ld 		de, #0xC336
	ld 		a, #0xFF
	ld 		c, #0x02
	ld 		b,	#0x08
	call		cpct_drawSolidBox_asm

	ld 		hl, #title1
 	call	loadColors
 	ld 		de, #0xC33E
 	call 	cpct_drawStringM0_asm

 	ld 		hl, #title2
 	call	loadColors
 	ld 		de, #0xC42E
 	call 	cpct_drawStringM0_asm
	ret
checkMenuInput::
	;;======
	;; Fran's approach
	;;======

	moveUp:
	call 	cpct_scanKeyboard_asm  	;checks a key is pressed
	ld 		hl, #Key_W			 	;loads key_D in hl
	call 	cpct_isKeyPressed_asm	 ;checks if the key loaded in hl is pressed
	cp 		#0 						 ;checks if debugger leaves a 0 behind, if it is 0, then D is not pressed
	jr 		z, moveDown				 ;This goes to Right not pressed

		;Up is pressed
		ld 		a, #0x00
		ld 		(selector), a
		call 	updateSelectMenu
		call 	moveDown
	moveDown:
	call 	cpct_scanKeyboard_asm
	ld 		hl, #Key_S				 	;loads key_W in hl
	call 	cpct_isKeyPressed_asm	 	;checks if the key loaded in hl is pressed
	cp 		#0 						 		;checks if debugger leaves a 0 behind, if it is 0, then W is not pressed
	jr 		z, select			 	 	;This goes to up not pressed

		;left is pressed
		ld 		a, #0x01
		ld 	    (selector), a
		call 	updateSelectMenu
		call  	select
	select:
	call 	cpct_scanKeyboard_asm
	ld 		hl, #Key_Space					;loads key_W in hl
	call 	cpct_isKeyPressed_asm	 		;checks if the key loaded in hl is pressed
	cp 		#0 						 		;checks if debugger leaves a 0 behind, if it is 0, then W is not pressed
	jr 		z, skipFuck			 	 ;This goes to up not pressed

		;space is pressed
		call	enterStart

	skipFuck:
		ret

loadColors:
	ld 		c, #0xFF 			
	ld 		b, #0xF0;

	ret

enterStart:
	ld 		a, (selector)
	dec 	a
	cp 		#0
	jr 		z, closeGame
	jp 		m, playGame
	
	playGame:
	ld 		a, #0x0A
	ld 		(selector), a

	ret
	closeGame:
	ld 		hl, (#0x0004)
	jp		(hl)
	ret

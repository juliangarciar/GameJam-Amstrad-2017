.area _DATA
video: 		.db #0xC000
life: 		.db #0x03
counter0: 	.db #0x30
counter1:	.db #0x30
counter2:	.db #0x30
counter3:	.db #0x30
title: 		.db #83, #67, #79, #82, #69, #58, #0
.area _CODE
.include "cpctelera.h.s"
loadHud::
	ld 		de, #0xC020
	call 	loadTitle			;Loading titles
	call 	drawHearths
	ret
hudUpdate::
	ld 		de, #0xC03B
	ld 		a, (counter3)
	call 	loadColors
	call 	cpct_drawCharM0_asm
	ld 		de, #0xC040
	ld 		a, (counter2)
	call 	loadColors
	call 	cpct_drawCharM0_asm
	ld 		de, #0xC045
	ld 		a, (counter1)
	call 	loadColors
	call 	cpct_drawCharM0_asm
	ld 		de, #0xC04A
	ld 		a, (counter0)
	call 	loadColors
	call 	cpct_drawCharM0_asm

	ret
updateGround::
	ld 		hl, #0xCDF0
		drawing:
		ld 		a, #0xFF
		ld 		(hl), a
		inc 	hl
		ld 		a, l
		sub 	#0x40
		jr 		nz, drawing
	ret
;Destroys 
incPoints::
	ld 		a, (counter0)
	cp 		#0x39
	jr 		z, incPoints1

	inc 	a
	ld 		(counter0), a
	ret
	incPoints1::
		ld 		a, #0x30
		ld 		(counter0), a
		ld 		a, (counter1)
		cp 		#0x39
		jr 		z, incPoints2

		inc 	a
		ld 		(counter1), a
		ret
	incPoints2::
		ld 		a, #0x30
		ld 		(counter1), a
		ld 		a, (counter2)
		cp 		#0x39
		jr 		z, incPoints3

		inc 	a
		ld 		(counter2), a
		ret
	incPoints3::
		ld 		a, #0x30
		ld 		(counter2), a
		ld 		a, (counter3)
		inc 	a
		ld 		(counter3), a
		ret
	
loadTitle:
    ld 		hl, #title
 	call	loadColors
 	call 	cpct_drawStringM0_asm

	ret
loadColors:
	ld 		c, #0xFF 			
	ld 		b, #0xF0

	ret
loadColorsHP:
	ld 		c, #0x03
	ld 		b, #0x02
	ret
loseHP::
	ld 		a, (life)
	dec 	a
	ld 		(life), a
	call 	drawHearths
	ret
drawHearths:
	ld 		de, #0xC000
	ld 		a, (life)
	ld 		c, a
	ld 		a, #0x30
	add 	c
	call 	loadColors
	call 	cpct_drawCharM0_asm
	;bucle:
	;	call 	loadColorsHP
	;	ld 		de, #0xC000
	;	inc 	e
	;	inc 	e
	;	ld 		(video), de
	;	ld 		a, #60
	;	call 	cpct_drawCharM0_asm

	;	call 	loadColorsHP
	;	ld 		de, #0xC004
	;	inc 	e
	;	inc 	e
	;	ld 		(video), de
	;	ld 		a, #51
	;	call 	cpct_drawCharM0_asm

	;	dec 	l
		;;jp 		nz, bucle
	
	ret
.area _DATA
.area _CODE
.include "cpctelera.h.s"
.include "control.h.s"

;==================
;;;PRIVATE DATA
;==================
bullet_x:: .db #0
bullet_y:: .db #0
bullet_w:: .db #0x02
bullet_alive:: .db #0
bullet_dir:: .db #0

moveDir:
	ld 		a, (bullet_dir)
	dec		a
	jp		z, left
	dec 	a
	jp		z, right
	dec 	a
	jp 		z, topLeft
	dec		a
	jp		z, topRight

	left:
		ld 		a, (bullet_x)
		dec 	a
		ld 		(bullet_x), a
		ret
	right:
		ld 		a, (bullet_x)
		inc 	a
		ld 		(bullet_x), a
		ret
	topLeft:
		ld 		a, (bullet_x)
		dec 	a
		ld 		(bullet_x), a

		ld 		a, (bullet_y)
		dec 	a
		;dec 	a
		ld 		(bullet_y), a
		ret
	topRight:
		ld 		a, (bullet_x)
		inc 	a
		ld 		(bullet_x), a
		
		ld 		a, (bullet_y)
		dec 	a
		;dec 	a
		ld 		(bullet_y), a
		ret

shootBullet::
	ld 		b, a
	ld 		a, (bullet_alive)
	cp 		#1
	jp		z, skipShoot
    

    ld 		a, b
 	ld 		(bullet_dir), a
 	dec		a
 	jp 		z, correccionIzq
 	dec		a
 	jp 		z, correccionDch
 		correccionIzq:
		ld 		a, (hero_x)
		dec 	a
		ld 		(bullet_x), a
		ld 		a, (hero_y)
		ld 		(bullet_y), a

		ld 	    a, #1
	 	ld 		(bullet_alive), a
	 		ret
 		correccionDch:
 		ld 		a, (hero_x)
 		add 	a, #4
		ld 		(bullet_x), a
		ld 		a, (hero_y)
		ld 		(bullet_y), a

		ld 	    a, #1
	 	ld 		(bullet_alive), a
 			ret
 	skipShoot:
	ret
shootUpdate::
	ld 		a, (bullet_alive)
	cp 		#0
	jp 		z, skipUpdate


	call 	eraseBullet
	call	checkBorders
	cp 		#1
	jp 		z, skipUpdate

	call 	moveDir
	;ld 		a, (bullet_x)
	;inc 	a
	;ld 		(bullet_x), a

	call 	drawBullet
	skipUpdate:
		
	ret
;;CORREGIR SIDA
checkBorders:
	ld		a, (bullet_x)
	cp 		#0x08
	jp 		z, outside

	ld		a, (bullet_x)
	cp 		#0x4F
	jp		z, outside

	ld 		a, (bullet_y)
	cp 		#0x67 
	
	jp		z, outside	

	ld 		a, (bullet_y)
	cp 		#0x00
	
	jp 		z, outside
	
	ret	
outside:
	ld 		a, (bullet_alive)
	dec 	a
	ld 		(bullet_alive), a
	
	call 	eraseBullet
	ld 		a, #0
	ld 		(bullet_x), a
	ld 		a, #0
	ld 		(bullet_y), a
	ld 		a, #1

	ld 		a, #0
	ld 		(bullet_dir), a

	ret
	
drawBullet::
	ld 		de, #0xC000
	ld 		a, (bullet_x)
	ld 		c, a
	ld 		a, (bullet_y)
	ld 		b, a

	call 	cpct_getScreenPtr_asm

	ex		de, hl
	ld 		a, #0xFF
	ld		bc, #0x0201
	call 	cpct_drawSolidBox_asm

	skipDraw:
	ret
;ESTO ES SUPER SIDOSO
eraseBullet:
	ld 		de, #0xC000
	ld 		a, (bullet_x)
	ld 		c, a
	ld 		a, (bullet_y)
	ld 		b, a

	call 	cpct_getScreenPtr_asm

	ex		de, hl
	ld 		a, #0x00
	ld		bc, #0x0201
	call 	cpct_drawSolidBox_asm

	skipDraw2:
	ret
.area _DATA
.area _CODE
.include "cpctelera.h.s"

;ARRAYS INFO
;MAYBE THERE'S NO NEED FOR GLOBALS
enemy1_x:: .db #0
enemy1_y:: .db #60
enemy1_width:: .db #0x02
enemy1_heigth:: .db #0x02
enemy1_alive: .db #1
enemy1_dir: .db #1

enemy2_x:: .db #0x9F
enemy2_y:: .db #70
enemy2_width:: .db #0x02
enemy2_heigth:: .db #0x02
enemy2_alive: .db #1
enemy2_dir: .db #0

;ENEMIES RUTINE
updateEnemys::
	call eraseEnemys
	call moveEnemys
	call drawEnemys
	ret
moveEnemys::
	;ENEMY 1
	moveEnemy1:
	;CHECK IF THAT ENEMY IS ALIVE, ELSE JUMP NEXT ONE
	ld 		a, (enemy1_alive)
	cp 		#0
	jp		z, moveEnemy2

	;CHECK IF HE'S GOING LEFT OR RIGHT
	ld		a, (enemy1_dir)
	cp  	#0
	jp		z, moveLeft1
	jp 		moveRight1
		;MOVE LEFT AND REFRESH POSITION
		moveLeft1:
		ld 		a, (enemy1_x)
		cp 		#0
		jp 		z, skipL1
		dec		a
		ld 		(enemy1_x), a
		jp 		moveEnemy2
			;SKIP MOVE IF HE'S OUT OF THE SCREEN
			;AND RESTART POSITION
			skipL1:
			ld		a, #0x9F
			ld		(enemy1_x), a
			jp 		moveEnemy2
		;SAME FOR RIGHT
		moveRight1:
		ld 		a, (enemy1_x)
		cp 		#159
		jp 		z, skipR1
		inc		a
		ld 		(enemy1_x), a
		jp 		moveEnemy2
			skipR1:
			ld		a, #0
			ld		(enemy1_x), a
			jp 		moveEnemy2
	;ENEMY 2
	moveEnemy2:
	ld 		a, (enemy2_alive)
	cp 		#0
	jp		z, doneMove

	ld		a, (enemy2_dir)
	cp  	#0
	jp		z, moveLeft2
	jp 		moveRight2
		moveLeft2:
		ld 		a, (enemy2_x)
		cp 		#0
		jp 		z, skipL2
		dec		a
		ld 		(enemy2_x), a
		jp 		doneMove
			skipL2:
			ld		a, #0x9F
			ld		(enemy2_x), a
			jp 		doneMove
		moveRight2:
		ld 		a, (enemy2_x)
		cp 		#159
		jp 		z, skipR2
		inc		a
		ld 		(enemy2_x), a
		jp 		doneMove
			skipR2:
			ld		a, #0
			ld		(enemy2_x), a
			jp 		doneMove
	doneMove:
	ret

dirEnemys::
	ret
checkBorders:
	ret
outside:
	ret
drawEnemys::
	enemy1draw:
	ld 		a, (enemy1_alive)
	cp 		#0
	jp		z, enemy2draw

	ld 		de, #0xC000
	ld 		a, (enemy1_x)
	ld 		c, a
	ld 		a, (enemy1_y)
	ld 		b, a

	call 	cpct_getScreenPtr_asm

	ex		de, hl
	ld 		a, #0xFF
	ld		bc, #0x0402
	call 	cpct_drawSolidBox_asm
	enemy2draw:
	ld 		a, (enemy1_alive)
	cp 		#0
	jp		z, doneDraw

	ld 		de, #0xC000
	ld 		a, (enemy2_x)
	ld 		c, a
	ld 		a, (enemy2_y)
	ld 		b, a

	call 	cpct_getScreenPtr_asm

	ex		de, hl
	ld 		a, #0xFF
	ld		bc, #0x0402
	call 	cpct_drawSolidBox_asm

	doneDraw:
	ret
eraseEnemys:
	enemy1erase:
	ld 		a, (enemy1_alive)
	cp 		#0
	jp		z, enemy2erase

	ld 		de, #0xC000
	ld 		a, (enemy1_x)
	ld 		c, a
	ld 		a, (enemy1_y)
	ld 		b, a

	call 	cpct_getScreenPtr_asm

	ex		de, hl
	ld 		a, #0x00
	ld		bc, #0x0402
	call 	cpct_drawSolidBox_asm
	enemy2erase:
	ld 		a, (enemy1_alive)
	cp 		#0
	jp		z, doneErase

	ld 		de, #0xC000
	ld 		a, (enemy2_x)
	ld 		c, a
	ld 		a, (enemy2_y)
	ld 		b, a

	call 	cpct_getScreenPtr_asm

	ex		de, hl
	ld 		a, #0x00
	ld		bc, #0x0402
	call 	cpct_drawSolidBox_asm

	doneErase:
	ret